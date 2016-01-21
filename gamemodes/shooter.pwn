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
#define A_COLOR 0xD279D2FF

//---------------------EGY�B DEFINEOK-------------------------------------------
#define TAKEOVER_TIME 15 // mennyi ido kell az elfoglal�shoz
#define MIN_DEATHS_TO_START_WAR 1 // minimum ennyi embert kell kiny�rni hogy beinduljon a csata
#define MAX_ZONE 100
#define MAX_SHOPS 50

//------------------------CSAPAT DEFINI�L�S-------------------------------------
#define TEAM_NOT 0
#define TEAM_HUN 1
#define TEAM_GRE 2
#define TEAM_ITA 3
#define TEAM_RUS 4
#define TEAM_KIN 5
#define TEAM_KAM 6
#define TEAM_AUS 7

#define SKIN_HUN 72
#define SKIN_GRE 48
#define SKIN_ITA 46
#define SKIN_RUS 112
#define SKIN_KIN 117
#define SKIN_KAM 142
#define SKIN_AUS 37

new Skins[7] = {SKIN_HUN, SKIN_GRE, SKIN_ITA, SKIN_RUS, SKIN_KIN, SKIN_KAM, TEAM_AUS};

//--------------------FORWARDOK-------------------------------------------------
forward RegEllenorzes(playerid);
forward ZoneTimer();
forward ZoneLoad();
forward GetPlayersOnServer();
forward HackTimer();

#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print("ZoneWars 0.1");
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
	DIALOG_BAN,
	DIALOG_SHOP,
	d_rangok,
	DIALOG_CMDS
}

enum JatekosInfo {
	Nev[25],
	Penz,
	Pont,
	Skin,
	alevel,
	teamcolor,
	warndb,
	helmet
}
new jInfo[MAX_PLAYERS][JatekosInfo];

enum eZone
{
	zId,
	Float:zMinX,
	Float:zMinY,
	Float:zMaxX,
	Float:zMaxY,
	zTeam,
	foglalhato,
	felirat[51],
	Float:fx,
	Float:fy,
	Float:fz,
	fId
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

enum Car{
	ID,
	db_id,
	rszam[8],
	modelid,
	Float:xPos,
	Float:yPos,
	Float:zPos,
	Float:angle,
	tulaj,
	col1,
	col2
}
new CarInfo[MAX_VEHICLES][Car];

enum shop{
	id,
	Float:xPos,
	Float:yPos,
	Float:zPos,
	pickupId,
	mapiconid
}
new Shops[MAX_SHOPS][shop];

enum dobject{
	modelid,
	Float:fX,
	Float:fY,
	Float:fZ,
	Float:fR
}
new DeleteObj[500][dobject];

/*new Teams[] = {
	TEAM_GROVE,
	TEAM_BALLAS,
	TEAM_VAGOS
};*/



//---------------------GLOB�LIS V�LTOZ�K----------------------------------------
new kapcs, query[2000];
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
new foglal[MAX_PLAYERS];
new foglalja[MAX_ZONE];
new ShopsDb=0;
new inShop[MAX_PLAYERS];
new playerSK[MAX_PLAYERS];
new Train;
new TrainUzenet = 0;
new cargoType[] = {1212,346,1279}; // p�nz, fegyver, egy�b
new cargoes[3];
new cargoesType[3];
new inCargo[MAX_PLAYERS];
new hadkp;

main()
{
	print("\n----------------------------------");
	print("ZoneWars 0.1");
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
    AddPlayerClass(SKIN_HUN,1137.1510,-2037.0577,69.0078,270.9954,24,1500,27,1500,16,2); //magyar
    AddPlayerClass(SKIN_GRE,2336.3398,38.8450,26.4813,268.4628,24,1500,27,1500,16,2); // g�r�g
    AddPlayerClass(SKIN_ITA,218.0903,-87.0485,1.5696,313.5960,24,1500,27,1500,16,2); //olasz
    AddPlayerClass(SKIN_RUS,912.1116,-1231.0538,16.9766,8.6328,24,1500,27,1500,16,2); // orosz
    AddPlayerClass(SKIN_KIN,2675.8403,-2453.0208,13.6379,272.1722,24,1500,27,1500,16,2); // k�naiak
    AddPlayerClass(SKIN_KAM,537.7534,-1877.5918,3.8040,341.5533,24,1500,27,1500,16,2); // kameruniak
    AddPlayerClass(SKIN_AUS,-2163.3647,-2387.4873,30.6250,149.0301,24,1500,27,1500,16,2); // Austria
    /*AddPlayerClass(109,2215.1963,-1164.0492,25.7266,270.5322,24,1500,27,1500,16,2); // Jefferson Vagos spawn
    AddPlayerClass(110,2215.1963,-1164.0492,25.7266,270.5322,24,1500,27,1500,16,2); // Jefferson Vagos spawn*/

    mysql_log(LOG_ALL, LOG_TYPE_HTML);
	kapcs = mysql_connect("localhost", "root", "zone", "");
	if(mysql_errno(kapcs) != 0) printf("MySQL hiba! Hibak�d: %d", mysql_errno(kapcs));

	mysql_tquery(kapcs, "SELECT * FROM zones", "ZoneLoad");
	mysql_tquery(kapcs, "SELECT * FROM cars","AutoLoad");
	mysql_tquery(kapcs, "SELECT * FROM objects","ObjectLoad");
	mysql_tquery(kapcs, "SELECT * FROM shops","ShopLoad");

    ConnectNPC("[BOT]Train","train_ls");
	cargoes[0] = 100;
	cargoes[1] = 100;
	cargoes[2] = 100;
	SetTimer("ZoneTimer", 1000, true);
	SetTimer("HackTimer", 60000, true);
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
        case 6: {
                gTeam[playerid] = TEAM_AUS;
                GameTextForPlayer(playerid,"~w~Osztr�kok",3000,6);
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
                SetPlayerColor(playerid, 0x80400088);
                SetPlayerTeam(playerid, TEAM_KAM);
                jInfo[playerid][teamcolor] = TEAM_KAM;
        }
        else if (gTeam[playerid] == TEAM_AUS)
        {
                SetPlayerColor(playerid, 0xFF000088);
                SetPlayerTeam(playerid, TEAM_AUS);
                jInfo[playerid][teamcolor] = TEAM_AUS;
        }
}

public OnPlayerConnect(playerid)
{
    if(IsPlayerNPC(playerid)) //Checks if the player that just spawned is an NPC.
    {
		return 1;
	}
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
	    mysql_tquery(kapcs, "SELECT * FROM dobjects","DeleteObjects", "d", playerid);
    }
    else {
        ShowPlayerDialog(playerid, DIALOG_BAN, DIALOG_STYLE_MSGBOX, "Ban", "Bannolva vagy a szerverr�l!", "Close", "");
    }
	return 1;
}

public ZoneLoad()
{
	//printf("ZoneLoad-ban vagyunk, %d", cache_get_row_count());
    if(!cache_get_row_count()) return printf("Nincs egy z�na sem az adatb�zisban!");
	 	for(new i = 0; i < cache_get_row_count(); i++)
		{
		    new text[51];
			ZoneInfo[i][zId] = cache_get_field_content_int(i,"id",kapcs);
		    ZoneInfo[i][zMinX] = cache_get_field_content_float(i,"minX",kapcs);
		    ZoneInfo[i][zMinY] = cache_get_field_content_float(i,"minY",kapcs);
		    ZoneInfo[i][zMaxX] = cache_get_field_content_float(i,"maxX",kapcs);
			ZoneInfo[i][zMaxY] = cache_get_field_content_float(i,"maxY",kapcs);
			ZoneInfo[i][zTeam] = cache_get_field_content_int(i,"team",kapcs);
			ZoneInfo[i][foglalhato] = cache_get_field_content_int(i,"foglalhato",kapcs);
			cache_get_field_content(i, "felirat", text);
			ZoneInfo[i][felirat] = text;
			ZoneInfo[i][fx] = cache_get_field_content_float(i,"fX",kapcs);
			ZoneInfo[i][fy] = cache_get_field_content_float(i,"fY",kapcs);
			ZoneInfo[i][fz] = cache_get_field_content_float(i,"fZ",kapcs);

			zoneDb++;
			//printf("%d, %f, %f, %f, %f, %d, %s", ZoneInfo[i][zId], ZoneInfo[i][zMinX], ZoneInfo[i][zMinY], ZoneInfo[i][zMaxX], ZoneInfo[i][zMaxY], ZoneInfo[i][zTeam], ZoneInfo[i][felirat]);
			ZoneID[i] = GangZoneCreate(ZoneInfo[i][zMinX], ZoneInfo[i][zMinY], ZoneInfo[i][zMaxX], ZoneInfo[i][zMaxY]);
			if(ZoneInfo[i][fx] != 0 && ZoneInfo[i][fy] != 0 && ZoneInfo[i][fz] != 0){
				Create3DTextLabel(ZoneInfo[i][felirat], 0x008080FF, ZoneInfo[i][fx], ZoneInfo[i][fy], ZoneInfo[i][fz], 40.0, 0, 1);
			}
			if(!strcmp("Had�szati k�zpont",ZoneInfo[i][felirat]))
			{
			    hadkp = i;
			    //printf("%d", hadkp);
			}
			foglalja[ZoneID[i]] = -1;
		}
    print("\n-----------mySQL------------------");
	//printf("%d z�na, ", zoneDb);
	/*for(new i=0; i < zoneDb; i++)
	{
		ZoneID[i] = GangZoneCreate(ZoneInfo[i][zMinX], ZoneInfo[i][zMinY], ZoneInfo[i][zMaxX], ZoneInfo[i][zMaxY]);
	}*/
	return 1;
}

