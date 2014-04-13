PATH=$PATH:./bin;

start()
{
printf "\033c";
ssid="`NETSH WLAN SHOW INTERFACE | grep SSID | head -n1 | cut -d\: -f2`";
if [ ! "$ssid" ]; then ssid="(未连接WiFi)";fi; 
while [ ! "`echo $ssid | grep CMCC-EDU`"  ]; do 
	printf '\033c\e[1;40;37m%-6s\e[m' "当前网络:$ssid"; echo;
	printf '\e[1;40;33m%-6s\e[m' "请将wifi连接到CMCC-EDU"; 
	sleep 0.2;printf .;sleep 0.2;printf .;sleep 0.2;echo .;sleep 0.2; 
	ssid="`NETSH WLAN SHOW INTERFACE | grep SSID | head -n1 | cut -d\: -f2`";
	if [ ! "$ssid" ]; then ssid="(未连接WiFi)"; fi;  
done; 

printf "正在连接...";
str="`curl -s "wap.baidu.com" `"; 
if [ $? == 0 ]; then printf '\e[1;40;32m%-6s\e[m\n' "Ok ";fi;
if [ "`echo $str | grep CMCC-EDU`" ]; then
	echo "0" > /tmp/.sync;
	
	printf "获取IP地址...";
	while [ ! "$ip" ]; do
		ip=`ipconfig | grep "IPv4" | grep 10. | cut -d: -f2 | cut -d' ' -f2`;  sleep 0.5;
	done;
	printf '\e[1;40;32m%-6s\e[m\n' "$ip";
	
	printf '\e[1;40;37m%-6s\e[m' "正在登录...";
	while [ "`cat /tmp/.sync`" == "0" ]; do  sleep 0.5; printf ".";done &
	
	server=`echo $str | head -n2 | tail -n1 | cut -d / -f3`; 
	ac=`echo $str | head -n2 | tail -n1 | cut -d/ -f4 | cut -d\= -f2 | cut -d\& -f1`; 
	curl -sqL "http://$server/portal/servlets/BusinessLoginServlet?wlanacname=$ac&wlanuserip=$ip&ssid=CMCC520">/dev/null; 
	
	test=`curl -s "wap.baidu.com" | grep baidu`; 
	echo "1" > /tmp/.sync;

	if [ ! "$test" ]; then 
		 printf  '\e[1;40;31m%-6s\e[m' "登录失败";  
		 return 1;
	else printf  '\e[1;40;32m%-6s\e[m' "登录成功";	
	fi;

else if [ "`echo $str | grep baidu`" ]; then 
	printf  '\e[1;40;32m%-6s\e[m' "仍然在线";
fi;

fi;

sleep 2;
echo ;
}


reconCount=0;
monitor()
{
echo "开始监控";
sleep 1;
test="true";
while [ "$test" ] ; do
	printf "\033c联网监控中, 已自动重连 "; printf '\e[1;40;32m%-2s\e[m' "$reconCount"; printf "次\n";
	printf  '\e[1;40;32m%-6s\e[m' "在线";
	sleep 2;printf .;sleep 2;printf .;sleep 2;printf ".\n"; 
	test=`curl -s "wap.baidu.com" | grep baidu`; 
done;
printf "\033c联网监控中\n";
printf  '\e[1;40;31m%-6s\e[m' "已掉线，即将重新登录...";sleep 1;

reconCount=$(($reconCount+1));
}


while [ "true" ]; do 

start;
while [ $? != 0 ]; do
	printf "\n\n即将重试";
	sleep 0.8; printf .;sleep 0.8; printf .; sleep 0.8; printf .;printf "\033c";
	start;
done;
monitor;
done;