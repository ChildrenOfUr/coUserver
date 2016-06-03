# getMemoryUsage.sh <pid>

echo 0 $(cat /proc/$1/smaps | grep Pss | awk '{print $2}' | sed 's#^#+#') | bc
