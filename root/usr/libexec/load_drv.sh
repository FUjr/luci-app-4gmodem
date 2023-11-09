#!/bin/sh
. /lib/functions.sh
cfg_hash=$1
source /usr/libexec/modem/get_vendor
config_load 4gmodem
config_get reset_module $cfg_hash reset_module

idProduct=$(cat $usb_port/idProduct)
idVendor=$(cat $usb_port/idVendor)
module_load=1

driver_type(){
    port=$(basename $usb_port)
    cat ${usb_port}/${port}:1.${tty_driver_if}/uevent | grep DRIVER | cut -d "=" -f 2
}


load_tty_driver(){
    drv=$(driver_type $tty_driver_if)
    count=0
    while [ "$drv" != "$tty_driver_name" ] 
    do
        count=$(($count+1))
        logger -t 4gmodem "load driver $tty_driver_name $tty_driver_if try: $count"
        rmmod $tty_driver_name && modprobe $tty_driver_name
        drv=$(driver_type $tty_driver_if)
        sleep 5
    done
    logger -t 4gmodem "load driver $tty_driver_name $tty_driver_if success"
}

set_atport(){
    port=$(basename $usb_port)
    at_port=$( find  ${usb_port}/${port}:1.${tty_driver_if}/ -type d -maxdepth 1 -name tty* )
    at_port=$(basename $at_port)
    at_port="/dev/${at_port}"
    if [ -n "$at_port" ] && [ -e "$at_port" ]; then
        logger -t 4gmodem "set at_port $at_port"
        uci -q set 4gmodem.${cfg_hash}.at_port=$at_port
    else
        logger -t 4gmodem "at_port not found ,set to /dev/ttyUSB2"
        at_port="/dev/ttyUSB2"
        uci -q set 4gmodem.${cfg_hash}.at_port=$at_port
    fi
}

reset_module(){
    reset=$(uci -q get 4gmodem.${cfg_hash}.reset_module)
    if [ "$reset" = "1" ]; then
        logger -t 4gmodem "reset module"
        uci set 4gmodem.${cfg_hash}.reset_module=0
        uci commit 4gmodem
        /usr/libexec/modem_ctrl run_func ${cfg_hash} reset_module
    fi
}

seirra_reset(){
    while [ ! -e /tmp/sierra_boot ];do
        if [ -e $at_port ];then
            logger -t 4gmodem "sierra reset module"
            touch /tmp/sierra_boot
            logger -t 4gmodem $(gl_modem $at_port "AT+CFUN=0")
            sleep 5
            logger -t 4gmodem $(gl_modem $at_port "AT+CFUN=1")
            sleep 5
            logger -t 4gmodem $(gl_modem $at_port "AT!RESET")
        fi
    done

}

check_cfun(){
    cfun=$(gl_modem $at_port "AT+CFUN?" |grep CFUN: |grep -o "[0-9]")
    if [ "$cfun" != "1" ];then
        logger -t 4gmodem "sierra cfun not 1,reset module"
        logger -t 4gmodem $(gl_modem $at_port "AT+CFUN=1")
        sleep 5
        logger -t 4gmodem $(gl_modem $at_port "AT!RESET")
    else
        logger -t 4gmodem "sierra cfun is 1"
    fi

}

load_tty_driver
set_atport
case $idVendor in 
    '1199')
        #sierra每次开机需要重启模组
        #Sierra
        seirra_reset
        check_cfun
        ;;
    *)
        #其他模组每次恢复出厂设置需要重置模组
        #other
        reset_module
        ;;

esac
