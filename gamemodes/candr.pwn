// This is a comment
// uncomment the line below if you want to write a filterscript
//#define FILTERSCRIPT

#include <a_samp>
#include <a_mysql>
#include <ZCMD>
#include <sscanf2>
#include <cuffs>

#define WHITE     0xFFFFFFAA
#define GREY      0xAFAFAFAA
#define RED       0xFF0000AA
#define YELLOW    0xFFFF00FF
#define LIGHTBLUE 0x33CCFFAA
#define BLUE      0x0000FFFF
#define GREEN     0x33AA33AA
#define ORANGE    0xFF9900AA
#define ROSE      0xFF99CCAA

#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Rics & Dev Cops and Robbers");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

#else

new kapcs, query[2000];
new AutoCount = 0;
new playerBoltElott[MAX_PLAYERS];
new Sorompok[MAX_OBJECTS];
new ObjektCount=0;
new SorompoID=0;
new EnterCount=0;
new AtmCount=0;

main()
{
	print("\n----------------------------------");
	print(" Rics & Dev Cops and Robbers");
	print("----------------------------------\n");
	mysql_log(LOG_ALL, LOG_TYPE_HTML);
	kapcs = mysql_connect("localhost", "root", "cops", "");
	if(mysql_errno(kapcs) != 0) printf("MySQL hiba! Hibakód: %d", mysql_errno(kapcs));
	mysql_tquery(kapcs, "SELECT * FROM `cars`","AutoLoad");
	mysql_tquery(kapcs, "SELECT * FROM `objects`","ObjectLoad");
	mysql_tquery(kapcs, "SELECT * FROM `enter`","EnterLoad");
}

enum Player{
	db_id,
	nev[40],
	score,
	penz,
	alvl,
	munka
}
new PlayerInfo[MAX_PLAYERS][Player];

enum Car{
	ID,
	db_id,
	rszam[8],
	modelid,
	Float:x,
	Float:y,
	Float:z,
	Float:angle,
	tulaj,
	col1,
	col2
}
new CarInfo[MAX_VEHICLES][Car];

enum mRiasztas{
	hivo,
	Float:x,
	Float:y,
	Float:z,
	szabad
}
new MentoRiasztas[500][mRiasztas];
new MentoRiasztasDb = 0;

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

enum Enter
{
	id,
	interior,
	Float:x,
	Float:y,
	Float:z,
	Float:hx,
	Float:hy,
	Float:hz,
	kibe,
	leiras[31],
	mapicon
}
new EnterInfo[200][Enter];

enum Atm
{
	id,
	modelID,
	Float:xCor,
	Float:yCor,
	Float:zCor,
    Float:rxCor,
    Float:ryCor,
    Float:rzCor,
    rabolhato
}
new AtmInfo[100][Atm];

//dialog enum
enum
{
	d_reg,
	d_belep,
	DialogFegyverbolt
} //Dialogok automatikus számozása.
//dialog enum

#endif

public OnGameModeInit()
{
	// Don't use these lines if it's a filterscript
	UsePlayerPedAnims();         			//Normál futás
	DisableInteriorEnterExits(); 			//Interior kikapcs
	EnableStuntBonusForAll(0);              //ugrató pénz kikapcs
	SetGameModeText("Rics & Dev Cops and Robbers");
	
	//civil
	//civil
	//bandák
	AddPlayerClass(102, 2442.3882, -1357.1639, 24.0000, 269.4359, 22, 320, 28, 400, 0, 0);//0 lila
	AddPlayerClass(103, 2442.3882, -1357.1639, 24.0000, 269.4359, 22, 320, 28, 400, 0, 0);//1 lila
	AddPlayerClass(104, 2442.3882, -1357.1639, 24.0000, 269.4359, 22, 320, 28, 400, 0, 0);//2 lila
	AddPlayerClass(105, 2514.7234, -1673.9424, 13.6764, 64.5817, 22, 320, 29, 450, 0, 0);//3 zöld
	AddPlayerClass(106, 2514.7234, -1673.9424, 13.6764, 64.5817, 22, 320, 29, 450, 0, 0);//4 zöld
	AddPlayerClass(107, 2514.7234, -1673.9424, 13.6764, 64.5817, 22, 320, 29, 450, 0, 0);//5 zöld
	AddPlayerClass(108, 2112.4253, -1063.8143, 25.7362, 131.9865, 22, 320, 32, 450, 0, 0);//6 sárga
	AddPlayerClass(109, 2112.4253, -1063.8143, 25.7362, 131.9865, 22, 320, 32, 450, 0, 0);//7 sárga
	AddPlayerClass(110, 2112.4253, -1063.8143, 25.7362, 131.9865, 22, 320, 32, 450, 0, 0);//8 sárga
	AddPlayerClass(114, 1903.9756, -1924.7733, 13.5469, 182.7015, 22, 320, 32, 450, 0, 0);//9 kék
	AddPlayerClass(115, 1903.9756, -1924.7733, 13.5469, 182.7015, 22, 320, 32, 450, 0, 0);//10 kék
	AddPlayerClass(116, 1903.9756, -1924.7733, 13.5469, 182.7015, 22, 320, 32, 450, 0, 0);//11 kék
	//bandák 31 id 30
	//rendõr
	AddPlayerClass(280, 1544.7183,-1675.5586,13.5590, 90, 3, 1, 22, 320, 25, 24);//12
	AddPlayerClass(281, 1544.7183,-1675.5586,13.5590, 90, 3, 1, 22, 320, 25, 24);//13
	AddPlayerClass(282, 1544.7183,-1675.5586,13.5590, 90, 3, 1, 22, 320, 25, 24);//14
	AddPlayerClass(283, 1544.7183,-1675.5586,13.5590, 90, 3, 1, 22, 320, 25, 24);//15
	AddPlayerClass(284, 1544.7183,-1675.5586,13.5590, 90, 3, 1, 22, 320, 25, 24);//16
	AddPlayerClass(288, 1544.7183,-1675.5586,13.5590, 90, 3, 1, 22, 320, 25, 24);//17
	//rendõr 37 id 36
	//mentõ
	AddPlayerClass(274,2025.3894,-1423.2598,16.9922,136.1342,0,0,0,0,0,0);//18
	AddPlayerClass(275,2025.3894,-1423.2598,16.9922,136.1342,0,0,0,0,0,0);//19
	AddPlayerClass(276,1182.1154,-1323.9969,13.5814,270,0,0,0,0,0,0);//20
	//mentõ 40 id 39
	return 1;
}

