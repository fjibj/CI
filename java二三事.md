1. java内存模型？

Java内存模型定义了多线程之间共享变量的可见性以及如何在需要的时候对共享变量进行同步。

Java线程之间的通信采用的是过共享内存模型，这里提到的共享内存模型指的就是Java内存模型(简称JMM)，JMM决定一个线程对共享变量的写入何时对另一个线程可见。从抽象的角度来看，JMM定义了线程和主内存之间的抽象关系：线程之间的共享变量存储在主内存（main memory）中，每个线程都有一个私有的本地内存（local memory），本地内存中存储了该线程以读/写共享变量的副本。本地内存是JMM的一个抽象概念，并不真实存在。它涵盖了缓存，写缓冲区，寄存器以及其他的硬件和编译器优化。
在JVM内部，Java内存模型把内存分成了两部分：线程栈区和堆区。
JVM中运行的每个线程都拥有自己的线程栈，线程栈包含了当前线程执行的方法调用相关信息，我们也把它称作调用栈。随着代码的不断执行，调用栈会不断变化。

线程栈还包含了当前方法的所有本地变量信息。一个线程只能读取自己的线程栈，也就是说，线程中的本地变量对其它线程是不可见的。即使两个线程执行的是同一段代码，它们也会各自在自己的线程栈中创建本地变量，因此，每个线程中的本地变量都会有自己的版本。

所有原始类型(boolean,byte,short,char,int,long,float,double)的本地变量都直接保存在线程栈当中，对于它们的值各个线程之间都是独立的。对于原始类型的本地变量，一个线程可以传递一个副本给另一个线程，当它们之间是无法共享的。

堆区包含了Java应用创建的所有对象信息，不管对象是哪个线程创建的，其中的对象包括原始类型的封装类（如Byte、Integer、Long等等）。不管对象是属于一个成员变量还是方法中的本地变量，它都会被存储在堆区。

一个本地变量如果是原始类型，那么它会被完全存储到栈区。 
一个本地变量也有可能是一个对象的引用，这种情况下，这个本地引用会被存储到栈中，但是对象本身仍然存储在堆区。

对于一个对象的成员方法，这些方法中包含本地变量，仍需要存储在栈区，即使它们所属的对象在堆区。 
对于一个对象的成员变量，不管它是原始类型还是包装类型，都会被存储到堆区。

Static类型的变量以及类本身相关信息都会随着类本身存储在堆区。

堆中的对象可以被多线程共享。如果一个线程获得一个对象的应用，它便可访问这个对象的成员变量。如果两个线程同时调用了同一个对象的同一个方法，那么这两个线程便可同时访问这个对象的成员变量，但是对于本地变量，每个线程都会拷贝一份到自己的线程栈中。

Java’s volatile keyword. volatile 关键字可以保证变量会直接从主存读取，而对变量的更新也会直接写到主存。volatile原理是基于CPU内存屏障指令实现的。synchronized代码块可以保证同一个时刻只能有一个线程进入代码竞争区，synchronized代码块也能保证代码块中所有变量都将会从主存中读，当线程退出代码块时，对所有变量的更新将会flush到主存，不管这些变量是不是volatile类型的。

