#!/bin/bash
#By Wangqianchun

target_file=/tmp/${USER}_qstat.dat
python_file=/opt/software/jobstate/


echo "sta_0" > ${target_file}
qstat -n -r >> ${target_file}
echo "end_0" >> ${target_file}

for A in node01 node02 node03 node04 node05 node06
do

echo >> ${target_file}
echo "sta_${A:0-1:1}" >> ${target_file}
timeout 3 ssh $A sensors -u | grep 'temp1_input' >> ${target_file}
s_node=$?
if [ $s_node -eq 0 ];then
    timeout 3 ssh $A nvidia-smi -q -d TEMPERATURE | grep  'GPU Current Temp' >> ${target_file}
    s_gpu=$?
    if [ $s_gpu -eq 0 ];then
        timeout 3 ssh $A nvidia-smi -q -d UTILIZATION | grep 'Gpu' >> ${target_file}
    fi
fi
echo 'state' $s_node $s_gpu >> ${target_file}
echo "end_${A:0-1:1}" >> ${target_file}

done

/usr/bin/python ${python_file}qstat.py ${target_file}

echo 'Disk space:'
df -h | grep --color=never 'Filesystem'
df -h | grep --color=never '/home'
echo '*******************************************************************'
