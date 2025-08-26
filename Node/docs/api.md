Coffee Backend API 文档（简版）

服务地址：`http://localhost:3000`

## 请求方式说明
- 通用响应结构：`{ success:boolean, data:any, message:string }`
- 常见状态码：400 参数错误；404 资源不存在；500 服务器错误
- 认证：当前接口无需鉴权（无需携带 Token）。

- GET（查询参数在 URL 上）
  - 例：`GET /api/order/discount/preview?user_id=1&level_type=1&subtotal=58`

- POST/PUT/DELETE（JSON 请求体）
  - 必须带请求头：`Content-Type: application/json`
  - 例：`POST /api/member/1/on-order-paid`，Body：`{"amount":58.9}`

- curl 示例
```bash
# GET
curl -s "http://localhost:3000/api/order/discount/preview?user_id=1&level_type=1&subtotal=58"

# POST（JSON）（在 PowerShell 中建议改用 Invoke-RestMethod 示例）
curl -s -X POST "http://localhost:3000/api/member/1/on-order-paid" \
  -H "Content-Type: application/json" \
  -d '{"amount":58.9}'
```

- PowerShell 示例（建议用 hashtable 转 JSON，避免引号转义）
```powershell
# GET
Invoke-RestMethod -Method Get -Uri "http://localhost:3000/api/order/discount/preview?user_id=1&level_type=1&subtotal=58" | ConvertTo-Json -Depth 5

# POST JSON
$b = @{ amount = 58.9 } | ConvertTo-Json
Invoke-RestMethod -Method Post -Uri "http://localhost:3000/api/member/1/on-order-paid" -ContentType "application/json" -Body $b | ConvertTo-Json -Depth 5
```


## 订单折扣试算
- POST `/api/order/discount/preview`
  - Body(JSON)：`{ user_id?: number, level_type: number, subtotal: number, coupon_id?: number }`
- GET `/api/order/discount/preview`
  - Query：`level_type`、`subtotal`、`user_id?`、`coupon_id?`

返回数据结构
```json
{
  "success": true,
  "data": {
    "amount": 58.0,                 // 原始小计
    "rightDiscount": 5.8,           // 会员权益优惠
    "rightText": "8.0折会员日优惠", // 优惠文案（可能为 null）
    "appliedRule": { "id": 1, "type": "percentage" },
    "couponDiscount": 2.0,          // 优惠券优惠
    "couponDetail": { "coupon_id": 12, "discount_amount": 2.0 },
    "totalDiscount": 7.8,           // 合计优惠（不会超过 amount）
    "payable": 50.2                 // 应付
  },
  "message": "折扣试算成功"
}
```


示例返回（请求 + 响应）
```json
GET /api/order/discount/preview?user_id=1&level_type=1&subtotal=58
{
  "success": true,
  "data": {
    "amount": 58,
    "rightDiscount": 0,
    "rightText": null,
    "appliedRule": null,
    "couponDiscount": 0,
    "couponDetail": null,
    "totalDiscount": 0,
    "payable": 58
  },
  "message": "折扣试算成功"
}
```

## 会员服务（积分/成长/等级）
- GET `/api/member/:userId/coins` → `{ coins }`
- POST `/api/member/:userId/coins/add` Body：`{ delta }` → `{ coins }`
- GET `/api/member/:userId/growth` → `{ growth, level_type }`
- POST `/api/member/:userId/growth/add` Body：`{ delta }` → `{ growth, level_type }`
- POST `/api/member/:userId/on-order-paid` Body：`{ amount }` → `{ coins_added, growth_added, multiplier, growth, level_type }`
- GET `/api/member/multipliers` → `{ [level_type]: multiplier }`


示例返回（请求 + 响应，来自本地实测）
```json
POST /api/member/1/on-order-paid
{
  "success": true,
  "data": {
    "coins_added": 58,
    "growth_added": 61,
    "multiplier": 1.05,
    "growth": 149,
    "level_type": 3
  },
  "message": "订单支付处理完成"
}

GET /api/member/1/coins
{
  "success": true,
  "data": { "coins": 252 },
  "message": "获取雪王币成功"
}

GET /api/member/1/growth
{
  "success": true,
  "data": { "growth": 367, "level_type": 3 },
  "message": "获取成长值成功"
}

POST /api/member/1/coins/add
{
  "success": true,
  "data": { "coins": 252 },
  "message": "雪王币增加成功"
}

POST /api/member/1/growth/add
{
  "success": true,
  "data": { "growth": 367, "level_type": 3 },
  "message": "成长值增加并重算等级成功"
}
```

