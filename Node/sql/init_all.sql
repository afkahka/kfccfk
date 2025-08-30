SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 会员等级表
CREATE TABLE `member_level` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `level_type` INT NOT NULL COMMENT '等级类型，对应返回的levelType',
  `level_name` VARCHAR(50) NOT NULL COMMENT '等级名称，对应返回的levelName',
  `growth_value_min` INT NOT NULL COMMENT '成长值最小值',
  `growth_value_max` INT NULL DEFAULT NULL COMMENT '成长值最大值，null表示无上限',
  `growth_multiplier` DECIMAL(5,2) NULL DEFAULT NULL COMMENT '成长加成系数，1=100%',
  `current_level_txt` VARCHAR(255) NULL DEFAULT NULL COMMENT '当前等级提示文案',
  `current_level_rights_num` INT NOT NULL DEFAULT 0 COMMENT '当前等级权益数量',
  `next_level_txt` VARCHAR(255) NULL DEFAULT NULL COMMENT '下一等级提示文案',
  `next_level_rights_num` INT NOT NULL DEFAULT 0 COMMENT '下一等级权益数量',
  `level_unlock_rights_num` INT NULL DEFAULT NULL COMMENT '等级解锁权益数量',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_level_type` (`level_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会员等级表';

-- 示例数据，来源于给定返回数据的概要
INSERT INTO `member_level` 
(`level_type`, `level_name`, `growth_value_min`, `growth_value_max`, `growth_multiplier`, `current_level_txt`, `current_level_rights_num`, `next_level_txt`, `next_level_rights_num`, `level_unlock_rights_num`) VALUES
(1, '微雪花', 0, 30, 1.00, NULL, 6, '生日福利', 10, NULL),
(2, '小雪球', 31, 100, 1.05, '生日福利', 10, '新品试饮', 12, NULL),
(3, '大雪人', 101, 1000, 1.10, '新品试饮', 12, '周边特价', 15, NULL),
(4, '冰雪王', 1001, NULL, 1.15, '周边特价', 15, NULL, 0, NULL);

-- 会员权益分类表
CREATE TABLE `member_right_category` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `category` INT NOT NULL COMMENT '分类编号，对应返回的category',
  `category_name` VARCHAR(50) NOT NULL COMMENT '分类名称',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会员权益分类表';

-- 示例分类数据
INSERT INTO `member_right_category` (`category`, `category_name`) VALUES
(1, '每日礼'),
(2, '成长礼'),
(3, '心意礼');

