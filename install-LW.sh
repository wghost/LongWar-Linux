#!/bin/bash
# Long War Linux install script

# default values
USERFILES=~/.local/share/feral-interactive/XCOM/XEW
INSTALLDIR=~/.local/share/Steam/SteamApps/common/XCom-Enemy-Unknown

MOD_DATA_DIR=`dirname $0`/install-files
MOD_CONFIG_DIR=${MOD_DATA_DIR}/xew/xcomgame/config

FERAL_OVERRIDES="xew/xcomgame/localization/int/xcomgame.int xew/xcomgame/localization/int/xcomuishell.int"
FERAL_OVERRIDE_DIR="xew/binaries/share/feraloverrides"

LW_FILES=`find ${MOD_DATA_DIR} -type f | sed s,${MOD_DATA_DIR},,g`

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
rm -f $usersaves/*
rm -f $userconf/*

# iterate through LW files and backup corresponding game files
# for each LW upk file check if corresponding .upk.uncompressed_size file exist, back it up and delete
for file in ${LW_FILES}; do
	case "$file" in
		*upk)
			if [ -e ${INSTALLDIR}/$file.uncompressed_size ]; then
				mv ${INSTALLDIR}/$file.uncompressed_size $gamebackup/$file.uncompressed_size
			fi
			;;
	esac
done

# backup xcomgame.int and xcomuishell.int in feraloverrides
for file in ${FERAL_OVERRIDES}; do
	if [ -e ${INSTALLDIR}/${FERAL_OVERRIDE_DIR}/`basename $file` ]; then
		mv "${INSTALLDIR}/${FERAL_OVERRIDE_DIR}/`basename $file`" ${gamebackup}/${FERAL_OVERRIDE_DIR}/`basename $file`
	fi
done

# backup remaining files
for file in ${LW_FILES}; do
	if [ -e ${INSTALLDIR}/${file} ]; then
		mv ${INSTALLDIR}/${file} ${gamebackup}/
	fi
done

# copy LW files to game dir
cp -r ${MOD_DATA_DIR}/* ${INSTALLDIR}

# copy xcomgame.int and xcomuishell.int to feraloverrides
for file in ${FERAL_OVERRIDES}; do
	cp ${MOD_DATA_DIR}/$file ${INSTALLDIR}/${FERAL_OVERRIDE_DIR}/`basename $file`
done

# copy LW defaultgamecore.ini to WritableFiles/XComGameCore.ini
cp ${MOD_CONFIG_DIR}/defaultgamecore.ini ${USERFILES}/WritableFiles/XComGameCore.ini

# copy LW defaultloadouts.ini to WritableFiles/XComLoadouts.ini
cp ${MOD_CONFIG_DIR}/defaultloadouts.ini ${USERFILES}/WritableFiles/XComLoadouts.ini

exit 0

# end of install script
