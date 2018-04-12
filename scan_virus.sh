#!/bin/bash
DIR="/media"
TMPDIR="${DIR}/tmp"
VERSION_YARA="3.7.1"
VERSION_MALDET="1.6.2"
URLMALDET="wget -qO- http://www.rfxn.com/downloads/maldetect-current.tar.gz"
URLYARA="wget -qO- https://github.com/VirusTotal/yara/archive/v${VERSION_YARA}.tar.gz"
TAR="tar xzv -C ${TMPDIR}"
YARA_SIG="wget http://files.xserver.ua/php/kos.yara"

version_os()
        {
                if [[ -f /etc/debian_version ]]; then
                    apt-get update && apt-get install -y automake libtool make gcc flex bison
                else
                    yum install automake libtool make gcc flex bison
                fi
        }
install_yara()
        {
                if [[ -e ${TMPDIR} ]]; then
                        echo "Download YARA"
                        version_os
                        cd ${TMPDIR} && ${URLYARA} | ${TAR} && cd yara-${VERSION_YARA}
                        ./bootstrap.sh && ./configure
                        make && make install && make check
                        cd ${DIR}  && rm -rfv ${TMPDIR} && ${YARA_SIG}
                else
                        echo "$DIR exist, created"
                        mkdir -p ${TMPDIR}
                        install_yara
                fi
        }

install_maldet()
        {
                if [[ -e ${TMPDIR} ]]; then
                        echo "Download YARA"
                        cd ${TMPDIR} && ${URLMALDET} | ${TAR} && cd maldetect-${VERSION_MALDET} && ./install.sh
                        rm -rfv ${TMPDIR}
                else
                        echo "$DIR exist, created"
                        mkdir -p ${TMPDIR}
                        install_maldet
                fi
        }
scan_yara()
        {
                if [[  -z $(which yara) ]];then
                    echo "Yara not found, please run install_yara"
                    exit 0
                fi
                if [[ -d $2 ]]; then
                        echo "Find $2, start scaning"
                        $(which yara) -r ${DIR}/kos.yara $2
                 else
                        echo "Not found directory $2"
                        exit $?
                fi
        }
scan_maldet()
        {
                if [[ -z $(which maldet) ]]; then
                    echo "Maldet not found, please run install_maldet"
                fi
                if [[ -d $2 ]]; then
                    echo "Find $2, start scaning"
                    $(which maldet) -a $2
                else
                    echo "Not found directory $2"
                    exit $2
                fi
        }
find_log()
        {
            if [[ -n $(netstat -tulpan | grep 1500) && -n $(pidof nginx) ]]; then
                grep -ri access_log /etc/nginx | awk {'print $3'} | cut -d\; -f 1| grep $1.access.log |tail -n 1
            elif [[ -d /etc/apache2  ]]; then
                grep -ri CustomLog /etc/apache2 | awk {'print $3'} | grep $1.access.log |tail -n 1
            else
                grep -ri CustomLog /etc/httpd | awk {'print $3'} | grep $1.access.log |tail -n 1
            fi
            if [[ -n $(netstat -tulpan | grep 8083) && -n $(pidof nginx) && -z $(ls /var/log/nginx/domains) ]]; then
                grep -ri -E "(CustomLog|access_log)" /home/*/conf/web | awk {'print $3'} | grep $1.log |tail -n 1
            fi
        }
scan_log()
        {
            echo "Scaning $(find_log $*)"
            grep POST $(find_log $*)| awk -F\"  '$3 ~ /200/ {print $2}' | sort -n | uniq -c |sort -rn | head -n100
        }
case $1 in
        --install_maldet) install_maldet
        ;;
        --install_yara) install_yara
        ;;
        --scan_yara) scan_yara $*
        ;;
        --scan_maldet) scan_maldet $*
        ;;
        --scan_log) scan_log $2
        ;;
        --help)
        echo "Scans for viruses and malware."
        echo "Options:"
        echo "--install_maldet		Install Maldetect."
        echo "--install_yara		Install Yara."
        echo "--scan_yara		Scans the selected directory. Example: ./scan_virus --scan_yara /path/to/directory"
        echo "--scan_maldet		Scans the selected directory. Example: ./scan_virus --scan_maldet /path/to/directory"
        echo "--scan_log		Scans log files for POST requests. Example: ./scan_virus --scan_log google.com"
        ;;
        *)
        echo "Enter options --help"
        exit 1
        ;;
esac
