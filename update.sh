#!/bin/bash

# Get user's home directory
USERHOME=`eval echo "~$USER"`

DAEMON_TAR_URL=$(curl -s https://api.github.com/repos/oxidcoin/oxid_2.0/releases/latest | grep browser_download_url | grep linux-oxidd | cut -d '"' -f 4)
CLI_TAR_URL=$(curl -s https://api.github.com/repos/oxidcoin/oxid_2.0/releases/latest | grep browser_download_url | grep linux-oxid-cli | cut -d '"' -f 4)

DAEMON_TAR_NAME=$(curl -s https://api.github.com/repos/oxidcoin/oxid_2.0/releases/latest | grep browser_download_url | grep linux-oxidd | cut -d '"' -f 4 | cut -d "/" -f 9)
CLI_TAR_NAME=$(curl -s https://api.github.com/repos/oxidcoin/oxid_2.0/releases/latest | grep browser_download_url | grep linux-oxid-cli | cut -d '"' -f 4 | cut -d "/" -f 9)

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
echo '#    Updating daemon...            #'
echo '####################################'

/usr/bin/oxid-cli stop

sleep 5

chmod 0755 $USERHOME/oxidd
chmod 0755 $USERHOME/oxid-cli
sudo mv $USERHOME/oxidd /usr/bin/oxidd
sudo mv $USERHOME/oxid-cli /usr/bin/oxid-cli

echo '####################################'
echo '#    Removing old files...         #'
echo '####################################'
rm -rf $USERHOME/.oxidred/accumulators
rm -rf $USERHOME/.oxidred/blocks
rm -rf $USERHOME/.oxidred/chainstate
rm -rf $USERHOME/.oxidred/database
rm -rf $USERHOME/.oxidred/sporks
rm $USERHOME/.oxidred/db.log
rm $USERHOME/.oxidred/debug.log
rm $USERHOME/.oxidred/.lock
rm $USERHOME/.oxidred/oxidd.pid
rm $USERHOME/.oxidred/peers.dat
rm $USERHOME/.oxidred/mncache.dat
rm $USERHOME/.oxidred/mnpayments.dat

echo "Updated the daemon"

echo '####################################'
echo '#    Starting daemon...            #'
echo '####################################'
echo ''

/usr/bin/oxidd -daemon

echo "Daemon started"

echo '###########################################'
echo '#    Syncing VPS wallet..., please wait   #'
echo '###########################################'
echo ''

until su -c "oxid-cli mnsync status 2>/dev/null | grep 'IsBlockchainSynced\" : true' > /dev/null" "$USER"; do 
  echo -ne "Current block: $(su -c "oxid-cli getblockcount" "$USER")\\r"
  sleep 1
done

clear

output=""
required_message="Masternode successfully started"

while [[ $output != *"$required_message"* ]]
do
    echo "$output"
    output="$(oxid-cli startmasternode local false)"
    sleep 10
done

echo ''
echo '###################################################'
echo '# Your masternode/supernode update was sucessful. #'
echo '###################################################'
