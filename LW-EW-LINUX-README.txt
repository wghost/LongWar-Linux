XCOM: Long War EW for Linux (LW-EW-Linux)
=========================================

This file contains Linux specific install and uninstall instructions. Original mod readme files are located in ./docs directory.


Before you begin
----------------

This mod is for Steam version of XCOM: Enemy Within only.

Ensure the game was started at least once without the mod (fails to load menu if it never phoned home).

Switch off all Steam online features for XCOM: cloud sync and automatic updates.


Install notes
-------------

1. If you ever installed any other mods verify your Steam cache back to vanilla install.

2. Run install-LW.sh script.

   Script will search for XCOM:EW install at two default locations:
   ~/.local/share/Steam/SteamApps/common/XCom-Enemy-Unknown/xew
   or
   ~/.steam/steam/SteamApps/common/XCom-Enemy-Unknown/xew
   
   Script will also owerwrite user files. By default those are searched in:
   ~/.local/share/feral-interactive/XCOM/XEW
   
   If you have XCOM:EW installed to any other location, you'll have to pass that location to script via command line:
   ./install-LW.sh /path/to/XEW/userfiles /path/to/XEW/install/dir
   
3. Install script will automatically backup you profile, existing saved games, user configuration files and vanilla game resources.

   Default backup path for user files:
   ~/.local/share/feral-interactive/XCOM/XEW/backup
   For game resources:
   ~/.local/share/Steam/SteamApps/common/XCom-Enemy-Unknown/xew/backup

4. If you have any previous LW-EW versions installed, script will backup your saved games (and all the other mod files), run uninstall procedure to revert to vanilla version and then install new LW-EW version.

   Default backup path for user files:
   ~/.local/share/feral-interactive/XCOM/XEW/backup_oldLW
   For game resources:
   ~/.local/share/Steam/SteamApps/common/XCom-Enemy-Unknown/xew/backup_oldLW
   
5. Since install procedure requires user cache to be cleared, some of your game settings may revert to default values (video settings, for example).
   

Uninstall notes
---------------

1. Run uninstall-LW.sh script to remove LW-EW and revert to previously backed up vanilla game.

2. Script will delete all the modded files and restore original ones. This includes profile and vanilla saved games. LW-EW saved games will be deleted.

3. Default saved games location is
   ~/.local/share/feral-interactive/XCOM/XEW/savedata
   You can manually backup this folder before uninstalling the mod.
   
   
Troubleshooting
---------------

If you're experiencing some strange bugs, like 4 man squad instead of 6 from the start, unusual alien stats, etc try to block Firaxis' servers via /etc/hosts:
127.0.0.1       prod.xcom.firaxis.com
127.0.0.1       prod.xcom-ew.firaxis.com
And then reinstall the mod.


Credits
-------
Long War Team: JohnnyLump, Amineri, XMarksTheSpot and the others (full list in ./docs/Long_War_EW_ReadMe.txt)
shivoc (Linux version install script main author, testing)
falex007 (Linux version install script contributor, testing)
wghost81 (Linux version testing and bugfixing)
