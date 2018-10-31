
-- mysql -D samp_db -u root -p < createtable.sql
create table students
	(
		id int unsigned not null auto_increment primary key,
		name char(8) not null,
		sex char(4) not null,
		age tinyint unsigned not null,
		tel char(13) null default "------"
	);

CREATE TABLE items(
id int( 5 ) NOT NULL AUTO_INCREMENT PRIMARY KEY ,
label varchar( 255 ) NOT NULL
);
 

insert into items(label) values ('xxx');
 
insert into items(label) values ('yyy');
 
insert into items(label) values ('zzz');
 

 
select * from items;
 
/*
 	id 	label
	1 	xxx
	2 	yyy
	3 	zzz
	
	*/
CREATE TABLE `user` (
  `user_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '会员信息表主键，自增长',
  `uuid` bigint(20) DEFAULT '0' COMMENT '会员唯一标识表主键，自增长',
  `guid` bigint(20) DEFAULT '0' COMMENT '用户中心全局ID',
  `is_certed` tinyint(4) DEFAULT '2' COMMENT '是否认证，1 认证 2  未认证',
  `mobile` varchar(40) COLLATE utf8mb4_bin NOT NULL COMMENT '手机号码',
  `last_login_tm` datetime(6) DEFAULT '0000-00-00 00:00:00.000000' COMMENT '最后一次登录时间',
  `last_login_device` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '最后一次登录设备号',
  `remark` varchar(250) COLLATE utf8mb4_bin DEFAULT '' COMMENT '备注',
  `is_deleted` tinyint(4) DEFAULT '1' COMMENT '是否删除，1 未删除，2 已删除',
  `created_tm` datetime(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '创建时间，默认是 CURRENT_TIMESTAMP(6)',
  `updated_tm` datetime(6) DEFAULT '0000-00-00 00:00:00.000000' ON UPDATE CURRENT_TIMESTAMP(6) COMMENT '修改时间，修改时 CURRENT_TIMESTAMP(6)',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=88889 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='会员信息表';



CREATE TABLE `user_bank_card` (
  `user_bank_card_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '会员银行卡表主键，自增长',
  `user_bank_card_audit_id` bigint(20) DEFAULT '0' COMMENT '会员银行卡审核表主键，自增长',
  `user_id` bigint(20) DEFAULT '0' COMMENT '会员信息表主键，自增长',
  `uuid` bigint(20) DEFAULT '0' COMMENT '会员唯一标识表主键，自增长',
  `province_id` bigint(20) DEFAULT '0' COMMENT '省表主键，自增长',
  `city_id` bigint(20) DEFAULT '0' COMMENT '市表主键，自增长',
  `area_id` bigint(20) DEFAULT '0' COMMENT '区表主键，自增长',
  `bank_name` varchar(20) COLLATE utf8mb4_bin DEFAULT '' COMMENT '银行名称',
  `accnt_bank` varchar(40) COLLATE utf8mb4_bin DEFAULT '' COMMENT '开户行',
  `bank_card_num` varchar(30) COLLATE utf8mb4_bin DEFAULT '' COMMENT '银行卡号码',
  `user_delete` tinyint(4) DEFAULT '1' COMMENT '用户删除标志，1 未删除 2 已删除',
  `user_delete_reason` varchar(100) COLLATE utf8mb4_bin DEFAULT '' COMMENT '用户删除原因',
  `is_deleted` tinyint(4) DEFAULT '1' COMMENT '是否删除，1 未删除，2 已删除',
  `created_tm` datetime(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '创建时间，默认是 CURRENT_TIMESTAMP(6)',
  `updated_tm` datetime(6) DEFAULT '0000-00-00 00:00:00.000000' ON UPDATE CURRENT_TIMESTAMP(6) COMMENT '修改时间，修改时 CURRENT_TIMESTAMP(6)',
  PRIMARY KEY (`user_bank_card_id`),
  KEY `IDX_ubc_uuid` (`uuid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=83855 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='会员银行卡表';


CREATE TABLE `user_bank_card_audit` (
  `user_bank_card_audit_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '会员银行卡审核表主键，自增长',
  `user_id` bigint(20) DEFAULT '0' COMMENT '会员信息表主键，自增长',
  `cfg_bank_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '银行配置表主键，自增长',
  `bank_name` varchar(20) COLLATE utf8mb4_bin DEFAULT '' COMMENT '银行名称',
  `accnt_bank` varchar(40) COLLATE utf8mb4_bin DEFAULT '' COMMENT '开户行',
  `bank_card_num` varchar(30) COLLATE utf8mb4_bin DEFAULT '' COMMENT '银行卡号码',
  `bank_card_url` varchar(250) COLLATE utf8mb4_bin DEFAULT '' COMMENT '银行卡图片URL',
  `province_id` bigint(20) DEFAULT '0' COMMENT '省表主键，自增长',
  `city_id` bigint(20) DEFAULT '0' COMMENT '市表主键，自增长',
  `area_id` bigint(20) DEFAULT '0' COMMENT '区表主键，自增长',
  `bank_3key_avl_sts` tinyint(4) DEFAULT '0' COMMENT '银行卡三要素是否可用，0 未知 1 不可用 2 可用',
  `bank_3key_remark` varchar(250) COLLATE utf8mb4_bin DEFAULT '' COMMENT '银行卡三要素可用备注',
  `bank_3key_check_result` tinyint(4) DEFAULT '1' COMMENT '银行卡三要素检验结果，1 未校验，2 校验成功 3 校验失败',
  `bank_3key_check_remark` varchar(250) COLLATE utf8mb4_bin DEFAULT '' COMMENT '银行卡三要素检验备注',
  `audit_sts` tinyint(4) DEFAULT '1' COMMENT '审核状态，1 待审核，2 通过， 3 未通过',
  `audit_by` bigint(20) DEFAULT '0' COMMENT '审核人 SYS_USER_ID',
  `audit_tm` datetime(6) DEFAULT '0000-00-00 00:00:00.000000' COMMENT '审核时间',
  `audit_remark` varchar(250) COLLATE utf8mb4_bin DEFAULT '' COMMENT '审核备注',
  `remark` varchar(250) COLLATE utf8mb4_bin DEFAULT '' COMMENT '备注',
  `is_deleted` tinyint(4) DEFAULT '1' COMMENT '是否删除，1 未删除，2 已删除',
  `created_tm` datetime(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '创建时间，默认是 CURRENT_TIMESTAMP(6)',
  `updated_tm` datetime(6) DEFAULT '0000-00-00 00:00:00.000000' ON UPDATE CURRENT_TIMESTAMP(6) COMMENT '修改时间，修改时 CURRENT_TIMESTAMP(6)',
  PRIMARY KEY (`user_bank_card_audit_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=83862 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='会员银行卡审核表';



CREATE TABLE `user_work_card_audit` (
  `user_work_card_audit_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '会员工牌审核表主键，自增长',
  `user_id` bigint(20) DEFAULT '0' COMMENT '会员信息表主键，自增长',
  `uuid` bigint(20) DEFAULT '0' COMMENT '会员唯一标识表主键，自增长',
  `work_card_url` varchar(250) COLLATE utf8mb4_bin DEFAULT '' COMMENT '工牌图片URL',
  `work_card_no` varchar(20) COLLATE utf8mb4_bin DEFAULT '' COMMENT '工牌号码',
  `ent_id` bigint(20) DEFAULT '0' COMMENT '标准企业表主键，从记返费同步，使用原系统ID',
  `audit_sts` tinyint(4) DEFAULT '1' COMMENT '审核状态，1 待审核，2 通过， 3 未通过',
  `audit_by` bigint(20) DEFAULT '0' COMMENT '审核人 SYS_USER_ID',
  `audit_remark` varchar(250) COLLATE utf8mb4_bin DEFAULT '' COMMENT '审核备注',
  `audit_tm` datetime(6) DEFAULT '0000-00-00 00:00:00.000000' COMMENT '审核时间',
  `remark` varchar(250) COLLATE utf8mb4_bin DEFAULT '' COMMENT '备注',
  `is_deleted` tinyint(4) DEFAULT '1' COMMENT '是否删除，1 未删除，2 已删除',
  `created_tm` datetime(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '创建时间，默认是 CURRENT_TIMESTAMP(6)',
  `updated_tm` datetime(6) DEFAULT '0000-00-00 00:00:00.000000' ON UPDATE CURRENT_TIMESTAMP(6) COMMENT '修改时间，修改时 CURRENT_TIMESTAMP(6)',
  PRIMARY KEY (`user_work_card_audit_id`)
) ENGINE=InnoDB AUTO_INCREMENT=83817 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='会员工牌审核表';

CREATE TABLE `user_idcard` (
  `user_idcard_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '会员身份证表主键，自增长',
  `user_id` bigint(20) DEFAULT '0' COMMENT '会员信息表主键，自增长',
  `uuid` bigint(20) DEFAULT '0' COMMENT '会员唯一标识表主键，自增长',
  `is_deleted` tinyint(4) DEFAULT '1' COMMENT '是否删除，1 未删除，2 已删除',
  `created_tm` datetime(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '创建时间，默认是 CURRENT_TIMESTAMP(6)',
  `updated_tm` datetime(6) DEFAULT '0000-00-00 00:00:00.000000' ON UPDATE CURRENT_TIMESTAMP(6) COMMENT '修改时间，修改时 CURRENT_TIMESTAMP(6)',
  PRIMARY KEY (`user_idcard_id`)
) ENGINE=InnoDB AUTO_INCREMENT=83857 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='会员身份证表';


CREATE TABLE `user_unique` (
  `uuid` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '会员唯一标识表主键，自增长',
  `id_card_num` varchar(20) COLLATE utf8mb4_bin DEFAULT '' COMMENT '身份证号码',
  `real_name` varchar(20) COLLATE utf8mb4_bin DEFAULT '' COMMENT '真实姓名',
  `gender` tinyint(4) NOT NULL COMMENT '性别 1 男 2 女',
  `remark` varchar(250) COLLATE utf8mb4_bin DEFAULT '' COMMENT '备注',
  `is_deleted` tinyint(4) DEFAULT '1' COMMENT '是否删除，1 未删除，2 已删除',
  `created_tm` datetime(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '创建时间，默认是 CURRENT_TIMESTAMP(6)',
  `updated_tm` datetime(6) DEFAULT '0000-00-00 00:00:00.000000' ON UPDATE CURRENT_TIMESTAMP(6) COMMENT '修改时间，修改时 CURRENT_TIMESTAMP(6)',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `idx_user_unique_idcardnum` (`id_card_num`)
) ENGINE=InnoDB AUTO_INCREMENT=348181 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='会员唯一标识表';

CREATE TABLE `sp_fund_app_split_detail` (
  `sp_fund_app_split_detail_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '服务商账户出入金申请拆分明细表主键，自增长',
  `sp_fund_app_id` bigint(20) DEFAULT '0' COMMENT '服务商账户出入金申请表主键，自增长',
  `sp_fund_app_split_typ` tinyint(4) DEFAULT NULL COMMENT '服务商账户出入金申请拆分类型， 1 催款单 2 押金',
  `sp_id` bigint(20) DEFAULT '0' COMMENT '服务商表主键，从记返费同步，使用原系统ID',
  `ent_id` bigint(20) DEFAULT '0' COMMENT '标准企业表主键，从记返费同步，使用原系统ID',
  `biz_mo` date DEFAULT '0000-00-00' COMMENT '业务实际发生月',
  `weekly_salary_amt` bigint(20) DEFAULT '0' COMMENT '周薪(分)',
  `monthly_salary_amt` bigint(20) DEFAULT '0' COMMENT '月薪(分)',
  `platform_srvc_amt` bigint(20) DEFAULT '0' COMMENT '平台服务费用(分)',
  `agent_amt` bigint(20) DEFAULT '0' COMMENT '中介费用(分)',
  `deposit_amt` char(10) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '押金',
  `audit_sts` tinyint(4) DEFAULT '1' COMMENT '审核状态，1 待审核，2 通过， 3 未通过',
  `is_deleted` tinyint(4) DEFAULT '1' COMMENT '是否删除，1 未删除，2 已删除',
  `created_tm` datetime(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '创建时间，默认是 CURRENT_TIMESTAMP(6)',
  `updated_tm` datetime(6) DEFAULT '0000-00-00 00:00:00.000000' ON UPDATE CURRENT_TIMESTAMP(6) COMMENT '修改时间，修改时 CURRENT_TIMESTAMP(6)',
  PRIMARY KEY (`sp_fund_app_split_detail_id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='服务商账户出入金申请拆分明细表';