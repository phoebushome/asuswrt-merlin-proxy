使用 Asus Merlin 实现路由器科学上网
======
#前置条件<br>
	1. 你有一台刷上 Asus Merlin 固件并能支持 USB 扩展的路由器
	2. 你已经有一台海外 VPS，并已经运行 Shadowsocks 服务端
	3. 基础的 ssh 或 telnet 知识，基础的命令行知识

#解决DNS污染<br>
##思路：
国内的 DNS 服务器在解析被墙网站时，返回的 IP 基本上是不能正常访问的，实时更新被墙网站的列表非常麻烦。<br>
所有的国外网站的 DNS 解析，转发到 VPS 上去做。<br>
国内网站的 DNS 解析，直接放行。<br>
##解决方法：
Asus Merlin 中内置了 dnsmasq，可以用来指定特定的域名走特定的 DNS 服务器进行解析。所以剩下的问题是如何区分国内和国外的域名。<br>
我使用的 [dnsmasq-china-list](https://github.com/felixonmars/dnsmasq-china-list) 提供的中国网站列表。
dnsmasq-china-list 项目提供了三个 dnsmasq 的配置文件：
	1. accelerated-domains.china.conf
这个文件里面存放了绝大部分中国网站的域名，并使 dnsmasq 对这些域名使用 114.114.114.114 公共 DNS 进行解析。
	2. bogus-nxdomain.china.conf
这个文件存放了一些 IP，表示当远程 DNS 服务器返回这些 IP 时，dnsmasq 将其当作解析失败来处理。原因是一些运营商对一些不存在的域名做解析时，没有正常地返回域名不存在的错误，而是返回了自己的一些广告网站的 IP。
	3. google.china.conf
加速 Google 服务，我不太关心这个，没细看。


下载accelerated-domains.china.conf<br>
`
wget -c -O ./accelerated-domains.china.conf https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf
`
对于 accelerated-domains.china.conf 文件，它使用了 114.114.114.114 公共 DNS 做解析。我觉得对于国内的域名，走运营商自己提供的 DNS 服务器会更好，于是执行了下面的命令，把这个文件中的 DNS 服务器换成默认的：<br>
`
sed -i "s|^\(server.*\)/[^/]*$|\1/#|" ./accelerated-domains.china.conf
`
然后，生成一个文件告诉 dnsmasq 除了国内的域名，其他的走之前 ss-tunnel 绑定的端口(7913)，转发到 VPS 上走 Google 的 8.8.8.8 DNS 服务器。<br>
`
echo server=/#/127.0.0.1#7913 > foreign-domains.conf
`
然后我们要把这个配置文件让 dnsmasq 感知到。这里使用 Asus Merlin 提供的 Custom config files 能力，将一条配置加入 dnsmasq.conf 中：
mkdir /jffs/dnsmasq-conf
cp ./accelerated-domains.china.conf /jffs/dnsmasq-conf
cp ./foreign-domains.conf /jffs/dnsmasq-conf
echo conf-dir=/jffs/dnsmasq-conf > /jffs/configs/dnsmasq.conf.add

#VPN设置
##使用 bestroutetb 生成国内 IP 段的 iptables
**注**：使用bestroutetb来产生iptables使用的路由表，是由于该路由表条目较少。另一个解决方案是使用上文提到的 accelerated-domains.china.conf 来生成路由表。<br>
[bestroutetb](https://github.com/ashi009/bestroutetb) 是个 Node.js 程序，用来获取国内 ISP 的网段并生成一些转发的规则。<br>
在本地安装bestroutetb，我使用的是mac系统，安装命令为：
`
$ brew install nodejs
#从 NPM 安装，当做命令行程序：
$ npm install -g bestroutetb
$ bestroutetb -p custom --rule-format="iptables -t nat -A SHADOWSOCKS -d %prefix/%mask -j %gw"$'\n'  --gateway.net="RETURN" -o ./iptables
$ grep RETURN ./iptables > ./iptables.china
`
**注**：上述命令运行时间较长，我将运行结果保存为iptables和iptables.china

##生成iptables
iptables 是 Linux 系统下用来做流量控制的工具。我们要用它来做实际的流量转发。
目的是实现：
	1. 到内网的流量（如 127.0.0.1, 192.168.1.*) 直连
	2. 到国内 ISP 的流量直连
	3. 到 VPS 的流量直连
	4. 其他流量都转到 VPS 上

#参考资料
[在路由器上部署 shadowsocks](https://zzz.buzz/zh/gfw/2016/02/16/deploy-shadowsocks-on-routers/)




