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
    ARCH="64" # Only support 64bit 
    XRAY_FILE="Xray-linux-${ARCH}.zip"
	echo "Downloading binary file: ${XRAY_FILE}"

	wget -O ${PWD}/Xray.zip https://cdn.jsdelivr.net/gh/wf09/Xray-release/"${XRAY_FILE}" --progress=bar:force
    unzip -d /tmp/Xray Xray.zip
    chmod +x /tmp/Xray/xray
    mv /tmp/Xray/xray /usr/local/bin/xray
    mkdir /usr/local/etc/xray
    rm -rf Xray.zip /tmp/Xray

    echo "${XRAY_FILE} has been downloaded" 
}

install_dat(){
	wget -O /usr/local/bin/geoip.dat https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat
	wget -O /usr/local/bin/geosite.dat https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat
	echo ".dat has been downloaded!"
}
install_service(){
    cat << EOF > /etc/systemd/system/xray.service
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target
[Service]
User=root
ExecStart=/usr/local/bin/xray -config /usr/local/etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
EOF
    echo "Enable xray service.."
    systemctl enable xray.service

    echo "Please after install /usr/local/etc/xray/config.json"
    echo "Please run \"systemctl start xray.service\" to start service"

}

check_root
check_system_and_install_deps
install_bin
install_dat
install_service