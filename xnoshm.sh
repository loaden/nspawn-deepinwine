#!/bin/bash
# 维护：Yuchen Deng QQ群：19346666、111601117

# 确认管理员权限
if [ $UID != 0 -o "$SUDO_USER" == "root" ]; then
    echo "请先打开终端，执行 sudo -s 获得管理员权限后再运行本脚本。"
    exit 1
fi


# 禁用MIT-SHM
[[ $(machinectl list) =~ $1 ]] && machinectl stop $1
DISABLE_X_MITSHM_EXTENSION=0

if [ $DISABLE_X_MITSHM_EXTENSION == 1 ]; then
    [[ `loginctl show-session $(loginctl | grep $SUDO_USER |awk '{print $1}') -p Type` != *wayland* ]] && \
    [[ ! -f /etc/X11/xorg.conf || ! $(cat /etc/X11/xorg.conf | grep MIT-SHM) ]] && \
    echo -e 'Section "Extensions"\n    Option "MIT-SHM" "Disable"\nEndSection' >> /etc/X11/xorg.conf
    cat > /var/lib/machines/$1/disable_mitshm.sh <<EOF
    rm -f /disable_mitshm.c
    rm -f /lib32/disable_mitshm.so
    rm -f /lib64/disable_mitshm.so
    echo -e 'Section "Extensions"\n    Option "MIT-SHM" "Disable"\nEndSection' > /etc/X11/xorg.conf
EOF
else
    perl -0777 -pi -e 's/Section "Extensions"\n    Option "MIT-SHM" "Disable"\nEndSection//g' /etc/X11/xorg.conf
    [[ ! $(cat /etc/X11/xorg.conf) ]] && rm -f /etc/X11/xorg.conf
    cp -f `dirname ${BASH_SOURCE[0]}`/xnoshm.c /var/lib/machines/$1/disable_mitshm.c
    cat > /var/lib/machines/$1/disable_mitshm.sh <<EOF
    rm -f /etc/X11/xorg.conf
    rm -f /disable_mitshm.so
    if [[ ! -f /lib32/disable_mitshm.so || ! -f /lib64/disable_mitshm.so ]]; then
        dpkg --add-architecture i386
        apt update
        apt install -y gcc gcc-multilib libc6-dev libxext-dev
        gcc /disable_mitshm.c -shared -fPIC -o /lib64/disable_mitshm.so
        ls -l /lib64/disable_mitshm.so
        gcc /disable_mitshm.c -m32 -fPIC -shared -o /lib32/disable_mitshm.so
        ls -l /lib32/disable_mitshm.so
        apt purge -y gcc gcc-multilib libc6-dev libxext-dev
        apt autopurge -y
        apt clean
    fi
EOF
fi

chroot /var/lib/machines/$1/ /bin/bash /disable_mitshm.sh


# 导出SHM相关环境变量
DISABLE_MITSHM=$(bash -c 'echo -e "[[ -f /lib32/disable_mitshm.so && -f /lib64/disable_mitshm.so ]] && export LD_PRELOAD=disable_mitshm.so
export QT_X11_NO_MITSHM=1
export _X11_NO_MITSHM=1
export _MITSHM=0
"')
