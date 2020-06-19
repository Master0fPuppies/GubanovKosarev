#!/bin/bash
#ip S и M, используются для ping и ssh
S_ip="192.168.1.12"
M_ip="192.168.1.11"
#файл для логирования
log=./A.log
#имя пользователя для ssh (slave)
ssh_user="postgres"
#текущая дата и время год - месяц -день :час :минута :секунда
asktime=`date +%Y-%m-%d:%H:%M:%S`
#уведомление о том что скрипт запущен
echo  $asktime "A machine script starting" >> ${log}
#переменная,определяющая, падал ли мастер ( для избежания повторения действий )
master_dropped=false

while [ true ]; do
  #бесконечный цикл
  ping -q -c 1 $M_ip > /dev/null
  #пингуем мастера если хотя бы один пинг не проходит
  if [ $? -eq 0 ];
    then
	  #если пинг проходит => М жив, ничего делать не надо.
	  #sleep 0 - затычка,чтобы небыло пустого then
	  sleep 0
	else
	  #если пинг не проходит => M упал		  
	  if [[ "$master_dropped" == "false" ]]
	    then
		  #если мастер упал первый раз,пишем сообщение в лог
		  echo  $asktime "Promoting replica (S) " >> ${log}
		  #промоутим по ssh S 
		  ssh ${ssh_user}@${S_ip} 'sudo -u postgres /usr/lib/postgresql/9.6/bin/pg_ctl promote -D /var/lib/postgresql/9.6/main/'
	  fi	  
	  master_dropped=true
  fi
done
echo  $asktime "A machine script stopped..." >> ${log}

