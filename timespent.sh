#!/bin/bash

declare -A conditions=()

while getopts i:k:t:T:f:F:h opt
do
	case ${opt} in
		i) conditions["IGNORE"]="name not like '%${OPTARG}%'";;
		k) conditions["TASK"]="name like '%${OPTARG}%'";;
		f) conditions["FROM"]="start_time > STR_TO_DATE('${OPTARG}','%d/%m/%Y')";;
		F) conditions["FROM"]="start_time > STR_TO_DATE('${OPTARG}','%d/%m/%Y %H:%i')";;
		t) conditions["TO"]="end_time < STR_TO_DATE('${OPTARG}','%d/%m/%Y')";;
		T) conditions["TO"]="end_time < STR_TO_DATE('${OPTARG}','%d/%m/%Yi %H:%i')";;
		h) echo -e "USAGE: timespent\n\t\t-i ignore task\n\t\t-k task\n\t\t-f start time <dd/mm/yyyy>\n\t\t-F start time <dd/mm/yyyy hh:ii>\n\t\t-t end time <dd/mm/yyyy>\n\t\t-T end time <dd/mm/yyyy hh:ii>\n\n\t\tIf no arguments are provided, all time recorded will be printed";
		exit 2;;
	esac
done
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

mysql --user=root --password= timecontrol_development <<EOF

select sec_to_time(sum(time_to_sec(timediff(end_time, start_time)))) as total from tasks $CONDITIONAL;

EOF
exit 2
