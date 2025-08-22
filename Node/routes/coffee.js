const express = require('express');
const router = express.Router();
const { pool } = require('../database');

// 获取所有咖啡产品
router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM coffee ORDER BY id');
    res.json({
      success: true,
      data: rows,
      message: '获取咖啡产品列表成功'
    });
  } catch (error) {
    console.error('获取咖啡产品列表失败:', error);
    res.status(500).json({
      success: false,
      message: '获取咖啡产品列表失败',
      error: error.message
    });
  }
});

// 根据ID获取咖啡产品
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await pool.execute('SELECT * FROM coffee WHERE id = ?', [id]);
    
    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '咖啡产品不存在'
      });
    }
    
    res.json({
      success: true,
      data: rows[0],
      message: '获取咖啡产品成功'
    });
  } catch (error) {
    console.error('获取咖啡产品失败:', error);
    res.status(500).json({
      success: false,
      message: '获取咖啡产品失败',
      error: error.message
    });
  }
});

// 根据分类ID获取咖啡产品
router.get('/category/:parentId', async (req, res) => {
  try {
    const { parentId } = req.params;
    const [rows] = await pool.execute('SELECT * FROM coffee WHERE parentId = ? ORDER BY id', [parentId]);
    
    res.json({
      success: true,
      data: rows,
      message: '获取分类咖啡产品成功'
    });
  } catch (error) {
    console.error('获取分类咖啡产品失败:', error);
    res.status(500).json({
      success: false,
      message: '获取分类咖啡产品失败',
      error: error.message
    });
  }
});

// 搜索咖啡产品
router.get('/search/:keyword', async (req, res) => {
  try {
    const { keyword } = req.params;
    const [rows] = await pool.execute(
      'SELECT * FROM coffee WHERE title LIKE ? ORDER BY id',
      [`%${keyword}%`]
    );
    
    res.json({
      success: true,
      data: rows,
      message: '搜索咖啡产品成功'
    });
  } catch (error) {
    console.error('搜索咖啡产品失败:', error);
    res.status(500).json({
      success: false,
      message: '搜索咖啡产品失败',
      error: error.message
    });
  }
});

module.exports = router;
