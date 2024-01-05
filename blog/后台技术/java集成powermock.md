# JAVA集成PowerMock

## 一、引入依赖

### maven构建

在pom文件中引入如下依赖项：

```xml
<properties>
        <maven.compiler.source>8</maven.compiler.source>
        <maven.compiler.target>8</maven.compiler.target>
        <powermock.version>1.5.6</powermock.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.powermock</groupId>
            <artifactId>powermock-module-junit4</artifactId>
            <version>${powermock.version}</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.powermock</groupId>
            <artifactId>powermock-api-mockito</artifactId>
            <version>${powermock.version}</version>
            <scope>test</scope>
        </dependency>

<!-- 如果使用2.0.2版本，需要引入powermock-api-mockito2 -->
<!--        <dependency>-->
<!--            <groupId>org.powermock</groupId>-->
<!--            <artifactId>powermock-api-mockito2</artifactId>-->
<!--            <version>2.0.2</version>-->
<!--            <scope>test</scope>-->
<!--        </dependency>-->

<!--        <dependency>-->
<!--            <groupId>junit</groupId>-->
<!--            <artifactId>junit</artifactId>-->
<!--            <version>4.13</version>-->
<!--            <scope>test</scope>-->
<!--        </dependency>-->
    </dependencies>
```

### java lib构建

由于powermock官网上lib包下载链接失效，这里需要自行构建依赖项，推荐使用maven创建项目引入以上依赖之后再导出依赖jar。在使用maven构建项目后，引入上面的依赖信息，然后在 `pom.xml` 同级目录下创建lib目录，执行以下命令导出项目依赖

```
mvn dependency:copy-dependencies -DoutputDirectory=lib   -DincludeScope=test
```

导出完成后将lib目录移动到需要集成的项目下，并作为依赖项引入即可。

## 二、入门案例

### 业务代码

- dao

```java
public class EmployeeDao {
    public int getTotal() {
        throw new UnsupportedOperationException();
    }

    public void addEmployee(Employee employee) {
        throw new UnsupportedOperationException();
    }
}

```

- service

```java
public class EmployeeService {
    private EmployeeDao employeeDao;

    public EmployeeService(EmployeeDao employeeDao) {
        this.employeeDao = employeeDao;
    }

    public int getTotalEmployee() {
        return employeeDao.getTotal();
    }

    public void createEmployee(Employee employee)    {
        employeeDao.addEmployee(employee);
    }
}
```

- entity

```
public class Employee {
}
```

### 测试代码

```java
public class EmployeeServiceTest {
    /**
     * 由于dao中的方法均会抛出异常，因此这个案例执行失败
     */
    @Test
    public void testGetTotalEmployee() {
        final EmployeeDao employeeDao = new EmployeeDao();
        final EmployeeService service = new EmployeeService(employeeDao);
        int total = service.getTotalEmployee();
        assertEquals(10, total);
    }

    @Test
    public void testGetTotalEmployeeWithMock() {
        // mock一个dao对象，设置dao对象行为
        EmployeeDao employeeDao = PowerMockito.mock(EmployeeDao.class);
        // 设置调用employeeDao对象的getTotal()方法时返回10
        PowerMockito.when(employeeDao.getTotal()).thenReturn(10);
        // 将mock的对象传入到service中
        final EmployeeService service = new EmployeeService(employeeDao);
        // 这里再调用到dao的方法时会执行我们前面设定的逻辑
        int total = service.getTotalEmployee();
        assertEquals(10, total);
    }

    @Test
    public void testCreateEmployee() {
        Employee employee = new Employee();

        // 第二种情况下，dao中的方法没有返回值，这时调用到dao时不需要执行任何操作，只需要确认方法被调用即可
        EmployeeDao employeeDao = PowerMockito.mock(EmployeeDao.class);
        PowerMockito.doNothing().when(employeeDao).addEmployee(employee);
  
        EmployeeService service = new EmployeeService(employeeDao);
        service.createEmployee(employee);

        // 验证方法是否被调用即可
        Mockito.verify(employeeDao).addEmployee(employee);
    }
}
```

## 三、mock local variable

### 业务代码

