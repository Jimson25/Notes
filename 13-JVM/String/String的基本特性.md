## StringTable

### 一、String的基本特性
1. String代表一个不可变的字符序列，简称不可变性。
    - 当对String进行操作时，其本质是创建一个新的String对象并重新赋值。下面的代码中的replace实际上会创建一个新的String对象，其值为"mbc"
    ```java
        public class Demo{
            public static void main(String args){
                String s1 = "abc";
                String s2 = s1.replace("a","m")
            }
        }
    ```

2. JVM中的字符串常量池是一个固定大小的HashTable，其默认值是1009。如果放进字符串常量池中的字符串非常多，那么就会导致Hash冲突，从而导致链表长度过长。而当链表长度过长后，会导致String.intern的执行效率降低。
    - 使用-XX:StringTableSize可以设置StringTable的长度。
    - 在JDK6中，StringTable的默认长度是1009，-XX:StringTableSize的长度设置没有限制，最高长度没有要求，所以当字符串常量池中的字符串过多时就会导致效率下降。
    - 在JDK7中，StringTable的默认长度为60013，-XX:StringTableSize的长度设置没有限制。
    - 在JDK8中，StringTable的长度最小只能设置到1009

### 二、String在内存中的分配
1. 在java中8中，为了提高程序运行性能，设计者为8种基本数据类型和String类型都设计了一个常量池，但是String的常量池属于比较特殊的存在。
    - 当我们使用字面量直接创建String对象（`String s = "abc";`）的时候，String对象会直接存储在常量池中
    - 当我们使用`new`关键字创建对象时，对象存储在堆中。但是当我们使用new出来的对象调用其intern方法时会将其创建到常量池中。使用idea进行debug执行程序并打开memory视图，可以看到前3个字符串都创建了新的对象，但是执行后面3条语句的时候并没有创建新的对象，即后面三个是使用的前面创建的对象。
    ```java
        public class Demo{
            public static void main(String args){
                String s1 = "1";    //2140
                String s2 = "2";    //2141
                String s3 = "3";    //2142
                String s4 = "1";    //2142
                String s5 = "2";    //2142
                String s6 = "3";    //2142
            }
        }
    ```

### 三、字符串拼接操作
1. 拼接字符串中，如果全部都是以字符串常量的形式拼接，结果会`创建在常量池中`，属于编译器优化。`String s ="a" +"b";`会在编译期间直接优化成`String s = "ab";`

2. 字符串拼接中，只要有一个是变量，那么创建的对象就分配在堆中。如下代码中A代码块创建的两个对象都存在于堆中。在B中，当字符串调用了intern()方法后，该变量指向的就是字符串常量池中得字符串对象。
    ```java
        String a = "a";
        String b = "b";
        //A:
        String s1 = a + "b";
        String s2 = a + b;
        //B:
        s2 = s2.intern();

    ```

3. 字符串拼接实际上是创建了一个StringBuilder对象并调用他的append()方法。从字节码分析可以大概看出，在使用字符串拼接时实际上是创建了一个StringBuilder对象（6）并调用它的append()方法（4，8），当字符串拼接完成后再调用toString方法创建一个String对象。
    ```java
        String x = "x";
        String y = "y";
        String xy = x + y;
    ```
    ```
        0 ldc               #7 <x>
        2 astore_1  
        3 ldc               #8 <y>
        5 astore_2  
        6 new               #9 <java/lang/StringBuilder>
        9 dup   
        0 invokespecial     #10 <java/lang/StringBuilder.<init>>
        3 aload_1   
        4 invokevirtual     #11 <java/lang/StringBuilder.append>
        7 aload_2   
        8 invokevirtual     #11 <java/lang/StringBuilder.append>
        1 invokevirtual     #12 <java/lang/StringBuilder.toString>
        4 astore_3
        5 return
    ```

4. 面试题:3小结中的代码共创建了多少个对象？
    - 对象一：字符串常量池中的对象"x"
    - 对象二：字符串常量池中的对象"y"
    - 对象三：字符串拼接对象StringBuilder
    - 对象四：拼接完成后调用toString方法后创建的String对象

### 四、intern()方法的使用

1. 前面我们提到，对于不是通过`""`创建的对象，它是存在于堆中的，那么这时候我们可以调用String类的intern()方法将这个对象保存到字符串常量池中。
    - `String s1 = new String("s1")`这时候的s1就指向堆内存(新生代\老年代)中的对象，而`String s1 = new String("s1").intern()`中的s1指向的就是字符串常量池中的对象。

    - 简单点将就是任意字符串对象调用intern()方法后返回的结果指向的就是字符串常量池中的对象，即`new String("abc").intern() == "abc";`结果一定是`true`

2. 调用intern()方法的结果`s.intern()`：
    - 如果字符串常量池中不存在s所表示的字符串，那么会把它所表示的字符串在堆内存中的地址保存到字符串常量池中
    - 如果字符串常量池中存在s所表示的字符串，那么就把常量池中的字符串的地址值返回给调用者。
    - 在下面的案例中，在执行完字符串拼接操作后调用toString()方法时是不会在字符串常量池中创建对象的，也就是说此时字符串常量池中是没有"ab"这个字符串的，而当我们调用了intern()方法时，会把堆内存中那个"ab"对象保存在字符串常量池中，再当s2对象创建的时候会先在字符串常量池中找"ab"这个对象，而此时常量池中已经存在"ab"这个对象了，所以返回的是"ab"这个对象的地址，所以判断的地址值相等。
        ```java
        public void test3() {
            /**
             *  这里首先会创建一个StringBuilder对象
             *  然后在字符串常量池创建"a""b"两个对象
             *  再在堆空间创建两个String对象
             *  再调用StringBuilder的append()方法拼接字符串，
             *  最后调用SB的toString()方法生成字符串，toString不会在常量池中创建对象
             *  所以下面s1调用intern()方法时会把s1的地址指向的字符串放到字符串常量池中。
             *  所以这里结果为true
             */
            String s1 = new String("a") + new String("b");
            s1.intern();
            String s2 = "ab";
            System.out.println(s1 == s2);
        }
        ```












