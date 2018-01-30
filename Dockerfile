FROM ubuntu
MAINTAINER Siddharth Yadav


RUN apt-get update &&  && apt-get install -yf \
                                        qemu-kvm \
                                        make \
                                        gcc \
                                        unzip \
                                        wget \ 
                                        qemu \
                                        virt-manager \
                                        virt-viewer \
                                        libvirt-bin \
                                        libelf-dev \ 
                                        chrpath \
                                        gawk \
                                        texinfo \
                                        libsdl1.2-dev \
                                        whiptail \
                                        diffstat \
                                        cpio \
                                        libssl-dev \
                                        bc


RUN rm -rf /var/lib/apt/lists/*


RUN mkdir /workstation
COPY . /workstation

RUN mkdir /kp
VOLUME ["/kp/"]
