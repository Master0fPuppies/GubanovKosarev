#!/bin/bash
#ip S и A, используются для ping
S_ip="192.168.1.12"
A_ip="192.168.1.13"
#файл для логирования
log=./M.log
#переменная,определяющая, закрыт ли мастер
M_status=fine
#переменная,определяющая, есть ли соединение хотя бы с одной из машин
Someone_alive=true
#текущая дата и время год - месяц -день :час :минута :секунда
asktime=`date +%Y-%m-%d:%H:%M:%S`

echo  $asktime "M machine script starting" >> ${log}

while [ true ]; do
  #бесконечный цикл
  if [[ "$M_status" == "fine" ]];
    then
	  #если M открыт, проверяем соединения с A и S
	  ping -q -c1 $S_ip > /dev/null
	  if [ $? -eq 0 ];
	    then
		  #ничего не нужно делать, т.к. есть соединение с S
		  sleep 0
		else
		  ping -q -c1 $A_ip > /dev/null
		  if [ $? -eq 0 ];
		    then
			  #ничего не нужно делать, т.к. есть соединение с A
		      sleep 0
			else
			  #нету соединения ни с A ни с S, закрываем порты.
			  sudo iptables -A INPUT -p tcp --dport 5432 -j DROP
              sudo iptables -A INPUT -p tcp --sport 5432 -j DROP
              sudo iptables -A OUTPUT -p tcp --dport 5432 -j DROP
              sudo iptables -A OUTPUT -p tcp  --dport 5432 -j DROP
			  echo  $asktime "M machine has no connection to S and A, closed ports" >> ${log}
			  M_status=bad
			  Someone_alive=false
		  fi
	  fi
  fi

  if [[ "$M_status" == "bad" ]];
    then
	  #если M закрыт, проверяем наличие соединения с A или S
	  ping -q -c1 $S_ip > /dev/null
	  if [ $? -eq 0 ];
	    then
		  #есть соединение с S
		  Someone_alive=true
		  echo  $asktime "S machine alive" >> ${log}
	  fi
	  ping -q -c1 $A_ip > /dev/null
	  if [ $? -eq 0 ];
	    then
		  #есть соединение с A
		  Someone_alive=true
		  echo  $asktime "A machine alive" >> ${log}
	  fi
	 if [[ "$Someone_alive" == "true" ]];
	   then
	     #если есть соединение с A или S, открываем M
         sudo iptables -D INPUT 1
         sudo iptables -D INPUT 1
         sudo iptables -D OUTPUT 1
         sudo iptables -D OUTPUT 1
         sudo iptables -A INPUT -p tcp --dport 5432 -j ACCEPT
         sudo iptables -A INPUT -p tcp --sport 5432 -j ACCEPT
         sudo iptables -A OUTPUT -p tcp --sport 5432 -j ACCEPT
         sudo iptables -A OUTPUT -p tcp --dport 5432 -j ACCEPT
         echo  $asktime "M machine has connection to S or A, opened ports" >> ${log}
		 M_status=fine
	  fi
  fi
done

echo  $asktime "M machine script stopping" >> ${log}


