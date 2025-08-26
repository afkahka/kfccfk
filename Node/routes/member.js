const express = require('express');
const router = express.Router();
const { pool } = require('../database');
const MembershipService = require('../services/membership');

// 根路径：返回该模块的可用接口
router.get('/', async (req, res) => {
	res.json({
		success: true,
		message: '会员模块接口可用',
		endpoints: {
			levels: '/api/member/levels',
			levelDetail: '/api/member/levels/:levelType',
			rightCategories: '/api/member/right-categories',
			rights: '/api/member/rights?category=1',
			levelRights: '/api/member/levels/:levelType/rights',
			levelMainRights: '/api/member/levels/:levelType/main-rights',
			coins: '/api/member/:userId/coins',
			growth: '/api/member/:userId/growth',
			orderPaid: '/api/member/:userId/on-order-paid',
			multipliers: '/api/member/multipliers'
		}
	});
});

// 会员等级 - 列表
router.get('/levels', async (req, res) => {
	try {
		const [rows] = await pool.execute('SELECT * FROM member_level ORDER BY level_type');
		res.json({
			success: true,
			data: rows,
			message: '获取会员等级列表成功'
		});
	} catch (error) {
		console.error('获取会员等级列表失败:', error);
		res.status(500).json({ success: false, message: '获取会员等级列表失败', error: error.message });
	}
});

// 会员等级 - 详情（按 level_type）
router.get('/levels/:levelType', async (req, res) => {
	try {
		const { levelType } = req.params;
		const [rows] = await pool.execute('SELECT * FROM member_level WHERE level_type = ?', [levelType]);
		if (rows.length === 0) {
			return res.status(404).json({ success: false, message: '会员等级不存在' });
		}
		res.json({ success: true, data: rows[0], message: '获取会员等级成功' });
	} catch (error) {
		console.error('获取会员等级失败:', error);
		res.status(500).json({ success: false, message: '获取会员等级失败', error: error.message });
	}
});

// 权益分类 - 列表
router.get('/right-categories', async (req, res) => {
	try {
		const [rows] = await pool.execute('SELECT * FROM member_right_category ORDER BY category');
		res.json({ success: true, data: rows, message: '获取权益分类列表成功' });
	} catch (error) {
		console.error('获取权益分类列表失败:', error);
		res.status(500).json({ success: false, message: '获取权益分类列表失败', error: error.message });
	}
});

// 权益 - 列表（可按分类筛选）
router.get('/rights', async (req, res) => {
	try {
		const { category } = req.query;
		let rows;
		if (category) {
			[rows] = await pool.execute('SELECT * FROM member_right WHERE category = ? ORDER BY id', [category]);
		} else {
			[rows] = await pool.execute('SELECT * FROM member_right ORDER BY id');
		}
		res.json({ success: true, data: rows, message: '获取权益列表成功' });
	} catch (error) {
		console.error('获取权益列表失败:', error);
		res.status(500).json({ success: false, message: '获取权益列表失败', error: error.message });
	}
});

// 某会员等级的全部权益（联表返回，含是否主页展示）
router.get('/levels/:levelType/rights', async (req, res) => {
	try {
		const { levelType } = req.params;
		const [rows] = await pool.execute(
			`SELECT 
				mr.*, 
				COALESCE(mlr.show_in_main_page, mr.show_in_main_page) AS show_in_main_page
			FROM member_level_right mlr
			JOIN member_right mr ON mr.external_id = mlr.right_external_id
			WHERE mlr.level_type = ?
			ORDER BY mr.id`
		, [levelType]);
		res.json({ success: true, data: rows, message: '获取等级权益列表成功' });
	} catch (error) {
		console.error('获取等级权益列表失败:', error);
		res.status(500).json({ success: false, message: '获取等级权益列表失败', error: error.message });
	}
});

