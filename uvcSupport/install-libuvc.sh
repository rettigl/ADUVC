#!/bin/bash

EPICS_HOST_ARCH=linux-x86_64
#EPICS_HOST_ARCH=linux-arm

echo "Building libuvc with expected EPICS target $EPICS_HOST_ARCH..."


if [ -d 'libuvc' ];
then
    echo "Removing existing libuvc build artefacts..."
    rm -rf libuvc
fi


echo "Grabbing libuvc..."
# Install libuvc by cloning from github and running cmake
git clone https://github.com/jwlodek/libuvc.git
cd libuvc
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make

# return to support directory
cd ../..

# Remove existing include folder if necessary.
if [ -d 'include' ];
then
    rm -rf include
fi

echo "Copying and updating include files..."
# Copy the library include files
cp -r libuvc/include .


# Remove template file and replace with auto-populated
# header file generated by cmake build
rm include/libuvc/libuvc_config.h.in
cp libuvc/build/include/libuvc/libuvc_config.h include/libuvc/.

# The internal uvc include file has a failing include for libusb.
sed -i "s/#include <libusb.h>/#include <libusb-1.0\/libusb.h>/g" include/libuvc/libuvc_internal.h


# This line will compile the program and place a copy of the libs in /usr/local. 
# It is recommended to keep it uncommented to compile the helper programs.
# This is also required if using dynamic linking, and moving the executable.
#
#echo "Installing libuvc to system location..."
#sudo make install


# Moves libs into the correct positions for EPICS.
# Clear old 'os' folder first, if exsits.
if [ -d "os" ];
then
    rm -rf os
fi


echo "Copying compiled library files..."
mkdir os
mkdir os/$EPICS_HOST_ARCH
cp libuvc/build/libuvc.a os/$EPICS_HOST_ARCH/.
cp libuvc/build/libuvc.so* os/$EPICS_HOST_ARCH/.

# Remove build artefacts.
rm -rf libuvc
echo "Finished installing libuvc."