public OnGameModeExit()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerConnected(i))
	    {
			JatekosMent(i);
			printf("%i playerid mentve!", i);
		}
	}
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(classid >= 0 && classid <= 11)
	{
	    GameTextForPlayer(playerid, "Banda", 1000, 3);
	    if(classid == 0 || classid == 1 || classid == 2) // lila
		{
		    SetPlayerPos(playerid, 2442.3882, -1357.1639, 24.0000);
		    SetPlayerFacingAngle(playerid, 269.4359);
			SetPlayerCameraPos(playerid, 2446.0061, -1357.1639, 24.0000);
			SetPlayerCameraLookAt(playerid, 2442.3882, -1357.1639, 24.0000);
			SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 0);
    		SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 0);
		}
		else if(classid == 3 || classid == 4 || classid == 5 )// zöld
	    {
     		SetPlayerPos(playerid, 2514.7234,-1673.9424,13.6764);
		    SetPlayerFacingAngle(playerid, 64.5817);
			SetPlayerCameraPos(playerid, 2509.5061,-1672.0372,13.6764);
			SetPlayerCameraLookAt(playerid, 2514.7234,-1673.9424,13.6764);
			SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 0);
    		SetPlayerSkillLevel(playerid, WEAPONSKILL_MP5, 0);
	    }
	    else if(classid == 6 || classid == 7 || classid == 8) // sárga
	    {
     		SetPlayerPos(playerid, 2112.4253, -1063.8143, 25.7362);
		    SetPlayerFacingAngle(playerid, 131.9865);
			SetPlayerCameraPos(playerid, 2109.5676,-1067.4277,25.7362);
			SetPlayerCameraLookAt(playerid, 2112.4253, -1063.8143, 25.7362);
			SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 0);
    		SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 0);
	    }
	    else if(classid == 9 || classid == 10 || classid == 11) // kék
	    {
     		SetPlayerPos(playerid, 1903.9756, -1924.7733, 13.5469);
		    SetPlayerFacingAngle(playerid, 182.7015);
			SetPlayerCameraPos(playerid, 1903.9756,-1929.8198,13.5469);
			SetPlayerCameraLookAt(playerid, 1903.9756, -1924.7733, 13.5469);
			SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 0);
    		SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 0);
	    }
		SetPlayerArmour(playerid, 0.0);
		
	    SetPlayerColor(playerid, YELLOW);
	    PlayerInfo[playerid][munka] = 1;
	}
	if(classid >= 12 && classid <= 17)
	{
	    GameTextForPlayer(playerid, "Rendor", 1000, 3);
	    SetPlayerPos(playerid, 1544.7183, -1675.5586, 13.5590);
	    SetPlayerFacingAngle(playerid, 90);
		//SetPlayerCameraPos(playerid, (1544.7183+3), -1675.5586, 13.5590);
		SetPlayerCameraPos(playerid, 1540.7135,-1675.5586, 13.5590);
		SetPlayerCameraLookAt(playerid, 1544.7183, -1675.5586, 13.5590);
		SetPlayerArmour(playerid, 100.0);
		SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 0);
    	SetPlayerSkillLevel(playerid, WEAPONSKILL_SHOTGUN, 0);
	    SetPlayerColor(playerid, BLUE);
	    PlayerInfo[playerid][munka] = 2;
	}
	if(classid >= 18 && classid <= 20)
	{
	    GameTextForPlayer(playerid, "Mento", 1000, 3);
	    if(classid == 39)
	    {
	        SetPlayerPos(playerid, 1182.1154,-1323.9969,13.5814);
		    SetPlayerFacingAngle(playerid, 270);
			SetPlayerCameraPos(playerid, (1182.1154+3),-1323.9969,13.5814);
			SetPlayerCameraLookAt(playerid, 1182.1154,-1323.9969,13.5814);
	    }
	    else
	    {
		    SetPlayerPos(playerid, 2025.3894,-1423.2598,16.9922);
		    SetPlayerFacingAngle(playerid, 136.1342);
			SetPlayerCameraPos(playerid, 2022.9388,-1425.6360,16.9922);
			SetPlayerCameraLookAt(playerid, 2025.3894,-1423.2598,16.9922);
		}
		SetPlayerArmour(playerid, 0.0);
		SetPlayerColor(playerid, ROSE);
		PlayerInfo[playerid][munka] = 3;
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
    TogglePlayerSpectating(playerid, true);                                                   //eltuntetjük a spawn gombot.
    GetPlayerName(playerid, PlayerInfo[playerid][nev], 40);                                  //Lekérjük a nevét.
    if(strfind(PlayerInfo[playerid][nev], "_") == -1)                                        //Nem tartalmaz alsóvonást.
    for(new a; a < strlen(PlayerInfo[playerid][nev]); a++) if(PlayerInfo[playerid][nev][a] == '_') PlayerInfo[playerid][nev][a] = ' ';//Végigfutunk a nevén. Ha az egyik karaktere '_', kicseréli ' '-re.
    mysql_format(kapcs, query, 256, "SELECT id,name FROM users WHERE name='%e' LIMIT 1", PlayerInfo[playerid][nev]);
    mysql_tquery(kapcs, query, "RegEllenorzes", "d", playerid);
    
    //remove building
    RemoveBuildingForPlayer(playerid, 1440, 1147.9771, -1386.1046, 13.35551,3.6364884);
    RemoveBuildingForPlayer(playerid, 1440, 1142.4459, -1346.2114, 13.18058,3.6364884);
    //remove buliding
    
    for(new i = 0; i < EnterCount; i++)
	{
		if(EnterInfo[i][kibe] == 0)
		{
	    	Create3DTextLabel(EnterInfo[i][leiras], YELLOW, EnterInfo[i][x],EnterInfo[i][y],EnterInfo[i][z], 40.0, 0, 0);
	    	SetPlayerMapIcon(playerid, i+1, EnterInfo[i][x],EnterInfo[i][y],EnterInfo[i][z], EnterInfo[i][mapicon], 0, MAPICON_LOCAL);
		}
    }
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    JatekosMent(playerid);
    
    new szDisconnectReason[3][] =
    {
        "Timeout",
        "Exit",
        "Kick/Ban"
    };
    
    new msg[128];
    format(msg, sizeof(msg), "%s kilépett a játékból! (%s)", PlayerInfo[playerid][nev], szDisconnectReason[reason]);
    SendClientMessageToAll(GREY, msg);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
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
	if(GetPVarInt(playerid, "mentoCh") == 1)
	{
	    DisablePlayerCheckpoint(playerid);
	    SetPVarInt(playerid, "mentoCh", 0);
	}
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
	//bejáratok
	for(new i = 0; i < EnterCount; i++)
	{
	    if(IsPlayerInRangeOfPoint(playerid,1.0,EnterInfo[i][x],EnterInfo[i][y],EnterInfo[i][z]))
		{
		    SetPlayerInterior(playerid, EnterInfo[i][interior]);
		    SetPlayerPos(playerid, EnterInfo[i][hx], EnterInfo[i][hy], EnterInfo[i][hz]);
		}
	}
	//bejáratok
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

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
	{
        case d_reg: Dialog_Regisztracio(playerid, response, inputtext);
        case d_belep: Dialog_Belepes(playerid, response, inputtext);
        case DialogFegyverbolt: Dilaog_Fegyver(playerid, response, listitem);
    }
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

//SQL belépés
forward RegEllenorzes(playerid);
public RegEllenorzes(playerid) {
    new sorok_szama = cache_get_row_count();
    if(sorok_szama == 0) ShowPlayerDialog(playerid, d_reg, DIALOG_STYLE_PASSWORD, "Regisztráció", "{FFFFFF}Üdv a szerveren!\nMég nem regisztráltál!\nKérlek adj meg egy jelszót!", "Regisztrál", "Kilép");
    else ShowPlayerDialog(playerid, d_belep, DIALOG_STYLE_PASSWORD, "Bejelentkezés", "{FFFFFF}Üdv a szerveren!\nMár regisztráltál!\n\nKérlek add meg a jelszavad, amivel regisztráltált!", "Belép", "Kilép");
    return 1;
}

Dialog_Regisztracio(playerid, response, inputtext[])
{
	{
        if(!response) return Kick(playerid);
        if(strlen(inputtext) < 5 || strlen(inputtext) > 32) return ShowPlayerDialog(playerid, d_reg, DIALOG_STYLE_PASSWORD, "Regisztráció", "{FFFFFF}Üdv a szerveren!\nMég nem regisztráltál!\nKérlek adj meg egy megjegyezheto és eros jelszót!\n\n{FF0000}Jelszavadnak 5-32 karakter között kell lennie!", "Regisztrál", "Kilép");
        mysql_format(kapcs, query, 256, "INSERT INTO users (name,pass,money,score,alvl) VALUES ('%e',SHA1('%e'),'20000','0','0')", PlayerInfo[playerid][nev], inputtext);
        mysql_tquery(kapcs, query, "JatekosBeregelt", "d", playerid);
    }
	return 1;
}

Dialog_Belepes(playerid, response, inputtext[])
{
	{
        if(!response) return Kick(playerid);
        if(strlen(inputtext) < 5 || strlen(inputtext) > 32) return ShowPlayerDialog(playerid, d_belep, DIALOG_STYLE_PASSWORD, "Bejelentkezés", "{FFFFFF}Üdv a szerveren!\nMár regisztráltál!\nKérlek add meg a jelszavad, amivel regisztráltáltál!\n\n{FF0000}Jelszavadnak 5-32 karakter között kell lennie!", "Belép", "Kilép");
        mysql_format(kapcs, query, 256, "SELECT * FROM users WHERE name='%e' AND pass=SHA1('%e')", PlayerInfo[playerid][nev], inputtext);
        mysql_tquery(kapcs, query, "JatekosBelep", "d", playerid);
    }
	return 1;
}

forward JatekosBeregelt(playerid);
public JatekosBeregelt(playerid)
{
        SendClientMessage(playerid, 0xFFFFFFFF, "Sikeresen regisztráltál!");
        //SetSpawnInfo(playerid, 0, 7, 1679.2263, 1447.4387, 10.7745, 270.0, 0, 0, 0, 0, 0, 0);
        TogglePlayerSpectating(playerid, false);
        //SpawnPlayer(playerid);
        PlayerInfo[playerid][penz] = 20000;
		PlayerInfo[playerid][score] = 0;
		PlayerInfo[playerid][alvl] = 0;
        SendClientMessage(playerid, 0xFFFFFFFF, "Jó játékot kívánok!");
        playerBoltElott[playerid] = 0;
        GivePlayerMoney(playerid, PlayerInfo[playerid][penz]);
        SetPlayerScore(playerid, PlayerInfo[playerid][score]);
        new con[128];
		format(con, sizeof(con), "%s kapcsolódott a szerverre.", PlayerInfo[playerid][nev]);
        SendClientMessageToAll(GREY, con);
        return 1;
}

forward JatekosBelep(playerid);
public JatekosBelep(playerid)
{
        new sorok_szama = cache_get_row_count();
        if(sorok_szama == 0) return ShowPlayerDialog(playerid, d_belep, DIALOG_STYLE_PASSWORD, "Bejelentkezés", "{FFFFFF}Üdv a szerveren!\nJatekosInfo regisztráltál!Kérlek add meg a jelszavad, amivel regisztráltált!\n\n{FF0000}Hibás jelszó!", "Belép", "Kilép");
        //Az elobb, ha hibás volt a jelszó visszatértünk volna, szóval innenztol ami lefut kód, az már jó jelszóval fut le:
        SendClientMessage(playerid, GREEN, "Sikeresen bejelentkeztél!");
        SendClientMessage(playerid, 0xFFFFFFFF, "Jó játékot kívánok!");
        TogglePlayerSpectating(playerid, false);
        //SetSpawnInfo(playerid, 0, cache_get_field_content_int(0, "skin"), cache_get_field_content_float(0, "X"), cache_get_field_content_float(0, "Y"), cache_get_field_content_float(0, "Z"), 90.0, 0, 0, 0, 0, 0, 0); //Beállítjuk a spawn pozíciót, skint egyebeket.
        //SpawnPlayer(playerid);
        PlayerInfo[playerid][penz] = cache_get_field_content_int(0, "money",kapcs);
		PlayerInfo[playerid][score] = cache_get_field_content_int(0, "score",kapcs);
		PlayerInfo[playerid][db_id] = cache_get_field_content_int(0, "id",kapcs);
		PlayerInfo[playerid][alvl] = cache_get_field_content_int(0, "alvl",kapcs);
        playerBoltElott[playerid] = 0;
        GivePlayerMoney(playerid, PlayerInfo[playerid][penz]);
        SetPlayerScore(playerid, PlayerInfo[playerid][score]);
		new con[128];
		format(con, sizeof(con), "%s kapcsolódott a szerverre.", PlayerInfo[playerid][nev]);
        SendClientMessageToAll(GREY, con);
		return 1;
}

forward AutoLoad();
public AutoLoad()
{
	if(!cache_get_row_count()) return printf("cache_get_row_count returned false. Nincsennek betöltendõ sorok.");
 	for(new i = 0; i < cache_get_row_count(); i++)
	{
	    new rendszam[8];
		//AutoInfo[i][ID] = AutoCount;
		cache_get_field_content(i, "rendszam", rendszam);
		CarInfo[i][rszam] = rendszam;
		CarInfo[i][modelid] = cache_get_field_content_int(i,"modelid",kapcs);
		CarInfo[i][tulaj] = cache_get_field_content_int(i,"tulaj",kapcs);
		CarInfo[i][x] = cache_get_field_content_float(i,"x",kapcs);
		CarInfo[i][y] = cache_get_field_content_float(i,"y",kapcs);
		CarInfo[i][z] = cache_get_field_content_float(i,"z",kapcs);
		CarInfo[i][angle] = cache_get_field_content_float(i,"angle",kapcs);
		CarInfo[i][col1] = cache_get_field_content_int(i,"col1",kapcs);
		CarInfo[i][col2] = cache_get_field_content_int(i,"col2",kapcs);
		if(CarInfo[i][tulaj] == 0)
		{
			CarInfo[i][ID] = AddStaticVehicleEx(CarInfo[i][modelid],CarInfo[i][x],CarInfo[i][y],CarInfo[i][z],CarInfo[i][angle],CarInfo[i][col1],CarInfo[i][col2],300,0);
		}
		else
		{
		    CarInfo[i][ID] = AddStaticVehicleEx(CarInfo[i][modelid],CarInfo[i][x],CarInfo[i][y],CarInfo[i][z],CarInfo[i][angle],CarInfo[i][col1],CarInfo[i][col2],-1,0);
		}
		SetVehicleNumberPlate(CarInfo[i][ID], CarInfo[i][rszam]);
		AutoCount++;
		//printf("autok: %f, %f, %f",CarInfo[i][x],CarInfo[i][y],CarInfo[i][z]);
	}
    printf("%d autó betöltve!", AutoCount);
		//SetTimer("AutoSave", 1000, true);
	return 1;
}

forward JatekosMent(playerid);
public JatekosMent(playerid)
{
    mysql_format(kapcs, query, 384, "UPDATE users SET money='%d',score = '%d' WHERE name='%s'", PlayerInfo[playerid][penz], PlayerInfo[playerid][score], PlayerInfo[playerid][nev]);
    mysql_tquery(kapcs, query);
}

forward ObjectLoad();
public ObjectLoad()
{
	if(!cache_get_row_count()) return printf("cache_get_row_count returned false. Nincsennek betöltendõ sorok.");
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

		if(Objektumok[i][modelID] == 968 || Objektumok[i][modelID] == 3578 || Objektumok[i][modelID] == 980)
		{
		    Sorompok[SorompoID] = CreateObject(Objektumok[i][modelID], Objektumok[i][xCor], Objektumok[i][yCor], Objektumok[i][zCor], Objektumok[i][rxCor], Objektumok[i][ryCor], Objektumok[i][rzCor]);
		    SorompoID ++;
		}
		else if(Objektumok[i][modelID] == 2942)
		{
            AtmInfo[AtmCount][id] = Objektumok[i][id];
			AtmInfo[AtmCount][modelID] = Objektumok[i][modelID];
		    AtmInfo[AtmCount][xCor] = Objektumok[i][xCor];
		    AtmInfo[AtmCount][yCor] = Objektumok[i][yCor];
		    AtmInfo[AtmCount][zCor] = Objektumok[i][zCor];
		    AtmInfo[AtmCount][rxCor] = Objektumok[i][rxCor];
		    AtmInfo[AtmCount][ryCor] = Objektumok[i][ryCor];
		    AtmInfo[AtmCount][rzCor] = Objektumok[i][rzCor];
		    AtmInfo[AtmCount][rabolhato] = 1;
		    CreateObject(Objektumok[i][modelID], Objektumok[i][xCor], Objektumok[i][yCor], Objektumok[i][zCor], Objektumok[i][rxCor], Objektumok[i][ryCor], Objektumok[i][rzCor]);
	        AtmCount++;
		}
		else
		{
			CreateObject(Objektumok[i][modelID], Objektumok[i][xCor], Objektumok[i][yCor], Objektumok[i][zCor], Objektumok[i][rxCor], Objektumok[i][ryCor], Objektumok[i][rzCor]);
	        ObjektCount ++;
		}
	}
	printf("%d objektum betöltve!", ObjektCount);
	printf("%d sorompo betöltve!",SorompoID);
	printf("%d atm betöltve!",AtmCount);
	SetTimer("SaveObject", 900000, true);

	return 1;
}