forward ObjectLoad();
public ObjectLoad()
{
	if(!cache_get_row_count()) return printf("Nincs egy objektum sem az adatb�zisban!");
	 	for(new i = 0; i < cache_get_row_count(); i++)
		{
			Objektumok[i][id] = ObjektCount;
			Objektumok[i][modelID] = cache_get_field_content_int(i,"modelID",kapcs);
		    Objektumok[i][xCor] = cache_get_field_content_float(i,"x",kapcs);
		    Objektumok[i][yCor] = cache_get_field_content_float(i,"y",kapcs);
		    Objektumok[i][zCor] = cache_get_field_content_float(i,"z",kapcs);
		    Objektumok[i][rxCor] = cache_get_field_content_float(i,"rx",kapcs);
		    Objektumok[i][ryCor] = cache_get_field_content_float(i,"ry",kapcs);
		    Objektumok[i][rzCor] = cache_get_field_content_float(i,"rz",kapcs);

			CreateObject(Objektumok[i][modelID], Objektumok[i][xCor], Objektumok[i][yCor], Objektumok[i][zCor], Objektumok[i][rxCor], Objektumok[i][ryCor], Objektumok[i][rzCor]);
	        ObjektCount++;
	        //printf("%d, %f, %f, %f, %f, %f, %f",Objektumok[i][modelID], Objektumok[i][xCor], Objektumok[i][yCor], Objektumok[i][zCor], Objektumok[i][rxCor], Objektumok[i][ryCor], Objektumok[i][rzCor]);
		}
		//printf("%d object bet�ltve!", ObjektCount);
	return 1;
}

forward AutoLoad();
public AutoLoad()
{
	if(!cache_get_row_count()) return printf("Nincs egy aut� sem az adatb�zisban!");
 	for(new i = 0; i < cache_get_row_count(); i++)
	{
	    new rendszam[8];
		cache_get_field_content(i, "rendszam", rendszam);
		CarInfo[i][rszam] = rendszam;
		CarInfo[i][modelid] = cache_get_field_content_int(i,"modelid",kapcs);
		CarInfo[i][tulaj] = cache_get_field_content_int(i,"tulaj",kapcs);
		CarInfo[i][xPos] = cache_get_field_content_float(i,"x",kapcs);
		CarInfo[i][yPos] = cache_get_field_content_float(i,"y",kapcs);
		CarInfo[i][zPos] = cache_get_field_content_float(i,"z",kapcs);
		CarInfo[i][angle] = cache_get_field_content_float(i,"angle",kapcs);
		CarInfo[i][col1] = cache_get_field_content_int(i,"col1",kapcs);
		CarInfo[i][col2] = cache_get_field_content_int(i,"col2",kapcs);
		/*if(CarInfo[i][tulaj] == 0)
		{*/
			CarInfo[i][ID] = AddStaticVehicleEx(CarInfo[i][modelid],CarInfo[i][xPos],CarInfo[i][yPos],CarInfo[i][zPos],CarInfo[i][angle],CarInfo[i][col1],CarInfo[i][col2],300,0);
		/*}
		else
		{
		    CarInfo[i][ID] = AddStaticVehicleEx(CarInfo[i][modelid],CarInfo[i][x],CarInfo[i][y],CarInfo[i][z],CarInfo[i][angle],CarInfo[i][col1],CarInfo[i][col2],-1,0);
		}*/
		if(CarInfo[i][modelid]==537){
		    Train = CarInfo[i][ID];
		}
		
		SetVehicleNumberPlate(CarInfo[i][ID], CarInfo[i][rszam]);
		AutoCount++;
		//printf("ID: %d, AutoCount: %d",CarInfo[i][ID], AutoCount);
		//printf("autok: %f, %f, %f",CarInfo[i][x],CarInfo[i][y],CarInfo[i][z]);
	}
    //printf("%d aut� �s ", AutoCount);
		//SetTimer("AutoSave", 1000, true);
	return 1;
}

forward ShopLoad();
public ShopLoad()
{
	if(!cache_get_row_count()) return printf("Nincs egy bolt sem az adatb�zisban!");
	 	for(new i = 0; i < cache_get_row_count(); i++)
		{
		    //Shops[i][id] = cache_get_field_content_int(i,"id",kapcs);
		    Shops[i][xPos] = cache_get_field_content_float(i,"x",kapcs);
		    Shops[i][yPos] = cache_get_field_content_float(i,"y",kapcs);
		    Shops[i][zPos] = cache_get_field_content_float(i,"z",kapcs);
		    Shops[i][pickupId] = cache_get_field_content_int(i,"pickupid",kapcs);
		    Shops[i][mapiconid] = cache_get_field_content_int(i,"mapiconid",kapcs);
		    
		    Shops[i][id] = CreatePickup(Shops[i][pickupId], 1, Shops[i][xPos], Shops[i][yPos], Shops[i][zPos], -1);
			
	        ShopsDb++;
		}
		printf("%d z�na, %d object, %d aut� �s %d bolt bet�ltve!", zoneDb, ObjektCount, AutoCount, ShopsDb);
		print("----------------------------------\n");
	return 1;
}

