#!/bin/bash
# Original Author: Vicer
# Modified by Aniverse
# https://github.com/Aniverse/lotServer
#
# bash <(wget --no-check-certificate -qO- https://github.com/Aniverse/lotServer/raw/master/ls.sh) -i
#
# 2019.03.04
# 0.1.3

black=$(tput setaf 0); red=$(tput setaf 1); green=$(tput setaf 2); yellow=$(tput setaf 3);
blue=$(tput setaf 4); magenta=$(tput setaf 5); cyan=$(tput setaf 6); white=$(tput setaf 7); 
bold=$(tput bold); normal=$(tput sgr0); on_red=$(tput setab 1); on_green=$(tput setab 2)
CW="${bold}${white}${on_red} ERROR ${normal}${bold}"

[[ $EUID -ne 0 ]] && { echo "$CW This script must be run as root!${normal}" ; exit 1 ; }

function pause() { echo ; read -p "${bold}Press ${white}${on_green} Enter ${normal}${bold} to Continue ...${normal} " INP ; }

function Check() {
mkdir -p /tmp
cd /tmp
echo -e "\n${bold}Preparatory work ...${normal}\n"
apt-get >/dev/null 2>&1
[ $? -le '1' ] && apt-get -y -qq install grep unzip ethtool >/dev/null 2>&1
yum >/dev/null 2>&1
[ $? -le '1' ] && yum -y -q install which sed grep awk unzip ethtool >/dev/null 2>&1
[ -f /etc/redhat-release ] && KNA=$(awk '{print $1}' /etc/redhat-release)
[ -f /etc/os-release ] && KNA=$(awk -F'[= "]' '/PRETTY_NAME/{print $3}' /etc/os-release)
[ -f /etc/lsb-release ] && KNA=$(awk -F'[="]+' '/DISTRIB_ID/{print $2}' /etc/lsb-release)
KNB=$(getconf LONG_BIT)
ifconfig >/dev/null 2>&1
[ $? -gt '1' ] && echo -e "$CW I can not run 'ifconfig' successfully! \nPlease check your system, and try again!${normal}\n" && exit 1;
[ ! -f /proc/net/dev ] && echo -e "$CW I can not find network device!${normal}\n" && exit 1;
[ -n "$(grep 'eth0:' /proc/net/dev)" ] && Eth=eth0 || Eth=`cat /proc/net/dev |awk -F: 'function trim(str){sub(/^[ \t]*/,"",str); sub(/[ \t]*$/,"",str); return str } NR>2 {print trim($1)}'  |grep -Ev '^lo|^sit|^stf|^gif|^dummy|^vmnet|^vir|^gre|^ipip|^ppp|^bond|^tun|^tap|^ip6gre|^ip6tnl|^teql|^venet' |awk 'NR==1 {print $0}'`
[ -z "$Eth" ] && echo -e "$CW I can not find the server pubilc Ethernet!${normal}\n" && exit 1
URLKernel='https://raw.githubusercontent.com/MoeClub/lotServer/master/lotServer.log'
AcceVer=$(wget --no-check-certificate -qO- "$URLKernel" |grep "$KNA/" |grep "/x$KNB/" |grep "/$KNK/" |awk -F'/' '{print $NF}' |sort -n -k 2 -t '_' |tail -n 1)
MyKernel=$(wget --no-check-certificate -qO- "$URLKernel" |grep "$KNA/" |grep "/x$KNB/" |grep "/$KNK/" |grep "$AcceVer" |tail -n 1)
[ -z "$MyKernel" ] && echo -e "$CW Kernel not be matched, you should change kernel manually and try again! \n\nView the link to get detaits: \n${green}$URLKernel ${normal}\n\n\n" && exit 1 ; }

function Install() {
pause
Check
lotServer
Lic
update-rc.d -f lotServer remove >/dev/null 2>&1
update-rc.d lotServer defaults >/dev/null 2>&1
/etc/init.d/lotServer start
clear
echo -e "${bold}${white}$(tput setab 0)[Running Kernel]${normal}\nKernel               $KNK\n"
/etc/init.d/lotServer status
# [[ $(ps aux | grep appex | grep -v grep) ]] && echo -e "\n${bold}${green}LotServer is running ...${normal}\n" || echo -e "\n${bold}${red}LotServer is NOT running${normal}\n"
echo ; exit 0 ; }

