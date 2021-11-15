#!/bin/bash
# 维护：Yuchen Deng [Zz] QQ群：19346666、111601117

# 不能单独执行提醒
if [[ `basename $0` == xnoshm.sh ]]; then
    echo "'`basename $0`' 命令不能单独执行"
    exit 1
fi


# 禁用MIT-SHM
[[ $(machinectl list) =~ $1 ]] && machinectl stop $1
[[ ! $DISABLE_HOST_MITSHM ]] && DISABLE_HOST_MITSHM=0

[ -f /etc/X11/xorg.conf ] && perl -0777 -pi -e 's/Section "Extensions"\n    Option "MIT-SHM" "Disable"\nEndSection\n//g' /etc/X11/xorg.conf
[ -f /etc/X11/xorg.conf ] && [[ ! $(cat /etc/X11/xorg.conf) ]] && rm -f /etc/X11/xorg.conf

DISABLE_MIT_SHM_SH=disable-MIT-SHM.sh
DISABLE_MIT_SHM_SO=disable-MIT-SHM.so

if [[ $DISABLE_HOST_MITSHM == 1 ]]; then
    if [[ `loginctl show-session $(loginctl | grep $SUDO_USER |awk '{print $ 1}') -p Type` != *wayland* ]]; then
        mkdir -p /etc/X11/xorg.conf.d
        echo -e 'Section "Extensions"\n    Option "MIT-SHM" "Disable"\nEndSection' > /etc/X11/xorg.conf.d/disable-MIT-SHM.conf
    fi
    cat > $ROOT/$DISABLE_MIT_SHM_SH <<EOF
    /bin/rm -f /lib/i386-linux-gnu/$DISABLE_MIT_SHM_SO
    /bin/rm -f /lib/x86_64-linux-gnu/$DISABLE_MIT_SHM_SO
    /bin/mkdir -p /etc/X11/xorg.conf.d
    /bin/echo -e 'Section "Extensions"\n    Option "MIT-SHM" "Disable"\nEndSection' > /etc/X11/xorg.conf.d/disable-MIT-SHM.conf
    /bin/rm -f /etc/X11/xorg.conf
EOF
else
    rm -f /etc/X11/xorg.conf.d/disable-MIT-SHM.conf
    [[ -d /etc/X11/xorg.conf.d && `ls -A /etc/X11/xorg.conf.d |wc -w` == 0 ]] && rm -rf /etc/X11/xorg.conf.d
    cp -fp `dirname ${BASH_SOURCE[0]}`/xnoshm.c $ROOT/disable-MIT-SHM.c
    cat > $ROOT/$DISABLE_MIT_SHM_SH <<EOF
    /bin/rm -rf /etc/X11/xorg.conf.d
    /bin/rm -f /etc/X11/xorg.conf
    if [[ ! -f /lib/i386-linux-gnu/$DISABLE_MIT_SHM_SO || ! -f /lib/x86_64-linux-gnu/$DISABLE_MIT_SHM_SO
        || \$(/bin/stat -c %Y /disable-MIT-SHM.c) > \$(/bin/stat -c %Y /lib/i386-linux-gnu/$DISABLE_MIT_SHM_SO)
        || \$(/bin/stat -c %Y /disable-MIT-SHM.c) > \$(/bin/stat -c %Y /lib/x86_64-linux-gnu/$DISABLE_MIT_SHM_SO) ]]; then
        /bin/dpkg --add-architecture i386
        /bin/apt update
        /bin/apt install -y gcc gcc-multilib libc6-dev libxext-dev --no-install-recommends
        /bin/mkdir -p /lib/x86_64-linux-gnu/
        /bin/gcc /disable-MIT-SHM.c -shared -o /lib/x86_64-linux-gnu/$DISABLE_MIT_SHM_SO
        /bin/chmod u+s /lib/x86_64-linux-gnu/$DISABLE_MIT_SHM_SO
        /bin/ls -lh /lib/x86_64-linux-gnu/$DISABLE_MIT_SHM_SO
        /bin/mkdir -p /lib/i386-linux-gnu/
        /bin/gcc /disable-MIT-SHM.c -m32 -shared -o /lib/i386-linux-gnu/$DISABLE_MIT_SHM_SO
        /bin/chmod u+s /lib/i386-linux-gnu/$DISABLE_MIT_SHM_SO
        /bin/ls -lh /lib/i386-linux-gnu/$DISABLE_MIT_SHM_SO
        if [[ -f /lib/x86_64-linux-gnu/$DISABLE_MIT_SHM_SO && -f /lib/i386-linux-gnu/$DISABLE_MIT_SHM_SO ]]; then
            /bin/rm -f /disable-MIT-SHM.c
            /bin/apt purge -y gcc gcc-multilib libc6-dev libxext-dev
            /bin/apt autopurge -y
        fi
    fi
EOF
fi

chroot $ROOT /bin/bash /$DISABLE_MIT_SHM_SH


# 导出SHM相关环境变量
DISABLE_MITSHM="[[ -f /lib/x86_64-linux-gnu/$DISABLE_MIT_SHM_SO && -f /lib/i386-linux-gnu/$DISABLE_MIT_SHM_SO ]] && export LD_PRELOAD=$DISABLE_MIT_SHM_SO
export QT_X11_NO_MITSHM=1
export _X11_NO_MITSHM=1
export _MITSHM=0
"
