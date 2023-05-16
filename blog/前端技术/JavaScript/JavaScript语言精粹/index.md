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

当可能检索到一个不存在的值并且不想填充默认值时，可以使用`&&`运算法避免报错

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