function Uninstall() {
pause
chattr -R -i /appex >/dev/null 2>&1
[ -d /etc/rc.d ] && rm -rf /etc/rc.d/init.d/serverSpeeder >/dev/null 2>&1
[ -d /etc/rc.d ] && rm -rf /etc/rc.d/rc*.d/*serverSpeeder >/dev/null 2>&1
[ -d /etc/rc.d ] && rm -rf /etc/rc.d/init.d/lotServer >/dev/null 2>&1
[ -d /etc/rc.d ] && rm -rf /etc/rc.d/rc*.d/*lotServer >/dev/null 2>&1
[ -d /etc/init.d ] && rm -rf /etc/init.d/serverSpeeder >/dev/null 2>&1
[ -d /etc/init.d ] && rm -rf /etc/rc*.d/*serverSpeeder >/dev/null 2>&1
[ -d /etc/init.d ] && rm -rf /etc/init.d/lotServer >/dev/null 2>&1
[ -d /etc/init.d ] && rm -rf /etc/rc*.d/*lotServer >/dev/null 2>&1
rm -rf /etc/lotServer.conf >/dev/null 2>&1
rm -rf /etc/serverSpeeder.conf >/dev/null 2>&1
[ -f /appex/bin/lotServer.sh ] && bash /appex/bin/lotServer.sh uninstall -f >/dev/null 2>&1
[ -f /appex/bin/serverSpeeder.sh ] && bash /appex/bin/serverSpeeder.sh uninstall -f >/dev/null 2>&1
rm -rf /appex >/dev/null 2>&1
rm -rf /tmp/appex* >/dev/null 2>&1
echo -e "\n${bold}lotServer has been removed!${normal} \n"
exit 0 ; }

function Lic() {
wget --no-check-certificate https://raw.githubusercontent.com/Aniverse/lotServer/master/lotCheck.sh -qO lotCheck.sh
chmod +x lotCheck.sh
SERIAL_NUM=$(./lotCheck.sh | grep Serial | awk '{print $NF}')
[ -z "$SERIAL_NUM" ] && Uninstall && echo "$CW I can not get serial number!\n" && exit 1
wget --no-check-certificate https://lotserver.tty1.dev/20991231/$SERIAL_NUM -O /appex/etc/apx.lic
[ "$(du -b /appex/etc/apx.lic | awk '{ print $1 }')" -ne 160 ] && Uninstall && echo -e "$CW I can not generate the Lic!${normal}\n" && exit 1
rm -f lotCheck.sh
[ -n $(which ethtool) ] && rm -rf /appex/bin/ethtool && cp -f $(which ethtool) /appex/bin ; }

function lotServer() {
# Get lotServer
mkdir -p /appex/etc /appex/bin
chattr -R -i /appex >/dev/null 2>&1
wget --no-check-certificate -qO /tmp/lotServer.zip 'https://raw.githubusercontent.com/Aniverse/lotServer/master/lotServer.zip'
unzip -o -qq -d /tmp/appex /tmp/lotServer.zip
sed -i '/^# Set acc inf/,$d' /tmp/appex/install.sh
echo -e 'boot=y && addStartUpLink' >> /tmp/appex/install.sh
bash /tmp/appex/install.sh
rm -rf /tmp/appex /tmp/lotServer.zip
# Get proper binary
KNN=$(echo $MyKernel | awk -F '/' '{ print $2 }') && [ -z "$KNN" ] && Uninstall && echo -e "$CW KNN not matched!${normal}\n" && exit 1
KNV=$(echo $MyKernel | awk -F '/' '{ print $5 }') && [ -z "$KNV" ] && Uninstall && echo -e "$CW KNV not matched!${normal}\n" && exit 1
wget --no-check-certificate -qO "/appex/bin/acce-"$KNV"-["$KNA"_"$KNN"_"$KNK"]" "https://raw.githubusercontent.com/Aniverse/lotServer/master/$MyKernel"
[ ! -f "/appex/bin/acce-"$KNV"-["$KNA"_"$KNN"_"$KNK"]" ] && Uninstall && echo -e "$CW Failed to download acce-$KNV-[$KNA_$KNN_$KNK]!${normal}\n" && exit 1
# Other work
APXEXE=$(ls -1 /appex/bin |grep 'acce-')
sed -i "s/^apxexe\=.*/apxexe\=\"\/appex\/bin\/$APXEXE\"/" /appex/etc/config
sed -i "s/^accif\=.*/accif\=\"$Eth\"/" /appex/etc/config
chmod -R a+x /appex
ln -sf /appex/bin/lotServer.sh /etc/init.d/lotServer ; }

[ $# == '1' ] && [ "$1" == 'i' ] && KNK="$(uname -r)" && Install
[ $# == '1' ] && [ "$1" == 'u' ] && Uninstall
[ $# == '2' ] && [ "$1" == 'i' ] && KNK="$2" && Install
echo -ne "Usage:\n     bash $0 [i | u | i '{lotServer of kernel version}']\n"
