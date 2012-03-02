#!/bin/bash
 
declare -A conditions=()
declare -A queries=()

#DEFAULTS
query_type='REPORT'
from='today'
to='now'
ignore=''
task=''
debug=false

#GET OPTIONS AND FLAGS
while getopts sdi:k:t:T:f:F:h: opt
do
	case ${opt} in
		i) ignore=${OPTARG};;
		k) task=${OPTARG};;
		f) from=${OPTARG};;
		t) to=${OPTARG};;
		s) query_type='SUMTIME';;
		d) debug=true;;
		h) cat <<EOF
			USAGE: $0
				-i ignore task
				-k task
				-f start time <dd/mm/yyyy> [today|yesterday]
				-t end time <dd/mm/yyyy>
				-s sum all the durations found
	
				If no arguments are provided, all tasks for today will be printed
EOF
		exit 2;;
	esac
done

#PREPARING SQL CONDITIONS
case ${ignore} in
	'') ;;
	*) conditions["IGNORE"]="name not like '%${ignore}%'";
		label_ignore="IGNORING: ${ignore}";;
esac

case ${task} in
	'') ;;
	*) conditions["TASK"]="name like '%${task}%'";
		label_task="LOOKING FOR: ${task}";;
esac

case ${from} in
	'today') 
		conditions["FROM"]="start_time > STR_TO_DATE(curdate(),'%Y-%m-%d %H:%i')"; 
		label_from="TODAY ($(date --date="1 day ago" +%d/%m/%Y))";;
	'yesterday') 
		conditions["FROM"]="start_time > STR_TO_DATE(DATE_SUB(curdate(), INTERVAL 1 DAY), '%Y-%m-%d %H:%i')"; 
		label_from="YESTERDAY ($(date --date="2 days ago" +%d/%m/%Y))";
		to='today';;
	*)
		conditions["FROM"]="start_time > STR_TO_DATE('${from}','%d/%m/%Y %H:%i')";
		label_from="FROM: ${from}";;
esac

case ${to} in
	'now')
                conditions["TO"]="end_time < STR_TO_DATE(ADDDATE(curdate(), INTERVAL 1 DAY), '%Y-%m-%d %H:%i')";
                label_to="";;
	'today')
                conditions["TO"]="end_time < STR_TO_DATE(curdate(),'%Y-%m-%d %H:%i')";
                label_to="";;
	*)
		conditions["TO"]="end_time < STR_TO_DATE('${to}','%d/%m/%Y %H:%i')";
		label_to="- TO: ${to}";;

esac

#QUERY CHUNKS
queries['REPORT']="select name as Task, sec_to_time(sum(time_to_sec(timediff(end_time, start_time)))) as Duration "
queries['SUMTIME']="select sec_to_time(sum(time_to_sec(timediff(end_time, start_time)))) as Duration "
queries['GROUP']=" group by name "
queries['ORDER']=" order by name "
query=${queries[$query_type]}


itens=${#conditions[@]}
conditional="where"
separator="and"
for item in "${!conditions[@]}"; do
    let itens--
    if [[ $itens == 0 ]]; then
	separator=""
    fi
    conditional="$conditional ${conditions[$item]} $separator"
done

case ${query_type} in
	'REPORT') query="$query from tasks $conditional ${queries['GROUP']} ${queries['ORDER']}";;
	'SUMTIME') query="$query from tasks $conditional";;
esac

if [ "$debug" == true ]; then
	echo -e "###########################################################"
	echo -e $query
	echo -e "###########################################################\n\n"
fi

echo -e "+--------------------------------------------+"
echo -e "| $label_from $label_to"
[[ -n $label_task ]] && echo -e "| $label_task"
[[ -n $label_ignore ]] && echo -e "| $label_ignore"
echo -e "+--------------------------------------------+"

mysql --table --user=root --password= timecontrol_development <<EOF
$query;
EOF
exit 2
