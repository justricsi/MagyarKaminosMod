// This is a comment
// uncomment the line below if you want to write a filterscript
//#define FILTERSCRIPT
#include <a_samp>
#include <ZCMD>
#include <sscanf2>
//#include <fixchars.h>
#include <a_mysql>

#pragma tabsize 0
//---------------------SZÍNEK DEFINIÁLÁSA---------------------------------------
#define feher 0xFFFFFFFF
#define orange 0xFF8000FF
#define zold 0x1BA901FF

//---------------------EGYÉB DEFINEOK-------------------------------------------
#define TAKEOVER_TIME 120 // mennyi idõ kell az elfoglaláshoz
#define MIN_DEATHS_TO_START_WAR 1 // minimum ennyi embert kell kinyírni hogy beinduljon a csata

#define TEAM_GROVE 1
#define TEAM_BALLAS 2
#define TEAM_VAGOS 3

//--------------------FORWARDOK-------------------------------------------------
forward RegEllenorzes(playerid);
forward ZoneTimer();

#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Blank Filterscript by your name here");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

#else

//----------------------------ENUMOK--------------------------------------------
enum
{
	d_reg,
	d_belep
}

enum JatekosInfo {
	Nev[25],
	Penz,
	Pont,
	Skin,
	alevel
}
new jInfo[MAX_PLAYERS][JatekosInfo];

enum eZone
{
	Float:zMinX,
	Float:zMinY,
	Float:zMaxX,
	Float:zMaxY,
	zTeam
}

/*new Teams[] = {
	TEAM_GROVE,
	TEAM_BALLAS,
	TEAM_VAGOS
};*/

new ZoneInfo[][eZone] = {
	{2337.9004,-1808.8383,2590.2043,-1610.3673,TEAM_GROVE},
	{2084.7,-1808.8383,2337.9004,-1610.3673,TEAM_BALLAS},
	{2590.2043,-1808.8383,2842.3,-1610.3673,TEAM_VAGOS}
};
new ZoneID[sizeof(ZoneInfo)];

//---------------------GLOBÁLIS VÁLTOZÓK----------------------------------------
new kapcs, query[2000];
new Text:TDEditor_TD[11];
new AutoCount = 0;
new ZoneAttacker[sizeof(ZoneInfo)] = {-1, ...};
new ZoneAttackTime[sizeof(ZoneInfo)];
new ZoneDeaths[sizeof(ZoneInfo)];

main()
{
	print("\n----------------------------------");
	print(" VALAMI");
	print("----------------------------------\n");
}

#endif

public OnGameModeInit()
{
	UsePlayerPedAnims();         			//Normál futás
	DisableInteriorEnterExits(); 			//Interior kikapcs
	EnableStuntBonusForAll(0);              //ugrató pénz kikapcs
	SetGameModeText("ZoneWars");
	
	mysql_log(LOG_ALL, LOG_TYPE_HTML);
	kapcs = mysql_connect("localhost", "root", "zone", "");
	if(mysql_errno(kapcs) != 0) printf("MySQL hiba! Hibakód: %d", mysql_errno(kapcs));
	
	for(new i=0; i < sizeof(ZoneInfo); i++)
	{
		ZoneID[i] = GangZoneCreate(ZoneInfo[i][zMinX], ZoneInfo[i][zMinY], ZoneInfo[i][zMaxX], ZoneInfo[i][zMaxY]);
	}
	
	SetTimer("ZoneTimer", 1000, true);
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SpawnPlayer(playerid);
	return 1;
}

public OnPlayerConnect(playerid)
{
	//TextDrawok(playerid); //Csapatválasztó textdrawok
	
	TogglePlayerSpectating(playerid, true);
    for(new a; JatekosInfo:a < JatekosInfo; a++) jInfo[playerid][JatekosInfo:a] = 0;    //Nullázzuk az enumjait
    GetPlayerName(playerid, jInfo[playerid][Nev], 25);                                  //Lekérjük a nevét.
    if(strfind(jInfo[playerid][Nev], "_") == -1)                                        //Nem tartalmaz alsóvonást.
    for(new a; a < strlen(jInfo[playerid][Nev]); a++) if(jInfo[playerid][Nev][a] == '_') jInfo[playerid][Nev][a] = ' ';//Végigfutunk a nevén. Ha az egyik karaktere '_', kicseréli ' '-re.
    mysql_format(kapcs, query, 256, "SELECT ID,NEV FROM jatekosok WHERE NEV='%e' LIMIT 1", jInfo[playerid][Nev]);
    mysql_tquery(kapcs, query, "RegEllenorzes", "d", playerid);

	return 1;
}

