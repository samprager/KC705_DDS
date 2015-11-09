#!/bin/sh

# Targeted Reference Design for Kintex-7

# Driver compilation and module build script
# Author: Xilinx Inc.

# Clean and build the driver objects

cd linux_driver
make clean
make
cd ..

# Clean and build the XPMON Application

cd linux_driver/xpmon
make clean
make
cd ../../

# Insert the driver modules into the kernel

cd linux_driver
sudo make insert
cd ..
echo "Driver Modules Loaded"

sleep 1
lsmod

# Start the GUI
./linux_driver/xpmon/xpmon

# Remove driver modules

cd linux_driver
sudo make remove
cd ..# Remove driver objects