- 调整service如下，其余代码不变：

```
public class EmployeeService {

    public int getTotalEmployee() {
        EmployeeDao employeeDao = new EmployeeDao();
        return employeeDao.getTotal();
    }

    public void createEmployee(Employee employee)
    {
        EmployeeDao employeeDao = new EmployeeDao();
        employeeDao.addEmployee(employee);
    }
}
```

这里获取dao对象的方式调整为在service类中自行创建。

### 测试代码

这里由于更改了dao对象的创建方式，因此前面mock一个dao对象再传入service的方式就不再适用，此时需要引入新的测试方案。

```java
@RunWith(PowerMockRunner.class)
@PrepareForTest(EmployeeService.class)
public class EmployeeServiceTest {

    /**
     * 用传统的方式测试
     *  - 这里在EmployeeService中会创建一个EmployeeDao对象，
     *  在调用这个对象的getTotalEmployee方法的时候会抛出我们设置的异常，因此这里测试肯定是失败
     */ 
    @Test
    public void testGetTotalEmployee() {
        EmployeeService service = new EmployeeService();
        int total = service.getTotalEmployee();
        assertEquals(10, total);
    }

    /**
     * mock一个局部变量
     */
    @Test
    public void testGetTotalEmployeeWithMock() {
        // 首先使用PowerMock创建一个局部变量EmployeeDao的对象
        EmployeeDao employeeDao = PowerMockito.mock(EmployeeDao.class);
        try {
            // 设置当通过无参构造创建EmployeeDao这个类的对象时返回前面我们mock出来的对象，
            // 这里相当于使用我们前面mock出来的对象替换new出来的对象，这么做是为了下一步修改局部变量方法调用的返回值做准备
            PowerMockito.whenNew(EmployeeDao.class).withAnyArguments().thenReturn(employeeDao);
            // 当调用前面mock出来的employeeDao对象的getTotal方法时，返回数值10。
            PowerMockito.when(employeeDao.getTotal()).thenReturn(10);
            // 方法调用
            int totalEmployee = new EmployeeService().getTotalEmployee();
            // 断言
            assertEquals(10, totalEmployee);
        } catch (Exception e) {
            Assert.fail("test Failed");
        }
    }



    /**
     * mock一个局部变量并且验证void方法
     */
    @Test
    public void testCreateEmployee(){
        EmployeeDao employeeDao = PowerMockito.mock(EmployeeDao.class);
        try {
            PowerMockito.whenNew(EmployeeDao.class).withNoArguments().thenReturn(employeeDao);
            // 这一行代码可以加也可以不加。在powermock中，mock的对象默认就是doNothing() 即他们不会执行任何操作。
            // 返回值如果为void，则默认不返回任何结果，返回值为基本类型则返回默认值，返回值为Object则返回null
            PowerMockito.doNothing().when(employeeDao).addEmployee(Mockito.any());
      
            // 测试代码
            Employee employee = new Employee();
            EmployeeService employeeService = new EmployeeService();
            employeeService.createEmployee(employee);
            // 验证void方法是否被调用
            Mockito.verify(employeeDao).addEmployee(employee);
        } catch (Exception e) {
            Assert.fail("test Failed");
        }
    }
}
```

### @PrepareForTest注解

[`@PrepareForTest`]()注解的作用是告诉PowerMock准备某些类进行测试。这些类通常是需要在字节码级别上进行操作的类。这包括最终类，具有最终、私有、静态或本地方法的类，以及应该在实例化时返回模拟对象的类。

在上面的案例中，我们需要从字节码层面调整EmployeeService类的行为，因此需要在注解中添加该类用于powermock框架测试。

## 四、mock static

### 业务代码

- service

```
public class EmployeeService {
    public int getEmployeeCount() {
        return EmployeeUtils.getEmployeeCount();
    }

    public void createEmployee(Employee employee) {
        EmployeeUtils.persistenceEmployee(employee);
    }
}
```

- utils

```
public class EmployeeUtils {
    public static int getEmployeeCount()
    {
        throw new UnsupportedOperationException();
    }
    public static void persistenceEmployee(Employee employee)
    {
        throw new UnsupportedOperationException();
    }
}

```

