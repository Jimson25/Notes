### JS中for-in和for-of的区别

#### 一、结论

在js中，对于对象来说`for-in`循环出来的是key，而`for-of`循环的是value。而对于数组，`for-in`循环出来的是数组的下标值，`for-of`循环的是value。



#### 二、代码演示

- 首先我们先定义一个数组一个对象

  ```js
  let obj = {
      "name": "zhangsan",
      "age": 18,
      "addr": '北京'
  }
  let arr = ['a', 'b', 'c', 'd'];
  ```

  

- 使用for-in循环

  ```js
  for (const key in obj) {
      console.log(`key = ${key}`);
  }
  
  console.log(`==================`)
  
  for (let index in arr) {
      console.log(`key = ${index}, value = ${arr[index]}`);
  }
  
  // 输出
  /*
  name
  age
  addr
  ==================
  
  key = 0, value = a
  key = 1, value = b
  key = 2, value = c
  key = 3, value = d
  */
  ```

  从上面的输出结果可以看出，对于一个对象而言，for-in打印的是其key的值，而对于数组而言，打印的是其元素的下标值。



- 使用for-of循环

  ```js
  // for (let val of obj) {
  //     console.log(`key = ${val}`);
  // }
  
  console.log(`==================`)
  
  for (let val of arr) {
      console.log(`key = ${val}`);
  }
  
  /*
  ==================
  key = a
  key = b
  key = c
  key = d
  */
  ```

  在上面的的案例中没有使用for-of遍历对象，如果打开注释会出现`TypeError: obj is not iterable`的错误。这里之所以不能使用for-of是因为for-of是依赖于迭代器实现的，而Object没有内置迭代器，所以对Object使用for-of会报错。
  
  如果需要使用for-of遍历对象，方法如下：
  
  ```js
  /*
  	这里先获取到Object的key的集合，然后使用for-of遍历key的集合在通过取到的key获取对应的value
  	这里对象的key是变量，所以取值的时候需要使用`obj[]`取值
  */
  for (let val of Object.keys(obj)) {
      console.log(`key = ${val}, value = ${obj[val]}`);
  }
  ```
  
  
  
  ​	
  
  