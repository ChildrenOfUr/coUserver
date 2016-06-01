ps -p $(pgrep -f "declarations.dart") -o %cpu | tail -n +2
