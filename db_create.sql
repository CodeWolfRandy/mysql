#脚本中不要使用制表符!在linux下运行脚本会提示语法错误运行失败 

DROP DATABASE IF EXISTS mss;
create database mss DEFAULT CHARSET=utf8;

use mss;

#频道
DROP TABLE IF EXISTS Channels;
create table Channels
(
id          int             auto_increment,
createtime  int             not null,
name        varchar(64)     not null,
description varchar(2048)   not null,
CONSTRAINT  Channels        PRIMARY KEY (id)
);

#栏目
DROP TABLE IF EXISTS Columns;
create table Columns
(
id          int             auto_increment,
channelid   int             not null,
createtime  int             not null,
name        varchar(64)     not null,
description varchar(2048)   not null,
CONSTRAINT  Columns         PRIMARY KEY (id)
);

#媒体接入--流信息 
DROP TABLE IF EXISTS MediaStream;
create table MediaStream
(
id          int            auto_increment,
createtime  int            not null,
parent      int                    ,  #协议为GB28181&视频源时,这里存的是视频源所属平台的国标源ID 
protocol    int            not null,  #5.GB28181, 0.RTSP，1.rtmp 
publish     int            default 0, #被发布次数  
record      int            default 0, #有几路录像  
sourceid    varchar(64)            ,  #国标源ID 协议为GB28181时，才有该项目,如果是平台下的视频源,则这里存的是视频源的ID 
mssid       varchar(64)            ,  #协议为GB28181时，才有该项目 
name        varchar(64)    default '',
password    varchar(64)    not null,
username    varchar(64)    not null,
token       varchar(256)   not null,  #
url         varchar(256)   not null,
description varchar(2048)          ,
visible     tinyint(1)     default 1, # 是否可见,在删除媒体接入时,如果存在录像文件,则不删除该项,仅将其设置为不可见 
CONSTRAINT  MediaStream    PRIMARY KEY (id),
UNIQUE MediaStreamTokenUniqueIndex (token(255))
);

#媒体仓库--目录 
DROP TABLE IF EXISTS MediaFileNode;
create table MediaFileNode
(
id            int           auto_increment,
parent        int           not null,
createtime    int           not null,
hierarchy     int           not null,         #当前节点的层级,需求要求最大16级目录,使用存储过程计算较为繁复,这个字段只在创建时起作用,具体业务不需要关心 
name          varchar(64)   not null,
description   varchar(2048) not null,
CONSTRAINT    MediaFileNode PRIMARY KEY (id)
);

#媒体仓库--录像文件 
DROP TABLE IF EXISTS MediaFile;
create table MediaFile
(
id          int           auto_increment,
taskid      int           not null,         #对应taskbackup任务表中创建的任务id
type        int           default 2,  #1.上传，2.下载，3转码，4录制
user        int           default 0,  #操作用户
diskid      int           not null,
parent      int           default 0,  #所属文件夹ID 
publish     int           default 0, #发布状态(被发布次数)  
duration    int           not null,
filesize    bigint        not null,
streamid    int                   ,  #来源，上传文件时为空，下载和录制时指向直播资源表，转码指向点播资源表 
starttime   int                   ,  #录制时为录制开始时间，下载时为平台录像时间，转码沿用源文件时间 
createtime  int           not null,
endtime     int                   ,
name        varchar(256)  not null,
path        varchar(256)  not null,
token       varchar(256)  not null, 
description varchar(2048) null,  #用户自定义描述 
CONSTRAINT  MediaFile     PRIMARY KEY (id),
UNIQUE MediaFileTokenUniqueIndex (token(255))
);

#资源列表--已发布媒体
DROP TABLE IF EXISTS MediaPublish;      #原MediaRelease
create table MediaPublish
(
token       varchar(256)    not null,    #资源ID
hits        int                     ,    #点击数
bdid        int                     ,    #源ID
hdid        int                     ,
sdid        int                     ,
ldid        int                     ,
level       int             not null,
restype     int             not null,    #0.直播 or 1.点播
transbdid   int                     ,    #模板ID
transhdid   int                     ,
transsdid   int                     ,
transldid   int                     ,
columnid    int             not null,
channelid   int             not null,
createtime  int             not null,
name        varchar(64)     not null,
imgurl      varchar(256)            ,     #播放次数 
description varchar(2048)           ,  
CONSTRAINT  MediaPublish    PRIMARY KEY (token(255))        
);

#录像模板
DROP TABLE IF EXISTS RecordTemplate;
create table RecordTemplate
(
id          int            auto_increment,
duration    int            not null,        #录制时长，以秒为单位 
createtime  int            not null,        #创建时间,后续update后会修改该时间(是否需要添加updateTime需要讨论) 
name        varchar(64)    not null,
format      varchar(64)    not null,        #录制格式，MP4/ASF 
token       varchar(256)   not null,
description varchar(2048)  not null,
CONSTRAINT  RecordTemplate PRIMARY KEY (id),
UNIQUE RecordTemplateTokenUniqueIndex (token(255))
);

#实时转码模板
DROP TABLE IF EXISTS StreamTransTemplate;   #原StreamTemplate
create table StreamTransTemplate
(
id              int           auto_increment,
stretch         int           not null,       #拉伸策略，1.自适应拉伸，2.等比例拉伸 
framerate       int           not null,
createtime      int           not null,
audiobitrate    int           not null,
videobitrate    int           not null,
audiochannelnum int           not null,
audiosamplerate int           not null,
name            varchar(64)   not null,
audiotype       varchar(64)   not null,
videotype       varchar(64)   not null,
streamformat    varchar(64)   not null,
videomode       varchar(64)   not null,        #编码复杂度，baseline/main/highprofile 
resolution      varchar(64)   not null,
token           varchar(256)  not null,
description     varchar(2048) not null,
CONSTRAINT      StreamTransTemplate  PRIMARY KEY (id),
UNIQUE StreamTransTemplateTokenUniqueIndex (token(255))
);

#文件转码模板
DROP TABLE IF EXISTS FileTransTemplate;   #原FileTemplate
create table FileTransTemplate
(
id              int           auto_increment,
stretch         int           not null,        #拉伸策略，1.自适应拉伸，2.等比例拉伸 
framerate       int           not null,
createtime      int           not null,
audiobitrate    int           not null,
videobitrate    int           not null,
audiosamplerate int           not null,
audiochannelnum int           not null,
name            varchar(64)   not null,
format          varchar(64)   not null,
videotype       varchar(64)   not null,
filetype        varchar(64)   not null,
videomode       varchar(64)   not null,         #编码复杂度，baseline/main/highprofile 
resolution      varchar(64)   not null,
audiotype       varchar(64)   not null,
token           varchar(256)  not null,
description     varchar(2048) not null,
CONSTRAINT      FileTransTemplate PRIMARY KEY (id),
UNIQUE FileTransTemplateTokenUniqueIndex (token(255))
);

#上传任务列表
DROP TABLE IF EXISTS UploadTask;   #原MediaUpload
create table UploadTask
(
token      varchar(256) not null,
user       int          not null,  #上传来源(user id)
diskid     int                  ,
parent     int          not null,  #上传媒体仓库节点id
status     int          not null,  #上传状态,0正在上传,1上传完毕,2上传失败.....状态枚举还需再议
streamid   int                  ,
filesize   int          not null,
createtime int          not null,
name       varchar(64)  not null,
path       varchar(256) not null,
CONSTRAINT UploadTask   PRIMARY KEY (token(255))
);

#导入任务列表
DROP TABLE IF EXISTS ImportTask;   #原MediaImport
create table ImportTask
(
token      varchar(256) not null,
user       int          not null,  #来源(user id) 
diskid     int                  ,
parent     int          not null,  #媒体仓库节点id 
status     int          not null,  #状态,0正在,1完毕,2失败.....状态枚举还需再议  
streamid   int                  ,
starttime  int          not null,
endtime    int          not null,
filesize   int          not null,
createtime int          not null,
name       varchar(64)  not null,
path       varchar(256) not null,
CONSTRAINT ImportTask   PRIMARY KEY (token(255))
);

#文件转码任务
DROP TABLE IF EXISTS FileTransTask;   #原FileTranscode
create table FileTransTask
(
token       varchar(256)  not null,
diskid      int           not null,
source_id   int           not null,    #点播源ID 
createtime  int           not null,
template_id int           not null,    #转码模板 
filenode_id int           not null,    #文件节点ID 
path        varchar(256)  not null,
filename    varchar(256)  not null,    
CONSTRAINT  FileTransTask PRIMARY KEY (token(255))        
);

#录像任务
DROP TABLE IF EXISTS RecordTask;  #原FileRecord
create table RecordTask
(
token          varchar(256) not null,
diskid         int          not null,
createtime     int          not null,
filenode_id    int          not null,   #MediaFileNode节点token
path           varchar(256) not null,
filename       varchar(256) not null,   #文件名 
source_token   varchar(256) not null,   #直播源ID 
template_token varchar(256) not null,   #录制模板ID 
status         int          default 0,  #录制状态 0 未开始 1 录制中 2 录制失败
CONSTRAINT     RecordTask   PRIMARY KEY (token(255))        
);

