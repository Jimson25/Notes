### ActiveMQ实例

#### 一、下载安装

1. 在 `/usr/local/src`目录下运行 `wget http://archive.apache.org/dist/activemq/5.14.5/apache-activemq-5.14.5-bin.tar.gz`下载activeMQ安装文件
2. 在 `/usr/local`中创建目录 `mkdir ../activeMQ`
3. 将下载后的文件解压到创建好的目录中 `tar -xvf apache-activemq-5.14.5-bin.tar.gz -C ../activeMQ/ `
4. 进入到解压后的文件目录中的bin目录中 `cd ../activeMQ/apache-activemq-5.14.5/bin`
5. 运行脚本 `./activemq start`启动activeMQ
6. 查看进程是否存在 `ps -ef |grep activemq`
7. 如果需要修改登陆用户名密码只需要修改 `conf/`目录下的 `jetty-realm.properties`即可

#### 二、简单使用

1. 点对点(P2P)模型

   点对点模型是采用队列作为消息载体，在该模式中，一条消息只能被一个消费者消费，没有被消费的消息会被留在队列中等待被消费或者超时。已经被消费的消息会被删除。实例代码及打印信息如下：

   - 生产者：

     ```java
     @Test
     public void test1() throws JMSException, InterruptedException {
         String ACTIVEMQ_URL = "tcp://192.168.1.172:61616";
         
         ActiveMQConnectionFactory factory = new ActiveMQConnectionFactory(ACTIVEMQ_URL);
         Connection connection = factory.createConnection();
         connection.start();
         Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
         Destination testMQ = session.createQueue("testMQ");
         MessageProducer producer = session.createProducer(testMQ);
         for (int i = 0; ; i++) {
             TextMessage message = session.createTextMessage("第 " + i + " 条消息");
             producer.send(message);
             System.out.println("已发送第 " + i + " 条消息");
             Thread.sleep(1000);
         }
     }
     
     /*
     ......
     已发送第 9 条消息
     已发送第 10 条消息
     已发送第 11 条消息
     已发送第 12 条消息
     已发送第 13 条消息
     已发送第 14 条消息
     已发送第 15 条消息
     已发送第 16 条消息
     已发送第 17 条消息
     已发送第 18 条消息
     ......
     */
     ```

   - 消费者1：

     ```java
     @Test
     public void test2() throws Exception {
         ActiveMQConnectionFactory factory = new ActiveMQConnectionFactory(ACTIVEMQ_URL);
         Connection connection = factory.createConnection();
         connection.start();
         Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
         Destination testMQ = session.createQueue("testMQ");
         MessageConsumer consumer = session.createConsumer(testMQ);
         while (true) {
             TextMessage receive = (TextMessage) consumer.receive();
             System.out.println(receive.getText());
         }
     }
     
     /*
     第 9 条消息
     第 11 条消息
     第 13 条消息
     第 15 条消息
     第 17 条消息
     第 19 条消息
     第 21 条消息
     .......
     */
     ```

   - 消费者2：

     ```java
     @Test
     public void test2() throws Exception {
         ActiveMQConnectionFactory factory = new ActiveMQConnectionFactory(ACTIVEMQ_URL);
         Connection connection = factory.createConnection();
         connection.start();
         Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
         Destination testMQ = session.createQueue("testMQ");
         MessageConsumer consumer = session.createConsumer(testMQ);
         while (true) {
             TextMessage receive = (TextMessage) consumer.receive();
             System.out.println(receive.getText());
         }
     }
     
     /*
     第 10 条消息
     第 12 条消息
     第 14 条消息
     第 16 条消息
     第 18 条消息
     第 20 条消息
     第 22 条消息
     ......
     */
     ```

