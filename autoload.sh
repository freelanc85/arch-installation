#!/usr/bin/env bash

# variables
source ./variables.sh

# packages
for file in ./packages/*.sh
do
  source $file
done

# functions
for file in ./functions/*.sh
do
  source $file
done
