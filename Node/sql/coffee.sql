/*
 Navicat Premium Data Transfer

 Source Server         : 阿里云
 Source Server Type    : MySQL
 Source Server Version : 50724
 Source Host           : 47.117.139.145:3306
 Source Schema         : luckin

 Target Server Type    : MySQL
 Target Server Version : 50724
 File Encoding         : 65001

 Date: 21/02/2022 10:52:47
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for coffee
-- ----------------------------
DROP TABLE IF EXISTS `coffee`;
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

-- ----------------------------
-- Records of coffee
-- ----------------------------

INSERT INTO `coffee` VALUES (1, '生椰丝绒拿铁', 21, 35, 'https://p0.meituan.net/208.126/deal/093880b69e5e11abe419d5a83a3dbdd862872.jpg@100w_100h_1e_1c', 1);
INSERT INTO `coffee` VALUES (2, '蓝丝绒飒雪拿铁', 21, 35, 'https://img2.baidu.com/it/u=3877260444,3437185297&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=667', 1);
INSERT INTO `coffee` VALUES (3, '瓦尔登滑雪拿铁', 21, 35, 'https://img2.baidu.com/it/u=16908971,4283523234&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=700', 1);
INSERT INTO `coffee` VALUES (4, '丝绒拿铁', 20, 32, 'https://p1.meituan.net/208.126/deal/1f8a4c8ee4fa442156a732c5704f0a07704945.jpg@100w_100h_1e_1c', 1);
INSERT INTO `coffee` VALUES (5, '海盐芝士厚乳拿铁', 21, 35, 'https://img0.baidu.com/it/u=3720791090,332713631&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=666', 1);
INSERT INTO `coffee` VALUES (6, '耶加雪菲·澳瑞白', 21, 35, 'https://img1.baidu.com/it/u=1255445071,33924644&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=644', 1);
INSERT INTO `coffee` VALUES (7, '厚乳拿铁', 18, 32, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 1);
INSERT INTO `coffee` VALUES (8, '厚乳拿铁', 18, 32, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 2);
INSERT INTO `coffee` VALUES (9, '生椰丝绒拿铁', 21, 35, 'https://p0.meituan.net/208.126/deal/093880b69e5e11abe419d5a83a3dbdd862872.jpg@100w_100h_1e_1c', 2);
INSERT INTO `coffee` VALUES (10, '蓝丝绒飒雪拿铁', 21, 35, 'https://img2.baidu.com/it/u=3877260444,3437185297&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=667', 2);
INSERT INTO `coffee` VALUES (11, '丝绒拿铁', 20, 32, 'https://p1.meituan.net/208.126/deal/1f8a4c8ee4fa442156a732c5704f0a07704945.jpg@100w_100h_1e_1c', 2);
INSERT INTO `coffee` VALUES (12, '冲绳黑糖拿铁', 19, 32, 'https://img2.baidu.com/it/u=2165661496,874316978&fm=253&fmt=auto&app=138&f=JPEG?w=249&h=249', 2);
INSERT INTO `coffee` VALUES (13, '香草丝绒拿铁', 21, 35, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 3);
INSERT INTO `coffee` VALUES (14, '冲绳黑糖丝绒拿铁', 21, 35, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 3);
INSERT INTO `coffee` VALUES (15, '新鸳鸯红茶拿铁', 20, 32, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 4);
INSERT INTO `coffee` VALUES (16, '陨石厚乳拿铁', 21, 35, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 4);
INSERT INTO `coffee` VALUES (17, '生椰爱摩卡', 21, 35, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 5);
INSERT INTO `coffee` VALUES (18, '焦糖拿铁', 19, 32, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 6);
INSERT INTO `coffee` VALUES (19, '香草拿铁', 19, 32, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 6);
INSERT INTO `coffee` VALUES (20, '精萃澳瑞白', 19, 32, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 7);
INSERT INTO `coffee` VALUES (21, '卡布奇诺', 19, 32, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 7);
INSERT INTO `coffee` VALUES (22, '抹茶瑞纳冰', 21, 35, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 8);
INSERT INTO `coffee` VALUES (23, '如梦令·工夫轻乳茶', 18, 32, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 9);
INSERT INTO `coffee` VALUES (24, '桃桃大福', 6, 10, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 10);
INSERT INTO `coffee` VALUES (25, '抹茶奶酥软欧包', 10, 15, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 11);
INSERT INTO `coffee` VALUES (26, '牛肉芝士蛋香可颂', 13, 20, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 11);
INSERT INTO `coffee` VALUES (27, '经典核桃贝果', 8, 12, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 11);
INSERT INTO `coffee` VALUES (28, '纯牛奶', 13, 22, 'https://p0.meituan.net/208.126/deal/5901371a55477b182c24d092297442b439323.jpg@100w_100h_1e_1c', 12);

SET FOREIGN_KEY_CHECKS = 1;
