#!/bin/bash
 
declare -A conditions=()
declare -A queries=()

queries['REPORT']="select name, sec_to_time(sum(time_to_sec(timediff(end_time, start_time)))) as total "
queries['GROUP']=" group by name "
queries['ORDER']=" order by name "


#select name, sec_to_time(sum(time_to_sec(timediff(end_time, start_time)))) as total"

query_type='REPORT'

while getopts i:k:t:T:f:F:h: opt
do
	case ${opt} in
		i) conditions["IGNORE"]="name not like '%${OPTARG}%'";;
		k) conditions["TASK"]="name like '%${OPTARG}%'";;
		f) conditions["FROM"]="start_time > STR_TO_DATE('${OPTARG}','%d/%m/%Y')";;
		F) conditions["FROM"]="start_time > STR_TO_DATE('${OPTARG}','%d/%m/%Y %H:%i')";;
		t) conditions["TO"]="end_time < STR_TO_DATE('${OPTARG}','%d/%m/%Y')";;
		T) conditions["TO"]="end_time < STR_TO_DATE('${OPTARG}','%d/%m/%Yi %H:%i')";;
		h) cat <<EOF
			USAGE: $0
				-i ignore task
				-k task
				-f start time <dd/mm/yyyy>
				-F start time <dd/mm/yyyy hh:ii>
				-t end time <dd/mm/yyyy>
				-T end time <dd/mm/yyyy hh:ii>
				-r report mode
				-l labels showed in the report (report mode only)
				If no arguments are provided, all time recorded will be printed
EOF
		exit 2;;
	esac
done

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
echo -e "$query from tasks $CONDITIONAL"
echo -e "###########################################################"

mysql --table --user=root --password= timecontrol_development <<EOF

$query;

EOF
exit 2