### 测试代码

这里调整代码结构，在service中不再直接调用dao，而是通过一个静态工具类实现数据查询操作。此时，如果我们需要模拟数据库查询操作，就需要mock静态工具类的行为。

```
/**
 * 这里由于我们需要修改EmployeeUtils这个类的执行过程，
 * 所以在@PrepareForTest中传入的是EmployeeUtils
 */
@RunWith(PowerMockRunner.class)
@PrepareForTest(EmployeeUtils.class)
public class EmployeeServiceTest {

    @Test
    public void testGetEmployeeCountWithMock() {
        // Enable static mocking for all methods of a class
        PowerMockito.mockStatic(EmployeeUtils.class);
        PowerMockito.when(EmployeeUtils.getEmployeeCount()).thenReturn(10);
        EmployeeService service = new EmployeeService();
        int count = service.getEmployeeCount();
        assertEquals(10, count);

    }

    @Test
    public void testCreateEmployeeWithMock() {
        PowerMockito.mockStatic(EmployeeUtils.class);
        // EmployeeUtils这个类中所有方法被调用都不会返回任何结果
        PowerMockito.doNothing().when(EmployeeUtils.class);

        Employee employee = new Employee();
        EmployeeService service = new EmployeeService();
        service.createEmployee(employee);

        PowerMockito.verifyStatic();
    }

}
```

## 五、verifying

### 业务代码

- service

```
public class EmployeeService {
    public void saveOrUpdate(Employee employee) {
        final EmployeeDao employeeDao = new EmployeeDao();
        long count = employeeDao.getCount(employee);
        if (count > 0)
            employeeDao.updateEmployee(employee);
        else
            employeeDao.saveEmployee(employee);
    }
}
```

- dao

```
public class EmployeeDao {
    /**
     * @param employee
     */
    public void saveEmployee(Employee employee) {
        throw new UnsupportedOperationException();
    }
    /**
     * @param employee
     */
    public void updateEmployee(Employee employee) {
        throw new UnsupportedOperationException();
    }
    /**
     * @param employee
     * @return
     */
    public long getCount(Employee employee) {
        throw new UnsupportedOperationException();
    }
}
```

这里我们对service做了部分调整，模拟了一个实际中常用的场景，根据参数在数据库中是否存在来决定执行写入或者更新。这种情况下可以引入一些新的验证方式。

### 测试代码

```
@RunWith(PowerMockRunner.class)
@PrepareForTest(EmployeeService.class)
public class EmployServiceTest {

    @Test
    public void testSaveOrUpdateCountLessZero() {
        EmployeeDao employeeDao = PowerMockito.mock(EmployeeDao.class);
        try {
            // 前面提到过修改局部变量返回值的操作
            PowerMockito.whenNew(EmployeeDao.class).withNoArguments().thenReturn(employeeDao);
            // 这里设置当调用getCount时返回0，即后面执行新增操作
            Employee employee = new Employee();
            PowerMockito.when(employeeDao.getCount(employee)).thenReturn(0L);
            EmployeeService service = new EmployeeService();
            service.saveOrUpdate(employee);
            // 验证新增操作被执行了，隐含了一个参数Mockito.times(1)
            Mockito.verify(employeeDao,Mockito.times(1)).saveEmployee(employee);
            // 验证更新操作没有被执行
            Mockito.verify(employeeDao, Mockito.never()).updateEmployee(employee);
        } catch (Exception e) {
            Assert.fail("测试失败");
        }
    }

    @Test
    public void testSaveOrUpdateCountMoreThanZero() {
        EmployeeDao employeeDao = PowerMockito.mock(EmployeeDao.class);

        try {
            Employee employee = new Employee();
            PowerMockito.whenNew(EmployeeDao.class).withNoArguments().thenReturn(employeeDao);
            PowerMockito.when(employeeDao.getCount(employee)).thenReturn(1L);

            EmployeeService service = new EmployeeService();
            service.saveOrUpdate(employee);

            Mockito.verify(employeeDao, Mockito.times(1)).updateEmployee(employee);
            Mockito.verify(employeeDao, Mockito.times(0)).saveEmployee(employee);
            /*
             * 验证事件一次都不执行，Mockito.never()等价于Mockito.times(0)
             *  Mockito.verify(employeeDao, Mockito.never()).saveEmployee(employee);
             * 事件至少执行一次，可以执行一次或多次
             *  Mockito.verify(employeeDao, Mockito.atLeastOnce()).saveEmployee(employee);
             * 事件要求只能执行一次并且必须要执行
             *  Mockito.verify(employeeDao, Mockito.times(1)).saveEmployee(employee);
             * 事件最多执行n次，这里可以修改执行次数
             *  Mockito.verify(employeeDao, Mockito.atMost(1)).saveEmployee(employee);
             * 事件最少执行n次，这里可以修改执行次数
             *  Mockito.verify(employeeDao, Mockito.atLeast(1)).saveEmployee(employee);
             */

        } catch (Exception e) {
            Assert.fail("测试失败");
        }
    }

}
```