forward DeleteObjects(playerid);
public DeleteObjects(playerid){
    if(!cache_get_row_count()) return printf("Nincs t�r�lend� object!");
	 	for(new i = 0; i < cache_get_row_count(); i++)
		{
		    DeleteObj[i][modelid] = cache_get_field_content_int(i,"modelid",kapcs);
		    DeleteObj[i][fX] = cache_get_field_content_int(i,"x",kapcs);
		    DeleteObj[i][fY] = cache_get_field_content_int(i,"y",kapcs);
		    DeleteObj[i][fZ] = cache_get_field_content_int(i,"z",kapcs);
		    DeleteObj[i][fR] = cache_get_field_content_int(i,"r",kapcs);
		    
		    RemoveBuildingForPlayer(playerid, DeleteObj[i][modelid], DeleteObj[i][fX], DeleteObj[i][fY], DeleteObj[i][fZ], DeleteObj[i][fR]);
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
	AdminSzolgalat[playerid] = false;
	return 1;
}

public OnPlayerSpawn(playerid)
{
    if(IsPlayerNPC(playerid)) //Checks if the player that just spawned is an NPC.
    {
        new npcname[MAX_PLAYER_NAME];
        GetPlayerName(playerid, npcname, sizeof(npcname)); //Getting the NPC's name.
        if(!strcmp(npcname, "[BOT]Train", true)) //Checking if the NPC's name is MyFirstNPC
        {
            SetPlayerMarkerForPlayer(playerid, 1, 00); // A 00 elt�nteti a mapmarkerj�t a vonatnak.
            PutPlayerInVehicle(playerid, Train, 0); //Putting the NPC into the vehicle we created for it.
        }
        return 1;
    }

    PlayerPlaySound( playerid, 1188, 0.0, 0.0, 0.0 );
    SetPlayerToTeamColor(playerid);
	//Itt mutatjuk a gangzonokat a j�t�kosoknak valamint villog�st is itt lehet be�ll�tani
	for(new i=0; i < zoneDb; i++)
	{
		GangZoneShowForPlayer(playerid, ZoneID[i], GetTeamZoneColor(ZoneInfo[i][zTeam]));
		if(ZoneAttacker[i] != -1) GangZoneFlashForPlayer(playerid, ZoneID[i], GetTeamZoneColor(ZoneAttacker[i]));
	}
	if(AdminSzolgalat[playerid] == true)
	{
	    SetPlayerSkin(playerid, 217);
	}
	SetPlayerHealth(playerid, 9999);
	playerSK[playerid] = 1;
	if(GetPlayerTeam(playerid) == ZoneInfo[hadkp][zTeam]){
	    jInfo[playerid][helmet] = 1;
	    SetPlayerAttachedObject(playerid, 1, 19106, 2, 0.15, -0, 0, 180, 180, 180);
	    new str[128];
	    format(str, sizeof(str), "A csapatod b�rtokolja a %s b�zist, ez�rt kapt�l goly��ll�mell�nyt �s sisakot!", ZoneInfo[hadkp][felirat]);
	    SendClientMessage(playerid, vzold, str);
	}else{
		jInfo[playerid][helmet] = 0;
		RemovePlayerAttachedObject(playerid, 2);
	}
    SendClientMessage(playerid, -1, "| 15 m�sodpercig v�dve vagy a t�mad�sokt�l. |");
    SetTimerEx("EndAntiSpawnKill", 15000, false, "i", playerid);
	RankChechk(playerid);
	return 1;
}

forward EndAntiSpawnKill(playerid);
public EndAntiSpawnKill(playerid)
{
	playerSK[playerid] = 0;
    SetPlayerHealth(playerid, 100);
    SendClientMessage(playerid, -1, "| Lej�rt a v�delmed. |");
 	if(GetPlayerTeam(playerid) == ZoneInfo[hadkp][zTeam]){
		SetPlayerArmour(playerid, 100.0);
	}
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(killerid != INVALID_PLAYER_ID){
	    getPont(killerid, 1);
	    new str[128];
		new money = random(600)+400;
	    format(str,sizeof(str),"Meg�lted %s j�t�kost. Jutalmad: %d$ �s 1 pont",jInfo[playerid][Nev], money);
	    SendClientMessage(killerid, zold, str);
	    jInfo[killerid][Penz]+=money;
	    GivePlayerMoney(killerid, money);
	    format(str,sizeof(str),"%s j�t�kos meg�lt. Vesztes�ged: %d$",jInfo[killerid][Nev], money);
	    SendClientMessage(playerid, orange, str);
	    jInfo[playerid][Penz]-=money;
	    GivePlayerMoney(playerid, -money);
	    SendDeathMessage(killerid, playerid, reason);
	    RemovePlayerAttachedObject(playerid, 2);
	    jInfo[playerid][helmet] = 0;
	}
	if(IsPlayerConnected(killerid) && GetPlayerTeam(playerid) != GetPlayerTeam(killerid) && ZoneInfo[GetPlayerZone(playerid)][foglalhato] == 1) // not a suicide or team kill
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
	for(new i=0;i<ShopsDb;i++){
	    if(pickupid==Shops[i][id] && inShop[playerid] == 0){
			inShop[playerid] = 1;
			ShowPlayerDialog(playerid, DIALOG_SHOP, DIALOG_STYLE_LIST, "Bolt", "�let\nP�nc�l\nSisak", "Megvesz", "M�gse");
	    }
	}
	for(new i = 0; i < 3; i++){
		    if(pickupid == cargoes[i]){
		        if(ZoneInfo[GetPlayerZone(playerid)][zTeam] == GetPlayerTeam(playerid)){
			        if(cargoesType[i] == cargoType[0]) {//p�nz
			            new money = random(15000)+10000;
			            GivePlayerMoney(playerid, money);
						jInfo[playerid][Penz] += money;
						new str[128];
						format(str, sizeof(str), "%d$ volt a csomagban.", money);
						SendClientMessage(playerid, vzold, str);
			        }
			        else if(cargoesType[i] == cargoType[1]) { //fegyver
			            new weaponid = random(18)+16;
			            GivePlayerWeapon(playerid, weaponid, 140);
			            new weaponname[50], str[128];
			            GetWeaponName(weaponid, weaponname, sizeof(weaponname));
			            format(str, sizeof(str), "%s fegyvert kapt�l 140 l�szerrel!", weaponname);
			            SendClientMessage(playerid, vzold, str);
			        }
			        else if (cargoesType[i] == cargoType[2]) { //egy�b
			            SendClientMessage(playerid, vzold, "Egy�b dolgot kapt�l!");
			        }
		         	DestroyPickup(pickupid);
                } else {
				    if(inCargo[playerid] == 0) {
				    	SendClientMessage(playerid, piros, "Nem a Te csapatod� a b�zis, ez�rt nem veheted fel a csomagot!");
				    	inCargo[playerid] = 1;
				    	SetTimerEx("InCargoRes", 5000, false, "i", playerid);
					}
				}
		    }
	}
	return 1;
}

forward InCargoRes(playerid);
public InCargoRes(playerid){
    inCargo[playerid] = 0;
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
		case TEAM_NOT: return 0xFFFFFF88;
		case TEAM_HUN: return 0x00FF0088;
		case TEAM_GRE: return 0xFF00FF88;
		case TEAM_ITA: return 0xFFFF0088;
		case TEAM_RUS: return 0x0000FF88;
		case TEAM_KIN: return 0x01F8FE88;
		case TEAM_KAM: return 0x80400088;
		case TEAM_AUS: return 0xFF000088;
	}
	return -1;
}

public OnPlayerUpdate(playerid)
{
    if(IsPlayerNPC(playerid)) //Checks if the player that just spawned is an NPC.
    {
        if(IsPlayerInRangeOfPoint(playerid, 7.0, 2765.0864, 311.9946, 9.7014)){
            if(TrainUzenet == 0){
				SendClientMessageToAll(vzold, "[ ! ] K�t perc m�lva vonat �rkezik a Vas�t�llom�sra!");
				TrainUzenet = 1;
			}
        }
        if(IsPlayerInRangeOfPoint(playerid, 7.0, 1697.9894,-1953.9486,13.5469)){
            if(TrainUzenet == 1){
				SendClientMessageToAll(vzold, "[ ! ] Vonat �rkezett a Vas�t�llomsra!");
				new randomnumb = random(3);
				cargoes[0] = CreatePickup(cargoType[randomnumb], 1, 1725.1725,-1949.4868,14.1172, -1);
				cargoesType[0] = cargoType[randomnumb];
				randomnumb = random(2);
				cargoes[1] = CreatePickup(cargoType[randomnumb], 1, 1734.1632,-1949.6388,14.1172, -1);
				cargoesType[1] = cargoType[randomnumb];
				randomnumb = random(2);
				cargoes[2] = CreatePickup(cargoType[randomnumb], 1, 1743.7703,-1949.4736,14.1172, -1);
				cargoesType[2] = cargoType[randomnumb];
				SetTimer("CargoDel", 300000, false);
				TrainUzenet = 0;
			}
        }
        return 1;
	}
	if(GetPlayersInZone(GetPlayerZone(playerid), ZoneInfo[GetPlayerZone(playerid)][zTeam]) == 0 && foglal[playerid] == 0 && foglalja[GetPlayerZone(playerid)] == -1 && ZoneInfo[GetPlayerZone(playerid)][foglalhato] == 1 && !IsPlayerInAnyVehicle(playerid)){
	    ZoneDeaths[GetPlayerZone(playerid)] = 0;
		ZoneAttacker[GetPlayerZone(playerid)] = GetPlayerTeam(playerid);
		ZoneAttackTime[GetPlayerZone(playerid)] = 0;
		GangZoneFlashForAll(ZoneID[GetPlayerZone(playerid)], GetTeamZoneColor(ZoneAttacker[GetPlayerZone(playerid)]));
		foglal[playerid] = 1;
		foglalja[GetPlayerZone(playerid)] = playerid;
	}
	return 1;
}

forward CargoDel();
public CargoDel(){
	for(new i = 0; i < 3; i++){
        DestroyPickup(cargoes[i]);
	}
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
	if(AdminSzolgalat[playerid] == true){
	    SetPlayerHealth(playerid, 100.0);
	    SendClientMessage(issuerid,piros,"Ne l�dd az admint!");
	    return 1;
	}
	if(playerSK[playerid] == 1){
		SetPlayerHealth(playerid, 9999);
		SendClientMessage(issuerid, piros,"Anti spawn kill v�delme van, nem tudod meg�lni!");
	}
	if(issuerid != INVALID_PLAYER_ID && bodypart == 9)
    {
		new pTeam = GetPlayerTeam(playerid), kTeam = GetPlayerTeam(issuerid);
		if(pTeam != kTeam){
		    if(jInfo[playerid][helmet] != 1){
				if(playerSK[playerid] == 0){
					getPont(issuerid, 1);
			        SetPlayerHealth(playerid, 0.0);
			        SendClientMessage(issuerid,zold,"Fejbel�tted. Kiv�l� tal�lat! +1 pont");
			        SendClientMessage(playerid,zold,"Fejbel�ttek.");
		        }
	        } else {
	            SendClientMessage(issuerid, feher, "| Nem tudod fejbel�ni, mert sisak van a fej�n! |");
	            SendClientMessage(playerid, feher, "| A sisak megv�dett a fejl�v�st�l! |");
	        }
		}
    }/*
    else {
		new Float:oldhealt;
		GetPlayerHealth(playerid,oldhealt);
		SetPlayerHealth(playerid, oldhealt-amount);
    }*/
    if(GetPlayerTeam(playerid) != GetPlayerTeam(issuerid))
    	PlayerHang(5205, issuerid);
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
        case d_reg: Dialog_Regisztracio(playerid, response, inputtext);
        case d_belep: Dialog_Belepes(playerid, response, inputtext);
        case DIALOG_SHOP: Dialog_Shopitem(playerid, response, listitem);
    }
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    if(!success)
    {
        SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
    }
    return 1;
}

