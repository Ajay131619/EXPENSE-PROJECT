#!/bin/bash

# Author: Ajay

#date : Tue, Dec 10, 2024  5:06:32 AM

#script name:backend.sh

#description :: In this script , I am going to install the mysql tool ,setup the password and the username for the sql server, and I will also start and enable the mysql service and we will also check the service and the server is working or not 

# here goes the script

userid=$(id -u)
folder="/var/log/EX-P_logs"
timestamp=$(date)
scriptname=$(echo $0 | awk -F "." {'print $1F'})
logfile="$folder/$scriptname-$timestamp.log"

r="\e[31m" #red colour code
g="\e[32m" #green colour code
y="\e[33m" #yellow colour code
n="\e[0m"  #no colour code

#these colours are used for better user experience 

check(){

    if [ $userid -eq 0 ]
    then
        mkdir -p $folder
        echo -e " the execution of the script is $g started $n" | tee -a $logfilea
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
    echo -e " $1 is $g success $n " | tee -a $logfile
else
    echo -e " $1 is $r failed $n " | tee -a $logfile
    exit 1
fi
}

front(){
dnf install nginx -y &>>$logfile
valid "nginx installation" | tee -a $logfile

systemctl enable nginx &>>$logfile
valid "enabling nginx service" | tee -a $logfile

systemctl start nginx &>>$logfile
valid "starting nginx service" | tee -a $logfile

rm -rf /usr/share/nginx/html/* &>>$logfile
valid "removing default html files" | tee -a $logfile

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$logfile
valid "downloading frontend zip file" | tee -a $logfile

cd /usr/share/nginx/html &>>$logfile
unzip /tmp/frontend.zip &>>$logfile
valid "unzipping frontend zip file"  | tee -a $logfile

cp ~/expense-project/frontend.conf /etc/nginx/default.d/expense.conf &>>$logfile
valid "copying configuration"

systemctl restart nginx &>>$logfile
valid "restarting nginx service" | tee -a $logfile
}

check
front