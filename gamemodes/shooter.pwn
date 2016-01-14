// This is a comment
// uncomment the line below if you want to write a filterscript
//#define FILTERSCRIPT
#include <a_samp>
#include <a_mysql>
#include <ZCMD>
#include <sscanf2>
#include <fixchars.h>

#pragma tabsize 0
//---------------------SZ�NEK DEFINI�L�SA---------------------------------------
#define feher 0xFFFFFFFF
#define orange 0xFF8000FF
#define zold 0x1BA901FF
#define kek 0x0000FFFF
#define vkek 0x01F8FEFF
#define vbarna 0xBE7C41FF
#define vzold 0x80FF00FF
#define piros 0xFF0000FF

//---------------------EGY�B DEFINEOK-------------------------------------------
#define TAKEOVER_TIME 5 // mennyi ido kell az elfoglal�shoz
#define MIN_DEATHS_TO_START_WAR 1 // minimum ennyi embert kell kiny�rni hogy beinduljon a csata
#define MAX_ZONE 100

//------------------------CSAPAT DEFINI�L�S-------------------------------------
#define TEAM_HUN 1
#define TEAM_GRE 2
#define TEAM_ITA 3
#define TEAM_RUS 4
#define TEAM_KIN 5
#define TEAM_KAM 6

//--------------------FORWARDOK-------------------------------------------------
forward RegEllenorzes(playerid);
forward ZoneTimer();
forward ZoneLoad();
forward GetPlayersOnServer();

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
	d_belep,
	d_admin,
	DIALOG_BAN
}

enum JatekosInfo {
	Nev[25],
	Penz,
	Pont,
	Skin,
	alevel,
	teamcolor,
	warndb
}
new jInfo[MAX_PLAYERS][JatekosInfo];

enum eZone
{
	zId,
	Float:zMinX,
	Float:zMinY,
	Float:zMaxX,
	Float:zMaxY,
	zTeam
}
new ZoneInfo[MAX_ZONE][eZone];
new SaveZone[1][eZone];

enum Object
{
	id,
	modelID,
	Float:xCor,
	Float:yCor,
	Float:zCor,
    Float:rxCor,
    Float:ryCor,
    Float:rzCor
}
new Objektumok[MAX_OBJECTS][Object];

/*new Teams[] = {
	TEAM_GROVE,
	TEAM_BALLAS,
	TEAM_VAGOS
};*/



//---------------------GLOB�LIS V�LTOZ�K----------------------------------------
new kapcs, query[2000];
new Text:TDEditor_TD[11];
new zoneDb = 0;
new AutoCount = 0;
new ZoneID[MAX_ZONE];
new ZoneAttacker[MAX_ZONE] = {-1, ...};
new ZoneAttackTime[MAX_ZONE];
new ZoneDeaths[MAX_ZONE];
new gTeam[MAX_PLAYERS];
new ObjektCount=0;
new bool:AdminSzolgalat[MAX_PLAYERS];
new Text3D: asz;
new bannolvavan[MAX_PLAYERS];


main()
{
	print("\n----------------------------------");
	print(" VALAMI");
	print("----------------------------------\n");
}

#endif

public OnGameModeInit()
{
	UsePlayerPedAnims();         			//Norm�l fut�s
	DisableInteriorEnterExits(); 			//Interior kikapcs
	EnableStuntBonusForAll(0);              //ugrat� p�nz kikapcs
	SetGameModeText("ZoneWars");

	// Player Classes
    AddPlayerClass(72,1137.1510,-2037.0577,69.0078,270.9954,24,1500,27,1500,16,2); //magyar
    AddPlayerClass(48,2336.3398,38.8450,26.4813,268.4628,24,1500,27,1500,16,2); // g�r�g
    AddPlayerClass(46,218.0903,-87.0485,1.5696,313.5960,24,1500,27,1500,16,2); //olasz
    AddPlayerClass(112,912.1116,-1231.0538,16.9766,8.6328,24,1500,27,1500,16,2); // orosz
    AddPlayerClass(117,2675.8403,-2453.0208,13.6379,272.1722,24,1500,27,1500,16,2); // k�naiak
    AddPlayerClass(142,537.7534,-1877.5918,3.8040,341.5533,24,1500,27,1500,16,2); // kameruniak
    /*AddPlayerClass(108,2215.1963,-1164.0492,25.7266,270.5322,24,1500,27,1500,16,2); // Jefferson Vagos spawn
    AddPlayerClass(109,2215.1963,-1164.0492,25.7266,270.5322,24,1500,27,1500,16,2); // Jefferson Vagos spawn
    AddPlayerClass(110,2215.1963,-1164.0492,25.7266,270.5322,24,1500,27,1500,16,2); // Jefferson Vagos spawn*/

    mysql_log(LOG_ALL, LOG_TYPE_HTML);
	kapcs = mysql_connect("localhost", "root", "zone", "");
	if(mysql_errno(kapcs) != 0) printf("MySQL hiba! Hibak�d: %d", mysql_errno(kapcs));

	mysql_tquery(kapcs, "SELECT * FROM zones", "ZoneLoad");

	SetTimer("ZoneTimer", 1000, true);
	return 1;
}

