echo 0 $(cat /proc/`pgrep -f "declarations.dart"`/smaps  | grep Pss | awk '{print $2}' | sed 's#^#+#') | bc