// 某会员等级在主页展示的权益
router.get('/levels/:levelType/main-rights', async (req, res) => {
	try {
		const { levelType } = req.params;
		const [rows] = await pool.execute(
			`SELECT 
				mr.*, 
				COALESCE(mlr.show_in_main_page, mr.show_in_main_page) AS show_in_main_page
			FROM member_level_right mlr
			JOIN member_right mr ON mr.external_id = mlr.right_external_id
			WHERE mlr.level_type = ? AND COALESCE(mlr.show_in_main_page, mr.show_in_main_page) = 1
			ORDER BY mr.id`
		, [levelType]);
		res.json({ success: true, data: rows, message: '获取等级主页展示权益成功' });
	} catch (error) {
		console.error('获取等级主页展示权益失败:', error);
		res.status(500).json({ success: false, message: '获取等级主页展示权益失败', error: error.message });
	}
});

// 读取用户雪王币余额
router.get('/:userId/coins', async (req, res) => {
  try {
    const { userId } = req.params;
    const coins = await MembershipService.getUserCoins(userId);
    res.json({ success: true, data: { coins }, message: '获取雪王币成功' });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
});

// 增加雪王币
router.post('/:userId/coins/add', async (req, res) => {
  try {
    const { userId } = req.params;
    const { delta } = req.body;
    const coins = await MembershipService.addCoins(userId, delta);
    res.json({ success: true, data: { coins }, message: '雪王币增加成功' });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
});

// 读取成长值与等级
router.get('/:userId/growth', async (req, res) => {
  try {
    const { userId } = req.params;
    const growth = await MembershipService.getUserGrowth(userId);
    const [u] = await pool.execute('SELECT level_type FROM user WHERE id = ?', [userId]);
    const level_type = u.length ? u[0].level_type : null;
    res.json({ success: true, data: { growth, level_type }, message: '获取成长值成功' });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
});

// 增加成长值并重算等级
router.post('/:userId/growth/add', async (req, res) => {
  try {
    const { userId } = req.params;
    const { delta } = req.body;
    const info = await MembershipService.addGrowth(userId, delta);
    res.json({ success: true, data: info, message: '成长值增加并重算等级成功' });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
});

// 订单支付完成：累计币与成长值，并重算等级
router.post('/:userId/on-order-paid', async (req, res) => {
  try {
    const { userId } = req.params;
    const { amount } = req.body;
    if (amount === undefined) {
      return res.status(400).json({ success: false, message: '缺少 amount 参数' });
    }
    const result = await MembershipService.onOrderPaid(userId, amount);
    res.json({ success: true, data: result, message: '订单支付处理完成' });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
});

// 查看等级成长加成系数
router.get('/multipliers', async (req, res) => {
  try {
    const data = await MembershipService.loadLevelMultipliers();
    res.json({ success: true, data, message: '获取成长加成系数成功' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;

// 今日会员特权文案：根据 member_right_rule 和 weekday 计算
router.get('/rights/today', async (req, res) => {
  try {
    const { level_type } = req.query;
    if (!level_type) {
      return res.status(400).json({ success: false, message: '缺少 level_type 参数' });
    }

    const weekday = new Date().getDay(); // 0-6

    const [rows] = await pool.execute(
      `SELECT * FROM member_right_rule 
       WHERE level_type = ? AND weekday = ? AND status = 'active'
       ORDER BY priority ASC, id ASC LIMIT 1`,
      [level_type, weekday]
    );

    if (rows.length === 0) {
      return res.json({ success: true, data: null, message: '今日无特权规则' });
    }

    const rule = rows[0];
    let text;
    if (rule.type === 'percentage') {
      text = `今日会员日：${(Number(rule.percent_off) / 10).toFixed(1)}折`;
    } else if (rule.type === 'fixed') {
      text = `今日会员日：立减￥${Number(rule.discount_amount).toFixed(2)}`;
    } else if (rule.type === 'threshold_cut') {
      text = `今日会员日：满￥${Number(rule.threshold_amount).toFixed(2)}减￥${Number(rule.discount_amount).toFixed(2)}`;
    }

    res.json({
      success: true,
      data: {
        text,
        type: rule.type,
        percent_off: rule.percent_off,
        discount_amount: rule.discount_amount,
        threshold_amount: rule.threshold_amount,
        weekday
      },
      message: '获取今日会员特权成功'
    });
  } catch (error) {
    console.error('获取今日会员特权失败:', error);
    res.status(500).json({ success: false, message: '获取今日会员特权失败', error: error.message });
  }
});


