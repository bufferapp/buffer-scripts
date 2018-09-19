#/bin/bash

# Cycle pods for a given matching label by killing pods and sleeping in
# between each "delete" command

# Usage:
#   ./cyclepods.sh label=value <sleep-seconds-between-deletes>
#   ./cyclepods.sh app=buffer-api 2

LABEL="$1"
SLEEP="$2"

if [ -z $LABEL ]; then
  echo "You must include a label, ex. app=something"
  exit 1
fi

if [ -z $SLEEP ]; then
  SLEEP="2" # default
fi

PODS=($(k get po -l $LABEL -oname))
TOTAL_PODS="${#PODS[@]}"

echo "Found $TOTAL_PODS matching pods"
if [ "$TOTAL_PODS" == "0" ]; then
  exit 0
fi

read -p "Press any key to continue or control+c to cancel... " -n1 -s
echo "starting..."

COMPLETED="0"

for POD in "${PODS[@]}"
do
  REMAINING=`expr $TOTAL_PODS - $COMPLETED`
  echo "$REMAINING remaining pods"
  kubectl delete $POD #--grace-period 1 #0 --force
  COMPLETED=`expr $COMPLETED + 1`
  echo "Sleeping $SLEEP seconds..."
  sleep $SLEEP
done

echo "Cycled $TOTAL_PODS pods"
