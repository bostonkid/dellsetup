#!/bin/bash

# Configuration
BASE_URL="http://192.168.12.199:8200/MediaItems"
MIN=100
MAX=3500

# Create a temporary directory and socket for mpv IPC communication
SOCKET_DIR=$(mktemp -d)
SOCKET="${SOCKET_DIR}/mpv-socket"

# Clean up socket on exit
trap "rm -rf '${SOCKET_DIR}'" EXIT

# Arrays to manage video history
declare -a HISTORY=()
CURRENT_INDEX=-1

# Helper function to generate a random ID
get_random_id() {
    echo $(( RANDOM % (MAX - MIN + 1) + MIN ))
}

echo "Starting advanced DLNA player..."
echo "----------------------------------------"
echo "  Controls:"
echo "    [n] -> Next random video"
echo "    [p] -> Previous video (go back)"
echo "    [q] -> Quit player completely"
echo "----------------------------------------"
echo ""

while true; do
    # If we are navigating backward in history, use the existing history item
    if (( CURRENT_INDEX >= 0 && CURRENT_INDEX < ${#HISTORY[@]} )); then
        VIDEO_ID="${HISTORY[$CURRENT_INDEX]}"
        IS_HISTORY_PLAY=true
    else
        # Otherwise, pick a new random video and add it to our history stack
        VIDEO_ID=$(get_random_id)
        HISTORY+=("$VIDEO_ID")
        CURRENT_INDEX=$((${#HISTORY[@]} - 1))
        IS_HISTORY_PLAY=false
    fi

    VIDEO_URL="${BASE_URL}/${VIDEO_ID}.mp4"

    if [ "$IS_HISTORY_PLAY" = true ]; > /dev/null 2>&1
    then
        echo "▶️ [History $CURRENT_INDEX/${#HISTORY[@]}] Playing video ID: ${VIDEO_ID}"
    else
        echo "▶️ [New Random] Playing video ID: ${VIDEO_ID} (${#HISTORY[@]} total in history)"
    fi

    # Launch mpv with IPC input socket enabled in the background
    mpv --input-ipc-server="${SOCKET}" "${VIDEO_URL}" > /dev/null 2>&1 &
    MPV_PID=$!

    # Input listener loop while mpv is playing
    ACTION=""
    while kill -0 "${MPV_PID}" 2>/dev/null; do
        read -n 1 -s KEY
        if [[ "${KEY}" == "n" ]]; then
            ACTION="next"
            echo -e "\n⏭️ Skipping to next random video..."
            echo '{"command": ["quit"]}' | socat -u - "UNIX-CONNECT:${SOCKET}" 2>/dev/null
            break
        elif [[ "${KEY}" == "p" ]]; then
            if (( CURRENT_INDEX > 0 )); then
                ACTION="prev"
                echo -e "\n⏮️ Going back to previous video..."
                echo '{"command": ["quit"]}' | socat -u - "UNIX-CONNECT:${SOCKET}" 2>/dev/null
                break
            else
                echo -e "\n⚠️ Already at the oldest video in current history!"
            fi
        elif [[ "${KEY}" == "q" ]]; then
            echo -e "\n👋 Exiting player."
            kill "${MPV_PID}" 2>/dev/null
            exit 0
        fi
    done

    # Wait for mpv process to fully close
    wait "${MPV_PID}" 2>/dev/null

    # Adjust index based on user action
    if [[ "$ACTION" == "next" ]]; then
        CURRENT_INDEX=$((${#HISTORY[@]})) # forces generating a brand new random item next loop
    elif [[ "$ACTION" == "prev" ]]; then
        ((CURRENT_INDEX--))
    else
        # Video finished naturally on its own -> move forward as a new random selection
        CURRENT_INDEX=$((${#HISTORY[@]}))
    fi

    sleep 0.3
done
