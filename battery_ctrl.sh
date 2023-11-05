#!/bin/sh

if [ $# != 2 ]
then
  echo "No start and stop thresholds specified."
  echo "example: $ battery_ctrl.sh 70 80"
  exit
fi

ACPI_BATTERY_HANDLE=$(sysctl dev.acpi_ibm.0.%location | cut -f2 -d'=')

acpi_call -p $ACPI_BATTERY_HANDLE.BCCS -i $1

acpi_call -p $ACPI_BATTERY_HANDLE.BCSS -i $2







# Copyright (C) 2023 Dr.Amr Osman, consultant of cardiology 
# License-Identifier: BSD-3-Clause
