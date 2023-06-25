# TODO:
# write userscript to setup Java and install Minecraft server on VM launch
# copy ./start_server.sh to the server
# create cron job to start server on reboot

# install java
sudo apt-get update -y
sudo apt-get install openjdk-17-jre-headless -y

# download minecraft
curl https://piston-data.mojang.com/v1/objects/84194a2f286ef7c14ed7ce0090dba59902951553/server.jar

# cron job to start minecraft server on system startup
echo @reboot sh -c "cd /home/minecraft && /usr/bin/java -Xmx2048M -Xms1024M -jar /home/minecraft/server.jar nogui" | sudo tee /var/spool/cron/crontabs/minecraft

# accept EULA
cat << EOF
#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA).
#Thu Jun 22 02:10:56 UTC 2023
eula=TRUE
EOF >> /home/minecraft/eula.txt

# minecraft server.properties
cat << EOF
#Minecraft server properties
#Sun Jun 25 02:56:51 UTC 2023
enable-jmx-monitoring=false
rcon.port=25575
level-seed=
gamemode=survival
enable-command-block=false
enable-query=false
generator-settings={}
enforce-secure-profile=true
level-name=world
motd=Welcome to "What The Fish" Minecraft Server
query.port=25565
pvp=true
generate-structures=true
max-chained-neighbor-updates=1000000
difficulty=easy
network-compression-threshold=256
max-tick-time=60000
require-resource-pack=false
use-native-transport=true
max-players=20
online-mode=false
enable-status=true
allow-flight=true
initial-disabled-packs=
broadcast-rcon-to-ops=true
view-distance=10
server-ip=
resource-pack-prompt=
allow-nether=true
server-port=25565
enable-rcon=false
sync-chunk-writes=true
op-permission-level=4
prevent-proxy-connections=false
hide-online-players=false
resource-pack=
entity-broadcast-range-percentage=100
simulation-distance=10
rcon.password=
player-idle-timeout=0
force-gamemode=false
rate-limit=0
hardcore=false
white-list=false
broadcast-console-to-ops=true
spawn-npcs=true
spawn-animals=true
function-permission-level=2
initial-enabled-packs=vanilla
level-type=minecraft\:normal
text-filtering-config=
spawn-monsters=true
enforce-whitelist=false
spawn-protection=16
resource-pack-sha1=
max-world-size=29999984
EOF > /home/minecraft/server.properties
