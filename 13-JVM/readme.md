 1. 本篇主要为B站视频 [尚硅谷2020最新版宋红康JVM教程](https://www.bilibili.com/video/BV1PJ411n7xZ?) 的学习记录。

 2. 主要参考书籍为 [《深入理解Java虚拟机：JVM高级特性与最佳实践（第2版）》](https://item.jd.com/11252778.html)。

 3. 笔记为个人学习笔记，不保证完全正确。

 4. JVM参数设置：
    - -Xms 设置堆空间（新生代+老年代）初始内存大小（-Xms256m/-Xms2g）

    - -Xmx 设置堆空间（新生代+老年代）最大内存大小（-Xmx256m/-Xmx2g）

    - -XX:NewRatio=2 设置新生代/老年代的大小比例，2表示老年代为新生代的2倍，即整个堆内存中，新生代占1/3，老年代占2/3。当修改为-XX:NewRatio=4时，表示新生代占1，老年代占4。

    - -XX:SurvivorRatio: 设置新生代中伊甸园区与Survivor区的比例，如设置-XX:SurvivorRatio=8表示伊甸园区中新生代和两个Survivor区的比例为8：1：1

    - -XX:+PrintGCDetails 打印程序运行后的垃圾回收细节

    - -XX:-UseAdaptiveSizeProxy 关闭自适应内存比例（Use前面的-表示关闭，当使用+时就表示开启）

    - -XX:DoEscapeAnalysis  用于显式开启逃逸分析

    - -XX:PrintEscapeAnalysis   用于查看逃逸分析结果 

    - -XX:EliminateAllocations  开启标量替换，允许将对象打散分配到栈上。

    - -server 设置虚拟机以server模式运行

    - -XX:StringTableSize 设置字符串常量池的大小