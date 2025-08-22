-- 创建带外键关联的地址表
CREATE TABLE address (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    user_id INT NOT NULL COMMENT '关联用户ID',
    contact_person VARCHAR(50) NOT NULL COMMENT '联系人',
    gender ENUM('男', '女') NOT NULL COMMENT '性别',
    phone_number VARCHAR(20) NOT NULL COMMENT '手机号',
    address TEXT NOT NULL COMMENT '地址',
    house_number VARCHAR(20) NOT NULL COMMENT '门牌号',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    -- 添加外键约束
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- 为手机号字段添加唯一约束，确保一个手机号只能对应一个地址记录
    UNIQUE KEY unique_phone (phone_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='地址信息表';

-- 为外键字段添加索引
CREATE INDEX idx_user_id ON address(user_id);

-- 为手机号字段添加索引
CREATE INDEX idx_phone_number ON address(phone_number);

-- 为联系人字段添加索引
CREATE INDEX idx_contact_person ON address(contact_person);

-- 插入示例数据
INSERT INTO address (user_id, contact_person, gender, phone_number, address, house_number) VALUES
(1, '一只安慕嘻', '男', '15380979728', '北京市朝阳区建国门外大街1号', 'A座1501室'),
(2, '喝口白桃呜龙', '女', '15996150127', '上海市浦东新区陆家嘴环路1000号', 'B栋2202室');

-- 示例查询：联立查询用户和地址信息
-- SELECT u.name, u.telephone, a.contact_person, a.gender, a.address, a.house_number
-- FROM user u
-- LEFT JOIN address a ON u.id = a.user_id;
