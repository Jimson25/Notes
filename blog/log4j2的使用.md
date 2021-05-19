## Log4j的使用方法

### 一、 前置条件

- 创建一个可运行的Maven项目
- 测试JDK版本为1.6

### 二、 整合实现

#### 1. 导入Maven依赖

- 在pom.xml中添加如下内容

  ```xml
  <dependency>
      <groupId>com.lmax</groupId>
      <artifactId>disruptor</artifactId>
      <version>3.2.1</version>
  </dependency>
  
  <!-- 使用slf4j 作为日志门面 -->
  <dependency>
      <groupId>org.slf4j</groupId>
      <artifactId>slf4j-api</artifactId>
      <version>1.7.22</version>
  </dependency>
  
  <!-- 使用 log4j2 的适配器进行绑定 -->
  <dependency>
      <groupId>org.apache.logging.log4j</groupId>
      <artifactId>log4j-slf4j-impl</artifactId>
      <version>2.6.2</version>
  </dependency>
  
  <dependency>
      <groupId>org.apache.logging.log4j</groupId>
      <artifactId>log4j-api</artifactId>
      <version>2.0.2</version>
  </dependency>
  
  <dependency>
      <groupId>org.apache.logging.log4j</groupId>
      <artifactId>log4j-core</artifactId>
      <version>2.0.2</version>
  </dependency>
  ```

#### 2. 创建 `log4j2.xml` 文件

- 在项目`resource` 目录下创建`log4j2.xml`文件，内容如下

  ```xml
  <?xml version="1.0" encoding="UTF-8" ?>
  <!--
      status="warn" 日志框架本身的输出日志级别，可以修改为debug
      monitorInterval="5" 自动加载配置文件的间隔时间，不低于 5秒；生产环境中修改配置文件，是热更新，无需重启应用
   -->
  <configuration status="warn" monitorInterval="5">
      <!-- 提取公共属性，在后面可以使用${<name>}来引用 -->
      <properties>
          <property name="LOG_HOME">D:/temp/Log/demo02</property>
          
          <!--    这个地址指向用户目录 在windows下是C:/user/xxx 在linux下是/home    -->
          <!--    等价于java代码中的 System.getProperty("user.home")    -->
          <!--    在实际项目运行中使用这个配置    -->
          <!--    <property name="LOG_HOME">${sys:user.home}</property>    -->
      </properties>
  
      <!-- 日志处理 -->
      <!--  所有的appender的源码位置： org.apache.logging.log4j.core.appender  -->
      <Appenders>
          <!-- 控制台输出 appender，SYSTEM_OUT输出黑色，SYSTEM_ERR输出红色 -->
          <Console name="Console" target="SYSTEM_OUT">
              <PatternLayout pattern="%d{HH:mm:ss.SSS} [%t] [%-5level] %c{36}:%L --- %m%n"/>
          </Console>
  
        <!-- 在项目中的日志文件存放在${LOG_HOME}/logs/2021-04-23/xxx.log中 -->  
          <RollingFile name="RollingFileInfo" fileName="${LOG_HOME}/logs/${date:yyyy-MM-dd}/info.log"
                       filePattern="${LOG_HOME}/$${date:yyyy-MM}/info-%d{yyyy-MM-dd}-%i.log">
              <!--ThresholdFilter :日志输出过滤-->
              <!--level="info" :日志级别,onMatch="ACCEPT" :级别在info之上则接受,onMismatch="DENY" :级别在info之下则拒绝-->
              <!--日志级别以及优先级排序: OFF > FATAL > ERROR > WARN > INFO > DEBUG > TRACE > ALL -->
              <ThresholdFilter level="info" onMatch="ACCEPT" onMismatch="DENY"/>
              <PatternLayout pattern="[%d{HH:mm:ss:SSS}] [%p] - %l - %m%n"/>
              <!-- Policies :日志滚动策略-->
              <Policies>
                  <!-- TimeBasedTriggeringPolicy :时间滚动策略,默认0点小时产生新的文件,interval="6" : 自定义文件滚动时间间隔,每隔6小时产生新文件, modulate="true" : 产生文件是否以0点偏移时间,即6点,12点,18点,0点-->
                  <TimeBasedTriggeringPolicy interval="6" modulate="true"/>
                  <!-- SizeBasedTriggeringPolicy :文件大小滚动策略-->
                  <SizeBasedTriggeringPolicy size="100 MB"/>
              </Policies>
              <!-- DefaultRolloverStrategy属性如不设置，则默认为最多同一文件夹下7个文件，这里设置了10 -->
              <DefaultRolloverStrategy max="10"/>
          </RollingFile>
  
          <RollingFile name="RollingFileDebug" fileName="${LOG_HOME}/logs/${date:yyyy-MM-dd}/debug.log"
                       filePattern="${LOG_HOME}/$${date:yyyy-MM}/info-%d{yyyy-MM-dd}-%i.log">
              <ThresholdFilter level="DEBUG" onMatch="ACCEPT" onMismatch="DENY"/>
              <PatternLayout pattern="[%d{HH:mm:ss:SSS}] [%p] - %l - %m%n"/>
              <Policies>
                  <TimeBasedTriggeringPolicy/>
                  <SizeBasedTriggeringPolicy size="100 MB"/>
              </Policies>
          </RollingFile>
          <RollingFile name="RollingFileError" fileName="${LOG_HOME}/logs/${date:yyyy-MM-dd}/error.log"
                       filePattern="${LOG_HOME}/${date:yyyy-MM-dd}/info-%d{yyyy-MM-dd}-%i.log">
              <ThresholdFilter level="error" onMatch="ACCEPT" onMismatch="DENY"/>
              <PatternLayout pattern="[%d{HH:mm:ss:SSS}] [%p] - %l - %m%n"/>
              <Policies>
                  <TimeBasedTriggeringPolicy/>
                  <SizeBasedTriggeringPolicy size="100 MB"/>
              </Policies>
          </RollingFile>
  		<!-- 这里配置了3项RollingFileAppender，分别对应debug、info、error级别的日志输出 -->
  
      </Appenders>
  
  
      <loggers>
          <!-- Root节点用来指定项目的根日志，如果没有单独指定Logger，那么就会默认使用该Root日志输出 -->
          <!-- 控制台打印全部日志 -->
          <root level="all">
              <appender-ref ref="Console"/>
          </root>
          <!--AsyncLogger :异步日志,LOG4J有三种日志模式,全异步日志,混合模式,同步日志,性能从高到底,线程越多效率越高,也可以避免日志卡死线程情况发生-->
          <!--additivity="false" : additivity设置事件是否在root logger输出，为了避免重复输出，可以在Logger 标签下设置additivity为”false”-->
          <!-- 写入到文件里面的日志全部异步打印 -->
          <AsyncLogger name="AsyncLogger" level="trace" includeLocation="true" additivity="false">
              <appender-ref ref="RollingFileError"/>
              <appender-ref ref="RollingFileInfo"/>
              <appender-ref ref="RollingFileWarn"/>
          </AsyncLogger>
      </loggers>
  </configuration>
  ```

