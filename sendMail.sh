#!/bin/bash

######## VAR's ########
#######################
DATABASE_NAME_UPPERCASE="$(echo "$DATABASE_NAME" | tr a-z A-Z)";
WORK_DIR_SCRIPT_MAIL="/home/auto.k8s/MONGODB-SLOW-QUERIES/10.50.6.131/NOVA-SRM";
CURRENT_DAY="$(date +%a)";
CURRENT_DAY_MONTH="$(date +%d)";
CURRENT_MONTH="$(date +%m)";
CURRENT_YEAR="$(date +%Y)";
CURRENT_HOUR="$(date +%H)";
CURRNT_MINUTE="$(date +%M)";
CURRENT_TIMEZONE="$(cat /etc/timezone)";
cd "$WORK_DIR_SCRIPT_MAIL";
CURRENT_LOCAL="$(pwd)";
SMTP_SRV="smtp.office365.com";
SMTP_PORT="587";
SMTP_USR="$(echo -ne '<xxxxxxxxxxxxxxxxxxxxxxxxx>' | base64 -d)";
SMTP_PASS="$(echo -ne '<yyyyyyyyyyyyyyyyyyyyyyyy>' | base64 -d)";
MAIL_FROM="$(echo -ne '<xxxxxxxxxxxxxxxxxxxxxxxx>' | base64 -d)";
MAIL_TO="$(echo -ne "<zzzzzzzzzzzzzzzzzzzzzzzzzz>" | base64 -d)";
SUBJECT="REPORT: "$DATABASE_NAME_UPPERCASE" - SLOW QUERIES MONGODB ("$IP_MONGODB_VM")";
######################

HEADER_REPORT_FILE="
From: "$MAIL_FROM"
To: "$MAIL_TO"
Subject: "$SUBJECT"

`echo "
#################################################################
#################################################################
##                                                             
##                  REPORT: "$DATABASE_NAME_UPPERCASE" - SLOW QUERIES MONGODB ("$IP_MONGODB_VM")              
##                                                             
##  DATE: "$CURRENT_DAY" "$CURRENT_DAY_MONTH"-"$CURRENT_MONTH"-"$CURRENT_YEAR" "$CURRENT_HOUR":"$CURRNT_MINUTE" "$CURRENT_TIMEZONE"
##  CONPANY: AGILITY                                            
##  TEAM: "Multi-Cloud Automation"                                      
#################################################################                   
######################## REPORT DETAILS ############################
"`
";

function createHeaderReportFile(){
    
    if [ -e "$CURRENT_LOCAL"/report.txt ];
    then
    	cd "$CURRENT_LOCAL" && rm -rf report.txt;
    fi
    echo "$HEADER_REPORT_FILE" | sed 1d > "$CURRENT_LOCAL"/report.txt;
}

#createHeaderReportFile;

function sendMailNotification(){
        cd "$CURRENT_LOCAL";
        curl --ssl-reqd \
          --url "$SMTP_SRV":"$SMTP_PORT" \
          --user "$SMTP_USR":"$SMTP_PASS" \
          --mail-from "$MAIL_FROM" \
          --mail-rcpt "$MAIL_TO" \
          --upload-file report.txt
}

#sendMailNotification;

