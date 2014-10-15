#!/bin/bash
#echo BIOTRUMP_DIR=$BIOTRUMP_DIR
if [[ -z "$BIOTRUMP_DIR" ]]; then
  BIOTRUMP_DIR=$(cd `dirname ${BASH_SOURCE[0]}`; pwd)
#  echo ">>>BIOTRUMP_DIR=$BIOTRUMP_DIR"
fi
#echo "<<<BIOTRUMP_DIR=$BIOTRUMP_DIR"

. "$BIOTRUMP_DIR/.config"
if [ $? -ne 0 ]; then
	echo Could not load .config. Did you run config.sh?
	exit -1
fi

if [ -f "$BIOTRUMP_DIR/.userconfig" ]; then
	. "$BIOTRUMP_DIR/.userconfig"
fi

# Use default Gecko location if it's not provided in config files.
#if [ -z $GECKO_PATH ]; then
#  GECKO_PATH=$BIOTRUMP_DIR/gecko
#fi

VARIANT=${VARIANT:-eng}
#PRODUCT_NAME=${PRODUCT_NAME:-full_${DEVICE}}
#DEVICE=${DEVICE:-${PRODUCT_NAME}}
#LUNCH=${LUNCH:-${PRODUCT_NAME}-${VARIANT}}
#DEVICE_DIR=${DEVICE_DIR:-device/*/$DEVICE}
