#!/bin/bash

# Copyright (c) 2021 Emil Suleymanov <suleymanovemil8@gmail.com>
#
# This file is part of "Lenovo Conservation Mode Helper".
#
# "Lenovo Conservation Mode Helper" is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# "Lenovo Conservation Mode Helper" is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with "Lenovo Conservation Mode Helper".  If not, see
# <https://www.gnu.org/licenses/>.

set -e

MODULE_NAME="ideapad_laptop"
PROMPT="$MODULE_NAME is not loaded! Do you want to try loading it? [Y/n] "

ENABLE=0
DISABLE=0
ASSUME_YES=0

mod_check() {
    if lsmod | grep "$MODULE_NAME" &>/dev/null; then
        echo "$MODULE_NAME module is already loaded."
    else
        if [ "$ASSUME_YES" == "1" ]; then
            echo "${PROMPT}yes"
            response="yes"
        else
            read -r -p "$PROMPT" response
        fi

        response=${response,,}
        if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
            modprobe $MODULE_NAME
        else
            exit 0
        fi
    fi
}

print_usage() {
    echo "Usage:"
    echo "  $0 {--enable|-e|--disable|-d}"
    echo ""
    echo "Enable or disable the \"Battery Conservation Mode\" on Lenovo. If enabled, it"
    echo "will limit the battery charge to around 60%, to increase the battery lifespan."
    echo "The \"ideapad_laptop\" module is required for this feature to work."
    echo ""
    echo "Options:"
    echo " -d, --disable               disable the \"Battery Conservation Mode\""
    echo " -e, --enable                enable the \"Battery Conservation Mode\""
    echo " -y                          assume \"yes\" to all questions"
    echo " -h, --help                  display this help"
}

while test $# -gt 0; do
    case "$1" in
    --enable | -e)
        ENABLE=1
        ;;
    --disable | -d)
        DISABLE=1
        ;;
    -y)
        ASSUME_YES=1
        ;;
    --help|-h)
        print_usage
        exit 0
        ;;
    --*)
        print_usage
        exit 1
        ;;
    *)
        print_usage
        exit 1
        ;;
    esac
    shift
done

if [ "$ENABLE" == "1" ] && [ "$DISABLE" == "1" ]; then
    print_usage
    exit 1
elif [ "$ENABLE" == "1" ]; then
    mod_check
    # Turn on
    echo 1 >/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode
    echo "Conservation mode enabled."
elif [ "$DISABLE" == "1" ]; then
    mod_check
    # Turn off
    echo 0 >/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode
    echo "Conservation mode disabled."
else
    print_usage
    exit 1
fi
