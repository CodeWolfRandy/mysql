## Redis知识点
- Redis支持哪几种数据类型
    - String、List、Sorted Set、Hashes

    - 速度快，因为数据存在内存中，类似于HashMap，HashMap的优势就是查找和操作的时间复杂度都是O(1) 

    - 支持丰富数据类型，支持string，list，set，sorted set，hash 

    - 支持事务，操作都是原子性，所谓的原子性就是对数据的更改要么全部执行，要么全部不执行 

    - 丰富的特性：可用于缓存，消息，按key设置过期时间，过期后将会自动删除
    
- Redis与memcached对比优势
    - memcached所有值均是字符串。redis支持更丰富类型。
    - redis速度快很多
    - redis可以持久化数据    
- Redis数据淘汰策略
    - allkeys-lru:尝试回收最少使用的键
    - volatile-lru:尝试回收最少使用的键。但仅限于过期集合的键
    - allkeys-random:回收随机的键。
    - volatile-random:回收随机的键。但仅限于过期集合的键
    - volatile-ttl:回收过期集合的键。优先回收存活时间ttl较短的键
- Redis事物相关命令
    - multi(标记一个事物块的开始),exec（执行事物块命令）,discard（取消事物）,watch（监视）
- Redis做大批量数据插入
    - pipe mode 模式
- Redis回收进程如何工作
    - 一个客户端运行了新的命令，添加了新的数据
    - Redis检查内存使用情况，如果大于maxmemory的限制, 则根据设定好的策略进行回收
    - 新的命令执行
    - 不断穿越内存限制的边界.通过不断达到内存限制的边界然后不断回收到边界以下。
- 为什么使用Redis分区
    - 分区可以管理更大的内存。redis可以使用所有机器的内存。
- WATCH命令和基于CAS的乐观锁

    - redis事物中watch命令提供CAS（check and set）功能。假设通过watch命令在事物执行之前监控了多个keys，如果在watch之后有任何key值发生了变化，exec命令执行的事物都将被放弃。同时返回null mutil-bulk应答以通知调用者事物执行失败。
    <p>  

        WATHC mykey  
        val = GET mykey
        val = val +1
        MULTI
        SET mykey $val
        EXEC
    </p>
- redis持久化策略
    - 快照
    - AOF(append only file)
    - 虚拟内存
- redis并发竞争问题解决
    - redis单进程单线程模式，采用队列模式将并发访问变为串行访问。本身没有锁的概念。
    解决方案：
    1.客户端角度，对连接池化。同时对客户端读写redis操作采用内部锁synchronized.
    2.服务器角度，利用setnx（set if not exists）命令。