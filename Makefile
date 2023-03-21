export DOCKER_CMD = podman
export VIVADO_VERSION = 2022.2
export WEB_INSTALLER = Xilinx_Unified_2022.2_1014_8888_Lin64
export UBUNTU_VERSION = 20.04
export USERNAME=${USER}

.PHONY: all extract token config

all: extract token config

extract: $(WEB_INSTALLER)/xsetup
token: $(WEB_INSTALLER)/wi_authentication_key 
config: $(WEB_INSTALLER)/install_config.txt 

$(WEB_INSTALLER)/xsetup:
	echo "Decompress Installer..."
	chmod +x $(WEB_INSTALLER).bin 
	./$(WEB_INSTALLER).bin --keep --noexec --target $(WEB_INSTALLER)

$(WEB_INSTALLER)/wi_authentication_key: $(WEB_INSTALLER)/xsetup
	echo "Generate authentication key..."
	$(WEB_INSTALLER)/xsetup -b AuthTokenGen && mv -f ~/.Xilinx/wi_authentication_key $(WEB_INSTALLER)

$(WEB_INSTALLER)/install_config.txt: $(WEB_INSTALLER)/xsetup
	echo "Generate instalation config ..."
	$(WEB_INSTALLER)/xsetup -b ConfigGen && mv ~/.Xilinx/install_config.txt $(WEB_INSTALLER)

clean:
	$(RM) -rf $(WEB_INSTALLER)
	$(RM) -rf ~/.Xilinx/install_config.txt
	$(RM) -rf ~/.Xilinx/wi_authentication_key

image: $(WEB_INSTALLER)/wi_authentication_key $(WEB_INSTALLER)/install_config.txt
	echo "Creating docker image..."
	$(DOCKER_CMD) build  --no-cache --squash -f Dockerfile \
	--build-arg WEB_INSTALLER=$(WEB_INSTALLER)   \
	--build-arg UBUNTU_VERSION=$(UBUNTU_VERSION) \
	--build-arg VIVADO_VERSION=${VIVADO_VERSION} \
	--build-arg USERNAME=$(USERNAME) \
	--build-arg CONFIG_FILE=install_config.txt \
	--build-arg TOKEN_FILE=wi_authentication_key \
	--tag vivado:$(VIVADO_VERSION) .




# xsetup --agree 3rdPartyEULA,XilinxEULA 
# --batch Install --edition "Vitis Unified Software Platform" --location "/home/Xilinx"


	
# ./xsetup -b Install -a XilinxEULA,3rdPartyEULA -c <path_to_configuration_file>