## 六、mock final

在powermock中，一个方法是否是final对于mock而言并没有什么区别，只需要按照正常测试方法编写案例即可。

### 业务代码

- dao

```
public class EmployeeDao {
    public final boolean insertEmployee(Employee employee) {
        throw new UnsupportedOperationException();
    }
}
```

- service

```
public class EmployeeService {
    private EmployeeDao employeeDao;

    public EmployeeService(EmployeeDao employeeDao) {
        this.employeeDao = employeeDao;
    }

    public EmployeeService() {
    }

    public void createEmployee(Employee employee) {
//        EmployeeDao employeeDao = new EmployeeDao();
        employeeDao.insertEmployee(employee);
    }
}
```

### 测试代码

```
/**
 * 这里模拟了两种情况，在手册上这里将service中的dao对象设置为全局变量，在创建service对象时通过构造方法传入，所以在测试的时候@PrepareForTest中只需要传入dao类即可
 * 而如果将dao修改为一个方法内的局部变量，则在需要@PrepareForTest中需要同时传入Service和Dao两个类，因为这里实际上这两个类都会被mock框架调用
 */
@RunWith(PowerMockRunner.class)
@PrepareForTest({EmployeeDao.class,EmployeeService.class})
public class EmployeeServicePowerMockTest {

    @Test
    public void testFinal() throws Exception {
        EmployeeDao employeeDao = PowerMockito.mock(EmployeeDao.class);
        Employee employee = new Employee();
        PowerMockito.when(employeeDao.insertEmployee(employee)).thenReturn(true);

        EmployeeService service = new EmployeeService(employeeDao);
        service.createEmployee(employee);

        Mockito.verify(employeeDao, Mockito.times(1)).insertEmployee(employee);
    }

    @Test
    public void testFinal2() throws Exception {
        EmployeeDao employeeDao = PowerMockito.mock(EmployeeDao.class);
        Employee employee = new Employee();
        PowerMockito.when(employeeDao.insertEmployee(employee)).thenReturn(true);
        PowerMockito.whenNew(EmployeeDao.class).withNoArguments().thenReturn(employeeDao);

//        EmployeeService service = new EmployeeService(employeeDao);
        EmployeeService service = new EmployeeService();
        service.createEmployee(employee);

        Mockito.verify(employeeDao, Mockito.times(1)).insertEmployee(employee);
    }
}

```

## 七、mock constructors

### 业务代码

- service

```
public class EmployeeService {
    public void createEmployee(final Employee employee) {
        EmployeeDao employeeDao = new EmployeeDao(false, EmployeeDao.Dialect.MYSQL);
        employeeDao.insertEmployee(employee);
    }
}
```

- dao

```
public class EmployeeDao {
    public enum Dialect {
        MYSQL,
        ORACLE
    }

    public EmployeeDao(boolean lazy, Dialect dialect) {
        throw new UnsupportedOperationException();
    }

    public void insertEmployee(Employee employee) {
        throw new UnsupportedOperationException();
    }
}

```

### 测试代码

这里dao对象不再提供默认的无参构造。此时，我们依然可以使用前面的方式mock代码行为。但是如果dao中根据构造方法传入的不同参数会产生不同的逻辑，就需要用到mock构造方法相关逻辑。

