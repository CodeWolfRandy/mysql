#!usr/bin/python
#coding=gbk
import pymysql
#�������ݿ�
conn=pymysql.connect(user='root',password='password',database='samp_db')
cursor=conn.cursor()
#����user��
# cursor.execute('create table user2(id varchar(20) primary key,name varchar(20))')
#����һ�����ݣ�mysql��ռλ������%s
# cursor.execute('insert into user2(id,name) values(%s, %s)',['2','LANSHIP'])
#��ӡ����
print(cursor.rowcount)
#�ύ����
conn.commit()
cursor.close()
#���в�ѯ
cursor=conn.cursor()
cursor.execute('select * from user2 where id =%s',('2',))
values=cursor.fetchall()
print(values)
cursor.close()
conn.close()