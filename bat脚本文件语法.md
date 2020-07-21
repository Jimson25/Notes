[原文链接](https://www.cnblogs.com/s1ihome/archive/2009/01/15/batTutorial.html)

1. @ 
> 用于让直行窗口不显示它后面这一行的命令本身。例: `@ echo off` 这里不会在控制台显示 `echo off` 这行命令。

2. echo 
> echo是一个开关命令，只有 `on` 和 `off` 两种状态,用于控制是否显示后面的所有命令。即当其状态为off时 后面所有的代码命令都只会显示执行结果而不显示命令本身。和前面的`@`结合起来含义就是 `不显示 echo off,不显示后面的所有语句命令` 。

3. ::
> 注释，在批处理中和 `rem`作用等效。

4. pause
> 当程序执行到这里的时候会暂停下来，并且在窗口上显示 `请按任意键继续. . .`

5. : 和 goto
> `:` 在批处理中是一个标签， `goto` 是一个跳转语句， 在程序中使用 `:` 可以定义一个标签标记一段代码，然后使用 `goto` 可以跳转到指定的标签处。
```bat
...
goto flag
...
:flag
```

6. %
> 严格来说他不算是一个命令而是批处理中的一个参数。 待续

7. if
> 判断命令，根据得出的结果执行对应的操作。在批处理中有三种用法，分别是 `输入判断` 、 `存在判断` 、 `结果判断`。这里的三种用法都可以在前面添加 `not`取反表示否定。
> ```
> IF [NOT] string1==string2 do command
> IF [NOT] EXIST filename do command
> IF [NOT] ERRORLEVEL number do command
> ```
>> 输入判断：判断输入的参数指定对应的语句。
>> ```bat 
>> if "%1"=="" goto usage
>> ```
>>
>> 存在判断：存在条件成立就执行对应语句
>> ```bat 
>> if exist C:\Progra~1\Tencent\AD\*.gif del C:\Progra~1\Tencent\AD\*.gif 
>>```
>>
>> 结果判断：根据程序运行返回的结果执行对应操作
>> ```bat 
>> @echo off 
>> rem 对%1.asm汇编
>> masm %1.asm
>> rem 判断汇编的返回结果errorlevel，如果结果为1(汇编失败)则暂停并且在按任意键后进入编辑界面
>> if errorlevel 1 pause & edit %1.asm
>> rem 如果汇编成功就用link程序连接生成的obj文件
>> link %1.obj
>> ```

8. call
> 在一个bat脚本中调用另一个bat脚本，可以使用参数。  
>
> start.bat
> ```bat
> ……
> CALL 10.BAT 0
> ……
> ```
>
> 10.bat：
> ```bat
> ……
> ECHO %IPA%.%1 >HFIND.TMP
> ……
> CALL ipc.bat IPCFind.txt
> ```
>
> ipc.bat：
> ```bat
> for /f "tokens=1,2,3 delims= " %%i in (%1) do call HACK.bat %%i %%j %%k
> ```
> 在`start.bat`中调用`10.bat`时后面跟着参数 0 ，这里将会使用0替换 `10.bat`中的参数 `%1`。

9. find
> 这是一条搜索命令，用来在文件中搜索特定的字符串，通常用来做条件判断的铺垫程序（当存在···就执行xx）
> ```bat
> @echo off
> rem 列出当前全部网络连接并将结果保存到 a.txt 中
> netstat -a -n > a.txt
> rem 列出a.txt的全部内容，并在其中查找7626端口是否被占用，如果被占用就打印提示信息
> type a.txt | find "7626" && echo "Congratulations! You have infected GLACIER!"
> rem 如果a.txt中不存在7626端口，就删除a.txt并退出
> del a.txt
> pause & exit
> ```

10. for、set、shift
> 待定

11. |
> 管道命令，`type a.txt | find "7626"`、`help | more`，其作用是将第一条命令的输出信息当做第二条命令的输入信息

12. > >>
> 这两个命令都是重定向命令，直白的说就是把前面的一个命令的输出写入到一个文件中
> 1) `netstat -ano > a.txt` 
> 2) `ping www.baidu.com > a.txt`
> 3) `ping www.jd.com >> a.txt`     

>上面示例中执行完 1 后会生成一个 a.txt 的文件，其中保存的当前电脑的网络连接信息，执行完 2 后会将用其结果替换掉a.txt中原先的内容，执行完 3 之后 2 的执行结果依然存在，3 的结果会追加到 2 的结果后面

13. < 、 >& 、<& 
> `<`，输入重定向命令，从文件中读入命令输入，而不是从键盘中读入。     
> `>&`，将一个句柄的输出写入到另一个句柄的输入中。       
> `<&`，刚好和>&相反，从一个句柄读取输入并将其写入到另一个句柄输出中。        

14. &
> 用于连接多个DOS命令并把这些命令按照顺序执行，而不管命令是否执行失败
> `copy a.txt b.txt /y & del a.txt` 将a.txt的内容复制到b.txt中并且删除a.txt且不会管前面的复制命令是否执行成功

15. &&
> 用于连接多个DOS命令并把这些命令按照顺序执行，但是当前面一个命令执行失败时后面的将不会继续执行
> `copy a.txt b.txt /y && del a.txt` 这里如果前面copy执行失败那么就不会删除 a.txt

16. ||
> 这个命令和 `&&` 作用相反，利用这种方法执行多条命令时，当遇到一个执行正确的命令式就会退出命令组合，不再继续执行下面的命令      
> 题目：查看当前目录下是否有以s开头的exe文件，如果有则退出。    
>
> 方案一、
> ```bat
> @echo off
> dir s*.exe || exit
> ```
> 当当前目录存在s开头的exe时，`dir s*.exe` 执行成功，就不会执行后面的语句，程序结束。当当前目录不存在s开头的exe时，`dir s*.exe`执行不成功，执行`exit`。方案二为改进版本    
>
> 方案二、
> ```bat
> @echo off
> dir s*.exe || echo Didn't exist file s*.exe & pause & exit
> ```
> 列出当前目录是否有以s开头的exe文件，1）当目录存在exe时程序判断执行正确，那么就不会执行`echo`而直接跳转到`pause`，程序结束。2）当前目录不存在exe时，`dir s*.exe`执行不成功，那么就会执行`echo`打印对应语句再执行`pause`