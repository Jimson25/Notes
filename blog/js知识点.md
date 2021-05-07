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

- js中的严格模式表示程序将在严格模式下运行。使用`use strict`设置严格模式.

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

