const express = require('express');
const router = express.Router();
const { pool } = require('../database');

// 获取所有分类
router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM category ORDER BY id');
    res.json({
      success: true,
      data: rows,
      message: '获取分类列表成功'
    });
  } catch (error) {
    console.error('获取分类列表失败:', error);
    res.status(500).json({
      success: false,
      message: '获取分类列表失败',
      error: error.message
    });
  }
});

// 根据ID获取分类
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await pool.execute('SELECT * FROM category WHERE id = ?', [id]);
    
    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '分类不存在'
      });
    }
    
    res.json({
      success: true,
      data: rows[0],
      message: '获取分类成功'
    });
  } catch (error) {
    console.error('获取分类失败:', error);
    res.status(500).json({
      success: false,
      message: '获取分类失败',
      error: error.message
    });
  }
});

module.exports = router;