2. 发布订阅(Pub/Sub)模型

   发布订阅模型是以topic(主题)为消息载体，发布者发布一条消息到消息队列中，然后所有订阅该主题的消费者都会接收到该消息，是一种一对多的模型。在这个模式下，发布者发布的消息如果没有被即时消费就无法再次被读取，即消费者无法接收在它连接到该topic之前生产者发布的消息。其代码及打印信息如下：

   - 发布者：

     ```java
     @Test
     public void test1() throws Exception {
         //获取连接工厂
         ActiveMQConnectionFactory factory = new ActiveMQConnectionFactory("tcp://192.168.1.172:61616");
         //获取连接
         Connection conn = factory.createConnection();
         //开启连接
         conn.start();
         //创建一个会话
         Session session = conn.createSession(false, Session.AUTO_ACKNOWLEDGE);
     	//创建一个topic（主题）
         Topic topic = session.createTopic("test-topic");
         //创建一个生产者并绑定这个topic
         MessageProducer producer = session.createProducer(topic);
         for (int i = 0; ; i++) {
             //topic中发送消息
             TextMessage message = session.createTextMessage("第 " + i + " 条消息");
             System.out.println("生产第 " + i + " 条消息");
             producer.send(message);
             Thread.sleep(1000);
         }
     }
     /*
     生产第 0 条消息
     生产第 1 条消息
     生产第 2 条消息
     生产第 3 条消息
     生产第 4 条消息
     生产第 5 条消息
     生产第 6 条消息
     生产第 7 条消息
     生产第 8 条消息
     生产第 9 条消息
     生产第 10 条消息
     生产第 11 条消息
     生产第 12 条消息
     生产第 13 条消息
     生产第 14 条消息
     生产第 15 条消息
     ......
     */
     ```

     

   - 订阅者1：

     ```java
     @Test
     public void test2() throws Exception {
         //获取连接工厂
         ActiveMQConnectionFactory factory = new ActiveMQConnectionFactory("tcp://192.168.1.172:61616");
         //获取连接
         Connection conn = factory.createConnection();
         //开启连接
         conn.start();
         //创建一个会话
         Session session = conn.createSession(false, Session.AUTO_ACKNOWLEDGE);
         //创建一个topic
         Topic topic = session.createTopic("test-topic");
         //创建一个消费者并订阅这个主题
         MessageConsumer consumer = session.createConsumer(topic);
         while (true) {
             //接收消息
             consumer.setMessageListener(message -> {
                 TextMessage textMessage = (TextMessage) message;
                 String text;
                 try {
                     text = textMessage.getText();
                     System.out.println("接收到消息==> "+text);
                 } catch (JMSException e) {
                     e.printStackTrace();
                 }
             });
         }
     }
     /*
     接收到消息==> 第 8 条消息
     接收到消息==> 第 9 条消息
     接收到消息==> 第 10 条消息
     接收到消息==> 第 11 条消息
     接收到消息==> 第 12 条消息
     接收到消息==> 第 13 条消息
     接收到消息==> 第 14 条消息
     接收到消息==> 第 15 条消息
     ......
     */
     ```

   - 订阅者2：

     ```java
     @Test
     public void test3() throws Exception {
         //获取连接工厂
         ActiveMQConnectionFactory factory = new ActiveMQConnectionFactory("tcp://192.168.1.172:61616");
         //获取连接
         Connection conn = factory.createConnection();
         //开启连接
         conn.start();
         //创建一个会话
         Session session = conn.createSession(false, Session.AUTO_ACKNOWLEDGE);
         //创建一个topic
         Topic topic = session.createTopic("test-topic");
         //创建一个消费者并订阅这个主题
         MessageConsumer consumer = session.createConsumer(topic);
         while (true) {
             //接收消息
             consumer.setMessageListener(message -> {
                 TextMessage textMessage = (TextMessage) message;
                 String text;
                 try {
                     text = textMessage.getText();
                     System.out.println("接收到消息==> "+text);
                 } catch (JMSException e) {
                     e.printStackTrace();
                 }
             });
         }
     }
     /*
     接收到消息==> 第 12 条消息
     接收到消息==> 第 13 条消息
     接收到消息==> 第 14 条消息
     接收到消息==> 第 15 条消息
     接收到消息==> 第 16 条消息
     接收到消息==> 第 17 条消息
     接收到消息==> 第 18 条消息
     接收到消息==> 第 19 条消息
     接收到消息==> 第 20 条消息
     ......
     */
     ```


   

   #### 三、整合spring-boot

   1. 创建spring-boot项目并导入依赖

      创建一个spring-boot项目，并在pom文件中引入`web-starter`及`activemq-starter`

      ```xml
      <dependency>
          <groupId>org.springframework.boot</groupId>
          <artifactId>spring-boot-starter-web</artifactId>
      </dependency>
      <dependency>
          <artifactId>spring-boot-starter-activemq</artifactId>
          <groupId>org.springframework.boot</groupId>
      </dependency>
      ```

      

   2. 修改配置文件

      修改配置文件为`.yml` 并添加如下配置：

      ```yaml
      server:
        port: 7002
      
      spring:
        activemq:
          in-memory: false
          user: admin
          password: admin
          broker-url: tcp://192.168.1.172:61616
          pool:
            enabled: false
          packages:
            trust-all: true
      
      ```

      

   3. 创建配置类

      在启动类同级目录下创建文件 `config.ActiveMQConfig.java` 代码如下：

      ```java
      @Configuration
      public class ActiveMQConfig {
          @Bean
          public Queue queue() {
              return new ActiveMQQueue("springboot.queue");
          }
      
          @Bean
          public Topic topic() {
              return new ActiveMQTopic("springboot.topic");
          }
      
          @Bean
          public JmsListenerContainerFactory jmsListenerContainerFactory(
                  @Qualifier("jmsConnectionFactory") ConnectionFactory connectionFactory) {
              DefaultJmsListenerContainerFactory factory = new DefaultJmsListenerContainerFactory();
              factory.setConnectionFactory(connectionFactory);
              //配置为发布/订阅模式 这里设置后就只能发送topic类型的数据
              factory.setPubSubDomain(true);
              return factory;
          }
      }
      ```

      

   4. 创建生产者及消费者

      这里我们使用一个controller来控制生产者，当收到`/activemq/topic`请求后会产生一条消息到MQ

      ```java
      @RestController
      @RequestMapping("/activemq")
      public class ActiveMQProducer {
          @Autowired
          private Queue queue;
          @Autowired
          private Topic topic;
          @Autowired
          private JmsMessagingTemplate jmsTemplate;
      
          @GetMapping("/queue")
          public void sendQueue(String msg) {
              jmsTemplate.convertAndSend(queue, msg);
          }
      
          @GetMapping("/topic")
          public void sendTopic(String msg){
              jmsTemplate.convertAndSend(topic,msg);
          }
      }
      ```

      创建一个消费者，分别接受queue和topic消息

      ```java
      //这里的destination对应的是我们配置的队列名
      @Component
      public class ActiveMQConsumer {
          
          @JmsListener(destination = "springboot.queue")
          public void queueListen(String msg) {
              System.out.println("接收到queue消息:===> " + msg);
          }
      
          @JmsListener(destination = "springboot.topic", containerFactory = "jmsListenerContainerFactory")
          public void topicListen(String msg) {
              System.out.println("接收到topic消息:===> " + msg);
          }
      
      }
      ```

      

   