#!/bin/bash

tmux new-session -d -s fishcraft 'java -Xmx2048M -Xms1024M -jar server.jar nogui'
