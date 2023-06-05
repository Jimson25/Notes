## 自定义Spring-boot starter实现自动配置

1. 创建一个Maven/springboot项目并实现业务代码
   ![项目结构](./doc/image/img/项目结构.jpg)
2. 修改pom文件如下

   ```xml
       <?xml version="1.0" encoding="UTF-8"?>
       <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/        2001/XMLSchema-instance"
                xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.       apache.org/xsd/maven-4.0.0.xsd">
           <modelVersion>4.0.0</modelVersion>

           <!-- 添加/修改parent标签 -->
           <parent>
               <groupId>org.springframework.boot</groupId>
               <artifactId>spring-boot-starter-parent</artifactId>
               <version>2.3.2.RELEASE</version>
               <relativePath/> <!-- lookup parent from repository -->
           </parent>

           <groupId>com.bdht.starter</groupId>
           <artifactId>demo-starter</artifactId>
           <version>0.0.1-SNAPSHOT</version>
           <name>demo-starter</name>
           <description>Demo project for Spring Boot</description>

           <properties>
               <java.version>1.8</java.version>
           </properties>

           <dependencies>
               <!-- 添加一些依赖 -->   
               <!-- 
                   用于使用自定义配置文件的依赖,
                   通过这个依赖可以把配置文件编译为xxx-metadata.json,
                   在修改项目配置文件时会有代码提示
                -->
               <dependency>
                   <groupId>org.springframework.boot</groupId>
                   <artifactId>spring-boot-configuration-processor</artifactId>
                   <optional>true</optional>
               </dependency>

               <!-- starter自动配置依赖,这是starter的核心依赖 -->
               <dependency>
                   <groupId>org.springframework.boot</groupId>
                   <artifactId>spring-boot-autoconfigure</artifactId>
               </dependency>


               <!-- 测试用的,实际开发可以不要 -->
               <dependency>
                   <groupId>org.springframework.boot</groupId>
                   <artifactId>spring-boot-starter-web</artifactId>
               </dependency>
               <dependency>
                   <groupId>org.springframework.boot</groupId>
                   <artifactId>spring-boot-starter</artifactId>
               </dependency>
               <dependency>
                   <groupId>org.springframework.boot</groupId>
                   <artifactId>spring-boot-starter-test</artifactId>
                   <scope>test</scope>
                   <exclusions>
                       <exclusion>
                           <groupId>org.junit.vintage</groupId>
                           <artifactId>junit-vintage-engine</artifactId>
                       </exclusion>
                   </exclusions>
               </dependency>
           </dependencies>

           <build>
               <plugins>
                   <plugin>
                       <groupId>org.springframework.boot</groupId>
                       <artifactId>spring-boot-maven-plugin</artifactId>
                   </plugin>
               </plugins>
           </build>

       </project>
   ```
3. 创建 `Config`类并配置Bean对象及其他相关设置

   ```java
   ackage com.bdht.starter.config;

   import ch.qos.logback.classic.Level;
   import ch.qos.logback.classic.LoggerContext;
   import ch.qos.logback.classic.encoder.PatternLayoutEncoder;
   import ch.qos.logback.classic.filter.LevelFilter;
   import ch.qos.logback.classic.filter.ThresholdFilter;
   import ch.qos.logback.classic.spi.ILoggingEvent;
   import ch.qos.logback.core.encoder.Encoder;
   import ch.qos.logback.core.filter.Filter;
   import ch.qos.logback.core.rolling.RollingFileAppender;
   import ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP;
   import ch.qos.logback.core.rolling.TimeBasedRollingPolicy;
   import ch.qos.logback.core.spi.FilterReply;
   import ch.qos.logback.core.util.FileSize;
   import com.bdht.starter.aspect.Log4jAspect;
   import com.bdht.starter.aspect.LogbackAspect;
   import com.bdht.starter.props.LogProperties;
   import com.bdht.starter.props.LogbackProperties;
   import org.slf4j.Logger;
   import org.slf4j.LoggerFactory;
   import org.springframework.boot.autoconfigure.SpringBootApplication;
   import org.springframework.boot.autoconfigure.condition.ConditionalOnClass;
   import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
   import org.springframework.boot.context.properties.EnableConfigurationProperties;
   import org.springframework.context.annotation.Bean;
   import org.springframework.context.annotation.Configuration;

   import java.nio.charset.Charset;

   /**
   * spring-boot-starter自动配置类，仅在spring-boot环境下生效
   */
   @Configuration      //这是一个配置类,并且会加载到spring容器
   @ConditionalOnClass(SpringBootApplication.class)    //只有在springboot环境下才会生效
   @EnableConfigurationProperties({LogProperties.class})   //启用配置文件
   public class LogToolAutoConfiguration {
       public LogToolAutoConfiguration() {
       }

       /**
       * 当配置文件里面的log.name 配置的值为`log4j`时会加载该类
       */
       @Configuration
       @ConditionalOnProperty(value = {"log.name"}, havingValue = "log4j")
       public static class log4jConfiguration {
           @Bean
           public Log4jAspect logAspect() {
               return new Log4jAspect();
           }
       }

       /**
       * 当配置文件里面的log.name 配置的值为`logback`时会加载该类
       */
       @Configuration
       @EnableConfigurationProperties({LogbackProperties.class})
       @ConditionalOnProperty(value = {"log.name"}, havingValue = "logback")
       public static class logbackConfiguration {
           private static LogbackProperties logbackProperties;
           private static Logger logger;

           @Bean
           public LogbackAspect logbackAspect(){
               return new LogbackAspect(this.logger);
           }

           public logbackConfiguration(final LogbackProperties logbackProperties) {
               this.logbackProperties = logbackProperties;
               init();
           }

           private void init() {
               /*****/
           }
       }
   }
   ```
4. 在 `resource`目录下创建 `META-INF`目录并添加 `spring.factories`文件

   ```
   org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
       com.bdht.starter.config.LogToolAutoConfiguration
   ```
5. springboot启动时会吧配置类加载为 `EnableAutoConfiguration`的一个子类