```
@RunWith(PowerMockRunner.class)
@PrepareForTest(EmployeeService.class)
public class EmployeeServiceTest {
    @Test
    public void testAnyArguments() {
        EmployeeDao employeeDao = PowerMockito.mock(EmployeeDao.class);

        try {
            // 这里无论创建对象时需要什么参数都返回我们mock的对象，这种情况下相当于忽略了由构造方法产生的差异性
            PowerMockito.whenNew(EmployeeDao.class).withAnyArguments().thenReturn(employeeDao);

            Employee employee = new Employee();
            EmployeeService employeeService = new EmployeeService();
            employeeService.createEmployee(employee);
            // 验证方法是否被执行
            Mockito.verify(employeeDao).insertEmployee(employee);// (3)

        } catch (Exception e) {
            Assert.fail("测试失败");
        }
    }
  
    @Test
    public void testArguments() {
        EmployeeDao employeeDao = PowerMockito.mock(EmployeeDao.class);

        try {
            // 当以指定参数创建对象的时候返回前面我们mock的对象
            PowerMockito.whenNew(EmployeeDao.class).withArguments(false, EmployeeDao.Dialect.MYSQL).thenReturn(employeeDao);


            Employee employee = new Employee();
            EmployeeService employeeService = new EmployeeService();
            employeeService.createEmployee(employee);
            // 验证方法是否被执行
            Mockito.verify(employeeDao).insertEmployee(employee);// (3)

        } catch (Exception e) {
            Assert.fail("测试失败");
        }
    }
}

```

### mock Arguments

在powermock中，关于构造方法的mock有三种形式：

- 指定构造方法的参数

```
PowerMockito.whenNew(EmployeeDao.class).withArguments(false, EmployeeDao.Dialect.MYSQL).thenReturn(employeeDao);
```

- 默认调用无参构造

```
PowerMockito.whenNew(EmployeeDao.class).withNoArguments().thenReturn(employeeDao);
```

- 忽略构造方法参数的差异性

```
PowerMockito.whenNew(EmployeeDao.class).withAnyArguments().thenReturn(employeeDao);
```

第一种情况下，只会遇到和我们指定的参数相同的情况下才按照mock的行为执行。

第二种情况下，默认使用无参构造，如果被mock的类不存在无参构造，这里会出现异常导致测试失败，如当前案例。

第三种情况下，mock不会判断构造方法的参数，对于任意位置，只要创建该对象就执行设定的mock行为，无论是否存在有参构造。

## 八、Arguments Matcher

### 业务代码

- controller

```
public class EmployeeController {
    public String getEmail(final String userName) {
        EmployeeService employeeService = new EmployeeService();
        return employeeService.findEmailByUserName(userName);
    }
}

```

- service

```
public class EmployeeService {
    public String findEmailByUserName(String userName) {
        throw new UnsupportedOperationException();
    }
}

```

### 测试代码

这里我们模拟根据不同的参数返回不同的执行结果。

