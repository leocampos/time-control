#!/bin/bash

while getopts i:t: opt
do
	case ${opt} in
		i) IGNORE="name not like '%${OPTARG}%'";;
		t) TASK="name like '%${OPTARG}%'";;
	esac
done
CONDITIONAL="where"

if [ "$IGNORE" != "" ]; then
	CONDITIONAL="$CONDITIONAL $IGNORE"
fi

if [ "$TASK" != "" ]; then
	if [ "$CONDITIONAL" != "where" ]; then
		CONDITIONAL="$CONDITIONAL and $TASK";
	else
		CONDITIONAL="$CONDITIONAL $TASK";
	fi
fi

if [ "$CONDITIONAL" = "where" ]; then
	CONDITIONAL="";
fi

#echo -e $CONDITIONAL

mysql --user=root --password= timecontrol_development <<EOF

select sec_to_time(sum(time_to_sec(timediff(end_time, start_time)))) as total from tasks $CONDITIONAL;

EOF
exit 2
