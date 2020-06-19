#!/bin/bash
#ip M и A, используются для ping
M_ip="192.168.1.11"
A_ip="192.168.1.13"
#файл для логирования
log=./S.log
#текущая дата и время год - месяц -день :час :минута :секунда
asktime=`date +%Y-%m-%d:%H:%M:%S`
#переменные, определяющие последние состояния соединения с M и A,нужны, чтобы избавить лог от спама.
M_down=true
A_down=true

echo  $asktime "A machine script starting" >> ${log}

while [ true ]; do
#бесконечный цикл
  ping -q -c 1 $M_ip > /dev/null
  if [ $? -eq 0 ];
	then
      #если есть соединение с M
	  echo "+ M"
	    if [[ "$M_down" == "true" ]];
		  then
		    #если его не было, логируем новое состояние
			echo  $asktime "M machine up" >> ${log}
			M_down=false
		  fi
	else
      #если нет соединения с M	
      echo "- M"	  
		if [[ "$M_down" == "false" ]];
		  then
			#если оно было до этого, логируем новое состояние
			echo  $asktime "M machine down" >> ${log}
			M_down=true
		fi
  fi
  ping -q -c 1 $A_ip > /dev/null
  if [ $? -eq 0 ];
	    then
		  #если есть соединение с A
		  if [[ "$A_down" == "true" ]];
		    then
			  #если его не было, логируем новое состояние
			  echo  $asktime "A machine up" >> ${log}
			  A_down=false
		  fi
		else
          #если нет соединения с A		
		  if [[ "$A_down" == "false" ]];
		    then
			  #если оно было до этого, логируем новое состояние
			  echo  $asktime "A machine down" >> ${log}
			  A_down=true
		  fi
  fi  
done
