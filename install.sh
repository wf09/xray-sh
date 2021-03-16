#!/bin/bash
check_root(){
    if [[ "$EUID" -ne '0' ]]; then
        echo "error: You must run this script as root!"
        exit 1
    fi
}
check_system_and_install_deps(){
    if [[ "$(type -P apt)" ]]; then
        apt update
        apt install wget curl unzip ca-certificates -y 
    elif [[ "$(type -P yum)" ]]; then
        yum update -y
        yum install wget curl unzip ca-certificates -y 
    fi
}
install_bin(){
  XRAY_FILE="Xray-linux-${arch}.zip"
	echo "Downloading binary file: ${XRAY_FILE}"
  if [ "$mirror" = "github" ]; then
      echo $mirror
      XRAY_BIN_URL="https://github.com/wf09/Xray-release/raw/master/${XRAY_FILE}"
  else
      XRAY_BIN_URL="https://cdn.jsdelivr.net/gh/wf09/Xray-release/${XRAY_FILE}"
  fi

	wget -qO ${PWD}/Xray.zip $XRAY_BIN_URL --progress=bar:force
    unzip -d /tmp/Xray Xray.zip
    chmod +x /tmp/Xray/xray
    mv /tmp/Xray/xray /usr/local/bin/xray
    rm -rf Xray.zip /tmp/Xray


    echo "${XRAY_FILE} has been downloaded" 
}

install_dat(){
	wget -qO /usr/local/bin/geoip.dat https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat
	wget -qO /usr/local/bin/geosite.dat https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat
	echo ".dat has been downloaded!"
}
install_service(){
  if [ ! -f /etc/systemd/system/xray.service ];then
      cat << EOF > /etc/systemd/system/xray.service
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target
[Service]
User=root
ExecStart=/usr/local/bin/xray
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
EOF
  fi
  echo "Enable xray service.."
  systemctl enable xray.service

  echo "Please after install /usr/local/bin/config.json"
  echo "Please run \"systemctl start xray.service\" to start service"

}

func(){
  echo "Usage:"
  echo "install [-m mirror] [-a arch] [-i install] [-u update]"
  echo "Description:"
  echo "-m, --mirror: mirror of github or cloudflare" 
  echo "-a, --arch: amd64, arm64-v8a or anything else"
  echo "-i, --install: install xray"
  echo "-u, --update: update xray"
  exit -1
}

update_xray(){
  echo "You are updating xray.."
  check_root
  install_bin
  install_dat
  service xray restart
}

install_xray(){
  echo "You are installing xray.."
  check_root
  check_system_and_install_deps
  install_bin
  install_dat
  install_service
}

while [ -n "$1" ]  
do  
  case "$1" in   
    --mirror)
        mirror=$2
        shift 
        ;;  
    --arch)  
        arch=$2
        shift   
        ;;  
    --install)
      install="1"
        ;;  
    --update)
      update="1"
        ;;
    --help,-h)
        func
        ;; 
    *)  
        echo "Please run ./install --help to get some help."
        exit 0  
        ;;  
  esac  
  shift  
done

while [ -n "$1" ]  
do  
  case "$1" in   
    -m|--mirror)
        mirror=$2
        shift 
        ;;  
    -a|--arch)  
        arch=$2
        shift   
        ;;  
    -i|--install)
      contrl="install"
        ;;  
    -u|--update)
      contrl="update"
        ;;
    -h|--help)
        func
        ;; 
    *)  
        echo "Please run ./install --help to get some help."
        exit 0  
        ;;  
  esac  
  shift  
done

if [[ -z "$mirror" ]];then
  mirror="github"
fi
if [[ -z "$arch" ]];then
  arch="64"
fi
if [[ -z "$contrl" ]];then
  contrl="install"
fi

if [[ $contrl = "install" ]];then
  install_xray
elif [[ $contrl = "update" ]];then
  update_xray
fi