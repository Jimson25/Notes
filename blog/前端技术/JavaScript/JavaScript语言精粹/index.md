# JavaScript语言精粹

## 第2章 语法

### 2.3 数字

- js中，数字类型被表示为一个64位的浮点数。其内部不分整形和浮点型，即 `1`和 `1.0`表示的是同一个数。
- js中，数字可以用指数形式表示。如 `let num = 1e2; console.log(num); // 100`
- js中，`NaN`是一个数值，表示不能产生正常结果的运算结果。NaN不等于任何值，包括它自己。可以用 `isNaN(number)`检测NaN。

### 2.4 字符和字符串

- `js中没有字符类型`，要表示字符，只需要定义一个只含有一个字符的字符串即可。

### 2.5 语句

- 当var语句被定义在函数内部时，它定义了这个函数的私有变量。
- 在js中，`代码块不会创建新的作用域`。
- 在if语句中，`false、null、undefined、空串、0、NaN`都会被认为false，除此之外都为true

## 第3章 对象

> javascript中的简单类型包括数字、字符串、布尔值、null和undefined。其他所有的值都是对象。
>
> 对象是属性的容器，其中每个属性都有名字和数值。属性的名字可以是包括空字符串在内的任意字符串。属性值可以是undefined之外的任意值。
>
> JavaScript可以通过原型链特性实现继承另一个对象的属性。

### 3.1 对象字面量

属性名可以是包括空字符串在内的任何字符串，并且不要求使用引号括住属性名。

```javascript
var obj = {
	name:"zhangsan",
	age:18,
	tel:{
		phone:12121,
		wechat:31313
	}
}
```

### 3.2 检索

有如下两种方法检索对象中的值：

- 使用 `obj["name"];//"zhangsan"`
- 使用 `obj.age;//18`

当检索一个不存在的元素时会返回一个undefined值。

- `obj.addr; //undefined`

当可能检索到一个不存在的值时，可以使用 ||运算符来填充默认值

```javascript
var addr = obj.addr || "beijing"; // "beijing"
var name = obj.name || "lisi";	//"zhangsan"
```

当可能检索到一个不存在的值并且不想填充默认值时，可以使用 `&&`运算法避免报错

```javascript
console.log(obj.addr)                       // undefined
console.log(obj.addr.detail)                // typeError
console.log(obj.addr && obj.addr.detail)    // undefined
```

### 3.3 更新

可以使用 `obj.name = "lisi"` 来更新对象中的数据。如果name存在则更新，如果不存在则将name添加到对象中。

### 3.4 引用

对象实际为引用类型，即将对象赋值给变量时，实际给的是对象的内存地址，此时两个变量指向同一块内存。

```
var x = obj;
x.name = "lisi";
console.log(obj.name)   // "lisi"
```

### 3.5 原型

每个对象都连接到一个原型对象，并且它可以从中继承属性。所有通过字面量创建的对象都连接到 `Object.prototype` 这个JavaScript中的标准对象。

我们可以为Object增加一个beget方法，这个方法创建一个使用原对象作为其新对象。

```javascript
if (typeof Object.beget !== 'function') {
    // 为Object增加beget方法
    Object.beget = function (o) {
        var F = function () { }
        F.prototype = o;
        return new F();
    }
}

let foo = {
    name:"zhangsan",
    age:18
}

var anotherObj = Object.beget(foo);

console.log(anotherObj.name);   // 张三
```

- 当我们对某个对象做更改时，不会影响该对象的原型。
- 原型连接只有在检索时才会用到。当从对象中获取某个属性的值时，如果该对象中没有此属性名，则会依次往上从原型中检索，如果一直到Object.prototype中都不存在，则返回undefined。以上这一过程称为委托。
- 当我们往原型中添加一个新属性时，该属性会对所以基于该原型创建的对象可见。

### 3.6 反射

当我们需要检查对象是否拥有某个属性时，可以使用 `hasOwnProperty()`函数来检查，该函数不会检查原型链，只检查对象的独有的属性。

### 3.7 枚举

使用 `for...in` 语句可以对象中的所有属性名。但是这种方式会遍历包括函数和原型链上的属性，如果我们只需要对象自身的属性，则可以使用 `hasOwnProperty()` 和 `typeof`来排除。

```javascript
let foo = {
    name: "zhangsan",
    age: 18,
    getName: () => {
        return this.name;
    }
}

for (const key in foo) {
    if (typeof foo[key] !== 'function' && Object.hasOwnProperty.call(foo, key)) {
        const element = foo[key];
        console.log(key)
        console.log(element)
    }
}
```

### 3.8 删除

可以使用 `delete`删除对象的属性。使用delete会移除对象中确定包含的属性，不会触及原型链中的属性。

使用delete可以是原型链中的属性浮现出来。当对象和原型链中同时拥有某一同名属性时，对对象的属性执行delete后，在检索该属性则返回原型链中的属性对应的值。

### 3.9 减少全局变量的污染

JavaScript中，全局变量削弱了程序的灵活性，应该避免。`最小化全局变量的方法是在应用中只创建一个唯一的全局变量：var MYAPP = {}。`此时 `MYAPP` 成为应用的容器。

```javascript
MYAPP.user = {
	name:"zhangsan",
    age:18
}

MYAPP.unit = {
    name:"google",
    code:99991001
}

```

## 第4章 函数

### 函数定义方式的区别

#### 箭头函数定义

