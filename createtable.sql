
-- mysql -D samp_db -u root -p < createtable.sql
create table students
	(
		id int unsigned not null auto_increment primary key,
		name char(8) not null,
		sex char(4) not null,
		age tinyint unsigned not null,
		tel char(13) null default "------"
	);
-- mysqladmin -u root -p password ???(?root?????)




/*
???? SQL ?????????? ( ???? 0.0170 ? )
*/
CREATE TABLE items(
id int( 5 ) NOT NULL AUTO_INCREMENT PRIMARY KEY ,
label varchar( 255 ) NOT NULL
);
 
/*
??????,???id,?????,??AUTO_INCREMENT
???? SQL ??????????
*/
insert into items(label) values ('xxx');
 
insert into items(label) values ('yyy');
 
insert into items(label) values ('zzz');
 
/*
?????,?????,???id???
*/
 
select * from items;
 
/*
 	id 	label
	1 	xxx
	2 	yyy
	3 	zzz
	
	*/