public RegEllenorzes(playerid)
{
    new sorok_szama = cache_get_row_count();
    if(sorok_szama == 0) ShowPlayerDialog(playerid, d_reg, DIALOG_STYLE_PASSWORD, "Regisztráció", "{FFFFFF}Üdv a szerveren!\nMég nem regisztráltál!\nKérlek adj meg egy jelszót!", "Regisztrál", "Kilép");
    else ShowPlayerDialog(playerid, d_belep, DIALOG_STYLE_PASSWORD, "Bejelentkezés", "{FFFFFF}Üdv a szerveren!\n\nKérlek add meg a jelszavad, amivel regisztráltált!", "Belép", "Kilép");
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	mysql_format(kapcs, query, 384, "UPDATE jatekosok SET PENZ='%d',PONT='%d' WHERE NEV='%s'", jInfo[playerid][Penz],jInfo[playerid][Pont],jInfo[playerid][Nev]);
	mysql_tquery(kapcs, query);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	//Itt mutatjuk a gangzonokat a játékosoknak valamint villogást is itt lehet beállítani
	for(new i=0; i < sizeof(ZoneInfo); i++)
	{
		GangZoneShowForPlayer(playerid, ZoneID[i], GetTeamZoneColor(ZoneInfo[i][zTeam]));
		if(ZoneAttacker[i] != -1) GangZoneFlashForPlayer(playerid, ZoneID[i], GetTeamZoneColor(ZoneAttacker[i]));
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(IsPlayerConnected(killerid) && GetPlayerTeam(playerid) != GetPlayerTeam(killerid)) // not a suicide or team kill
	{
		new zoneid = GetPlayerZone(playerid);
		if(zoneid != -1 && ZoneInfo[zoneid][zTeam] == GetPlayerTeam(playerid)) // zone member has been killed in the zone
		{
			ZoneDeaths[zoneid]++;
			if(ZoneDeaths[zoneid] == MIN_DEATHS_TO_START_WAR)
			{
				ZoneDeaths[zoneid] = 0;
				ZoneAttacker[zoneid] = GetPlayerTeam(killerid);
				ZoneAttackTime[zoneid] = 0;
				GangZoneFlashForAll(ZoneID[zoneid], GetTeamZoneColor(ZoneAttacker[zoneid]));
			}
		}
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid, bodypart)
{
    if(issuerid != INVALID_PLAYER_ID && bodypart == 9)
    {
        // One shot to the head to kill with sniper rifle
        SetPlayerHealth(playerid, 0.0);
    }
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
        case d_reg: Dialog_Regisztracio(playerid, response, inputtext);
        case d_belep: Dialog_Belepes(playerid, response, inputtext);
    }
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

forward JatekosBeregelt(playerid);
public JatekosBeregelt(playerid)
{
    TogglePlayerSpectating(playerid, false);
    SendClientMessage(playerid, zold, "Sikeresen regisztráltál!");
    SetSpawnInfo(playerid,0,0,2529.7461,-1736.1093,13.0943,0, 0, 0, 0, 0, 0, 0);
    SpawnPlayer(playerid);
    return 1;
}

forward JatekosBelep(playerid);
public JatekosBelep(playerid)
{
    new sorok_szama = cache_get_row_count();
    if(sorok_szama == 0) return ShowPlayerDialog(playerid, d_belep, DIALOG_STYLE_PASSWORD, "Bejelentkezés", "{FFFFFF}Üdv a szerveren!\nKérlek add meg a jelszavad, amivel regisztráltált!\n\n{FF0000}Hibás jelszó!", "Belép", "Kilép");
    //Az elobb, ha hibás volt a jelszó visszatértünk volna, szóval innenztol ami lefut kód, az már jó jelszóval fut le:
    TogglePlayerSpectating(playerid, false);
    SetSpawnInfo(playerid,0,0,2529.7461,-1736.1093,13.0943,0, 0, 0, 0, 0, 0, 0);
    SpawnPlayer(playerid);
    SendClientMessage(playerid, zold, "Sikeresen bejelentkeztél!");
	jInfo[playerid][Penz] = cache_get_field_content_int(0, "PENZ",kapcs);
    jInfo[playerid][Pont] = cache_get_field_content_int(0, "PONT",kapcs);
    return 1;
}

public ZoneTimer()
{
	for(new i=0; i < sizeof(ZoneInfo); i++) // loop all zones
	{
		if(ZoneAttacker[i] != -1) // zone is being attacked
		{
			if(GetPlayersInZone(i, ZoneAttacker[i]) >= 1) // there must be at least 1 attacker left
			{
				ZoneAttackTime[i]++;
				if(ZoneAttackTime[i] == TAKEOVER_TIME) // zone has been under attack for enough time and attackers take over the zone
				{
					GangZoneStopFlashForAll(ZoneID[i]);
					ZoneInfo[i][zTeam] = ZoneAttacker[i];
					GangZoneShowForAll(ZoneID[i], GetTeamZoneColor(ZoneInfo[i][zTeam])); // update the zone color for new team
					ZoneAttacker[i] = -1;
				}
			}
			else // attackers failed to take over the zone
			{
				GangZoneStopFlashForAll(ZoneID[i]);
				ZoneAttacker[i] = -1;
			}
		}
	}
}

stock IsPlayerInZone(playerid, zoneid)
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	return (x > ZoneInfo[zoneid][zMinX] && x < ZoneInfo[zoneid][zMaxX] && y > ZoneInfo[zoneid][zMinY] && y < ZoneInfo[zoneid][zMaxY]);
}

stock GetPlayerZone(playerid)
{
	for(new i=0; i < sizeof(ZoneInfo); i++)
	{
		if(IsPlayerInZone(playerid, i))
		{
			return i;
		}
	}
	return -1;
}

stock GetPlayersInZone(zoneid, teamid)
{
	new count;
	for(new i=0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerConnected(i) && GetPlayerTeam(i) == teamid && IsPlayerInZone(i, zoneid))
	    {
			count++;
	    }
	}
	return count;
}

