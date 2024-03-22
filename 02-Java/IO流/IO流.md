# IO流

## 字节流和字符流的区别是什么？

- **字节流**（InputStream/OutputStream）是用于处理原始二进制数据的流
- **字符流**（Reader/Writer）是用于处理字符数据的流。字符流在内部使用字节流来操作文件，但它还会使用合适的字符集来解码字节。

## 在读取一个文件内容写入到另一个文件时怎么避免出现乱码？

在读取和写入文件时，乱码通常是由于字符编码不一致导致的。为了避免乱码，你需要确保在读取和写入文件时使用的字符编码是一致的。在Java中，可以使用 `InputStreamReader`和 `OutputStreamWriter`来指定字符编码。

```java
try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream("input.txt"), "UTF-8"));
     BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream("output.txt"), "UTF-8"))) {
    String line;
    while ((line = reader.readLine()) != null) {
        writer.write(line);
        writer.newLine();
    }
} catch (IOException e) {
    e.printStackTrace();
}

```

除此之外，如果文件的编码格式未知或者为了最大程度地保持文件的原始字节序列，可以使用字节流来实现文件内容的复制，从而避免编码转换可能带来的问题。
在Java中，InputStream和OutputStream及其子类是用于处理字节数据的流。使用字节流可以保证读取和写入到文件系统中的数据是完全相同的字节序列，不会进行任何字符集的转换。这样可以确保文件在复制过程中保持其原始的字节内容，从而避免出现乱码问题。

## 缓冲流是怎么提高IO操作性能的？

缓冲流（BufferedInputStream/BufferedOutputStream/BufferedReader/BufferedWriter）在内部维护一个缓冲区，当我们从流中读取或写入数据时，它会尽可能地一次读取或写入多个字节到缓冲区，这样可以减少实际的物理读写操作次数，从而提高IO操作的性能。

## 什么是序列化和反序列化？有哪些第三方的序列化库？

- **序列化**是将对象的状态信息转换为可以存储或传输的形式的过程。
- **反序列化**则是将已序列化的数据恢复为对象的过程。

Java提供了 `java.io.Serializable`接口来支持序列化。同时，Java中也有许多第三方的序列化库，例如：

* **Google Gson** ：一个可以将Java对象转换为其JSON表示形式的库，也可以将JSON字符串转换回Java对象。
* **Jackson** ：一个可以读取和写入JSON和其他数据格式（如XML和CSV）的库。
* **Fastjson2** ：阿里巴巴的开源JSON处理库，可以将Java对象转换为JSON格式，也可以将JSON字符串转换为Java对象。

## 什么是java中的文件锁？

文件锁是用于控制对文件的并发访问。

Java的 `java.nio.channels.FileLock`类提供了对文件的锁定和解锁操作。文件锁可以是共享的，也可以是独占的。共享锁只允许其他并发进程读取文件，但不允许写入。独占锁则不允许其他并发进程读取或写入文件。

```java
import java.io.RandomAccessFile;
import java.nio.channels.FileChannel;
import java.nio.channels.FileLock;

public class FileLockExample {
    public static void main(String[] args) {
        Thread t1 = new Thread(new Worker(), "Thread-1");
        Thread t2 = new Thread(new Worker(), "Thread-2");
        t1.start();
        t2.start();
    }

    static class Worker implements Runnable {
        @Override
        public void run() {
            try {
                RandomAccessFile file = new RandomAccessFile("test.txt", "rw");
                FileChannel fileChannel = file.getChannel();

                System.out.println(Thread.currentThread().getName() + " is waiting to acquire the lock...");
                FileLock lock = fileChannel.lock();
                System.out.println(Thread.currentThread().getName() + " has acquired the lock.");

                Thread.sleep(3000);

                lock.release();
                System.out.println(Thread.currentThread().getName() + " has released the lock.");

                fileChannel.close();
                file.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}

```