#文件合并任务 
DROP TABLE IF EXISTS FileMergeTask;
create table FileMergeTask
(
id             int           auto_increment,
diskid         int           not null,
isdelsrc       int           not null,            #完毕后是否删除源文件  
status         int           not null,            #0还未开始,1正在合并,2合并完毕,3合并失败  
createtime     int           not null,
dstfilepath    varchar(256)  null,
dstfilename    varchar(256)  null,
vodidlist      varchar(512)  not null,            #源文件列表,空格分隔 
CONSTRAINT     FileMergeTask PRIMARY KEY (id)
);

#磁盘信息
DROP TABLE IF EXISTS DiskInfo;
create table DiskInfo
(
id         int          auto_increment,
lasttime   int          not null,
uuid       char(64)     not null,
path       varchar(256) not null,
CONSTRAINT DiskInfo PRIMARY KEY (id)
);

#用户表
DROP TABLE IF EXISTS Users;
create table Users
(
id            int           auto_increment,
type          int           not null,   #0:guest 1:operater 2:administrator 3:super admin
lastlogintime int           not null,   #最后登录时间，显示和排序使用 
level         int           not null,
password      varchar(256)  not null,
privilege     varchar(256)  not null,   #操作浏览权限 
name          varchar(256)  not null,
CONSTRAINT    Users         PRIMARY KEY (id),
UNIQUE UsersNameUniqueIndex (name(255))
);

#首页指向的默认url 后台登陆页面 or 浏览页面;只有一条数据
DROP TABLE IF EXISTS WebDefault;
create table WebDefault
(
    url varchar(256) not null
);

DROP TABLE IF EXISTS SystemLog;
create table SystemLog
(
id          int             auto_increment,
createtime  int             not null,
devname     varchar(64)     not null,
type        varchar(64)     not null,
name        varchar(64)     not null,   #operator name
description varchar(2048)   not null,
CONSTRAINT  SystemLog       PRIMARY KEY (id),
INDEX       SystemLogTimeIndex (createtime)
);

#任务组--节点
DROP TABLE IF EXISTS TaskNode;
create table TaskNode
(
id            int   auto_increment,
name          varchar(64)   not null,
type          int           not null,         #0为备份类型 
createtime    int           not null,
CONSTRAINT    TaskNode PRIMARY KEY (id)
);

#备份录像任务
DROP TABLE IF EXISTS TaskBackup;
create table TaskBackup 
(
id           int   auto_increment,
token        varchar(255) not null,
streamid     int          not null,             #设备MediaStream表的id 
status       int          not null,             #0=未开始,1=等待中,2=正在录制,3=录制完成，>3 录制失败 (没有录像,过期等待) 
timetype     int          not null,             #0=一次性任务，1=周期任务 
vodtype      int          not null,             #0=一次性录像，1=周期录像
startday     int          not null,             #录像起始日期 当天0点 
starttime    int          not null,             #录像开始时间 从当天0点起的秒数 
endday       int          not null,             #录像结束日期 当天0点 
endtime      int          not null,             #录像结束时间 从当天0点起的秒数 
cyclemark    int          not null,             #录像周期标识, 第0bit:sunday,第1 bit:monday...  第 6 bit :  saturday 
parent       int          not null,             #所属任务组ID  
vodcount     int          not null,             #录像记录个数，smu内部使用。初始为0
taskmodle    int          default 0,             #任务类型 1-anr任务，0-非anr任务  
CONSTRAINT   TaskBackup PRIMARY KEY (id),
UNIQUE  TaskBackupTokenUniqueIndex (token(255))
);

#周期任务表
DROP TABLE IF EXISTS CycleTimeTask;
create table CycleTimeTask 
(
id           int   auto_increment,
tasktype     int,                        #0为备份类型  
taskid         int   not null,             #关联TaskBackup表任务 
startday     int   not null,             #录像起始日期 当天0点 
starttime    int,                        #开始时间 从当天0点起的秒数 
cyclemark    int,                        #周期标识, 第0bit:sunday,第1 bit:monday...  第 6 bit :  saturday 
CONSTRAINT    CycleTimeTask PRIMARY KEY (id)
);

#一次任务表
DROP TABLE IF EXISTS OneTimeTask;
create table OneTimeTask 
(
id            int   auto_increment,
tasktype      int,             #0为备份类型  
taskid           int  not null,   #关联TaskBackup表任务 
starttime     int,             #录像起始绝对时间 秒 
CONSTRAINT    OneTimeTask PRIMARY KEY (id)
);
DROP TABLE IF EXISTS AnrTask;
create table AnrTask
(
id            int   auto_increment,
sourceid      varchar(64),  #视频源id
offlinetime   int   not null,   #设备下线时间
CONSTRAINT    AnrTask  PRIMARY  KEY (id)
);

#Initialize the database 
#defalut home page relative url 
insert into WebDefault value ("console/login.html");
#supper admin user name: admin default pwd: 888888
insert into Users(name,password,type,level,privilege,lastlogintime) value("admin", "21218cca77804d2ba1922c33e0151105", 3, 4, "admin", TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()));
#default Channels 
insert into Channels(id,createtime,name,description) value(1,TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()),'直播频道','');
insert into Channels(id,createtime,name,description) value(2,TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()),'点播频道','');
#default Columns 
insert into Columns(id,channelid,createtime,name,description) value(1,1,TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()),'直播栏目','');
insert into Columns(id,channelid,createtime,name,description) value(2,2,TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()),'点播栏目','');
#default templates
insert into FileTransTemplate(id,stretch,framerate,createtime,audiobitrate,videobitrate,audiosamplerate,audiochannelnum,name,format,videotype,filetype,videomode,resolution,audiotype,token,description) value (1,1,25,1489764133,25,2048,0,0,'file_1280*720_mp4','','H264','MP4','Baseline','1280_720','AACLC','6DA9D7CD6CB9844BE1A7B8ED3CA90D93','1280*720分辨率，2M码率，MP4'),(2,1,15,1489764213,25,512,0,0,'file_352*228_MP4','','H264','MP4','Baseline','352_288','AACLC','3E0CFFB00DA8185172F3B33058D99FA4','352*228分辨率，512K码率，MP4');
insert into RecordTemplate(id,duration,createtime,name,format,token,description) value (1,120,1489764048,'一般发布录制','MP4','92D0D2CEA6E6C04F79226F5586EC066E','视频格式MP4');
insert into StreamTransTemplate(id,stretch,framerate,createtime,audiobitrate,videobitrate,audiochannelnum,audiosamplerate,name,audiotype,videotype,streamformat,videomode,resolution,token,description) values (1,1,25,1489763818,25,2048,0,0,'live_720P(1280*720)','AACLC','H264','RTP','Baseline','1280_720','FE0D47D19AF888FFDC07372B82901502','720P(1280*720)分辨率'),(2,1,15,1489763918,25,512,0,0,'live_cif(352*288)','AACLC','H264','RTP','Baseline','352_288','F741C81BFA752A72225E1720D5651DA7','cif(352*288)分辨率');

#procedure
DELIMITER $

#所有输出值为非查询结果存储过程返回值如下定义 
#返回字段统一为result 
#>0  为新插入数据id or 成功 
#=0  数据重复 
#=-1 父节点不存在 
#=-2 数据数量达到上限 
#=-3 数据不存在 
#=-4 用户不存在 
#=-5 密码不匹配 
#=-6 有其他数据残留无法删除 


DROP PROCEDURE IF EXISTS DEL_TASKBACKUPNODE$
create procedure DEL_TASKBACKUPNODE(
varId   int
)
begin
    declare retValue int;
    declare varName varchar(256);
    label:begin
        select name into varName from TaskNode where id = varId;
        delete from TaskNode where id = varId;
        insert into SystemLog value('', TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()), '', 0, 'admin', concat('删除任务组 ',varName,' 成功！'));    
        set retValue = 1;
    end;
    select retValue as result;
end$

DROP PROCEDURE IF EXISTS CREATE_TASKBACKUPNODE$
create procedure CREATE_TASKBACKUPNODE(
varName    varchar(64)
)
begin
    declare nCount, nSum, retValue int;
    label:begin
        select count(*) into nCount from TaskNode where name = varName;
        if nCount > 0 then
            insert into SystemLog value('', TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()), '', 0, 'admin', concat('新增任务组 ',varName,' 失败，任务组已存在！'));
            set retValue = 0;
            leave label;
        end if;
        select count(*) into nSum from TaskNode;
        if nSum >= 1024 then
            insert into SystemLog value('', TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()), '', 0, 'admin', concat('新增任务组 ',varName,' 失败，超出最大任务组数！'));
            set retValue = -2;
            leave label;
        end if;
        insert into SystemLog value('', TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()), '', 0, 'admin', concat('新增任务组 ',varName,' 成功！'));
        insert into TaskNode(name, type, createtime) value(varName,0,TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()));
        set retValue = last_insert_id();
    end;
    select retValue as result;
end$

