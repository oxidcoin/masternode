#!/bin/bash

if [ $# -eq 0 ]; then
	echo "Please enter private key."
	echo "Usage: ./install.sh <private key>"
	exit 1
fi

# Get required parameters
SERVER_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
PRIVATE_KEY=$1

RPC_PORT=28933
DEFAULT_PORT=28932
SEED_1=104.207.132.149
SEED_2=45.76.247.235
SEED_3=seed3.oxid.io
SEED_4=seed4.oxid.io
SEED_5=seed5.oxid.io
SEED_6=seed6.oxid.io
SEED_7=seed7.oxid.io
SEED_8=seed8.oxid.io
SEED_9=seed9.oxid.io
SEED_10=seed10.oxid.io

# Generate random passwords
RPC_USER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
RPC_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# Get user's home directory
USERHOME=`eval echo "~$USER"`

DAEMON_TAR_URL=$(curl -s https://api.github.com/repos/oxidcoin/oxid_2.0/releases/latest | grep browser_download_url | grep linux-oxidd | cut -d '"' -f 4)
CLI_TAR_URL=$(curl -s https://api.github.com/repos/oxidcoin/oxid_2.0/releases/latest | grep browser_download_url | grep linux-oxid-cli | cut -d '"' -f 4)

DAEMON_TAR_NAME=$(curl -s https://api.github.com/repos/oxidcoin/oxid_2.0/releases/latest | grep browser_download_url | grep linux-oxidd | cut -d '"' -f 4 | cut -d "/" -f 9)
CLI_TAR_NAME=$(curl -s https://api.github.com/repos/oxidcoin/oxid_2.0/releases/latest | grep browser_download_url | grep linux-oxid-cli | cut -d '"' -f 4 | cut -d "/" -f 9)

# Install dependencies
echo '####################################'
echo '#    Installing dependencies...    #'
echo '####################################'
echo ''
sudo apt-get -y update && sudo apt-get -y install build-essential libssl-dev libdb++-dev libboost-all-dev libcrypto++-dev libqrencode-dev libminiupnpc-dev libgmp-dev libgmp3-dev autoconf autogen automake libtool autotools-dev pkg-config bsdmainutils software-properties-common libzmq3-dev libminiupnpc-dev libssl-dev libevent-dev

sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y

# Install oxid
echo '####################################'
echo '#    Downloading daemon...         #'
echo '####################################'
echo ''
wget $DAEMON_TAR_URL
wget $CLI_TAR_URL
tar -xzvf $DAEMON_TAR_NAME
tar -xzvf $CLI_TAR_NAME
rm $DAEMON_TAR_NAME
rm $CLI_TAR_NAME


echo '####################################'
echo '#    Creating config directory...  #'
echo '####################################'
echo ''
# Make .oxidred directory
if [ ! -d $USERHOME/.oxidred ]; then
	mkdir $USERHOME/.oxidred
fi

# Create oxid.conf
touch $USERHOME/.oxidred/oxid.conf

# Paste configuration
cat > $USERHOME/.oxidred/oxid.conf << EOL
rpcuser=${RPC_USER}
rpcpassword=${RPC_PASSWORD}
rpcport=${RPC_PORT}
port=${DEFAULT_PORT}
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
staking=0

masternode=1
externalip=${SERVER_IP}
bind=${SERVER_IP}
masternodeaddr=${SERVER_IP}:${DEFAULT_PORT}
masternodeprivkey=${PRIVATE_KEY}

addnode=${SEED_1}
addnode=${SEED_2}
addnode=${SEED_3}
addnode=${SEED_4}
addnode=${SEED_5}
addnode=${SEED_6}
addnode=${SEED_7}
addnode=${SEED_8}
addnode=${SEED_9}
addnode=${SEED_10}
EOL

chmod 0755 $USERHOME/oxidd
chmod 0755 $USERHOME/oxid-cli
sudo mv $USERHOME/oxidd /usr/bin/oxidd
sudo mv $USERHOME/oxid-cli /usr/bin/oxid-cli
chmod 0600 $USERHOME/.oxidred/oxid.conf
chown -R $USER:$USER $USERHOME/.oxidred

echo '####################################'
echo '#    Starting daemon...            #'
echo '####################################'
echo ''

oxidd -daemon

# Add cronjob
(crontab -l 2>/dev/null; echo "@reboot sleep 30 && /usr/bin/oxidd -daemon") | crontab -

echo '###########################################'
echo '#    Syncing VPS wallet..., please wait   #'
echo '###########################################'
echo ''

until su -c "oxid-cli mnsync status 2>/dev/null | grep 'IsBlockchainSynced\" : true' > /dev/null" "$USER"; do 
  echo -ne "Current block: $(su -c "oxid-cli getblockcount" "$USER")\\r"
  sleep 1
done

clear

echo '##########################################################################################'
echo '#    Start masternode/supernode in your local wallet. Waitting for it to be started...   #'
echo '##########################################################################################'
echo ''


read -rp "Press Enter if your local wallet masternode status is ENABLED. " -n1 -s

echo ""

output="error"
required_message="Masternode successfully started"

while [[ $output != *"$required_message"* ]]
do
    echo "$output"
    output="$(oxid-cli masternode status)"
    sleep 10
done

echo ''
echo '###################################################'
echo '# Your masternode/supernode setup was sucessful.  #'
echo '###################################################'
