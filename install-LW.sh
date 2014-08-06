#!/bin/bash
# Long War Linux install script

# default values
USERFILES=~/.local/share/feral-interactive/XCOM/XEW
INSTALLDIR=~/.local/share/Steam/SteamApps/common/XCom-Enemy-Unknown/xew

MOD_DATA_DIR=`dirname $0`/install-files
MOD_CONFIG_DIR=${MOD_DATA_DIR}/xcomgame/config

FERAL_OVERRIDES="xcomgame/localization/int/xcomgame.int xcomgame/localization/int/xcomuishell.int"
FERAL_OVERRIDE_DIR="binaries/share/feraloverrides"

LW_FILES=`find ${MOD_DATA_DIR}/ -type f | sed s,${MOD_DATA_DIR}/,,g`

SELFNAME=`basename $0`

IS_UNINSTALL=false
if [ $SELFNAME = "uninstall-LW.sh" ]; then
	IS_UNINSTALL=true
fi

$IS_UNINSTALL && echo "Uninstalling Long War for XCOM:EW, please, be patient..." || echo "Installing Long War for XCOM:EW, please, be patient..."

dry_run=false

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

function ln_() {
	if $dry_run; then
		echo ln $*
	else
		ln $*
	fi
}

function uninstall() {
	echo "should uninstall now"
}

function backup() {
	mkdir_ $userbackup
	mkdir_ $gamebackup
	mkdir_ $gamebackup/feraloverrides

	# backup user files
	usersaves=$userfiles/savedata
	userconf=$userfiles/WritableFiles

	cp_ -r $usersaves $userbackup/savedata
	cp_ -r $userconf $userbackup/WritableFiles

	# iterate through LW files and backup corresponding game files
	# for each LW upk file check if corresponding .upk.uncompressed_size file exist and back it up
	for file in ${LW_FILES}; do
		case "$file" in
			*upk)
				if [ -e ${installdir}/$file.uncompressed_size ]; then
					cp_ ${installdir}/$file.uncompressed_size $gamebackup/`basename $file`.uncompressed_size
				fi
				;;
		esac
	done

	# backup xcomgame.int and xcomuishell.int in feraloverrides
	for file in ${FERAL_OVERRIDES}; do
		if [ -e ${installdir}/${FERAL_OVERRIDE_DIR}/`basename $file` ]; then
			cp_ "${installdir}/${FERAL_OVERRIDE_DIR}/`basename $file`" ${gamebackup}/feraloverrides/`basename $file`
		fi
	done

	# backup remaining files
	for file in ${LW_FILES}; do
		if [ -e ${installdir}/${file} ]; then
			cp_ ${installdir}/${file} ${gamebackup}/
		fi
	done
}

function install() {
	# for each LW upk file check if corresponding .upk.uncompressed_size file exist and delete it
	for file in ${LW_FILES}; do
		case "$file" in
			*upk)
				if [ -e ${installdir}/$file.uncompressed_size ]; then
					rm_ ${installdir}/$file.uncompressed_size
				fi
				;;
		esac
	done

	# copy LW files to game dir
	cp_ -r ${MOD_DATA_DIR}/* ${installdir}
	INSTALLED_FILES="${LW_FILES}"

	# copy xcomgame.int and xcomuishell.int to feraloverrides
	for file in ${FERAL_OVERRIDES}; do
		cp_ ${MOD_DATA_DIR}/$file ${installdir}/${FERAL_OVERRIDE_DIR}/`basename $file`
		INSTALLED_FILES="${INSTALLED_FILES}
${FERAL_OVERRIDE_DIR}/`basename $file`"
	done

	# copy LW defaultgamecore.ini to WritableFiles/XComGameCore.ini
	cp_ ${MOD_CONFIG_DIR}/defaultgamecore.ini ${userfiles}/WritableFiles/XComGameCore.ini

	# copy LW defaultloadouts.ini to WritableFiles/XComLoadouts.ini
	cp_ ${MOD_CONFIG_DIR}/defaultloadouts.ini ${userfiles}/WritableFiles/XComLoadouts.ini

	if ! ${dry_run}; then
		echo "${INSTALLED_FILES}" > "${installdir}/.lw_install"
	fi
	
	if [ ! -e "${installdir}/binaries/linux/${SELFNAME}" ]; then
		cp_ $0 "${installdir}/binaries/linux"
		ln_ -s "${installdir}/binaries/linux/${SELFNAME}" "${installdir}/binaries/linux/uninstall-LW.sh"
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
userbackup=$userfiles/backup
gamebackup=$installdir/backup

if $IS_UNINSTALL; then
	if [ -f "${installdir}/.lw_install" ]; then
		uninstall
	fi
	
	echo "Done"
	exit 0
fi

keep_saves=false
if [ -f "${installdir}/.lw_install" ]; then
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

echo "Copying install files..."

install

echo "Done. Now run the game. Remeber to check your game settings (especially video settings)."

exit 0

# end of install script
