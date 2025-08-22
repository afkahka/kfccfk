## 项目简介

本项目为基于 OpenHarmony/ArkUI（ArkTS）的外卖/咖啡点餐类应用示例，包含启动页、登录、底部多 Tab 主页面、点餐下单、地址管理、结算支付、订单记录与会员中心等典型功能。以下说明基于仓库现有代码，力求客观、实事求是。

## 运行环境

- ArkTS/ArkUI 项目结构（`entry` 模块）
- 构建与配置文件：`hvigorfile.ts`、`oh-package.json5`、`build-profile.json5` 等

## 页面与导航

- 启动/路由入口（`pages/Index.ets`）
  - 管理隐私同意状态与冷启动逻辑（`agreedState`）。
  - 同步登录状态（`LoginStateService.syncStorageData`），根据是否已登录路由至登录页或主页面。
  - 维护全局导航栈 `pathStack`。

- 登录页（`pages/LoginPage.ets`）
  - 支持手机号 + 验证码登录流程：校验手机号、调用验证码校验（`VerificationCodeService.verifyCode`）。
  - 登录成功后通过 `RcpUtilsService.getUserByPhone` 拉取用户信息，写入 `LoginStateService` 并替换路由到主页面。

- 主页面（`pages/MainPage.ets` + `view/BottomTabsBar.ets`）
  - 底部 4 个 Tab：主页（`HomePage`）、点餐（`OrderPage`）、订单列表（`OrderListPage`）、我的（`MinePage`）。
  - 支持从其他页面设置 `switchTabIndex` 切换指定 Tab。

- 主页（`view/HomePage.ets`）
  - 用于展示首页内容（横幅、入口等，具体以现有 UI 为准）。

- 点餐页面（`view/OrderPage.ets`）
  - 商品分类与列表（`RcpUtilsService` 提供 `CoffeeCategory`、`CoffeeItem`）。
  - 购物车数量与金额统计（`cartMap`、`totalCount`、`totalPrice`）。
  - 地址选择联动（监听 `AddressEditService` 的变更；未选地址时阻止结算并引导选择）。
  - 结算跳转：使用 `CheckoutService.setCheckoutData` 写入地址、清单与金额后跳转 `CheckoutPage`。

- 地址列表与编辑
  - 地址列表页（`view/AddressPage.ets`）：
    - 拉取地址（`RcpUtilsService.fetchAddresses`），点击地址即设为选中地址并返回。
    - 编辑入口：设置编辑状态（`AddressEditService.setEditAddress`）后跳转至新增/编辑页。
    - 通过 `AddressEditService` 的变更事件在新增/编辑后刷新列表。
  - 新增/编辑页（`view/AddAddressPage.ets`）：
    - 新增：`RcpUtilsService.saveAddress`；编辑：`RcpUtilsService.updateAddress`。
    - 成功后触发地址变更事件并返回。
  - 地址编辑服务（`common/service/AddressEditService.ets`）：
    - 维护编辑态、选中地址、刷新标记与变更监听；选中地址会持久化到 `AppStorage`/`PersistentStorage`。

- 结算页（`view/CheckoutPage.ets`）
  - 从 `CheckoutService` 读取选中地址、商品明细与总金额。
  - 支持支付方式选择（微信/支付宝枚举）。
  - 点击“确认支付”后生成订单记录（`OrderService.createFromCheckout`），并进入订单详情页。

- 订单相关
  - 订单服务（`common/service/OrderService.ets`）：
    - 持久化订单列表（JSON + 时间戳，超过 7 天自动清理）。
    - 基于 `CheckoutService` 生成订单记录（包含订单号、取餐码、时间、地址、条目、金额与支付方式）。
  - 订单列表页（`view/OrderListPage.ets`）：
    - 展示订单列表并支持下拉刷新（从 `OrderService.getOrders` 读取）。
  - 订单详情页（`view/OrderDetailPage.ets`）：
    - 展示单笔订单详情（订单号、取餐码、金额、条目等）。

- 我的/会员中心（`view/MinePage.ets`）
  - 从 `LoginStateService` 读取用户昵称、手机号、头像与会员等级。
  - 通过 `RcpUtilsService` 获取会员等级、权益分类与权益清单，支持根据当前等级展示对应权益。

## 核心服务

- 登录状态服务（`common/service/LoginStateService.ets`）
  - 使用 `AppStorage` + `PersistentStorage` 维护登录态、最近账号、用户基本信息与会员等级。
  - 提供同步方法 `syncStorageData`，支持应用冷启动时的状态恢复；`isUserLoggedIn` 用于快速判断是否为已登录且存在有效用户 ID。

- 结算服务（`common/service/CheckoutService.ets`）
  - 在结算前暂存地址、商品条目与金额，并生成订单号、取餐码与时间，供 `CheckoutPage` 与 `OrderService` 使用。

- 订单服务（`common/service/OrderService.ets`）
  - 负责订单的生成与持久化，提供列表读取与过期清理机制。

- 地址编辑服务（`common/service/AddressEditService.ets`）
  - 负责新增/编辑流程的中间状态管理、选中地址的持久化与变更通知。

- 业务数据工具（`common/service/RcpUtilsService.ets`）
  - 提供用户查询、商品/分类、地址、会员等级与权益等数据的获取与更新（具体数据源实现以现有代码为准）。

## 资源与配置

- 资源位于 `entry/src/main/resources/base` 与 `dark`，包含图标、图片、文案、色板等。
- 路由、页面清单与资源表在 `entry/build` 生成产物中可查看（只读）。

## 已知行为与限制（基于现有代码）

- 支付为前端模拟流程：点击“确认支付”即生成订单记录并跳转详情，无真实支付对接。
- 登录依赖验证码校验服务与用户信息查询工具；具体校验逻辑与后端对接以现有实现为准。
- 订单与地址等数据使用本地持久化（`AppStorage`/`PersistentStorage`），存在清理策略与时效性限制（如订单 7 天过期清理）。

## 目录索引（关键路径）

- 入口能力：`entry/src/main/ets/entryability/EntryAbility.ets`
- 路由入口：`entry/src/main/ets/pages/Index.ets`
- 主页面：`entry/src/main/ets/pages/MainPage.ets`，底部栏 `view/BottomTabsBar.ets`
- 登录：`entry/src/main/ets/pages/LoginPage.ets`，状态：`common/service/LoginStateService.ets`
- 点餐：`entry/src/main/ets/view/OrderPage.ets`
- 地址：`entry/src/main/ets/view/AddressPage.ets`、`view/AddAddressPage.ets`，服务：`common/service/AddressEditService.ets`
- 结算：`entry/src/main/ets/view/CheckoutPage.ets`，服务：`common/service/CheckoutService.ets`
- 订单：`entry/src/main/ets/view/OrderListPage.ets`、`view/OrderDetailPage.ets`，服务：`common/service/OrderService.ets`
- 我的：`entry/src/main/ets/view/MinePage.ets`

## 构建与运行（简述）

请使用 DevEco Studio 或命令行按 OpenHarmony/ArkUI 标准流程构建与运行本工程；依赖配置见仓库根目录与 `entry` 模块内的 `oh-package.json5`、`build-profile.json5` 等文件。


