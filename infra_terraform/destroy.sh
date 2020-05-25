#!/bin/bash

## set -x	## Uncomment for debugging

## Include vars if the file exists
FILE=../vars.sh
if [ -f "$FILE" ]; then
    source ../vars.sh
fi

RECORDS=("api.${STACK_NAME}" "*.api.${STACK_NAME}" "apps.${STACK_NAME}" "*.apps.${STACK_NAME}" "${STACK_NAME}" "*.${STACK_NAME}" "${STACK_NAME}-k8smasternode-0" "${STACK_NAME}-k8smasternode-1" "${STACK_NAME}-k8smasternode-2" "${STACK_NAME}-k8sworkernode-0" "${STACK_NAME}-k8sworkernode-1"  "${STACK_NAME}-k8sloadbalancernode-0")
record_type="A"

terraform destroy

## check to see if a record exists
function checkRecord() {
  request=$(curl -sS -X GET -H "Content-Type: application/json" -H "Authorization: Bearer ${DO_PAT}" "https://api.digitalocean.com/v2/domains/${1}/records?per_page=200")
  ## echo -e "\n\n${request}\n\n"
  filter=$(echo $request | jq '.domain_records[] | select((.name | contains("'"${2}"'")) and (.type == "'"${record_type}"'"))')
  FILTER_NO_EXTERNAL_SPACE="$(echo -e "${filter}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -d '\n')"
  if [ -z "$FILTER_NO_EXTERNAL_SPACE" ]; then
    echo -e "Record [A - ${2}.${1}.] does not exist!\n"
    return 1
  else
    IP_FILTER="$(echo "${FILTER_NO_EXTERNAL_SPACE}" | jq '.data')"
    returned_record_id="$(echo "${FILTER_NO_EXTERNAL_SPACE}" | jq '.id')"
    echo -e "Record [A - ${2}.${1}.] exists at ${IP_FILTER}...\n"
    return 0
  fi
}

function deleteRecord() {
  request=$(curl -sS -X DELETE -H "Content-Type: application/json" -H "Authorization: Bearer ${DO_PAT}" "https://api.digitalocean.com/v2/domains/${1}/records/${2}")
  echo $request
}

for d in ${RECORDS[@]}; do
    record_name="${d,,}"
    checkRecord $DOMAIN "${d,,}"
    if [ $? -eq 0 ]; then
        for recid in $returned_record_id; do
          deleteRecord $DOMAIN $recid
        done
    fi
done


rm -rf ./.generated/