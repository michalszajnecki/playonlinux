#!/bin/bash
# Date : (2012-05-17 21:00)
# Last revision : (2018-03-01 00:00)
# Wine version used : 3.2
# Distribution used to test : Ubuntu 16.04.3 LTS (Xenial Xerus) 64x
# Author : Aragmor
# Licence : Retail
# Only For : http://www.playonlinux.com
 
## Begin Note ##
# This script is based on the version published by GNU_Raziel on https://www.playonlinux.com/en/app-1126-Guild_Wars_2.html
# Client may crash every few MB when downloading game, no crash when playing - see Bug #30511 - http://bugs.winehq.org/show_bug.cgi?id=30511
# Used Awesomium patch to fix Bug #27168 - http://bugs.winehq.org/show_bug.cgi?id=27168
## End Note ##
 
[ "$PLAYONLINUX" = "" ] && exit 0
source "$PLAYONLINUX/lib/sources"
 
TITLE="Guild Wars 2"
PREFIX="GuildWars2"
FILENAME="Gw2.exe"
EDITOR="ArenaNet"
GAME_URL="http://www.guildwars2.com"
AUTHOR="Aragmor"
GAME_VMS="4096"
 
# Starting the script
POL_GetSetupImages "http://files.playonlinux.com/resources/setups/gw2/top.jpg" "http://files.playonlinux.com/resources/setups/gw2/left.jpg" "$TITLE"
POL_SetupWindow_Init
POL_SetupWindow_SetID 1126
 
# Starting debugging API
POL_Debug_Init
 
POL_SetupWindow_presentation "$TITLE" "$EDITOR" "$GAME_URL" "$AUTHOR" "$PREFIX"
 
# Setting Wine Version
WORKING_WINE_VERSION="3.2"
 
# Setting prefix path
POL_Wine_SelectPrefix "$PREFIX"
 
# Choose a 32-Bit or 64-Bit architecture
POL_SetupWindow_menu_list "$(eval_gettext 'Select architecture')" "$TITLE" "auto~x86~amd64" "~" "auto"
ARCHITECTURE="$APP_ANSWER"
 
# Downloading wine if necessary and creating prefix
POL_System_SetArch "$ARCHITECTURE"
POL_Wine_PrefixCreate "$WORKING_WINE_VERSION"
 
# (Added by Tinou) Seems to help with random crash issue
Set_OS "win7"
 
# Choose between Downloading client or using local one
POL_SetupWindow_InstallMethod "DOWNLOAD,LOCAL,CD"
 
# Asking about memory size of graphic card
POL_SetupWindow_VMS $GAME_VMS
 
# Set Graphic Card information keys for wine
POL_Wine_SetVideoDriver
 
# Fix for this game
POL_Wine_X11Drv "GrabFullscreen" "Y"
 
# Downloading client or choosing existing one
mkdir -p "$WINEPREFIX/drive_c/$PROGRAMFILES/ArenaNet/Guild Wars 2"
if [ "$INSTALL_METHOD" = "DOWNLOAD" ]; then
        # Donwloading client
        cd "$WINEPREFIX/drive_c/$PROGRAMFILES/ArenaNet/Guild Wars 2"
        if [ "$ARCHITECTURE" = "amd64" ]; then
                POL_Download "https://s3.amazonaws.com/gw2cdn/client/branches/Gw2-64.exe"
                FILENAME="Gw2-64.exe"
        else
                POL_Download "https://cloudfront.guildwars2.com/client/Gw2.exe"
                FILENAME="Gw2.exe"
        fi
elif [ "$INSTALL_METHOD" = "LOCAL" ]; then
        # Asking for client exe
        cd "$HOME"
        POL_SetupWindow_browse "$(eval_gettext 'Please select the setup file to run')" "$TITLE"
        SETUP_EXE="$APP_ANSWER"
        cp "$SETUP_EXE" "$WINEPREFIX/drive_c/$PROGRAMFILES/ArenaNet/Guild Wars 2/Gw2.exe"
else
        POL_Call POL_Wine_InstallCDROM "1" "w" "GW2Setup.exe"
        POL_Wine_WaitBefore "$TITLE"
        POL_Wine start /unix "$CDROM/Gw2Setup.exe"
        POL_Call POL_Wine_InstallCDROM "2" "w" "Gw2.js2"
        POL_Wine_WaitExit "$TITLE"
fi
 
# Making shortcut
POL_Shortcut "$FILENAME" "$TITLE" "$TITLE.png" "-dx9single -autologin" "Game;RolePlaying;"
 
# Begin installation
cd "$WINEPREFIX/drive_c/$PROGRAMFILES/ArenaNet/Guild Wars 2"
POL_Wine start /unix $FILENAME -repair -image
 
POL_SetupWindow_Close
exit 0