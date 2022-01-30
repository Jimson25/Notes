# Spring5学习笔记

## 一、Spring IOC

### 一）使用xml配置spring

#### 1. 创建初始项目

##### 1. 创建项目

> 创建maven项目并添加依赖，pom文件添加如下依赖	

```xml
<dependencies>
    <!-- https://mvnrepository.com/artifact/org.springframework/spring-core -->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-core</artifactId>
        <version>5.2.6.RELEASE</version>
    </dependency>
    <!-- https://mvnrepository.com/artifact/org.springframework/spring-beans -->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-beans</artifactId>
        <version>5.2.6.RELEASE</version>
    </dependency>
    <!-- https://mvnrepository.com/artifact/org.springframework/spring-beans -->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-context</artifactId>
        <version>5.2.6.RELEASE</version>
    </dependency>
    <!-- https://mvnrepository.com/artifact/org.springframework/spring-beans -->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-expression</artifactId>
        <version>5.2.6.RELEASE</version>
    </dependency>
    <dependency>
        <groupId>junit</groupId>
        <artifactId>junit</artifactId>
        <version>RELEASE</version>
        <scope>test</scope>
    </dependency>

</dependencies>
```

##### 2. 新建spring配置xml

> 在resource目录下新建spring-config.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans.xsd">

</beans>
```

#### 2. 获取bean实例

>  新建User类

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    private String id;
    private String name;
    private int age;

    public void printf() {
        System.out.println("User.printf");
    }
}
```

> 在配置xml的beans标签下添加bean标签

```xml
<bean class="com.cs.spring.entity.User" id="user"/>
```

> 在测试路径新建测试类

```java
public class UserTest {

    /*
    User.printf
    */
    @Test
    public void printf() {
        ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("bean.xml");
        User user = context.getBean("user", User.class);
        user.printf();
    }
}
```

#### 3. 属性注入

> 以前面User实体类为例

> 测试代码

```java
@Test
public void test() {
    ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("bean.xml");
    User user = context.getBean("user", User.class);
    System.out.println(user.toString());
}
```



##### 1. set方法注入

> xml配置

```xml
<bean class="com.cs.spring.entity.User" id="user">
    <property name="id" value="100000"/>
    <property name="name" value="zhangsan"/>
    <property name="age" value="18"/>
</bean>
```

##### 2. 构造方法注入

> xml配置

```xml
<bean id="user" class="com.cs.spring.entity.User">
    <constructor-arg name="id" value="10010"/>
    <constructor-arg name="name" value="lisi"/>
    <constructor-arg name="age" value="20"/>
</bean>
```



##### 3. p名称空间注入

> 使用p名称注入需要先添加p名称空间，配置如下
>
> 只需要将beans的命名空间后面的beans替换为p，在前面添加:p即可

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:p="http://www.springframework.org/schema/p"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans.xsd">
       
    <bean id="user" class="com.cs.spring.entity.User" 
          p:id="10086" 
          p:name="wangmazi" 
          p:age="22"/>


</beans>
```

#### 4. bean管理

##### 1. 注入字面量

> 为属性注入null

```xml
< property  name= "address">< null/></ property>
```

> 为属性注入特殊字符

```xml
<property name="name"><value><![CDATA[<<南京>>]]></value></property>
```

##### 2. 注入外部bean

> xml配置

```xml
<bean class="com.cs.spring.entity.User" id="user">
    <property name="id" value="100000"/>
    <property name="name" value="zhangsan"/>
    <property name="age" value="18"/>
</bean>

<bean id="userDao" class="com.cs.spring.dao.UserDao"/>

<bean id="userService" class="com.cs.spring.service.impl.UserServiceImpl">
    <property name="userDao" ref="userDao"/>
</bean>
```

> 新增类

```java
public interface UserService {
    public String getInfo(User user);
}


@Data
public class UserServiceImpl implements UserService {
    private UserDao userDao;

    @Override
    public String getInfo(User user) {
        return userDao.getInfo(user);
    }
}


public class UserDao {
    public String getInfo(User user) {
        return user.toString();
    }
}
```

> 测试类

```java
@Test
public void test02(){
    ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("bean.xml");
    User user = context.getBean("user", User.class);
    UserService userService = context.getBean("userService", UserService.class);
    System.out.println(userService.getInfo(user));
}
```

##### 3. 注入内部bean

> xml

```xml
<bean id="userService" class="com.cs.spring.service.impl.UserServiceImpl">
    <property name="userDao" >
        <bean id="userDao" class="com.cs.spring.dao.UserDao"/>
    </property>
</bean>
```

> 测试类同上