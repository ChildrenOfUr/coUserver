# getCpuUsage.sh <pid>

ps -p $1 -o %cpu | tail -n +2