forward EnterLoad();
public EnterLoad()
{
	if(!cache_get_row_count()) return printf("cache_get_row_count returned false. Nincsennek betöltendõ sorok.");
 	for(new i = 0; i < cache_get_row_count(); i++)
	{
		EnterInfo[i][id] = cache_get_field_content_int(i,"id",kapcs);
		EnterInfo[i][interior] = cache_get_field_content_int(i,"interior",kapcs);
	    EnterInfo[i][x] = cache_get_field_content_float(i,"x",kapcs);
	    EnterInfo[i][y] = cache_get_field_content_float(i,"y",kapcs);
	    EnterInfo[i][z] = cache_get_field_content_float(i,"z",kapcs);
	    EnterInfo[i][hx] = cache_get_field_content_float(i,"hx",kapcs);
	    EnterInfo[i][hy] = cache_get_field_content_float(i,"hy",kapcs);
	    EnterInfo[i][hz] = cache_get_field_content_float(i,"hz",kapcs);
	    EnterInfo[i][kibe] = cache_get_field_content_int(i,"kibe",kapcs);
	    new szoveg[31];
		cache_get_field_content(i, "leiras", szoveg);
		EnterInfo[i][leiras] = szoveg;
		EnterInfo[i][mapicon] = cache_get_field_content_int(i,"mapicon",kapcs);

		EnterCount++;
	}
	printf("%d bejárat/kijárat betöltve!", EnterCount);

	return 1;
}
//SQL belépés