forward getPont(playerid, mennyit);
public getPont(playerid, mennyit){
	jInfo[playerid][Pont]++;
	SetPlayerScore(playerid, GetPlayerScore(playerid) + mennyit);
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
    jInfo[playerid][helmet] = 0;
    RemovePlayerAttachedObject(playerid, 2);
	SetPlayerScore(playerid, jInfo[playerid][Pont]);
	GivePlayerMoney(playerid, jInfo[playerid][Penz]);
	foglal[playerid] = 0;
	inShop[playerid] = 0;
	inCargo[playerid] = 0;
	for(new i=0; i < ShopsDb; i++){
	    SetPlayerMapIcon(playerid, i, Shops[i][xPos], Shops[i][yPos], Shops[i][zPos], Shops[i][mapiconid], 0, MAPICON_LOCAL);
	}
	for(new i=0; i < zoneDb; i++){
	    if(ZoneInfo[i][foglalhato] != 0){
	        if(ZoneInfo[i][fx] != 0 && ZoneInfo[i][fy] != 0 && ZoneInfo[i][fz] != 0)
	    		SetPlayerMapIcon(playerid, i, ZoneInfo[i][fx], ZoneInfo[i][fy], ZoneInfo[i][fz], 19, 0, MAPICON_LOCAL);
	 	}
	}
    return 1;
}

public ZoneTimer()
{
	for(new i=0; i < zoneDb; i++) // loop all zones
	{
		if(ZoneAttacker[i] != -1) // zone is being attacked
		{
			if(GetPlayersInZone(i, ZoneAttacker[i]) >= 1 && !IsPlayerInAnyVehicle(foglalja[i])) // there must be at least 1 attacker left
			{
				ZoneAttackTime[i]++;
				if(ZoneAttackTime[i] == TAKEOVER_TIME) // zone has been under attack for enough time and attackers take over the zone
				{
					GangZoneStopFlashForAll(ZoneID[i]);
					ZoneInfo[i][zTeam] = ZoneAttacker[i];
					GangZoneShowForAll(ZoneID[i], GetTeamZoneColor(ZoneInfo[i][zTeam])); // update the zone color for new team
					ZoneAttacker[i] = -1;
					foglal[foglalja[i]] = 0;
					new money = random(1000)+500;
					GivePlayerMoney(foglalja[i],money);
					jInfo[foglalja[i]][Penz] += money;
					new str[128];
					format(str, sizeof(str), "Sikeresen elfoglaltad a b�zist! Jutalmad: %d$ �s 3 pont", money);
					getPont(foglalja[i], 3);
					SendClientMessage(foglalja[i], zold, str);
					for(new j = 0; j < MAX_PLAYERS; j++){
					    if(j != foglalja[i]){
						    if(IsPlayerInZone(j, i) && GetPlayerTeam(j) == GetPlayerTeam(foglalja[i])){
						        GivePlayerMoney(j,money-200);
						        jInfo[j][Penz] += money-200;
						        format(str, sizeof(str), "Seg�tett�l elfoglalni egy b�zist! Jutalmad: %d$ �s 2 pont", money-200);
		         				getPont(foglalja[i], 2);
		         				SendClientMessage(j, zold, str);
						    }
					    }
					}
					foglalja[i] = -1;
				}
			}
			else // attackers failed to take over the zone
			{
				GangZoneStopFlashForAll(ZoneID[i]);
				ZoneAttacker[i] = -1;
				foglal[foglalja[i]] = 0;
				foglalja[i] = -1;
			}
		}
	}
}

public HackTimer(){
	for(new i = 0; i < MAX_PLAYERS; i++){
	    if(IsPlayerConnected(i)){
		    if(GetPlayerTeam(i) == ZoneInfo[hadkp][zTeam]){
		        new money = 500;
				GivePlayerMoney(i, money);
				jInfo[i][Penz]+=money;
				new str[128];
				format(str, sizeof(str), "A %s b�rtokl�s��rt hackel�si jutalmad: $%d", ZoneInfo[hadkp][felirat], money);
				SendClientMessage(i, vzold, str);
		    }
		}
	}
}

public GetPlayersOnServer() {
 new count;
 for(new i=0; i< MAX_PLAYERS; i++) { //x = MAX_PLAYERS
    if(IsPlayerConnected(i)) {
   count++;
  }
 }
 return count;
}

