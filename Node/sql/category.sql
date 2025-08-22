/*
 Navicat Premium Data Transfer

 Source Server         : Mysql8.0.25
 Source Server Type    : MySQL
 Source Server Version : 80025
 Source Host           : localhost:3306
 Source Schema         : luckin

 Target Server Type    : MySQL
 Target Server Version : 80025
 File Encoding         : 65001

 Date: 07/02/2022 22:38:24
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '一级分类的名称',
  `desc` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '该分类的描述',
  `indexImg` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '该分类是不是有引导图',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES (1, '谷爱凌推荐', '这一杯应援你的热爱', NULL);
INSERT INTO `category` VALUES (2, '人气Top', '瑞幸必喝爆款，无限回购', NULL);
INSERT INTO `category` VALUES (3, '丝绒拿铁', '小分子膜分离工艺厚奶\\n丝滑感提升20.99%', NULL);
INSERT INTO `category` VALUES (4, '厚乳拿铁', '冷萃厚牛乳注入 醇厚新口感\\n2020 EDGE Awards年度新消费产品', NULL);
INSERT INTO `category` VALUES (5, '生椰家族', '《新周刊》2021中国生活趋势磅 国民风味', NULL);
INSERT INTO `category` VALUES (6, '经典拿铁', 'Espresso 邂逅丝滑牛奶\\n超越经典，一口惊艳', NULL);
INSERT INTO `category` VALUES (7, '大师咖啡', 'WBC(世界咖啡师大赛)冠军团队拼配\\n2020 IIAC国际咖啡品鉴大赛金奖咖啡', NULL);
INSERT INTO `category` VALUES (8, '瑞纳冰®', NULL, NULL);
INSERT INTO `category` VALUES (9, '小鹿茶', '这杯小鹿茶，藏在咖啡店', NULL);
INSERT INTO `category` VALUES (10, '甜品小点', NULL, NULL);
INSERT INTO `category` VALUES (11, '烘焙轻食', '元气唤醒，谷物给我力量', NULL);
INSERT INTO `category` VALUES (12, '经典饮品', NULL, NULL);

SET FOREIGN_KEY_CHECKS = 1;
