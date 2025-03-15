#!/bin/bash

# Define the list of exceptions
EXCEPTIONS=("filesets" "wav" "scripts" "transcriptions.txt" "lexicon.txt" "run_usc.sh" "cleanup.sh")

echo "Cleaning up the directory, but keeping:"
for item in "${EXCEPTIONS[@]}"; do
    echo "   - $item"
done

# Loop through all items in the directory
for item in *; do
    # Check if item is in exceptions list
    if [[ ! " ${EXCEPTIONS[@]} " =~ " $item " ]]; then
        rm -rf "$item"
        echo "Deleted: $item"
    fi
done

echo "Cleanup completed!"

