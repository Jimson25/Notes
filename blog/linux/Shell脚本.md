### Shell教程



#### 一、变量及命名规则

- 定义变量时变量名和等号之间不能有空格；

- 变量名由数字、字母、下划线组成，数字不能作为开头；

- 变量中间不能有空格，可以有下划线；

- 不能使用关键字；

  ```shell
  #!/bin/bash
  # 定义变量
  user_name= "zhangsan"
  # 使用变量
  echo $user_name
  echo ${user_name}
  #设置变量为只读
  readonly user_name
  
  # 删除变量
  user_age= "18"
  unset user_age
  ```

- 运行shell时会存在3种变量

  - **局部变量：**局部变量在shell中定义，仅在当前shell中生效。

  - **环境变量：**所有程序都能访问环境变量，有些程序需要环境变量保证其正常运行。必要时shell脚本也可以定义环境变量。

  - **shell变量：**shell变量是由shell程序设置的特殊变量。shell变量中有一部分是环境变量，有一部分是局部变量，这些变量保证了shell的正常运行。

    

####  二、字符串

- shell中，定义字符串可以使用单引号、双引号、不使用引号。

- 单引号：

  - 在单引号中，任何字符都会原样输出，其中的变量是无效的。

  - 单引号字串中不能出现单独一个的单引号（对单引号使用转义符后也不行），但可成对出现，作为字符串拼接使用。

  - 下面代码输出语法错误。

    ```shell
    #!/bin/hash
    
    userName= "zhangsan"
    
    echo 'your name is \'’$userName'
    ```

    

- 双引号：

  - 双引号里面可以有变量。

  - 双引号里面可以出现转义字符。

  - 下面代码输出`your name is "zhangsan`

    ```shell
    #!/bin/hash
    
    userName= "zhangsan"
    
    echo "your name is \"${userName}"
    ```

  

- **获取字符串长度**

  - 使用`#变量名`获取字符串长度

    ```shell
    #!/bin/bash
    userName = "zhangsan"
    
    echo "strLength = ${#userName}"
    ```

  

- **提取字符串**

  - 使用`#变量名:起始位置:截取长度`获取字符串

    ```shell
    #!/bin/bash
    
    user_name= "zhangsan"
    
    # 从第二个字符开始，往后截取4个字符-hang
    echo "${user_name:1:4}"
    ```

  

- **查找字符串**

  - 使用`expr index "$string" io`

    ```shell
    #!/bin/bash
    
    userName="zhangsan"
    
    echo `expr index $userName a`
    ```

     