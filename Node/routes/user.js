const express = require('express');
const router = express.Router();
const { pool } = require('../database');

// 获取所有用户
router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM user ORDER BY id');
    res.json({
      success: true,
      data: rows,
      message: '获取用户列表成功'
    });
  } catch (error) {
    console.error('获取用户列表失败:', error);
    res.status(500).json({
      success: false,
      message: '获取用户列表失败',
      error: error.message
    });
  }
});

// 根据ID获取用户
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await pool.execute('SELECT * FROM user WHERE id = ?', [id]);
    
    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '用户不存在'
      });
    }
    
    res.json({
      success: true,
      data: rows[0],
      message: '获取用户成功'
    });
  } catch (error) {
    console.error('获取用户失败:', error);
    res.status(500).json({
      success: false,
      message: '获取用户失败',
      error: error.message
    });
  }
});

// 根据电话号码查找用户
router.get('/phone/:telephone', async (req, res) => {
  try {
    const { telephone } = req.params;
    const [rows] = await pool.execute('SELECT * FROM user WHERE telephone = ?', [telephone]);
    
    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '用户不存在'
      });
    }
    
    res.json({
      success: true,
      data: rows[0],
      message: '获取用户成功'
    });
  } catch (error) {
    console.error('获取用户失败:', error);
    res.status(500).json({
      success: false,
      message: '获取用户失败',
      error: error.message
    });
  }
});

// 创建新用户
router.post('/', async (req, res) => {
  try {
    const { name, telephone } = req.body;
    
    if (!name || !telephone) {
      return res.status(400).json({
        success: false,
        message: '姓名和电话号码不能为空'
      });
    }
    
    const [result] = await pool.execute(
      'INSERT INTO user (name, telephone) VALUES (?, ?)',
      [name, telephone]
    );
    
    res.status(201).json({
      success: true,
      data: { id: result.insertId, name, telephone },
      message: '用户创建成功'
    });
  } catch (error) {
    console.error('创建用户失败:', error);
    res.status(500).json({
      success: false,
      message: '创建用户失败',
      error: error.message
    });
  }
});

// 更新用户信息
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, telephone } = req.body;
    
    // 验证参数，防止 undefined 值
    if (name === undefined || telephone === undefined) {
      return res.status(400).json({
        success: false,
        message: '姓名和电话号码不能为空'
      });
    }
    
    // 检查参数是否为空字符串
    if (!name.trim() || !telephone.trim()) {
      return res.status(400).json({
        success: false,
        message: '姓名和电话号码不能为空'
      });
    }
    
    const [result] = await pool.execute(
      'UPDATE user SET name = ?, telephone = ? WHERE id = ?',
      [name, telephone, id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: '用户不存在'
      });
    }
    
    res.json({
      success: true,
      message: '用户信息更新成功'
    });
  } catch (error) {
    console.error('更新用户失败:', error);
    res.status(500).json({
      success: false,
      message: '更新用户失败',
      error: error.message
    });
  }
});

// 删除用户
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const [result] = await pool.execute('DELETE FROM user WHERE id = ?', [id]);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: '用户不存在'
      });
    }
    
    res.json({
      success: true,
      message: '用户删除成功'
    });
  } catch (error) {
    console.error('删除用户失败:', error);
    res.status(500).json({
      success: false,
      message: '删除用户失败',
      error: error.message
    });
  }
});

module.exports = router;