stock MySQL_BanCheck(playerid)
{
	new IP[16];
	GetPlayerIp(playerid, IP, 16);
	format(query, sizeof(query),"SELECT * FROM `bandata` WHERE(`jatekos`='%s' OR `ip`='%s') AND `bannolva`=1 LIMIT 1", jInfo[playerid][Nev], IP);
	mysql_query(kapcs, query);
	bannolvavan[playerid] = 0;

	if(!cache_get_row_count()) return printf("Nincs bann.");
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

Dialog_Shopitem(playerid, response, listitem){
	if(response){
		switch(listitem){
		    case 0: {
		        new Float: health;
				GetPlayerHealth(playerid, health);
				if(health == 100){
				    SetTimerEx("ShopExit", 3000, false, "i", playerid);
					return SendClientMessage(playerid, piros, "Az �leted teljesen fel van t�ltve!");
				}
				new ar = 5000 - floatround(((health / 100) * 5000));
		        if(GetPlayerMoney(playerid) < ar) return SendClientMessage(playerid, piros, "Nincs r� el�g p�nzed!");
		        {
		            new str[128];
					SetPlayerHealth(playerid, 100);
					GivePlayerMoney(playerid, -ar);
					jInfo[playerid][Penz]-=ar;
					format(str, sizeof(str), "Sikeresen felt�lt�tted az �leted! �ra: %d$ volt.", ar);
					SendClientMessage(playerid, zold, str);
					SetTimerEx("ShopExit", 3000, false, "i", playerid);
		        }
		    }
		    case 1: {
		        if(playerSK[playerid] == 1){
		            return SendClientMessage(playerid, piros, "Anti Spawn Kill v�delem alatt, nem vehetsz goly��ll�mell�nyt!");
		        }
		        new Float: armour;
		        GetPlayerArmour(playerid, armour);
		        if(armour == 100){
		            SetTimerEx("ShopExit", 3000, false, "i", playerid);
					return SendClientMessage(playerid, piros, "A p�nc�lod s�rtetlen!");
		        }
				new ar = 5000 - floatround(((armour / 100) * 5000));
				if(GetPlayerMoney(playerid) < ar) return SendClientMessage(playerid, piros, "Nincs r� el�g p�nzed!");
		        {
		            new str[128];
					SetPlayerArmour(playerid, 100);
					GivePlayerMoney(playerid, -ar);
					jInfo[playerid][Penz]-=ar;
					format(str, sizeof(str), "Sikeresen vett�l egy goly��ll�mell�nyt! �ra: %d$ volt.", ar);
					SendClientMessage(playerid, zold, str);
					SetTimerEx("ShopExit", 3000, false, "i", playerid);
		        }
		    }
		    case 2: {
		        new str[128];
		        new ar = 5000;
		        if(jInfo[playerid][helmet] != 1){
		            if(GetPlayerMoney(playerid) < ar) return SendClientMessage(playerid, piros, "Nincs r� el�g p�nzed!");
		        	{
				        format(str, sizeof(str), "Sikeresen vett�l egy helmetet! �ra: %d$ volt.", ar);
		                SendClientMessage(playerid, zold, str);
		                GivePlayerMoney(playerid, -ar);
						jInfo[playerid][Penz]-=ar;
						jInfo[playerid][helmet] = 1;
						SetPlayerAttachedObject(playerid, 1, 19106, 2, 0.15, -0, 0, 180, 180, 180);
						SetTimerEx("ShopExit", 3000, false, "i", playerid);
					}
                } else {
                    SendClientMessage(playerid, piros, "M�r van sisakod, nem vehetsz m�gegyet!");
                    SetTimerEx("ShopExit", 3000, false, "i", playerid);
                }
		    }
		}
	}
	SetTimerEx("ShopExit", 3000, false, "i", playerid);
	return 1;
}

forward ShopExit(playerid);
public ShopExit(playerid){
	//printf("ShopExit playerid: %d", playerid);
	inShop[playerid] = 0;
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

IsVehicleOccupied(a){
	for(new i=0; i < MAX_PLAYERS; i++)
    	if(IsPlayerInVehicle(i, a))
			return 1;
	return 0;
}

Hang(hangid){
	for(new i=0; i < MAX_PLAYERS; i++){
	    PlayerPlaySound(i, hangid, 0.0, 0.0, 0.0);
	}
}

PlayerHang(hangid, playerid){
	PlayerPlaySound(playerid, hangid, 0.0, 0.0, 0.0);
}

CheckAdmin(playerid){
    if(jInfo[playerid][alevel] == 0)
        return true;
	else
	    return false;
}

stock RankChechk(playerid)
{
    if(jInfo[playerid][Pont] > 3000)
    {
        new Text3D:label = Create3DTextLabel("Alt�bornagy",orange, 30.0, 40.0, 50.0, 40.0, 0);
        Attach3DTextLabelToPlayer(label, playerid, 0.0, 0.0, 0.3);
	}
	else if(jInfo[playerid][Pont] > 2800)
	{
        new Text3D:label1 = Create3DTextLabel("Vez�r�rnagy",orange, 30.0, 40.0, 50.0, 40.0, 0);
        Attach3DTextLabelToPlayer(label1, playerid, 0.0, 0.0, 0.3);
	}
	else if(jInfo[playerid][Pont] > 2600)
	{
        new Text3D:label2 = Create3DTextLabel("Dand�rt�bornok",orange, 30.0, 40.0, 50.0, 40.0, 0);
        Attach3DTextLabelToPlayer(label2, playerid, 0.0, 0.0, 0.3);
	}
	else if(jInfo[playerid][Pont] > 2400)
	{
        new Text3D:label3 = Create3DTextLabel("Ezredes",orange, 30.0, 40.0, 50.0, 40.0, 0);
        Attach3DTextLabelToPlayer(label3, playerid, 0.0, 0.0, 0.3);
	}
	else if(jInfo[playerid][Pont] > 2200)
	{
        new Text3D:label4 = Create3DTextLabel("Alezredes",orange, 30.0, 40.0, 50.0, 40.0, 0);
        Attach3DTextLabelToPlayer(label4, playerid, 0.0, 0.0, 0.3);
	}
	else if(jInfo[playerid][Pont] > 2000)
	{
        new Text3D:label5 = Create3DTextLabel("�rnagy",orange, 30.0, 40.0, 50.0, 40.0, 0);
        Attach3DTextLabelToPlayer(label5, playerid, 0.0, 0.0, 0.3);
	}
	else if(jInfo[playerid][Pont] > 1800)
	{
        new Text3D:label6 = Create3DTextLabel("�rmester",orange, 30.0, 40.0, 50.0, 40.0, 0);
        Attach3DTextLabelToPlayer(label6, playerid, 0.0, 0.0, 0.3);
	}
	else if(jInfo[playerid][Pont] > 1600)
    {
        new Text3D:label7 = Create3DTextLabel("T�rzs�rmester",orange, 30.0, 40.0, 50.0, 40.0, 0);
        Attach3DTextLabelToPlayer(label7, playerid, 0.0, 0.0, 0.3);
	}
	else if(jInfo[playerid][Pont] > 1400)
	{
        new Text3D:label8 = Create3DTextLabel("F�t�rzs�rmester",orange, 30.0, 40.0, 50.0, 40.0, 0);
        Attach3DTextLabelToPlayer(label8, playerid, 0.0, 0.0, 0.3);
	}
	else if(jInfo[playerid][Pont] > 1200)
	{
        new Text3D:label9 = Create3DTextLabel("Z�szl�s",orange, 30.0, 40.0, 50.0, 40.0, 0);
        Attach3DTextLabelToPlayer(label9, playerid, 0.0, 0.0, 0.3);
	}
	else if(jInfo[playerid][Pont] > 1000)
	{
        new Text3D:label10 = Create3DTextLabel("T�rzsz�szl�s",orange, 30.0, 40.0, 50.0, 40.0, 0);
        Attach3DTextLabelToPlayer(label10, playerid, 0.0, 0.0, 0.3);
	}
	else if(jInfo[playerid][Pont] > 800)
	{
        new Text3D:label11 = Create3DTextLabel("F�t�rzsz�szl�s",orange, 30.0, 40.0, 50.0, 40.0, 0);
        Attach3DTextLabelToPlayer(label11, playerid, 0.0, 0.0, 0.3);
	}
	else if(jInfo[playerid][Pont] > 600)
	{
        new Text3D:label12 = Create3DTextLabel("Hadnagy",orange, 30.0, 40.0, 50.0, 40.0, 0);
        Attach3DTextLabelToPlayer(label12, playerid, 0.0, 0.0, 0.3);
	}
	else if(jInfo[playerid][Pont] > 400)
	{
        new Text3D:label13 = Create3DTextLabel("F�hadnagy",orange, 30.0, 40.0, 50.0, 40.0, 0);
        Attach3DTextLabelToPlayer(label13, playerid, 0.0, 0.0, 0.3);
	}
	else if(jInfo[playerid][Pont] > 200)
	{
        new Text3D:label14 = Create3DTextLabel("Sz�zados",orange, 30.0, 40.0, 50.0, 40.0, 0);
        Attach3DTextLabelToPlayer(label14, playerid, 0.0, 0.0, 0.3);
	}
return 1;
}


//------------------------------PARANCSOK---------------------------------------

CMD:rangok(playerid,params[]){
	new masik[1000];
	new rangok[1000] = "Sz�zados - \t\t200pont\nF�hadnagy - \t\t400pont\nHadnagy - \t\t600pont\nF�t�rzsz�szl�s - \t800pont\nT�rzsz�szl�s - \t1000pont\nZ�szl�s - \t\t1200pont\nF�t�rzs�rmester - \t1400pont\nT�rzs�rmester - \t1600pont\n�rmester - \t\t1800pont\n�rnagy - \t\t2000pont\nAlezredes - \t\t2200pont\nEzredes - \t2400pont\nDand�rt�bornok - \t2600pont\nVez�r�rnagy - \t\t2800pont\nAlt�bornagy - \t\t3000pont";
	format(masik,sizeof(masik),"%s",rangok);
	ShowPlayerDialog(playerid,d_rangok,DIALOG_STYLE_MSGBOX,"Szerveren el�rhet� rangok",masik,"Rendben","");
	return 1;
}

CMD:parancsok(playerid, params[]){
	new full[1024];
	new str1[512] = "/rangok\tMegmutatja a rangokat\n";
	new str2[512] = "";
	format(full, sizeof(full), "%s%s", str1, str2);
    ShowPlayerDialog(playerid, DIALOG_CMDS, DIALOG_STYLE_MSGBOX, "Parancsok:", full,"Rendben","");
}

//-----------------------------------ADMIN PARANCSOK----------------------------
CMD:acmd(playerid, params[])
{
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
    if(jInfo[playerid][alevel] > 0)
	{
		new teljes[1024];
		new str1[512] = "/time [ID�] - id��ll�t�s\n/get [ID] -  j�t�kos magadhoz tel�z�se\n/oda [ID] - odateleport�lsz valakihez\n/vrespawn - j�rm�vek �jraspawnol�sa\n/adszolg - adminszolg�lat\n/warn [ID] [INDOK] - figyelmeztet�s\n/ban [ID] [INDOK] - j�t�kos kitilt�sa\n/kick [ID] [INDOK] - j�t�kos kir�g�sa\n/setskin [ID] [SkinID] - kin�zet �ll�t�s\n/penz [ID] [�SSZEG] - p�nz �ll�t�s\n/idojaras [Id�j�r�sID] - id�j�r�s �ll�t�s\n/pont - pontot lehet �ll�tani\n";
		new str2[512] = "/adminszint [ID] [SZINT] - adminszint �ll�t�s\n/healall - mindenkinek az �let�t felt�lti\n/heal [ID] - egy j�t�kos �let�nek felt�lt�se\n/armour [ID] - p�nc�lzat felt�lt�se\n/disarm [ID] - j�t�kos lefegyverz�se\n/dynamic - dinamikus id� �s id�j�r�s\n/asz [SZ�VEG] - F�admin-chat\n/jail [ID] [PERC] [INDOK] - j�t�kos b�rt�nbe z�r�sa\n/unjail [ID] - j�t�kos kienged�se";
		format(teljes, sizeof(teljes), "%s%s", str1, str2);
		ShowPlayerDialog(playerid, d_admin, DIALOG_STYLE_MSGBOX, "Adminparancsok:", teljes,"Rendben","");
	}
	return 1;
}

CMD:pont(playerid,params[])
{
 if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
 if(jInfo[playerid][alevel] > 1)
 {
  new pont,pID;
  if(sscanf(params,"ii",pID,pont)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /pont [playerid][mennyis�g]");
  if(pID == INVALID_PLAYER_ID) return SendClientMessage(playerid, piros, "[ ! ] Nincs ilyen j�t�kos!");
  SetPlayerScore(pID, GetPlayerScore(pID)+pont);
  jInfo[pID][Pont]+=pont;
  new str[128],str1[128];
  format(str,sizeof(str),"[ ! ] Admin: %s adott %d pontot!",jInfo[playerid][Nev],pont);
  SendClientMessage(pID, vzold, str);
  format(str1,sizeof(str1),"[ ! ] %s j�t�kos pontja be�ll�tva! [�j �rt�ke: %d pont]",jInfo[pID][Nev],jInfo[pID][Pont]);
  SendClientMessage(playerid, vzold, str1);
 }else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 2]");
return 1;
}

CMD:ac(playerid, params[]){
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
    if(jInfo[playerid][alevel] > 0)
	{
	    new szoveg[128];
	    if(sscanf(params, "s[128]", szoveg)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /ac [sz�veg]");
	    new str[256];
	    format(str, sizeof(str), "[ ! ] Admin %s: %s", jInfo[playerid][Nev], szoveg);
	    SendClientMessageToAll(A_COLOR, str);
	}
	return 1;
}

CMD:adszolg(playerid,params[]){
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
	new string[128];
	if(IsPlayerConnected(playerid))
	{
		if(jInfo[playerid][alevel] > 0)
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
				SetPlayerSkin(playerid,Skins[GetPlayerTeam(playerid)-1]);
			}
		}else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 1]");
	}
return 1;
}

