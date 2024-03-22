# CountDownLatch类的作用是什么？

`CountDownLatch`是一个同步工具类，它允许一个或多个线程等待直到在其他线程中执行的一组操作完成。

假设我们有一个应用程序，在启动之前需要初始化多个服务。我们想要在所有服务都初始化完成后才启动应用程序的主线程。我们可以使用 CountDownLatch 来实现这一点。

```java

import java.util.concurrent.CountDownLatch;


publicclass ApplicationLauncher {


    // 假设有三个服务需要初始化

    privatestaticfinalint N = 3;


    publicstaticvoid main(String[] args) {

        // 创建一个计数器，初始化为3

        CountDownLatch latch = new CountDownLatch(N);


        // 创建并启动三个服务初始化线程

        for (int i = 0; i < N; ++i) {

            new Thread(new ServiceInitializer(latch, "Service" + (i+1))).start();

        }


        // 主线程等待所有服务初始化完成

        try {

            latch.await(); // 阻塞，直到计数器降为0

        } catch (InterruptedException e) {

            e.printStackTrace();

        }


        // 所有服务都已初始化，主线程可以继续执行

        System.out.println("所有服务已初始化，应用程序正在启动...");

    }


    // 服务初始化任务

    staticclass ServiceInitializer implements Runnable {

        privatefinalCountDownLatch latch;

        privatefinalString serviceName;


        public ServiceInitializer(CountDownLatch latch, String serviceName) {

            this.latch = latch;

            this.serviceName = serviceName;

        }


        @Override

        publicvoid run() {

            try {

                // 模拟服务初始化的耗时操作

                Thread.sleep((long) (Math.random() * 10000));

                System.out.println(serviceName + " 初始化完成。");

            } catch (InterruptedException e) {

                e.printStackTrace();

            } finally {

                // 完成初始化后，计数器减1

                latch.countDown();

            }

        }

    }

}


```