CMD:reclass(playerid,params[])
{
	ForceClassSelection(playerid);
    SetPlayerHealth(playerid,0);
    SetPlayerArmour(playerid, 0.0);
	return 1;
}


CMD:kocsi(playerid,params[])
{
	new mID;
	if(sscanf(params,"i",mID)) return SendClientMessage(playerid,YELLOW,"INFO: /kocsi [ID]");
	if(mID<400 || mID>611) return SendClientMessage(playerid,RED,"400-611-ig vannak csak kocsik!");

	new Float:pX,Float:pY,Float:pZ,Float:pR;
	GetPlayerPos(playerid,pX, pY, pZ);
	GetPlayerFacingAngle(playerid, pR);
	SetVehicleNumberPlate(AddStaticVehicleEx(mID,pX+4,pY,pZ,pR,12,12,-1,1), "ADMIN");
	return 1;
}

CMD:kocsiszin(playerid,params[])
{
	new mID;
	new szin1, szin2;
	if(sscanf(params,"iii",mID,szin1,szin2)) return SendClientMessage(playerid,YELLOW,"INFO: /kocsi [ID] [szin1] [szin2]");
	if(mID<400 || mID>611) return SendClientMessage(playerid,RED,"400-611-ig vannak csak kocsik!");
	if(szin1<0 || szin1>168 && szin2<=0 || szin2>168) return SendClientMessage(playerid,RED,"0-tól 168-ig van szín!");

	new Float:pX,Float:pY,Float:pZ,Float:pR;
	GetPlayerPos(playerid,pX, pY, pZ);
	GetPlayerFacingAngle(playerid, pR);
	SetVehicleNumberPlate(AddStaticVehicleEx(mID,pX-4,pY-8,pZ,pR,szin1,szin2,-1,1), "ADMIN");
	return 1;
}

