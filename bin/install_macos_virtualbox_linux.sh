#!/bin/bash

VBOXIMG = "macOS Sonoma"

# Suppress the annoying warnings about keyboards and such
VBoxManage setextradata global GUI/SuppressMessages "all"

VBoxManage modifyvm $VBOXIMG --cpuid-set 00000001 000106e5 00100800 0098e3fd bfebfbff

VBoxManage setextradata $VBOXIMG "VBoxInternal/Devices/efi/0/Config/DmiSystemProduct" "MacBookPro15,1"

VBoxManage setextradata $VBOXIMG "VBoxInternal/Devices/efi/0/Config/DmiSystemVersion" "1.0"

VBoxManage setextradata $VBOXIMG "VBoxInternal/Devices/efi/0/Config/DmiBoardProduct" "Mac-551B86E5744E2388"

VBoxManage setextradata $VBOXIMG "VBoxInternal/Devices/smc/0/Config/DeviceKey" "ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"

VBoxManage setextradata $VBOXIMG "VBoxInternal/Devices/smc/0/Config/GetKeyFromRealSMC" 1

VBoxManage setextradata $VBOXIMG "VBoxInternal/TM/TSCMode" "RealTSCOffset"

# Set the CPU to Intel, as it won't work with anything else
VBoxManage modifyvm $VBOXIMG --cpu-profile "Intel Core i7-6700K"

