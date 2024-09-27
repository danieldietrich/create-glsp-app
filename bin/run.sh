#!/bin/bash

# Exit if any command fails
set -e

# Set variables
REPO_URL="https://github.com/eclipse-glsp/glsp-examples"
TEMPLATES_DIR="project-templates"

# Create a temporary directory
TMP_DIR=$(mktemp -d)

# Clone the repository
git clone --depth 1 $REPO_URL "$TMP_DIR"

# List subdirectories and prompt user to choose
# shellcheck disable=SC2207,SC2035
subdirs=($(cd "$TMP_DIR/$TEMPLATES_DIR" && ls -d *))

# Function to display menu
display_menu() {
    echo -e "Please select the GLSP template:\n"
    local current=$1
    for i in "${!subdirs[@]}"; do
        if [ "$i" -eq "$current" ]; then
            printf "\033[7m%2d. %s\033[0m\n" "$((i+1))" "${subdirs[$i]}"
        else
            printf "%2d. %s\n" "$((i+1))" "${subdirs[$i]}"
        fi
    done
}

# Initialize selection
current=0

# Clear screen and display initial menu
clear
display_menu $current

# Handle user input
while true; do
    read -r -s -n 1 key
    case "$key" in
        A) # Up arrow
            if [ $current -gt 0 ]; then
                ((current--))
            fi
            ;;
        B) # Down arrow
            if [ $current -lt $((${#subdirs[@]}-1)) ]; then
                ((current++))
            fi
            ;;
        '') # Enter key
            selected_template="${subdirs[$current]}"
            break
            ;;
        *)
            continue
            ;;
    esac

    # Clear screen and redisplay menu
    clear
    display_menu $current
done

echo -e "\nYou selected: $selected_template"
TARGET_DIR="${1:-$selected_template}"

if [ "$TARGET_DIR" = "." ]; then
    echo "Copying the template to the current directory..."
else
    echo "Copying the template to $TARGET_DIR..."
    mkdir -p "$TARGET_DIR"
fi

cp -R "$TMP_DIR/$TEMPLATES_DIR/$selected_template/." "$TARGET_DIR/"

echo "Done!"

# Cleanup
rm -rf "$TMP_DIR"