CMD:adminszint(playerid,params[])
{
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
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
	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 4]");
	return 1;
}

CMD:kocsi(playerid,params[])
{
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
    if(jInfo[playerid][alevel] > 3)
	{
		new mID,buffer[20];
		if(sscanf(params,"i",mID)) return SendClientMessage(playerid,orange,"INFO: /kocsi [ID]");
		if(mID<400 || mID>611) return SendClientMessage(playerid,orange,"400-611-ig vannak csak kocsik!");

		new Float:pX,Float:pY,Float:pZ,Float:pR;
		GetPlayerPos(playerid,pX, pY, pZ);
		GetPlayerFacingAngle(playerid, pR);

		format(buffer, sizeof(buffer),"Z�NA-%d",random(10));
		SetVehicleNumberPlate(AddStaticVehicleEx(mID,pX+4,pY,pZ,pR,140,140,-1,0),buffer);

		//AutoCount++;
	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 4]");
	return 1;
}

CMD:pteam(playerid,params[])
{
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
    if(jInfo[playerid][alevel] > 2)
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
		} else return SendClientMessage(playerid, piros, "[ ! ] Nem online a megadott j�t�kos!");
	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 3]");
	return 1;
}

CMD:setskin(playerid, params[])
{
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
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
    }else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 1]");
	return 1;
}

