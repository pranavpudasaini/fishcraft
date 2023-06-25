#!/bin/sh

# tmux new-session -d -s fishcraft 'java -Xmx2048M -Xms1024M -jar server.jar nogui'
cd /home/minecraft
/usr/bin/java -Xmx2048M -Xms1024M -jar server.jar nogui
