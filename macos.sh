#!/bin/bash


# Wait 5 minutes before running script. Seems like it takes a bit of time after the system is registered before we are able to retrieve the relevant info via API calls.
sleep 300

jcAPIKey="<JC API Key>"


# Retrieve Serial Number of macOS device through CLI
unformatedSerial=$(system_profiler SPHardwareDataType | grep -i "Serial Number")
removedCharsSerial=${unformatedSerial#*:}
realSerialNumber=${removedCharsSerial//[[:blank:]]}

# Call JC API to get information of enrolled systems, filtered with Serial Number
responseForSystemId=$(
    curl -s -f -X GET https://console.jumpcloud.com/api/systems?filter=serialNumber:$eq:${realSerialNumber} \
        -H 'Accept: application/json' \
        -H 'Content-Type: application/json' \
        -H "x-api-key: ${jcAPIKey}"
)

# String manipulation to get SystemID of enrolled device
regex='("id":")([^"]*)(",)'
if [[ $responseForSystemId =~ $regex ]]; then
    executingSystemId="${BASH_REMATCH[2]}"
fi

# Call JC API to get Device Groups info, filtered by Device Group name e.g. Mac Devices
responseForDeviceGroupId=$(
    curl -s -f -X GET https://console.jumpcloud.com/api/v2/systemgroups?filter=name:eq:Mac+Devices \
        -H 'Accept: application/json' \
        -H 'Content-Type: application/json' \
        -H "x-api-key: ${jcAPIKey}"
)

# String manipulation to get Device Group ID
if [[ $responseForDeviceGroupId =~ $regex ]]; then
    macSystemGroupId="${BASH_REMATCH[2]}"
fi

# Call JC API to add System to Device Group
addSystemToGroup=$(
    curl -s -f -X POST https://console.jumpcloud.com/api/v2/systemgroups/${macSystemGroupId}/members \
        -H 'Accept: application/json' \
        -H 'Content-Type: application/json' \
        -H "x-api-key: ${jcAPIKey}" \
        -d '{
            "op":"add",
            "type":"system",
            "id":"'${executingSystemId}'"
        }'
)