CMD:get(playerid,params[])
{
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
	if(jInfo[playerid][alevel] > 2)
	{
        new pID, str[128];
		new Float:aX, Float:aY, Float:aZ;
		if(sscanf(params, "i", pID)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /get [playerid]");
		if(pID == INVALID_PLAYER_ID) return SendClientMessage(playerid, piros, "[ ! ] Nincs ilyen j�t�kos!");
	 	if(!IsPlayerInAnyVehicle(pID))
	 	{
			GetPlayerPos(playerid, aX, aY, aZ);
			SetPlayerPos(pID, aX+0.5, aY+0.5, aZ+0.5);
			format(str, sizeof(str), "[ ! ] Admin %s mag�hoz telepolt�rt! ",jInfo[playerid][Nev]);
			SendClientMessage(pID, zold, str);
			SetPlayerInterior(pID,0);
		}
		else {
		    GetPlayerPos(playerid, aX, aY, aZ);
		    SetVehiclePos(GetPlayerVehicleID(pID), aX+2, aY+2, aZ+2);
		    format(str, sizeof(str), "[ ! ] Admin %s mag�hoz telepolt�rt! ",jInfo[playerid][Nev]);
			SendClientMessage(pID, zold, str);
			SetPlayerInterior(pID,0);
		}
	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 3]");
	return 1;
}

CMD:oda(playerid,params[])
{
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
	if(jInfo[playerid][alevel] > 2)
	{
	    new pID, str[128];
		new Float:aX, Float:aY, Float:aZ;
		if(sscanf(params, "i", pID)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /oda [playerid]");
		if(pID == INVALID_PLAYER_ID) return SendClientMessage(playerid, piros, "[ ! ] Nincs ilyen j�t�kos!");
		if(!IsPlayerInAnyVehicle(playerid)){
			GetPlayerPos(pID, aX, aY, aZ);
			SetPlayerPos(playerid, aX+0.5, aY+0.5, aZ+0.5);
			format(str, sizeof(str), "[ ! ] Odament�l %s j�t�koshoz! ",jInfo[pID][Nev]);
			SendClientMessage(playerid, zold, str);
			SetPlayerInterior(playerid,0);
		} else {
		    GetPlayerPos(pID, aX, aY, aZ);
		    SetVehiclePos(GetPlayerVehicleID(playerid), aX+2, aY+2, aZ+2);
		    format(str, sizeof(str), "[ ! ] Odament�l %s j�t�koshoz! ",jInfo[pID][Nev]);
			SendClientMessage(playerid, zold, str);
			SetPlayerInterior(playerid,0);
		}
	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 3]");
	return 1;
}

CMD:tp(playerid, params[]){
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
	if(jInfo[playerid][alevel] > 0)
	{
		new hova[4];
		if(sscanf(params, "s[4]", hova)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /tp [TEAM R�VID�T�S pl: HUN, ITA, GRE]");
		for(new i = 0; i < sizeof(hova); i++){
			hova[i] = toupper(hova[i]);
		}
		if(!IsPlayerInAnyVehicle(playerid)){
			if(!strcmp("HUN", hova)){
			    SetPlayerPos(playerid, 1137.1510, -2037.0577, 69.0078);
			    SetPlayerFacingAngle(playerid, 270.9954);
			    SetPlayerInterior(playerid,0);
			}
			if(!strcmp("GRE", hova)){
			    SetPlayerPos(playerid, 2336.3398, 38.8450, 26.4813);
			    SetPlayerFacingAngle(playerid, 268.4628);
			    SetPlayerInterior(playerid,0);
			}
			if(!strcmp("ITA", hova)){
			    SetPlayerPos(playerid, 218.0903, -87.0485, 1.5696);
			    SetPlayerFacingAngle(playerid, 313.5960);
			    SetPlayerInterior(playerid,0);
			}
			if(!strcmp("RUS", hova)){
			    SetPlayerPos(playerid, 912.1116, -1231.0538, 16.9766);
			    SetPlayerFacingAngle(playerid, 8.6328);
			    SetPlayerInterior(playerid,0);
			}
			if(!strcmp("KIN", hova)){
			    SetPlayerPos(playerid, 2675.8403, -2453.0208, 13.6379);
			    SetPlayerFacingAngle(playerid, 272.1722);
			    SetPlayerInterior(playerid,0);
			}
			if(!strcmp("KAM", hova)){
			    SetPlayerPos(playerid, 537.7534, -1877.5918, 3.8040);
			    SetPlayerFacingAngle(playerid, 341.5533);
			    SetPlayerInterior(playerid,0);
			}
			if(!strcmp("AUS", hova)){
			    SetPlayerPos(playerid, -2163.3647, -2387.4873, 30.6250);
			    SetPlayerFacingAngle(playerid, 149.0301);
			    SetPlayerInterior(playerid,0);
			}
		} else {
		    if(!strcmp("HUN", hova)){
		    	SetVehiclePos(GetPlayerVehicleID(playerid), 1137.1510, -2037.0577, 69.0078);
			}
			if(!strcmp("GRE", hova)){
			    SetVehiclePos(GetPlayerVehicleID(playerid), 2336.3398, 38.8450, 26.4813);
			    SetVehicleZAngle(GetPlayerVehicleID(playerid), 181.0543);
			}
			if(!strcmp("ITA", hova)){
			    SetVehiclePos(GetPlayerVehicleID(playerid), 218.0903, -87.0485, 1.5696);
			    SetVehicleZAngle(GetPlayerVehicleID(playerid), 309.8417);
			}
			if(!strcmp("RUS", hova)){
			    SetVehiclePos(GetPlayerVehicleID(playerid), 912.1116, -1231.0538, 16.9766);
			    SetVehicleZAngle(GetPlayerVehicleID(playerid), 268.8889);
			}
			if(!strcmp("KIN", hova)){
			    SetVehiclePos(GetPlayerVehicleID(playerid), 2675.8403, -2453.0208, 13.6379);
			}
			if(!strcmp("KAM", hova)){
			    SetVehiclePos(GetPlayerVehicleID(playerid), 537.7534, -1877.5918, 3.8040);
			}
			if(!strcmp("AUS", hova)){
			    SetVehiclePos(GetPlayerVehicleID(playerid), -2163.3647, -2387.4873, 30.6250);
			    SetVehicleZAngle(GetPlayerVehicleID(playerid), 231.4317);
			}
		}
 	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 1]");
	return 1;
}

CMD:penz(playerid,params[])
{
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
	if(jInfo[playerid][alevel] > 3)
	{
		new pID, str[128],str1[128], osszeg;
		if(sscanf(params, "ii", pID,osszeg)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /penz [playerid] [�sszeg]");
		if(pID == INVALID_PLAYER_ID) return SendClientMessage(playerid, piros, "[ ! ] Nincs ilyen j�t�kos!");
		if(osszeg < 0)return SendClientMessage(playerid, piros, "[ ! ] Negat�v �sszeget nem lehet megadni!");
		format(str, sizeof(str), "[ ! ] Admin adott %d Ft-ot! ",osszeg);
		SendClientMessage(pID, zold, str);
		format(str, sizeof(str1), "[ ! ] P�nzt adt�l %s j�t�kosnak! ",jInfo[pID][Nev]);
		SendClientMessage(playerid, zold, str1);
		jInfo[pID][Penz] += osszeg;

	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 4]");
	return 1;
}

CMD:time(playerid, params[])
{
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
    if(jInfo[playerid][alevel] > 0)
	{
		new time, string[128];
		if(sscanf(params, "d", time)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /time [�RA]");
		if(time > 24) return SendClientMessage(playerid, piros, "[ ! ] Maximum id�: 24");
		format(string,sizeof(string),"[ ! ] Admin: %s �t�ll�totta az id�t! [Id�: %d]", jInfo[playerid][Nev], time);
		SendClientMessageToAll( vzold, string);
		SetWorldTime(time);
		Hang(1139);
    } else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 1]");
	return 1;
}

CMD:idojaras(playerid, params[])
{
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
    if(jInfo[playerid][alevel] > 0)
	{
		new weather, string[128];
		if(sscanf(params, "d", weather)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /idojaras [ID�J�R�S-ID]");
		if(weather > 700) return SendClientMessage(playerid, piros, "[ ! ] Maximum id�j�r�s: 700");
		format(string,sizeof(string),"[ ! ] Admin: %s �t�ll�totta az id�j�r�st! [Id�j�r�s: %d]", jInfo[playerid][Nev], weather);
		SendClientMessageToAll(vzold, string);
		SetWeather(weather);
		Hang(1139);
  	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 1]");
	return 1;
}

CMD:kick(playerid, params[])
{
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
    if(jInfo[playerid][alevel]  > 1)
	{
		new pid, indok[50], string[128];
		if(sscanf(params, "us[50]", pid, indok)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /kick [ID] [INDOK]");
		if(pid == INVALID_PLAYER_ID) return SendClientMessage(playerid, piros, "[ ! ] Nincs ilyen j�t�kos!");
		if(pid == playerid) return SendClientMessage(playerid, piros, "[ ! ] Nem r�ghatod ki magad!");
		format(string,sizeof(string),"[ ! ] Admin: %s kir�gta %s -t![indok: %s]", jInfo[playerid][Nev], jInfo[pid][Nev], indok);
		SendClientMessageToAll(vzold, string);
		Kick_Player(pid);
	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 2]");
	return 1;
}

CMD:ban(playerid, params[])
{
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
    if(jInfo[playerid][alevel]  > 2)
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
    } else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 3]");
	return 1;
}

CMD:warn(playerid, params[])
{
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
    if(jInfo[playerid][alevel] > 0)
	{
		new pId, reason[50], str[128];
		if(sscanf(params, "is[50]", pId, reason)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /warn [ID] [INDOK]");
		if(pId == INVALID_PLAYER_ID) return SendClientMessage(playerid, piros, "[ ! ] Nincs ilyen j�t�kos!");
		if(pId == playerid) return SendClientMessage(playerid, piros, "[ ! ] Nem figyelmeztetheted magadat!");
		jInfo[pId][warndb]++;
		if(jInfo[pId][warndb] != 3) {
			format(str, sizeof(str), "[ ! ] Admin: %s figyelmeztette %s -t! [indok: %s] [%d/3]", jInfo[playerid][Nev], jInfo[pId][Nev], reason, jInfo[pId][warndb]);
			SendClientMessageToAll(vzold, str);
			PlayerPlaySound(pId, 1139, 0.0, 0.0, 0.0);
		} else {

			format(str, sizeof(str), "[ ! ] Admin: %s kir�gta a szerverr�l %s -t! [indok: %s] [Figyelmeztet�s: %d/3]", jInfo[playerid][Nev], jInfo[pId][Nev], reason, jInfo[pId][warndb]);
			SendClientMessageToAll(vzold, str);
		    Kick_Player(pId);
		}
	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 1]");
	return 1;
}

CMD:healall(playerid, params[])
{
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
    if(jInfo[playerid][alevel] > 1)
	{
	    new str[128];
		for(new i = 0; i < MAX_PLAYERS; i++) {
			SetPlayerHealth(i, 100.0);
		}
		format(str, sizeof(str), "[ ! ] Admin: %s meggy�gy�tott minden j�t�kost!", jInfo[playerid][Nev]);
		SendClientMessageToAll(vzold, str);
		Hang(1139);
	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 2]");
	return 1;
}

CMD:armourall(playerid, params[])
{
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
    if(jInfo[playerid][alevel] > 1)
	{
	    new str[128];
		for(new i = 0; i < MAX_PLAYERS; i++) {
			SetPlayerArmour(i, 100.0);
		}
		format(str, sizeof(str), "[ ! ] Admin: %s mindenkinek adott goly��ll�mell�nyt!", jInfo[playerid][Nev]);
		SendClientMessageToAll(vzold, str);
		Hang(1139);
	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 2]");
	return 1;
}

CMD:helmall(playerid, params[])
{
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
    if(jInfo[playerid][alevel] > 1)
	{
	    new str[128];
		for(new i = 0; i < MAX_PLAYERS; i++) {
		    if(jInfo[i][helmet] != 1){
				SetPlayerAttachedObject(i, 1, 19106, 2, 0.15, -0, 0, 180, 180, 180);
				jInfo[i][helmet] = 1;
			}
		}
		format(str, sizeof(str), "[ ! ] Admin: %s mindenkinek adott sisakot!", jInfo[playerid][Nev]);
		SendClientMessageToAll(vzold, str);
		Hang(1139);
	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 2]");
	return 1;
}

CMD:weaponall(playerid,params[]){
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
    if(jInfo[playerid][alevel] > 1)
	{
		new weaponID, ammo;
	    if(sscanf(params,"ii",weaponID, ammo)) return SendClientMessage(playerid,orange,"Haszn�lat /fegyver [id] [ammo]");
	    if(weaponID<0 || weaponID>47) return SendClientMessage(playerid,orange,"1-47-ig vannak csak fegyverek!");
		for(new i = 0; i < MAX_PLAYERS; i++){
			GivePlayerWeapon(i, weaponID, ammo);
		}
		new str[128], weaponname[50];
		GetWeaponName(weaponID, weaponname, sizeof(weaponname));
		format(str, sizeof(str), "[ ! ] Admin: %s mindenkinek adott %s fegyvert, %d l�szerrel!", jInfo[playerid][Nev], weaponname, ammo);
		SendClientMessageToAll(vzold, str);
		Hang(1139);
	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 2]");
	return 1;
}

CMD:playsound(playerid, params[]){ // Ez csak arra ha valamilyen hangot keres�nk
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
    if(jInfo[playerid][alevel] > 4)
	{
		new hang;
		if(sscanf(params, "i", hang)) return SendClientMessage(playerid, piros, "Haszn�lat: /playsound [id]");
		{
		    PlayerPlaySound(playerid, hang, 0.0, 0.0, 0.0);
		}
 	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 5]");
	return 1;
}

CMD:vrespawn(playerid, params[])
{
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
    if (jInfo[playerid][alevel] > 1)
	{
	    for(new i=0; i <= AutoCount;i++)
		{
		    if(IsVehicleOccupied(i) == 0)
		    {
		        if(CarInfo[i][modelid] != 537){
		        	SetVehicleToRespawn(i);
		        }
		    }
		}
		new string[128];
		format(string, sizeof(string), "[ ! ] Admin: %s visszatett minden haszn�laton k�v�li j�rm�vet a hely�re!", jInfo[playerid][Nev]);
		SendClientMessageToAll(vzold, string);
		Hang(1139);
	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 2]");
	return 1;
}

CMD:fixall(playerid, params[]){
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
	if (jInfo[playerid][alevel] > 1)
	{
	    for(new i=0; i <= MAX_VEHICLES;i++)
		{
		    RepairVehicle(i);
		}
		new string[128];
		format(string, sizeof(string), "[ ! ] Admin: %s megjav�tott minden j�rm�vet!", jInfo[playerid][Nev]);
		SendClientMessageToAll(vzold, string);
		Hang(1139);
	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 2]");
    return 1;
}

CMD:ipm(playerid,params[])
{
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
	if (jInfo[playerid][alevel] > 4)
	{
		new ip[16],ipstring[128];
		GetPlayerIp(playerid, ip, 16);
		format(ipstring,sizeof(ipstring),"IP c�m: %s",ip);
		SendClientMessage(playerid,vzold,ipstring);
	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 5]");
	return 1;
}

CMD:getzone(playerid, params[]){
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
    if (jInfo[playerid][alevel] > 4)
	{
	    new str[128];
	    new Float:aX, Float:aY, Float:aZ;
	    format(str, sizeof(str), "Z�na id amiben vagy: %d, Getplayezone: %d", ZoneInfo[GetPlayerZone(playerid)][zId], GetPlayerZone(playerid));
	    SendClientMessage(playerid, vzold, str);
	    GetPlayerPos(playerid, aX, aY, aZ);
	    format(str, sizeof(str), "Poz�ci�d: x: %f, y: %f, z: %f", aX, aY, aZ);
	    SendClientMessage(playerid, vzold, str);
	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 5]");
	return 1;
}

CMD:szone(playerid,params[]){
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
	if(jInfo[playerid][alevel] > 4)
	{
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
				format(query, sizeof(query), "INSERT INTO zones VALUES ('','%f','%f','%f','%f','%d','1','',0,0,0)", SaveZone[0][zMinX], SaveZone[0][zMinY], SaveZone[0][zMaxX], SaveZone[0][zMaxY], melyikteam);
				mysql_tquery(kapcs, query);
				SendClientMessage(playerid, zold, "A z�na sikeresen elmentve az adatb�zisba!");

				ZoneInfo[zoneDb][zId] = zoneDb;
				ZoneInfo[zoneDb][zMinX] = SaveZone[0][zMinX];
				ZoneInfo[zoneDb][zMinY] = SaveZone[0][zMinY];
				ZoneInfo[zoneDb][zMaxX] = SaveZone[0][zMaxX];
				ZoneInfo[zoneDb][zMaxY] = SaveZone[0][zMaxY];
				ZoneInfo[zoneDb][zTeam] = SaveZone[0][zTeam];
				ZoneID[zoneDb] = GangZoneCreate(SaveZone[0][zMinX], SaveZone[0][zMinY], SaveZone[0][zMaxX], SaveZone[0][zMaxY]);
				//printf("zonedb: %d", zoneDb);
				//printf("%d, %f, %f, %f, %f, %d", ZoneInfo[zoneDb][zId], ZoneInfo[zoneDb][zMinX], ZoneInfo[zoneDb][zMinY], ZoneInfo[zoneDb][zMaxX], ZoneInfo[zoneDb][zMaxY], ZoneInfo[zoneDb][zTeam]);

			for(new i = 0; i < GetPlayersOnServer(); i++){
				new zoneidija = GangZoneShowForPlayer(i, ZoneID[zoneDb], GetTeamZoneColor(ZoneInfo[zoneDb][zTeam]));
				foglalja[zoneidija] = -1;
			}
			zoneDb++;
	        }
	    }
   } else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 5]");
 return 1;
}

CMD:szonetext(playerid, params[]){
	if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
    if (jInfo[playerid][alevel] > 4)
	{
	    new ftext[50];
        if(sscanf(params, "s[50]", ftext)) return SendClientMessage(playerid, piros, "[ ! ] Haszn�lat: /szonetext [felirat]");
        new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		format(query, sizeof(query), "UPDATE zones SET felirat='%s', fX='%f', fY='%f', fZ='%f' WHERE id='%d'", ftext, x, y, z, ZoneInfo[GetPlayerZone(playerid)][zId]);
		if(mysql_tquery(kapcs, query) == 1)
			SendClientMessage(playerid, zold, "[ ! ] A z�na felirata sikeresen mentve az adatb�zisba!");
		else
		    SendClientMessage(playerid, piros, "[ ! ] Valami hiba t�rt�nt a z�na felirat�nak m�dos�t�s�n�l!");
	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 5]");
	return 1;
}

CMD:skocsi(playerid, params[])
{
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
    if (jInfo[playerid][alevel] > 4)
	{
		if(IsPlayerInAnyVehicle(playerid) != 0)
		{
			new rendszam[8];
			new tulajdonos, szin1, szin2;
			//new string[128];
			if(sscanf(params, "dd", szin1, szin2)) return SendClientMessage(playerid, piros, "Haszn�lata: /skocsi [szin1] [szin2]");
			{
				tulajdonos = 0;
			    new currentveh = GetPlayerVehicleID(playerid);
			    new vehModelID = GetVehicleModel(currentveh);
				new Float:vehx, Float:vehy, Float:vehz, Float:z_rot;
				GetVehiclePos(currentveh, vehx, vehy, vehz);
				GetVehicleZAngle(currentveh, z_rot);
				if(AutoCount < 10)
				{
				    format(rendszam, sizeof(rendszam), "ZW-000%d", AutoCount);
					//printf("%s", rendszam);
				}
			 	else if(AutoCount < 100)
				{
					format(rendszam, sizeof(rendszam), "ZW-00%d", AutoCount);
					//printf("%s", rendszam);
				}
				else if(AutoCount < 1000)
				{
				    format(rendszam, sizeof(rendszam), "ZW-0%d", AutoCount);
					//printf("%s", rendszam);
				}
				else
				{
				    format(rendszam, sizeof(rendszam), "ZW-%d", AutoCount);
					//printf("%s", rendszam);
				}
				format(query, sizeof(query), "INSERT INTO `cars` (`id`, `rendszam`, `modelid`, `x`, `y`, `z`, `angle`, `tulaj`, `col1`,`col2`) VALUES (NULL, '%s', '%d', '%f', '%f', '%f', '%f', '%d', '%d', '%d')", rendszam, vehModelID, vehx, vehy, vehz, z_rot, tulajdonos, szin1, szin2);
				mysql_tquery(kapcs, query);
				SendClientMessage(playerid, zold, "| A kocsi mentve az adatb�zisba! |");
				AutoCount++;
			}
		}
	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 5]");
	return 1;
}

CMD:sshop(playerid, params[])
{
    if(CheckAdmin(playerid)) return SendClientMessage(playerid, piros, "[ ! ] Ismeretlen parancs! [/parancsok]");
    if (jInfo[playerid][alevel] > 4)
	{
	    new Float:aX, Float:aY, Float:aZ;
	    new pickid, mapid;
	    GetPlayerPos(playerid, aX, aY, aZ);
	    if(sscanf(params, "dd", pickid, mapid)) return SendClientMessage(playerid, piros, "Haszn�lata: /sshop [pickupid] [mapiconid]");
		{
		    format(query, sizeof(query), "INSERT INTO shops VALUES('','%f','%f','%f','%d','%d')", aX, aY, aZ, pickid, mapid);
		    mysql_tquery(kapcs, query);
		    SendClientMessage(playerid, zold, "| A shop mentve az adatb�zisba! |");
		}
 	} else SendClientMessage(playerid, piros, "[ ! ] Nem haszn�lhatod ezt a parancsot! [Min. adminszint: 5]");
	return 1;
}

CMD:getvehid(playerid, params[]){
	printf("%d", GetPlayerVehicleID(playerid));
	return 1;
}

CMD:putnpc(playerid, params[]){
    PutPlayerInVehicle(0, Train, 0);
}
