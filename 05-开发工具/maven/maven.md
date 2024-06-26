# maven

## Maven依赖

### dependency标签

#### groupId

用于标识项目所属的组织或团队。它按照域、公司、部门的层次结构划分，确保了项目的唯一性。取值通常是反向域名形式

#### artifactId

定义了项目的唯一标识，通常与项目的实际名称相匹配。它是Maven坐标的一部分，与groupId一起确保了项目的唯一性。

#### version

指定项目的版本号，用于区分项目的不同迭代版本。取值可以是数字、日期、语义化版本号（如1.0.0）等。

#### scope

定义依赖的使用范围，决定了该依赖在哪些构建阶段可用，以及是否包含在最终打包的产品中。其取值和作用如下：

- **compile** (默认): 参与编译、测试、打包、运行所有阶段。
- **test**: 仅在测试编译和执行测试时使用。
- **provided**: 在编译和测试时使用，但在运行时由容器提供，不包含在打包中。
- **runtime**: 不参与编译，但参与测试和运行时使用，包含在打包中。
- **system**: 类似于provided，但需要显式指定系统路径（通过systemPath）。
- **import**: 在dependencyManagement中使用，用于导入其他POM的dependencyManagement配置。

#### optional

表示此依赖是否对项目的使用者也是可选的。如果为true，则依赖该模块的项目所依赖的项目不会自动传递这个依赖。取值为 `true`或 `false`。

如模块A依赖模块B，模块B中引入依赖C。假如在C的maven依赖中将optional设置为 `true` ，那么A模块则无法使用C模块的功能。

#### systemPath

当scope设置为system时，用于指定依赖的本地路径。取值是文件系统的绝对路径，例如 `/path/to/my-jar.jar`

#### type

指定依赖的类型，通常为 `jar`，但也可能是 `war`、`ear`、`pom`、`aar`等。定义了依赖的打包格式。取值需符合Maven支持的类型。

### 安装jar包到本地仓库

```
mvn install:install-file 
-Dfile=d:/xxx-spring-boot-starter-2.x-9.5.1.jar 
-DgroupId=com.xxx.appserver 
-DartifactId=xxxxx-spring-boot-starter-9.5.1
-Dversion=9.5.1 
-Dpackaging=jar
```

### maven依赖分析

#### 查看当前项目依赖

- 控制台显示当前项目maven依赖

```cmd
mvn dependency:tree
```

- 控制台显示当前项目maven依赖并指定settings文件

```cmd
mvn -S D:\Develop\maven\apache-maven-3.8.8\conf\settings.xml  dependency:tree > tree.txt
```
