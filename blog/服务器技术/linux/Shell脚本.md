### Shell教程



#### 一、变量

- 命名规则：

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

- 变量类型：

- **局部变量：**局部变量在shell中定义，仅在当前shell中生效。

- **环境变量：**所有程序都能访问环境变量，有些程序需要环境变量保证其正常运行。必要时shell脚本也可以定义环境变量。

- **shell变量：**shell变量是由shell程序设置的特殊变量。shell变量中有一部分是环境变量，有一部分是局部变量，这些变量保证了shell的正常运行。

    

####  二、字符串

- shell中，定义字符串可以使用单引号、双引号、不使用引号。

- **单引号**：

  - 在单引号中，任何字符都会原样输出，其中的变量是无效的。

  - 单引号字串中不能出现单独一个的单引号（对单引号使用转义符后也不行），但可成对出现，作为字符串拼接使用。

  - 下面代码输出语法错误。

    ```shell
    #!/bin/hash
    
    userName= "zhangsan"
    
    echo 'your name is \'’$userName'
    ```

    

- **双引号**：

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
    #或者使用表达式计算
    echo "str length = `expr length ${your_name}`"
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

  
  
- **在shell中还有如下几种方法可以截取字符串：**

  - **使用`#`截取，删除左边字符保留右边字符**，用法为`#条件`。它会找到指定条件在字符串中第一次出现的位置并从该位置开始删除前面的全部字符（包含条件），即删除`0 ~ 条件`之间的字符串。

    ```shell
    #!/bin/bash
    
    url="http://www.baidu.com//aaa"
    
    # 使用'#'截取字符串，删除左边字符保留右边字符
    # 下面代码会删除第一个//之前的字符，保留后面的字符
    # 输出：www.baidu.com//aaa
    echo "${url#*//}"
    ```

  - **使用`##`截取，删除左边的字符保留右边的字符**，用法和前面一个`#`基本上相同。但是区别在于该命令会找到条件在字符串中**最后一次出现的位置**而不是第一次出现的位置。

    ```shell
    #!/bin/bash
    
    url="http://www.baidu.com//aaa"
    
    # 使用'##'截取字符串，删除左边字符保留右边字符
    # 下面代码会删除最后一个//之前的字符，保留后面的字符
    # 输出：aaa
    echo "${url##*//}"
    ```

  - **使用`%`截取，删除右边的字符保留左边的字符**，用法为`$条件`。该命令会找到%后面的条件在字符串中**最后一次出现的位置**。然后删除条件右边的字符保留左边的字符。

    ```shell
    #!/bin/bash
    
    url="http://www.baidu.com//aaa"
    
    # 下面语句会在url中查找'//'在字符串中最后一次出现的位置，并删除后面全部字符
    # 输出：http://www.baidu.com
    echo "${url%//*}"
    ```

  - **使用`%%`截取，删除右边的字符保留左边的字符**。和前面`%`截取不同的是，该命令会查找指定条件在字符串中第一次出现的位置，然后删除该条件右边的全部字符。

    ```shell
    #!/bin/bash
    
    url="http://www.baidu.com//aaa"
    
    # 使用%%截取字符串，会查找条件在字符串中第一次出现的位置，然后删除后面所有字符。
    # 输出：http:
    echo "${url%%//*}"
    ```

  - **按位置+字符个数从左边截取**。这里第一个数字表示截取的起始位置，第二个数字表示要截取的长度。下面的代码表示截取从第5个字符开始往后数5个字符

    ```shell
    #!/bin/bash
    
    url="http://www.baidu.com//aaa"
    
    # 从左边第五个字符开始往后截取5个字符
    # 输出：//www
    echo "${url:5:5}"
    ```

  - **从左边第n个字符开始截取到结尾。**

    ```shell
    #!/bin/bash
    
    url="http://www.baidu.com//aaa"
    
    # 从左边第5个字符开始截取到字符串结束
    # 输出：//www.baidu.com//aaa
    echo "${url:5}"
    ```

  - **从右边第n个字符开始截取m个字符。**

    ```shell
    #!/bin/bash
    
    url="http://www.baidu.com//aaa"
    
    # 从右边第7个字符开始往后截取5个字符
    # 输出：om//a
    echo "${url:0-7:5}"
    ```

  - **从右边第n个字符开始截取到字符串结尾。**

    ```shell
    #!/bin/bash
    
    url="http://www.baidu.com//aaa"
    
    # 从右边第7个字符开始截取到字符串末尾
    # 输出：om//aaa
    echo "${url:0-7}"
    ```

  - **以上全部代码**

    ```shell
    #!/bin/bash
    
    url="http://www.baidu.com//aaa"
    
    echo "str = ${url}"
    
    # 使用'#'截取字符串，删除左边字符保留右边字符
    # 下面代码会删除第一个//之前的字符，保留后面的字符
    echo "${url#*//}"
    
    # 使用'##'截取字符串，删除左边字符保留右边字符
    # 下面代码会删除最后一个//之前的字符，保留后面的字符
    # 输出：aaa
    echo "${url##*//}"
    
    # 使用%截取字符串，会删除条件及之后的字符，只保留前面的字符。
    # 输出：http://www.baidu.com
    echo "${url%//*}"
    
    # 使用%%截取字符串，会查找条件在字符串中第一次出现的位置，然后删除后面所有字符。
    # 输出：http:
    echo "${url%%//*}"
    
    # 从左边第五个字符开始往后截取5个字符
    # 输出：//www
    echo "${url:5:5}"
    
    # 从左边第5个字符开始截取到字符串结束
    # 输出：//www.baidu.com//aaa
    echo "${url:5}"
    
    # 从右边第7个字符开始往后截取5个字符。
    # 输出：om//a
    echo "${url:0-7:5}"
    
    # 从右边第7个字符开始截取到字符串末尾
    # 输出：om//aaa
    echo "${url:0-7}"
    ```





