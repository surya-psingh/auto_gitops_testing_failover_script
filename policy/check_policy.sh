#!/bin/bash
evalresult=$(opa eval --data ${DIR/$REPO_REL_DIR/}policy/policy.rego --input $SHOWFILE "data.terraform")
if [ $? -ne 0 ]
then
  echo "Error running OPA evaluation"
  echo "OPA result: $evalresult"
  exit 1
fi

denylines=$(echo $evalresult | jq '.result[].expressions[].value.deny[]' 2>&1)
if [ $? -ne 0 ]
then
  echo "Unable to parse OPA result"
  echo "OPA result: $denylines"
  exit 1
fi

numdenylines=$(echo $evalresult | jq '.result[].expressions[].value.deny[]' | wc -l)
if [ $numdenylines -ne 0 ]
then
  #If we have policy errors, print error message and exit with error 1
  echo "OPA policy check failed"
  echo "OPA policy check result:"
  echo $evalresult | jq '.result[].expressions[].value.deny'
  exit 1
else
  #Everything seems OK, exit with status 0
  echo "OPA policy check OK"
  exit 0
fi
#If we got here, then we have some unknown error.
echo "Unable to parse policy, a horrible unknown error occured"
exit 1