CMD:skocsi(playerid, params[])
{
	if(IsPlayerInAnyVehicle(playerid) != 0)
	{
		new rendszam[8];
		new tulajdonos, szin1, szin2;
		//new string[128];
		if(sscanf(params, "ddd", tulajdonos, szin1, szin2)) return SendClientMessage(playerid, LIGHTBLUE, "Használata: /skocsi [tulaj] [szin1] [szin2]");
		{
		    AutoCount++;
		    new currentveh = GetPlayerVehicleID(playerid);
		    new vehModelID = GetVehicleModel(currentveh);
			new Float:vehx, Float:vehy, Float:vehz, Float:z_rot;
			GetVehiclePos(currentveh, vehx, vehy, vehz);
			GetVehicleZAngle(currentveh, z_rot);
			if(AutoCount < 100)
			{
				format(rendszam, sizeof(rendszam), "CR-00%d", AutoCount);
				printf("%s", rendszam);
			}
			else if(AutoCount < 1000)
			{
			    format(rendszam, sizeof(rendszam), "CR-0%d", AutoCount);
				printf("%s", rendszam);
			}
			else
			{
			    format(rendszam, sizeof(rendszam), "CR-%d", AutoCount);
				printf("%s", rendszam);
			}
			format(query, sizeof(query), "INSERT INTO `cars` (`id`, `rendszam`, `modelid`, `x`, `y`, `z`, `angle`, `tulaj`, `col1`,`col2`) VALUES (NULL, '%s', '%d', '%f', '%f', '%f', '%f', '%d', '%d', '%d')", rendszam, vehModelID, vehx, vehy, vehz, z_rot, tulajdonos, szin1, szin2);
			mysql_tquery(kapcs, query);
			SendClientMessage(playerid, GREEN, "| A kocsi mentve az adatbázisba! |");
		}
	}
	return 1;
}

CMD:tp(playerid, params[])
{
	new Float:xPos, Float:yPos, Float:zPos;
	if(sscanf(params, "fff", xPos, yPos, zPos)) return SendClientMessage(playerid, LIGHTBLUE, "Használata: /tp [x] [y] [z]");
	{
		SetPlayerPos(playerid, xPos, yPos, zPos);
	}
	return 1;
}

CMD:penzad(playerid, params[])
{
    new pID, money;
    new mstring[128];
    if(sscanf(params,"ii",pID,money)) return SendClientMessage(playerid,RED,"Használat: /penzad [playerid][pénz]");
    if(IsPlayerConnected(pID))
	{
		PlayerInfo[playerid][penz] += money;
		GivePlayerMoney(playerid, money);
		format(mstring,sizeof(mstring),"%s admintól kaptál %d Ft-ot",PlayerInfo[playerid][nev],money);
		SendClientMessage(pID,GREEN,mstring);
	}
	else SendClientMessage(playerid, RED, "Nincs ilyen játékos!");
	return 1;
}

