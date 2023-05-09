### JS中的函数问题



#### 一、函数表达式

- 在js中，函数可以通过一个表达式定义，函数表达式可以存储在变量中。

- 我们可以将一个函数存放在一个变量中，这个变量可以当做函数使用，这种写法称为匿名函数。

  ```js
  let x = function fun1(a, b) {
      return a + b;
  }
  
  let y = x(1, 3);
  
  console.log(y);	//4
  ```



#### 二、Function()构造函数

- 在js中，除了使用`function`之外，我们还可以使用`Function`定义函数。

  ```js
  let fun = new Function("a", "b", "return a + b");
  
  console.log(fun(1,4));// 5
  ```

- 上面的写法等同于使用`function`定义。在js中，我们应该尽量避免使用`new`。



#### 三、函数提升

- 在js中，函数和变量一样具备作用域提升的特性，因此我们可以在声明之前调用函数。

- **使用函数表达式定义的函数作用域无法提升。**

  ```js
  console.log(fun1(1,5));	//6
  
  function fun1(a, b) {
      return a + b;
  }
  ```

  ```js
  console.log(x(1,5));	// err
  
  var x = function fun1(a, b) {
      return a + b;
  }
  ```



#### 四、自调用函数

- js中函数表达式可以`自调用`，自调用函数在函数加载后会自动执行。

- 只有函数表达式支持自调用，声明函数不能自调用。

- 在下面代码中，第一对`()`表示里面是一个函数表达式，第二对`()`表示其自调用。

  ```js
  (function(){
      console.log(`hello`);
  })()
  // hello
  ```



#### 五、箭头函数

- [Vue.js笔记链接](https://github.com/Jimson25/StudyVue.js/tree/master/day06/03-%E7%AE%AD%E5%A4%B4%E5%87%BD%E6%95%B0)

- 在ES6中新增箭头函数写法，其用法相对于原生function而言更加简洁。

  > 有的箭头函数都没有自己的 **this**。 不适合定义一个 **对象的方法**。
  >
  > 当我们使用箭头函数的时候，箭头函数会默认帮我们绑定外层 this 的值，所以在箭头函数中 this 的值和外层的 this 是一样的。
  >
  > 箭头函数是不能提升的，所以需要在使用之前定义。
  >
  > 使用 **const** 比使用 **var** 更安全，因为函数表达式始终是一个常量。
  >
  > 如果函数部分只是一个语句，则可以省略 return 关键字和大括号 {}，这样做是一个比较好的习惯:

  ```js
  function fun1(a, b) {
      return a + b;
  }
  console.log(fun1(1, 5))
  
  // 等同于
  const fun = (a, b) => {
      return a + b;
  }
  console.log(fun(1, 5))
  ```

- 对于一个参数的箭头函数，可以省略`()`

  ```js
  const fun1 = a =>{
      return a+1;
  }
  console.log(fun1(1));	// 2
  
  const fun2 = (a) =>{
      return a+1;
  }
  console.log(fun2(1));	// 2
  ```

- 如果函数体只有一行代码，可以省略`{}`

  ```js
  const fun = (a, b) => a + b;
  
  console.log(fun(1, 3));
  ```



#### 六、函数的arguments对象

- 在函数中都有一个`arguments`对象，该对象是一个类数组（以数组的形式存在，有length，但不具备数组的方法）。

- 在箭头函数中可以打印出`arguments`对象，但是与function中不同的是，它打印的值不是传递到函数的参数。

  ```js
  /*
  [Arguments] { '0': 1, '1': 4 }
  */
  function fun(a, b) {
      console.log(arguments)
  }
  
  fun(1, 4)
  ```

  

#### 七、js中的闭包

- 在网上有各种关于js闭包的解释，但是其本质就是存在一个函数，它返回另外一个函数，在返回的函数中可以访问外层函数的属性，而由于内层函数引用了外层函数的属性，此时被引用的变量不会被销毁。

  ```js
  var add = (function () {
      var counter = 0;
      return function () {return counter += 1;}
  })();
   
  console.log(add.toString());    // function () {return counter += 1;}
  console.log(typeof(add))        // function
  console.log(add())              // 1
  ```

  > 在程序加载的时候会执行这个自调用函数，这时候会初始化counter变量，然后返回一个函数保存到add变量里。此时的add相当于一个函数表达式。
  > 当我们再次执行add()时，相当于自调用add这个函数表达式，即等同于(function () {return counter += 1;})()
  > 在js中，函数也是一个对象，那么当我们使用add变量保存外层函数的返回值时，相当于将返回的函数表达式在内存中的地址赋给了变量add，
  > 此时执行add()相当于在执行内部的函数表达式。

- 根据上面的内容我们大致可以总结关于闭包的如下信息

  - 存在函数嵌套关系，即一个函数内嵌另外一个函数。
  - 内部函数可以使用外部函数的参数和变量。
  - 由于存在内部函数的引用，所以外部函数的参数不会被销毁。