```
@RunWith(PowerMockRunner.class)
@PrepareForTest(EmployeeController.class)
public class EmployeeControllerTest {

    @Test
    public void testGetEmail() {
        EmployeeService employeeService = mock(EmployeeService.class);
        PowerMockito.when(employeeService.findEmailByUserName(Mockito.argThat(new ArgumentMatcher<String>() {
            // 添加匹配规则当参数满足arg.startsWith("wangwenjun") || arg.startsWith("wwj")时才返回后面的邮箱地址，否则抛出异常信息
            @Override
            public boolean matches(Object argument) {
                String arg = (String) argument;
                if (arg.startsWith("wangwenjun") || arg.startsWith("wwj")) return true;
                else throw new RuntimeException();
            }
        }))).thenReturn("wangwenjun@gmail.com");

        // 输入任意字符都会返回hahahaha
        // PowerMockito.when(employeeService.findEmailByUserName(Mockito.anyString())).thenReturn("hahahahahaha");
        // PowerMockito.when(employeeService.findEmailByUserName(Mockito.anyVararg())).thenReturn("hello");

        // 当输入的参数以“wa”开头的时候返回"world"
        // PowerMockito.when(employeeService.findEmailByUserName(Mockito.startsWith("wa"))).thenReturn("world");
        try {
            // PowerMockito.when(employeeService.findEmailByUserName("wangwenjun")).thenReturn("wangwenjun@gmail.com");
            PowerMockito.whenNew(EmployeeService.class).withAnyArguments().thenReturn(employeeService);
            EmployeeController controller = new EmployeeController();
            // 下面这行代码会调用service中的findEmailByUserName方法，而前面我们设置了当参数以"wangwenjun"开头时返回"wangwenjun@gmail.com"
            // 所以这里会返回"wangwenjun@gmail.com"，即下面的断言通过
            String email = controller.getEmail("wangwenjun");
            System.out.println(email);

            assertEquals("wangwenjun@gmail.com", email);
            // 这里传入的参数不匹配我们前面设置的参数，所以在执行过程中会抛出RuntimeException，那么下面的fail会执行，cache会捕获到异常信息，测试通过
            email = controller.getEmail("liudehua");
            System.out.println(email);

            fail("should not process to here.");
        } catch (Exception e) {
            // e.printStackTrace();
            assertTrue(e instanceof RuntimeException);
        }
    }
}
```

## 九、Answer interface

通过前面的 `Arguments Matcher` 章节，实现了根据参数匹配输出结果的测试逻辑，但是也存在一些弊端。

在上面的测试中，service层方法只有一个参数，但是在实际中这种情况是很少的。如果前面的service存在多个参数，就需要为每个参数提供一个matcher，并且由于其语法限制，每次mock只能返回一个固定的值，且不能根据输入动态匹配输出结果。

针对这种情况，powermock提供了Answer Interface功能实现参数匹配。

### 业务代码

- controller

```
public class EmployeeController {
    public String getEmail(final String userName) {
        return getEmail(userName, true);
    }


    public String getEmail(final String userName, boolean flag) {
        EmployeeService employeeService = new EmployeeService();
        return employeeService.findEmailByUserName(userName,flag);
    }
}
```

- service

```
public class EmployeeService {
    public String findEmailByUserName(String userName) {
        throw new UnsupportedOperationException();
    }

    public String findEmailByUserName(String userName, boolean flag) {
        throw new UnsupportedOperationException();
    }
}

```


### 测试代码

```
@RunWith(PowerMockRunner.class)
@PrepareForTest(EmployeeController.class)
public class EmployeeControllerTest {

    @Test
    public void testGetEmail() {
        EmployeeService employeeService = PowerMockito.mock(EmployeeService.class);

        // 这里根据不同的输入参数返回不同的执行结果
        PowerMockito.when(employeeService.findEmailByUserName(Mockito.anyString()))
                .then((Answer<String>) invocation -> {
                    String argument = (String) invocation.getArguments()[0];
                    if ("wangwenjun".equals(argument)) return "wangwenjun@gmail.com";
                    else if ("liudehua".equals(argument)) return "andy@gmail.com";
                    throw new NullPointerException();
                });
        try {
            PowerMockito.whenNew(EmployeeService.class).withNoArguments().thenReturn(employeeService);
            EmployeeController controller = new EmployeeController();
            String email = controller.getEmail("wangwenjun");
            assertEquals("wangwenjun@gmail.com", email);
            email = controller.getEmail("liudehua");
            assertEquals("andy@gmail.com", email);
            email = controller.getEmail("JackChen");
            fail("should not process to here.");
        } catch (Exception e) {
            assertTrue(e instanceof NullPointerException);
        }
    }

    @Test
    public void testGetEmailWithFlag() {
        EmployeeService service = PowerMockito.mock(EmployeeService.class);
        PowerMockito.when(service.findEmailByUserName(Mockito.anyString(), Mockito.anyBoolean())).then(invocationOnMock -> {
            // 获取第一个参数
            String arg1 = (String) invocationOnMock.getArguments()[0];
            // 获取第二个参数
            Boolean arg2 = (Boolean) invocationOnMock.getArguments()[1];
            // 两个参数均为设定值则返回成功
            if (arg2 && "zhangsan".equals(arg1)) {
                return "success";
            }
            return "error";
        });

        try {
            PowerMockito.whenNew(EmployeeService.class).withAnyArguments().thenReturn(service);
            EmployeeController controller = new EmployeeController();
            // success
            assertEquals("success", controller.getEmail("zhangsan", true));
            // failed
            assertEquals("success", controller.getEmail("zhangsan", false));
        } catch (Exception e) {
            Assert.fail("测试失败：" + e.getMessage());
        }
    }
}
```


