const express = require('express');
const router = express.Router();
const { pool } = require('../database');

// 获取所有地址
router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM address ORDER BY id');
    res.json({
      success: true,
      data: rows,
      message: '获取地址列表成功'
    });
  } catch (error) {
    console.error('获取地址列表失败:', error);
    res.status(500).json({
      success: false,
      message: '获取地址列表失败',
      error: error.message
    });
  }
});

// 根据ID获取地址
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await pool.execute('SELECT * FROM address WHERE id = ?', [id]);
    
    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '地址不存在'
      });
    }
    
    res.json({
      success: true,
      data: rows[0],
      message: '获取地址成功'
    });
  } catch (error) {
    console.error('获取地址失败:', error);
    res.status(500).json({
      success: false,
      message: '获取地址失败',
      error: error.message
    });
  }
});

// 根据用户ID获取地址列表
router.get('/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const [rows] = await pool.execute('SELECT * FROM address WHERE user_id = ? ORDER BY id', [userId]);
    
    res.json({
      success: true,
      data: rows,
      message: '获取用户地址列表成功'
    });
  } catch (error) {
    console.error('获取用户地址列表失败:', error);
    res.status(500).json({
      success: false,
      message: '获取用户地址列表失败',
      error: error.message
    });
  }
});

// 检查电话号码是否可用
router.get('/check-phone/:phoneNumber', async (req, res) => {
  try {
    const { phoneNumber } = req.params;
    
    const [rows] = await pool.execute('SELECT * FROM address WHERE phone_number = ?', [phoneNumber]);
    
    res.json({
      success: true,
      data: {
        phoneNumber,
        isAvailable: rows.length === 0,
        message: rows.length === 0 ? '电话号码可用' : '电话号码已被使用'
      },
      message: '电话号码检查完成'
    });
  } catch (error) {
    console.error('检查电话号码失败:', error);
    res.status(500).json({
      success: false,
      message: '检查电话号码失败',
      error: error.message
    });
  }
});

// 测试接口 - 返回请求体信息
router.post('/test', (req, res) => {
  console.log('测试接口收到请求:');
  console.log('Headers:', req.headers);
  console.log('Body:', req.body);
  console.log('Query:', req.query);
  
  res.json({
    success: true,
    message: '测试接口正常',
    data: {
      headers: req.headers,
      body: req.body,
      query: req.query,
      timestamp: new Date().toISOString()
    }
  });
});

// 创建新地址
router.post('/', async (req, res) => {
  try {
    console.log('收到创建地址请求:', req.body);
    
    const { user_id, contact_person, gender, phone_number, address, house_number } = req.body;
    
    // 验证必填字段
    if (!user_id || !contact_person || !phone_number || !address) {
      console.log('字段验证失败:', { user_id, contact_person, phone_number, address });
      return res.status(400).json({
        success: false,
        message: '用户ID、联系人、电话号码和地址不能为空',
        missingFields: {
          user_id: !user_id,
          contact_person: !contact_person,
          phone_number: !phone_number,
          address: !address
        }
      });
    }
    
    console.log('开始检查电话号码重复性...');
    
    // 检查电话号码是否已存在
    const [existingAddresses] = await pool.execute(
      'SELECT * FROM address WHERE phone_number = ?',
      [phone_number]
    );
    
    if (existingAddresses.length > 0) {
      console.log('电话号码已存在:', phone_number);
      return res.status(400).json({
        success: false,
        message: '该电话号码已被使用，请使用其他电话号码或修改现有地址',
        error: '电话号码重复',
        existingAddress: existingAddresses[0]
      });
    }
    
    console.log('电话号码检查通过，开始插入数据库...');
    
    const [result] = await pool.execute(
      'INSERT INTO address (user_id, contact_person, gender, phone_number, address, house_number) VALUES (?, ?, ?, ?, ?, ?)',
      [user_id, contact_person, gender, phone_number, address, house_number]
    );
    
    console.log('地址创建成功，ID:', result.insertId);
    
    res.status(201).json({
      success: true,
      data: { 
        id: result.insertId, 
        user_id, 
        contact_person, 
        gender, 
        phone_number, 
        address, 
        house_number 
      },
      message: '地址创建成功'
    });
  } catch (error) {
    console.error('创建地址失败:', error);
    
    // 处理特定的数据库错误
    if (error.code === 'ER_DUP_ENTRY') {
      console.log('数据库重复键错误:', error.message);
      return res.status(400).json({
        success: false,
        message: '该电话号码已被使用，请使用其他电话号码或修改现有地址',
        error: '电话号码重复',
        code: error.code
      });
    }
    
    res.status(500).json({
      success: false,
      message: '创建地址失败',
      error: error.message,
      code: error.code
    });
  }
});

// 更新地址信息
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { contact_person, gender, phone_number, address, house_number } = req.body;
    
    // 检查电话号码是否已被其他地址使用
    const [existingAddresses] = await pool.execute(
      'SELECT * FROM address WHERE phone_number = ? AND id != ?',
      [phone_number, id]
    );
    
    if (existingAddresses.length > 0) {
      return res.status(400).json({
        success: false,
        message: '该电话号码已被其他地址使用，请使用其他电话号码'
      });
    }
    
    const [result] = await pool.execute(
      'UPDATE address SET contact_person = ?, gender = ?, phone_number = ?, address = ?, house_number = ? WHERE id = ?',
      [contact_person, gender, phone_number, address, house_number, id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: '地址不存在'
      });
    }
    
    res.json({
      success: true,
      message: '地址信息更新成功'
    });
  } catch (error) {
    console.error('更新地址失败:', error);
    
    // 处理特定的数据库错误
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({
        success: false,
        message: '该电话号码已被使用，请使用其他电话号码',
        error: '电话号码重复'
      });
    }
    
    res.status(500).json({
      success: false,
      message: '更新地址失败',
      error: error.message
    });
  }
});

// 删除地址
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const [result] = await pool.execute('DELETE FROM address WHERE id = ?', [id]);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: '地址不存在'
      });
    }
    
    res.json({
      success: true,
      message: '地址删除成功'
    });
  } catch (error) {
    console.error('删除地址失败:', error);
    res.status(500).json({
      success: false,
      message: '删除地址失败',
      error: error.message
    });
  }
});

// 设置默认地址 (需要数据库中有is_default字段)
router.put('/:id/default', async (req, res) => {
  try {
    const { id } = req.params;
    const { user_id } = req.body;
    
    // 检查地址是否存在
    const [checkRows] = await pool.execute('SELECT * FROM address WHERE id = ? AND user_id = ?', [id, user_id]);
    
    if (checkRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '地址不存在或不属于该用户'
      });
    }
    
    // 注意：如果数据库中没有is_default字段，请先添加该字段
    // ALTER TABLE address ADD COLUMN is_default TINYINT(1) DEFAULT 0;
    
    // 先取消该用户的所有默认地址
    await pool.execute('UPDATE address SET is_default = 0 WHERE user_id = ?', [user_id]);
    
    // 设置指定地址为默认
    const [result] = await pool.execute(
      'UPDATE address SET is_default = 1 WHERE id = ? AND user_id = ?',
      [id, user_id]
    );
    
    res.json({
      success: true,
      message: '默认地址设置成功'
    });
  } catch (error) {
    console.error('设置默认地址失败:', error);
    res.status(500).json({
      success: false,
      message: '设置默认地址失败，请确保数据库中有is_default字段',
      error: error.message
    });
  }
});

module.exports = router;
