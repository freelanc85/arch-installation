#!/usr/bin/env bash
source ./variables.sh
source ./functions.sh

# Run install
installBase
installSoftware
installSoftwareAur
finalSetup