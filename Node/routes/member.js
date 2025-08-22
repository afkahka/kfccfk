const express = require('express');
const router = express.Router();
const { pool } = require('../database');

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
			levelMainRights: '/api/member/levels/:levelType/main-rights'
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

module.exports = router;