DROP PROCEDURE IF EXISTS UPDATE_TASKBACKUPNODE$
create procedure UPDATE_TASKBACKUPNODE(
varID       int,  
varName     varchar(64)
)
begin
    declare nCount, retValue int;
    declare varOldName varchar(256);
    label:begin
        select name into varOldName from TaskNode where id = varId;
        select count(*) into nCount from TaskNode where name = varName;
        if nCount > 0 then
            insert into SystemLog value('', TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()), '', 0, 'admin', concat('修改任务组 ', varOldName,' 为 ',varName,' 失败，任务组已存在！'));
            set retValue = 0;
            leave label;
        end if;
        insert into SystemLog value('', TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()), '', 0, 'admin', concat('修改任务组 ', varOldName,' 为 ',varName,' 成功！'));
        update TaskNode set name = varName where id = varID;
        set retValue = 1;
    end;
    select retValue as result;
end$

DROP PROCEDURE IF EXISTS CREATE_TASKBACKUP$
create procedure CREATE_TASKBACKUP(
varToken          varchar(256),
varSrcID          int,
varNodeID         int,            #任务节点ID 
varTimeType       int,            #一次性还是周期任务 0=一次性任务，1=周期任务 
varStartDay       int,            #开始日期 
varStartTime      int,            #开始时间 
varCycleDay       int,            #任务周期标示 
varVodTimeType    int,            #一次性还是周期任务 0=一次性任务，1=周期任务 
varVodCycleDay    int,            #任务周期标示 
varVodStartDay    int,            #录像开始日期 
varVodStartTime   int,            #录像开始时间 
varVodEndDay      int,            #录像结束日期 
varVodEndTime     int            #录像结束时间 
)
begin
    declare nCount, retValue int;
    declare parentName,mediaName varchar(256);
    label:begin
        select count(*) into nCount from MediaStream where id = varSrcID;
        select name into mediaName from MediaStream where id = varSrcID;
        select name into parentName from TaskNode where id = varNodeID;
        if nCount = 0 then
            insert into SystemLog value('', TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()), '', 0, 'admin', concat('新增任务:任务组 ', parentName,' 视频源 ', mediaName, ' 失败！'));
            set retValue = -3;
            leave label;
        end if;
        insert into SystemLog value('', TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()), '', 0, 'admin', concat('新增任务:任务组 ', parentName,' 视频源 ', mediaName, ' 成功！'));
        insert into TaskBackup(token,streamid,status,timetype,vodtype,startday,starttime,endday,endtime,cyclemark,parent)
            value(varToken,varSrcID,0,varTimeType,varVodTimeType,varVodStartDay,varVodStartTime,varVodEndDay,varVodEndTime,varVodCycleDay,varNodeID);
        set retValue = last_insert_id();
        if varTimeType = 0 then
            insert into OneTimeTask(tasktype,taskid,starttime) value(0,retValue,varStartDay+varStartTime);
        else
            insert into CycleTimeTask(tasktype,taskid,startday,starttime,cyclemark) value(0,retValue,varStartDay,varStartTime,varCycleDay);
        end if;
        set retValue = last_insert_id();
    end;
    select retValue as result;
end$

DROP PROCEDURE IF EXISTS MODIFY_IMPORTTASK$
create procedure MODIFY_IMPORTTASK(
varToken          varchar(256),
varNodeID         int,            #任务节点ID 
varTimeType       int,            #一次性还是周期任务 0=一次性任务，1=周期任务 
varStartDay       int,            #开始日期 
varStartTime      int,            #开始时间 
varCycleDay       int,            #任务周期标示 
varVodTimeType    int,            #一次性还是周期任务 0=一次性任务，1=周期任务 
varVodCycleDay    int,            #任务周期标示 
varVodStartDay    int,            #录像开始日期 
varVodStartTime   int,            #录像开始时间 
varVodEndDay      int,            #录像结束日期 
varVodEndTime     int            #录像结束时间  
)
begin
    declare nCount,oldTimeType, retValue,sourceid int;
    declare parentName,mediaName varchar(256);
    label:begin
        select id,timetype,streamid into retValue,oldTimeType,sourceid from TaskBackup where token = varToken;
        select name into mediaName from MediaStream where id = sourceid;
        select name into parentName from TaskNode where id = varNodeID;
        if retValue is null then
            insert into SystemLog value('', TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()), '', 0, 'admin', concat('修改任务:任务组 ', parentName,' 视频源 ', mediaName, ' 失败！'));
            set retValue = -3;
            leave label;
        end if;
        if oldTimeType = varTimeType then
            #一样,老的就不用删了 
            if varTimeType = 0 then
                update OneTimeTask set starttime = varStartDay+varStartTime where taskid = retValue;
            else
                update CycleTimeTask set startday = varStartDay, starttime=varStartTime,cyclemark=varCycleDay;
            end if;
        else
            #类型不一样,老的要删掉重新加 
            if varTimeType = 0 then
                delete from CycleTimeTask where taskid = retValue;
                insert into OneTimeTask(tasktype,taskid,starttime) value(0,retValue,varStartDay);
            else
                delete from OneTimeTask where taskid = retValue;
                insert into CycleTimeTask(tasktype,taskid,startday,starttime,cyclemark) value(0,retValue,varStartDay,varStartTime,varCycleDay);
            end if;
        end if;
        insert into SystemLog value('', TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()), '', 0, 'admin', concat('修改任务:任务组 ', parentName,' 视频源 ', mediaName, ' 成功！'));
        update TaskBackup set status=0,timetype=varTimeType,vodtype=varVodTimeType,startday=varVodStartDay,starttime=varVodStartTime,endday=varVodEndDay,endtime=varVodEndTime,cyclemark=varVodCycleDay,parent=varNodeID where token = varToken;
    end;
    select retValue as result;
end$


DROP PROCEDURE IF EXISTS DEL_IMPORTTASK$
create procedure DEL_IMPORTTASK(
varToken          varchar(256)
)
begin
    declare nCount, retValue,parentid,sourceid int;
    declare parentName,mediaName varchar(256);
    label:begin
        select id,timetype,streamid,parent into nCount,retValue,sourceid,parentid from TaskBackup where token = varToken;
        select name into mediaName from MediaStream where id = sourceid;
        select name into parentName from TaskNode where id = parentid;
        if nCount is null then
            insert into SystemLog value('', TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()), '', 0, 'admin', concat('删除任务:任务组 ', parentName,' 视频源 ', mediaName, ' 失败！'));
            set retValue = -3;
            leave label;
        end if;
        if retValue = 1 then
            delete from CycleTimeTask where taskid = nCount;
        else
            delete from OneTimeTask where taskid = nCount;
        end if;
        delete from TaskBackup where token = varToken;
        insert into SystemLog value('', TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()), '', 0, 'admin', concat('删除任务:任务组 ', parentName,' 视频源 ', mediaName, ' 成功！'));
        set retValue = 1;
    end;
    select retValue as result;
end$


DROP PROCEDURE IF EXISTS CREATE_USER$
create procedure CREATE_USER(
varType          int         ,
varLevel         int         ,
varPassword      varchar(256),
varPrivilege     varchar(256),
varName          varchar(256)
)
begin
    declare nCount, retValue int;
    label:begin
        select count(*) into nCount from Users;
        #最多2048个用户 
        if nCount > 2047 then
            set retValue = -2;
            leave label;
        end if;
        select count(*) into nCount from Users where name = varName;
        if nCount > 0 then
            set retValue = 0;
            leave label;
        end if;
        insert into Users(name,password,type,level,privilege,lastlogintime) value(varName,varPassword,varType,varLevel,varPrivilege,0);
        set retValue = last_insert_id();
    end;
    select retValue as result;
end$

DROP PROCEDURE IF EXISTS CREATE_PUBLISH$
create procedure CREATE_PUBLISH(
varToken       varchar(256),
varName        varchar(64),
varDescription varchar(2048),
varChannelid   int,
varColumnid    int,
varLevel       int,
varRestype     int,
varBdid        int,
varHdid        int,
varSdid        int,
varLdid        int,
varImgurl      varchar(256),
varTBdid       int,
varTHdid       int,
varTSdid       int,
varTLdid       int
)
begin
    declare nCount, retValue int;
    label:begin
        select count(*) into nCount from MediaPublish where columnid = varColumnid;
        if nCount >= 2048 then
            set retValue = -2;
            leave label;
        end if;
        #发布次数通过触发器去设置,这里就不管了 
        insert into MediaPublish(token,name,description,channelid,columnid,level,restype,bdid,hdid,sdid,ldid,imgurl,transbdid,transhdid,transsdid,transldid,hits,createtime)
            value(varToken,varName,varDescription,varChannelid,varColumnid,varLevel,varRestype,varBdid,varHdid,varSdid,varLdid,varImgurl,varTBdid,varTHdid,varTSdid,varTLdid,0,TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()));
        set retValue = last_insert_id();
    end;
    select retValue as result;
end$

DROP PROCEDURE IF EXISTS MODIFY_PUBLISH$
create procedure MODIFY_PUBLISH(
varToken       varchar(256),
varName        varchar(64),
varDescription varchar(2048),
varChannelid   int,
varColumnid    int,
varLevel       int,
varRestype     int,
varBdid        int,
varHdid        int,
varSdid        int,
varLdid        int,
varTBdid       int,
varTHdid       int,
varTSdid       int,
varTLdid       int
)
begin
    declare nCount, retValue, oldColumnid int;
    label:begin
        select columnid into oldColumnid from MediaPublish where token = varToken;
        if oldColumnid <> varColumnid then
            select count(*) into nCount from MediaPublish where columnid = varColumnid;
            if nCount >= 2048 then
                set retValue = -2;
                leave label;
            end if;
        end if;
        #发布次数由触发器去更改  
        update MediaPublish set name=varName,description=varDescription,channelid=varChannelid,columnid=varColumnid,
            level=varLevel,restype=varRestype,bdid=varBdid,hdid=varHdid,sdid=varSdid,ldid=varLdid,
            transbdid=varTBdid,transhdid=varTHdid,transsdid=varTSdid,transldid=varTLdid where token = varToken;
        set retValue = 1;
    end;
    select retValue as result;