Dilaog_Fegyver(playerid, response, listitem){
	if(response)
	{
	    switch(listitem)
		{
	        case 0:
			{
			    if(GetPlayerMoney(playerid) >= 50000)
			    {
					GivePlayerWeapon(playerid, WEAPON_AK47, 200);
					GivePlayerMoney(playerid, -50000);
				}
				else SendClientMessage(playerid, RED, "Nincs rá elég pénzed!");
			}
            case 1:
			{
			    if(GetPlayerMoney(playerid) >= 50000)
			    {
					GivePlayerWeapon(playerid, WEAPON_M4, 200);
					GivePlayerMoney(playerid, -50000);
				}
				else SendClientMessage(playerid, RED, "Nincs rá elég pénzed!");
			}
            case 2:
			{
			    if(GetPlayerMoney(playerid) >= 35000)
			    {
					GivePlayerWeapon(playerid, WEAPON_SNIPER, 28);
					GivePlayerMoney(playerid, -35000);
				}
				else SendClientMessage(playerid, RED, "Nincs rá elég pénzed!");
			}
            case 3:
			{
			    new Float:armour;
				GetPlayerArmour(playerid, armour);
				if(armour != 100.0)
				{
				    if(GetPlayerMoney(playerid) >= 5000)
				    {
						SetPlayerArmour(playerid, 100.0);
						GivePlayerMoney(playerid, -5000);
					}
					else SendClientMessage(playerid, RED, "Nincs rá elég pénzed!");
				}
				else SendClientMessage(playerid, RED, "Már van armour-od!");
			}
	    }
	}
	return 1;
}

CMD:vasarol(playerid, params[])
{
	if(IsPlayerInRangeOfPoint(playerid, 7.0, 295.9707, -37.6697, 1001.5156))
	{
	    ShowPlayerDialog(playerid, DialogFegyverbolt, DIALOG_STYLE_LIST, "Fegyverek", "AK47\t50000$\nM4\t50000$\nSniper Rifle\t35000$\nArmour\t5000$", "Ok", "Cancel");
	}
	else
	{
	    SendClientMessage(playerid, RED, "Nem vagy semmilyen boltban!");
	}
	return 1;
}

CMD:mentohiv(playerid, params[])
{
	MentoRiasztasDb++;
	new riasztas[128];
	GetPlayerPos(playerid, MentoRiasztas[MentoRiasztasDb][x], MentoRiasztas[MentoRiasztasDb][y], MentoRiasztas[MentoRiasztasDb][z]);
	MentoRiasztas[MentoRiasztasDb][hivo] = playerid;
	MentoRiasztas[MentoRiasztasDb][szabad] = 1;
	SendClientMessage(playerid, GREEN, "A mentõket értesítettük!");
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(PlayerInfo[i][munka] == 3)
	    {
	        SendClientMessage(i, LIGHTBLUE, "----------------------------------------------");
	        SendClientMessage(i, LIGHTBLUE, "Valakinek mentõre van szüksége!");
	        SendClientMessage(i, LIGHTBLUE, "/mentofogad [riasztas szama]");
	        format(riasztas, sizeof(riasztas), "A riasztás száma: %d", MentoRiasztasDb);
	        SendClientMessage(i, LIGHTBLUE, riasztas);
	        SendClientMessage(i, LIGHTBLUE, "----------------------------------------------");
	    }
	}
	return 1;
}

CMD:mentofogad(playerid, params[])
{
	if(PlayerInfo[playerid][munka] == 3)
	{
	    new szam;
		if(sscanf(params,"i",szam)) return SendClientMessage(playerid,RED,"Használat: /mentofogad [riasztás száma]");
		{
		    if(szam <= MentoRiasztasDb)
		    {
		        if(MentoRiasztas[szam][szabad] == 1)
		        {
		            SetPlayerCheckpoint(playerid, MentoRiasztas[szam][x], MentoRiasztas[szam][y], MentoRiasztas[szam][z], 3.0);
		            SetPVarInt(playerid, "mentoCh", 1);
		            SendClientMessage(MentoRiasztas[szam][hivo], GREEN, "Egy mentõ fogadta a hívást és úton van a hívás helyszínére!");
		            SendClientMessage(playerid, GREEN, "A hívás helyszíne jelölve a térképen!");
		            MentoRiasztas[szam][szabad] = 0;
				}
				else SendClientMessage(playerid, RED, "A riasztást már fogadta valaki");
	        }
	        else SendClientMessage(playerid, RED, "A riasztás nem létezik!");
		}
	}
	else
	{
	    SendClientMessage(playerid, RED, "Nem vagy mentõs, ezért nem használhatod ezt a parancsot!");
	}
	return 1;
}

CMD:gyogyit(playerid, params[])
{
	if(PlayerInfo[playerid][munka] == 3)
	{
	    new szam;
		if(sscanf(params,"i",szam)) return SendClientMessage(playerid,RED,"Használat: /gyogyit [playerid]");
		{
		    new Float:gX, Float:gY, Float:gZ;
		    GetPlayerPos(szam, gX, gY, gZ);
		    if(IsPlayerInRangeOfPoint(playerid, 3.0, gX, gY, gZ))
		    {
		        new Float:gHealth;
				GetPlayerHealth(szam, gHealth);
			    if(gHealth != 100.0)
				{
					SetPlayerHealth(szam, 100.0);
					if(szam != playerid)
					{
						GivePlayerMoney(playerid, 5000);
						PlayerInfo[playerid][penz]+=5000;
					}
					PlayerInfo[playerid][score]++;
					SetPlayerScore(playerid, GetPlayerScore(playerid) + 1);
					SendClientMessage(szam, GREEN, "Meggyógyított egy mentõs!");
					SendClientMessage(playerid, GREEN, "Sikeresen meggyógyítottad a játékost!");
				}
				else SendClientMessage(playerid, RED, "A játékosnak nincs szüksége ellátásra!");
			}
			else SendClientMessage(playerid, RED, "Nem vagy a megadott játékos közelében!");
		}
	}
	else
	{
	    SendClientMessage(playerid, RED, "Nem vagy mentõs, ezért nem használhatod ezt a parancsot!");
	}
	return 1;
}

