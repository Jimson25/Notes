# 数据结构

**这部分代码由ai生成，没有经过测试**

## string

字符串类型，可以存储一个字符串、整数或浮点数，主要用于存储简单的键值对。

- jedis操作代码

```java
import redis.clients.jedis.Jedis;

public class JedisStringExample {
    public static void main(String[] args) {
        Jedis jedis = new Jedis("localhost", 6379);
        jedis.set("key", "value");
        String value = jedis.get("key");
        System.out.println("Value: " + value);
        jedis.close();
    }
}

```

- springboot redistemplate操作代码

```java
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;

public class RedisTemplateStringExample {
    public static void main(String[] args) {
        ApplicationContext ctx = new AnnotationConfigApplicationContext(RedisConfig.class);
        StringRedisTemplate redisTemplate = ctx.getBean(StringRedisTemplate.class);
        redisTemplate.opsForValue().set("key", "value");
        String value = redisTemplate.opsForValue().get("key");
        System.out.println("Value: " + value);
    }
}

```

## list

列表是简单的字符串列表，按照插入顺序排序。它允许从列表的头部或尾部添加或删除元素。list类型适合存储具有时序性的数据，可以用于实现一个简单的任务队列或者消息队列。

- jedis实现

```java
import redis.clients.jedis.Jedis;

public class JedisListExample {
    public static void main(String[] args) {
        Jedis jedis = new Jedis("localhost", 6379);
        jedis.lpush("list", "value1");
        jedis.lpush("list", "value2");
        String value = jedis.rpop("list");
        System.out.println("Value: " + value);
        jedis.close();
    }
}

```

- springboot redistemplate操作实现

```java
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.data.redis.core.ListOperations;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;

public class RedisTemplateListExample {
    public static void main(String[] args) {
        ApplicationContext ctx = new AnnotationConfigApplicationContext(RedisConfig.class);
        RedisTemplate<String, String> redisTemplate = ctx.getBean(RedisTemplate.class);
        ListOperations<String, String> listOps = redisTemplate.opsForList();
        listOps.leftPush("list", "value1");
        listOps.leftPush("list", "value2");
        String value = listOps.rightPop("list");
        System.out.println("Value: " + value);
    }
}

```

## set

无序集合，采用哈希表实现，元素具有唯一性。可以用于存储需要去重的元素。

- 使用jedis实现操作

```java
import redis.clients.jedis.Jedis;

public class JedisSetExample {
    public static void main(String[] args) {
        Jedis jedis = new Jedis("localhost", 6379);
        jedis.sadd("set", "value1");
        jedis.sadd("set", "value2");
        Boolean isMember = jedis.sismember("set", "value1");
        System.out.println("Is member: " + isMember);
        jedis.close();
    }
}

```

- 使用springboot redistemplate实现操作

```java
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.SetOperations;

public class RedisTemplateSetExample {
    public static void main(String[] args) {
        ApplicationContext ctx = new AnnotationConfigApplicationContext(RedisConfig.class);
        RedisTemplate<String, String> redisTemplate = ctx.getBean(RedisTemplate.class);
        SetOperations<String, String> setOps = redisTemplate.opsForSet();
        setOps.add("set", "value1");
        setOps.add("set", "value2");
        Boolean isMember = setOps.isMember("set", "value1");
        System.out.println("Is member: " + isMember);
    }
}

```

## hash

哈希是键值对结构的集合。适合存储对象，可以很方便的获取对象的信息。

- 使用jedis实现操作

```java
import redis.clients.jedis.Jedis;

public class JedisHashExample {
    public static void main(String[] args) {
        Jedis jedis = new Jedis("localhost", 6379);
        jedis.hset("hash", "field1", "value1");
        String value = jedis.hget("hash", "field1");
        System.out.println("Value: " + value);
        jedis.close();
    }
}

```

- 使用springboot redistemplate实现操作

```java
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.data.redis.core.HashOperations;
import org.springframework.data.redis.core.RedisTemplate;

public class RedisTemplateHashExample {
    public static void main(String[] args) {
        ApplicationContext ctx = new AnnotationConfigApplicationContext(RedisConfig.class);
        RedisTemplate<String, Object> redisTemplate = ctx.getBean(RedisTemplate.class);
  
        // 写入哈希表
        HashOperations<String, String, Object> hashOps = redisTemplate.opsForHash();
        hashOps.put("user:1", "name", "John Doe");
        hashOps.put("user:1", "age", 30);
  
        // 读取哈希表
        String name = (String) hashOps.get("user:1", "name");
        Integer age = (Integer) hashOps.get("user:1", "age");
  
        System.out.println("Name: " + name);
        System.out.println("Age: " + age);
  
        // 获取整个哈希表
        Map<String, Object> userMap = hashOps.entries("user:1");
        System.out.println(userMap);
    }
}

```

## Zset

有序集合

- 使用jedis实现操作

```java
import redis.clients.jedis.Jedis;

public class JedisZSetExample {
    public static void main(String[] args) {
        Jedis jedis = new Jedis("localhost", 6379);
  
        // 写入有序集合
        jedis.zadd("leaderboard", 100, "Alice");
        jedis.zadd("leaderboard", 200, "Bob");
        jedis.zadd("leaderboard", 300, "Charlie");
  
        // 读取有序集合
        Set<String> members = jedis.zrange("leaderboard", 0, -1);
        System.out.println("Members: " + members);
  
        // 获取分数
        Double score = jedis.zscore("leaderboard", "Alice");
        System.out.println("Alice's score: " + score);
  
        jedis.close();
    }
}

```

- 使用springboot redistemplate实现操作

```java
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ZSetOperations;

public class RedisTemplateZSetExample {
    public static void main(String[] args) {
        ApplicationContext ctx = new AnnotationConfigApplicationContext(RedisConfig.class);
        RedisTemplate<String, Object> redisTemplate = ctx.getBean(RedisTemplate.class);
  
        // 写入有序集合
        ZSetOperations<String, Object> zSetOps = redisTemplate.opsForZSet();
        zSetOps.add("leaderboard", "Alice", 100);
        zSetOps.add("leaderboard", "Bob", 200);
        zSetOps.add("leaderboard", "Charlie", 300);
  
        // 读取有序集合
        Set<Object> members = zSetOps.range("leaderboard", 0, -1);
        System.out.println("Members: " + members);
  
        // 获取分数
        Double score = zSetOps.score("leaderboard", "Alice");
        System.out.println("Alice's score: " + score);
    }
}

```