## 用户
- GET `/api/user`
- GET `/api/user/:id`
- GET `/api/user/:id/summary` → `{ coins, couponCount, level_type }`

示例返回
```json
{
  "success": true,
  "data": { "coins": 0, "couponCount": 3, "level_type": 2 },
  "message": "获取用户概要成功"
}
```

## 会员等级/权益
- GET `/api/member/levels`
- GET `/api/member/levels/:levelType`
- GET `/api/member/levels/:levelType/rights`
- GET `/api/member/levels/:levelType/main-rights`
- GET `/api/member/rights?category=1`
- GET `/api/member/rights/today?level_type=2`

示例返回（请求 + 响应）
```json
GET /api/member/levels
{
  "success": true,
  "data": [ { "level_type": 1, "level_name": "微雪花" }, { "level_type": 2, "level_name": "小雪球" } ],
  "message": "获取会员等级列表成功"
}

GET /api/member/levels/1
{
  "success": true,
  "data": { "level_type": 1, "level_name": "微雪花" },
  "message": "获取会员等级成功"
}

GET /api/member/rights?category=1
{
  "success": true,
  "data": [ { "external_id": "1", "right_name": "周一咖啡日" } ],
  "message": "获取权益列表成功"
}

GET /api/member/levels/1/rights
{
  "success": true,
  "data": [ { "right_name": "周一咖啡日", "show_in_main_page": 1 } ],
  "message": "获取等级权益列表成功"
}

GET /api/member/levels/1/main-rights
{
  "success": true,
  "data": [ { "right_name": "周一咖啡日", "show_in_main_page": 1 } ],
  "message": "获取等级主页展示权益成功"
}

GET /api/member/rights/today?level_type=2
{
  "success": true,
  "data": { "text": "今日会员日：8.0折", "type": "percentage", "weekday": 3 },
  "message": "获取今日会员特权成功"
}
```

## 分类与商品
- GET `/api/category`
- GET `/api/category/:id`
- GET `/api/coffee`
- GET `/api/coffee/:id`
- GET `/api/coffee/category/:parentId`
- GET `/api/coffee/search/:keyword`

示例返回（请求 + 响应）
```json
GET /api/category
{
  "success": true,
  "data": [ { "id": 1, "title": "谷爱凌推荐" } ],
  "message": "获取分类列表成功"
}

GET /api/coffee/category/1
{
  "success": true,
  "data": [ { "id": 1, "title": "生椰丝绒拿铁" } ],
  "message": "获取分类咖啡产品成功"
}

GET /api/coffee/search/拿铁
{
  "success": true,
  "data": [ { "id": 4, "title": "丝绒拿铁" } ],
  "message": "搜索咖啡产品成功"
}
```

## 地址
- GET `/api/address`
- GET `/api/address/:id`
- GET `/api/address/user/:userId`
- GET `/api/address/check-phone/:phoneNumber`
- POST `/api/address`
- PUT `/api/address/:id`
- DELETE `/api/address/:id`
- PUT `/api/address/:id/default`（需要表有 `is_default` 字段）

示例返回（请求 + 响应）
```json
GET /api/address/user/1
{
  "success": true,
  "data": [ { "id": 1, "user_id": 1, "contact_person": "一只安慕嘻" } ],
  "message": "获取用户地址列表成功"
}

GET /api/address/check-phone/15380979728
{
  "success": true,
  "data": { "phoneNumber": "15380979728", "isAvailable": false, "message": "电话号码已被使用" },
  "message": "电话号码检查完成"
}

POST /api/address
{
  "success": true,
  "data": { "id": 10, "user_id": 1, "contact_person": "张三", "phone_number": "13800000000" },
  "message": "地址创建成功"
}

PUT /api/address/10
{
  "success": true,
  "message": "地址信息更新成功"
}

DELETE /api/address/10
{
  "success": true,
  "message": "地址删除成功"
}
```