public OnGameModeExit()
{
    mysql_close(kapcs);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	//SpawnPlayer(playerid);
	SetPlayerCameraPos(playerid, 2220.9197,-1164.0920,25.7331);
    SetPlayerCameraLookAt(playerid, 2215.1963,-1164.0492,25.7266);
    SetPlayerPos(playerid, 2215.1963,-1164.0492,25.7266);
    SetPlayerFacingAngle(playerid, 270.5322);
    ApplyAnimation(playerid,"DANCING","DAN_LOOP_A",4.0,1,0,0,0,-1);
    PlayerPlaySound(playerid, 1183, 0.0, 0.0, 0.0);
    SetPlayerTeamFromClass(playerid, classid);
	return 1;
}

SetPlayerTeamFromClass(playerid, classid)
{
switch (classid) {
        case 0: {
                gTeam[playerid] = TEAM_HUN;
                GameTextForPlayer(playerid,"~w~Magyarok",3000,6);
        }
        case 1: {
                gTeam[playerid] = TEAM_GRE;
                GameTextForPlayer(playerid,"~w~G�r�g�k",3000,6);
        }
        case 2: {
                gTeam[playerid] = TEAM_ITA;
                GameTextForPlayer(playerid,"~w~Olaszok",3000,6);
        }
        case 3: {
                gTeam[playerid] = TEAM_RUS;
                GameTextForPlayer(playerid,"~w~Oroszok",3000,6);
        }
        case 4: {
                gTeam[playerid] = TEAM_KIN;
                GameTextForPlayer(playerid,"~w~K�naiak",3000,6);
        }
        case 5: {
                gTeam[playerid] = TEAM_KAM;
                GameTextForPlayer(playerid,"~w~Kameruniak",3000,6);
        }
}
return 1;
}

SetPlayerToTeamColor(playerid)
{
        if (gTeam[playerid] == TEAM_HUN)
        {
                SetPlayerColor(playerid, 0x00FF0088);
                SetPlayerTeam(playerid, TEAM_HUN);
				jInfo[playerid][teamcolor] = TEAM_HUN;
        }
        else if (gTeam[playerid] == TEAM_GRE)
        {
                SetPlayerColor(playerid, 0xFF00FF88);
                SetPlayerTeam(playerid, TEAM_GRE);
                jInfo[playerid][teamcolor] = TEAM_GRE;
        }
        else if (gTeam[playerid] == TEAM_ITA)
        {
                SetPlayerColor(playerid, 0xFFFF0088);
                SetPlayerTeam(playerid, TEAM_ITA);
                jInfo[playerid][teamcolor] = TEAM_ITA;
        }
        else if (gTeam[playerid] == TEAM_RUS)
        {
                SetPlayerColor(playerid, 0x0000FF88);
                SetPlayerTeam(playerid, TEAM_RUS);
                jInfo[playerid][teamcolor] = TEAM_RUS;
        }
        else if (gTeam[playerid] == TEAM_KIN)
        {
                SetPlayerColor(playerid, 0x01F8FE88);
                SetPlayerTeam(playerid, TEAM_KIN);
                jInfo[playerid][teamcolor] = TEAM_KIN;
        }
        else if (gTeam[playerid] == TEAM_KAM)
        {
                SetPlayerColor(playerid, 0xBE7C4188);
                SetPlayerTeam(playerid, TEAM_KAM);
                jInfo[playerid][teamcolor] = TEAM_KAM;
        }
}

public OnPlayerConnect(playerid)
{
	//TextDrawok(playerid);//Csapatv�laszt� textdrawok
    MySQL_BanCheck(playerid);
    if(bannolvavan[playerid] != 1){
	TogglePlayerSpectating(playerid, true);
    for(new a; JatekosInfo:a < JatekosInfo; a++) jInfo[playerid][JatekosInfo:a] = 0;    //Null�zzuk az enumjait
    GetPlayerName(playerid, jInfo[playerid][Nev], 25);                                  //Lek�rj�k a nev�t.
    if(strfind(jInfo[playerid][Nev], "_") == -1)                                        //Nem tartalmaz als�von�st.
    for(new a; a < strlen(jInfo[playerid][Nev]); a++) if(jInfo[playerid][Nev][a] == '_') jInfo[playerid][Nev][a] = ' ';//V�gigfutunk a nev�n. Ha az egyik karaktere '_', kicser�li ' '-re.
    mysql_format(kapcs, query, 256, "SELECT ID,NEV FROM jatekosok WHERE NEV='%e' LIMIT 1", jInfo[playerid][Nev]);
    mysql_tquery(kapcs, query, "RegEllenorzes", "d", playerid);
    }
    else {
        ShowPlayerDialog(playerid, DIALOG_BAN, DIALOG_STYLE_MSGBOX, "Ban", "Bannolva vagy a szerverr�l!", "Close", "");
    }
	return 1;
}

