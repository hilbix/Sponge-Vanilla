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
- You know how to use SSH and come from some Unix system which is able to directly connect to the VM

Following will be explained:

- How to update to (Debian Jessie without SystemD)[http://permalink.de/tino/jessie].
- How to setup everything for compiling / running Sponge Vanilla.
- How to setup a user `mc` which runs everything
- How to run everything as the user `mc`

Following parameters (if yours differ, change accordingly.  Sorry, I cannot help you.  Period.)

- Machine from which you are installing is `medusa`
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


## Setup

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
- `df` to see the filesystem setup
- `su -` and at the password prompt the password of "root" of the VM
- `reboot` to make the VM reboot
- `ssh sponge` again to jump into the VM after reboot

Note:  Thanks to it being a VM a full reboot of the VM is assumed to take less than 10 seconds.  Hence reboot can be done frequently.
