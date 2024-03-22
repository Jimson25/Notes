# Netty框架

## Netty与Tomcat的区别

首先，让我们澄清一下NIO（New I/O）和BIO（Blocking I/O）之间的区别：

1. **BIO（Blocking I/O）** ：

* 在BIO模型中，每个客户端连接都需要一个独立的线程来处理。
* 当一个客户端连接建立后，服务器线程会阻塞等待数据的到来，直到数据到达或连接关闭。
* 这导致了线程资源的浪费，因为每个连接都需要一个线程，而机器能够支持的最大线程数是有限的。

1. **NIO（New I/O）** ：

* NIO使用了Selector、Channel和Buffer的概念，允许一个线程处理多个连接。
* 当一个Socket建立好之后，Thread并不会阻塞去接受这个Socket，而是将这个请求交给Selector。
* Selector会不断地遍历所有的Socket，一旦有一个Socket建立完成，它会通知Thread，然后Thread处理完数据再返回给客户端。
* 这个过程是非阻塞的，允许一个Thread处理更多的请求。

现在，让我们来看看Netty和Tomcat之间的区别：

* **Netty** ：
  * Netty是一个基于NIO开发的网络通信框架，对比于BIO，它的并发性能得到了很大提高。
  * Netty可以自定义各种协议，因为它能够通过编码/解码字节流来完成类似Redis访问的功能。
  * Netty适用于需要高度可扩展性、性能和支持各种协议的场景。
* **Tomcat** ：
  * Tomcat是一个基于HTTP协议的Web容器，主要用于处理Servlet请求。
  * Tomcat支持NIO模式，从6.x版本开始，它引入了NIO，后续还有ARP模式，进一步提高了并发性能。
  * Tomcat适用于传统的Servlet-based Web应用。

假设服务端能开启10个线程，在netty框架中一个线程能处理20个socket连接：

* 在Netty中，一个线程可以处理多个Socket请求，因此假设为20，那么实际Netty中能处理的最大并发请求数理论上可以达到200。
* 在Tomcat中，由于一个请求只能处理一个连接，最大只能处理10个请求。