public ZoneLoad()
{
	printf("ZoneLoad-ban vagyunk, %d", cache_get_row_count());
    if(!cache_get_row_count()) return printf("cache_get_row_count returned false. Nincsennek bet�ltend� sorok.");
	 	for(new i = 0; i < cache_get_row_count(); i++)
		{
			ZoneInfo[i][zId] = cache_get_field_content_int(i,"id",kapcs);
		    ZoneInfo[i][zMinX] = cache_get_field_content_float(i,"minX",kapcs);
		    ZoneInfo[i][zMinY] = cache_get_field_content_float(i,"minY",kapcs);
		    ZoneInfo[i][zMaxX] = cache_get_field_content_float(i,"maxX",kapcs);
			ZoneInfo[i][zMaxY] = cache_get_field_content_float(i,"maxY",kapcs);
			ZoneInfo[i][zTeam] = cache_get_field_content_int(i,"team",kapcs);

			zoneDb++;
			printf("%d, %f, %f, %f, %f, %d", ZoneInfo[i][zId], ZoneInfo[i][zMinX], ZoneInfo[i][zMinY], ZoneInfo[i][zMaxX], ZoneInfo[i][zMaxY], ZoneInfo[i][zTeam]);
			ZoneID[i] = GangZoneCreate(ZoneInfo[i][zMinX], ZoneInfo[i][zMinY], ZoneInfo[i][zMaxX], ZoneInfo[i][zMaxY]);
		}
	printf("bet�lt�tt sorok: %d", zoneDb);
	/*for(new i=0; i < zoneDb; i++)
	{
		ZoneID[i] = GangZoneCreate(ZoneInfo[i][zMinX], ZoneInfo[i][zMinY], ZoneInfo[i][zMaxX], ZoneInfo[i][zMaxY]);
	}*/
	return 1;
}

forward ObjectLoad();
public ObjectLoad()
{
	if(!cache_get_row_count()) return printf("cache_get_row_count returned false. Nincsennek bet�ltend� sorok.");
	 	for(new i, j = cache_get_row_count(); i < j ; i++)
		{
			Objektumok[i][id] = ObjektCount;
			Objektumok[i][modelID] = cache_get_field_content_int(i,"modelid",kapcs);
		    Objektumok[i][xCor] = cache_get_field_content_float(i,"x",kapcs);
		    Objektumok[i][yCor] = cache_get_field_content_float(i,"y",kapcs);
		    Objektumok[i][zCor] = cache_get_field_content_float(i,"z",kapcs);
		    Objektumok[i][rxCor] = cache_get_field_content_float(i,"rx",kapcs);
		    Objektumok[i][ryCor] = cache_get_field_content_float(i,"ry",kapcs);
		    Objektumok[i][rzCor] = cache_get_field_content_float(i,"rz",kapcs);

			CreateObject(Objektumok[i][modelID], Objektumok[i][xCor], Objektumok[i][yCor], Objektumok[i][zCor], Objektumok[i][rxCor], Objektumok[i][ryCor], Objektumok[i][rzCor]);
	        ObjektCount ++;
		}
	return 1;
}

