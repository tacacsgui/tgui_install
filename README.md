# Installation script for TacacsGUI
There is no need to worry about dependencies, packages or libraries now. All you need is clear **Ubuntu 18.04.x**.
I hope it will be intuitive for you and you will enjoy installation process.

## Requerements:
1. Clear **Ubuntu 18.04.x** (you can download iso here)

## Script does three steps:
1. (Optional) **Set Interface Settings** (you have to do that only once)
2. **Install Dependencies** (! Internet Required !)
3. **Install Frameworks, Libraries, Web Interface and so on** (! Internet Required !)

## Prepare and run your script
- Move to home, delete old data (if it is) and download latest release (or just copy/past):

`cd ~; sudo rm -r tgui_install*; wget https://github.com/tacacsgui/tgui_install/archive/tgui_install.tar.gz`
- Unpack and move to unpacked files:

`mkdir tgui_install; tar -xvf tgui_install.tar.gz -C ~/tgui_install/ --strip-components 1; cd ./tgui_install`
- Make it executable and run:

`sudo chmod 755 ./tacacsgui.sh ; sudo ./tacacsgui.sh`
# OR
`sudo chmod 755 ./tacacsgui.sh ; sudo ./tacacsgui.sh silent`

**silent** run fast installation process.




### Step 1. Set Interface Settings :satellite:
If it is you first installation, you have to prepare network interface for communication.
From the main menu your choice is **3**, **Network Settings**.
```
###############################################################
##############   TACACSGUI Installation Script    ##############
###############################################################

ver. 1.0.0

##############     List of available options    ##############

1) Install TacacsGUI       5) Clear and Refresh Menu
2) Re-install TacacsGUI    6) Write to Log file
3) Network Settings        7) Quit
4) Test the System

Please enter your choice (5 to clear output): 3
```
Now you have to select interface that will be the main one.
Now you have to select interface that will be the main one. To show all available interfaces choose **1** (**Show Interface List**) and then choose **3** (**Configure interface**), type selected interface and finish network configuration settings.
I hope it will be very intuitive for you and you will get success.
```
###############################################################
##############   TACACSGUI Network Settings Script    #########
###############################################################

ver. 1.0.0

##############     List of available options    ##############

1) Show Interface List      4) Clear and Refresh Menu
2) Show Interface Settings  5) Back to Main Menu
3) Configure interface

Please enter your choice (4 to clear output):
```
To return to **Main Menu** select **5**.
### Step 2. Install Dependencies :see_no_evil:
From the **Main Menu** select option number **1**, **Install TacacsGUI** (or Re-install TacacsGUI if required).
On this step you doesn't need to do anything, just see as the script resolve all boring stuff.
There are some checks on this step:
1. Check network settings. If you did not do Step 1, script will notify you and this step will exit.
2. Check installed packges. If some package missing, script will try to download and install it.
3. Check connectivity to *github.com*.
4. Check connectivity to *packagist.org* (Composer).
5. Check connectivity to *tacacsgui.com*.
6. Check tac_plus daemon existence. If tac_plus does not installed, script will try to install it for you. There is an archive inside of this package, downloaded from [the Marc's Huber site](http://www.pro-bono-publico.de/projects/) (now it is *DEVEL.201903091339.tar.bz2*).
7. Check PHP version. Now it is the latest version - 7.3. If your server does not have it, the script will try to resolve that issue for you.
8. Check Pip. I can't just pass by Python, hope it will take more places in the project. As in the previous checks it will be installed if you don't have it yet.
9. Check Composer. If you don't have it yet or have old version, it will installed.
10. Check root access to two files: */opt/tacacsgui/tac_plus.sh* and */opt/tacacsgui/main.sh*. Do you know how to use `sudo visudo`? Don't worry script will do that for you.
11. Check Ubuntu version. Unfornunately, only *16.04.x* supported.

Ok. That all. If you finally see menu of Step 3, it means Step 2 was finished successfully! :sunglasses:
### Step 3. Install Frameworks, Libraries, Web Interface and so on :hammer:
It is here your help is needed. Script will ask you **MySQL root password** and if it is the first installation password for the *tgui_user*. :exclamation: Password containing special characters like **!,&,\*,/** and so on **will destroy the script**, it is **a bug**. Please, **set alphanumeric password**, to avoid it. Sorry for inconvenience.:exclamation:
```
###############################################################
##############   TACACSGUI Installation    #########
###############################################################

ver. 1.0.0


Start Installation
Check database...
Try to get root password to MySQL...Not Found
Enter root password to mysql:
Done. Correct password
Remember root password? (y/n): n
Test existence of tgui database...tgui database was created
Test existence of tgui_log database...tgui_log database was created
...
bla bla bla, some boring stuff
...
Tacacs Daemon setup...
tac_plus.service is not a native service, redirecting to systemd-sysv-install
Executing /lib/systemd/systemd-sysv-install enable tac_plus
Daemon apploaded
Test Daemon work...Done
Final Check...Check main libraries...Done. Congratulation!
Press any key to exit...
```
If you see the last three lines, like above, it is a time to check Web Interface!
There are two ways:
- **https**://*\<your ip address\>*:**4443**
- **http**://*\<your ip address\>*:**8008**

After installation I recommend to upgrade your system, use command `sudo apt-get full-upgrade -y` for that.

Hope you will enjoy installation process and you does not meet any trouble.
If you want to help, you are welcome! Also you can be my Patron [on Patreon](https://www.patreon.com/tacacsgui), you can stimulate me do updates more often.
# [<img src="https://tacacsgui.com/wp-content/uploads/2018/11/1000px-Patreon_logo_with_wordmark.png" width="40%">](https://www.patreon.com/tacacsgui)

Best Regards, Aleksey
