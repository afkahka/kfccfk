const express = require('express');
const router = express.Router();
const { pool } = require('../database');
const MembershipService = require('../services/membership');

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

// 用户概要：coins、未使用优惠券数量、level_type
router.get('/:id/summary', async (req, res) => {
  try {
    const { id } = req.params;

    const [[userRows], [couponRows]] = await Promise.all([
      pool.execute('SELECT coins, level_type FROM user WHERE id = ?', [id]),
      pool.execute('SELECT COUNT(*) AS cnt FROM user_coupon WHERE user_id = ? AND status = ?',[id, 'unused'])
    ]);

    if (userRows.length === 0) {
      return res.status(404).json({ success: false, message: '用户不存在' });
    }

    const { coins, level_type } = userRows[0];
    const couponCount = couponRows[0]?.cnt ?? 0;

    res.json({
      success: true,
      data: { coins, couponCount, level_type },
      message: '获取用户概要成功'
    });
  } catch (error) {
    console.error('获取用户概要失败:', error);
    res.status(500).json({ success: false, message: '获取用户概要失败', error: error.message });
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
    const { name, telephone, avatar } = req.body;
    
    if (!name || !telephone) {
      return res.status(400).json({
        success: false,
        message: '姓名和电话号码不能为空'
      });
    }
    
    const [result] = await pool.execute(
      'INSERT INTO user (name, telephone, avatar) VALUES (?, ?, ?)',
      [name, telephone, avatar ?? null]
    );
    
    res.status(201).json({
      success: true,
      data: { id: result.insertId, name, telephone, avatar: avatar ?? null },
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

// 查询用户优惠券列表
router.get('/:id/coupons', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.query; // optional: unused|used|expired

    // 确认用户存在
    const [u] = await pool.execute('SELECT id FROM user WHERE id = ?', [id]);
    if (u.length === 0) {
      return res.status(404).json({ success: false, message: '用户不存在' });
    }

    let sql = `SELECT uc.*, c.title, c.desc, c.threshold_amount, c.discount_amount, c.valid_from, c.valid_to
               FROM user_coupon uc
               JOIN coupon c ON c.id = uc.coupon_id
               WHERE uc.user_id = ?`;
    const params = [id];
    if (status) {
      sql += ' AND uc.status = ?';
      params.push(status);
    }
    sql += ' ORDER BY uc.obtained_at DESC';

    const [rows] = await pool.execute(sql, params);
    res.json({ success: true, data: rows, message: '获取用户优惠券成功' });
  } catch (error) {
    console.error('获取用户优惠券失败:', error);
    res.status(500).json({ success: false, message: '获取用户优惠券失败', error: error.message });
  }
});

// 更新用户信息
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, telephone, avatar, coins, growth_value, coins_delta, growth_delta } = req.body;

    const fields = [];
    const values = [];

    if (name !== undefined) {
      if (!String(name).trim()) {
        return res.status(400).json({ success: false, message: '姓名不能为空' });
      }
      fields.push('name = ?');
      values.push(name);
    }

    if (telephone !== undefined) {
      if (!String(telephone).trim()) {
        return res.status(400).json({ success: false, message: '电话号码不能为空' });
      }
      fields.push('telephone = ?');
      values.push(telephone);
    }

    if (avatar !== undefined) {
      fields.push('avatar = ?');
      values.push(avatar);
    }

    // 允许直接设置 coins 和 growth_value（绝对值）
    if (coins !== undefined) {
      if (Number.isNaN(Number(coins))) {
        return res.status(400).json({ success: false, message: 'coins 必须为数字' });
      }
      fields.push('coins = ?');
      values.push(Number(coins));
    }

    if (growth_value !== undefined) {
      if (Number.isNaN(Number(growth_value))) {
        return res.status(400).json({ success: false, message: 'growth_value 必须为数字' });
      }
      fields.push('growth_value = ?');
      values.push(Number(growth_value));
    }

    // 支持增量更新（与绝对值同时提供时，先应用绝对值，再应用增量）
    if (coins_delta !== undefined) {
      if (Number.isNaN(Number(coins_delta))) {
        return res.status(400).json({ success: false, message: 'coins_delta 必须为数字' });
      }
      fields.push('coins = COALESCE(coins, 0) + ?');
      values.push(Number(coins_delta));
    }

    if (growth_delta !== undefined) {
      if (Number.isNaN(Number(growth_delta))) {
        return res.status(400).json({ success: false, message: 'growth_delta 必须为数字' });
      }
      fields.push('growth_value = COALESCE(growth_value, 0) + ?');
      values.push(Number(growth_delta));
    }

    if (fields.length === 0) {
      return res.status(400).json({ success: false, message: '未提供需要更新的字段' });
    }

    const sql = `UPDATE user SET ${fields.join(', ')} WHERE id = ?`;
    values.push(id);

    const [result] = await pool.execute(sql, values);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: '用户不存在'
      });
    }
    
    // 若成长值发生变化，重算等级
    let levelInfo = undefined;
    if (growth_value !== undefined || growth_delta !== undefined) {
      try {
        levelInfo = await MembershipService.recalcLevelByGrowth(id);
      } catch (_) {
        // ignore recalculation error, still respond success for base update
      }
    }

    res.json({
      success: true,
      data: levelInfo ? levelInfo : undefined,
      message: levelInfo ? '用户信息更新成功并已重算等级' : '用户信息更新成功'
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
