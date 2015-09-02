#!/bin/bash

IFS=$'\n' 	# Make newlines the only seperator
PLAYLISTURL="https://www.youtube.com/playlist?list=PLMLBPF3TpA2QuUbUuJAINVixCmFL931Fv"
SURL=/home/edgar/Desktop/videos

# Create videos directory if it already doesnt exist
if [ -d ${SURL} ]
then
	echo "${SURL} already created"
else
	echo "Creating ${SURL} directory"
	sudo mkdir ${SURL}
	sudo mkdir ${SURL}/Videos
	sudo chmod 777 ${SURL}/Videos
	sudo chmod 777 ${SURL}
fi

echo "Downloading playlist information"
sudo youtube-dl --get-filename -i $PLAYLISTURL > ${SURL}/tmp 2>/dev/null
echo "Done"


# Check and download each video accordingly
# Video that already exists locally will not be downloaded
for v in `sudo cat ${SURL}/tmp`
do
	# Get title of video
	TITLE=`echo -n ${v%%-*.mp4}`
	sudo echo -n $TITLE >> ${SURL}/info

	# Get id of video
	ID=`echo -n ${v#*-}`
	ID=`echo -n ${ID%.mp4}`
	sudo echo -$ID >> ${SURL}/info
done

# Begin to download missing videos
echo "Downloading missing youtube videos from playlist"
for i in `sudo cat ${SURL}/info`
do
	T=`echo -n ${i%%-*}`
	I=`echo -n ${i#*-}`

	echo $T
	echo $I

	# TODO: Check if video already exists locally
	if [ -e ${SURL}/${T}.mp4 ]
	then
		echo "${SURL}/${T}.mp4 already exists"
	else
		youtube-dl -i -o ${SURL}/Videos/${T}.mp4 https://youtube.com/watch?v=${I}
		wait
		
	fi

done
echo "Done."

# Clean up work
sudo rm ${SURL}/tmp
sudo rm ${SURL}/info

echo "Starting playback"
setterm -cursor off
SERVICE="omxplayer"


if [ -t 0 ]; then stty -echo -icanon -icrnl time 0 min 0; fi
keypress=''

while [ "x$keypress" = "x" ]
do
keypress="`cat -v`"
if ps ax | grep -v grep | grep ${SERVICE} > /dev/null
then
	sleep 1
else
	for vid in ${SURL}/Videos/*.mp4
	do
		keypress="`cat -v`"
		if [ "$keypress" = "x" ]
		then
			echo "x key pressed"
			sleep 1
			break
		fi
		clear
		#sudo omxplayer ${vid} > /dev/null
		sleep 1
	done
fi
done

if [ -t 0 ]; then stty sane; fi