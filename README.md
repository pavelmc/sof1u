ScrollOutF1 Updated
===================

This is a modified version of the ScrollOutF1 email gateway software.

The changes made was only the needed ones to make it run on moder Ubuntu (Xenial 16.04 LTS) and Debian (Stretch 9.x) systems.

Changelog:
==========

* 27 nov 2017: Repository creation based on the actual tar file from www.scrolloutf1.com page
* 27 nov 2017: Basic support for Ubuntu 16.04 LTS, in fact its teaked to **ONLY** work on that system at this point, it will not work on older ones (either Ubuntu or Debian) I will introduce more validations on the script to make it support older and new versions soon.

Roadmap
=======

* Validations on the script to supoort older Ubuntu OS (14.04 LTS)
* Support for Debian Stretch 9.x
* Validation and support for old/actual Debian versions (8 and 9 branches)


Installation
============

Note: If you are using a CT in proxmox please remove postfix before start to install with:

```
apt-get remove --purge postfix* -y
``` 

* Download the software with the green button on this page to your desktop.
* Copy the file sof1u-master.zip it to your base OS, in the /tmp folder.
* Extract it with:

```
unzip sof1u-master.zip
```

* Extract the scrollOut F1 folder from the created one with:

```
mv sof1u-master/* ./
```
 
* Change the permissions of the files with

```
chmod 755 /tmp/scrolloutf1/www/bin/*
```

* Invoke the install script with

```
/tmp/scrolloutf1/www/bin/install.sh
```

That's all.


Author
======

I'm Pavel Milanes a FLOSS lover, I live in Cuba where a masive migration to FLOSS are taking place system by system, all that by dedicated sysadmins who spend precious hours of his time to make thinks work and work fine.

This is my contribution for them, you can reach us by email or [telegram](https://t.me/sysadmincuba), also we have place on the net: [SysAdminsdeCuba](https://www.sysadminsdecuba.com)

Want to say thanks?
===================
If this mod work for you, please, say thanks in the way you like or contact me for instructions.
 

