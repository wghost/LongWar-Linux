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
backup_data=true

function cp_() {
	if $dry_run; then
		echo cp $* >&2
	else
		cp $*
	fi
}

function mkdir_() {
	if $dry_run; then
		echo mkdir $* >&2
	else
		mkdir $*
	fi
}

function rm_() {
	if $dry_run; then
		echo rm $* >&2
	else
		rm $*
	fi
}

function mv_() {
	if $dry_run; then
		echo mv $* >&2
	else
		mv $*
	fi
}

function ln_() {
	if $dry_run; then
		echo ln $* >&2
	else
		ln $*
	fi
}

function uninstall() {
	echo "uninstalling LW mod now"

	# delete mod files
	while read file; do
		rm_ -f ${installdir}/${file}
	done < ${installdir}/.lw_install

	usersaves=$userfiles/savedata
	userconf=$userfiles/WritableFiles
	rm_ -f $usersaves/*
	rm_ -f $userconf/*

	# restore original files
	cp_ -r ${installdir}/backup/* ${installdir}/
	cp_ -r ${userbackup}/* ${userfiles}

	# delete restored backups
	rm_ -rf ${userbackup} ${gamebackup}
	rm_ -f ${installdir}/.lw_install

	echo "Everything should be restored to pre mod versions."
}

function uninstall_old() {
	echo "uninstalling old version now"
	if [ -e "${installdir}/backup_oldLW" -o -e "${userfiles}/backup_oldLW" ]; then
		echo "found old LW backup in ${installdir}/backup_oldLW or ${userfiles}/backup_oldLW"
		echo -en "\e[0;31mremove old LW backup files?\e[0m (y/n)"
		read yn
		if [[ $yn == y || $yn == Y ]]
		then
			echo "Removing old LW backup and all its content..."
			rm_ -rf ${installdir}/backup_oldLW
			rm_ -rf ${userfiles}/backup_oldLW
		else
			exit 1
		fi
	fi

	# backup old LW files
	mkdir_ ${installdir}/backup_oldLW
	while read file; do
		mv_ ${installdir}/${file} ${installdir}/backup_oldLW
	done < ${installdir}/.lw_install

	usersaves=$userfiles/savedata
	userconf=$userfiles/WritableFiles
	cp_ -r $usersaves ${installdir}/backup_oldLW
	cp_ -r $userconf ${userfiles}/backup_oldLW

	# restore original files
	cp_ -r ${installdir}/backup/* ${installdir}/
	# no need to restore savedata or userdata since both would just be deleted anyway

	rm_ -f ${installdir}/.lw_install

	echo "old LW version backed up in:"
	echo ${installdir}/backup_oldLW
	echo ${userfiles}/backup_oldLW
}

function backup() {
	mkdir_ $userbackup
	mkdir_ $gamebackup

	# backup user files
	usersaves=$userfiles/savedata
	userconf=$userfiles/WritableFiles

	cp_ -r $usersaves $userbackup
	cp_ -r $userconf $userbackup

	# iterate through LW files and backup corresponding game files
	# for each LW upk file check if corresponding .upk.uncompressed_size file exist and back it up
	for file in ${LW_FILES}; do
		case "$file" in
			*upk)
				if [ -e ${installdir}/$file.uncompressed_size ]; then
					mkdir_ -p ${gamebackup}/`dirname $file`
					cp_ ${installdir}/$file.uncompressed_size $gamebackup/$file.uncompressed_size
				fi
				;;
		esac
	done

	# backup xcomgame.int and xcomuishell.int in feraloverrides
	for file in ${FERAL_OVERRIDES}; do
		if [ -e ${installdir}/${FERAL_OVERRIDE_DIR}/`basename $file` ]; then
			mkdir_ -p ${gamebackup}/`dirname $file`
			cp_ "${installdir}/${FERAL_OVERRIDE_DIR}/`basename $file`" ${gamebackup}/$file
		fi
	done

	# backup remaining files
	for file in ${LW_FILES}; do
		if [ -e ${installdir}/${file} ]; then
			mkdir_ -p ${gamebackup}/`dirname $file`
			cp_ ${installdir}/${file} ${gamebackup}/$file
		fi
	done
}

function install() {
	# for each LW upk file check if corresponding .upk.uncompressed_size file exist and delete it
	for file in ${LW_FILES}; do
		case "$file" in
			*upk)
				if [ -e ${installdir}/$file.uncompressed_size ]; then
					rm_ -f ${installdir}/$file.uncompressed_size
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
		echo -ne "\e[0;31mThis will delete all mod savegames and configs. Are you sure?\e[0m (y/n)"
		read yn
		if [[ $yn == y || $yn == Y ]]; then
			uninstall
		else
			echo "you can find the savegames in ${userfiles}/savedata and settings in ${userfiles}/WritableFiles if you want to back them up."
		fi
	else
		echo "LW install not found!"
	fi
	
	exit 0
fi

keep_saves=false
if [ -f "${installdir}/.lw_install" ]; then
	echo -ne "\e[0;31mOld version of LW found. Keep savegames?\e[0m (y/n)"
	read yn
	if [[ $yn == y || $yn == Y ]]; then
		echo "keeping savegames"
		keep_saves=true
	else
		echo "not keeping savegames"
	fi

	uninstall_old
	backup_data=false
fi

if ${backup_data}; then
	# check if backup dir already exist
	if [ -d ${userbackup} -o -d ${gamebackup} ]; then
		echo "old backup already exists in ${userbackup} or ${gamebackup}."
		echo -n "Owerwrite old backup? (y/n) "
		read yn
		if [[ $yn == y || $yn == Y ]]
		then
			echo "Removing old backup and all its content..."
			rm_ -rf $userbackup
			rm_ -rf $gamebackup
		else
			exit 1
		fi
	fi

	backup

	echo "Wrote backup to:"
	echo "User files: $userbackup"
	echo "Game files: $gamebackup"
fi

# clear user files
usersaves=$userfiles/savedata
userconf=$userfiles/WritableFiles
if ! ${keep_saves}; then
	rm_ -f $usersaves/*
fi
rm_ -f $userconf/*

echo "Copying install files..."

install

echo -e "\e[0;32mLong War installed successful.\e[0m"
echo "Now run the game. Remeber to check your game settings (especially video settings)."

exit 0

# end of install script