#### 3. 添加日志打印代码

- 在需要打印日志的地方添加代码如下

  ```java
  public class A extends HttpServlet {
      // 这里传入Class对象用于打印日志中类的信息
      private static final Logger LOGGER = LogManager.getLogger(A.class);
  
      @Override
      protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
          LOGGER.info("\t ===== request-start =====");
          LOGGER.info("\t ===== request-url =====\t" + req.getRequestURI());
          LOGGER.info("\t ===== request-method =====\t" + req.getMethod());
          LOGGER.info("\t ===== request-params =====\t" + JSONObject.toJSONString(req.getParameterMap()));
          LOGGER.info("\t ===== request-end =====");
  
          String id = req.getParameter("id");
           Map<String, String> info = null;
          try{
              info = new DaoExec().getCustInfo(id);
          }catch(Exception e){
              LOGGER.error(e.getMessage());
              e.printStackTrace();
          }
         
          resp.setStatus(200);
          resp.setContentType("text/html;charset=utf-8");
          resp.getWriter().write(JSON.toJSONString(info));
  
          LOGGER.info("\t ===== response-start =====");
          LOGGER.info("\t ===== response-status =====\t" + resp.getStatus());
          LOGGER.info("\t ===== response-contentType =====\t" + resp.getContentType());
          LOGGER.info("\t ===== response-data =====\t" + JSONObject.toJSONString(info));
          LOGGER.info("\t ===== response-end =====");
  
      }
  }
  ```

  