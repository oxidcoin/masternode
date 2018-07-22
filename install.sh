#!/bin/bash

if [ $# -eq 0 ]; then
	echo "Please enter private key."
	echo "Usage: ./install.sh <private key>"
	exit 1
fi

# Get required parameters
SERVER_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
PRIVATE_KEY=$1

RPC_PORT=18933
DEFAULT_PORT=18932
SEED_1=seed1.oxid.io
SEED_2=seed2.oxid.io

# Generate random passwords
RPC_USER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
RPC_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# Get user's home directory
USERHOME=`eval echo "~$USER"`

DAEMON_TAR_URL=$(curl -s https://api.github.com/repos/oxidcoin/oxid/releases/latest | grep browser_download_url | grep linux | cut -d '"' -f 4)

DAEMON_TAR_NAME=$(curl -s https://api.github.com/repos/oxidcoin/oxid/releases/latest | grep browser_download_url | grep linux | cut -d '"' -f 4 | cut -d "/" -f 9)

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
tar -xzvf $DAEMON_TAR_NAME
rm $DAEMON_TAR_NAME


echo '####################################'
echo '#    Creating config directory...  #'
echo '####################################'
echo ''
# Make .Oxid directory
if [ ! -d $USERHOME/.Oxid ]; then
	mkdir $USERHOME/.Oxid
fi

# Create Oxid.conf
touch $USERHOME/.Oxid/Oxid.conf

# Paste configuration
cat > $USERHOME/.Oxid/Oxid.conf << EOL
rpcuser=${RPC_USER}
rpcpassword=${RPC_PASSWORD}
rpcport=${RPC_PORT}
port=${DEFAULT_PORT}
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
staking=0

masternodeaddr=${SERVER_IP}:${DEFAULT_PORT}
masternode=1
masternodeprivkey=${PRIVATE_KEY}

addnode=${SEED_1}
addnode=${SEED_2}
EOL

chmod 0755 $USERHOME/Oxidd
sudo mv $USERHOME/Oxidd /usr/bin/Oxidd
chmod 0600 $USERHOME/.Oxid/Oxid.conf
chown -R $USER:$USER $USERHOME/.Oxid

echo '####################################'
echo '#    Starting daemon...            #'
echo '####################################'
echo ''

Oxidd -daemon

# Add cronjob
(crontab -l 2>/dev/null; echo "@reboot sleep 30 && ${USERHOME}/Oxidd -daemon") | crontab -

echo ''
echo '####################################'
echo "# It's time to set up your wallet  #"
echo '####################################'

