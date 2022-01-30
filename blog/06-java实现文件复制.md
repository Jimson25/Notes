## 使用JAVA I/O流实现文件复制操作

### 一、需求

使用java的io流实现文件复制，将源目录及其子目录下全部的文件复制到目标目录下

### 二、代码

```java
import java.io.*;

public class ExecFile {
    public static void main(String[] args) {
        String sourcePath = "D:\\tem\\music\\Recovered data 02-27-2021 at 20_18_30";
        String targetPath = "D:\\tem\\music\\";
        execFIle(sourcePath, targetPath);
    }

    /**
     * 将源目录及其子目录下全部的文件复制到目标目录下
     * @param sourcePath 源目录
     * @param targetPath 目标目录
     */
    public static void execFIle(String sourcePath, String targetPath) {
        File source = new File(sourcePath);
        if (!source.exists()) {
            return;
        }

        //如果传入的是文件夹，就递归遍历子文件夹
        if (source.isDirectory()) {
            File[] files = source.listFiles();
            for (int i = 0; i < files.length; i++) {
                execFIle(files[i].getAbsolutePath(), targetPath);
            }
        } else {
            File outFile = new File(targetPath + source.getName());
            FileOutputStream out = null;
            FileInputStream in = null;
            try {
                out = new FileOutputStream(outFile);
                in = new FileInputStream(source.getAbsoluteFile());
                byte[] b = new byte[8192];
                //读到多少字节就写入多少字节的数据
                int len;
                while ((len = in.read(b)) != -1) {
                    out.write(b, 0, len);
                }
                System.out.println("已移动文件: {" + source.getName() + "}");
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                try {
                    in.close();
                    out.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}

```

