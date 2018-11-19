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

echo "Updated the daemon"

echo '####################################'
echo '#    Starting daemon...            #'
echo '####################################'
echo ''

/usr/bin/oxidd -daemon

echo "Daemon started"

output=""
required_message="Masternode successfully started"

while [[ $output != *"$required_message"* ]]
do
    echo "$output"
    output="$(oxid-cli masternode status)"
    sleep 10
done

echo ''
echo '###################################################'
echo '# Your masternode/supernode update was sucessful. #'
echo '###################################################'
