#!/bin/bash
# ###########################################
# SCRIPT : DOWNLOAD AND INSTALL E2IPLAYER_TSiplayer
# ###########################################
#
# Command: wget -q "--no-check-certificate" https://raw.githubusercontent.com/emil237/E2IPLAYER_TSiplayer/main/e2iplayer.sh -O - | /bin/sh
#
# ###########################################
versions="25.06.2022"
###########################################
# Configure where we can find things here #
TMPDIR='/tmp'
PLUGINPATH='/usr/lib/enigma2/python/Plugins/Extensions/IPTVPlayer'
SETTINGS='/etc/enigma2/settings'
URL='https://raw.githubusercontent.com/emil237/E2IPLAYER_TSiplayer/main'
#PYTHON_VERSION=$(python -c"import sys; print(sys.hexversion)")
PYTHON_VERSION=$(python -c"import platform; print(platform.python_version())")
# FILE=/usr/lib/enigma2/python/Components/
# PY=Input.pyc
# SPA=/usr/bin/OpenSPA.info

#########################
VERSION=VERSION=$(wget $MY_URL/version -qO- | cut -d "=" -f2-)
########################
if [ -f /etc/opkg/opkg.conf ]; then
    STATUS='/var/lib/opkg/status'
    OSTYPE='Opensource'
    OPKG='opkg update'
    OPKGINSTAL='opkg install'
elif [ -f /etc/apt/apt.conf ]; then
    STATUS='/var/lib/dpkg/status'
    OSTYPE='DreamOS'
    OPKG='apt-get update'
    OPKGINSTAL='apt-get install'
fi

#########################
if [ "$PYTHON_VERSION" == 3.9.9 -o "$PYTHON_VERSION" == 3.9.7 ]; then
    echo ":You have $PYTHON_VERSION image ..."
    PLUGINPY3='E2IPLAYER_TSiplayer-PYTHON3.tar.gz'
    rm -rf ${TMPDIR}/"${PLUGINPY3:?}"
elif [ "$PYTHON_VERSION" == 3.8.5 ]; then
    echo ":You have $PYTHON_VERSION image ..."
    PLUGINPY5='E2IPLAYER_TSiplayer-py3.8.5-openspa.tar.gz'
    rm -rf ${TMPDIR}/"${PLUGINPY5:?}"    
elif [ "$PYTHON_VERSION" == 3.10.4 ]; then
    echo ":You have $PYTHON_VERSION image ..."
    PLUGINPY4='E2IPLAYER_TSiplayer-PYTHON310.tar.gz'
    rm -rf ${TMPDIR}/"${PLUGINPY4:?}"
else
    echo ":You have $PYTHON_VERSION image ..."
    PLUGINPY2='E2IPLAYER_TSiplayer.tar.gz'
    rm -rf ${TMPDIR}/"${PLUGINPY2:?}"
fi

#########################
case $(uname -m) in
armv7l*) plarform="armv7" ;;
mips*) plarform="mipsel" ;;
aarch64*) plarform="ARCH64" ;;
sh4*) plarform="sh4" ;;
esac

#########################
rm -rf ${PLUGINPATH}
rm -rf /etc/enigma2/iptvplaye*.json
rm -rf /etc/tsiplayer_xtream.conf
rm -rf /iptvplayer_rootfs
rm -rf /usr/lib/enigma2/python/Components/Input.py

#########################
install() {
    if grep -qs "Package: $1" $STATUS; then
        echo
    else
        $OPKG >/dev/null 2>&1
        echo "   >>>>   Need to install $1   <<<<"
        echo
        if [ $OSTYPE = "Opensource" ]; then
            $OPKGINSTAL "$1"
            sleep 1
            clear
        elif [ $OSTYPE = "DreamOS" ]; then
            $OPKGINSTAL "$1" -y
            sleep 1
            clear
        fi
    fi
}

#########################
if [ "$PYTHON_VERSION" == 3.9.9 -o "$PYTHON_VERSION" == 3.9.7 -o "$PYTHON_VERSION" == 3.8.5 ] || [ "$PYTHON_VERSION" == 3.10.4 ]; then
    for i in duktape wget python3-sqlite3; do
        install $i
    done
else
    for i in duktape wget python-sqlite3; do
        install $i
    done
fi

#########################
clear

