在Linux下编译梅林版REDSOCKS2
===
该文是我在摸索学习编译REDSOCKS2过程中整理，在此与大家一起分享~<br>
REDSOCKS2软件的介绍，请参考[REDSOCKS2主页](https://github.com/semigodking/redsocks/)
#1、配置编译环境
因为我们需要在linux下编译能在路由器上运行的程序，所以需要的是merlin的交叉编译工具链（toolchain）。<br>
我直接把merlin源码下载到/work/目录下，里面有交叉编译工具链<br>
```
cd /home
git clone https://github.com/RMerl/asuswrt-merlin.git
```
源码包有些大，下载需要等一段时间！下载完成后在/work/asuswrt-merlin/release目录下，就能找到
src-rt-6.x.4708和src-rt-6.x这两个目录，前者对应的是ARM架构的路由器，如RT-AC56U, RT-AC68U,
RT-AC87U等机器，后者对应的是MIPSEL架构的路由器，如RT-AC66U。<br>
本文以MIPSEL下的交叉编译为例，进行Redsock2 的编译