stock GetTeamZoneColor(teamid)
{
	switch(teamid)
	{
		//A színek végén a 88-as az átlátszóságot jelenti, ez csökkenthetõ ha mégkisebb számot írunk
		case TEAM_GROVE: return 0x00FF0088;
		case TEAM_BALLAS: return 0xFF00FF88;
		case TEAM_VAGOS: return 0xFFFF0088;
	}
	return -1;
}

stock TextDrawok(playerid)
{
	TDEditor_TD[0] = TextDrawCreate(134.450942, 127.583305, "box");
	TextDrawLetterSize(TDEditor_TD[0], 0.000000, 25.554901);
	TextDrawTextSize(TDEditor_TD[0], 226.000000, 0.000000);
	TextDrawAlignment(TDEditor_TD[0], 1);
	TextDrawColor(TDEditor_TD[0], -1);
	TextDrawUseBox(TDEditor_TD[0], 1);
	TextDrawBoxColor(TDEditor_TD[0], 255);
	TextDrawSetShadow(TDEditor_TD[0], 0);
	TextDrawSetOutline(TDEditor_TD[0], 0);
	TextDrawBackgroundColor(TDEditor_TD[0], 255);
	TextDrawFont(TDEditor_TD[0], 1);
	TextDrawSetProportional(TDEditor_TD[0], 1);
	TextDrawSetShadow(TDEditor_TD[0], 0);

	TDEditor_TD[1] = TextDrawCreate(144.289916, 138.083389, "Magyarok");
	TextDrawLetterSize(TDEditor_TD[1], 0.400000, 1.600000);
	TextDrawTextSize(TDEditor_TD[1], 215.000000, 0.000000);
	TextDrawAlignment(TDEditor_TD[1], 1);
	TextDrawColor(TDEditor_TD[1], -1);
	TextDrawUseBox(TDEditor_TD[1], 1);
	TextDrawBoxColor(TDEditor_TD[1], -16776961);
	TextDrawSetShadow(TDEditor_TD[1], 0);
	TextDrawSetOutline(TDEditor_TD[1], 0);
	TextDrawBackgroundColor(TDEditor_TD[1], 255);
	TextDrawFont(TDEditor_TD[1], 1);
	TextDrawSetProportional(TDEditor_TD[1], 1);
	TextDrawSetShadow(TDEditor_TD[1], 0);
	TextDrawSetSelectable(TDEditor_TD[1], true);

	TDEditor_TD[2] = TextDrawCreate(144.289916, 164.333358, "Nemetek");
	TextDrawLetterSize(TDEditor_TD[2], 0.400000, 1.600000);
	TextDrawTextSize(TDEditor_TD[2], 215.000000, 0.000000);
	TextDrawAlignment(TDEditor_TD[2], 1);
	TextDrawColor(TDEditor_TD[2], -1);
	TextDrawUseBox(TDEditor_TD[2], 1);
	TextDrawBoxColor(TDEditor_TD[2], -16776961);
	TextDrawSetShadow(TDEditor_TD[2], 0);
	TextDrawSetOutline(TDEditor_TD[2], 0);
	TextDrawBackgroundColor(TDEditor_TD[2], 255);
	TextDrawFont(TDEditor_TD[2], 1);
	TextDrawSetProportional(TDEditor_TD[2], 1);
	TextDrawSetShadow(TDEditor_TD[2], 0);
	TextDrawSetSelectable(TDEditor_TD[2], true);

	TDEditor_TD[3] = TextDrawCreate(144.289916, 190.000030, "Gorogok");
	TextDrawLetterSize(TDEditor_TD[3], 0.400000, 1.600000);
	TextDrawTextSize(TDEditor_TD[3], 215.000000, 0.000000);
	TextDrawAlignment(TDEditor_TD[3], 1);
	TextDrawColor(TDEditor_TD[3], -1);
	TextDrawUseBox(TDEditor_TD[3], 1);
	TextDrawBoxColor(TDEditor_TD[3], -16776961);
	TextDrawSetShadow(TDEditor_TD[3], 0);
	TextDrawSetOutline(TDEditor_TD[3], 0);
	TextDrawBackgroundColor(TDEditor_TD[3], 255);
	TextDrawFont(TDEditor_TD[3], 1);
	TextDrawSetProportional(TDEditor_TD[3], 1);
	TextDrawSetShadow(TDEditor_TD[3], 0);
	TextDrawSetSelectable(TDEditor_TD[3], true);

	TDEditor_TD[4] = TextDrawCreate(144.289916, 216.833389, "OLaszok");
	TextDrawLetterSize(TDEditor_TD[4], 0.400000, 1.600000);
	TextDrawTextSize(TDEditor_TD[4], 215.000000, 0.000000);
	TextDrawAlignment(TDEditor_TD[4], 1);
	TextDrawColor(TDEditor_TD[4], -1);
	TextDrawUseBox(TDEditor_TD[4], 1);
	TextDrawBoxColor(TDEditor_TD[4], -16776961);
	TextDrawSetShadow(TDEditor_TD[4], 0);
	TextDrawSetOutline(TDEditor_TD[4], 0);
	TextDrawBackgroundColor(TDEditor_TD[4], 255);
	TextDrawFont(TDEditor_TD[4], 1);
	TextDrawSetProportional(TDEditor_TD[4], 1);
	TextDrawSetShadow(TDEditor_TD[4], 0);
	TextDrawSetSelectable(TDEditor_TD[4], true);

	TDEditor_TD[5] = TextDrawCreate(233.308822, 128.166671, "box");
	TextDrawLetterSize(TDEditor_TD[5], 0.000000, 2.035140);
	TextDrawTextSize(TDEditor_TD[5], 429.000000, 0.000000);
	TextDrawAlignment(TDEditor_TD[5], 1);
	TextDrawColor(TDEditor_TD[5], -1);
	TextDrawUseBox(TDEditor_TD[5], 1);
	TextDrawBoxColor(TDEditor_TD[5], 255);
	TextDrawSetShadow(TDEditor_TD[5], 0);
	TextDrawSetOutline(TDEditor_TD[5], 0);
	TextDrawBackgroundColor(TDEditor_TD[5], 255);
	TextDrawFont(TDEditor_TD[5], 1);
	TextDrawSetProportional(TDEditor_TD[5], 1);
	TextDrawSetShadow(TDEditor_TD[5], 0);

	TDEditor_TD[6] = TextDrawCreate(256.734924, 130.499984, "Csapat_valaszto");
	TextDrawLetterSize(TDEditor_TD[6], 0.400000, 1.600000);
	TextDrawAlignment(TDEditor_TD[6], 1);
	TextDrawColor(TDEditor_TD[6], -1);
	TextDrawSetShadow(TDEditor_TD[6], 0);
	TextDrawSetOutline(TDEditor_TD[6], 0);
	TextDrawBackgroundColor(TDEditor_TD[6], 255);
	TextDrawFont(TDEditor_TD[6], 2);
	TextDrawSetProportional(TDEditor_TD[6], 1);
	TextDrawSetShadow(TDEditor_TD[6], 0);

	TDEditor_TD[7] = TextDrawCreate(231.266372, 153.833358, "");
	TextDrawLetterSize(TDEditor_TD[7], 0.000000, 0.000000);
	TextDrawTextSize(TDEditor_TD[7], 199.000000, 206.000000);
	TextDrawAlignment(TDEditor_TD[7], 1);
	TextDrawColor(TDEditor_TD[7], -1);
	TextDrawSetShadow(TDEditor_TD[7], 0);
	TextDrawSetOutline(TDEditor_TD[7], 0);
	TextDrawBackgroundColor(TDEditor_TD[7], 255);
	TextDrawFont(TDEditor_TD[7], 5);
	TextDrawSetProportional(TDEditor_TD[7], 0);
	TextDrawSetShadow(TDEditor_TD[7], 0);
	TextDrawSetPreviewModel(TDEditor_TD[7], 0);
	TextDrawSetPreviewRot(TDEditor_TD[7], 0.000000, 0.000000, 0.000000, 1.000000);

	TDEditor_TD[8] = TextDrawCreate(435.710144, 127.583320, "box");
	TextDrawLetterSize(TDEditor_TD[8], 0.000000, 25.554901);
	TextDrawTextSize(TDEditor_TD[8], 529.000000, 0.000000);
	TextDrawAlignment(TDEditor_TD[8], 1);
	TextDrawColor(TDEditor_TD[8], -1);
	TextDrawUseBox(TDEditor_TD[8], 1);
	TextDrawBoxColor(TDEditor_TD[8], 255);
	TextDrawSetShadow(TDEditor_TD[8], 0);
	TextDrawSetOutline(TDEditor_TD[8], 0);
	TextDrawBackgroundColor(TDEditor_TD[8], 255);
	TextDrawFont(TDEditor_TD[8], 1);
	TextDrawSetProportional(TDEditor_TD[8], 1);
	TextDrawSetShadow(TDEditor_TD[8], 0);

	TDEditor_TD[9] = TextDrawCreate(443.675384, 135.750091, "Katona");
	TextDrawLetterSize(TDEditor_TD[9], 0.400000, 1.600000);
	TextDrawTextSize(TDEditor_TD[9], 523.000000, 0.000000);
	TextDrawAlignment(TDEditor_TD[9], 1);
	TextDrawColor(TDEditor_TD[9], -1);
	TextDrawUseBox(TDEditor_TD[9], 1);
	TextDrawBoxColor(TDEditor_TD[9], 11141375);
	TextDrawSetShadow(TDEditor_TD[9], 0);
	TextDrawSetOutline(TDEditor_TD[9], 0);
	TextDrawBackgroundColor(TDEditor_TD[9], 255);
	TextDrawFont(TDEditor_TD[9], 1);
	TextDrawSetProportional(TDEditor_TD[9], 1);
	TextDrawSetShadow(TDEditor_TD[9], 0);
	TextDrawSetSelectable(TDEditor_TD[9], true);

	TDEditor_TD[10] = TextDrawCreate(443.675445, 161.416732, "Sniper");
	TextDrawLetterSize(TDEditor_TD[10], 0.400000, 1.600000);
	TextDrawTextSize(TDEditor_TD[10], 523.000000, 0.000000);
	TextDrawAlignment(TDEditor_TD[10], 1);
	TextDrawColor(TDEditor_TD[10], -1);
	TextDrawUseBox(TDEditor_TD[10], 1);
	TextDrawBoxColor(TDEditor_TD[10], 11141375);
	TextDrawSetShadow(TDEditor_TD[10], 0);
	TextDrawSetOutline(TDEditor_TD[10], 0);
	TextDrawBackgroundColor(TDEditor_TD[10], 255);
	TextDrawFont(TDEditor_TD[10], 1);
	TextDrawSetProportional(TDEditor_TD[10], 1);
	TextDrawSetShadow(TDEditor_TD[10], 0);
	TextDrawSetSelectable(TDEditor_TD[10], true);
	
	for(new i = 0; i<= 11; i++)
	{
		TextDrawShowForPlayer(playerid,TDEditor_TD[i]);
	}

	return 1;
}

