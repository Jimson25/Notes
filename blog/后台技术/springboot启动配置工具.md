# springboot启动时对项目配置的工具

### ApplicationContextAware

```java
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Component;


@Component
public class TestConfig implements ApplicationContextAware {
    private ApplicationContext context;
    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        this.context = applicationContext;
        this.process();
    }

    private void process(){
        // do process
    }
}
```

当一个bean实现 `ApplicationContextAware`接口时，在创建bean实例时会调用接口中的 `setApplicationContext`方法，在该方法中可以获取到spring上下文。通过实现 `ApplicationContextAware`接口可以在创建bean实例时在上下文中获取容器中实现了指定接口的bean实例，再执行具体业务逻辑。该接口一般用在项目配置类上，用于启动时配置项目环境。

使用 `ApplicationContextAware`接口可以很灵活的配置项目运行环境，但是需要注意的是，该接口会导致bean与Spring容器产生强耦合。如果只是获取少量bean实例，最好使用DI注入。

### BeanFactoryAware

`BeanFactoryAware`接口与 `ApplicationContextAware`接口类似，都是在bean创建过程中调用接口的方法，二者主要区别在于 `ApplicationContextAware`接口获取的是整个spring容器的上下文对象，而 `BeanFactoryAware`接口获取的是 `BeanFactory`对象。

```java
public interface ApplicationContext extends EnvironmentCapable, ListableBeanFactory, HierarchicalBeanFactory,
		MessageSource, ApplicationEventPublisher, ResourcePatternResolver {}
```

通过 `ApplicationContext`接口定义可以看出，`ApplicationContext`接口继承了 `ListableBeanFactory`，因此可以通过Spring上下文对象获取 `Beanfactory`接口中的全部功能。

```java
@Component
public class TestConfig implements BeanFactoryAware , ApplicationContextAware {


    @Override
    public void setBeanFactory(BeanFactory beanFactory) throws BeansException {
        System.out.println("TestConfig.setBeanFactory");
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        System.out.println("TestConfig.setApplicationContext");
    }
}

```

```java
private void invokeAwareInterfaces(Object bean) {
	if (bean instanceof EnvironmentAware) {
		((EnvironmentAware) bean).setEnvironment(this.applicationContext.getEnvironment());
	}
	if (bean instanceof EmbeddedValueResolverAware) {
		((EmbeddedValueResolverAware) bean).setEmbeddedValueResolver(this.embeddedValueResolver);
	}
	if (bean instanceof ResourceLoaderAware) {
		((ResourceLoaderAware) bean).setResourceLoader(this.applicationContext);
	}
	if (bean instanceof ApplicationEventPublisherAware) {
		((ApplicationEventPublisherAware) bean).setApplicationEventPublisher(this.applicationContext);
	}
	if (bean instanceof MessageSourceAware) {
		((MessageSourceAware) bean).setMessageSource(this.applicationContext);
	}
	if (bean instanceof ApplicationStartupAware) {
		((ApplicationStartupAware) bean).setApplicationStartup(this.applicationContext.getApplicationStartup());
	}
	if (bean instanceof ApplicationContextAware) {
		((ApplicationContextAware) bean).setApplicationContext(this.applicationContext);
	}
}
```

通过 `org.springframework.context.support.ApplicationContextAwareProcessor#invokeAwareInterfaces`方法可以看出，spring容器初始化bean的时候，最后调用 `ApplicationContextAware`接口。

通过以上方法可以看出，`EnvironmentAware`，`ResourceLoaderAware`，`ApplicationEventPublisherAware`，`MessageSourceAware`，`ApplicationStartupAware`接口均为直接或间接自 `ApplicationContext`接口取值。

### EmbeddedValueResolverAware

该接口提供一个字符串解析器用于解析带有占位符的字符串表达式。通过该接口可以获取配置文件中的数据。

```java
@Component
public class TestConfig implements EmbeddedValueResolverAware {

    @Override
    public void setEmbeddedValueResolver(StringValueResolver resolver) {
        // sout: 8080
        System.out.println(resolver.resolveStringValue("${server.port}")); 
    }
}

```

### ServletContextAware

```java
@Component
public class TestConfig implements ServletContextAware {

    @Override
    public void setServletContext(ServletContext servletContext) {
        // Apache Tomcat/9.0.63
        System.out.println(servletContext.getServerInfo());
    }
}
```

通过实现 `ServletContextAware`接口可以获取 `ServletContext`上下文，进而获取servlet信息。

### CommandLineRunner

```java
@Component
public class TestConfig implements CommandLineRunner {

    @Override
    public void run(String... args) throws Exception {
        System.out.println("TestConfig.run");
    }
}
```

`CommandLineRunner`接口提供一个run方法，其中参数为main方法启动时的参数，即该方法可以获取项目启动时通过命令传入的参数。该方法在SpringBoot启动完成后执行。

### ApplicationRunner

与 `CommandLineRunner`类似，只是 `ApplicationRunner` 的 `run` 方法接收一个 `ApplicationArguments` 对象作为参数，它提供了更丰富的特性来处理命令行参数。`ApplicationArguments` 可以获取命令行中传递的参数和选项，并支持处理非选项参数、选项参数、命令行选项等。而 `CommandLineRunner` 的 `run` 方法接收一个字符串数组（String[]）作为参数，它只能获取命令行中传递的简单字符串参数，对于复杂的命令行选项和参数需要手动解析。

- 选项参数（Option Arguments）：
  选项参数是命令行中以“--”开头的参数，如 `--name=value` 或 `--port=8080`。选项参数一般用于传递配置信息或标志，可以根据具体需求添加。选项参数的特点是可以带有值，如上述的 `--name=value`，也可以是没有值的开关参数，如 `--verbose`。

- 非选项参数（Non-Option Arguments）：
  非选项参数是命令行中不带“--”的参数，也就是普通的字符串参数，如 `abc`、`123` 等。非选项参数一般用于传递位置相关的参数或其他一些简单参数。
