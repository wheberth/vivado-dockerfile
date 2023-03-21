ARG UBUNTU_VERSION=20.04
FROM ubuntu:${UBUNTU_VERSION} AS build

ARG VIVADO_VERSION=2022.2
ARG WEB_INSTALLER="Xilinx_Unified_2022.2_1014_8888_Lin64"
ARG LOCATION="/opt/Xilinx"
ARG PRODUCT="Vivado"
ARG EDITION="Vivado ML Standard"
ARG USERNAME=user
ARG CONFIG_FILE="install_config.txt"
ARG TOKEN_FILE="wi_authentication_key"

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install --no-install-recommends -y locales
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8

# Dependencies
RUN apt-get install -y libstdc++6 libgtk2.0-0 dpkg-dev
RUN apt-get install -y libtinfo5 libtinfo-dev libncurses5 libncurses5-dev libncursesw5-dev libtcmalloc-minimal4 libxtst6
RUN ln -s /usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4 /usr/lib/x86_64-linux-gnu/libtcmalloc.so.4 
RUN apt-get install -y python3-pip
RUN apt-get install --no-install-recommends -y sudo
RUN ln -s /usr/bin/make /usr/bin/gmake

 
# ADD ${UNIFIED_INSTALLER}.tar.gz /tmp/vivado-install-dir # <- not working
ADD ${WEB_INSTALLER} /tmp/vivado-install-dir

RUN chmod +x /tmp/vivado-install-dir/xsetup
RUN mkdir -p /root/.Xilinx
RUN ls -lah /tmp/vivado-install-dir/${TOKEN_FILE}

RUN cp /tmp/vivado-install-dir/${TOKEN_FILE} /root/.Xilinx/${TOKEN_FILE}
RUN cd /tmp/vivado-install-dir && ./xsetup --agree XilinxEULA,3rdPartyEULA --product ${PRODUCT} --edition ${EDITION} --location ${LOCATION}  --batch Install -c ${CONFIG_FILE}

RUN useradd -U -m ${USERNAME} && usermod -G users ${USERNAME}
RUN adduser ${USERNAME} sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Cleaning up 
RUN rm -rf /tmp/vivado-install-dir


WORKDIR /home/${USERNAME}
USER ${USERNAME}
RUN echo "source  ${LOCATION}/Vivado/${VIVADO_VERSION}/settings64.sh" > .bashrc
RUN echo "parse_git_branch() { git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/' ; }" >> .bashrc
RUN echo "export PS1='\${debian_chroot:+(\$debian_chroot)}\[\033[01;32m\]\u@\h\[\033[01;36m\]<vivado:$VIVADO_VERSION>\[\033[00m\]:\[\033[01;34m\]\w\\[\033[33m\]\$(parse_git_branch)\[\033[00m\]\$ ' " >> .bashrc

ENTRYPOINT ["bash","-i"]
