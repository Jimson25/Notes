# 数据淘汰策略

- noeviction：不进行内存数据淘汰，如果运行内存超过设置的最大内存，则在写入时报错。
- volatile-random：随机淘汰设置了1过期时间的键值对。
- volatile-ttl：优先淘汰更早过期的键值对。
- volatile-lru：淘汰所有设置了过期时间的键值对中最久未使用的键值对。
- volatile-lfu：淘汰所有设置了过期时间的键值对中最少使用的键值对。
- allkeys-random：随机淘汰任意数据
- allkeys-lru：淘汰所有数据中最久未使用的键值对。
- allkeys-lfu：淘汰所有数据中使用最少的键值对。