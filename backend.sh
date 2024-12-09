#!/bin/bash

# Author: Ajay

#date : Tue, Dec 10, 2024  2:57:41 AM

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
        echo -e " the execution of the script is $g started $n" | tee -a $logfile
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
    echo -e "  $1 is $g success $n " | tee -a $logfile
else
    echo -e "  $1 is $r failed $n " | tee -a $logfile
    exit 1
fi
}

backend(){
dnf module disable nodejs -y &>> $logfile
dnf module enable nodejs:20 -y &>> $logfile
dnf install nodejs -y &>> $logfile
valid "installation of nodejs"

id expense
if [ $? -eq 0 ]
then
    echo -e " expense user is $g already created!! $n " | tee -a $logfile
else
    echo -e " expense user is  $y not created yet!! $n " | tee -a $logfile
    echo -e " going to create$y expense user!! $n " | tee -a $logfile
    useradd expense 
    valid "expense user creation"
fi

mkdir -p /app
valid " creation of /app "
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE "Downloading backend application code"

cd /app &>> $logfile

rm -rf /app/* | tee -a $logfile

unzip /tmp/backend.zip | tee -a $logfile
valid "unzipping backend application code"

cd /app

npm install | tee -a $logfile
valid "installation of backend application dependencies"
cp /~/EXPENSE-PROJECT/backend.service /etc/systemd/system/backend.service | tee -a $logfile
valid "backend service is created"

systemctl daemon-reload | tee -a $logfile
valid "reloading the systemd"

systemctl enable backend | tee -a $logfile
valid "enabling backend service "

systemctl start backend | tee -a $logfile
valid "starting backend service"

dnf install mysql -y &>> $logfile
valid "installation of mysql"

mysql -h sql.daws19.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>> $logfile
valid "loading the schema"

systemctl restart backend &>> $logfile
valid "restarting backend service"
}

#calling functions
check
backend