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

 Date: 22/02/2022 21:13:13
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `telephone` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `avatar` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '用户头像URL',
  `level_type` int(0) NULL DEFAULT NULL COMMENT '会员等级，引用member_level.level_type',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_level_type` (`level_type`),
  CONSTRAINT `fk_user_member_level` FOREIGN KEY (`level_type`) REFERENCES `member_level`(`level_type`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, '一只安慕嘻', '15380979728', 'https://picsum.photos/150/150', NULL);
INSERT INTO `user` VALUES (2, '喝口白桃呜龙', '15996150127', 'https://picsum.photos/150/150', NULL);
INSERT INTO `user` VALUES (3, '机械院小院草', '15678971123', 'https://picsum.photos/150/150', NULL);
INSERT INTO `user` VALUES (4, '瑞幸用户_09208', '15380979711', 'https://picsum.photos/150/150', NULL);

-- 初始化会员等级
UPDATE `user` SET `level_type` = 1 WHERE `id` = 1;
UPDATE `user` SET `level_type` = 2 WHERE `id` = 2;
UPDATE `user` SET `level_type` = 3 WHERE `id` = 3;
UPDATE `user` SET `level_type` = 4 WHERE `id` = 4;

SET FOREIGN_KEY_CHECKS = 1;