end$

DROP PROCEDURE IF EXISTS DEL_PUBLISH$
create procedure DEL_PUBLISH(
varToken       varchar(256)
)
begin
    declare retValue int;
    label:begin
        #发布次数由触发器进行修改 
        delete from MediaPublish where token = varToken;
        set retValue = 1;
    end;
    select retValue as result;
end$


DROP PROCEDURE IF EXISTS CREATE_CHANNEL$
create procedure CREATE_CHANNEL(
varName        varchar(64),
varDescription varchar(2048)
)
begin
    declare nCount, retValue int;
    label:begin
        select count(*) into nCount from Channels where name = varName;
        if nCount <> 0 then
            set retValue = 0;
            leave label;
        end if;
        select count(*) into nCount from Channels;
        if nCount >= 10 then
            set retValue = -2;
            leave label;
        end if;
        insert into Channels(name,description,createtime) value(varName,varDescription,TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()));
        set retValue = last_insert_id();
    end;
    select retValue as result;
end$

DROP PROCEDURE IF EXISTS MODIFY_CHANNEL$
create procedure MODIFY_CHANNEL(
varId          int,
varName        varchar(64),
varDescription varchar(2048)
)
begin
    declare nCount, retValue int;
    label:begin
        select count(*) into nCount from Channels where id = varId;
        if nCount = 0 then
            set retValue = -3;
            leave label;
        end if;
        select count(*) into nCount from Channels where name = varName and id <> varId;
        if nCount <> 0 then
            set retValue = 0;
            leave label;
        end if;
        update Channels set name = varName, description = varDescription where id = varId;
        set retValue = varId;
    end;
    select retValue as result;
end$


DROP PROCEDURE IF EXISTS MODIFY_COLUMN$
create procedure MODIFY_COLUMN(
varId          int,
varName        varchar(64),
varDescription varchar(2048)
)
begin
    declare nCount, nChannelid, retValue int;
    label:begin
        select channelid into nChannelid from Columns where id = varId;
        if nChannelid is null then
            set retValue = -3;
        end if;
        select count(*) into nCount from Columns where channelid = nChannelid and name = varName and id <> varId;
        if nCount <> 0 then
            set retValue = 0;
            leave label;
        end if;
        update Columns set name = varName, description = varDescription where id = varId;
        set retValue = varId;
    end;
    select retValue as result;
end$


DROP PROCEDURE IF EXISTS CREATE_COLUMN$
create procedure CREATE_COLUMN(
varChannelid   int,
varName        varchar(64),
varDescription varchar(2048)
)
begin
    declare nCount, retValue int;
    label:begin
        select count(*) into nCount from Channels where id = varChannelid;
        if nCount = 0 then
            set retValue = -3;
            leave label;
        end if;
        select count(*) into nCount from Columns where channelid = varChannelid;
        if nCount >= 32 then
            set retValue = -2;
            leave label;
        end if;
        select count(*) into nCount from Columns where channelid = varChannelid and name = varName;
        if nCount <> 0 then
            set retValue = 0;
            leave label;
        end if;
        insert into Columns(channelid,name,description,createtime) value(varChannelid,varName,varDescription,TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()));
        set retValue = last_insert_id();
    end;
    select retValue as result;
end$

DROP PROCEDURE IF EXISTS DESC_VODNODE$
create procedure DESC_VODNODE(
varNodeid      int
)
begin
    declare files, sumsize, nodes int;
    label:begin
        select id into files from MediaFileNode where id = varNodeid;
        if files is null then
            select -3 as result;
            leave label;
        end if;
        select count(*) into nodes from MediaFileNode where parent = varNodeid;
        select count(*) into files from MediaFile where parent = varNodeid;
        if files = 0 then
            set sumsize = 0;
        else
            select sum(filesize) into sumsize from MediaFile where parent = varNodeid;
        end if;
        select parent,name,hierarchy,createtime,description,files,sumsize,nodes,1 as result from MediaFileNode where id = varNodeid;
    end;
end$ 

DROP PROCEDURE IF EXISTS NODEJS_ADD_RECORDTASK$
create procedure NODEJS_ADD_RECORDTASK(
varNodeid      int,
varName        varchar(64),
varToken       varchar(256),
varSrc         varchar(256),
varTemplate    varchar(256)
)
begin
    declare nCount, nSum, retValue int;
    label:begin
        select count(*) into nCount from MediaFileNode where id = varNodeid;
        if nCount = 0 then
            set retValue = -3;
            leave label;
        end if;
        select count(*) into nCount from MediaStream where token = varSrc;
        if nCount = 0 then
            set retValue = -3;
            leave label;
        end if;
        select count(*) into nCount from RecordTemplate where token = varTemplate;
        if nCount = 0 then
            set retValue = -3;
            leave label;
        end if;
        select count(*) into nCount from RecordTask where source_token = varSrc and template_token = varTemplate;
        if nCount <> 0 then
            set retValue = 0;
            leave label;
        end if;
        #录像文件夹与文件总数不能超过10240 
        select count(*) into nSum from MediaFileNode;
        select count(*) into nCount from MediaFile;
        set nSum = nSum + nCount;
        if nSum >= 10240 then
            set retValue = -2;
            leave label;
        end if;
        #这里不用关注diskid和path,smu获得这个任务时会自己添加进去-  
        insert into RecordTask(token,diskid,createtime,filenode_id,path,filename,source_token,template_token) value
            (varToken,0,TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()),varNodeid,'',varName,varSrc,varTemplate);
        set retValue = 1;
    end;
    select retValue as result;
end$ 
 
DROP PROCEDURE IF EXISTS GET_PUBLISH_DETAIL$
create procedure GET_PUBLISH_DETAIL(
vartoken       varchar(256)
)
begin
    declare retValue, vartype int;
    declare bd,hd,sd,ld,bdt,hdt,sdt,ldt int;
    declare bdName,bdToken,hdName,hdToken,sdName,sdToken,ldName,ldToken varchar(256);
    declare bdtName,hdtName,sdtName,ldtName varchar(256);
    set bd = 0, hd = 0, sd = 0, ld = 0, bdt = 0, hdt = 0, sdt = 0, ldt = 0;
    set bdName= "",bdToken="", hdName= "",hdToken="", sdName= "",sdToken="", ldName= "",ldToken="", bdtName= "", hdtName= "", sdtName= "", ldtName= "";
    label:begin
        select if(bdid is null,0,bdid), if(hdid is null,0,hdid), if(sdid is null,0,sdid), if(ldid is null,0,ldid),
            if(transbdid is null,0,transbdid),if(transhdid is null,0,transhdid),if(transsdid is null,0,transsdid),if(transldid is null,0,transldid),
            restype
            into bd,hd,sd,ld,bdt,hdt,sdt,ldt,vartype from MediaPublish where token = vartoken;
        if bd=0 and hd=0 and sd=0 and ld=0 then
            set retValue = -3;
            leave label;
        end if;
        if vartype = 0 then
            #直播,搜索媒体接入表,实时转码模板,获取名称    
            if bd <> 0 then
                select if(name is null,'',name),if(token is null,'',token) into bdName,bdToken from MediaStream where id = bd;
            end if;
            if hd <> 0 then
                select  if(name is null,'',name),if(token is null,'',token) into hdName,hdToken from MediaStream where id = hd;
            end if;
            if sd <> 0 then
                select  if(name is null,'',name),if(token is null,'',token) into sdName,sdToken from MediaStream where id = sd;
            end if;
            if ld <> 0 then
                select  if(name is null,'',name),if(token is null,'',token) into ldName,ldToken from MediaStream where id = ld;
            end if;
            #模板    
            if bdt <> 0 then
                select if(name is null,'',name) into bdtName from StreamTransTemplate where id = bdt;
            end if;
            if hdt <> 0 then
                select if(name is null,'',name) into hdtName from StreamTransTemplate where id = hdt;
            end if;
            if sdt <> 0 then
                select if(name is null,'',name) into sdtName from StreamTransTemplate where id = sdt;
            end if;
            if ldt <> 0 then
                select if(name is null,'',name) into ldtName from StreamTransTemplate where id = ldt;
            end if;
        else
            #点播,搜索录像表,文件转码模板,获取名称     
            if bd <> 0 then
                select if(name is null,'',name),if(token is null,'',token) into bdName,bdToken from MediaFile where id = bd;
            end if;                            
            if hd <> 0 then                    
                select  if(name is null,'',name),if(token is null,'',token) into hdName,hdToken from MediaFile where id = hd;
            end if;                            
            if sd <> 0 then                    
                select  if(name is null,'',name),if(token is null,'',token) into sdName,sdToken from MediaFile where id = sd;
            end if;                            
            if ld <> 0 then                    
                select  if(name is null,'',name),if(token is null,'',token) into ldName,ldToken from MediaFile where id = ld;
            end if;
            #模板   
            if bdt <> 0 then
                select if(name is null,'',name) into bdtName from FileTransTemplate where id = bdt;
            end if;
            if hdt <> 0 then
                select if(name is null,'',name) into hdtName from FileTransTemplate where id = hdt;
            end if;
            if sdt <> 0 then
                select if(name is null,'',name) into sdtName from FileTransTemplate where id = sdt;
            end if;
            if ldt <> 0 then
                select if(name is null,'',name) into ldtName from FileTransTemplate where id = ldt;
            end if;
        end if;
        set retValue = 1;
    end;
    select *,bdName,bdToken,hdName,hdToken,sdName,sdToken,ldName,ldToken,bdtName,hdtName,sdtName,ldtName,retValue as result from MediaPublish where token = vartoken;
