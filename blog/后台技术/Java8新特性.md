### Java8新特性

#### 一、默认方法

> 在java8中新增了默认方法和静态方法，默认方法和静态方法要求必须有实现，即不能为抽象。
>
> 静态方法不能被继承，不能被重写。默认方法可以被继承，可以重写。

> java语言中，要求接口的所有实现类都必须要重写其定义的抽象方法，这是面向对象中多态的前提。在这种情况下接口一旦定义就不能修改，否则就要修改该接口全部的实现类。但是在项目发展中难免会存在修改接口的情况，因此在java8中就加入了默认方法这一特性。

> 在接口中定义默认方法只需要使用 **default** 关键字修饰方法即可。

##### 1. 默认方法

- Interface

```java
public interface Interface {
    // 抽象方法
    void func01();

    // 默认方法
    default void func02() {
        System.out.println("Interface.func02");
    }
}
```

- Impl01

```java
public class Impl01 implements Interface {
    @Override
    public void func01() {
        System.out.println("Impl01.func01");
    }
}
```

- Impl02

```java
public class Impl02 implements Interface {
    @Override
    public void func01() {
        System.out.println("Impl02.func01");
    }

    @Override
    public void func02() {
        System.out.println("Impl02.func02");
    }
}
```

##### 2. 静态方法

- Interface

```java
public interface Interface {
    void func01();

    default void func02() {
        System.out.println("Interface.func02");
    }

    static void func03() {
        System.out.println("Interface.func03");
    }
}
```



#### 二、Lambda表达式

> [Lambda](https://www.runoob.com/java/java8-lambda-expressions.html) 表达式，也可称为闭包，它是推动 Java 8 发布的最重要新特性。
>
> Lambda 允许把函数作为一个方法的参数（函数作为参数传递进方法中）。
>
> 使用 Lambda 表达式可以使代码变的更加简洁紧凑。
>
> 
>
> 以下是lambda表达式的重要特征:
>
>  - **可选类型声明：**不需要声明参数类型，编译器可以统一识别参数值。
>  - **可选的参数圆括号：**一个参数无需定义圆括号，但多个参数需要定义圆括号。
>  - **可选的大括号：**如果主体包含了一个语句，就不需要使用大括号。
>  - **可选的返回关键字：**如果主体只有一个表达式返回值则编译器会自动返回值，大括号需要指定表达式返回了一个数值。
>



> Lambda 表达式的简单例子
>
> // 1. 不需要参数,返回值为 5  
> () -> 5  
>
> // 2. 接收一个参数(数字类型),返回其2倍的值  
> x -> 2 * x  
>
> // 3. 接受2个参数(数字),并返回他们的差值  
> (x, y) -> x – y  
>
> // 4. 接收2个int型整数,返回他们的和  
> (int x, int y) -> x + y  
>
> // 5. 接受一个 string 对象,并在控制台打印,不返回任何值(看起来像是返回void)  
> (String s) -> System.out.print(s)

##### 1. 无参数

```java
public class LambdaMain {
    public static void main(String[] args) {
        Interface01 i1 = ()->{
            System.out.println("LambdaMain.main");
        };
        i1.func01();
        // 如果方法只有一行代码，则可以省略大括号
		i1 = ()-> System.out.println("LambdaMain.main");
        i1.func01();
    }
}

interface Interface01{
    void func01();
}

```

##### 2. 一个参数

```java
package com.csbj.demo.lambda;

public class LambdaMain {
    public static void main(String[] args) {
        Interface02 i2 = (int a)-> System.out.println(a);
		// 可以省略类型声明
        i2 = (b)->System.out.println(b);
        i2.func01(10);
    }
}

interface Interface02{
    void func01(int a);
}
```

##### 3. 两个参数

```java
public class LambdaMain {
    public static void main(String[] args) {
        Interface03 i3 = (a, b) -> {
            System.out.println(a + b);
        };
        i3.func01(10, 20);
    }
}

interface Interface03 {
    void func01(int a, int b);
}

```



#### 三、函数式接口

函数式接口(Functional Interface)就是一个有且仅有一个抽象方法，但是可以有多个非抽象方法的接口，但是非抽象方法只能是默认方法或静态方法。

##### 1. JAVA-8新增函数式接口

在之前java已经存在函数式接口，如`java.lang.Runnable`等，在java8中又添加了`java.util.function` ， 它包含了很多类，用来支持 Java的 函数式编程，该包中的函数式接口举例如下：

> BiConsumer
>
> 这个接口包含 **void accept(T t, U u);** 和 **BiConsumer<T, U> andThen(BiConsumer<? super T, ? super U> after)** 两个方法，accept接收两个参数，返回值为空。andThen接收一个BiConsumer对象，返回一个组合对象

```java
public class Main {
    public static void main(String[] args) {
        BiConsumer<Integer, Integer> biConsumer01 = (a, b) -> {
            System.out.println(a);
            System.out.println(b);
        };

        BiConsumer<Integer, Integer> biConsumer02 = (a, b) -> {
            System.out.println(a + b);
        };

        test01(10, 20, biConsumer01, biConsumer02);
    }

    private static void test01(int a, int b, 
                               BiConsumer<Integer, Integer> biConsumer01, 
                               BiConsumer<Integer, Integer> biConsumer02) {
        biConsumer01.andThen(biConsumer02).accept(a, b);
    }
}

```

> andThen方法实现：

```java
// 调用这个方法之后会通过lambda创建一个新的BiConsumer实现，其实现为先执行当前的accept，然后再执行after的accept
// 前面的test01方法中，biConsumer01.andThen(biConsumer02)会返回一个BiConsumer对象，再后面调用这个对象的accept()
default BiConsumer<T, U> andThen(BiConsumer<? super T, ? super U> after) {
    Objects.requireNonNull(after);
    
    return (l, r) -> {
        accept(l, r);
        after.accept(l, r);
    };
}
```



#### 四、方法引用

```
class Car {
    //Supplier是jdk1.8的接口，这里和lamda一起使用了
    public static Car create(final Supplier<Car> supplier) {
        return supplier.get();
    }

    public static void collide(final Car car) {
        System.out.println("Collided " + car.toString());
    }

    public void follow(final Car another) {
        System.out.println("Following the " + another.toString());
    }

    public void repair() {
        System.out.println("Repaired " + this.toString());
    }
}

public class Main {
    public static void main(String[] args) {
        final Car car = Car.create(Car::new);
        final List<Car> cars = Arrays.asList(car);

        cars.forEach(Car::collide);

        cars.forEach(Car::repair);

        final Car police = Car.create(Car::new);
        cars.forEach(police::follow);
        cars.forEach(e -> police.follow(e));
    }
}
```