参考: [https://blog.csdn.net/suifeng3051/article/details/52611310](https://blog.csdn.net/suifeng3051/article/details/52611310)

2  数字证书和数字签名的区别？

数字签名：将报文按双方约定的HASH算法计算得到一个固定位数的报文摘要。在数学上保证：只要改动报文中任何一位，重新计算出的报文摘要值就会与原先的值不相符。这样就保证了报文的不可更改性。将该报文摘要值用发送者的私人密钥加密，然后连同原报文一起发送给接收者，而产生的报文即称数字签名

数字证书：数字证书就是互联网通讯中标志通讯各方身份信息的一系列数据，提供了一种在Internet上验证您身份的方式，其作用类似于司机的驾驶执照或日常生活中的身份证。它是由一个由权威机构-----CA机构，又称为证书授权（Certificate Authority）中心发行的，人们可以在网上用它来识别对方的身份。数字证书是一个经证书授权中心数字签名的包含公开密钥拥有者信息以及公开密钥的文件。最简单的证书包含一个公开密钥、名称以及证书授权中心的数字签名。

数字证书就是互联网通讯中标志通讯各方身份信息的一系列数据，提供了一种在Internet上验证您身份的方式，其作用类似于司机的驾驶执照或日常生活中的身份证。它是由一个由权威机构-----CA机构，又称为证书授权（Certificate Authority）中心发行的，人们可以在网上用它来识别对方的身份。数字证书是一个经证书授权中心数字签名的包含公开密钥拥有者信息以及公开密钥的文件。最简单的证书包含一个公开密钥、名称以及证书授权中心的数字签名。

3. java线程池？

Java线程池的分析和使用 参考 [http://ifeve.com/java-threadpool/](http://ifeve.com/java-threadpool/)

4. hashmap、hashtable，以及高并发下如何提升性能？

HashMap并不是线程安全的。但再引入了CHM（ConcurrentHashMap(）之后，我们有了更好的选择。CHM不但是线程安全的，而且比HashTable和synchronizedMap的性能要好。相对于HashTable和synchronizedMap锁住了整个Map，CHM只锁住部分Map。CHM允许并发的读操作，同时通过同步锁在写操作时保持数据完整性。

5. 分布式事务的底层处理机制？

分布式事务底层原理剖析 [https://blog.csdn.net/tvwr8ofv0p/article/details/78293658](https://blog.csdn.net/tvwr8ofv0p/article/details/78293658)

6. java内存的新生代老生代的gc算法？

参考 [https://blog.csdn.net/heyutao007/article/details/38151581](https://blog.csdn.net/heyutao007/article/details/38151581)

7. 如何解决缓存的内存穿透？

缓存穿透解决方案：1. 缓存空对象 2. bloomfilter或者压缩filter(bitmap等等)提前拦截
   
参考 [http://carlosfu.iteye.com/blog/2248185](http://carlosfu.iteye.com/blog/2248185)
   
缓存穿透，缓存雪崩，缓存击穿 参考 [https://blog.csdn.net/zeb_perfect/article/details/54135506](https://blog.csdn.net/zeb_perfect/article/details/54135506)

8. hashmap什么时候会扩容？

HashMap中的变量：
Node<K,V>：链表节点，包含了key、value、hash、next指针四个元素
table：Node<K,V>类型的数组，里面的元素是链表，用于存放HashMap元素的实体
size：记录了放入HashMap的元素个数
loadFactor：负载因子
threshold：阈值，决定了HashMap何时扩容，以及扩容后的大小，一般等于table大小乘以loadFactor
HashMap使用的是懒加载，构造完HashMap对象后，只要不进行put 方法插入元素之前，HashMap并不会去初始化或者扩容table。当首次调用put方法时，HashMap会发现table为空然后调用resize方法进行初始化。当添加完元素后，如果HashMap发现size（元素总数）大于threshold（阈值），则会调用resize方法进行扩容。

参考 [https://www.cnblogs.com/KingIceMou/p/6976574.html](https://www.cnblogs.com/KingIceMou/p/6976574.html)

9. 如何提高hashmap冲突的查找效率？

为了解决在频繁冲突时hashmap性能降低的问题，Java 8中使用平衡树来替代链表存储冲突的元素。这意味着我们可以将最坏情况下的性能从O(n)提高到O(logn)。在Java 8中使用常量TREEIFY_THRESHOLD来控制是否切换到平衡树来存储。目前，这个常量值是8，这意味着当有超过8个元素的索引一样时，HashMap会使用树来存储它们。

参考 [https://blog.csdn.net/balternotz/article/details/53843001](https://blog.csdn.net/balternotz/article/details/53843001)

10. java同步锁，自旋锁？

CAS：Compare and Swap, 翻译成比较并交换。 

java.util.concurrent包中借助CAS实现了区别于synchronouse同步锁的一种乐观锁，使用这些类在多核CPU的机器上会有比较好的性能.

CAS有3个操作数，内存值V，旧的预期值A，要修改的新值B。当且仅当预期值A和内存值V相同时，将内存值V修改为B，否则什么都不做。

(1)多核cpu如何去实现“原子操作”。相关知识点：缓存行（cacheline）、CPU流水线（CPU line）
处理器保证系统从内存当中读取一个字节是原子的，意思是当一个处理器读取一个字节时，其他处理器是不能访问这个字节的地址的。最新的Intel X86能保证单处理器对同一缓存行里进行的16/32/64位操作是原子的。复杂的内存操作如跨总线宽度、跨缓存行，处理器通过总线锁定和缓存锁定来保证原子性。这两种机制Intel提供很多lock指令来实现，比如上文说的cmpxchg。

(2)JDK文档说cas同时具有volatile读和volatile写的内存语义。
针对上文说的cmpxchg指令，在多处理器下会加入LOCK前缀（LOCK  cmpxchg），单处理器会忽略LOCK前缀。
Intel对lock前缀有特殊说明：
1.根据内存区域不同提供总线锁定和缓存锁定。
2.禁止改指令与之前和之后的读指令和写指令重排序。
3.把写缓冲区的数据全部刷新到内存中。
2、3点所具有的内存屏障效果，满足了volatile读和volatile写的内存语义。

(3)CAS缺点：

问题1：ABA问题

因为CAS需要在操作值的时候检查下值有没有发生变化，如果没有发生变化则更新，但是如果一个值原来是A，变成了B，又变成了A，那么使用CAS进行检查时会发现它的值没有发生变化，但是实际上却变化了。ABA问题的解决思路就是使用版本号。在变量前面追加上版本号，每次变量更新的时候把版本号加一，那么A－B－A 就会变成1A-2B－3A。从Java1.5开始JDK的atomic包里提供了一个类AtomicStampedReference来解决ABA问题。这个类的compareAndSet方法作用是首先检查当前引用是否等于预期引用，并且当前标志是否等于预期标志，如果全部相等，则以原子方式将该引用和该标志的值设置为给定的更新值。

问题2：循环时间长开销大。

自旋CAS如果长时间不成功，会给CPU带来非常大的执行开销。如果JVM能支持处理器提供的pause指令那么效率会有一定的提升，pause指令有两个作用，第一它可以延迟流水线执行指令（de-pipeline）,使CPU不会消耗过多的执行资源，延迟的时间取决于具体实现的版本，在一些处理器上延迟时间是零。第二它可以避免在退出循环的时候因内存顺序冲突（memory order violation）而引起CPU流水线被清空（CPU pipeline flush），从而提高CPU的执行效率。

参考：[https://blog.csdn.net/bohu83/article/details/51124065](https://blog.csdn.net/bohu83/article/details/51124065)

参考：[https://blog.csdn.net/notOnlyRush/article/details/51027161](https://blog.csdn.net/notOnlyRush/article/details/51027161)