end$

DROP PROCEDURE IF EXISTS GET_MEDIAFILE_ID$
create procedure GET_MEDIAFILE_ID(
varbd       varchar(256),
varhd       varchar(256),
varsd       varchar(256),
varld       varchar(256)
)
begin
    declare bdid,hdid,sdid,ldid int;
    declare retValue int;
    set bdid=0,hdid=0,sdid=0,ldid=0, retValue = 1;
    label:begin
        if LENGTH(varbd) > 0 then
            select if(id is null, 0, id) into bdid from MediaFile where token = varbd;
            if bdid = 0 then
                set retValue = -3;
            end if;
        end if;
        if LENGTH(varhd) > 0 then
            select if(id is null, 0, id) into hdid from MediaFile where token = varhd;
            if hdid = 0 then
                set retValue = -3;
            end if;
        end if;
        if LENGTH(varsd) > 0 then
            select if(id is null, 0, id) into sdid from MediaFile where token = varsd;
            if sdid = 0 then
                set retValue = -3;
            end if;
        end if;
        if LENGTH(varld) > 0 then
            select if(id is null, 0, id) into ldid from MediaFile where token = varld;
            if ldid = 0 then
                set retValue = -3;
            end if;
        end if;
    end;
    select bdid,hdid,sdid,ldid,retValue as result;
end$


#只有国标源才有子节点 如果varParent是空那么就是查询rtsp或rtmp的ID 
DROP PROCEDURE IF EXISTS ADD_MEDIASTREAM_CHILD$
create procedure ADD_MEDIASTREAM_CHILD(
#国标源子节点token 
varSourceid    varchar(64) ,
varName        varchar(64) ,
#国标源父节点srcid 
varParent      varchar(256),
varToken       varchar(256)
)
begin
    declare parentid,srcid int;
    declare retValue int;
    label:begin
        if LENGTH(varParent) = 0 and LENGTH(varSourceid) <> 0 then
            select if(id is null,-3,id) into retValue from MediaStream where token = varSourceid;
            leave label;
        end if;
        select id into parentid from MediaStream where sourceid = varParent;
        if parentid is null then
            set retValue = -3;
            leave label;
        end if;
        select id into srcid from MediaStream where parent = parentid and sourceid = varSourceid;
        if srcid is null then
            insert into MediaStream(createtime,parent,protocol,sourceid,name,password,username,url,token)
                value(TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()), parentid, 5, varSourceid, varName,'','','',varToken);
            set retValue = last_insert_id();
        else
            set retValue = srcid;
        end if;
    end;
    select retValue as result;
end$

#创建媒体接入 
DROP PROCEDURE IF EXISTS ADD_MEDIASTREAM$
create procedure ADD_MEDIASTREAM(
varCreatetime  int         ,
varParent      int         ,
varProtocol    int         ,
varSourceid    varchar(64) ,
varMssid       varchar(64) ,
varPassword    varchar(64) ,
varUsername    varchar(64) ,
varToken       varchar(256),
varUrl         varchar(256),
varDescription varchar(2048)
)
begin
    declare nCount, nUpdateID int;
    declare retToken varchar(256);
    declare retValue int;
    set nUpdateID = null;
    label:begin
        select count(*) into nCount from TaskBackup where status = 2;
        if nCount <> 0 then
            set retValue = -6;
            leave label;
        end if;
        delete from MediaStream where parent = 0; 
        update TaskBackup set status = 5 where status in(0,1,2);
        insert into MediaStream(createtime,parent,protocol,sourceid,mssid,password,username,token,url,description) value (varCreatetime,varParent,varProtocol,varSourceid,varMssid,varPassword,varUsername,varToken,varUrl,varDescription);
        set retValue = last_insert_id();
        set retToken = varToken;
    end;
    select retValue as result, retToken as token;
end$

DROP PROCEDURE IF EXISTS UPDATE_MEDIASTREAM$
create procedure UPDATE_MEDIASTREAM(
varParent      int         ,
varProtocol    int         ,
varSourceid    varchar(64) ,
varMssid       varchar(64) ,
varPassword    varchar(64) ,
varUsername    varchar(64) ,
varToken       varchar(256),
varUrl         varchar(256),
varDescription varchar(2048)
)
begin
    declare nCount int;
    declare retValue int;
    label:begin
        select count(*) into nCount from MediaStream where token = varToken;
        if nCount = 0 then
            set retValue = -3;
            leave label;
        end if;
        select count(*) into nCount from MediaStream where token <> varToken and sourceid = varSourceid;
        if nCount <> 0 then
            set retValue = 0;
            leave label;
        end if;
        update MediaStream set parent = varParent,protocol= varProtocol,sourceid = varSourceid,mssid = varMssid,password = varPassword,username = varUsername,url = varUrl,description = varDescription where token = varToken;
        set retValue = 1;
    end;
    select retValue as result;
end$


# 创建媒体仓库目录 
DROP PROCEDURE IF EXISTS ADD_MEDIAFILENODE$
create procedure ADD_MEDIAFILENODE(
varParent      int,
varName        varchar(64),
varDescription varchar(2048)
)
begin
    declare nCount,nSum int;
    declare nHierarchy int;
    declare retValue int;
    set nCount = 0, nSum = 0;
    label:begin
        #非根节点下插入需要先对其查询是否存在  
        if varParent <> 0 then
            select hierarchy into nHierarchy from MediaFileNode where id = varParent;
            if nHierarchy is null then
                #不存在父节点,退出  
                set retValue = -1;
                leave label;
            end if;
            #层级是否大于16 
            set nHierarchy=nHierarchy+1;
            if nHierarchy >= 16 then
                set retValue = -2;
                leave label;
            end if;
        else
            #第一层目录 
            set nHierarchy = 1;
            #查看是否第一层目录已经达到数量限制1024 
            select count(*) into nCount from MediaFileNode where parent = 0;
            if nCount >= 1024 then
                set retValue = -2;
                leave label;
            end if;
        end if;
        #文件&文件夹总数不能超过 10240 
        select count(*) into nCount from MediaFileNode;
        set nSum = nCount;
        select count(*) into nCount from MediaFile;
        set nSum = nSum + nCount;
        if nSum >= 10240 then
            set retValue = -2;
            leave label;
        end if;
        #查询是否有同名 
        select count(*) into nCount from MediaFileNode where parent = varParent and name = varName;
        if nCount = 0 then
            #没有,插入  
            insert into MediaFileNode(parent,hierarchy,createtime,name,description) value (varParent,nHierarchy,TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()),varName,varDescription);
            set retValue = last_insert_id();
            leave label;
        else
            #有,创建失败  
            set retValue = 0;
            leave label;
        end if;
    end;
    select retValue as result;
end$

# 更新媒体仓库目录 
DROP PROCEDURE IF EXISTS UPDATE_MEDIAFILENODE$
create procedure UPDATE_MEDIAFILENODE(
varId          int,
varName        varchar(64),
varDescription varchar(2048)
)
begin
    declare nCount int;
    declare retValue int;
    set nCount = 1;
    label:begin
        #需要先对其查询是否存在  
        select count(*) into nCount from MediaFileNode where id = varId;
        if nCount = 0 then
            #没有
            set retValue = -3;
            leave label;
        else
            #有,看看是否重名 
            select count(*) into nCount from MediaFileNode where id <> varId and name = varName and parent = (select parent from MediaFileNode where id = varId);
            if nCount <> 0 then
                set retValue = 0;
                leave label;
            end if;
            update MediaFileNode set name=varName,description=varDescription,createtime=TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()) where id = varId;
            set retValue = varId;
        end if;
    end;
    select retValue as result;
end$

#查找MediaFileNode和MediaFile中符合条件的结果数量    
DROP PROCEDURE IF EXISTS COUNT_MEDIA$
create procedure COUNT_MEDIA(
varCondition varchar(255),
varParent    int,
varNodeOnly  int
)
label:begin
    declare strSql varchar(500);
    declare intParent,nCount int;
    declare strParentName varchar(255);
    if varNodeOnly = TRUE then
        set strSql = concat('select count(*) into @mediaCount from MediaFileNode where ',varCondition);
        #PREPARE 预编译时必须使用用户变量@  
        set @frist_sql=strSql;
        prepare stmt from @frist_sql;
        execute stmt;
        deallocate prepare stmt;
        set nCount = @mediaCount;
    else
        set strSql = concat('select (select count(*) from MediaFileNode where ', varCondition, ' ) + (select count(*) from MediaFile where ', varCondition, ') into @mediaCount');
        #PREPARE 预编译时必须使用用户变量@  
        set @frist_sql=strSql;
        prepare stmt from @frist_sql;
        execute stmt;
        deallocate prepare stmt;
        set nCount = @mediaCount;
    end if;
    #查询父节点的id和祖父节点的name    
    #这里不能通过一条语句直接出结果,因为如果查询的是第一层目录的父父节点,这时没有结果,就会连mediaCount也不输出出来     
    select parent into intParent from MediaFileNode where id = varParent;
    select name into strParentName from MediaFileNode where id = intParent;
    select intParent as parent, strParentName as name, nCount as result;
