const { pool } = require('../database');

// 默认等级成长加成（当数据库未提供 growth_multiplier 字段时兜底）
const DEFAULT_LEVEL_GROWTH_MULTIPLIER = { 1: 1.00, 2: 1.05, 3: 1.10, 4: 1.15 };

async function loadLevelMultipliers() {
	try {
		const [rows] = await pool.execute('SELECT level_type, growth_value_min, growth_value_max, growth_multiplier FROM member_level ORDER BY level_type');
		const map = {};
		for (const r of rows) {
			map[r.level_type] = r.growth_multiplier != null ? Number(r.growth_multiplier) : (DEFAULT_LEVEL_GROWTH_MULTIPLIER[r.level_type] ?? 1.0);
		}
		return map;
	} catch (e) {
		// 字段不存在或查询失败时，使用默认值
		return { ...DEFAULT_LEVEL_GROWTH_MULTIPLIER };
	}
}

async function getUserCoins(userId) {
	const [rows] = await pool.execute('SELECT coins FROM user WHERE id = ?', [userId]);
	if (rows.length === 0) throw new Error('用户不存在');
	return rows[0].coins;
}

async function getUserGrowth(userId) {
	const [rows] = await pool.execute('SELECT growth_value FROM user WHERE id = ?', [userId]);
	if (rows.length === 0) throw new Error('用户不存在');
	return rows[0].growth_value;
}

async function addCoins(userId, delta) {
	const [result] = await pool.execute('UPDATE user SET coins = coins + ? WHERE id = ?', [Number(delta) || 0, userId]);
	if (result.affectedRows === 0) throw new Error('用户不存在');
	return getUserCoins(userId);
}

async function addGrowth(userId, delta) {
	const [result] = await pool.execute('UPDATE user SET growth_value = growth_value + ? WHERE id = ?', [Math.max(0, Number(delta) || 0), userId]);
	if (result.affectedRows === 0) throw new Error('用户不存在');
	return recalcLevelByGrowth(userId);
}

async function recalcLevelByGrowth(userId) {
	// 读取当前成长值
	const [u] = await pool.execute('SELECT growth_value FROM user WHERE id = ?', [userId]);
	if (u.length === 0) throw new Error('用户不存在');
	const growth = u[0].growth_value;

	// 根据 member_level 的区间匹配等级
	const [levels] = await pool.execute('SELECT level_type, growth_value_min, growth_value_max FROM member_level ORDER BY level_type');
	let newLevelType = null;
	for (const lvl of levels) {
		const min = Number(lvl.growth_value_min);
		const max = lvl.growth_value_max == null ? Number.POSITIVE_INFINITY : Number(lvl.growth_value_max);
		if (growth >= min && growth <= max) {
			newLevelType = lvl.level_type;
			break;
		}
	}
	if (newLevelType == null && levels.length > 0) {
		newLevelType = levels[0].level_type;
	}

	if (newLevelType != null) {
		await pool.execute('UPDATE user SET level_type = ? WHERE id = ?', [newLevelType, userId]);
	}

	return { growth, level_type: newLevelType };
}

async function onOrderPaid(userId, amount) {
	// 读取当前等级
	const [u] = await pool.execute('SELECT level_type FROM user WHERE id = ?', [userId]);
	if (u.length === 0) throw new Error('用户不存在');
	const levelType = u[0].level_type || 1;

	const multipliers = await loadLevelMultipliers();
	const multiplier = multipliers[levelType] ?? 1.0;
	const numericAmount = Number(amount) || 0;

	// 简化规则：支付金额的整数部分计入 coins；成长值 = 金额 * 系数，向下取整
	const coinsDelta = Math.floor(numericAmount);
	const growthDelta = Math.floor(numericAmount * multiplier);

	await pool.execute('UPDATE user SET coins = coins + ?, growth_value = growth_value + ? WHERE id = ?', [coinsDelta, growthDelta, userId]);

	const levelInfo = await recalcLevelByGrowth(userId);
	return { coins_added: coinsDelta, growth_added: growthDelta, multiplier, ...levelInfo };
}

module.exports = {
	DEFAULT_LEVEL_GROWTH_MULTIPLIER,
	loadLevelMultipliers,
	getUserCoins,
	getUserGrowth,
	addCoins,
	addGrowth,
	recalcLevelByGrowth,
	onOrderPaid
};


