### JS中的一些知识点

#### 一、变量作用域问题

- 变量在函数内部声明，其作用域为函数内，该变量称为局部变量。
- 在函数为声明的变量为全局变量，其作用域具有全局作用域，即在页面任意位置均可访问。
- 如果变量在函数中没有声明，那么该变量为全局变量，但是如果没有调用定义该变量的函数就直接使用该变量，会出现undefined。

  ```js
  function fun1(){
      a = 100;
  }
  // console.log(a); 
  fun1();
  console.log(a);
  ```

#### 二、声明提升问题

- 在js中，变量的声明会被解释器提升到最前方。即对于一个变量，我们可以先声明再使用。

  ```js
  /*
  a = 1
  delete a false
  */
  a = 1;
  console.log(`a = ${a}`);
  console.log(`delete a`,delete a);
  var a;
  ```

  ```js
  /*
  a = 1
  delete a true
  */
  a = 1;
  console.log(`a = ${a}`);
  console.log(`delete a`,delete a);
  ```
- 在js中，变量的初始化不会提升。

  ```js
  //a = undefined
  let a;
  console.log(`a = ${a}`);
  a = 10;
  ```

#### 三、严格模式

- js中的严格模式表示程序将在严格模式下运行。使用 `use strict`设置严格模式.
- 在严格模式下不允许使用未声明的变量。

  ```js
  // ReferenceError: a is not defined

  "use strict"
  a = 10;
  console.log(`a = ${a}`);
  ```

  ```js
  // ReferenceError: y is not defined

  "use strict"
  function fun1() {
      y = 100;
  }
  fun1();
  ```
- 在严格模式下不允许删除对象或变量

  ```js
  // SyntaxError: Delete of an unqualified identifier in strict mode.

  "use strict"
  let a = 100;

  delete a;
  ```
- [其他相关限制](https://www.runoob.com/js/js-strict.html)

#### 四、this指向问题

> 面向对象语言中 this 表示当前对象的一个引用。
>
> 但在 JavaScript 中 this 不是固定不变的，它会随着执行环境的改变而改变。
>
> - 在方法中，this 表示该方法所属的对象。
> - 如果单独使用，this 表示全局对象。
> - 在函数中，this 表示全局对象。
> - 在函数中，在严格模式下，this 是未定义的(undefined)。
> - 在事件中，this 表示接收事件的元素。
> - 类似 call() 和 apply() 方法可以将 this 引用到任何对象。

```html
<body>
    <!-- 点击按钮之后该按钮会消失 -->
    <button onclick="this.style.display = 'none'">按钮</button>
    <script>
        name = "global";
        console.log(`this.name: ${this.name}`)  // global

        let that = this;

        let user = {
            name: "John",
            getName: function () {
                console.log(`that.name`, that.name)     // global
                console.log(`name`, name);      		// global
                return this.name;
            }
        }
        console.log(`user.getName(): ${user.getName()}`);   // John

        function fun1() {
            let name = "fun1"
            let age = 18;
            //this.name：global + age: 18 
            console.log(`this.name：${this.name} + age: ${age} `);  //this.name：global + age: 18
        }
        fun1()
    </script>
</body>
```

通过上面的代码我们可以得出如下结论：

- 单独使用this时，指向的是全局属性（windows）
- 在对象的方法中调用this时，指向的是对象的属性。
- 在函数中调用this时指向的是全局属性。如果我们需要使用函数内部定义的变量，只需要使用变量名即可。
- 在事件中，this指向事件的html元素。

#### 五、使用let声明变量

- 在js中，使用var声明的变量没有块级作用域这一概念，即使用var在代码块中声明的变量在后面都是可以访问的。
- ES6 可以使用 let 关键字来实现块级作用域。let 声明的变量只在 let 命令所在的代码块 **{}** 内有效，在 **{}** 之外不能访问。

  ```js
  {
      let a = 10;
      // 变量a只在这个大括号内生效
  }
  // 在这里就无法再访问变量a了
  ```
- 使用var会重新定义变量，使用let可以避免这个问题。

  ```js
  var a = 10;
  {
      var a = 100;
  }
  console.log(a);	//这里a的值为100

  var b = 1;	//let也可以
  {
     let b = 100; 
      // 这里访问b是100
  }
  console.log(b);	// 这里输出的b为1，在代码块中做出的修改不会影响外面b的值。
  ```
- js中的循环作用域。从下面的代码中可以看出，在循环中使用let不会覆盖外面的同名变量值，而var会覆盖。

  ```js
  var i = 10;
  for (var i = 0; i < 100; i++) {}
  console.log(i); 	// 这里输出的值为100


  let x = 10;
  for (let x = 0; x < 100; x++) {}
  console.log(x)		// 这里输出的是10
  ```

#### 六、使用const声明变量

- const用于声明常量，用法等同于其他语言。相当于声明一个属性指向一块内存地址，这一关系不可变，但是指向的地址具体存储什么元素是可以变化的。
- 在同一作用域下不能存在同名的const变量。在不同的作用域中可以存在同名的const属性。
- const声明的属性必须在生命的时候初始化，并且在初始化之后其值不能被修改。

#### 七、JSON转换

- JSON转JavaScript对象

  ```js
  var text = '{ "sites" : [' +
      '{ "name":"Runoob" , "url":"www.runoob.com" },' +
      '{ "name":"Google" , "url":"www.google.com" },' +
      '{ "name":"Taobao" , "url":"www.taobao.com" } ]}';
  // 将json串转换为js对象
  var obj = JSON.parse(text);
  console.log(obj);
  ```
- JavaScript对象转JSON

  ```js
  // 将js对象转换为json串
  let str = JSON.stringify(obj);
  console.log(str);
  ```

#### 八、void关键字

- void表示要执行一个表达式但是不返回表达式的值。

  ```js
  let a = void(100);
  console.log(a);	//undefined
  ```
  ```html
  <a href="javascript:void(0)">单击此处什么也不会发生</a>
  ```
- `href="#"`与 `href="javascript:void(0)"`的区别

  > **#** 包含了一个位置信息，默认的锚是 **#top** 也就是网页的上端。
  >
  > 而javascript:void(0), 仅仅表示一个死链接。
  >
  > 在页面很长的时候会使用 **#** 来定位页面的具体位置，格式为：**# + id**。
  >
  > 如果你要定义一个死链接请使用 javascript:void(0) 。
  >

  ```html
  <!DOCTYPE html>
  <html lang="zh">

  <head>
      <meta charset="UTF-8">
      <meta http-equiv="X-UA-Compatible" content="IE=edge">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Document</title>
  </head>

  <body>
      <a href="javascript:void(0);">点我没有反应的!</a>
      <a href="#pos">点我定位到指定位置!</a>
      <br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>
      <br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>
      <br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>
      <br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>
      <p id="pos">尾部定位点</p>
  </body>

  </html>
  ```
