## Vivado docker
Dockerfile and Makefile to automate the cration of a Vivado Docker.
Currently in version 2023.1

You will need to download the Vivado Web Installer on your own.
The automated installation of Vivado requires an authentication token.
This process handled by the Makefile. You will need an Valid Xilinx account.

#Steps to generate the docker image
* Clone this repo;
* Download "Xilinx_Unified_2023.1_0507_1903_Lin64.bin" inside the repo folder;
* run `$make image`;