### Invocation对象

invocation.getArguments();		（1）获取 mock 方法中传递的入参
invocation.callRealMethod();		（2）获取是那个真实的方法调用了该 mock 接口
invocation.getMethod();			（3）获取是那么 mock 方法被调用了
invocation.getMock();			（4）获取被 mock 之后的对象



## 十、Mocking with spies

### 业务代码

```
public class FileService {
    public void write(final String text) {
        BufferedWriter bw = null;
        try {
            bw = new BufferedWriter(new FileWriter(System.getProperty("user.dir") + "/wangwenjun.txt"));
            bw.write(text);
            bw.flush();
            System.out.println("content write successfully.");
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (bw != null)
                try {
                    bw.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
        }
    }

    public String read(final String text) {
//        throw new RuntimeException();
        return "xxxxx";
    }
}

```


### 测试代码

```
/**
 * PowerMock中spy和mock的区别
 *  在使用spy对方法做mock操作的时候会执行方法内原始的代码，但是最终返回的是mock产生的结果，而对于类中没有mock的方法，使用spy会照常执行
 *  在使用mock的时候不会执行方法内的代码，当方法被调用的时候会直接返回mock的结果，对于一个类中没有生命mock的方法则不会被执行，即使被调用也不会返回任何结果
 */
public class FileServiceTest {
    /**
     * 在这个方法中，我们只对read()设置了when而没有对write()做任何修改，在实际执行时发现write()方法中的代码没有被执行
     */
    @Test
    public void testWrite() {
        FileService fileService = PowerMockito.mock(FileService.class);
        PowerMockito.when(fileService.read(Mockito.anyString())).thenReturn("hello");
        System.out.println(fileService.read(System.getProperty("user.dir") + "/wangwenjun.txt"));
        fileService.write("liudehua");
    }

    /**
     * 这里我们使用spy来实现mock，在后面的代码中即使没有设置write的mock，其原有的逻辑依然正常执行
     */
    @Test
    public void testWriteSpy() {
        // success
        FileService fileService = PowerMockito.spy(new FileService());
        // fail
        // FileService fileService = PowerMockito.mock(FileService.class);
        PowerMockito.when(fileService.read(Mockito.anyString())).thenReturn("hello");

        // hello
        System.out.println(fileService.read("aaa"));

        fileService.write("liudehua");
        File file = new File(System.getProperty("user.dir") + "/wangwenjun.txt");
        Assert.assertTrue(file.exists());
    }
}
```


## 十一、Mocking private methods

### 业务代码

```
public class EmployeeService {
    public boolean exist(String userName) {
        checkExist(userName);
        return true;
    }
    private void checkExist(String userName) {
        throw new UnsupportedOperationException();
    }
}
```


### 测试代码

```
@RunWith(PowerMockRunner.class)
@PrepareForTest(EmployeeService.class)
public class EmployeeServiceTest {
    @Test
    public void testExist() {
        try {
            // 这里我们只需要mock类EmployeeService中的checkExist方法，其中的exist方法我们希望它按照原有逻辑继续执行，所以这里要使用spy()而不是mock()
            EmployeeService employeeService = PowerMockito.spy(new EmployeeService());

            // 这里由于checkExist是私有方法，所以在外部是不可见的，需要通过方法名设置执行过程
            PowerMockito.doNothing().when(employeeService, "checkExist", "wangwenjun");
            boolean result = employeeService.exist("wangwenjun");
            assertTrue(result);
            PowerMockito.verifyPrivate(employeeService).invoke("checkExist", "wangwenjun");
        } catch (Exception e) {
            fail(e.getMessage());
        }
    }
}
```
