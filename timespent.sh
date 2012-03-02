#!/bin/bash
 
declare -A conditions=()
declare -A queries=()

queries['REPORT']="select name as Task, sec_to_time(sum(time_to_sec(timediff(end_time, start_time)))) as Duration "
queries['GROUP']=" group by name "
queries['ORDER']=" order by name "


#select name, sec_to_time(sum(time_to_sec(timediff(end_time, start_time)))) as total"

query_type='REPORT'

#DEFAULT DATE
from='today'
to='now'

while getopts i:k:t:T:f:F:h: opt
do
	case ${opt} in
		i) conditions["IGNORE"]="name not like '%${OPTARG}%'";;
		k) conditions["TASK"]="name like '%${OPTARG}%'";;
		f) from=${OPTARG};;
		t) to=${OPTARG};;
		h) cat <<EOF
			USAGE: $0
				-i ignore task
				-k task
				-f start time <dd/mm/yyyy> [today|yesterday]
				-t end time <dd/mm/yyyy>
				If no arguments are provided, all time recorded will be printed
EOF
		exit 2;;
	esac
done

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

query=${queries[$query_type]}
CONDITIONAL="where"
itens=${#conditions[@]}
separator="and"
for item in "${!conditions[@]}"; do
    let itens--
    if [[ $itens == 0 ]]; then
	separator=""
    fi
    CONDITIONAL="$CONDITIONAL ${conditions[$item]} $separator"
done

if [ "$CONDITIONAL" = "where" ]; then
	CONDITIONAL="";
fi

case ${query_type} in
	'REPORT') query="$query from tasks $CONDITIONAL ${queries['GROUP']} ${queries['ORDER']}";;
esac

echo -e "###########################################################"
echo -e $query
echo -e "###########################################################"
echo -e "$label_from $label_to"
echo -e "###########################################################"

mysql --table --user=root --password= timecontrol_development <<EOF

$query;

EOF
exit 2
