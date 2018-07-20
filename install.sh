#!/bin/bash

if [ $# -eq 0 ]; then
	echo "Please enter private key."
	echo "Usage: ./install.sh <private key>"
	exit 1
fi
