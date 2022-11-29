#!/bin/bash
ugr_nodes=(
    "checkout-client"
    "credit-broker"
    "dashboard"
    "deposit"
    "kassa"
    "kassa-client"
    "notifier"
    "payment-api-v3"
    "payout-api"
    "sber-pay-adapter-back"
    "sbp-adapter"
    "scrat"
    "shiro"
    "shop"
)

ugr_nodes_names=( 
    "*:frontend-checkout-client-main-*"
    "*:backend-credit-broker-main-*"
    "*:backend-dashboard-main-*"
    "*:backend-deposit-main-*"
    "*:backend-kassa-main-*"
    "*:frontend-kassa-client-main-*"
    "*:backend-notifier-main-*"
    "*:backend-payment-api-v3-main-*3"
    "*:backend-payout-api-main-*"
    "*:backend-sber-pay-adapter-back-main-*"
    "*:backend-sbp-adapter-*"
    "*:backend-scrat-main-*"
    "*:backend-shiro-main-*"
    "*:backend-shop-main-*:" )

show_menu(){
    normal=`echo "\033[m"`
    menu=`echo "\033[36m"` #Blue
    number=`echo "\033[33m"` #yellow
    bgred=`echo "\033[41m"`
    fgred=`echo "\033[31m"`
    printf "\n${menu}*********************************************${normal}\n"
    for i in ${!ugr_nodes_names[@]};
        do
            printf "${menu}**${number} $((i+1))) ${menu} ${ugr_nodes_names[i]} ${normal}\n";
        done
    printf "${menu}*********************************************${normal}\n"
    printf "Введи номер компоненты или ${fgred}x для выхода. ${normal}"
    read opt
}

option_picked(){
    msgcolor=`echo "\033[01;31m"` # bold red
    normal=`echo "\033[00;00m"` # normal white
    message=${@:-"${normal}Error: No message passed"}
    printf "${msgcolor}${message}${normal}\n"
}

message_text(){
    menu=`echo "\033[36m"` #Blue
    message=${@:-"${normal}Error: No message passed"}
    printf "\n${menu}*********************************************${normal}\n"
    printf "\n${menu}${message}${normal}\n"
}

read_date(){
    message_text "Введи дату (в формате YYYY-MM-DD)"
    read date
}

read_hour(){
    message_text "Указать час? (* - не указывать)"
    read hour 
}

read_request_parameter(){
    message_text "Введи строку для поиска"
    read request_parameter
}

process_menu_item(){
    correct_date='False'
    while [ $correct_date != 'True' ]
    do
        read_date;
        if [[ $date =~ ^[2][0][0-9][0-9]-[0-1][0-9]-[0-3][0-9]$ ]]; then
            correct_date='True'
        else
            clear;
            echo "${fgred}Дата некорректна! Формат должен быть таким: YYYY-MM-DD"
        fi
    done
    
    correct_hour='False'
    while [ $correct_hour != 'True' ]
    do
        read_hour;
        if [[ $hour =~ ^[0-9][0-9]$ ]] || [[ $hour == '*' ]]; then
            correct_hour='True'
        else
            clear;
            echo "${fgred}Значение некорректно! Могут быть только две цифры без пробелов или знак *"
        fi
    done

    read_request_parameter;
    clear;
}

shopt -s extglob
clear
show_menu
while [ $opt != '' ]
    do
    if [ $opt = '' ]; then
      exit;
    else
      case $opt in
        x)  exit;
        ;;

        \n) exit;
        ;;

        [1-9]?([0-4]))  clear;
            option_picked "${ugr_nodes_names[$((opt-1))]}";
            process_menu_item;
            printf "\n${menu}*********************************************${normal}\n"
            printf "${menu}Дата (Год-Месяц-День) | Час\n"
            printf "${fgred}${date} | ${hour}"
            printf "\n${menu}*********************************************${normal}\n\n"

            printf "\n${menu}*********************************************${normal}\n"
            printf "${menu}Строка для поиска\n"
            printf "${fgred}${request_parameter}"
            printf "\n${menu}*********************************************${normal}\n\n"

            printf "\n${menu}*********************************************${normal}\n"
            printf "${menu}Компонента\n"
            printf "${ugr_nodes[$((opt-1))]}"
            printf "\n${menu}*********************************************${normal}\n\n"

            echo "find /media/*/${ugr_nodes[$((opt-1))]}/ -name \"*${date//-/*}*${hour}*.gz\" -exec pigz -dc {} \; | grep -h -A5 -B5 -T --colour=always ${request_parameter}"
            exit;
        ;;

        *)  clear;
            show_menu;
        ;;
      esac
    fi
done
