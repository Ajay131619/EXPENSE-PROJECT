#!/bin/bash

# Author: Ajay

#date : Sun, Dec  8, 2024  4:51:00 PM

#script name:mysql.sh

#description :: In this script , I am going to install the mysql tool ,setup the password and the username for the sql server, and I will also start and enable the mysql service and we will also check the service and the server is working or not 

# here goes the script

folder="/var/log/EX-P_logs"
timestamp=$(date)
scriptname=$(echo $0 | awk -F "." {'print $1F'})
logfile="$folder/$scriptname-$timestamp.log"

r="\e[31m" #red colour code
g="\e[32m" #green colour code
y="\e[33m" #yellow colour code
n="\e[0m"  #no colour code

#these colours are used for better user experience 


userid=$(id -u)

check(){

    if [ $userid -eq 0 ]
    then
        echo -e " the execution of the script is $g started $n" | tee -a $logfile
        mkdir -p $folder
        echo -e " check the logs in this folder ->> $y "/var/log/EX-P_logs" $n "
    else
        echo -e " please run this script only using $y sudo access $n " | tee -a $logfile
        echo -e " the execution of the script is $r failed $n" | tee -a $logfile
        exit 1
    fi

}

valid(){
if [ $? -eq 0 ]
then
    echo -e " mysql server $1 is $g success $n " | tee -a $logfile
else
    echo -e " mysql server $1 is $r failed $n " | tee -a $logfile
    exit 1
fi
}

installation(){

 dnf install mysql-server -y &>> $logfile
 valid installation

 systemctl enable mysqld &>> $logfile
 valid enabling

 systemctl start mysqld &>> $logfile
 valid starting

}

passwordsetup(){

mysql -h sql.daws19.online -u root -pExpenseApp@1 -e 'show databases;'  &>> $logfile

if [ $? -eq 0 ]
then
    echo -e " password setup is $g already done $n " | tee -a $logfile
else
    echo -e " password setup process is$y initiated$n " | tee -a $logfile
    mysql_secure_installation --set-root-pass ExpenseApp@1
    valid password_setup
fi
}

#calling the functions

check

installation

passwordsetup