#!/bin/bash
update_resources() {
    # Path to your JSON file
    json_file="metabase.json"

    # Folder to check for directories named after containers
    folder_to_check="./"

    # Read container names along with their resource limits and requests, and update values.yaml if directory exists
    jq -c '.[] | {container, recommended: {requests: {cpu: .recommended.requests.cpu.value, memory: .recommended.requests.memory.value}, limits: {cpu: .recommended.limits.cpu.value, memory: .recommended.limits.memory.value}}}' "$json_file" | while read -r data; do
        container=$(echo "$data" | jq -r '.container')
        dir_path="${folder_to_check}/${container}"
        values_file="${dir_path}/values.yaml"

        if [ -d "$dir_path" ]; then
            echo "Directory exists for container: $container. Checking values.yaml..."

            if [ -f "$values_file" ]; then
                # Ensure the resources object exists before modifying it
                yq -i -y '
                    .resources |= .resources // {"limits": {}, "requests": {}}
                    | .resources.limits |= .resources.limits // {}
                    | .resources.requests |= .resources.requests // {}
                ' "$values_file"

                # Extract resource values from JSON or signal to delete
                cpu_limit=$(echo "$data" | jq -r '.recommended.limits.cpu // empty')
                memory_limit=$(echo "$data" | jq -r '.recommended.limits.memory // empty')
                cpu_request=$(echo "$data" | jq -r '.recommended.requests.cpu // empty')
                memory_request=$(echo "$data" | jq -r '.recommended.requests.memory // empty')

                # Update or delete CPU limits
                if [ -z "$cpu_limit" ]; then
                    yq  -i -y 'del(.resources.limits.cpu)' "$values_file"
                else
                    cpu_limit=$(echo "$cpu_limit * 1000 / 1" | bc)m
                    yq  -i -y "(.resources.limits.cpu) = \"$cpu_limit\"" "$values_file"
                fi

                # Update or delete memory limits
                if [ -z "$memory_limit" ]; then
                    yq  -i -y 'del(.resources.limits.memory)' "$values_file"
                else
                    memory_limit=$(echo "$memory_limit / 1048576 / 1" | bc)Mi
                    yq  -i -y "(.resources.limits.memory) = \"$memory_limit\"" "$values_file"
                fi

                # Update or delete CPU requests
                if [ -z "$cpu_request" ]; then
                    yq  -i -y 'del(.resources.requests.cpu)' "$values_file"
                else
                    cpu_request=$(echo "$cpu_request * 1000 / 1" | bc)m
                    yq  -i -y "(.resources.requests.cpu) = \"$cpu_request\"" "$values_file"
                fi

                # Update or delete memory requests
                if [ -z "$memory_request" ]; then
                    yq  -i -y 'del(.resources.requests.memory)' "$values_file"
                else
                    memory_request=$(echo "$memory_request / 1048576 / 1" | bc)Mi
                    yq  -i -y "(.resources.requests.memory) = \"$memory_request\"" "$values_file"
                fi

                echo "Updated values.yaml for container: $container with provided or default resource settings"

                # helm-upgrade -e prod -n "$container" || exit 1
            else
                echo "values.yaml does not exist in $dir_path"
            fi
        else
            echo "No directory found for container: $container"
        fi
    done

    rm -rf $json_file
}

update_resources

# get_optimized_resources() {
#     krr simple -p http://127.0.0.1:65400 --logtostderr --allow-hpa -w 1 -f json | jq '[.scans[] | {container: .object.container, recommended: {requests: {cpu: {value: .recommended.requests.cpu.value}, memory: {value: .recommended.requests.memory.value}}, limits: {cpu: {value: .recommended.limits.cpu.value}, memory: {value: .recommended.limits.memory.value}}}}]' > prod-simp.json
# }