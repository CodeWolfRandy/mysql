#!usr/bin/python
#coding=gbk
import pymysql
#连接数据库
conn=pymysql.connect(user='root',password='password',database='samp_db')
cursor=conn.cursor()
#创建user表
# cursor.execute('create table user2(id varchar(20) primary key,name varchar(20))')
#插入一行数据，mysql的占位符都是%s
# cursor.execute('insert into user2(id,name) values(%s, %s)',['2','LANSHIP'])
#打印行数
print(cursor.rowcount)
#提交事务
conn.commit()
cursor.close()
#运行查询
cursor=conn.cursor()
cursor.execute('select * from user2 where id =%s',('2',))
values=cursor.fetchall()
print(values)
cursor.close()
conn.close()