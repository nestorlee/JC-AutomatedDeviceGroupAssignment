#!/bin/bash

sleep 180
jcAPIKey="<JC API Key>"

# Retrieve Serial Number of Linux device through CLI
hostname=$(hostname)

# Call JC API to get information of enrolled systems, filtered with hostname
responseForSystemId=$(
    curl --request GET --silent --url "https://console.jumpcloud.com/api/systems?filter=hostname:$eq:${hostname}" \
    --header "x-api-key: ${jcAPIKey}" \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json'
)

# String manipulation to get SystemID of enrolled device
unformattedSystemId=$(echo $responseForSystemId | grep -Po '"id":.*?[^\\]"')
removedCharsSystemId=$(echo $unformattedSystemId | sed -e 's/id//g')
realSystemId=$(echo $removedCharsSystemId | sed 's/[^a-zA-Z0-9]//g')

# Call JC API to get Device Groups info, filtered by Device Group name e.g. Linux Devices
responseForDeviceGroupId=$(
    curl --request GET --silent --url "https://console.jumpcloud.com/api/v2/systemgroups?filter=name:eq:Linux+Devices" \
    --header "x-api-key: ${jcAPIKey}" \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json'
)

# String manipulation to get Device Group ID
unformattedSystemGroupId=$(echo $responseForDeviceGroupId | grep -Po '"id":.*?[^\\]"')
removedCharsSystemGroupId=$(echo $unformattedSystemGroupId | sed -e 's/id//g')
linuxSystemGroupId=$(echo $removedCharsSystemGroupId | sed 's/[^a-zA-Z0-9]//g')

# Call JC API to add System to Device Group 
addSystemToSystemGroup=$(
    curl --request POST --silent --url "https://console.jumpcloud.com/api/v2/systemgroups/${linuxSystemGroupId}/members" \
    --header "x-api-key: ${jcAPIKey}" \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    -d '{
        "op":"add",
        "type":"system",
        "id":"'${realSystemId}'"
    }'
)