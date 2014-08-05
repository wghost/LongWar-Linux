#!/bin/bash
# Long War Linux install script

# default values
USERFILES=~/.local/share/feral-interactive/XCOM/XEW
INSTALLDIR=~/.local/share/Steam/SteamApps/common/XCom-Enemy-Unknown/xew

echo "Installing Long War for XCOM:EW, please, be patient..."

# checking command line parameters
if [ -z $1 ]
	then
		userfiles=$USERFILES
	else
		userfiles=$1
fi

if [ -z $2 ]
	then
		installdir=$INSTALLDIR
	else
		installdir=$2
fi

# checking if directories exist
if [ -d $userfiles ]
	then
		echo "User files dir: $userfiles"
	else
		echo "$userfiles is not a directory!"
		exit 1
fi

if [ -d $installdir ]
	then
		echo "Install dir: $installdir"
	else
		echo "$installdir is not a directory!"
		exit 1
fi

# backup existing files
userbackup=$USERFILES/backup
gamebackup=$installdir/backup

echo "Writing backup to:"

echo "User files: $userbackup"

# check if backup dir already exist
#if [ -d $userbackup ]
#	then
#		echo -n "$userbackup already exists. Owerwrite? (y/n) "
#		read yn
#	if [[ $yn == y || $yn == Y ]]
#		then
#			echo "Removing $userbackup and all its content..."
#			rm -rf $userbackup
#		else
#			exit 1
#	fi
#fi
  
mkdir $userbackup

echo "Game files: $gamebackup"

# check if backup dir already exist
#if [ -d $gamebackup ]
#	then
#		echo -n "$gamebackup already exists. Owerwrite? (y/n) "
#		read yn
#	if [[ $yn == y || $yn == Y ]]
#		then
#			echo "Removing $gamebackup and all its content..."
#			rm -rf $gamebackup
#		else
#			exit 1
#	fi
#fi
  
mkdir $gamebackup

# backup user files
usersaves=$USERFILES/savedata
userconf=$USERFILES/WritableFiles

cp -r $usersaves $userbackup
cp -r $userconf $userbackup

# clear user files
#rm -f $usersaves/*
#rm -f $userconf/*

# iterate through LW files and backup corresponding game files
# for each LW upk file check if corresponding .upk.uncompressed_size file exist, back it up and delete

# backup xcomgame.int and xcomuishell.int in feraloverrides

# copy LW files to game dir

# copy xcomgame.int and xcomuishell.int to feraloverrides

# copy LW defaultgamecore.ini to WritableFiles/XComGameCore.ini

# copy LW defaultloadouts.ini to WritableFiles/XComLoadouts.ini

exit 0

# end of install script