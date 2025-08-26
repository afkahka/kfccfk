const express = require('express');
const router = express.Router();
const { pool } = require('../database');

// 订单接口根路径：用于健康检查或提示可用子路由
router.get('/', async (req, res) => {
  res.json({
    success: true,
    message: '订单接口可用',
    endpoints: {
      discountPreview: '/api/order/discount/preview'
    }
  });
});

// 折扣试算：根据会员规则和可选优惠券，返回优惠明细
router.post('/discount/preview', async (req, res) => {
  try {
    const { user_id, level_type, items, subtotal, coupon_id } = req.body;
    if (subtotal === undefined || level_type === undefined) {
      return res.status(400).json({ success: false, message: '缺少必要参数 subtotal/level_type' });
    }

    const weekday = new Date().getDay();

    // 取当日优先级最高的会员规则
    const [rules] = await pool.execute(
      `SELECT * FROM member_right_rule 
       WHERE level_type = ? AND weekday = ? AND status = 'active'
       ORDER BY priority ASC, id ASC LIMIT 1`,
      [level_type, weekday]
    );

    let rightDiscount = 0.0;
    let rightText = null;
    let appliedRule = null;
    const amount = Number(subtotal);

    if (rules.length > 0) {
      const r = rules[0];
      if (r.type === 'percentage' && r.percent_off) {
        rightDiscount = amount * (1 - Number(r.percent_off) / 100);
        rightText = `${(Number(r.percent_off) / 10).toFixed(1)}折会员日优惠`;
      } else if (r.type === 'fixed' && r.discount_amount) {
        rightDiscount = Number(r.discount_amount);
        rightText = `立减￥${Number(r.discount_amount).toFixed(2)}`;
      } else if (r.type === 'threshold_cut' && r.threshold_amount && r.discount_amount) {
        if (amount >= Number(r.threshold_amount)) {
          rightDiscount = Number(r.discount_amount);
          rightText = `满￥${Number(r.threshold_amount).toFixed(2)}减￥${Number(r.discount_amount).toFixed(2)}`;
        }
      }
      appliedRule = { id: r.id, type: r.type };
    }

    // 可选优惠券试算（简单版：仅直减，且与规则可叠加由规则的 stackable 决定）
    let couponDiscount = 0.0;
    let couponDetail = null;
    if (coupon_id) {
      const [rows] = await pool.execute(
        `SELECT uc.status, c.discount_amount, c.threshold_amount, c.valid_from, c.valid_to
         FROM user_coupon uc JOIN coupon c ON c.id = uc.coupon_id
         WHERE uc.id = ? AND uc.user_id = ?`,
        [coupon_id, user_id]
      );
      if (rows.length > 0 && rows[0].status === 'unused') {
        const now = new Date();
        const from = new Date(rows[0].valid_from);
        const to = new Date(rows[0].valid_to);
        const okTime = now >= from && now <= to;
        const okThreshold = rows[0].threshold_amount == null || amount >= Number(rows[0].threshold_amount);
        if (okTime && okThreshold) {
          couponDiscount = Number(rows[0].discount_amount);
          couponDetail = { coupon_id, discount_amount: couponDiscount };
        }
      }
    }

    const totalDiscount = Math.min(amount, Number((rightDiscount + couponDiscount).toFixed(2)));
    const payable = Number((amount - totalDiscount).toFixed(2));

    res.json({
      success: true,
      data: {
        amount,
        rightDiscount: Number(rightDiscount.toFixed(2)),
        rightText,
        appliedRule,
        couponDiscount: Number(couponDiscount.toFixed(2)),
        couponDetail,
        totalDiscount,
        payable
      },
      message: '折扣试算成功'
    });
  } catch (error) {
    console.error('折扣试算失败:', error);
    res.status(500).json({ success: false, message: '折扣试算失败', error: error.message });
  }
});

// 便于浏览器调试：GET 版本，参数通过 query 传入
router.get('/discount/preview', async (req, res) => {
  try {
    const { user_id, level_type, subtotal, coupon_id } = req.query;
    if (subtotal === undefined || level_type === undefined) {
      return res.status(400).json({ success: false, message: '缺少必要参数 subtotal/level_type' });
    }

    const weekday = new Date().getDay();

    const [rules] = await pool.execute(
      `SELECT * FROM member_right_rule 
       WHERE level_type = ? AND weekday = ? AND status = 'active'
       ORDER BY priority ASC, id ASC LIMIT 1`,
      [level_type, weekday]
    );

    let rightDiscount = 0.0;
    let rightText = null;
    let appliedRule = null;
    const amount = Number(subtotal);

    if (rules.length > 0) {
      const r = rules[0];
      if (r.type === 'percentage' && r.percent_off) {
        rightDiscount = amount * (1 - Number(r.percent_off) / 100);
        rightText = `${(Number(r.percent_off) / 10).toFixed(1)}折会员日优惠`;
      } else if (r.type === 'fixed' && r.discount_amount) {
        rightDiscount = Number(r.discount_amount);
        rightText = `立减￥${Number(r.discount_amount).toFixed(2)}`;
      } else if (r.type === 'threshold_cut' && r.threshold_amount && r.discount_amount) {
        if (amount >= Number(r.threshold_amount)) {
          rightDiscount = Number(r.discount_amount);
          rightText = `满￥${Number(r.threshold_amount).toFixed(2)}减￥${Number(r.discount_amount).toFixed(2)}`;
        }
      }
      appliedRule = { id: r.id, type: r.type };
    }

    let couponDiscount = 0.0;
    let couponDetail = null;
    if (coupon_id) {
      const [rows] = await pool.execute(
        `SELECT uc.status, c.discount_amount, c.threshold_amount, c.valid_from, c.valid_to
         FROM user_coupon uc JOIN coupon c ON c.id = uc.coupon_id
         WHERE uc.id = ? AND uc.user_id = ?`,
        [coupon_id, user_id]
      );
      if (rows.length > 0 && rows[0].status === 'unused') {
        const now = new Date();
        const from = new Date(rows[0].valid_from);
        const to = new Date(rows[0].valid_to);
        const okTime = now >= from && now <= to;
        const okThreshold = rows[0].threshold_amount == null || amount >= Number(rows[0].threshold_amount);
        if (okTime && okThreshold) {
          couponDiscount = Number(rows[0].discount_amount);
          couponDetail = { coupon_id, discount_amount: couponDiscount };
        }
      }
    }

    const totalDiscount = Math.min(amount, Number((rightDiscount + couponDiscount).toFixed(2)));
    const payable = Number((amount - totalDiscount).toFixed(2));

    res.json({
      success: true,
      data: {
        amount,
        rightDiscount: Number(rightDiscount.toFixed(2)),
        rightText,
        appliedRule,
        couponDiscount: Number(couponDiscount.toFixed(2)),
        couponDetail,
        totalDiscount,
        payable
      },
      message: '折扣试算成功'
    });
  } catch (error) {
    console.error('折扣试算失败:', error);
    res.status(500).json({ success: false, message: '折扣试算失败', error: error.message });
  }
});

module.exports = router;


