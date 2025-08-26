const express = require('express');
const cors = require('cors');
const config = require('./config');
const { testConnection } = require('./database');

// 导入路由
const categoryRoutes = require('./routes/category');
const coffeeRoutes = require('./routes/coffee');
const userRoutes = require('./routes/user');
const addressRoutes = require('./routes/address');
const memberRoutes = require('./routes/member');
const orderRoutes = require('./routes/order');

const app = express();

// 中间件
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 测试数据库连接
testConnection();

// 路由
app.use('/api/category', categoryRoutes);
app.use('/api/coffee', coffeeRoutes);
app.use('/api/user', userRoutes);
app.use('/api/address', addressRoutes);
app.use('/api/member', memberRoutes);
app.use('/api/order', orderRoutes);

// 根路径
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: '咖啡店后端API服务运行中',
    version: '1.0.0',
    endpoints: {
      category: '/api/category',
      coffee: '/api/coffee',
      user: '/api/user',
      address: '/api/address',
      member: '/api/member'
    }
  });
});

// 404处理
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: '接口不存在'
  });
});

// 错误处理中间件
app.use((error, req, res, next) => {
  console.error('服务器错误:', error);
  res.status(500).json({
    success: false,
    message: '服务器内部错误',
    error: error.message
  });
});

// 启动服务器
const PORT = config.server.port;
app.listen(PORT, () => {
  console.log(`服务器运行在 http://localhost:${PORT}`);
  console.log('API文档:');
  console.log(`- 分类接口: http://localhost:${PORT}/api/category`);
  console.log(`- 咖啡产品接口: http://localhost:${PORT}/api/coffee`);
  console.log(`- 用户接口: http://localhost:${PORT}/api/user`);
  console.log(`- 地址接口: http://localhost:${PORT}/api/address`);
  console.log(`- 会员接口: http://localhost:${PORT}/api/member`);
  console.log(`- 订单接口: http://localhost:${PORT}/api/order`);
});

module.exports = app;