CMD:nyit(playerid,params[])
{
	if(IsPlayerInRangeOfPoint(playerid,8.0,1998.6,-1439.4,13.6))
	{
	    if(PlayerInfo[playerid][munka] == 3)
	    {
			MoveObject(Sorompok[0],1998.6,-1439.4,13.6,1.0+0.0001,0,12.0000000,0);
			SetTimerEx("Kapuzar", 6000, false, "i", Sorompok[0]);
			SendClientMessage(playerid,YELLOW,"Kinyitva. (autómata kapu)");
		} else return SendClientMessage(playerid, RED, "Nem vagy mentõs, nem nyithatod ki ezt a kaput!");
	}
	else if(IsPlayerInRangeOfPoint(playerid,8.0,2008.6,-1449.4,13.6))
	{
	    if(PlayerInfo[playerid][munka] == 3)
	    {
			MoveObject(Sorompok[1],2008.6,-1449.4,13.6,11.0+0.0001,0,12.0,91);
			SetTimerEx("Kapuzar", 6000, false, "i", Sorompok[1]);
			SendClientMessage(playerid,YELLOW,"Kinyitva. (autómata kapu)");
		}else return SendClientMessage(playerid, RED, "Nem vagy mentõs, nem nyithatod ki ezt a kaput!");
	}
	else if(IsPlayerInRangeOfPoint(playerid,8.0,1150,-1384.8,13.7))
	{
	    if(PlayerInfo[playerid][munka] == 3)
	    {
			MoveObject(Sorompok[2],1150,-1384.8,13.7,11.0+0.0001,0,-12.0,0);
			SetTimerEx("Kapuzar", 6000, false, "i", Sorompok[2]);
			SendClientMessage(playerid,YELLOW,"Kinyitva. (autómata kapu)");
		}else return SendClientMessage(playerid, RED, "Nem vagy mentõs, nem nyithatod ki ezt a kaput!");
	}
	else if(IsPlayerInRangeOfPoint(playerid,8.0,1149.8,-1292.8,13.6))
	{
	    if(PlayerInfo[playerid][munka] == 3)
	    {
			MoveObject(Sorompok[3],1149.8,-1292.8,13.6,11.0+0.0001,0,-12.0,0);
			SetTimerEx("Kapuzar", 6000, false, "i", Sorompok[3]);
			SendClientMessage(playerid,YELLOW,"Kinyitva. (autómata kapu)");
		}else return SendClientMessage(playerid, RED, "Nem vagy mentõs, nem nyithatod ki ezt a kaput!");
	}
	else if(IsPlayerInRangeOfPoint(playerid,8.0,1544.7,-1630.8,13.3)) // rendõrség
	{
	    if(PlayerInfo[playerid][munka] == 2)
	    {
			MoveObject(Sorompok[4],1544.7,-1630.8,13.3,11.0+0.0001,0,-12.0,270);
			SetTimerEx("Kapuzar", 6000, false, "i", Sorompok[4]);
			SendClientMessage(playerid,YELLOW,"Kinyitva. (autómata kapu)");
		}else return SendClientMessage(playerid, RED, "Nem vagy rendõr, nem nyithatod ki ezt a kaput!");
	}else
	SendClientMessage(playerid,RED,"Nem állsz a kapunál!");
	return 1;
}

forward Kapuzar(sorompocska);
public Kapuzar(sorompocska)
{
	if(sorompocska == Sorompok[0])
		MoveObject(Sorompok[0],1998.6,-1439.4,13.6,1.0+0.0001,0,91.25,359.25);
	if(sorompocska == Sorompok[1])
	    MoveObject(Sorompok[1],2008.6,-1449.4,13.6,1.0+0.0001,0,91,91);
    if(sorompocska == Sorompok[2])
	    MoveObject(Sorompok[2],1150,-1384.8,13.7,1.0+0.0001,0,268.75,0);
    if(sorompocska == Sorompok[3])
	    MoveObject(Sorompok[3],1149.8,-1292.8,13.6,1.0+0.0001,0,268.748,0);
    if(sorompocska == Sorompok[4])
	    MoveObject(Sorompok[4],1544.7,-1630.8,13.3,1.0+0.0001,0,269.25,270);
}

CMD:cuff(playerid, params[])
{
	if(PlayerInfo[playerid][munka] == 2)
	{
		new player;
		if(sscanf(params,"i",player)) return SendClientMessage(playerid,RED,"Használat: /cuff [playerid]");
		{
			if(playerid != player)
			{
				new wanted = GetPlayerWantedLevel(player);
				if(wanted > 0)
				{
					new Float:xPos, Float:yPos, Float:zPos;
					GetPlayerPos(player, xPos, yPos, zPos);
					if(IsPlayerInRangeOfPoint(playerid, 6.0, xPos, yPos, zPos))
					{
						if(IsPlayerCuffed(player) == false)
						{
							SetPlayerCuffed(player, true);
							TogglePlayerControllable(player, 0);
							SendClientMessage(player, GREEN, "Egy rendõr megbilincselt!");
							new str[128];
							format(str, sizeof(str), "Sikeresen megbilincselted %s játékost!", PlayerInfo[player][nev]);
							SendClientMessage(playerid, GREEN, str);
						}
						else
						{
							SetPlayerCuffed(player, false);
							TogglePlayerControllable(player, 1);
							SendClientMessage(player, GREEN, "Egy rendõr levette a bilincset!");
							new str[128];
							format(str, sizeof(str), "Sikeresen levetted a bilincset %s játékosról!", PlayerInfo[player][nev]);
							SendClientMessage(playerid, GREEN, str);
						}
					} else return SendClientMessage(playerid, RED, "Nem vagy a játékos közelében!");
				} else return SendClientMessage(playerid, RED, "A játékos nincs körözés alatt!");
			}
		}
	}else return SendClientMessage(playerid, RED, "Nem vagy rendõr!");
	return 1;
}