if [ "$PYTHON_VERSION" == 3.9.9 -o "$PYTHON_VERSION" == 3.9.7 ]; then
    #set -e
    echo "Downloading And Insallling IPTVPlayer-$PYTHON_VERSION plugin Please Wait ......"
    echo
    wget --show-progress $URL/$PLUGINPY3 -qP $TMPDIR
    tar -xzf $TMPDIR/$PLUGINPY3 --warning=no-timestamp -C /
    # if [ -f "$SPA" ]; then
    #     cd $FILE
    #     rm $PY
    # fi     
    #set +e
elif [ "$PYTHON_VERSION" == 3.8.5 ]; then
    #set -e
    echo "Downloading And Insallling IPTVPlayer-$PYTHON_VERSION plugin Please Wait ......"
    echo
    wget --show-progress $URL/$PLUGINPY5 -qP $TMPDIR
    tar -xzf $TMPDIR/$PLUGINPY5 --warning=no-timestamp -C /    
elif [ "$PYTHON_VERSION" == 3.10.4 ]; then
    #set -e
    echo "Downloading And Insallling IPTVPlayer-$PYTHON_VERSION plugin Please Wait ......"
    echo
    wget --show-progress $URL/$PLUGINPY4 -qP $TMPDIR
    tar -xzf $TMPDIR/$PLUGINPY4 --warning=no-timestamp -C /
    #set +e
else
    #set -e
    echo "Downloading And Insallling IPTVPlayer-$PYTHON_VERSION plugin Please Wait ......"
    echo
    wget --show-progress $URL/$PLUGINPY2 -qP $TMPDIR
    tar -xzf $TMPDIR/$PLUGINPY2 --warning=no-timestamp -C /
    #set +e
fi

#########################
if [ -d $PLUGINPATH ]; then
    echo ":Your Device IS $(uname -m) processor ..."
    echo "Add Setting To ${SETTINGS} ..."
    init 4
    sleep 2
    sed -e s/config.plugins.iptvplayer.*//g -i ${SETTINGS}
    sleep 1
    {
        echo "config.plugins.iptvplayer.AktualizacjaWmenu=false"
        echo "config.plugins.iptvplayer.SciezkaCache=/etc/IPTVCache/"
        echo "config.plugins.iptvplayer.alternative${plarform^^}MoviePlayer=extgstplayer"
        echo "config.plugins.iptvplayer.alternative${plarform^^}MoviePlayer0=extgstplayer"
        echo "config.plugins.iptvplayer.buforowanie_m3u8=false"
        echo "config.plugins.iptvplayer.default${plarform^^}MoviePlayer=exteplayer"
        echo "config.plugins.iptvplayer.default${plarform^^}MoviePlayer0=exteplayer"
        echo "config.plugins.iptvplayer.remember_last_position=true"
        echo "config.plugins.iptvplayer.extplayer_skin=red"
        echo "config.plugins.iptvplayer.extplayer_infobanner_clockformat=24"       
        echo "config.plugins.iptvplayer.plarform=${plarform}"
        echo "config.plugins.iptvplayer.dukpath=/usr/bin/duk"
        echo "config.plugins.iptvplayer.wgetpath=wget"        
    } >>${SETTINGS}
fi

#########################
if [ "$PYTHON_VERSION" == 3.9.9 -o "$PYTHON_VERSION" == 3.9.7 ]; then
    rm -rf ${TMPDIR}/"${PLUGINPY3:?}"
elif [ "$PYTHON_VERSION" == 3.8.5 ]; then
    rm -rf ${TMPDIR}/"${PLUGINPY5:?}"    
elif [ "$PYTHON_VERSION" == 3.10.4 ]; then
    rm -rf ${TMPDIR}/"${PLUGINPY4:?}"
else
    rm -rf ${TMPDIR}/"${PLUGINPY2:?}"
fi
sync
echo ""
echo "***********************************************************************"
echo "**                                                                    *"
echo "**                       TSIPlayer  : $VERSION                      *"
echo "**                       Uploaded by: LINUXSAT                        *"
echo "**                                                                    *"
echo "***********************************************************************"
echo ""
if [ $OSTYPE = "DreamOS" ]; then
    sleep 2
    systemctl restart enigma2
else
    enit 4
   sleep ;4
    init 3
fi
exit 0
