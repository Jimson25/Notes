# maven

## Maven依赖安装

maven安装jar包到本地maven仓库

```
mvn install:install-file 
-Dfile=d:/xxx-spring-boot-starter-2.x-9.5.1.jar 
-DgroupId=com.xxx.appserver 
-DartifactId=xxxxx-spring-boot-starter-9.5.1
-Dversion=9.5.1 
-Dpackaging=jar
```