public RegEllenorzes(playerid)
{
    new sorok_szama = cache_get_row_count();
    if(sorok_szama == 0) ShowPlayerDialog(playerid, d_reg, DIALOG_STYLE_PASSWORD, "Regisztr�ci�", "{FFFFFF}�dv a szerveren!\nM�g nem regisztr�lt�l!\nK�rlek adj meg egy jelsz�t!", "Regisztr�l", "Kil�p");
    else ShowPlayerDialog(playerid, d_belep, DIALOG_STYLE_PASSWORD, "Bejelentkez�s", "{FFFFFF}�dv a szerveren!\n\nK�rlek add meg a jelszavad, amivel regisztr�lt�lt!", "Bel�p", "Kil�p");
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
    PlayerPlaySound( playerid, 1188, 0.0, 0.0, 0.0 );
    SetPlayerToTeamColor(playerid);
	//Itt mutatjuk a gangzonokat a j�t�kosoknak valamint villog�st is itt lehet be�ll�tani
	for(new i=0; i < zoneDb; i++)
	{
		GangZoneShowForPlayer(playerid, ZoneID[i], GetTeamZoneColor(ZoneInfo[i][zTeam]));
		if(ZoneAttacker[i] != -1) GangZoneFlashForPlayer(playerid, ZoneID[i], GetTeamZoneColor(ZoneAttacker[i]));
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(killerid != INVALID_PLAYER_ID){
	    getPont(killerid);
	    SendDeathMessage(killerid, playerid, reason);
	}
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
		getPont(issuerid);
        SetPlayerHealth(playerid, 0.0);
        SendClientMessage(issuerid,zold,"Fejbel�tted. Kiv�l� tal�lat! +1 pont");
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

forward getPont(playerid);
public getPont(playerid){
	jInfo[playerid][Pont]++;
	SetPlayerScore(playerid, GetPlayerScore(playerid) + 1);
}

forward JatekosBeregelt(playerid);
public JatekosBeregelt(playerid)
{
    TogglePlayerSpectating(playerid, false);
    SendClientMessage(playerid, zold, "Sikeresen regisztr�lt�l!");
    SetSpawnInfo(playerid,0,0,2529.7461,-1736.1093,13.0943,0, 0, 0, 0, 0, 0, 0);
    //SpawnPlayer(playerid);
    return 1;
}

forward JatekosBelep(playerid);
public JatekosBelep(playerid)
{
    new sorok_szama = cache_get_row_count();
    if(sorok_szama == 0) return ShowPlayerDialog(playerid, d_belep, DIALOG_STYLE_PASSWORD, "Bejelentkez�s", "{FFFFFF}�dv a szerveren!\nK�rlek add meg a jelszavad, amivel regisztr�lt�lt!\n\n{FF0000}Hib�s jelsz�!", "Bel�p", "Kil�p");
    //Az elobb, ha hib�s volt a jelsz� visszat�rt�nk volna, sz�val innenztol ami lefut k�d, az m�r j� jelsz�val fut le:
    TogglePlayerSpectating(playerid, false);
    SendClientMessage(playerid, zold, "Sikeresen bejelentkezt�l!");
	jInfo[playerid][Penz] = cache_get_field_content_int(0, "PENZ",kapcs);
    jInfo[playerid][Pont] = cache_get_field_content_int(0, "PONT",kapcs);
    jInfo[playerid][alevel] = cache_get_field_content_int(0, "ADMINLVL",kapcs);
    jInfo[playerid][warndb] = 0;
	SetPlayerScore(playerid, jInfo[playerid][Pont]);
	GivePlayerMoney(playerid, jInfo[playerid][Penz]);
    return 1;
}

public ZoneTimer()
{
	for(new i=0; i < zoneDb; i++) // loop all zones
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

public GetPlayersOnServer() {
 new count;
 for(new x=0; x< MAX_PLAYERS; x++) { //x = MAX_PLAYERS
    if(IsPlayerConnected( x )) {
   count++;
  }
 }
 return count;
}

stock IsPlayerInZone(playerid, zoneid)
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	return (x > ZoneInfo[zoneid][zMinX] && x < ZoneInfo[zoneid][zMaxX] && y > ZoneInfo[zoneid][zMinY] && y < ZoneInfo[zoneid][zMaxY]);
}

stock GetPlayerZone(playerid)
{
	for(new i=0; i < zoneDb; i++)
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
		//A sz�nek v�g�n a 88-as az �tl�tsz�s�got jelenti, ez cs�kkentheto ha m�gkisebb sz�mot �runk
		case TEAM_HUN: return 0x00FF0088;
		case TEAM_GRE: return 0xFF00FF88;
		case TEAM_ITA: return 0xFFFF0088;
		case TEAM_RUS: return 0x0000FF88;
		case TEAM_KIN: return 0x01F8FE88;
		case TEAM_KAM: return 0xBE7C4188;
	}
	return -1;
}

stock MySQL_BanCheck(playerid)
{
	new IP[16];
	GetPlayerIp(playerid, IP, 16);
	format(query, sizeof(query),"SELECT * FROM `bandata` WHERE(`jatekos`='%s' OR `ip`='%s') AND `bannolva`=1 LIMIT 1", jInfo[playerid][Nev], IP);
	mysql_query(kapcs, query);
	bannolvavan[playerid] = 0;

	if(!cache_get_row_count()) return printf("cache_get_row_count returned false. Nincsennek bet�ltend� sorok.");
	 	for(new i; i < cache_get_row_count(); i++)
		{
		    TogglePlayerControllable(playerid,0);
		    bannolvavan[playerid] = 1;
			new adminname[50], reason[100], eljaroadmin[50], oka[100];
			cache_get_field_content(0, "admin", eljaroadmin);
			cache_get_field_content(0, "ok", oka);
			format(adminname, sizeof(adminname),"Admin: %s", eljaroadmin);
			format(reason, sizeof(reason),"Reason: %s", oka);
			SendClientMessage(playerid, piros,"Bannolva vagy a szerverr�l!");
			SendClientMessage(playerid, piros,"___________________");
			SendClientMessage(playerid, piros, adminname);
			SendClientMessage(playerid, piros, reason);
			SendClientMessage(playerid, piros,"___________________");
			SendClientMessage(playerid, piros, "Ha jogtalannak �rzed a bannt, �s igazolni tudod screenshotal, keresd fel a f�rumot!");
			SendClientMessage(playerid, piros, "www.szerverunk.hu");
			Kick_Player(playerid);
		}
  return 0;
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
        if(strlen(inputtext) < 5 || strlen(inputtext) > 32) return ShowPlayerDialog(playerid, d_reg, DIALOG_STYLE_PASSWORD, "Regisztr�ci�", "{FFFFFF}�dv a szerveren!\nM�g nem regisztr�lt�l!\nK�rlek adj meg egy megjegyezheto �s eros jelsz�t!\n\n{FF0000}Jelszavadnak 5-32 karakter k�z�tt kell lennie!", "Regisztr�l", "Kil�p");
        mysql_format(kapcs, query, 256, "INSERT INTO jatekosok (NEV,JELSZO,PENZ,PONT) VALUES ('%e',SHA1('%e'),'0','0')", jInfo[playerid][Nev], inputtext);
        mysql_tquery(kapcs, query, "JatekosBeregelt", "d", playerid);
    }
return 1;
}

