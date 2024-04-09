# Springboot自定义条件注解

在Springboot框架中，提供了诸如 `ConditionalOnBean` 、 `ConditionalOnClass` 、 `ConditionalOnProperty` 等条件注解，可以实现根据配置文件或者bean来灵活配置系统属性。但是在某些情况下，这些注解依然无法满足特定的业务需求，此时可以通过自定义条件注解实现。

## conditional接口

conditional接口是springboot提供的一个关于条件配置的接口，用于在注册bean之前实现相关的检查，并根据当前环境下的相关信息自行决定是否注册bean。


## 业务场景

假设存在一个列表配置项，每一项在系统中都有一个唯一的service类与之对应。现在系统需要根据列表项中 `load`字段的值判断是否注册当前bean。yml配置如下：

```yaml
info:
  list:
    - id: getInfo
      load: false
    - id: getMsg
      load: true

```



## 实现方案

如果使用springboot提供的ConditionalOnProperty注解配置信息如下：

```java
@ConditionalOnProperty(prefix = "info.list[0]",name = "load",havingValue = "true")
```

这种情况下，需要对配置条件进行硬编码，而且这里写死了列表项的序号，如果后续列表项顺序发生变化，需要调整对应的注解中的条件信息。

### 自定义条件注解

- 新建自定义条件注解类

```java
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE, ElementType.METHOD})
@Conditional(OnListPropertyConditional.class)
public @interface ConditionalOnListProperty {
    // 配置项前缀
    String prefix();

    // 列表项ID的名称
    String itemIdLabel() default "id";

    // 列表项ID的值
    String itemIdValue();

    // 要判断的配置项
    String matchLabel();

    // 配置项匹配的值
    String matchValue();

    boolean matchIfMissing() default false;
}
```

- 新建自定义条件注解配置类

```java
public class OnListPropertyConditional implements Condition {
    @Override
    public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
        final Environment environment = context.getEnvironment();
        Map<String, Object> annotationAttributes = metadata.getAnnotationAttributes(ConditionalOnListProperty.class.getName());
        if (annotationAttributes == null) {
            return false;
        }
        final String prefix = String.valueOf(annotationAttributes.get("prefix"));
        final String itemIdLabel = String.valueOf(annotationAttributes.get("itemIdLabel"));
        final String itemIdValue = String.valueOf(annotationAttributes.get("itemIdValue"));
        final String matchLabel = String.valueOf(annotationAttributes.get("matchLabel"));
        final String matchValue = String.valueOf(annotationAttributes.get("matchValue"));

        int index = 0;
        while (true) {
            final String itemPrefix = prefix + "[" + index + "]" + ".";
            String profileID = environment.getProperty(itemPrefix + itemIdLabel);
            if (StringUtils.isBlank(profileID)) {
                break;
            }
            if (!StringUtils.equals(profileID, itemIdValue)) {
                index++;
                continue;
            }
            final String profileMatchValue = environment.getProperty(itemPrefix + matchLabel);
            return StringUtils.equals(profileMatchValue, matchValue);
        }
        return false;
    }
}
```

- 使用自定义注解

```java
@ConditionalOnListProperty(prefix = "info.list",itemIdValue = "getInfo",matchLabel = "load",matchValue = "true")
```
