#!/bin/bash

# attach to terminal docker dev container
adc() {
    # List available containers
    echo "Available containers:"
    docker ps --format "{{.Names}}" | nl

    # Prompt user to select a container
    echo -n "Enter the number of the container you want to attach to: "
    read container_number

    # Get the selected container name
    selected_container=$(docker ps --format "{{.Names}}" | sed -n "${container_number}p")

    if [ -z "$selected_container" ]; then
        echo "Invalid selection. Please try again."
        return 1
    fi

    # Set default command
    local command="${1:-bash}"

    # Check if the container name contains "dev" and use the dev user
    if [[ "$selected_container" == *dev* ]]; then
        docker exec -it -u dev "$selected_container" $command
    else
        # For other containers, use root user
        docker exec -it "$selected_container" $command
    fi
}

# Call the function
adc "$@"