Dialog_Regisztracio(playerid, response, inputtext[])
{
	{
        if(!response) return Kick(playerid);
        if(strlen(inputtext) < 5 || strlen(inputtext) > 32) return ShowPlayerDialog(playerid, d_reg, DIALOG_STYLE_PASSWORD, "Regisztráció", "{FFFFFF}Üdv a szerveren!\nMég nem regisztráltál!\nKérlek adj meg egy megjegyezhetõ és erõs jelszót!\n\n{FF0000}Jelszavadnak 5-32 karakter között kell lennie!", "Regisztrál", "Kilép");
        mysql_format(kapcs, query, 256, "INSERT INTO jatekosok (NEV,JELSZO,PENZ,PONT) VALUES ('%e',SHA1('%e'),'0','0')", jInfo[playerid][Nev], inputtext);
        mysql_tquery(kapcs, query, "JatekosBeregelt", "d", playerid);
    }
return 1;
}

Dialog_Belepes(playerid, response, inputtext[])
{
	{
        if(!response) return Kick(playerid);
        if(strlen(inputtext) < 5 || strlen(inputtext) > 32) return ShowPlayerDialog(playerid, d_belep, DIALOG_STYLE_PASSWORD, "Bejelentkezés", "{FFFFFF}Üdv a szerveren!\nMár regisztráltál!\nKérlek add meg a jelszavad, amivel regisztráltáltál!\n\n{FF0000}Jelszavadnak 5-32 karakter között kell lennie!", "Belép", "Kilép");
        mysql_format(kapcs, query, 256, "SELECT * FROM jatekosok WHERE NEV='%e' AND JELSZO=SHA1('%e')", jInfo[playerid][Nev], inputtext);
        mysql_tquery(kapcs, query, "JatekosBelep", "d", playerid);
    }
return 1;
}

