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
    if [[ -z "$1" ]]; then
        ARCH="$1" # Only support 64bit 
    else
        ARCH="64"
    fi
    XRAY_FILE="Xray-linux-${ARCH}.zip"
	echo "Downloading binary file: ${XRAY_FILE}"

	wget -O ${PWD}/Xray.zip https://cdn.jsdelivr.net/gh/wf09/Xray-release/"${XRAY_FILE}" --progress=bar:force
    unzip -d /tmp/Xray Xray.zip
    chmod +x /tmp/Xray/xray
    mv /tmp/Xray/xray /usr/local/bin/xray
    mkdir -p /usr/local/etc/xray
    rm -rf Xray.zip /tmp/Xray

    mv fullchain.crt privkey.key /usr/local/etc/xray

    echo "${XRAY_FILE} has been downloaded" 
}

install_dat(){
	wget -O /usr/local/bin/geoip.dat https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat
	wget -O /usr/local/bin/geosite.dat https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat
	echo ".dat has been downloaded!"
}
install_config(){
    cat << EOF > /usr/local/etc/xray/config.json
{
  "log": {
    "loglevel": "warning"
  }, 
  "dns": {
    "hosts": {
      "domain:googleapis.cn": "googleapis.com"
    }, 
    "servers": [
      {
        "address": "https+local://dns.google/dns-query"
      }
    ]
  }, 
  "routing": {
    "domainStrategy": "IPIfNonMatch", 
    "rules": [
      {
        "type": "field", 
        "outboundTag": "Proxy", 
        "domain": [
          "edge.activity.windows.com",
          "www.gstatic.com"
        ]
      },
      {
        "type": "field", 
        "outboundTag": "Proxy", 
        "ip": [
          "1.1.1.1/32", 
          "1.0.0.1/32", 
          "8.8.8.8/32", 
          "8.8.4.4/32", 
          "geoip:us", 
          "geoip:ca", 
          "geoip:telegram"
        ]
      },
      {
        "type": "field", 
        "outboundTag": "Reject", 
        "domain": [
          "geosite:category-ads-all",
          "geosite:win-spy",
          "domain:netflav.com",
          "domain:jable.tv",
          "domain:f1s.app"
        ]
      },
      {
        "type": "field",
        "outboundTag": "BacktoChina",
        "ip": [
          "223.5.5.5/32",
          "119.29.29.29/32",
          "180.76.76.76/32",
          "114.114.114.114/32",
          "geoip:cn",
          "geoip:private"
        ]
      },
      {
        "type": "field",
        "outboundTag": "BacktoChina",
        "domain": [
          "geosite:private",
          "geosite:apple-cn",
          "geosite:google-cn",
          "geosite:tld-cn"
        ]
      },
      {
        "type": "field",
        "outboundTag": "Proxy",
        "domain": [
          "geosite:geolocation-!cn"
        ]
      },
      {
        "type": "field",
        "outboundTag": "BacktoChina",
        "domain": [
          "geosite:cn"
        ]
      }
    ]
  }, 
  "inbounds": [
    {
      "port": 80,
      "tag": "ws", 
      "protocol": "vless", 
      "settings": {
        "decryption": "none", 
        "clients": [
          {
            "id": "115b399e-9c7d-406e-adf9-172c965a3c54"
          }
        ]
      }, 
      "streamSettings": {
        "network": "ws", 
        "security": "none", 
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/root/fullchain.crt", 
              "keyFile": "/root/privkey.key"
            }
          ]
        }
      }
    }, 
    {
      "port": 443,
      "tag": "xtls",
      "protocol": "vless", 
      "settings": {
        "clients": [
          {
            "id": "115b399e-9c7d-406e-adf9-172c965a3c54", 
            "flow": "xtls-rprx-direct"
          }
        ], 
        "decryption": "none", 
        "fallbacks": [
          {
            "dest": 8080, 
            "xver": 1
          }
        ]
      }, 
      "streamSettings": {
        "network": "tcp", 
        "security": "xtls", 
        "xtlsSettings": {
          "alpn": [
            "http/1.1"
          ], 
          "certificates": [
            {
              "certificateFile": "/usr/local/etc/xray/fullchain.crt", 
              "keyFile": "/usr/local/etc/xray/privkey.key"
            }
          ]
        }
      }, 
      "sniffing": {
        "enabled": true, 
        "destOverride": [
          "http", 
          "tls"
        ]
      }
    }, 
    {
      "port": 8080, 
      "protocol": "vmess", 
      "settings": {
        "clients": [
          {
            "id": "115b399e-9c7d-406e-adf9-172c965a3c54",
            "alterId": 0
          }
        ]
      }, 
      "streamSettings": {
        "network": "ws", 
        "security": "none", 
        "wsSettings": {
          "path": "/php"
        }
      }
    }
  ], 
  "outbounds": [
    {
      "protocol": "freedom", 
      "tag": "Proxy"
    },
    {
      "protocol": "vless", 
      "settings": {
        "vnext": [
          {
            "address": "gdfs.ddns.cdntip.top", 
            "port": 11106, 
            "users": [
              {
                "encryption": "none", 
                "flow": "xtls-rprx-direct", 
                "id": "115b399e-9c7d-406e-adf9-172c965a3c54"
              }
            ]
          }
        ]
      }, 
      "streamSettings": {
        "network": "tcp", 
        "security": "xtls", 
        "xtlsSettings": {
          "allowInsecure": true
        }
      }, 
      "tag": "BacktoChina"
    }, 
    {
      "protocol": "blackhole", 
      "settings": {
        "response": {
          "type": "http"
        }
      }, 
      "tag": "Reject"
    }
  ]
}

EOF
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
ExecStart=/usr/local/bin/xray -config /usr/local/etc/xray/config.json
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

  echo "Please after install /usr/local/etc/xray/config.json"
  echo "Please run \"systemctl start xray.service\" to start service"

}

check_root
check_system_and_install_deps
install_bin
install_config
install_dat
install_service