#!/bin/sh
#set -x

# check permissions
if ! [ "$(id -u)" -eq 0 ]
then
  echo "Please re-execute again as root."
  exit 1
fi

#check acpi_call kernel module and try to load it if not loaded
if [ $(kldstat | grep -c "acpi_call") -eq 0 ]
then
  echo "acpi_call kernel modules not loaded."
  echo "loading acpi_call ..."
  
  kldload acpi_call
  
  if [ $(kldstat | grep -c "acpi_call") -eq 0 ]
  then
    echo "acpi_call kernel modules failed to load."
    exit 2 
  fi
fi

#check if the user provided two args
if [ $# != 2 ]
then
  echo "No start and stop thresholds specified."
  echo "example: # battery_ctrl.sh 70 80"
  exit 3
fi

#check if start threshold is a digit
if ! [ $(echo $1 | grep -E '^[0-9]+$') ] 
then
   echo "Error: Not a valid number."
   exit 4
fi

#check if stop threshold is a digit
if ! [ $(echo $2 | grep -E '^[0-9]+$') ] 
then
   echo "Error: Not a valid number."
   exit 4
fi

#check if start threshold is less than stop threshold
if [ $1 -ge $2 ]
then
  echo "The start threshold must be less than the stop threshold."
  exit 6
fi

#check if start threshold is in range
if [ $1 -gt 100 ] || [ $1 -lt 0 ]   
then
  echo "start thrshold must be a number in the range of 0 - 100 "
  exit 7
fi

#check if stop threshold is in range
if [ $2 -gt 100 ] || [ $2 -lt 0 ]   
then
  echo "stop thrshold must be a number in the range of 0 - 100 "
  exit 8
fi

#obtaining the battery handle
ACPI_BATTERY_HANDLE=$(sysctl dev.acpi_ibm.0.%location | cut -f2 -d'=')

#applying the start threshold
SUCCESS_START=$(acpi_call -p $ACPI_BATTERY_HANDLE.BCCS -i $1)

if [ $SUCCESS_START != 0 ]
then
  echo "failed to set start threshold."
  exit 9
else 
  echo "start threshold was set to : $1"
fi

#applying the stop threshold
SUCCESS_STOP=$(acpi_call -p $ACPI_BATTERY_HANDLE.BCSS -i $2)

if [ $SUCCESS_STOP != 0 ]
then
  echo "failed to set stop threshold."
  exit 10 
else 
  echo "stop threshold was set to : $2"
fi


# Copyright (C) 2023 Dr.Amr Osman, consultant of cardiology 
# License-Identifier: BSD-3-Clause
