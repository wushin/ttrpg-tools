#!/bin/bash
taskexecution=$(aws datasync start-task-execution --task-arn $1 --override-options Gid=NONE,Uid=NONE,PreserveDeletedFiles=REMOVE --region $AWS_DEFAULT_REGION | awk 'NF{ print $NF }' | sed 's/{//g' | sed 's/"//g' | sed 's/}//g')
rtn=$?
if [ $rtn = 0 ]; then  
  execute=$(aws datasync describe-task-execution --task-execution-arn $taskexecution --region $AWS_DEFAULT_REGION | grep  "TransferStatus" | awk 'NF{ print $NF }' | sed 's/,$//' | sed 's/"//g')
  while [ -z "$execute" ] || [ "$execute" = "PENDING" ]
  do
    sleep 20
    echo "inprogress"
    execute=$(aws datasync describe-task-execution --task-execution-arn $taskexecution --region $AWS_DEFAULT_REGION | grep  "TransferStatus" | awk 'NF{ print $NF }' | sed 's/,$//' | sed 's/"//g')
    sleep 10
  done
  echo "transfer completed"
else
  echo "something wrong"
fi

