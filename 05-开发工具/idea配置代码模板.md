# idea中配置动态的代码模板

## 需求

在项目开发中，可能经常会出现一些固定的代码格式或者注释模板。针对这类标准的形式化结构，可以通过idea自带的代码模板功能实现提示生成。如针对 `todo` 格式，设置成 `// TODO: {username} {date} `这种形式，后续可以通过全局搜索的形式搜索全部待完成的任务。

## idea配置代码模板

1. 通过 `ctrl + alt + s` 快捷键打开 `settings` ，依次打开 `Editer - live Templates - java` 。
2. 点击左上角 `+` 新建规则，选择 `Live Template` ，在 `Abbreviation` 中输入提示词名称，这里以 `todo`为例。
3. 在下方 `Template text` 中输入配置模板。`// TODO: XXXX $date$ $todo$ `。
4. 在idea社区版中，需要自定义date参数。点击右侧 `Edit Variables` ，在name中输入 `date`，在Expression中输入 `date()` 。
5. 点击文本框下面 `Define` 链接，在打开的界面中勾选 `java`

## 配置java类注释

通过配置java类注释，可以实现在新建文件时自动生成相关文档注释，格式如下：

```java
/**
 * Description:
 *
 * @author xxxx
 * @date 2024/4/26
 */
public class DefaultAdapter {

}
```

- 通过 `ctrl + alt + s` 快捷键打开 `settings` ，依次打开 `Editer - File and Code Templates - includes - File Header` 。
- 在右侧文本框中添加自定义文本：

```java
/**
 * Description:
 * @author $USER
 * @date ${DATE} 
 */

```

- 在下方 `Description`中，可以选择其他引用变量，可根据需要自行配置。
- 点击 `apply - ok`，后续新建文件会自动生成以上文件头信息。

## 使用测试

在任意java代码位置输入 `todo` ，根据选择弹出的代码提示即可。

## 扩展

针对这一方式，可以设置其他的形式的代码模板。打开java项目下，找到任一配置，如`fori`，可以看到系统自带的配置模板。这里即使用的`fori`快捷键的生成模板。
