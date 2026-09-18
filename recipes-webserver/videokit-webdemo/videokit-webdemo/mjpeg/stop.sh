echo -e "$(date)"
echo -e "Start Time: $(date +"%T.%6N")"
echo "Stopping ffmpeg..."
kill $(pidof ffmpeg)
kill $(pidof ffmpeg)
echo -e "End Time: $(date +"%T.%6N")"

