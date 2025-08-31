# Define the music folder and log file path
MUSIC_FOLDER="/files/music/"
LOG_FILE="/tmp/navidrome_logfile.log"
#LOG_SERVICE="/tmp/service_music.log"
# Create the log directory if it doesn't exist
# Change directory to the music folder
cd "$MUSIC_FOLDER"
# Check if Navidrome is already running
if pgrep -x "navidrome" > /dev/null; then
    echo "Navidrome is already running. Exiting."
else
    # Run Navidrome command, redirecting output to the log file and detaching it from the terminal
    setsid nohup navidrome --musicfolder "$MUSIC_FOLDER" > "$LOG_FILE" 2>&1 &
#    setsid nohup loophole http 4533 --hostname ajattix > "$LOG_SERVICE" 2>&1 &
    echo "Navidrome started and detached from the terminal."
fi