//------------------------------PARANCSOK---------------------------------------
CMD:kocsi(playerid,params[])
{
	new mID,buffer[20];
	if(sscanf(params,"i",mID)) return SendClientMessage(playerid,orange,"INFO: /kocsi [ID]");
	if(mID<400 || mID>611) return SendClientMessage(playerid,orange,"400-611-ig vannak csak kocsik!");

	new Float:pX,Float:pY,Float:pZ,Float:pR;
	GetPlayerPos(playerid,pX, pY, pZ);
	GetPlayerFacingAngle(playerid, pR);
	
	format(buffer, sizeof(buffer),"ZÓNA-%d",random(10));
	SetVehicleNumberPlate(AddStaticVehicleEx(mID,pX+4,pY,pZ,pR,140,140,-1,0),buffer);
	
	AutoCount++;
	return 1;
}

CMD:tp(playerid,params[])
{
	new pID, str[128];
	new Float:aX, Float:aY, Float:aZ;
	if(sscanf(params, "i", pID)) return SendClientMessage(playerid, orange, "Használat: /tp [playerid]");
	if(IsPlayerConnected(pID))
	{
		GetPlayerPos(playerid, aX, aY, aZ);
		SetPlayerPos(pID, aX+0.5, aY+0.5, aZ+0.5);
		format(str, sizeof(str), "Teleportáltad %s játékost! ",jInfo[pID][Nev]);
		SendClientMessage(playerid, zold, str);
		SetPlayerInterior(pID,0);
	}
	else SendClientMessage(playerid, orange, "Nincs ilyen játékos!");
	return 1;
}

CMD:pteam(playerid,params[])
{
	new teamNumber, pID;
	if(sscanf(params, "ii", pID, teamNumber)) return SendClientMessage(playerid, orange, "Használat: /pteam [playerid] [teamnumber]");
	if(IsPlayerConnected(pID))
	{
		SetPlayerTeam(pID, teamNumber);
		new str[128];
		format(str, sizeof(str), "A team sikeresen beállítva %s játékosnak! [ID: %d, Team: %d]", jInfo[pID][Nev], pID, teamNumber);
		SendClientMessage(playerid, zold, str);
		format(str, sizeof(str), "Beállították a csapatodat! [Csapat: %d]", teamNumber);
		SendClientMessage(pID, zold, str);
	}
	return 1;
}

CMD:fegyver(playerid,params[]){
	new weaponID;

    if(sscanf(params,"i",weaponID)) return SendClientMessage(playerid,orange,"HasznÃ¡lat /fegyver [id]");
    if(weaponID<0 || weaponID>47) return SendClientMessage(playerid,orange,"1-47-ig vannak csak fegyverek!");
	GivePlayerWeapon(playerid, weaponID, 64);
	return 1;
}
