#!/bin/bash
# Long War Linux install script

# default values
USERFILES=~/.local/share/feral-interactive/XCOM/XEW
INSTALLDIR=~/.local/share/Steam/SteamApps/common/XCom-Enemy-Unknown

MOD_DATA_DIR=`dirname $0`/install-files
MOD_CONFIG_DIR=${MOD_DATA_DIR}/xew/xcomgame/config

FERAL_OVERRIDES="xew/xcomgame/localization/int/xcomgame.int xew/xcomgame/localization/int/xcomuishell.int"
FERAL_OVERRIDE_DIR="xew/binaries/share/feraloverrides"

LW_FILES=`find ${MOD_DATA_DIR}/ -type f | sed s,${MOD_DATA_DIR}/,,g`

echo "Installing Long War for XCOM:EW, please, be patient..."

dry_run=true
function cp_() {
	if $dry_run; then
		echo cp $*
	else
		cp $*
	fi
}

function mkdir_() {
	if $dry_run; then
		echo mkdir $*
	else
		mkdir $*
	fi
}

function rm_() {
	if $dry_run; then
		echo rm $*
	else
		rm $*
	fi
}

function uninstall() {
	echo "should uninstall now"
}

function backup() {
	mkdir_ $userbackup
	mkdir_ $gamebackup

	# backup user files
	usersaves=$USERFILES/savedata
	userconf=$USERFILES/WritableFiles

	cp_ -r $usersaves $userbackup/savedata
	cp_ -r $userconf $userbackup/WritableFiles

	# iterate through LW files and backup corresponding game files
	# for each LW upk file check if corresponding .upk.uncompressed_size file exist and back it up
	for file in ${LW_FILES}; do
		case "$file" in
			*upk)
				if [ -e ${INSTALLDIR}/$file.uncompressed_size ]; then
					cp_ ${INSTALLDIR}/$file.uncompressed_size $gamebackup/$file.uncompressed_size
				fi
				;;
		esac
	done

	# backup xcomgame.int and xcomuishell.int in feraloverrides
	for file in ${FERAL_OVERRIDES}; do
		if [ -e ${INSTALLDIR}/${FERAL_OVERRIDE_DIR}/`basename $file` ]; then
			cp_ "${INSTALLDIR}/${FERAL_OVERRIDE_DIR}/`basename $file`" ${gamebackup}/${FERAL_OVERRIDE_DIR}/`basename $file`
		fi
	done

	# backup remaining files
	for file in ${LW_FILES}; do
		if [ -e ${INSTALLDIR}/${file} ]; then
			cp_ ${INSTALLDIR}/${file} ${gamebackup}/
		fi
	done
}

function install() {
	# for each LW upk file check if corresponding .upk.uncompressed_size file exist and delete it
	for file in ${LW_FILES}; do
		case "$file" in
			*upk)
				if [ -e ${INSTALLDIR}/$file.uncompressed_size ]; then
					rm_ ${INSTALLDIR}/$file.uncompressed_size $gamebackup/$file.uncompressed_size
				fi
				;;
		esac
	done

	# copy LW files to game dir
	cp_ -r ${MOD_DATA_DIR}/* ${INSTALLDIR}
	INSTALLED_FILES="${LW_FILES}"

	# copy xcomgame.int and xcomuishell.int to feraloverrides
	for file in ${FERAL_OVERRIDES}; do
		cp_ ${MOD_DATA_DIR}/$file ${INSTALLDIR}/${FERAL_OVERRIDE_DIR}/`basename $file`
		INSTALLED_FILES="${INSTALLED_FILES}${FERAL_OVERRIDE_DIR}/`basename $file`"
	done

	# copy LW defaultgamecore.ini to WritableFiles/XComGameCore.ini
	cp_ ${MOD_CONFIG_DIR}/defaultgamecore.ini ${USERFILES}/WritableFiles/XComGameCore.ini

	# copy LW defaultloadouts.ini to WritableFiles/XComLoadouts.ini
	cp_ ${MOD_CONFIG_DIR}/defaultloadouts.ini ${USERFILES}/WritableFiles/XComLoadouts.ini

	if ! ${dry_run}; then
		echo "${INSTALLED_FILES}" > "${INSTALLDIR}/.lw_install"
	fi
}

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

# backup location for existing files
userbackup=$USERFILES/backup
gamebackup=$installdir/backup

keep_saves=false
if [ -f "${INSTALLDIR}/.lw_install" ]; then
	echo -n "Old version of LW found. Keep savegames? (y/n)"
	read yn
	if [[ $yn == y || $yn == Y ]]; then
		echo "keeping savegames"
		keep_saves=true
	else
		echo "not keeping savegames"
	fi

	uninstall
fi

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
  

backup

# clear user files
if ! ${keep_saves}; then
	rm_ -f $usersaves/*
fi
rm_ -f $userconf/*

install

exit 0

# end of install script