end$

DROP PROCEDURE IF EXISTS ADD_STREAM_TRANS_TEMPLATE$
create procedure ADD_STREAM_TRANS_TEMPLATE(
varStretch         int          ,
varFramerate       int          ,
varCreatetime      int          ,
varAudiobitrate    int          ,
varVideobitrate    int          ,
varAudiochannelnum int          ,
varAudiosamplerate int          ,
varName            varchar(64)  ,
varAudiotype       varchar(64)  ,
varVideotype       varchar(64)  ,
varStreamtype      varchar(64)  ,
varVideomode       varchar(64)  ,
varResolution      varchar(64)  ,
varToken           varchar(256) ,
varDescription     varchar(2048)
)
begin
    declare retValue int;
    label:begin
        declare nCount int;
        select count(*) into nCount from StreamTransTemplate;
        if nCount >= 1024 then
            set retValue = -2;
            leave label;
        end if;
        select count(*) into nCount from StreamTransTemplate where name = varName;
        if nCount > 0 then
            set retValue = 0;
            leave label;
        end if;
        insert into StreamTransTemplate(Stretch,Framerate,Createtime,Audiobitrate,Videobitrate,Audiochannelnum,Audiosamplerate,
            Name,Audiotype,Videotype,Videomode,Resolution,Token,Description,streamformat) value(varStretch,varFramerate,varCreatetime,varAudiobitrate,
            varVideobitrate,varAudiochannelnum,varAudiosamplerate,varName,varAudiotype,varVideotype,varVideomode,varResolution,varToken,
            varDescription,varStreamtype);
        set retValue = last_insert_id();
    end;
    select retValue as result;
end$

DROP PROCEDURE IF EXISTS UPDATE_STREAM_TRANS_TEMPLATE$
create procedure UPDATE_STREAM_TRANS_TEMPLATE(
varStretch         int          ,
varFramerate       int          ,
varAudiobitrate    int          ,
varVideobitrate    int          ,
varAudiochannelnum int          ,
varAudiosamplerate int          ,
varName            varchar(64)  ,
varAudiotype       varchar(64)  ,
varVideotype       varchar(64)  ,
varStreamtype      varchar(64)  ,
varVideomode       varchar(64)  ,
varResolution      varchar(64)  ,
varToken           varchar(256) ,
varDescription     varchar(2048)
)
begin
    declare retValue int;
    declare nCount int;
    label:begin
        select count(*) into nCount from StreamTransTemplate where token = varToken;
        if nCount = 0 then
            set retValue = -3;
            leave label;
        end if;
        select count(*) into nCount from StreamTransTemplate where token <> varToken and name = varName;
        if nCount > 0 then
            set retValue = 0;
            leave label;
        end if;
        update StreamTransTemplate set name = varName,videotype = varVideotype,videomode = varVideomode,videobitrate = varVideobitrate,framerate = varFramerate,
            resolution = varResolution,stretch = varStretch,audiotype = varAudiotype,audiosamplerate = varAudiosamplerate,audiochannelnum = varAudiochannelnum,
            audiobitrate = varAudiobitrate,description = varDescription, streamformat = varStreamtype where token = varToken;
        set retValue = 1;
    end;
    select retValue as result;
end$

DROP PROCEDURE IF EXISTS ADD_RECORD_TEMPLATE$
create procedure ADD_RECORD_TEMPLATE(
varDuration    int          ,
varCreatetime  int          ,
varName        varchar(64)  ,
varFormat      varchar(64)  ,
varToken       varchar(256) ,
varDescription varchar(2048)
)
begin
    declare retValue int;
    label:begin
        declare nCount int;
        select count(*) into nCount from RecordTemplate;
        if nCount >= 1024 then
            set retValue = -2;
            leave label;
        end if;
        select count(*) into nCount from RecordTemplate where name = varName;
        if nCount > 0 then
            set retValue = 0;
            leave label;
        end if;
        insert into RecordTemplate(duration,createtime,name,format,token,description) value(
            varDuration,varCreatetime,varName,varFormat,varToken,varDescription);
        set retValue = last_insert_id();
    end;
    select retValue as result;
end$

DROP PROCEDURE IF EXISTS UPDATE_RECORD_TEMPLATE$
create procedure UPDATE_RECORD_TEMPLATE(
varDuration    int          ,
varName        varchar(64)  ,
varFormat      varchar(64)  ,
varToken       varchar(256) ,
varDescription varchar(2048)
)
begin
    declare retValue int;
    label:begin
        declare nCount int;
        select count(*) into nCount from RecordTemplate where token = varToken;
        if nCount = 0 then
            set retValue = -3;
            leave label;
        end if;
        select count(*) into nCount from RecordTemplate where token <> varToken and name = varName;
        if nCount > 0 then
            set retValue = 0;
            leave label;
        end if;
        update RecordTemplate set duration=varDuration, name=varName,format=varFormat,description=varDescription where token = varToken;
        set retValue = 1;
    end;
    select retValue as result;
end$

DROP PROCEDURE IF EXISTS ADD_FILE_TRANS_TEMPLATE$
create procedure ADD_FILE_TRANS_TEMPLATE(
varStretch         int          ,
varFramerate       int          ,
varCreatetime      int          ,
varAudiobitrate    int          ,
varVideobitrate    int          ,
varAudiochannelnum int          ,
varAudiosamplerate int          ,
varName            varchar(64)  ,
varAudiotype       varchar(64)  ,
varVideotype       varchar(64)  ,
varFiletype        varchar(64)  ,
varVideomode       varchar(64)  ,
varResolution      varchar(64)  ,
varToken           varchar(256) ,
varDescription     varchar(2048)
)
begin
    declare retValue int;
    label:begin
        declare nCount int;
        select count(*) into nCount from FileTransTemplate;
        if nCount >= 1024 then
            set retValue = -2;
            leave label;
        end if;
        select count(*) into nCount from FileTransTemplate where name = varName;
        if nCount > 0 then
            set retValue = 0;
            leave label;
        end if;
        insert into FileTransTemplate(Stretch,Framerate,Createtime,Audiobitrate,Videobitrate,Audiochannelnum,Audiosamplerate,
            Name,Audiotype,Videotype,Videomode,Resolution,Token,Description,filetype) value(varStretch,varFramerate,varCreatetime,varAudiobitrate,
            varVideobitrate,varAudiochannelnum,varAudiosamplerate,varName,varAudiotype,varVideotype,varVideomode,varResolution,varToken,
            varDescription,varFiletype);
        set retValue = last_insert_id();
    end;
    select retValue as result;
end$

DROP PROCEDURE IF EXISTS UPDATE_FILE_TRANS_TEMPLATE$
create procedure UPDATE_FILE_TRANS_TEMPLATE(
varStretch         int          ,
varFramerate       int          ,
varAudiobitrate    int          ,
varVideobitrate    int          ,
varAudiochannelnum int          ,
varAudiosamplerate int          ,
varName            varchar(64)  ,
varAudiotype       varchar(64)  ,
varVideotype       varchar(64)  ,
varFiletype        varchar(64)  ,
varVideomode       varchar(64)  ,
varResolution      varchar(64)  ,
varToken           varchar(256) ,
varDescription     varchar(2048)
)
begin
    declare retValue int;
    declare nCount int;
    label:begin
        select count(*) into nCount from FileTransTemplate where token = varToken;
        if nCount = 0 then
            set retValue = -3;
            leave label;
        end if;
        select count(*) into nCount from FileTransTemplate where token <> varToken and name = varName;
        if nCount > 0 then
            set retValue = 0;
            leave label;
        end if;
        update FileTransTemplate set name = varName,videotype = varVideotype,videomode = varVideomode,videobitrate = varVideobitrate,framerate = varFramerate,
            resolution = varResolution,stretch = varStretch,audiotype = varAudiotype,audiosamplerate = varAudiosamplerate,audiochannelnum = varAudiochannelnum,
            audiobitrate = varAudiobitrate,description = varDescription, filetype = varFiletype where token = varToken;
        set retValue = 1;
    end;
    select retValue as result;
end$

DROP PROCEDURE IF EXISTS UPLOAD_FINISH$
create procedure UPLOAD_FINISH(
varToken      varchar(256)
)
begin
    declare retValue int;
    declare nCount int;
    label:begin
        select count(*) into nCount from UploadTask where token = varToken;
        if nCount = 0 then
            set retValue = -3;
            leave label;
        end if;
        insert into MediaFile(token,parent,name,path,type,streamid,starttime,endtime,description,user,filesize,duration,createtime) 
            select token,parent,name,path,1 as type, 0 as streamid, 0 as starttime, 0 as endtime, '' as description, user, filesize, 0 as duration, 
                TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()) as createtime from UploadTask where token = varToken;
        set retValue = last_insert_id();
    end;
    select retValue as result;