#### 三、数组

- shell支持数组，但是只支持一维数组。数组长度没有限制，下标从0开始。

- **定义数组：**

  ```shell
  #!/bin/bash
  
  #定义数组
  names=(张三 李四 王五)
  ```

- **输出数组元素：**

  ```shell
  #!/bin/bash
  
  #定义数组
  names=(张三 李四 王五)
  
  # 按下标打印数组元素
  echo "${names[0]}"
  echo "${names[1]}"
  echo "${names[2]}"
  
  #使用‘@’可以打印数组的全部元素。 输出 `张三 李四 王五`
  echo "${names[@]}"
  
  # 打印信息为空白
  echo "${names[3]}"
  ```

- **获取数组长度：**

  ```shell
  #!/bin/bash
  
  # 定义数组
  names=(张三 李四 王五)
  
  # 输出结果为3
  echo "${#names[@]}"
  # 或者
  echo "${#names[*]}"
  
  # 打印数组元素长度
  echo "${#names[1]}"
  ```

  

#### 四、参数传递

- 在执行shell脚本时，我们可以向脚本传递参数，获取方式为`$n`。这里的n表示第几个参数，其中`$0`表示执行的脚本文件路径及文件名。

  ```shell
  #!/bin/bash
  
  echo "shell 传递参数测试"
  echo "文件名称为：$0"
  echo "第一个参数：$1"
  echo "第二个参数：$2"
  
  # 当我们使用相对路径运行该脚本时
  # 执行：	sh ./testParams.sh 1 3
  # 输出：
  # shell 传递参数测试
  # 文件名称为：./testParams.sh
  # 第一个参数：1
  # 第二个参数：3
  
  ```

