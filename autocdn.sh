#!/bin/bash
#

function _colors(){
    red=$(tput setaf 1)          ; green=$(tput setaf 2)        ; yellow=$(tput setaf 3)  ; bold=$(tput bold)
    magenta=$(tput setaf 5)      ; cyan=$(tput setaf 6)         ; white=$(tput setaf 7)   ; normal=$(tput sgr0)
    on_red=$(tput setab 1)       ; on_magenta=$(tput setab 5)   ; on_cyan=$(tput setab 6) ; shanshuo=$(tput blink)
    baiqingse=${white}${on_cyan} ; baihongse=${white}${on_red}  ; baizise=${white}${on_magenta} ;
}
_colors

function inexistence_qb_fg() {
  echo -ne "${bold}${yellow}跑完会自动重启${normal}"
  #星菊脚本安装qb和flexget
  bash <(wget --no-check-certificate -qO- https://github.com/Aniverse/inexistence/raw/master/inexistence.sh)  -u r21cdn -p r21cdnvcbs --apt-no --qb 4.1.9 --de No --lt RC_1_1 --rt No --tr No --rdp-no --wine-no --tools-no --flexget-yes --rclone-no --bbr-yes --tweaks-yes -y ;
}

function configuration_qb_fg() {
  echo -ne "${bold}${yellow}请输入你的r21 passkey${normal}: " ; read -e Passkey
  #配置qb
  cat > /home/r21cdn/.config/qBittorrent/qBittorrent.conf << 'EOF'
[Application]
FileLogger\Age=6
FileLogger\AgeType=1
FileLogger\Backup=true
FileLogger\DeleteOld=true
FileLogger\Enabled=true
FileLogger\MaxSize=20
FileLogger\Path=/home/r21cdn/.config/qBittorrent

[AutoRun]
enabled=false
program=

[BitTorrent]
Session\AsyncIOThreadsCount=8
Session\BTProtocol=TCP
Session\CreateTorrentSubfolder=true
Session\DisableAutoTMMByDefault=true
Session\DisableAutoTMMTriggers\CategoryChanged=false
Session\DisableAutoTMMTriggers\CategorySavePathChanged=true
Session\DisableAutoTMMTriggers\DefaultSavePathChanged=true
Session\MultiConnectionsPerIp=true
Session\SendBufferLowWatermark=1024
Session\SendBufferWatermark=3072
Session\SendBufferWatermarkFactor=250

[Core]
AutoDeleteAddedTorrentFile=Never

[LegalNotice]
Accepted=true

[Preferences]
Bittorrent\AddTrackers=false
Bittorrent\DHT=true
Bittorrent\Encryption=0
Bittorrent\LSD=true
Bittorrent\MaxConnecs=-1
Bittorrent\MaxConnecsPerTorrent=-1
Bittorrent\MaxRatioAction=0
Bittorrent\PeX=true
Bittorrent\uTP=false
Bittorrent\uTP_rate_limited=true
Connection\GlobalDLLimit=30000
Connection\GlobalDLLimitAlt=0
Connection\GlobalUPLimitAlt=0
Connection\PortRangeMin=13719
Downloads\DiskWriteCacheSize=1024
Downloads\DiskWriteCacheTTL=5
Downloads\PreAllocation=false
Downloads\SavePath=/home/r21cdn/data/
Downloads\ScanDirsV2=@Variant(\0\0\0\x1c\0\0\0\0)
Downloads\StartInPause=false
Downloads\TorrentExportDir=/home/r21cdn/qbittorrent/torrent
DynDNS\DomainName=changeme.dyndns.org
DynDNS\Enabled=false
DynDNS\Password=
DynDNS\Service=0
DynDNS\Username=
General\Locale=zh
General\UseRandomPort=true
MailNotification\email=
MailNotification\enabled=false
MailNotification\password=j7cd2qt5
MailNotification\req_auth=true
MailNotification\req_ssl=false
MailNotification\sender=qBittorrent_notification@example.com
MailNotification\smtp_server=smtp.changeme.com
MailNotification\username=r21cdn
Queueing\IgnoreSlowTorrents=true
Queueing\MaxActiveDownloads=1
Queueing\MaxActiveTorrents=-1
Queueing\MaxActiveUploads=-1
Queueing\QueueingEnabled=true
WebUI\Address=*
WebUI\AlternativeUIEnabled=false
WebUI\AuthSubnetWhitelist=@Invalid()
WebUI\AuthSubnetWhitelistEnabled=false
WebUI\CSRFProtection=false
WebUI\ClickjackingProtection=true
WebUI\HTTPS\Enabled=false
WebUI\HostHeaderValidation=true
WebUI\LocalHostAuth=false
WebUI\Password_ha1=@ByteArray(01d4992343cfe863751df655bc0a518a)
WebUI\Port=2017
WebUI\RootFolder=
WebUI\ServerDomains=*
WebUI\UseUPnP=true
WebUI\Username=r21cdn
EOF
  service qbittorrent@r21cdn restart
  #配置flexget
  cat > /root/.config/flexget/config.yml << 'EOF'
tasks:
  r21:
    limit:
      amount: 7
      from:
        rss: https://share.acgnx.se/rss.xml?keyword=vcb-s
    accept_all: yes
    add_trackers:
      - https://r21.3333.moe/announce/Passkey
      - http://208.67.16.113:8000/annonuce
      - udp://208.67.16.113:8000/annonuce
      - udp://tracker.openbittorrent.com:80/announce
      - http://t.acg.rip:6699/announce
      - http://nyaa.tracker.wf:7777/announce
      - https://tr.bangumi.moe:9696/announce
      - http://tr.bangumi.moe:6969/announce
      - udp://tr.bangumi.moe:6969/announce
      - https://open.acgnxtracker.com/announce
    qbittorrent:
      host: localhost
      port: 2017
      username: r21cdn
      password: r21cdnvcbs
      label: r21-vcbs
web_server:
  port: 6566
  web_ui: yes
schedules:
  - tasks: [r21]
    schedule:
      minute: " */3 "
EOF
  sed -i "s/Passkey/$Passkey/g" /root/.config/flexget/config.yml
  service flexget restart ;
}

function art(){
  echo -ne "${bold}${yellow}请输入你希望用于分流的做种大小(GB)${normal}: " ; read -e CDNSize
  while [ -z "$(echo $CDNSize| sed -n "/^[0-9]\+$/p")" ]; do
    echo -ne "${bold}${yellow}你好？这里要输入数字的。${normal}"
    echo -e "${bold}${yellow}请输入你希望用于分流的做种大小(GB)${normal}: " ; read -e CDNSize
  done
  #安装autoremove-torrents
  pip install autoremove-torrents
  #配置autoremove-torrents
  mkdir -p ~/.config/autoremove-torrents
  mkdir -p ~/.config/autoremove-torrents/logs
  touch ~/.config/autoremove-torrents/config.yml
  if [[ $CDNSize != 0 ]]; then
    cat > /root/.config/autoremove-torrents/config.yml << 'EOF'
AutoCDN:
  client: qbittorrent
  host: http://127.0.0.1:2017
  username: r21cdn
  password: r21cdnvcbs
  strategies:
    strategy1:
      all_status: true
      categories: r21-vcbs
      seed_size:
        limit: CDNSize
        action: remove-old-seeds
  delete_data: true
EOF
  sed -i "s/CDNSize/$CDNSize/g" /root/.config/autoremove-torrents/config.yml
    crontab -l > /root/now.cron
    cat >> /root/now.cron << EOF
*/1 * * * * /usr/local/bin/autoremove-torrents --conf="/root/.config/autoremove-torrents/config.yml" --log="/root/.config/autoremove-torrents/logs"
EOF
    crontab /root/now.cron
    rm -rf /root/now.crom
  fi
  echo ;
}

client_location=$( command -v qbittorrent-nox )
echo -e "${green}00)${normal} 退出"
echo -e "${green}01)${normal} 安装qBittorrent和flexget"
if [[ -a $client_location ]]; then
  echo -e "${green}02)${normal} 配置qBittorrent和flexget"
  echo -e "${green}03)${normal} 安装并配置autoremove-torrents"
fi
echo -ne "${bold}${yellow}请输入操作选项${normal} (Default ${cyan}00${normal}): " ; read -e responce
case $responce in
    01 | 1     ) inexistence_qb_fg                 ;;
    02 | 2     ) configuration_qb_fg ;;
    03 | 3     ) art ;;
    00 | 0 | "") echo                                                                                               ;;
    *          ) echo                 ;;
esac