end$

#创建合并录像任务 idlist以逗号分隔 
DROP PROCEDURE IF EXISTS ADD_FILE_MERGE_TASK$
create procedure ADD_FILE_MERGE_TASK(
varDelSrc        int,
varIdList        varchar(256)
)
begin
    declare retValue int;
    declare nCount int;
    declare nIdNum int;
    label:begin
        if LENGTH(varIdList) = 0 then
            set retValue = -3;
            leave label;
        end if;
        set nIdNum = 1 + LENGTH(varIdList) - LENGTH(REPLACE(varIdList, ',', ''));
        set @frist_sql = concat('select count(*) into @vodCount from MediaStream where id in (',varIdList,')');
        prepare stmt from @frist_sql;
        execute stmt;
        deallocate prepare stmt;
        if @vodCount <> nIdNum then
            set retValue = -3;
            leave label;
        end if;
        insert into FileMergeTask(diskid,isdelsrc,status,createtime,dstfilepath,dstfilename,vodidlist) value(0,varDelSrc,0,TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()),'','',varIdList);
        set retValue = last_insert_id();
    end;
    select retValue as result;
end$

#删除录制模板 
DROP PROCEDURE IF EXISTS DEL_RECORD_TMPL$
create procedure DEL_RECORD_TMPL(
varToken      varchar(256)
)
begin
    declare retValue int;
    declare tmplId int;
    declare nCount int;
    set retValue = 1;
    label:begin
        select count(*) into nCount from RecordTask where template_token = varToken;
        if nCount > 0 then
            set retValue = -6;
            leave label;
        end if;
        delete from RecordTemplate where token = varToken;
    end;
    select retValue as result;
end$

#删除直播源 
DROP PROCEDURE IF EXISTS DEL_LIVE_SOURCE$
create procedure DEL_LIVE_SOURCE(
varToken      varchar(256)
)
begin
    declare retValue int;
    declare sourceId int;
    declare nCount int;
    set retValue = 1;
    label:begin
        select id into sourceId from MediaStream where token = varToken;
        if sourceId is null then
            leave label;
        end if;
        # 查看是否有录像任务 
        select count(*) into nCount from RecordTask rt join MediaStream ms on rt.source_token = ms.token where ms.parent = sourceId or 1=1;
        if nCount > 0 then
            set retValue = -6;
            leave label;
        end if;
        delete from MediaPublish where bdid = sourceId or bdid in (select id from MediaStream where parent = sourceId);
        delete from MediaPublish where hdid = sourceId or hdid in (select id from MediaStream where parent = sourceId); 
        delete from MediaPublish where sdid = sourceId or sdid in (select id from MediaStream where parent = sourceId); 
        delete from MediaPublish where ldid = sourceId or ldid in (select id from MediaStream where parent = sourceId); 
        select count(*) into nCount from MediaStream ms join MediaFile mf on ms.id = mf.streamid where (mf.type = 2 or mf.type = 4) and ms.parent = sourceId;
        if nCount > 0 then
            update MediaStream set visible = false where id = sourceId;
        else
            delete from MediaStream where parent = sourceId;
            delete from MediaStream where id = sourceId;
        end if;
    end;
    select retValue as result;
end$

#用户登录验证 
DROP PROCEDURE IF EXISTS USER_LOGIN$
create procedure USER_LOGIN(
varName varchar(255),
varPWD varchar(256)
)
label:begin
    declare strPrv varchar(256);
    declare pwd varchar(256);
    declare nCount int;
    set strPrv = "";
    set pwd = "";
    set nCount = 0;
    select count(*),privilege,password into nCount,strPrv,pwd from Users where name = varName;
    if nCount = 0 then
        select -4 as result;
    elseif pwd = varPWD then
        update Users set lastlogintime = TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()) where name = varName;
        select 1 as result, strPrv as privilege;
    else
        select -5 as result;
    end if;
end$

DROP PROCEDURE IF EXISTS SOAP_DEPUBLISH$
create procedure SOAP_DEPUBLISH(
varResId       varchar(64),
varDomainId    varchar(64)
)
begin
    declare retValue int;
    declare nCount int;
    declare mediaId int;
    label:begin
        select id into mediaId from MediaStream where sourceid = varResId and parent in (select id from MediaStream where sourceid = varDomainId);
        if mediaId is null then
            set retValue = -3;
            leave label;
        end if;
        select count(*) into nCount from MediaPublish where bdid = mediaId;
        if nCount = 0 then
            set retValue = -3;
            leave label;
        end if;
        delete from MediaPublish where bdid = mediaId;
        set retValue = 1;
    end;
    select retValue as result;
end$

DROP PROCEDURE IF EXISTS SOAP_GET_VODRES_NUM$
create procedure SOAP_GET_VODRES_NUM(
varStatus       int,          # -1：所有，0：发布，1：待发布，#后面这两个先不管 2：下载中，3，转码中 
varStart        int,
varEnd          int,
varResId        varchar(64),
varDomainId     varchar(64)
)
begin
    declare strCondition varchar(512);
    set strCondition = 'select count(*) into @vodCount from MediaFile where 1=1';
    case varStatus
        when 0 then set strCondition = concat(strCondition, ' and id in (select bdid from MediaPublish where bdid <> 0)');
        when 1 then set strCondition = concat(strCondition, ' and id not in (select bdid from MediaPublish where bdid <> 0)');
        else begin end;
    end case;

    #暂时不考虑只有开始或结束时间的搜索
    if varStart <> 0 and varEnd <> 0 then
        set strCondition = concat(strCondition, ' and (',varStart,' > starttime and ',varStart,' < endtime) or (',varEnd,' > starttime and ',varEnd,' < endtime) or (',varStart,' < starttime and ',varEnd,' > endtime)');
    end if;
    
    #如果resid是空的,那么就不做MediaStream的搜索,暂时不考虑Domainid 
    if LENGTH(varResId) <> 0 then
        set strCondition = concat(strCondition, ' and streamid in (select id from MediaStream where protocol=5 and sourceid = "', varResId, '")');
    end if;
    set @frist_sql = strCondition;
    prepare stmt from @frist_sql;
    execute stmt;
    deallocate prepare stmt;
    select @vodCount as result;
end$

DROP PROCEDURE IF EXISTS SOAP_GET_VODRES_LIST$
create procedure SOAP_GET_VODRES_LIST(
varStatus       int,          # -1：所有，0：发布，1：待发布，#后面这两个先不管 2：下载中，3，转码中 
varStart        int,
varEnd          int,
varStartIndex    int,
varRange        int,
varResId        varchar(64),
varDomainId     varchar(64)
)
begin
    declare strCondition varchar(512);
    set strCondition = 'select mf.*, ms.sourceid, ms.name as srcname, mp.token as mptoken from MediaFile mf join MediaStream ms on mf.streamid = ms.id left join MediaPublish mp on mf.id = mp.bdid and restype = 2 where 1=1';
    case varStatus
        when 0 then set strCondition = concat(strCondition, ' and mp.id is not null');
        when 1 then set strCondition = concat(strCondition, ' and mp.id is null');
        else begin end;
    end case;
    
    #暂时不考虑只有开始或结束时间的搜索
    if varStart <> 0 and varEnd <> 0 then
        set strCondition = concat(strCondition, ' and (',varStart,' > mf.starttime and ',varStart,' < mf.endtime) or (',varEnd,' > mf.starttime and ',varEnd,' < mf.endtime) or (',varStart,' < mf.starttime and ',varEnd,' > mf.endtime)');
    end if;
    
    #如果resid是空的,那么就不做MediaStream的搜索,暂时不考虑Domainid 
    if LENGTH(varResId) <> 0 then
        set strCondition = concat(strCondition, ' and ms.protocol = 5 and ms.sourceid = "', varResId, '"');
    end if;
    
    set strCondition = concat(strCondition, ' limit ', varStartIndex, ',', varRange);
    
    #执行搜索
    set @frist_sql = strCondition;
    prepare stmt from @frist_sql;
    execute stmt;
    deallocate prepare stmt;
end$

#删除直播源 
DROP PROCEDURE IF EXISTS SOAP_DEL_LIVE_SOURCE$
create procedure SOAP_DEL_LIVE_SOURCE(
varUrl      varchar(256)
)
begin
    declare sourceId int;
    label:begin
        select id into sourceId from MediaStream where url = varUrl;
        if id is null then
            leave label;
        end if;
        delete from MediaPublish where bdid = sourceId or hdid = sourceId or sdid = sourceId or ldid = sourceId;
        delete from MediaStream where id = sourceId;
    end;
end$

#发布第三方直播源(PublishThirdResource) 
DROP PROCEDURE IF EXISTS SOAP_PUBLISH_LIVE_SOURCE$
create procedure SOAP_PUBLISH_LIVE_SOURCE(
varId    int,
varName  varchar(64),
varToken varchar(256),
varDesc  varchar(256)
)
begin
    declare retValue int;
    declare nCount int;
    label:begin
        select count(*) into nCount from MediaStream where id = varId;
        if nCount = 0 then
            set retValue = -3;
            leave label;
        end if;
        #所有的soap发布的内容都当做高清源发布 发布到默认频道 
        insert into MediaPublish(token, bdid, level, restype, columnid, channelid, createtime, name, description)
            value(varToken, varId, 1, 1, 1, 1,TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()), varName, varDesc);
        set retValue = 1;
    end;
    select retValue as result;
