# Wait 5 minutes before running script. Seems like it takes a bit of time after the system is registered before we are able to retrieve the relevant info via API calls.
# Start-Sleep 300

$jcAPIKey="<JC API Key>"
$windowsDeviceGroupName="Windows Devices"

# Retrieve Serial Number of Windows Device through CLI
$windowsDeviceSerialNumber = (Get-WmiObject win32_bios | Select SerialNumber).SerialNumber

# Call JC API to get information of enrolled systems, filtered with Serial Number
$headers=@{}
$headers.Add("x-api-key", $jcAPIKey)
$uri='https://console.jumpcloud.com/api/systems?filter=serialNumber:$eq:' + $windowsDeviceSerialNumber
$response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers

# String Manipulation to get SystemID of enrolled device
$deviceSystemID=$response.results.id

# Call JC API to get Device Groups info, filtered by Device Group Name e.g. Windows Device
$headers=@{}
$headers.Add("x-api-key", $jcAPIKey)
$uri='https://console.jumpcloud.com/api/v2/systemgroups?filter=name:eq:' + $windowsDeviceGroupName
$response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers

# String manipulation to get Device Group ID
$deviceGroupID=$response.id

# Call JC API to add System to Device Group
$headers=@{}
$headers.Add("x-api-key", $jcAPIKey)
$uri = "https://console.jumpcloud.com/api/v2/systemgroups/" + $deviceGroupID + "/members"
$body=@{"op"="add";
"type"="system";
"id"=$deviceSystemID;
} | ConvertTo-Json
$response = Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -ContentType 'application/json' -Body $body