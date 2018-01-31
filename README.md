# ktester 

This is our attempt to make compiling of custom linux kernel(for kernel dev) followed by their testing in a virtual environment as easy as possible. 

## Prereq:

- Install docker on your system
  - For Ubuntu: https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce-1
  - For Windows 10: https://docs.docker.com/docker-for-windows/install/#what-to-know-before-you-install
- Check your installation using -
  - `sudo docker run -it ubuntu` (for windows)
  - This will take some time as it will download ubuntu image.
  - It will change your prompt to something like `root@4d4c9750e9e0:/#`. This is the shell of an full fledged ubuntu running on docker.
  
  
## Usage: 

- Clone this repo on your system using: `git clone https://github.com/geekSiddharth/ktester.git`

- Run the following commands:
  ```
    cd ktester
    chmod +x *.sh
    ./compile_and_run.sh <absolute path to your linux kernal>
    ```

  The last command you executed is going to take a lot a lot of time.It is going to compile the kernal present in the path you gave. This code is said to be executed successfully if you see something like this at the end and with no further progress.  
  DO NOT EXIT (or press Ctrl + C or Ctrl + D)

  ```
  ARCH=x86_64 qemu/qemu.sh -kernel /kp/arch/x86/boot/bzImage -enable-kvm -device virtio-serial -chardev pty,id=virtiocon0 -device virtconsole,chardev=virtiocon0 -net nic,model=virtio,vlan=0 -net tap,ifname=tap0,vlan=0,script=no,downscript=no -drive file=core-image-minimal-qemux86-64.ext4,if=virtio,format=raw --append "root=/dev/vda console=hvc0" --display none -m 512M -s 
  char device redirected to /dev/pts/1 (label virtiocon0)

  ```

  **Observe the ending `/dev/pts/1`. You may have a *different number* at the end.** We will refer to it as `pts number`. Our `pts number` is `1`.  

- Open another terminal and change directory to `ktester`

- Get to know the containter id
  ```
  ➜  ktester git:(master) sudo docker ps 
  [sudo] password for sid: 
  CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
  37fee7fd2351        geeksid/ktest:dev   "/bin/sh -c 'make ..."   26 minutes ago      Up 26 minutes                           quirky_ride

  ```

  **37fee7fd2351*** is the *container id*. You will have *a different number* on your system.  

- In our case, we will execute `./enter_shell.sh 37fee 1`.   
  The formate of the command it: `./enter_shell.sh <container_id> <pts number>`  
  Usually first few characters of container id are enough. 
  

**YOU ARE DONE NOW**


You will get something like this: 
```
Welcome to minicom 2.7

OPTIONS: I18n 
Compiled on Feb  7 2016, 13:37:27.
Port /dev/pts/1, 09:14:51

```
Press enter and you will see something like this prompting for login
```
Poky (Yocto Project Reference Distro) 2.4 qemux86-64 /dev/hvc0

qemux86-64 login:
```
The login id is `root`. 



 ### Old instructions


PLEASE set the KDIR first for this to work.

In the makefile, after the realpath, enter the path to your linux kernel source
`KDIR=$(shell realpath ~/kp/)`

You should have qemu-system-x86 installed for x86.

When you are all set..

try :
`make boot`

then using minicom


`minicom -D /dev/pts/4`

The number may varry ...

Dependency:

build-essential
qemu-system-x86
qemu-system-arm // if you care about arm
kvm 
minicom
