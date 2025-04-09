#!/bin/bash

HOSTED_ZONE_ID="Z0032297EA4MG7TE714I"

# List all record sets (if you have more than the default records, pagination might be necessary)
aws route53 list-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --max-items 100 > records.json

# Loop over each record that is not NS or SOA
cat records.json | jq -c '.ResourceRecordSets[]' | while read -r record; do
    TYPE=$(echo "$record" | jq -r '.Type')
    NAME=$(echo "$record" | jq -r '.Name')

    # Skip the required NS and SOA records
    if [[ "$TYPE" == "NS" || "$TYPE" == "SOA" ]]; then
        continue
    fi

    echo "Deleting ${TYPE} record: ${NAME}"

    # Prepare the JSON payload for the delete action
    CHANGE_BATCH=$(jq -n --argjson rec "$record" '{Changes: [{Action: "DELETE", ResourceRecordSet: $rec}]}')
    
    aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --change-batch "$CHANGE_BATCH"
done