Dialog_Belepes(playerid, response, inputtext[])
{
	{
        if(!response) return Kick(playerid);
        if(strlen(inputtext) < 5 || strlen(inputtext) > 32) return ShowPlayerDialog(playerid, d_belep, DIALOG_STYLE_PASSWORD, "Bejelentkez�s", "{FFFFFF}�dv a szerveren!\nM�r regisztr�lt�l!\nK�rlek add meg a jelszavad, amivel regisztr�lt�lt�l!\n\n{FF0000}Jelszavadnak 5-32 karakter k�z�tt kell lennie!", "Bel�p", "Kil�p");
        mysql_format(kapcs, query, 256, "SELECT * FROM jatekosok WHERE NEV='%e' AND JELSZO=SHA1('%e')", jInfo[playerid][Nev], inputtext);
        mysql_tquery(kapcs, query, "JatekosBelep", "d", playerid);
    }
return 1;
}

forward Kick_Player(playerid);
public Kick_Player(playerid){
	SetTimerEx("KickTimer", 1000, false, "i", playerid);
	return 1;
}

forward KickTimer(playerid);
public KickTimer(playerid)
{
    Kick(playerid);
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

	format(buffer, sizeof(buffer),"Z�NA-%d",random(10));
	SetVehicleNumberPlate(AddStaticVehicleEx(mID,pX+4,pY,pZ,pR,140,140,-1,0),buffer);

	AutoCount++;
	return 1;
}

CMD:tp(playerid,params[])
{
	new pID, str[128];
	new Float:aX, Float:aY, Float:aZ;
	if(sscanf(params, "i", pID)) return SendClientMessage(playerid, orange, "Haszn�lat: /tp [playerid]");
	if(IsPlayerConnected(pID))
	{
		GetPlayerPos(playerid, aX, aY, aZ);
		SetPlayerPos(pID, aX+0.5, aY+0.5, aZ+0.5);
		format(str, sizeof(str), "Teleport�ltad %s j�t�kost! ",jInfo[pID][Nev]);
		SendClientMessage(playerid, zold, str);
		SetPlayerInterior(pID,0);
	}
	else SendClientMessage(playerid, orange, "Nincs ilyen j�t�kos!");
	return 1;
}

CMD:pteam(playerid,params[])
{
	new teamNumber, pID;
	if(sscanf(params, "ii", pID, teamNumber)) return SendClientMessage(playerid, orange, "Haszn�lat: /pteam [playerid] [1,2,3]");
	if(IsPlayerConnected(pID))
	{
		SetPlayerTeam(pID, teamNumber);
		new str[128];
		format(str, sizeof(str), "A team sikeresen be�ll�tva %s j�t�kosnak! [ID: %d, Team: %d]", jInfo[pID][Nev], pID, teamNumber);
		SendClientMessage(playerid, zold, str);
		format(str, sizeof(str), "Be�ll�tott�k a csapatodat! [Csapat: %d]", teamNumber);
		SendClientMessage(pID, zold, str);
	}
	return 1;
}

CMD:fegyver(playerid,params[]){
	new weaponID;

    if(sscanf(params,"i",weaponID)) return SendClientMessage(playerid,orange,"HasznA!lat /fegyver [id]");
    if(weaponID<0 || weaponID>47) return SendClientMessage(playerid,orange,"1-47-ig vannak csak fegyverek!");
	GivePlayerWeapon(playerid, weaponID, 64);
	return 1;
}

