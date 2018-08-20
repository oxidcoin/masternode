#!/bin/bash

# Get user's home directory
USERHOME=`eval echo "~$USER"`

DAEMON_TAR_URL=$(curl -s https://api.github.com/repos/oxidcoin/oxid/releases/latest | grep browser_download_url | grep linux | cut -d '"' -f 4)

DAEMON_TAR_NAME=$(curl -s https://api.github.com/repos/oxidcoin/oxid/releases/latest | grep browser_download_url | grep linux | cut -d '"' -f 4 | cut -d "/" -f 9)

# Install oxid
echo '####################################'
echo '#    Downloading daemon...         #'
echo '####################################'
echo ''
wget $DAEMON_TAR_URL
tar -xzvf $DAEMON_TAR_NAME
rm $DAEMON_TAR_NAME

echo '####################################'
echo '#    Updating daemon...            #'
echo '####################################'

/usr/bin/Oxidd stop

sleep 5

chmod 0755 $USERHOME/Oxidd
sudo mv $USERHOME/Oxidd /usr/bin/Oxidd

echo "Updated the daemon"

echo '####################################'
echo '#    Starting daemon...            #'
echo '####################################'
echo ''

/usr/bin/Oxidd -daemon

echo "Daemon started"

# Add cronjob
crontab -r
(crontab -l 2>/dev/null; echo "@reboot sleep 30 && /usr/bin/Oxidd -daemon") | crontab -

echo ''
echo '####################################'
echo "# It's time to update your wallet  #"
echo '####################################'

