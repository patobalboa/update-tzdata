#!/bin/bash

#Patricio Balboa - CodePlus.cl

#This script is used to update the tzdata files.
#It is used to update the tzdata files when a new version of the tzdata files is released.
#This script is for CentOS 6.x and 7.x

#Verify that the script is being run with superuser privileges.
if [[ "${UID}" -ne 0 ]]
then
  echo 'Please run this scritp with sudo or as root.'
  exit 1
fi

#Install lzip if it is not installed.
if ! hash lzip 2>/dev/null; then
  yum install -y lzip
fi

#Install gcc if it is not installed.
if ! hash gcc 2>/dev/null; then
  yum install -y gcc
fi 


#Input parameter to set the timezone.
read -p 'Enter the timezone you want to set (e.g. America/New_York): ' TZ


#Download the latest version of the tzdata files.
echo 'Downloading the latest version of the tzdata db files...' 
curl -O https://data.iana.org/time-zones/releases/tzdb-2022c.tar.lz

#Extract the tzdata files.
echo 'Extracting the tzdata files...'
tar --lzip -xvf tzdb-2022c.tar.lz

#Remove the tzdata file archive.
echo 'Removing the tzdata file archive...'
rm tzdb-2022c.tar.lz

#cd to the tzdata directory.
cd tzdb-2022c

#Compile the tzdata files.
echo 'Compiling the tzdata files...'
make

#Install the tzdata files.
echo 'Installing the tzdata files...'
make install

#Remove the tzdata directory.
echo 'Removing the tzdata directory...'
rm -rf ../tzdb-2022c

#Update the tzdata.
echo 'Updating the tzdata...'

#If the command fails, exit the script.
if ! timedatectl set-timezone ${TZ} ; then
  echo 'Error: timedatectl set-timezone failed.'
  exit 1
else
  echo 'Timezone set to '${TZ}
  #echo timedatectl status
  timedatectl status | echo
  echo 'The tzdata files were updated successfully.'
  exit 0
fi