CMD:szone(playerid,params[]){
 new melyik;
 new melyikteam;
    if(sscanf(params,"ii",melyik, melyikteam)) return SendClientMessage(playerid,orange,"Haszn�lat /szone [1 - min, 2 - max] [melyik team]");
    {
        if(melyik == 1) {
			new Float:x, Float:y, Float:z;
			GetPlayerPos(playerid, x, y, z);
			SaveZone[0][zMinX] = x;
			SaveZone[0][zMinY] = y;
			SendClientMessage(playerid, zold, "A z�na kezdete sikeresen lementve! Menj a m�sik sarokba �s /szone 2 [teamcolor]!");
        }

        if(melyik == 2) {
			new Float:x, Float:y, Float:z;
			GetPlayerPos(playerid, x, y, z);
			SaveZone[0][zMaxX] = x;
			SaveZone[0][zMaxY] = y;
			SaveZone[0][zTeam] = melyikteam;
			format(query, sizeof(query), "INSERT INTO zones VALUES ('','%f','%f','%f','%f','%d')", SaveZone[0][zMinX], SaveZone[0][zMinY], SaveZone[0][zMaxX], SaveZone[0][zMaxY], melyikteam);
			mysql_tquery(kapcs, query);
			SendClientMessage(playerid, zold, "A z�na sikeresen elmentve az adatb�zisba!");

			ZoneInfo[zoneDb][zId] = zoneDb;
			ZoneInfo[zoneDb][zMinX] = SaveZone[0][zMinX];
			ZoneInfo[zoneDb][zMinY] = SaveZone[0][zMinY];
			ZoneInfo[zoneDb][zMaxX] = SaveZone[0][zMaxX];
			ZoneInfo[zoneDb][zMaxY] = SaveZone[0][zMaxY];
			ZoneInfo[zoneDb][zTeam] = SaveZone[0][zTeam];
			ZoneID[zoneDb] = GangZoneCreate(SaveZone[0][zMinX], SaveZone[0][zMinY], SaveZone[0][zMaxX], SaveZone[0][zMaxY]);
			printf("zonedb: %d", zoneDb);
			printf("%d, %f, %f, %f, %f, %d", ZoneInfo[zoneDb][zId], ZoneInfo[zoneDb][zMinX], ZoneInfo[zoneDb][zMinY], ZoneInfo[zoneDb][zMaxX], ZoneInfo[zoneDb][zMaxY], ZoneInfo[zoneDb][zTeam]);

		for(new i = 0; i < GetPlayersOnServer(); i++){
			GangZoneShowForPlayer(i, ZoneID[zoneDb], GetTeamZoneColor(ZoneInfo[zoneDb][zTeam]));
		}
		zoneDb++;
        }
    }
 return 1;
}

//-----------------------------------ADMIN PARANCSOK----------------------------
CMD:acmd(playerid, params[])
{
	new teljes[1024];
	new str1[512] = "/time [ID�] - id��ll�t�s\n/get [ID] -  j�t�kos magadhoz tel�z�se\n/oda [ID] - odateleport�lsz valakihez\n/vrespawn - j�rm�vek �jraspawnol�sa\n/adszolg - adminszolg�lat\n/warn [ID] [INDOK] - figyelmeztet�s\n/ban [ID] [INDOK] - j�t�kos kitilt�sa\n/kick [ID] [INDOK] - j�t�kos kir�g�sa\n/setskin [ID] [SkinID] - kin�zet �ll�t�s\n/penz [ID] [�SSZEG] - p�nz �ll�t�s\n/idojaras [Id�j�r�sID] - id�j�r�s �ll�t�s\n/gazdagok - megmutatja a leggazdagabb embereket\n";
	new str2[512] = "/adminszint [ID] [SZINT] - adminszint �ll�t�s\n/healall - mindenkinek az �let�t felt�lti\n/heal [ID] - egy j�t�kos �let�nek felt�lt�se\n/armour [ID] - p�nc�lzat felt�lt�se\n/disarm [ID] - j�t�kos lefegyverz�se\n/dynamic - dinamikus id� �s id�j�r�s\n/asz [SZ�VEG] - F�admin-chat\n/jail [ID] [PERC] [INDOK] - j�t�kos b�rt�nbe z�r�sa\n/unjail [ID] - j�t�kos kienged�se";
	if(jInfo[playerid][alevel] == 0) return SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 1]");
	format(teljes, sizeof(teljes), "%s%s%s", str1, str2);
	ShowPlayerDialog(playerid, d_admin, DIALOG_STYLE_MSGBOX, "Adminparancsok:", teljes,"Rendben","");
	return 1;
}

CMD:adszolg(playerid,params[]){
	new string[128];
	if(IsPlayerConnected(playerid))
	{
		if(jInfo[playerid][alevel] >0)
		{
			if(AdminSzolgalat[playerid] == false)
			{
				asz = Create3DTextLabel("Admin Szolg�latban", vkek, 0.0, 0.0, 2.0, 100, 0, 1);
				Attach3DTextLabelToPlayer(asz, playerid, 0.0, 0.0, 0.4);
           		ShowNameTags( 0 );
				format(string,sizeof(string),"[ ! ] Admin, %s szolg�latba l�pett!",jInfo[playerid][Nev]);
				SendClientMessageToAll(vzold,string);
				AdminSzolgalat[playerid] = true;
				SetPlayerSkin(playerid, 217);
			}
			else if(AdminSzolgalat[playerid] == true)
			{
                Delete3DTextLabel(asz);
		       	ShowNameTags( 1 );
				format(string, sizeof(string), "[ ! ] Admin %s befejezte a szolg�latot!", jInfo[playerid][Nev]);
				SendClientMessageToAll(vzold,string);
				AdminSzolgalat[playerid] = false;
				//SetPlayerSkin(playerid,)
			}
		}else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 1]");
	}
