#!/bin/sh
echo "version: 3"
echo "automerge: true"
echo "projects:"
region=$1

find . -name view.hcl | while read line
do  
  folder=$(echo $line | sed s'/\/view.hcl//' | sed s'/\.\///')
  cat $folder/view.hcl |sed s'/ //g' | grep -i "type=\"operational\"" 1>/dev/null 2>&1
  if [ $? -eq 0 ]
  then
    cat $folder/view.hcl |sed s'/ //g' | grep -i "region=\"$region\"" 1>/dev/null 2>&1
    if [ $? -eq 0 ]
    then
      echo "  - name: project-$folder/records"
      echo "    dir: $folder/records"
      echo "    autoplan:"
      echo "      when_modified: [\"*.yml\",\"*.tf\",\"*.hcl\"]"
      echo "  - name: project-$folder/zone"
      echo "    dir: $folder/zone"
      echo "    autoplan:"
      echo "      when_modified: [\"*.yml\",\"*.tf\",\"*.hcl\"]"
    fi
  fi
  
done
