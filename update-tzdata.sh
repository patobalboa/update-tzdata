#!/bin/bash

#Patricio Balboa - CodePlus.cl

#This script is used to update the tzdata files.
#It is used to update the tzdata files when a new version of the tzdata files is released.




#Verify that the script is being run with superuser privileges.
if [[ "${UID}" -ne 0 ]]
then
  echo 'Please run this scritp with sudo or as root.'
  exit 1
fi
#If the system operative is Ubuntu or Centos, then the script will continue.
if [[ "${ID}" == "ubuntu" ]]
then
    #Install lzip if it is not installed.
    if [[ "$(dpkg -s lzip 2>/dev/null | grep -c 'Status: install ok installed')" -eq 0 ]]
    then
        apt-get install lzip
    fi
    #Install gcc if it is not installed.
    if [[ "$(dpkg -s gcc 2>/dev/null | grep -c 'Status: install ok installed')" -eq 0 ]]
    then
        apt-get install gcc
    fi
elif [[ "${ID}" == "centos" ]]
then
    #Install lzip if it is not installed with yum.
    if ! hash lzip 2>/dev/null; then
    yum install -y lzip
    fi

    #Install gcc if it is not installed.
    if ! hash gcc 2>/dev/null; then
    yum install -y gcc
    fi 
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
  #Print timedatectl status.
    timedatectl status
  
  echo 'The tzdata files were updated successfully.'
  exit 0
fi