- 除了上面的`$0`之外，还有几个特殊的字符来处理参数

  | 参数处理 | 说明                                                         |
  | :------- | :----------------------------------------------------------- |
  | $#       | 传递到脚本的参数个数                                         |
  | $*       | 以一个单字符串显示所有向脚本传递的参数。 如"$*"用「"」括起来的情况、以"$1 $2 … $n"的形式输出所有参数。 |
  | $$       | 脚本运行的当前进程ID号                                       |
  | $!       | 后台运行的最后一个进程的ID号                                 |
  | $@       | 与$*相同，但是使用时加引号，并在引号中返回每个参数。 如"$@"用「"」括起来的情况、以"$1" "$2" … "$n" 的形式输出所有参数。 |
  | $-       | 显示Shell使用的当前选项，与[set命令](https://www.runoob.com/linux/linux-comm-set.html)功能相同。 |
  | $?       | 显示最后命令的退出状态。0表示没有错误，其他任何值表明有错误。 |

  - 测试代码

  ```shell
  #!/bin/bash
  
  echo "shell 传递参数测试"
  echo "文件名称为：$0"
  #!/bin/bash
  
  echo "shell 传递参数测试"
  echo "文件名称为：$0"
  echo "第一个参数：$1"
  echo "第二个参数：$2"
  
  # 这里获取到的参数个数是实际传递到脚本的参数个数而不是脚本使用的参数个数
  # 比如说前面我们只使用了 1 2两个，而如果在执行的时候传递的是1 2 3 4，那么打印的结果就是4而不是2
  echo "接收到的参数个数：$#"
  
  # 以一个单字符串显示所有向脚本传递的参数。1 3 4
  echo "以一个单字符串显示所有向脚本传递的参数。$*"
  
  # 当前脚本的进程号：29530
  echo "当前脚本的进程号：$$"
  
  echo "后台运行的最后一个进程的ID：$!"
  
  # 获取参数，这里和前面使用$*获取的参数列表的不同点在于这里是单独获取每一个参数
  echo "参数列表：$@"
  
  echo ======
  # 遍历$*获取的参数
  for i in "$*";do
          echo $i
  done
  # 遍历$@获取的参数
  for i in "$@"; do
          echo $i
  done
  echo =====
  
  
  echo "shell使用的当前选项：$-"
  
  # 这里如果输出结果为0则表示没有错误
  echo "最后命令的退出状态：$?"
  ```

  

#### 五、基本运算符

- shell支持多种运算符，主要如下：

  - 算术运算符
  - 关系运算符
  - 布尔运算符
  - 字符串运算符
  - 文件测试运算符

  shell中原生的bash不支持简单的算术运算，但是可以通过其他命令来实现。如`awk`和`expr`，其中`expr`较为常用。

  `expr` 是一款表达式计算工具，使用它能完成表达式的求值操作。**在使用表达式时，运算符两端需要添加空格。**

##### 算术运算符

| 运算符 | 说明                                          | 举例                          |
| :----- | :-------------------------------------------- | :---------------------------- |
| +      | 加法                                          | `expr $a + $b` 结果为 30。    |
| -      | 减法                                          | `expr $a - $b` 结果为 -10。   |
| *      | 乘法                                          | `expr $a \* $b` 结果为  200。 |
| /      | 除法                                          | `expr $b / $a` 结果为 2。     |
| %      | 取余                                          | `expr $b % $a` 结果为 0。     |
| =      | 赋值                                          | a=$b 将把变量 b 的值赋给 a。  |
| ==     | 相等。用于比较两个数字，相同则返回 true。     | [ $a == $b ] 返回 false。     |
| !=     | 不相等。用于比较两个数字，不相同则返回 true。 | [ $a != $b ] 返回 true。      |

- 测试代码

```shell
#!/bin/bash

a=100
b=20

echo "a = ${a} , b = ${b}"
echo "a + b = `expr $a + $b`"
echo "a - b = `expr $a - $b`"
echo "a * b = `expr $a \* $b`"
echo "a / b = `expr $a / $b`"
echo "a % b = `expr $a % $b`"
echo "a == b = `expr $a == $b`"
echo "a != b = `expr $a != $b`"
```



##### 关系运算符

| 运算符 | 说明                                                  | 举例                       |
| :----- | :---------------------------------------------------- | :------------------------- |
| -eq    | 检测两个数是否相等，相等返回 true。                   | [ $a -eq $b ] 返回 false。 |
| -ne    | 检测两个数是否不相等，不相等返回 true。               | [ $a -ne $b ] 返回 true。  |
| -gt    | 检测左边的数是否大于右边的，如果是，则返回 true。     | [ $a -gt $b ] 返回 false。 |
| -lt    | 检测左边的数是否小于右边的，如果是，则返回 true。     | [ $a -lt $b ] 返回 true。  |
| -ge    | 检测左边的数是否大于等于右边的，如果是，则返回 true。 | [ $a -ge $b ] 返回 false。 |
| -le    | 检测左边的数是否小于等于右边的，如果是，则返回 true。 | [ $a -le $b ] 返回 true    |

- 测试代码

```shell
#!/bin/bash

a=100
b=20

echo "===== 关系运算符 ====="
if [ $a -eq $b ]
then
        echo "$a -eq $b : a 等于 b"
else
        echo "$a -eq $b : a 不等于 b"
fi

echo ""
if [ $a -ne $b ]
then
        echo "$a -ne $b : a 不等于 b"
else
        echo "$a -ne $b : a 等于 b"
fi


echo ""
if [ $a -gt $b ]
then
        echo "$a -gt $b : a 大于 b"
else
        echo "$a -gt $b : a 不大于 b"
fi


echo ""
if [ $a -lt $b ]
then
        echo "$a -lt $b : a 小于 b"
else
        echo "$a -lt $b : a 不小于 b"
fi


echo ""
if [ $a -ge $b ]
then
        echo "$a -ge $b : a 大于等于 b"
else
        echo "$a -ge $b : a 不大于等于 b"
fi


echo ""
if [ $a -le $b ]
then
        echo "$a -le $b : a 小于等于 b"
else
        echo "$a -le $b : a 不小于等于 b"
fi
```

##### 布尔运算符

| 运算符 | 说明                                                | 举例                                     |
| :----- | :-------------------------------------------------- | :--------------------------------------- |
| !      | 非运算，表达式为 true 则返回 false，否则返回 true。 | [ ! false ] 返回 true。                  |
| -o     | 或运算，有一个表达式为 true 则返回 true。           | [ $a -lt 20 -o $b -gt 100 ] 返回 true。  |
| -a     | 与运算，两个表达式都为 true 才返回 true。           | [ $a -lt 20 -a $b -gt 100 ] 返回 false。 |

- 测试代码

```shell
#!/bin/bash

a=100
b=20

echo ""
echo ""
echo "===== 关系运算符 ====="

if [ $a != $b ]
then
   echo "$a != $b : a 不等于 b"
else
   echo "$a == $b: a 等于 b"
fi

echo ""
if [ $a -lt 100 -a $b -gt 15 ]
then
   echo "$a 小于 100 且 $b 大于 15 : 返回 true"
else
   echo "$a 小于 100 且 $b 大于 15 : 返回 false"
fi

echo ""
if [ $a -lt 100 -o $b -gt 100 ]
then
   echo "$a 小于 100 或 $b 大于 100 : 返回 true"
else
   echo "$a 小于 100 或 $b 大于 100 : 返回 false"
fi

echo ""
if [ $a -lt 5 -o $b -gt 100 ]
then
   echo "$a 小于 5 或 $b 大于 100 : 返回 true"
else
   echo "$a 小于 5 或 $b 大于 100 : 返回 false"
fi
```

##### 逻辑运算符

| 运算符 | 说明       | 举例                                       |
| :----- | :--------- | :----------------------------------------- |
| &&     | 逻辑的 AND | [[ $a -lt 100 && $b -gt 100 ]] 返回 false  |
| \|\|   | 逻辑的 OR  | [[ $a -lt 100 \|\| $b -gt 100 ]] 返回 true |

- 测试代码

```shell
#!/bin/bash

a=100
b=20

echo ""
echo ""
echo "===== 逻辑运算符 ====="
# $a < 100 && $b > 100
if [[ $a -lt 100 && $b -gt 100 ]]
then
        echo "返回 true"
else
        echo "返回 false"
fi

echo ""
# $a < 100 || $b > 100
if [[ $a -lt 100 || $b -gt 100 ]]
then
        echo "返回 true"
else
        echo "返回 false"
fi
```



##### 字符串运算符

| 运算符 | 说明                                         | 举例                     |
| :----- | :------------------------------------------- | :----------------------- |
| =      | 检测两个字符串是否相等，相等返回 true。      | [ $a = $b ] 返回 false。 |
| !=     | 检测两个字符串是否不相等，不相等返回 true。  | [ $a != $b ] 返回 true。 |
| -z     | 检测字符串长度是否为0，为0返回 true。        | [ -z $a ] 返回 false。   |
| -n     | 检测字符串长度是否不为 0，不为 0 返回 true。 | [ -n "$a" ] 返回 true。  |
| $      | 检测字符串是否为空，不为空返回 true。        | [ $a ] 返回 true         |

- 测试代码

```shell
#!/bin/bash
str1="hello"
str2="hello"
str3=""

echo "===== 字符串运算符 ====="
echo "str1 = $str1"
echo "str2 = $str2"
echo "str3 = $str3"

echo ""
# 检测两个字符串是否相等
if [ $str1 = $str2 ]
then
        echo "$str1 = $str2 : str1 等于 str2"
else
        echo "$str1 = $str2 : str1 不等于 str2"
fi


echo ""
# 检测两个字符串是否不等
if [ $str1 != $str2 ]
then
        echo "$str1 != $str2 : str1 不等于 str2"
else
        echo "$str1 != $str2 : str1 等于 str2"
fi


echo ""
# 检测字符串长度是否为0 -z
if [ -z $str3 ]
then
        echo "-z $str3 : str3 长度为0"
else
        echo "-z $str3 : str3 长度不为0"
fi
echo ""
# 检测字符串长度是否不为0 -n
if [ -n $str3 ]
then
        echo "-n $str3 : str3 长度不为0"
else
        echo "-n $str3 : str3 长度为0"
fi

echo ""
# 检测字符串是否为空 $
str4=""
if [ $str4 ]
then
        echo "$str4 : 字符串为空"
else
        echo "$str4 : 字符串不为空"
fi

```



文件测试运算符

| 操作符  | 说明                                                         | 举例                      |
| :------ | :----------------------------------------------------------- | :------------------------ |
| -b file | 检测文件是否是块设备文件，如果是，则返回 true。              | [ -b $file ] 返回 false。 |
| -c file | 检测文件是否是字符设备文件，如果是，则返回 true。            | [ -c $file ] 返回 false。 |
| -d file | 检测文件是否是目录，如果是，则返回 true。                    | [ -d $file ] 返回 false。 |
| -f file | 检测文件是否是普通文件（既不是目录，也不是设备文件），如果是，则返回 true。 | [ -f $file ] 返回 true。  |
| -g file | 检测文件是否设置了 SGID 位，如果是，则返回 true。            | [ -g $file ] 返回 false。 |
| -k file | 检测文件是否设置了粘着位(Sticky Bit)，如果是，则返回 true。  | [ -k $file ] 返回 false。 |
| -p file | 检测文件是否是有名管道，如果是，则返回 true。                | [ -p $file ] 返回 false。 |
| -u file | 检测文件是否设置了 SUID 位，如果是，则返回 true。            | [ -u $file ] 返回 false。 |
| -r file | 检测文件是否可读，如果是，则返回 true。                      | [ -r $file ] 返回 true。  |
| -w file | 检测文件是否可写，如果是，则返回 true。                      | [ -w $file ] 返回 true。  |
| -x file | 检测文件是否可执行，如果是，则返回 true。                    | [ -x $file ] 返回 true。  |
| -s file | 检测文件是否为空（文件大小是否大于0），不为空返回 true。     | [ -s $file ] 返回 true。  |
| -e file | 检测文件（包括目录）是否存在，如果是，则返回 true。          | [ -e $file ] 返回 true    |

- 测试代码

```shell
#!/bin/bash

echo "===== 文件测试运算符 ====="
file="/root/test/test.sh"

# -r 判断文件是否可读
if [ -r $file ]
then
        echo "$file 文件可读"
else
        echo "$file 文件不可读"
fi

# -w 判断文件是否可写
echo ""
if [ -w $file ]
then
        echo "$file 文件可写"
else
        echo "$file 文件不可写"
fi

# -x 判断文件是否可执行
echo ""
if [ -x $file ]
then
        echo "$file 文件可执行 "
else
        echo "$file 文件不可执行"
fi

# -d 判断文件是否是目录
echo ""
if [ -d $file ]
then
        echo "$file 是目录文件"
else
        echo "$file 不是目录文件"
fi

# -s 判断文件是否为空
echo ""
if [ -s $file ]
then
        echo "$file 文件不为空"
else
        echo "$file 文件为空"
fi

# -e 判断文件是否存在
echo ""
if [ -e $file ]
then
        echo "$file 文件存在"
else
        echo "$file 文件不存在"
fi

```



#### 六、printf 命令

- shell中，除了`echo`之外还提供了`printf`作为字符串打印命令。使用printf打印字符串可以使用格式化命令来限制打印格式，如限制字符串宽度、字符串对齐方式等。在printf中默认不会添加换行符，需要我们在末尾手动添加`\n`。

  ```shell
  #!/bin/bash
  
  printf "%-10s %-8s %-4s\n" 姓名 性别 体重
  
  printf "%-10s %-8s %-4.2f\n" 张三 男 11.11111
  
  # 如果没限定参数输出宽度，就按照参数实际宽度输出
  printf "%-s %-8s %-4.2f\n" 李四   男 22.332
  
  # 如果格式化字符串后面有多个参数，会重用格式化字符串
  printf "%-10s %-8s %-4.f\n" 王五 女 33.65 赵柳 男 22.31
  
  # 如果参数个数和格式化字符串不匹配，会按照顺序输出
  # 对于缺少的参数，如果是字符串会输出空白/null，如果是数字会输出0 
  # 下面的语句中的20.77会被识别为字符串
  printf "%-10s %-8s %-4.f\n" 王五 女 33.65 张麻子 20.77
  
  ```



