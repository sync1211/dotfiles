echo $(top -b -n 1 | grep "Cpu(s)" | grep -Po "(\d+(.\d+)?)(?=%?\s?(id(le)?))") | awk -F', ' '{printf("%5.1f%", 100-$1)}'
