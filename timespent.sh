#!/bin/bash
 
declare -A conditions=()
declare -A queries=()

#DEFAULTS
query_type='REPORT_BY_TASK'
from='today'
to='now'
ignore=''
task=''
debug=false

#GET OPTIONS AND FLAGS
while getopts di:k:t:T:f:F:h:m: opt
do
	case ${opt} in
		i) ignore=${OPTARG};;
		k) task=${OPTARG};;
		f) from=${OPTARG};;
		t) to=${OPTARG};;
		m) case ${OPTARG} in
			'sum') query_type='SUMTIME';;
			'task') query_type='REPORT_BY_TASK';;
			'time') query_type='REPORT_BY_TIME';;
		   esac;;
		d) debug=true;;
		h) cat <<EOF
			USAGE: $0
				-i ignore task
				-k task
				-f start time <dd/mm/yyyy> [today|yesterday]
				-t end time <dd/mm/yyyy>
				-m mode (default: task) 
					sum - sums up the total duration for all tasks meeting the search criteria
					task - sums up the total duration for each task meeting the search criteria
					time - shows a time table ordered by starting time o tasks meeting the search criteria
	
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
queries['REPORT_BY_TASK']="select name as Task, sec_to_time(sum(time_to_sec(timediff(end_time, start_time)))) as Duration "
queries['REPORT_BY_TIME']="select name as Task, start_time as Starting, end_time as Ending "
#queries['REPORT_BY_TIME']="select name as Task, start_time as Desde, end_time as Ateh, sec_to_time(sum(time_to_sec(timediff(end_time, start_time)))) as Duration "
queries['SUMTIME']="select sec_to_time(sum(time_to_sec(timediff(end_time, start_time)))) as Duration "
queries['GROUP']=" group by name "
queries['ORDER']=" order by name "
queries['ORDER_TIME']=" order by start_time "
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
	'REPORT_BY_TASK') query="$query from tasks $conditional ${queries['GROUP']} ${queries['ORDER']}";;
	'REPORT_BY_TIME') query="$query from tasks $conditional ${queries['ORDER_TIME']}";;
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
