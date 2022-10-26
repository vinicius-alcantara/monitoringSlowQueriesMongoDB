#!/bin/bash

#### VARIABLES #####
WC_COMMAND="$(which wc)";
IP_MONGODB_VM="10.50.6.131";
#USER_MONGODB="admin";
#PASSWORD_MONGODB="";
#PORT_MONGODB="27017";
DATABASE_NAME="nova_srm";
JAVASCRIPT_FILE_NAME="monitoring-slow-query-mongodb.js";
DIR_LOG="$(pwd)/log/";
FORMATED_HASH_LAST_SLOW_QUERIES_FILE_LOG=""$DIR_LOG"formatedLastSlowQueries.log";
FORMATED_HASH_CURRENT_SLOW_QUERIES_FILE_LOG=""$DIR_LOG"formatedCurrentSlowQueries.log";
LAST_SLOW_QUERIES_FILE_RAW=""$DIR_LOG"lastSlowQueries.raw";
CURRENT_SLOW_QUERIES_FILE_RAW=""$DIR_LOG"currentSlowQueries.raw";
LAST_SLOW_QUERIES_FILE_LOG=""$DIR_LOG"lastSlowQueries.log";
CURRENT_SLOW_QUERIES_FILE_LOG=""$DIR_LOG"currentSlowQueries.log";
FILTER_FIELD_RETURN_QUERIES='"ns"|"op"|"docsExamined"|"numYield"|"responseLength"|"millis"|"planSummary"|"ts"|"client"';
###################

#### IMPORT FUNCTIONS ####

source sendMail.sh;

###################
#### FUNCTIONS ####

function generateLastSlowQueriesFile(){

   mongo "$IP_MONGODB_VM"/"$DATABASE_NAME" < "$JAVASCRIPT_FILE_NAME" >> "$LAST_SLOW_QUERIES_FILE_RAW";

}

#generateLastSlowQueriesFile;

function generateCurrentSlowQueriesFile(){

   if [ -f "$CURRENT_SLOW_QUERIES_FILE_RAW" ];
   then
      rm -rf "$CURRENT_SLOW_QUERIES_FILE_RAW";
   fi

   mongo "$IP_MONGODB_VM"/"$DATABASE_NAME" < "$JAVASCRIPT_FILE_NAME" >> "$CURRENT_SLOW_QUERIES_FILE_RAW";

}

#generateCurrentSlowQueriesFile;

function formatLastSlowQueriesFile(){
   
   grep -E "$FILTER_FIELD_RETURN_QUERIES" "$LAST_SLOW_QUERIES_FILE_RAW" | tr -d ',' | sed 's/^[ \t]*//;s/[ \t]*$//' | tr -d " " | sed 's/:/: /g' | sed '/client/a #################################################################' >> "$LAST_SLOW_QUERIES_FILE_LOG";

}

#formatLastSlowQueriesFile;

function formatCurrentSlowQueriesFile(){

   if [ -f "$CURRENT_SLOW_QUERIES_FILE_LOG" ];
   then
      rm -rf "$CURRENT_SLOW_QUERIES_FILE_LOG";
   fi

   grep -E "$FILTER_FIELD_RETURN_QUERIES" "$CURRENT_SLOW_QUERIES_FILE_RAW" | tr -d ',' | sed 's/^[ \t]*//;s/[ \t]*$//' | tr -d " " | sed 's/:/: /g' | sed '/client/a #################################################################' >> "$CURRENT_SLOW_QUERIES_FILE_LOG";

}

#formatCurrentSlowQueriesFile;

if [ -f "$LAST_SLOW_QUERIES_FILE_RAW" ];
then
     
     #### Count lines in Last Log File ####
     QTD_LINES_LAST_FILE_LOG=$("$WC_COMMAND" -l "$LAST_SLOW_QUERIES_FILE_LOG" | cut -d " " -f1);     
     echo "$QTD_LINES_LAST_FILE_LOG";    
 
     #### Generate Current File Raw and Log####
     generateCurrentSlowQueriesFile;
     formatCurrentSlowQueriesFile;

     #### Test Alterar Hash no Current File Log ####
     echo "new text" >> "$CURRENT_SLOW_QUERIES_FILE_LOG";
      
     #### Count lines in Current Log File ####
     QTD_LINES_CURRENT_FILE_LOG=$("$WC_COMMAND" -l "$CURRENT_SLOW_QUERIES_FILE_LOG" | cut -d " " -f1);
     echo "$QTD_LINES_CURRENT_FILE_LOG";

     if [ "$QTD_LINES_LAST_FILE_LOG" == "$QTD_LINES_CURRENT_FILE_LOG" ];
     then
	 echo "Nada a fazer" > /dev/null;
     else
	 #echo "Enviar E-mail com relatório";
	 generateCurrentSlowQueriesFile;
	 formatCurrentSlowQueriesFile;
         createHeaderReportFile;
         cat "$CURRENT_SLOW_QUERIES_FILE_LOG" >> report.txt
         sendMailNotification;

	 if [ -e "$(pwd)"/report.txt ];
         then
             rm -rf report.txt
         fi

	 if [ -e "$LAST_SLOW_QUERIES_FILE_RAW" ] && [ -e "$LAST_SLOW_QUERIES_FILE_LOG" ];
	 then
             cd "$DIR_LOG" && rm -rf "$LAST_SLOW_QUERIES_FILE_RAW" "$LAST_SLOW_QUERIES_FILE_LOG";
             mv currentSlowQueries.raw lastSlowQueries.raw;
	     mv currentSlowQueries.log lastSlowQueries.log;
	 fi
         
     fi

else

     generateLastSlowQueriesFile;
     formatLastSlowQueriesFile;

     #echo "Enviar E-mail com relatório";

     createHeaderReportFile;
     cat "$LAST_SLOW_QUERIES_FILE_LOG" >> report.txt
     sendMailNotification;

     if [ -e "$(pwd)"/report.txt ];
     then
	  rm -rf report.txt
     fi          
fi

