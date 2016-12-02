在Linux下编译梅林版REDSOCKS2
===
该文是我在摸索学习编译REDSOCKS2过程中整理，在此与大家一起分享~<br>
REDSOCKS2软件的介绍，请参考[REDSOCKS2主页](https://github.com/semigodking/redsocks/)
#1、配置编译环境
因为我们需要在linux下编译能在路由器上运行的程序，所以需要的是merlin的交叉编译工具链（toolchain）。
我直接把merlin源码下载到/work/目录下，里面有交叉编译工具链<br>
```
cd /home
git clone https://github.com/RMerl/asuswrt-merlin.git
```