CMD:arr(playerid, params[])
{
	new player;
	if(sscanf(params,"i",player)) return SendClientMessage(playerid,RED,"Használat: /arr [playerid]");
	{
	    new Float:xPos, Float:yPos, Float:zPos;
		GetPlayerPos(player, xPos, yPos, zPos);
		if(IsPlayerInRangeOfPoint(playerid, 6.0, xPos, yPos, zPos))
		{
		    if(IsPlayerCuffed(player) == true)
		    {
		        new wanted = GetPlayerWantedLevel(player);

		        SetPlayerPos(player, 264.8605,77.3966,1001.0391);
		        SetPlayerInterior(player, 6);

		        SetPlayerCuffed(player, false);
		        TogglePlayerControllable(player, 1);
		        SetTimerEx("borton", wanted*60000, false, "%i", player);
		        new str[128];
	            format(str, sizeof(str), "Egy rendõr bezárt a börtönbe %i percre!", wanted);
		        SendClientMessage(player, ORANGE, str);
		        SetPlayerWantedLevel(player, 0);
		        format(str, sizeof(str), "Sikeresen bezártad %s a börtönbe!", PlayerInfo[player][nev]);
		        SendClientMessage(playerid, GREEN, str);
		        format(str, sizeof(str), "%s bezárva a börtönbe %i percre.", PlayerInfo[player][nev], wanted);
		        SendClientMessageToAll(GREY, str);
		        PlayerInfo[playerid][score]++;
		        SetPlayerScore(playerid, PlayerInfo[playerid][score]);
		        GivePlayerMoney(playerid, 63*wanted*90);
		        PlayerInfo[playerid][penz] += 63*wanted*90;
		    } else return SendClientMessage(playerid, RED, "Elõbb meg kell bilincselned!");
		} else return SendClientMessage(playerid, RED, "Nem vagy a játékos közelében!");
	}
	return 1;
}

forward borton(player);
public borton(player)
{
	SendClientMessage(player, GREEN, "Kiszabadultál!");
	SetPlayerPos(player, 264.0479,81.9556,1001.0391);
	SetPlayerInterior(player, 6);
	return 1;
}

CMD:pwl(playerid,params[])
{
	new pID;
	new plvl;
	if(sscanf(params,"ii",pID,plvl)) return SendClientMessage(playerid,RED,"Használat: /pwl [playerid][wanted level]");
    if(IsPlayerConnected(pID))
	{
		SetPlayerWantedLevel(pID, plvl);
	}
	else SendClientMessage(playerid, RED, "Nincs ilyen játékos!");
	return 1;
}

CMD:atm(playerid, params[])
{
	for(new i = 0; i < AtmCount; i++)
	{
	    if(IsPlayerInRangeOfPoint(playerid, 1.0, AtmInfo[i][xCor],AtmInfo[i][yCor],AtmInfo[i][zCor]))
	    {
	        SendClientMessage(playerid, GREEN, "ATM elõtt vagy");
	    }
	}
	return 1;
}

CMD:robatm(playerid, params[])
{
	if(PlayerInfo[playerid][munka] == 1)
	{
	    for(new i = 0; i < AtmCount; i++)
		{
		    if(IsPlayerInRangeOfPoint(playerid, 1.0, AtmInfo[i][xCor],AtmInfo[i][yCor],AtmInfo[i][zCor]))
		    {
		        if(AtmInfo[i][rabolhato] == 1)
		        {
			        AtmInfo[i][rabolhato] = 0;
			        PlayerInfo[playerid][penz] += 50000;
					GivePlayerMoney(playerid, 50000);
					SetTimerEx("robatmtimer", 600000, false, "%i", i);
					SendClientMessage(playerid, GREEN, "Sikeresen kiraboltad az atm-et!");
					SetPlayerWantedLevel(playerid, GetPlayerWantedLevel(playerid)+3);
					SetPlayerColor(playerid, ORANGE);
					for(new j = 0; j < MAX_PLAYERS; j++)
					{
					    if(PlayerInfo[j][munka] == 2)
					    {
					        SendClientMessage(j, LIGHTBLUE, "Kiraboltak egy ATM-et!");
					    }
					}
				}else return SendClientMessage(playerid, RED, "Az ATM-et nem rég kirabolták, várnod kell míg újra rabolható.");
			}
		}
	} else return SendClientMessage(playerid, GREEN, "Csak bandatag rabolhat!");
	return 1;
}

forward robatmtimer(atm);
public robatmtimer(atm)
{
	AtmInfo[atm][rabolhato] = 1;
	return 1;
}

forward GetPlayersOnServer();
public GetPlayersOnServer() {
	new count;
	for(new i = 0; i < MAX_PLAYERS; i++) {
	  if(IsPlayerConnected(i)) {
			count++;
		}
	}
	return count;
}

CMD:rob(playerid, params[])
{
    new bool:talalt = false;
    new str[128];
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		new Float:xPos, Float:yPos, Float:zPos;
	    if(i != playerid)
	    {
			GetPlayerPos(i, xPos, yPos, zPos);
		    if(IsPlayerInRangeOfPoint(playerid, 1.5, xPos, yPos, zPos))
		    {
		        new rand = random(10);
		        //new Float:szazalek = ((rand+40)/100);
				new pMoney = GetPlayerMoney(i);
				printf("%d, kapott penz: %d, %d", rand, floatround(pMoney*((rand+40)/100)), pMoney);
				GivePlayerMoney(i, -floatround(pMoney*((rand+40)/100)));
				GivePlayerMoney(playerid, floatround(pMoney*((rand+40)/100)));
		        format(str, sizeof(str), "Kiraboltad %s! Rabolt pénz: %d)", PlayerInfo[i][nev], floatround(pMoney*((rand+40)/100)));
		        SendClientMessage(playerid, GREEN, str);
		        format(str, sizeof(str), "Kiraboltak! Rabolt pénz: %d)", floatround(pMoney*((rand+40)/100)));
		        SendClientMessage(i, ORANGE, str);
                SetPlayerWantedLevel(playerid, GetPlayerWantedLevel(playerid)+1);
		        talalt = true;
		        for(new j = 0; j < MAX_PLAYERS; j++)
				{
				    if(PlayerInfo[j][munka] == 2)
				    {
				        SendClientMessage(j, LIGHTBLUE, "Kiraboltak egy játékost!");
				    }
				}
		    }
	    }
	}
	if(talalt == false)
	{
	    SendClientMessage(playerid, RED, "Nem állsz játékos közelében!");
	}
	return 1;
}