end$

#添加录像文件,按照老版本SMU逻辑,缺什么东西添什么东西 
DROP PROCEDURE IF EXISTS SOAP_ADD_VODRES$
create procedure SOAP_ADD_VODRES(
varStartTime     int,
varEndTime       int,
varDuration      int,
varFileSize      int,
varResId         varchar(64),
varResName       varchar(64),
varDomainId      varchar(64),
varDomainName    varchar(64),
varName          varchar(256),
varPath          varchar(256),
varUUID          varchar(256)
)
begin
    declare nCount int;
    declare dmID int;
    declare resID int;
    declare diskID int;
    declare varToken varchar(256);
    set varToken = MD5(concat(varStartTime,varEndTime,TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW())));
    select id into dmID from MediaStream where sourceid = varDomainId and protocol = 5;
    if dmID is null then
        insert into MediaStream(createtime,protocol,sourceid,name,token,url)
            value(TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()), 5, varDomainId, varDomainName, MD5(varDomainId), '');
        set dmID = last_insert_id();
    end if;
    select id into resID from MediaStream where parent = dmID and sourceid = varResId and protocol = 5;
    if resID is null then
        insert into MediaStream(createtime,parent,protocol,sourceid,name,token,url)
            value(TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()), dmID, 5, varResId, varResName, MD5(varResId), '');
        set resID = last_insert_id();
    end if;
    select id into diskID from DiskInfo where uuid = varUUID;
    if diskID is null then
        insert into DiskInfo(lasttime,uuid,path)
            value(0, varUUID, '');
        set diskID = last_insert_id();
    end if;
    #已有这个录像时的处理如何进行? 这里先直接插入一条 
    #默认存放文件夹(parent)是否需要默认? 这里先存根目录 
    insert into MediaFile(type,diskid,parent,duration,filesize,streamid,starttime,endtime,createtime,name,path,token)
        value(4,diskID,0,varDuration,varFileSize,resID,varStartTime,varEndTime,TIMESTAMPDIFF(SECOND, '1970-1-1 8:0:0', NOW()),varName,varPath,varToken);
    select last_insert_id() as result;
end$

DROP PROCEDURE IF EXISTS INSERT_LOG$
create procedure INSERT_LOG(
id             int,
createtime     int,
devname        varchar(64),
type           varchar(64),
name           varchar(64),
description    varchar(2048)
)
begin
    declare nCount int;
    select count(*) into nCount from SystemLog;
    if nCount >= 10000 then
        delete from SystemLog order by createtime asc limit 1000;
    end if;
    insert into SystemLog value(0, createtime, devname, type, name, description);
end$
#--------------------------------------------------------------------------------------------#
#触发器  

#添加后更新发布状态  
DROP TRIGGER IF EXISTS AFTIN_PUBLISH$
create trigger AFTIN_PUBLISH 
after insert on MediaPublish for each row
begin
    label:begin
        #点播 
        if NEW.restype = 1 then
            if NEW.bdid <> 0 then
                update MediaFile set publish = publish+1 where id = NEW.bdid;
            end if;
            if NEW.hdid <> 0 then
                update MediaFile set publish = publish+1 where id = NEW.hdid;
            end if;
            if NEW.sdid <> 0 then
                update MediaFile set publish = publish+1 where id = NEW.sdid;
            end if;
            if NEW.ldid <> 0 then
                update MediaFile set publish = publish+1 where id = NEW.ldid;
            end if;
        else
            if NEW.bdid <> 0 then
                update MediaStream set publish = publish+1 where id = NEW.bdid;
            end if;
            if NEW.hdid <> 0 then
                update MediaStream set publish = publish+1 where id = NEW.hdid;
            end if;
            if NEW.sdid <> 0 then
                update MediaStream set publish = publish+1 where id = NEW.sdid;
            end if;
            if NEW.ldid <> 0 then
                update MediaStream set publish = publish+1 where id = NEW.ldid;
            end if;
        end if;
    end;
end$

#修改后更新发布状态  
DROP TRIGGER IF EXISTS AFTUP_PUBLISH$
create trigger AFTUP_PUBLISH 
after update on MediaPublish for each row
begin
    label:begin
        #点播  
        if NEW.restype = 1 then
            if OLD.bdid <> NEW.bdid then
                if OLD.bdid <> 0 then
                    update MediaFile set publish = publish-1 where id = OLD.bdid;
                end if;
                if NEW.bdid <> 0 then
                    update MediaFile set publish = publish+1 where id = NEW.bdid;
                end if;
            end if;
            if OLD.hdid <> NEW.hdid then
                if OLD.hdid <> 0 then
                    update MediaFile set publish = publish-1 where id = OLD.hdid;
                end if;
                if NEW.hdid <> 0 then
                    update MediaFile set publish = publish+1 where id = NEW.hdid;
                end if;
            end if;
            if OLD.sdid <> NEW.sdid then
                if OLD.sdid <> 0 then
                    update MediaFile set publish = publish-1 where id = OLD.sdid;
                end if;
                if NEW.sdid <> 0 then
                    update MediaFile set publish = publish+1 where id = NEW.sdid;
                end if;
            end if;
            if OLD.ldid <> NEW.ldid then
                if OLD.ldid <> 0 then
                    update MediaFile set publish = publish-1 where id = OLD.ldid;
                end if;
                if NEW.ldid <> 0 then
                    update MediaFile set publish = publish+1 where id = NEW.ldid;
                end if;
            end if;
        else
            if OLD.bdid <> NEW.bdid then
                if OLD.bdid <> 0 then
                    update MediaStream set publish = publish-1 where id = OLD.bdid;
                end if;
                if NEW.bdid <> 0 then
                    update MediaStream set publish = publish+1 where id = NEW.bdid;
                end if;
            end if;
            if OLD.hdid <> NEW.hdid then
                if OLD.hdid <> 0 then
                    update MediaStream set publish = publish-1 where id = OLD.hdid;
                end if;
                if NEW.hdid <> 0 then
                    update MediaStream set publish = publish+1 where id = NEW.hdid;
                end if;
            end if;
            if OLD.sdid <> NEW.sdid then
                if OLD.sdid <> 0 then
                    update MediaStream set publish = publish-1 where id = OLD.sdid;
                end if;
                if NEW.sdid <> 0 then
                    update MediaStream set publish = publish+1 where id = NEW.sdid;
                end if;
            end if;
            if OLD.ldid <> NEW.ldid then
                if OLD.ldid <> 0 then
                    update MediaStream set publish = publish-1 where id = OLD.ldid;
                end if;
                if NEW.ldid <> 0 then
                    update MediaStream set publish = publish+1 where id = NEW.ldid;
                end if;
            end if;
        end if;
    end;
end$

#删除后更新发布状态  
DROP TRIGGER IF EXISTS AFTDE_PUBLISH$
create trigger AFTDE_PUBLISH 
after delete on MediaPublish for each row
begin
    label:begin
        #点播  
        if OLD.restype = 1 then
            if OLD.bdid <> 0 then
                update MediaFile set publish = publish+1 where id = OLD.bdid;
            end if;
            if OLD.hdid <> 0 then
                update MediaFile set publish = publish+1 where id = OLD.hdid;
            end if;
            if OLD.sdid <> 0 then
                update MediaFile set publish = publish+1 where id = OLD.sdid;
            end if;
            if OLD.ldid <> 0 then
                update MediaFile set publish = publish+1 where id = OLD.ldid;
            end if;
        else
            if OLD.bdid <> 0 then
                update MediaStream set publish = publish+1 where id = OLD.bdid;
            end if;
            if OLD.hdid <> 0 then
                update MediaStream set publish = publish+1 where id = OLD.hdid;
            end if;
            if OLD.sdid <> 0 then
                update MediaStream set publish = publish+1 where id = OLD.sdid;
            end if;
            if OLD.ldid <> 0 then
                update MediaStream set publish = publish+1 where id = OLD.ldid;
            end if;
        end if;
    end;
end$

DROP TRIGGER IF EXISTS AFTIN_RECORDTASK$
create trigger AFTIN_RECORDTASK 
after insert on RecordTask for each row
begin
    label:begin
        update MediaStream set record=record+1 where token = NEW.source_token;
    end;
end$

DROP TRIGGER IF EXISTS AFTUP_RECORDTASK$
create trigger AFTUP_RECORDTASK 
after update on RecordTask for each row
begin
    label:begin
        if NEW.status = 2 and OLD.status <> 2 then
            update MediaStream set record=record-1 where token = NEW.source_token;
        end if;
        if NEW.status <> 2 and OLD.status = 2 then
            update MediaStream set record=record+1 where token = NEW.source_token;
        end if;
    end;
end$

DROP TRIGGER IF EXISTS AFTDE_RECORDTASK$
create trigger AFTDE_RECORDTASK 
after delete on RecordTask for each row
begin
    label:begin
        update MediaStream set record=record-1 where token = OLD.source_token;
    end;
end$

DELIMITER ;