return 1;
}

CMD:adminszint(playerid,params[])
{
	if(jInfo[playerid][alevel] > 3)
	{
		new pid, level, string[128], nev[128];
        if(sscanf(params, "ud", pid, level)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /adminszint [ID] [SZINT]");
        GetPlayerName(pid,nev,sizeof(nev));
		if(pid == INVALID_PLAYER_ID) return SendClientMessage(playerid, piros, "[ ! ] Nincs ilyen j�t�kos!");
		if(level > 5) return SendClientMessage(playerid, piros, "[ ! ] Maximum adminszint: 5");
		if(jInfo[playerid][alevel] == level) return SendClientMessage(playerid, piros, "[ ! ] M�r megvan a be�rt szint!");
		format(string,sizeof(string),"[ ! ] Admin %s be�ll�totta %s adminszintj�t %d-re",jInfo[playerid][Nev],nev,level);
		SendClientMessageToAll(vzold,string);
		jInfo[pid][alevel] = level;
	}
	else
	{
        SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 4]");
	}
return 1;
}

CMD:setskin(playerid, params[])
{
    if(jInfo[playerid][alevel] > 0)
	{
		new pid, skin, string[128];
		if(sscanf(params, "ud", pid, skin)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /setskin [ID] [SKINID]");
		if(pid == INVALID_PLAYER_ID) return SendClientMessage(playerid, piros, "[ ! ] Nincs ilyen j�t�kos!");
		if(skin < 0 || skin > 299) return SendClientMessage(playerid, piros, "[ ! ] Hib�s skinID, 0-299 vannak!");
		format(string,sizeof(string),"[ ! ] Admin: %s �t�ll�totta a skined! [�j skin ID: %d]", jInfo[playerid][Nev], skin);
		SendClientMessage(pid, orange, string);
		SetPlayerSkin(pid, skin);
		TogglePlayerControllable(playerid, true);
    }else{
		SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 1]");
	}
	return 1;
}

CMD:get(playerid,params[])
{
	new pID, str[128];
	new Float:aX, Float:aY, Float:aZ;
	if(jInfo[playerid][alevel] > 2)
	{
		if(sscanf(params, "i", pID)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /tp [playerid]");
		if(pID == INVALID_PLAYER_ID) return SendClientMessage(playerid, piros, "[ ! ] Nincs ilyen j�t�kos!");
		GetPlayerPos(playerid, aX, aY, aZ);
		SetPlayerPos(pID, aX+0.5, aY+0.5, aZ+0.5);
		format(str, sizeof(str), "[ ! ] Admin %s mag�hoz telepolt�rt! ",jInfo[playerid][Nev]);
		SendClientMessage(pID, zold, str);
		SetPlayerInterior(pID,0);
	}else{
	SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 3]");
	}

return 1;
}

CMD:oda(playerid,params[])
{
	new pID, str[128];
	new Float:aX, Float:aY, Float:aZ;
	if(jInfo[playerid][alevel] > 2)
	{
		if(sscanf(params, "i", pID)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /oda [playerid]");
		if(pID == INVALID_PLAYER_ID) return SendClientMessage(playerid, piros, "[ ! ] Nincs ilyen j�t�kos!");
		GetPlayerPos(pID, aX, aY, aZ);
		SetPlayerPos(playerid, aX+0.5, aY+0.5, aZ+0.5);
		format(str, sizeof(str), "[ ! ] Odament�l %s j�t�koshoz! ",jInfo[pID][Nev]);
		SendClientMessage(playerid, zold, str);
		SetPlayerInterior(playerid,0);
	}else{
	SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 3]");
	}

return 1;
}

CMD:penz(playerid,params[])
{
	new pID, str[128],str1[128], osszeg;
	if(jInfo[playerid][alevel] > 3)
	{
		if(sscanf(params, "ii", pID,osszeg)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /penz [playerid] [�sszeg]");
		if(pID == INVALID_PLAYER_ID) return SendClientMessage(playerid, piros, "[ ! ] Nincs ilyen j�t�kos!");
		if(osszeg < 0)return SendClientMessage(playerid, piros, "[ ! ] Negat�v �sszeget nem lehet megadni!");
		format(str, sizeof(str), "[ ! ] Admin adott %d Ft-ot! ",osszeg);
		SendClientMessage(pID, zold, str);
		format(str, sizeof(str1), "[ ! ] P�nzt adt�l %s j�t�kosnak! ",jInfo[pID][Nev]);
		SendClientMessage(playerid, zold, str1);
		jInfo[pID][Penz] += osszeg;

	}else{
	SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 4]");
	}

return 1;
}

