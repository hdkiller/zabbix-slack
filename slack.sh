#!/bin/bash

# config
slack_url='https://hooks.slack.com/services/XXXXX'
slack_username='Zabbix'
channel="$1"
title="$2"
params="$3"
emoji=':zabbix:'
timeout="5"
cmd_curl="/usr/bin/curl"

# set params
host="`echo \"${params}\" | grep 'HOST: ' | awk -F'HOST: ' '{print $2}' | sed -e 's/
trigger_name="`echo \"${params}\" | grep 'TRIGGER_NAME: ' | awk -F'TRIGGER_NAME: ' '{print $2}' | sed -e 's/
trigger_status="`echo \"${params}\" | grep 'TRIGGER_STATUS: ' | awk -F'TRIGGER_STATUS: ' '{print $2}' | sed -e 's/
trigger_severity="`echo \"${params}\" | grep 'TRIGGER_SEVERITY: ' | awk -F'TRIGGER_SEVERITY: ' '{print $2}' | sed -e 's/
trigger_url="`echo \"${params}\" | grep 'TRIGGER_URL: ' | awk -F'TRIGGER_URL: ' '{print $2}' | sed -e 's/
datetime="`echo \"${params}\" | grep 'DATETIME: ' | awk -F'DATETIME: ' '{print $2}' | sed -e 's/
item_value="`echo \"${params}\" | grep 'ITEM_VALUE: ' | awk -F'ITEM_VALUE: ' '{print $2}' | sed -e 's/
event_id="`echo \"${params}\" | grep 'EVENT_ID: ' | awk -F'EVENT_ID: ' '{print $2}' | sed -e 's/

# set color
if [ "${trigger_status}" == 'OK' ]; then
  case "${trigger_severity}" in
    'Information')
      color="#439FE0"
      ;;
    *)
      color="good"
      ;;
  esac
elif [ "${trigger_status}" == 'PROBLEM' ]; then
  case "${trigger_severity}" in
    'Information')
      color="#439FE0"
      ;;
    'Warning')
      color="warning"
      ;;
    *)
      color="danger"
      ;;
  esac
else
  color="#808080"
fi

# set payload
payload="payload={
  \"channel\": \"${channel}\",
  \"username\": \"${slack_username}\",
  \"icon_emoji\": \"${emoji}\",
  \"attachments\": [
    {
      \"fallback\": \"Date / Time: ${datetime} - ${title}\",
      \"title\": \"${title}\",
      \"title_link\": \"${trigger_url}\",
      \"color\": \"${color}\",
      \"fields\": [
        {
            \"title\": \"Date / Time\",
            \"value\": \"${datetime}\",
            \"short\": true
        },
        {
            \"title\": \"Status\",
            \"value\": \"${trigger_status}\",
            \"short\": true
        },
        {
            \"title\": \"Host\",
            \"value\": \"${host}\",
            \"short\": true
        },
        {
            \"title\": \"Trigger\",
            \"value\": \"${trigger_name}: ${item_value}\",
            \"short\": true
        }
      ]
    }
  ]
}"

# send to slack
${cmd_curl} -m ${timeout} --data-urlencode "${payload}" "${slack_url}"