-- 会员权益主表
CREATE TABLE `member_right` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `external_id` VARCHAR(32) NOT NULL COMMENT '外部返回的id（字符串）',
  `category` INT NOT NULL COMMENT '所属分类，对应category',
  `right_name` VARCHAR(100) NOT NULL COMMENT '权益名称',
  `assist_desc` VARCHAR(255) NULL DEFAULT NULL COMMENT '辅助说明',
  `imgs` VARCHAR(500) NULL DEFAULT NULL COMMENT '图片URL',
  `right_desc` TEXT NULL COMMENT '权益描述',
  `day_of_week` TINYINT NULL DEFAULT NULL COMMENT '星期几，1-7',
  `jump_url` TEXT NULL COMMENT '跳转URL或JSON',
  `select_type` TINYINT NULL DEFAULT NULL COMMENT '选择类型',
  `limit_date_type` TINYINT NULL DEFAULT NULL COMMENT '限制日期类型',
  `limit_date` VARCHAR(100) NULL DEFAULT NULL COMMENT '限制日期',
  `limit_time_type` TINYINT NULL DEFAULT NULL COMMENT '限制时间类型',
  `need_pop` TINYINT NULL DEFAULT NULL COMMENT '是否弹窗',
  `is_has_right` TINYINT NULL DEFAULT NULL COMMENT '是否拥有该权益',
  `jump_url_channel_type` TINYINT NULL DEFAULT NULL COMMENT '跳转渠道类型',
  `received_status` TINYINT NULL DEFAULT NULL COMMENT '领取状态',
  `show_in_main_page` TINYINT NULL DEFAULT NULL COMMENT '主页展示',
  `main_page_show_setting` TEXT NULL COMMENT '主页展示配置JSON',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_external` (`external_id`),
  KEY `idx_category` (`category`),
  CONSTRAINT `fk_right_category` FOREIGN KEY (`category`) REFERENCES `member_right_category`(`category`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会员权益主表';

-- 等级-权益映射表（一个等级包含多个权益，权益可被多个等级复用）
CREATE TABLE `member_level_right` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `level_type` INT NOT NULL COMMENT '等级类型，引用member_level.level_type',
  `right_external_id` VARCHAR(32) NOT NULL COMMENT '权益外部ID，引用member_right.external_id',
  `show_in_main_page` TINYINT NULL DEFAULT NULL COMMENT '是否在主页展示（覆盖级）',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_level_right` (`level_type`, `right_external_id`),
  KEY `idx_level_type` (`level_type`),
  KEY `idx_right_external_id` (`right_external_id`),
  CONSTRAINT `fk_level_right_level` FOREIGN KEY (`level_type`) REFERENCES `member_level`(`level_type`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_level_right_right` FOREIGN KEY (`right_external_id`) REFERENCES `member_right`(`external_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会员等级-权益映射表';

-- 示例权益（从返回数据中挑选2条代表性数据）
INSERT INTO `member_right`(
  `external_id`, `category`, `right_name`, `assist_desc`, `imgs`, `right_desc`,
  `day_of_week`, `jump_url`, `select_type`, `limit_date_type`, `limit_date`, `limit_time_type`,
  `need_pop`, `is_has_right`, `jump_url_channel_type`, `received_status`, `show_in_main_page`, `main_page_show_setting`
) VALUES
('5', 1, '周五秒杀日', '雪王币秒杀券', 'https://mxsa-oss.mxbc.net/oss/h5/20231205/ff2e55844b1c4845b2a5ca2e525b653e.png', '所有会员可在周五参与雪王币超值秒杀，少量雪王币限量秒杀大额券。', 5,
 '{"appJumpUrl":"mxsa://web?from=duiba&redirect_uri=https://76177-activity.dexfu.cn/chw/visual-editor/skins?id=332713","wechatMiniJumpUrl":"https://76177-activity.dexfu.cn/chw/visual-editor/skins?id=332713","alipayMiniJumpUrl":"https://76177-activity.dexfu.cn/chw/visual-editor/skins?id=332713"}', 0, 1, '', 2, NULL, 1, 1, 2, 1, '{"showButtonFlag":1,"buttonText":"去秒杀"}'),
('1', 1, '周一咖啡日', '美式3.99起', 'https://mxsa-oss.mxbc.net/oss/h5/20231205/cc890c6f07bc47199b9abde9d09356fd.png', '所有会员可在每周一领取1张“1.01元”美式券，券后享3.99元起喝美式。', 1,
 '{"appJumpUrl":"https://mxsa-h5.mxbc.net/#/redirect?env=release&path=pages%2Factivity%2Fcoupon-center%2Findex%3FactivityId%3D1872555563028729857","wechatMiniJumpUrl":"/pages/activity/coupon-center/index?activityId=1872555563028729857","alipayMiniJumpUrl":"/pages/activity/coupon-center/index?activityId=1872555563028729857"}', 0, 2, '', 2, NULL, 1, 1, 2, 1, '{"showButtonFlag":1,"buttonText":"去领取"}');

-- 四个等级与两条示例权益的映射
INSERT INTO `member_level_right`(`level_type`, `right_external_id`, `show_in_main_page`) VALUES
(1, '5', 1),
(1, '1', 1),
(2, '5', 1),
(2, '1', 1),
(3, '5', 1),
(3, '1', 1),
(4, '5', 1),
(4, '1', 1);

-- 批量插入全部权益（1-15），使用 INSERT IGNORE 避免与已插入的重复
INSERT IGNORE INTO `member_right`(
  `external_id`, `category`, `right_name`, `assist_desc`, `imgs`, `right_desc`,
  `day_of_week`, `jump_url`, `select_type`, `limit_date_type`, `limit_date`, `limit_time_type`,
  `need_pop`, `is_has_right`, `jump_url_channel_type`, `received_status`, `show_in_main_page`, `main_page_show_setting`
) VALUES
-- 1 周一咖啡日（已存在，忽略重复）
('1', 1, '周一咖啡日', '美式3.99起', 'https://mxsa-oss.mxbc.net/oss/h5/20231205/cc890c6f07bc47199b9abde9d09356fd.png', '【所有会员可享】所有会员可在每周一领取1张“1.01元”美式券，券后享3.99元起喝美式。', 1,
 '{"appJumpUrl":"https://mxsa-h5.mxbc.net/#/redirect?env=release&path=pages%2Factivity%2Fcoupon-center%2Findex%3FactivityId%3D1872555563028729857","wechatMiniJumpUrl":"/pages/activity/coupon-center/index?activityId=1872555563028729857","alipayMiniJumpUrl":"/pages/activity/coupon-center/index?activityId=1872555563028729857"}', 0, 2, '', 2, NULL, 1, 1, 2, 1, '{"showButtonFlag":1,"buttonText":"去领取"}'),
-- 2 周二抵现日
('2', 1, '周二抵现日', '雪王币当钱花', 'https://mxsa-oss.mxbc.net/oss/h5/20231205/dc09658a08554f9a8a003c591d58c966.png', '【所有会员可享】所有会员可在每周二使用雪王币抵现,详细规则为：\n①订单支付金额满足抵现金额，且手动勾选开启按钮即可参与抵现；\n②每50个雪王币抵0.1元，最高可抵扣订单金额的12%；\n③雪王币抵现不可与其他优惠活动同享；', 2,
 '', 0, 2, '', 1, NULL, 1, 0, 2, 1, '{"showButtonFlag":0,"buttonText":""}'),
-- 3 周三会员日
('3', 1, '周三会员日', '满12元减2元', 'https://mxsa-oss.mxbc.net/oss/h5/20231205/59611927681a463abaa6c31d8342dee2.png', '【所有会员可享】所有会员可在每周三会员日领取一张“满12减2”全场饮品券，每人每周限领一次。', 3,
 '{"appJumpUrl":"https://mxsa-h5.mxbc.net/#/redirect?env=release&path=pages%2Factivity%2Fcoupon-center%2Findex%3FactivityId%3D1859894747833970690","wechatMiniJumpUrl":"/pages/activity/coupon-center/index?activityId=1859894747833970690","alipayMiniJumpUrl":"/pages/activity/coupon-center/index?activityId=1859894747833970690"}', 0, 2, '', 2, NULL, 1, 1, 2, 1, '{"showButtonFlag":1,"buttonText":"去领取"}'),
-- 4 周四加料日
('4', 1, '周四加料日', '满12元可享', 'https://mxsa-oss.mxbc.net/oss/h5/20231205/c3fa7403f3704392b2ce266639c22e1b.png', '【所有会员可享】所有会员可在每周四领取一张1元小料券，订单满12元可用，即满12元免费加1元小料一份哦~', 4,
 '{"appJumpUrl":"https://mxsa-h5.mxbc.net/#/redirect?env=release&path=pages%2Factivity%2Fcoupon-center%2Findex%3FactivityId%3D1872556604818341889","wechatMiniJumpUrl":"/pages/activity/coupon-center/index?activityId=1872556604818341889","alipayMiniJumpUrl":"/pages/activity/coupon-center/index?activityId=1872556604818341889"}', 0, 2, '', 2, NULL, 1, 1, 2, 1, '{"showButtonFlag":1,"buttonText":"去领取"}'),
-- 5 周五秒杀日（已存在，忽略重复）
('5', 1, '周五秒杀日', '雪王币秒杀券', 'https://mxsa-oss.mxbc.net/oss/h5/20231205/ff2e55844b1c4845b2a5ca2e525b653e.png', '【所有会员可享】所有会员可在周五参与雪王币超值秒杀，少量雪王币限量秒杀大额券。', 5,
 '{"appJumpUrl":"mxsa://web?from=duiba&redirect_uri=https://76177-activity.dexfu.cn/chw/visual-editor/skins?id=332713","wechatMiniJumpUrl":"https://76177-activity.dexfu.cn/chw/visual-editor/skins?id=332713","alipayMiniJumpUrl":"https://76177-activity.dexfu.cn/chw/visual-editor/skins?id=332713"}', 0, 1, '', 2, NULL, 1, 1, 2, 1, '{"showButtonFlag":1,"buttonText":"去秒杀"}'),
-- 6 新手礼包
('6', 2, '新手礼包', '20元券包', 'https://mxsa-oss.mxbc.net/oss/h5/20231205/e1d06d26e1684bd38f2582977b890e8c.png', '【首次入会】可享，首次在蜜雪冰城微信/支付宝小程序/APP注册会员可领20元新人券包，少量门店不可用。', 6,
 '', 4, NULL, '', NULL, NULL, 1, 0, 2, 0, NULL),
-- 7 生日福利
('7', 2, '生日福利', '优惠券7折起', 'https://mxsa-oss.mxbc.net/oss/h5/20231205/5c75fa6426a44fe6a1d1af8467c5bdee.png', '【小雪球及以上等级可享】在生日当天为您发放对应等级的生日礼包，设置当天生日的会员，生日礼包将于次日发放。', 2,
 '', 3, NULL, '', NULL, NULL, 0, 0, 2, 1, NULL),
-- 8 等级加速
('8', 2, '等级加速', '速度+10%', 'https://mxsa-oss.mxbc.net/oss/h5/20231205/958e4cc626b548678008b90b560af2e6.png', '【小雪球及以上等级可享】单笔订单满15元，雪王币/甜蜜值+10%。', 3,
 '', 2, NULL, '', NULL, NULL, 0, 0, 2, 1, NULL),
-- 9 升级礼包
('9', 2, '升级礼包', '优惠低至85折', 'https://mxsa-oss.mxbc.net/oss/h5/20231205/ede7f6127f30487aa7a3d324cf481401.png', '每次升级后可领取对应等级的升级礼包，升级为小雪球得7元券包，升级为大雪球得8元券包，升级为冰雪王得10元券包。', 4,
 '', 5, NULL, '', NULL, NULL, 0, 0, 2, 1, NULL),
-- 10 新品试饮
('10', 2, '新品试饮', '领新品88折券', 'https://mxsa-oss.mxbc.net/oss/h5/20231205/93bfa5869a554d4883130c80f8ab803b.png', '【大雪人及以上等级可享】全国新品小程序/App上线后，可领取1张/2张单杯新品88折券，快邀您的朋友一起来尝鲜吧', 5,
 '', 1, 1, '', 3, NULL, 0, 0, 2, 1, NULL),
-- 11 闲时优惠
('11', 2, '闲时优惠', '每周1张9折券', 'https://mxsa-oss.mxbc.net/oss/h5/20231205/a569d666ff0d4fcca941d8420f373d98.png', '【小雪球及以上等级可享】每周可领取一张9折券，仅限每周一至周四的00:00-11:00和21:00-23:59下单使用。', 1,
 '', 1, 1, '', 2, NULL, 0, 0, 2, 1, NULL),
-- 12 客服绿色通道
('12', 3, '客服绿色通道', '优先接线', 'https://mxsa-oss.mxbc.net/oss/h5/20231205/b58d324b934740c6ba6c39435f6e8d92.png', '【大雪人及以上等级会员可享】在APP小程序发起客服会话时享优先进线特权，同等级会员按进线时间接待。', 1,
 '', 0, NULL, '', NULL, NULL, 0, 0, 2, NULL, NULL),
-- 13 周边特价
('13', 3, '周边特价', '最低8折买周边', 'https://mxsa-oss.mxbc.net/oss/h5/20231205/d3e9c900f6384cc186b9d67ff87b5bc2.png', '敬请期待', 2,
 '{"appJumpUrl":"","wechatMiniJumpUrl":"","alipayMiniJumpUrl":""}', 0, NULL, '', NULL, NULL, 0, 1, 1, NULL, NULL),
-- 14 免费一袋冰
('14', 3, '免费一袋冰', '敬请期待', 'https://mxsa-oss.mxbc.net/oss/h5/20231205/a4f47d51c87d43478f857662f6b6de46.png', '该权益正在筹备中，敬请期待！', 3,
 '', 0, 1, '', 3, NULL, 0, 0, 0, NULL, NULL),
-- 15 音乐节门票
('15', 3, '音乐节门票', '免费抽门票', 'https://mxsa-oss.mxbc.net/oss/h5/20231205/607afd74669d4ab8b1398b352210f080.png', '【冰雪王会员可享】可优先参加冰淇淋音乐节的抢票活动，详细规则将在音乐节举办前公布，敬请关注。', 4,
 '', 0, NULL, '', NULL, NULL, 0, 0, 0, NULL, NULL);

-- 为四个等级批量建立与全部权益的映射，忽略已存在映射
-- 根据等级差异调整 show_in_main_page 取值，为各等级设置不同的默认权益集
INSERT IGNORE INTO `member_level_right`(`level_type`, `right_external_id`, `show_in_main_page`) VALUES
-- 微雪花(1)：基础权益，主要展示每日礼和成长礼
(1, '1', 1),(1, '2', 1),(1, '3', 1),(1, '4', 1),(1, '5', 1),(1, '6', 1),(1, '7', 0),(1, '8', 0),(1, '9', 0),(1, '10', 0),(1, '11', 0),(1, '12', 0),(1, '13', 0),(1, '14', 0),(1, '15', 0),
-- 小雪球(2)：进阶权益，展示每日礼、成长礼和部分心意礼
(2, '1', 1),(2, '2', 1),(2, '3', 1),(2, '4', 1),(2, '5', 1),(2, '6', 0),(2, '7', 1),(2, '8', 1),(2, '9', 1),(2, '10', 0),(2, '11', 1),(2, '12', 0),(2, '13', 0),(2, '14', 0),(2, '15', 0),
-- 大雪人(3)：高级权益，展示每日礼、成长礼和更多心意礼
(3, '1', 1),(3, '2', 1),(3, '3', 1),(3, '4', 1),(3, '5', 1),(3, '6', 0),(3, '7', 1),(3, '8', 1),(3, '9', 1),(3, '10', 1),(3, '11', 1),(3, '12', 1),(3, '13', 0),(3, '14', 0),(3, '15', 0),
-- 冰雪王(4)：顶级权益，展示所有权益
(4, '1', 1),(4, '2', 1),(4, '3', 1),(4, '4', 1),(4, '5', 1),(4, '6', 0),(4, '7', 1),(4, '8', 1),(4, '9', 1),(4, '10', 1),(4, '11', 1),(4, '12', 1),(4, '13', 1),(4, '14', 1),(4, '15', 1);
-- =============================
-- 用户表
-- =============================
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `telephone` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `avatar` MEDIUMTEXT NULL COMMENT '用户头像Base64或URL',
  `coins` int(0) NOT NULL DEFAULT 0 COMMENT '雪王币余额',
  `growth_value` int(0) NOT NULL DEFAULT 0 COMMENT '成长值',
  `level_type` int(0) NULL DEFAULT NULL COMMENT '会员等级，引用member_level.level_type',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_level_type` (`level_type`),
  CONSTRAINT `fk_user_member_level` FOREIGN KEY (`level_type`) REFERENCES `member_level`(`level_type`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- 示例用户
INSERT INTO `user` (`id`,`name`,`telephone`,`avatar`,`level_type`) VALUES
(1,'一只安慕嘻','15380979728','https://fastly.picsum.photos/id/1003/150/150.jpg?hmac=zY9_CZXKARGUzHCNnktbiH4XWSpm6_h_9zfQ5E7aquY',NULL),
(2,'喝口白桃呜龙','15996150127','https://fastly.picsum.photos/id/1003/150/150.jpg?hmac=zY9_CZXKARGUzHCNnktbiH4XWSpm6_h_9zfQ5E7aquY',NULL),
(3,'机械院小院草','15678971123','https://picsum.photos/150/150',NULL),
(4,'瑞幸用户_09208','15380979711','https://picsum.photos/150/150',NULL)
ON DUPLICATE KEY UPDATE name=VALUES(name), telephone=VALUES(telephone), avatar=VALUES(avatar);

-- 初始化会员等级到用户（确保 member_level 已存在后再更新）
UPDATE `user` SET `level_type` = 1 WHERE `id` = 1;
UPDATE `user` SET `level_type` = 2 WHERE `id` = 2;
UPDATE `user` SET `level_type` = 3 WHERE `id` = 3;
UPDATE `user` SET `level_type` = 4 WHERE `id` = 4;

-- =============================
-- 分类与商品
-- =============================
DROP TABLE IF EXISTS `coffee`;
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '一级分类的名称',
  `desc` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '该分类的描述',
  `indexImg` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '该分类是不是有引导图',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

INSERT INTO `category` VALUES
(1, '谷爱凌推荐', '这一杯应援你的热爱', NULL),
(2, '人气Top', '瑞幸必喝爆款，无限回购', NULL),
(3, '丝绒拿铁', '小分子膜分离工艺厚奶\\n丝滑感提升20.99%', NULL),
(4, '厚乳拿铁', '冷萃厚牛乳注入 醇厚新口感\\n2020 EDGE Awards年度新消费产品', NULL),
(5, '生椰家族', '《新周刊》2021中国生活趋势磅 国民风味', NULL),
(6, '经典拿铁', 'Espresso 邂逅丝滑牛奶\\n超越经典，一口惊艳', NULL),
(7, '大师咖啡', 'WBC(世界咖啡师大赛)冠军团队拼配\\n2020 IIAC国际咖啡品鉴大赛金奖咖啡', NULL),
(8, '瑞纳冰®', NULL, NULL),
(9, '小鹿茶', '这杯小鹿茶，藏在咖啡店', NULL),
(10, '甜品小点', NULL, NULL),
(11, '烘焙轻食', '元气唤醒，谷物给我力量', NULL),
(12, '经典饮品', NULL, NULL)
ON DUPLICATE KEY UPDATE title=VALUES(title), `desc`=VALUES(`desc`), indexImg=VALUES(indexImg);

CREATE TABLE `coffee`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `price` int(11) NOT NULL,
  `oldprice` int(11) NULL DEFAULT NULL,
  `image` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `parentId` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_parentId` (`parentId`),
  CONSTRAINT `fk_coffee_category` FOREIGN KEY (`parentId`) REFERENCES `category`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 29 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

INSERT INTO `coffee` VALUES
(1, '生椰丝绒拿铁', 21, 35, 'https://p0.meituan.net/208.126/deal/093880b69e5e11abe419d5a83a3dbdd862872.jpg@100w_100h_1e_1c', 1),
(2, '蓝丝绒飒雪拿铁', 21, 35, 'https://img2.baidu.com/it/u=3877260444,3437185297&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=667', 1),
(3, '瓦尔登滑雪拿铁', 21, 35, 'https://img2.baidu.com/it/u=16908971,4283523234&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=700', 1),
(4, '丝绒拿铁', 20, 32, 'https://p1.meituan.net/208.126/deal/1f8a4c8ee4fa442156a732c5704f0a07704945.jpg@100w_100h_1e_1c', 1),
(5, '海盐芝士厚乳拿铁', 21, 35, 'https://img0.baidu.com/it/u=3720791090,332713631&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=666', 1),
(6, '耶加雪菲·澳瑞白', 21, 35, 'https://img1.baidu.com/it/u=1255445071,33924644&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=644', 1),
(7, '厚乳拿铁', 18, 32, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 1),
(8, '厚乳拿铁', 18, 32, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 2),
(9, '生椰丝绒拿铁', 21, 35, 'https://p0.meituan.net/208.126/deal/093880b69e5e11abe419d5a83a3dbdd862872.jpg@100w_100h_1e_1c', 2),
(10, '蓝丝绒飒雪拿铁', 21, 35, 'https://img2.baidu.com/it/u=3877260444,3437185297&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=667', 2),
(11, '丝绒拿铁', 20, 32, 'https://p1.meituan.net/208.126/deal/1f8a4c8ee4fa442156a732c5704f0a07704945.jpg@100w_100h_1e_1c', 2),
(12, '冲绳黑糖拿铁', 19, 32, 'https://img2.baidu.com/it/u=2165661496,874316978&fm=253&fmt=auto&app=138&f=JPEG?w=249&h=249', 2),
(13, '香草丝绒拿铁', 21, 35, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 3),
(14, '冲绳黑糖丝绒拿铁', 21, 35, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 3),
(15, '新鸳鸯红茶拿铁', 20, 32, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 4),
(16, '陨石厚乳拿铁', 21, 35, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 4),
(17, '生椰爱摩卡', 21, 35, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 5),
(18, '焦糖拿铁', 19, 32, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 6),
(19, '香草拿铁', 19, 32, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 6),
(20, '精萃澳瑞白', 19, 32, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 7),
(21, '卡布奇诺', 19, 32, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 7),
(22, '抹茶瑞纳冰', 21, 35, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 8),
(23, '如梦令·工夫轻乳茶', 18, 32, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 9),
(24, '桃桃大福', 6, 10, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 10),
(25, '抹茶奶酥软欧包', 10, 15, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 11),
(26, '牛肉芝士蛋香可颂', 13, 20, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 11),
(27, '经典核桃贝果', 8, 12, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 11),
(28, '纯牛奶', 13, 22, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 12)
ON DUPLICATE KEY UPDATE title=VALUES(title), price=VALUES(price), oldprice=VALUES(oldprice), image=VALUES(image), parentId=VALUES(parentId);

-- =============================
-- 优惠券与用户优惠券
-- =============================
DROP TABLE IF EXISTS `user_coupon`;
DROP TABLE IF EXISTS `coupon`;
CREATE TABLE `coupon` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(100) NOT NULL,
  `desc` VARCHAR(255) NULL,
  `threshold_amount` DECIMAL(10,2) NULL,
  `discount_amount` DECIMAL(10,2) NOT NULL,
  `valid_from` DATETIME NOT NULL,
  `valid_to` DATETIME NOT NULL,
  `total` INT NOT NULL DEFAULT 0,
  `status` ENUM('active','inactive') NOT NULL DEFAULT 'active',
  `channel` ENUM('new_user','campaign','manual') NOT NULL DEFAULT 'manual',
  `per_user_limit` INT NULL DEFAULT NULL,
  `applicable_skus` JSON NULL,
  `applicable_categories` JSON NULL,
  `exclusions` JSON NULL,
  KEY `idx_status_time` (`status`,`valid_from`,`valid_to`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='优惠券表';

CREATE TABLE `user_coupon` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `coupon_id` INT NOT NULL,
  `status` ENUM('unused','used','expired') NOT NULL DEFAULT 'unused',
  `obtained_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `used_at` DATETIME NULL,
  FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`coupon_id`) REFERENCES `coupon`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE KEY `uniq_user_coupon_once` (`user_id`,`coupon_id`),
  KEY `idx_user_status` (`user_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户优惠券表';

-- =============================
-- 地址表
-- =============================
DROP TABLE IF EXISTS `address`;
CREATE TABLE `address` (
    `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `user_id` INT NOT NULL COMMENT '关联用户ID',
    `contact_person` VARCHAR(50) NOT NULL COMMENT '联系人',
    `gender` ENUM('男', '女') NOT NULL COMMENT '性别',
    `phone_number` VARCHAR(20) NOT NULL COMMENT '手机号',
    `address` TEXT NOT NULL COMMENT '地址',
    `house_number` VARCHAR(20) NOT NULL COMMENT '门牌号',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY `unique_phone` (`phone_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='地址信息表';

CREATE INDEX `idx_user_id` ON `address`(`user_id`);
CREATE INDEX `idx_phone_number` ON `address`(`phone_number`);
CREATE INDEX `idx_contact_person` ON `address`(`contact_person`);

INSERT INTO `address` (`user_id`,`contact_person`,`gender`,`phone_number`,`address`,`house_number`) VALUES
(1,'一只安慕嘻','男','15380979728','北京市朝阳区建国门外大街1号','A座1501室'),
(2,'喝口白桃呜龙','女','15996150127','上海市浦东新区陆家嘴环路1000号','B栋2202室')
ON DUPLICATE KEY UPDATE phone_number=VALUES(phone_number), address=VALUES(address), house_number=VALUES(house_number);

-- =============================
-- 会员权益规则
-- =============================
DROP TABLE IF EXISTS `member_right_rule`;
CREATE TABLE `member_right_rule` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `level_type` INT NOT NULL COMMENT '会员等级，引用 member_level.level_type',
  `weekday` TINYINT NOT NULL COMMENT '周几：0-6，0=周日',
  `type` ENUM('percentage','fixed','threshold_cut') NOT NULL COMMENT '优惠类型：折扣/固定减免/满减',
  `percent_off` DECIMAL(5,2) NULL DEFAULT NULL COMMENT '折扣：80 表示8折',
  `threshold_amount` DECIMAL(10,2) NULL DEFAULT NULL COMMENT '满减门槛金额',
  `discount_amount` DECIMAL(10,2) NULL DEFAULT NULL COMMENT '减免金额',
  `quota_per_day` INT NULL DEFAULT NULL COMMENT '每日使用上限/配额',
  `priority` INT NOT NULL DEFAULT 100 COMMENT '优先级，数字越小优先级越高',
  `stackable` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否允许与其他优惠叠加',
  `status` ENUM('active','inactive') NOT NULL DEFAULT 'active' COMMENT '开关',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_level_type_weekday` (`level_type`,`weekday`),
  KEY `idx_status_priority` (`status`,`priority`),
  CONSTRAINT `fk_rule_member_level` FOREIGN KEY (`level_type`) REFERENCES `member_level`(`level_type`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=Dynamic COMMENT='会员权益规则表';

-- 示例：2级会员每周三 8折
INSERT INTO `member_right_rule` (`level_type`,`weekday`,`type`,`percent_off`,`priority`,`stackable`,`status`) VALUES
(2,3,'percentage',80,10,1,'active')
ON DUPLICATE KEY UPDATE percent_off=VALUES(percent_off), priority=VALUES(priority), stackable=VALUES(stackable), status=VALUES(status);

-- =============================
-- 雪王币流水
-- =============================
DROP TABLE IF EXISTS `user_coin_ledger`;
CREATE TABLE `user_coin_ledger` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `change_amount` INT NOT NULL COMMENT '正数入账，负数支出',
  `balance_after` INT NOT NULL COMMENT '变动后的余额快照',
  `reason` VARCHAR(100) NOT NULL COMMENT '原因编码，如 order_reward, order_pay, adjust',
  `order_id` INT NULL DEFAULT NULL,
  `remark` VARCHAR(255) NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_created` (`user_id`,`created_at`),
  CONSTRAINT `fk_coin_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='雪王币流水';

SET FOREIGN_KEY_CHECKS = 1;