CMD:time(playerid, params[])
{
    if(jInfo[playerid][alevel] > 0)
	{
		new time, string[128];
		if(sscanf(params, "d", time)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /time [�RA]");
		if(time > 24) return SendClientMessage(playerid, piros, "[ ! ] Maximum id�: 24");
		format(string,sizeof(string),"[ ! ] Admin: %s �t�ll�totta az id�t! [Id�: %d]", jInfo[playerid][Nev], time);
		SendClientMessageToAll( vzold, string);
		SetWorldTime(time);
    }else{
		SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 1]");
	}
	return 1;
}

CMD:idojaras(playerid, params[])
{
    if(jInfo[playerid][alevel] > 0)
	{
		new weather, string[128];
		if(sscanf(params, "d", weather)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /idojaras [ID�J�R�S-ID]");
		if(weather > 700) return SendClientMessage(playerid, piros, "[ ! ] Maximum id�j�r�s: 700");
		format(string,sizeof(string),"[ ! ] Admin: %s �t�ll�totta az id�j�r�st! [Id�j�r�s: %d]", jInfo[playerid][Nev], weather);
		SendClientMessageToAll(vzold, string);
		SetWeather(weather);
    }else{
		SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 1]");
	}
	return 1;
}

CMD:kick(playerid, params[])
{
    if(jInfo[playerid][alevel]  > 4)
	{
		new pid, indok[50], string[128];
		if(sscanf(params, "us[50]", pid, indok)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /kick [ID] [INDOK]");
		if(pid == INVALID_PLAYER_ID) return SendClientMessage(playerid, piros, "[ ! ] Nincs ilyen j�t�kos!");
		if(pid == playerid) return SendClientMessage(playerid, piros, "[ ! ] Nem r�ghatod ki magad!");
		format(string,sizeof(string),"[ ! ] Admin: %s kir�gta %s -t![indok: %s]", jInfo[playerid][Nev], jInfo[pid][Nev], indok);
		SendClientMessageToAll(vzold, string);
		Kick_Player(pid);
	}else{
		SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 4]");
	}
	return 1;
}

CMD:ban(playerid, params[])
{
    if(jInfo[playerid][alevel]  > 4)
	{
		new pid, indok[50], string[128], ip[16];
		if(sscanf(params, "us[50]", pid, indok)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /ban [ID] [INDOK]");
		if(pid == INVALID_PLAYER_ID) return SendClientMessage(playerid, piros, "[ ! ] Nincs ilyen j�t�kos!");
	    if(pid == playerid) return SendClientMessage(playerid, piros, "[ ! ] Nem bannolhatod ki magad!");
	    GetPlayerIp(pid, ip, 16);
	    mysql_format(kapcs, query, 256, "INSERT INTO bandata (id,admin,jatekos,ok,ip,bannolva) VALUES (0, '%s', '%s', '%s', '%s', 1)", jInfo[playerid][Nev], jInfo[pid][Nev], indok, ip);
        mysql_tquery(kapcs, query);

		format(string,sizeof(string),"[ ! ] Admin: %s kibannolta %s -t![indok: %s]", jInfo[playerid][Nev], jInfo[pid][Nev], indok);
		SendClientMessageToAll(vzold, string);
       	Kick_Player(pid);
    }else{
		SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 4]");
	}
	return 1;
}

CMD:warn(playerid, params[])
{
	new pId, reason[50], str[128];
	if(sscanf(params, "is[50]", pId, reason)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /warn [ID] [INDOK]");
	if(pId == INVALID_PLAYER_ID) return SendClientMessage(playerid, piros, "[ ! ] Nincs ilyen j�t�kos!");
	if(pId == playerid) return SendClientMessage(playerid, piros, "[ ! ] Nem figyelmeztetheted magadat!");
	jInfo[pId][warndb]++;
	if(jInfo[pId][warndb] != 3) {
		format(str, sizeof(str), "[ ! ] Admin: %s figyelmeztette %s -t! [indok: %s] [%d/3]", jInfo[playerid][Nev], jInfo[pId][Nev], reason, jInfo[pId][warndb]);
		SendClientMessageToAll(vzold, str);
	} else {

		format(str, sizeof(str), "[ ! ] Admin: %s kir�gta a szerverr�l %s -t! [indok: %s] [Figyelmeztet�s: %d/3]", jInfo[playerid][Nev], jInfo[pId][Nev], reason, jInfo[pId][warndb]);
		SendClientMessageToAll(vzold, str);
	    Kick_Player(pId);
	}
	return 1;
}

CMD:vrespawn(playerid, params[])
{
	return 1;
}

CMD:ipm(playerid,params[])
{
new ip[16],ipstring[128];
GetPlayerIp(playerid, ip, 16);
format(ipstring,sizeof(ipstring),"IP c�m: %s",ip);
SendClientMessage(playerid,vzold,ipstring);
return 1;
}