- 箭头函数没有自己的 `this`绑定，它会捕获并继承包含它的外层作用域的 `this`值。
- 箭头函数不能用作构造函数，不能使用new关键字实例化对象，也不能设置自己的原型。
- 箭头函数没有自己的 `arguments`对象，而是继承外层作用域中的 `arguments`对象。
- 箭头函数中，`this`的值是在定义时确定的，定义箭头函数的位置决定了函数中this的值。
- 箭头函数的外层作用域问题：

> 当使用箭头函数定义函数时，箭头函数的作用域指向的是包含该对象的作用域。即箭头函数会继承并捕获包含它的对象所属的作用域。
>
> 如果对象是在全局作用域中定义的，那么箭头函数的作用域就是全局作用域。
>
> ```javascript
> const obj = {
>   arrowFunction: () => {
>     console.log(this); // 输出全局对象（如 Window或global）
>   }
> };
> ```
>
> 如果对象是在函数作用域中定义的，那么箭头函数的作用域就是函数的作用域。
>
> ```javascript
> function myFunction() {
>   const obj = {
>     arrowFunction: () => {
>       console.log(this); // 在浏览器环境中输出包含 myFunction 的函数的 this 值
>     }
>   };
> }
>
> ```

#### 声明式定义

- 使用 `function`关键字定义的函数，会根据函数的调用方式动态确定函数中 `this`的值。
- function关键字定义的函数可以 `作为构造函数使用`。
- 使用function关键字定义的函数有自己的 `arguments`对象。
- 使用function关键字定义的函数中的this对象指向 `调用这个函数的对象`。

### 4.1 函数对象

JavaScript中，函数也是对象。函数对象连接到Function.prototype(该原型对象本身连接到Object.prototype)。

每个函数创建时附有两个附加的隐藏属性：函数的上下文和实现函数行为的代码。

每个函数对象在创建时都会随带一个prototype属性。它的值是一个拥有constructor属性且值为该函数的对象。

### 4.2 函数的字面量

- **闭包：**

函数可以定义在其他函数中。一个内部函数自然可以访问自己的参数和变量，同时它也能方便的访问它被嵌套在其中的那个函数的参数和变量。通过函数字面量创建的函数对象包含一个连接到外部上下文的连接。这被称为**闭包**。

### 4.3 函数的调用

- **函数的默认参数**

除了声明时定义的形式参数，每个函数接收两个附加参数：`this`和 `arguments`。

`this`的值取决于调用模式。JavaScript中一共有4中调用模式：方法调用模式、函数调用模式、构造器调用模式和apply调用模式。

- **参数传递问题**

函数调用时，形参个数与实参个数可以不相等。当实参个数小于形参个数时，缺失的形参将被赋值为undefined。当实参个数大于形参个数时，多余的实参将被忽略。

- **JavaScript调用模式**

#### 方法调用模式

- 当函数被保存为 `对象的一个属性`时，我们称它为一个 `方法`。当一个方法被调用时，this绑定到该对象。方法可以使用this去访问对象，所以它能从对象中取值或修改该对象的值。
- this到对象的绑定发生在调用的时候。这个超级迟绑定使函数可以对this高度复用。`tips:`这里可以分为两种情况讨论：

  - 第一种情况是函数定义在公共作用域内。这时候如果在函数中使用this，那么this绑定到调用函数的对象上，这种情况下要求调用方必须包含this指向的属性。那么更好的使用方法是将this指向的属性调整为函数的参数，由调用方传递到函数中。

    ```javascript
    function greet() {
    console.log("Hello, " + this.name);
    }

    const person1 = { name: "John" };
    const person2 = { name: "Alice" };

    person1.greet = greet;
    person2.greet = greet;

    person1.greet(); // 输出 "Hello, John"
    person2.greet(); // 输出 "Hello, Alice"

    ```
  - 第二种情况下是函数定义在对象中。这种情况下this依然指向调用函数的对象，但是存在 `一个误区`就是函数只能由定义函数的对象调用，这里应该区别于java等后端语言。如下代码中，可以通过其他对象调用对象中的方法。

    ```javascript
    const person = {
      name: "John",
      greet: function() {
        console.log("Hello, " + this.name);
      }
    };

    person.greet(); // 输出 "Hello, John"

    const anotherPerson = {
      name: "Alice"
    };

    anotherPerson.greet = person.greet;
    anotherPerson.greet(); // 输出 "Hello, Alice"

    ```
- 通过this取得它所属对象的上下文的方法称为 `公共方法`。公共方法是指定义在对象内部，并且可以通过对象调用的方法。在对象中，只有使用普通函数语法（非箭头函数）定义的方法才能使用 `this` 关键字来访问对象的属性，并被称为公共方法。

  ```javascript
  let obj = {
      age:18,
      setAge:function() {
          this.log();
          this.age = 20;
      },
      log:function(){
          console.log(this.age);
      }
  }
  obj.setAge();
  console.log(obj.age);

  ```

#### 函数调用模式

当一个函数并非对象的属性时，那么它被当作一个函数来调用。

```javascript
let sum = add(5,3)
```

当函数以这种方式调用时，this被绑定到全局对象。

```javascript
name = "outer";     // 定义一个全局对象name
function test() {
    let name = "inner";
    function add(a, b) {
        console.log(this.name); // 打印 outer
        return a + b;
    }
    add(3, 4);
}
test();
```

#### 构造器调用模式

如果在函数前面带上new来调用，那么将创建一个隐藏连接到该函数的prototype成员的新对象，同时this将会被绑定到那个新对象上。
