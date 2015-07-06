> This is pre Alpha

# Run Sponge Vanilla in a VM

This here explains how to run Sponge Vanilla from scratch.

## Prerequisites

Following explains how to setup the prerequisites.  If your setup differs, you have adopt yourself.  No support.

Following assumptions:

- You have VM running under KVM
- VM has installed Debian Wheezy with a minimal Install (just `SSH` and `Standard System Utilities`)
- You have an LVM setup with separate LVs for root, /usr, /var and so on
- VM has enough resources like RAM, CPU, Disk.
  - No recommendations here how much, as it is a VM these are tunable parameters which can be changed easily.
- You do not have a direct Internet connection (no default route), only an `HTTP(S)` proxy to the outside world
  - Note that this is best practise, as having machines directly connected to the Internet always must be considered a major security risk.  Never expose things to the Internet if there is no direct inevitable need for it.  Period.
  - So much to IPv6.  Nope, firewalling is not the solution.  Firewalling is a symptom which shows the stupidity of the whole idea of having everything directly connected to the Internet!
- You know how to use SSH and come from some Unix system which is able to directly connect to the VM

Following will be explained:

- How to update to (Debian Jessie without SystemD)[http://permalink.de/tino/jessie].
- How to setup everything for compiling / running Sponge Vanilla.
- How to setup a user `mc` which runs everything
- How to run everything as the user `mc`

Following parameters (if yours differ, change accordingly.  Sorry, I cannot help you.  Period.) are used in the examples below:

- Machine from which you are installing is `medusa` (this probably is the host which runs the VM)
- VM you are installing into is called `sponge`
- Unprivileged user running in `medusa` and created on `sponge` for login: `tino`
- `tino` has `su` access (so you know the `root` password of `sponge`)
- User to run Sponge in: `mc`
- Network: 192.168.122.0/24
- Proxy at: 192.168.122.1:8080
- IP: 192.168.122.17
- You have a setup such, that `ssh sponge` opens a connection to the VM

Notes:
- If you have no DNS for `sponge` this can be done in `~/.ssh/config` and looks like:
```
Host sponge
        Hostname 192.168.122.17
```


## From Debian Wheezy minimal to Debian Jessy prepared to install Sponge Vanilla

Note: If you just want to install Sponge Vanilla in a already existing user, skip this steps up to "Setup Sponge-Vanilla"

> **Beware:**
>
> This guide replaces some system files unconditionally which most certainly **breaks productive servers**!
>
> Only do this on your dedicated new sponge VM such that nothing else harmed and you always can start fresh from scratch if something terribly goes wrong.
> I am not responsible if you break anything with this guide.  If unsure, do not follow this!  Backups are your friend.

I cannot help you if you get stuck.  Just follow this guide exactly to the point and it should work as shown.


### Prepare SSH login and reboot just to be sure

So we have a fresh, minimal installed Debian without gateway.

Note that I will leave away uninteresting clutter in future output, but here is the full one such that you can feel comfortable by seeing everything:

```
tino@medusa:~$ ssh-copy-id sponge
The authenticity of host '[127.1.0.4]:2207 ([127.1.0.4]:2207)' can't be established.
ECDSA key fingerprint is 20:e1:43:06:3c:7c:19:4a:b8:2c:91:d9:d9:bf:6a:7d.
Are you sure you want to continue connecting (yes/no)? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
tino@127.1.0.4's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'sponge'"
and check to make sure that only the key(s) you wanted were added.

tino@medusa:~$ ssh sponge
Linux sponge 3.2.0-4-amd64 #1 SMP Debian 3.2.68-1+deb7u2 x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Fri Jul  3 13:56:44 2015 from 192.168.122.1

tino@sponge:~$ cat /etc/network/interfaces 
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet static
 address 192.168.122.17
 netmask 255.255.255.0
 broadcast 192.168.122.255
 #gateway 192.168.122.1

tino@sponge:~$ cat /etc/resolv.conf 
nameserver 192.168.122.1

tino@sponge:~$ df
Filesystem              1K-blocks   Used Available Use% Mounted on
rootfs                     329233 143652    168583  47% /
udev                        10240      0     10240   0% /dev
tmpfs                       50884    216     50668   1% /run
/dev/mapper/sponge-root    329233 143652    168583  47% /
tmpfs                        5120      0      5120   0% /run/lock
tmpfs                      101760      0    101760   0% /run/shm
/dev/vda1                  233191  17807    202943   9% /boot
/dev/mapper/sponge-home   3632432  72788   3375120   3% /home
/dev/mapper/sponge-tmp     297485  10254    271871   4% /tmp
/dev/mapper/sponge-usr    3523616 413972   2930652  13% /usr
/dev/mapper/sponge-var    1713424 158140   1468244  10% /var

tino@sponge:~$ su -
Password: 
root@sponge:~# reboot

Broadcast message from root@sponge (pts/0) (Fri Jul  3 14:02:35 2015):

The system is going down for reboot NOW!
root@sponge:~# Connection to 192.168.122.17 closed by remote host.
Connection to 192.168.122.17 closed.
tino@medusa:~$ ssh sponge
Linux sponge 3.2.0-4-amd64 #1 SMP Debian 3.2.68-1+deb7u2 x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Fri Jul  3 14:01:35 2015 from 192.168.122.1
tino@sponge:~$ 
```

For reference just the command sequence entered:
- `ssh-copy-id sponge` and at the prompt `yes`
- `ssh sponge` which then brings us into the VM
- `cat /etc/network/interfaces` to see the networking setup
- `cat /etc/resolv.conf` to see the nameserver
- `df` to see the filesystem setup
- `su -` and at the password prompt the `password` of "root" of the VM
- `reboot` to make the VM reboot
- `ssh sponge` again to jump into the VM after reboot

Note:  Thanks to it being a VM a full reboot of the VM is assumed to take less than 10 seconds (no, I am not kidding).  Hence reboot can be done frequently.

### Setup APT

It is assumed that you need a proxy `192.168.122.1:8080` to download things.  Also this is a fresh wheezy install, right?  So we do the minimum and to prepare Jessie.

```
tino@sponge:~$ su -

echo 'Acquire::http::Proxy "http://192.168.122.1:8080/";' > /etc/apt/apt.conf
apt-get update

apt-get install sysvinit sysvinit-utils

cat <<'EOF' >/etc/apt/sources.list
deb     http://security.debian.org/     jessie/updates    main contrib non-free
deb-src http://security.debian.org/     jessie/updates    main contrib non-free

deb     http://http.debian.net/debian/  jessie            main contrib non-free
deb-src http://http.debian.net/debian/  jessie            main contrib non-free
deb     http://http.debian.net/debian/  jessie-updates    main contrib non-free
deb-src http://http.debian.net/debian/  jessie-updates    main contrib non-free

deb     http://http.debian.net/debian/  jessie-backports  main contrib non-free
deb-src http://http.debian.net/debian/  jessie-backports  main contrib non-free
EOF
apt-get update
apt-get install sysvinit-core

apt-get upgrade

apt-get dist-upgrade

apt-get dist-upgrade
# Note the list which are "no longer required" and purge them.  YMMV
apt-get purge   libbind9-80 libdns88 libgssglue1 libisc84 libisccc80 libisccfg82 liblwres80 openssh-blacklist openssh-blacklist-extra python-fpconst

reboot
```

Please note that `apt-get install` asks something, so you cannot just copy+paste this on the commandline, do it command by command, please, and always finish things afterwards.  I leave a blank line after commands, which need some interaction.

Notes:

- This pulls a lot via the proxy, so be sure you have a fast Internet connection.
- If some problems arise, fix them.  Each step must be completed successfully before you start the next step.
- The `apt-get dist-upgrade` is likely to fail for the first time.  Just repeat it a second time.


### Cleanups and `sudo`

Debian minimal is not really minimal.  I hate that.  So I usually clean it up a bit.  If you do like editors like `nano` in favor of `vim`, then change that to your likings.

```
tino@sponge:~$ su -

uname -a
# You will see that there is a new kernel active now, so we can clean fully
apt-get install apt-show-version

apt-show-versions | grep -v '/jessie[- ]'
# This shows some more packages with "No available version in archive", purge them, too: YMMV
apt-get purge libboost-iostreams1.49.0:amd64 libgcrypt11:amd64 libgnutls26:amd64 libprocps0:amd64 libtasn1-3:amd64 libudev0:amd64 linux-image-3.2.0-4-amd64:amd64 python2.6-minimal:amd64

# The easiest way to get rid of the very annoying default editor and other things
apt-get purge nano

apt-get purge rpcbind nfs-common

apt-get install sudo vim

# Be sure to add your user instead of `tino` to following command
# such that you can use `sudo` in future instead of `su`
# Do *not* add the `mc` user to the sudo group, this is a security risk!
adduser tino sudo

apt-get upgrade
# Again, something no more needed to purge.  YMMV
apt-get purge   libevent-2.0-5 libnfsidmap2 libtirpc1

reboot
```

Now that we have `sudo`, things get easier.

### Add a timeserver

You probably do not need this, however I always do this.  My timeserver is named `meine.uhr.geht.net.`

```
tino@sponge:~$ 

# Now add some Timeserver
sudo apt-get install openntpd

sudo tee /etc/openntpd/ntpd.conf <<EOF
server meine.uhr.geht.net.
EOF
sudo /etc/init.d/openntpd restart
sudo tee -a /etc/network/interfaces <<EOF
 up route add -host meine.uhr.geht.net. gw 192.168.122.1
EOF

sudo reboot
```

### Pull in development 

Probably not all packages are needed.  However it does not hurt much to install everything.

```
tino@sponge:~$ 

sudo apt-get install tmux git build-essential openjdk-7-jdk liblog4j1.2-java

# No we should configure a bit.  Pull it from where you think it's best:
for a in .vimrc .screenr .tmux.conf; do wget http://hydra.geht.net/"$a"; done
```

### Setup `sponge` user

```
tino@sponge:~$ 

sudo adduser --disabled-password --gecos 'Minecraft Sponge Vanilla' sponge
```

Notes:
- The user usually gets the default shell `bash`
- And now that everything is set up, we can install Sponge

## Setup Sponge-Vanilla

### Set the proxies

> You do not need this step if you are connected transparently to the Internet.

If you are behind a proxy, you need to source them, such that everything works as expected.

```
tino@sponge:~$ sudo su - sponge

cat <<'EOF' >> ~/.bashrc

# Proxy settings
PHOST=192.168.122.1
PPORT=8080
export http_proxy=http://$PHOST:$PPORT/
export https_proxy=http://$PHOST:$PPORT/
export JAVA_OPTS="-Dhttp.proxyHost=$PHOST -Dhttp.proxyPort=$PPORT -Dhttps.proxyHost=$PHOST -Dhttps.proxyPort=$PPORT"
EOF

. ~/.bashrc
```

### Checkout source, build and install
```
tino@sponge:~$ sudo su - sponge

git clone https://github.com/hilbix/Sponge-Vanilla.git src
cd src
make
```

### Install Sponge

```
tino@sponge:~$ sudo su - sponge

mkdir sponge
cp src/jar/spongevanilla.jar sponge/
cd sponge
java -Xms1024M -Xmx1024M -jar spongevanilla.jar
```
This crashes, because it cannot connect to the Internet.  There are 2 variants how to fix this:

#### Run spongevanilla with proxy setting

This means, it can transparently connect to the Internet.

```
java $JAVA_OPTS -Xms1024M -Xmx1024M -jar spongevanilla.jar
```

Note that you only need to run it with the proxies once if you want to run Sponge without a permanent Internet connectivity.


#### Alternative: Download manually

As `~/.bashrc` contains the `http_proxy` setting you can use wget:
```
wget https://s3.amazonaws.com/Minecraft.Download/versions/1.8/minecraft_server.1.8.jar
cd lib
wget https://libraries.minecraft.net/net/minecraft/launchwrapper/1.12/launchwrapper-1.12.jar
cd ..
```

Note that the URLs might change.  The Java error tells you the URL which cannot be downloaded, so you can find the correct one.


### Configure Sponge

```
tino@sponge:~$ sudo su - sponge

cd sponge
sed -i 's/eula=false/eula=true/' eula.txt
```

#### Disable Minecraft Login servers

If your server cannot transparently connect to the Internet (sadly, proxies do not help here) you must switch off the authentication check of the server:

```
sed -i 's/online-mode=true/online-mode=false/' server.properties
```
