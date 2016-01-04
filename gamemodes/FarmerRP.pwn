#include <a_samp>
#include <ZCMD>
#include <sscanf2>
//#include <fixchars.h>
#include <a_mysql>
#pragma tabsize 0

#define feher 0xFFFFFFFF
#define piros 0xFF0000FF
#define lila 0xCD32C9FF
#define zold 0x1BA901FF
#define turkiz 0x00FFFFFF
#define narancs 0xFF8000FF


new magok = 0;
new kapcs, query[2000];
new AutoCount = 0;
new FoldCount = 0;
new picupbanAll[MAX_PLAYERS];
new melyikPickUp[MAX_PLAYERS];

main()
{
	print("\n----------------------------------");
	print(" Blank Gamemode by your name here");
	print("----------------------------------\n");
}

enum
{
	d_reg,
	d_belep,
	d_varos,
	d_nemek,
	d_traktorBerles,
	d_Foldek,
	d_FoldBerles
}

enum JatekosInfo {
	Nev[25],
	Penz,
	Skin,
	Pont,
	Nem,
	Float:X,
	Float:Y,
	Float:Z,
	alevel
}
new jInfo[MAX_PLAYERS][JatekosInfo];

enum FoldInfo {
	id,
	ar,
	Float:X,
	Float:Y,
	Float:Z,
	pickupID,
	fold_pickup,
	meret,
	berletidij
}
new fInfo[100][FoldInfo];

public OnGameModeInit()
{
	mysql_log(LOG_ALL, LOG_TYPE_HTML);
	kapcs = mysql_connect("localhost", "root", "farmerrp", "");
	if(mysql_errno(kapcs) != 0) printf("MySQL hiba! Hibakód: %d", mysql_errno(kapcs));
	mysql_tquery(kapcs, "SELECT * FROM `foldek`","FoldLoad");
	
	UsePlayerPedAnims();         			//Normál futás
	DisableInteriorEnterExits(); 			//Interior kikapcs
	EnableStuntBonusForAll(0);              //ugrató pénz kikapcs
	SetGameModeText("GazdaMód 0.1");

	new str[128];
	new Text3D:magszam,proba_id;
	format(str,sizeof(str),"%d | 1000L",magok);
	magszam = Create3DTextLabel(str, zold, 0.0, 0.0, 0.0, 50.0, 0, 0);
	proba_id = CreateVehicle(610,1241.3000000,181.1000100,19.8000000,336.0000000,128,0,15); //Eke
	Attach3DTextLabelToVehicle(magszam,proba_id, 0.0, 0.0, 1.0);
	
	CreateVehicle(531,1238.5000000,182.3999900,19.8000000,335.9950000,128,0,15); //Tractor
	CreateObject(16610,3020.1001000,1056.2000000,35.3000000,0.0000000,0.0000000,0.0000000); //object(des_nbridgebit_02) (1)
	CreateObject(4654,2871.5000000,1571.8000000,17.5000000,0.0000000,0.0000000,270.0000000); //object(road09_lan2) (1)
	return 1;
}

public OnGameModeExit()
{
    mysql_close(kapcs);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SpawnPlayer(playerid);
	if(jInfo[playerid][Nem] == 1)
	{
		SetPlayerSkin(playerid,158);
	}else if(jInfo[playerid][Nem] == 2) SetPlayerSkin(playerid,198);
	return 1;
}

public OnPlayerConnect(playerid)
{
    RemoveBuildingForPlayer(playerid, 705, 979.74219, 272.17188, 27.375, 27.506569);
	RemoveBuildingForPlayer(playerid, 705, 948.39844, 296.96875, 24.91406, 27.506569);
	
	TogglePlayerSpectating(playerid, true);
    for(new a; JatekosInfo:a < JatekosInfo; a++) jInfo[playerid][JatekosInfo:a] = 0;    //Nullázzuk az enumjait
    GetPlayerName(playerid, jInfo[playerid][Nev], 25);                                  //Lekérjük a nevét.
    if(strfind(jInfo[playerid][Nev], "_") == -1)                                        //Nem tartalmaz alsóvonást.
    for(new a; a < strlen(jInfo[playerid][Nev]); a++) if(jInfo[playerid][Nev][a] == '_') jInfo[playerid][Nev][a] = ' ';//Végigfutunk a nevén. Ha az egyik karaktere '_', kicseréli ' '-re.
    mysql_format(kapcs, query, 256, "SELECT id,nev FROM jatekosok WHERE nev='%e' LIMIT 1", jInfo[playerid][Nev]);
    mysql_tquery(kapcs, query, "RegEllenorzes", "d", playerid);
    for(new i = 0; i < FoldCount; i++)
    {
    	SetPlayerMapIcon(playerid, i, fInfo[i][X], fInfo[i][Y], fInfo[i][Z], 60, 0, MAPICON_GLOBAL);
	}
	return 1;
}

forward RegEllenorzes(playerid);
public RegEllenorzes(playerid)
{
    new sorok_szama = cache_get_row_count();
    if(sorok_szama == 0) ShowPlayerDialog(playerid, d_reg, DIALOG_STYLE_PASSWORD, "Regisztráció", "{FFFFFF}Üdv a szerveren!\nMég nem regisztráltál!\nKérlek adj meg egy jelszót!", "Regisztrál", "Kilép");
    else ShowPlayerDialog(playerid, d_belep, DIALOG_STYLE_PASSWORD, "Bejelentkezés", "{FFFFFF}Üdv a szerveren!\n\nKérlek add meg a jelszavad, amivel regisztráltált!", "Belép", "Kilép");
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	mysql_format(kapcs, query, 384, "UPDATE jatekosok SET penz='%d',pont='%d' WHERE nev='%s'", jInfo[playerid][Penz],jInfo[playerid][Pont],jInfo[playerid][Nev]);
	mysql_tquery(kapcs, query);
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
	if(GetVehicleModel(vehicleid) == 531)
	ShowPlayerDialog(playerid,d_traktorBerles,DIALOG_STYLE_MSGBOX,"{289AD0}Jármű bérlése","Szeretnéd kibérelni?\n\n{FF8040}40.000Ft/óra","Igen","Nem");
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
	FoldPickup(playerid);		//itt hívom meg, hogy mit csináljon ha beleáll a pickupba
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
        case d_varos: Dialog_Varosok(playerid, response, listitem);
        case d_nemek: Dialog_Nem(playerid, response, inputtext);
        case d_traktorBerles: Dialog_TraktorBerlo(playerid, response);
        case d_Foldek: Dialog_Fold(playerid,response,listitem);     //ez a dialog amit a pickup megjelenít
		case d_FoldBerles: Dialog_FoldBerles(playerid,response);    //ez csak a bérlés menűpontja a fő dialognak
    }
    return 0;
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
    ShowPlayerDialog(playerid,d_varos,DIALOG_STYLE_LIST,"Kezdő városok","PalominoCreek\nMontgomery\nBlueBerry\nFortCarson\nLasPayasadas\nBaySide\nAngelPine","Választ","Mégsem");
    return 1;
}

forward JatekosBelep(playerid);
public JatekosBelep(playerid)
{
    new sorok_szama = cache_get_row_count();
    if(sorok_szama == 0) return ShowPlayerDialog(playerid, d_belep, DIALOG_STYLE_PASSWORD, "Bejelentkezés", "{FFFFFF}Üdv a szerveren!\nKérlek add meg a jelszavad, amivel regisztráltált!\n\n{FF0000}Hibás jelszó!", "Belép", "Kilép");
    //Az elobb, ha hibás volt a jelszó visszatértünk volna, szóval innenztol ami lefut kód, az már jó jelszóval fut le:
    SendClientMessage(playerid, zold, "Sikeresen bejelentkeztél!");
	jInfo[playerid][Nem] = cache_get_field_content_int(0, "neme",kapcs);
	jInfo[playerid][Penz] = cache_get_field_content_int(0, "penz",kapcs);
    jInfo[playerid][Pont] = cache_get_field_content_int(0, "pont",kapcs);
    
   	if(jInfo[playerid][Nem] == 1)
	{
		SetPlayerSkin(playerid,158);
	}else if(jInfo[playerid][Nem] == 2) SetPlayerSkin(playerid,198);
	ShowPlayerDialog(playerid,d_varos,DIALOG_STYLE_LIST,"Kezdő városok","PalominoCreek\nMontgomery\nBlueBerry\nFortCarson\nLasPayasadas\nBaySide\nAngelPine","Választ","Mégsem");
    return 1;
}

forward FoldLoad();
public FoldLoad()
{
if(!cache_get_row_count()) return printf("cache_get_row_count returned false. Nincsennek betöltendő sorok.");
 	for(new i, j = cache_get_row_count(); i < j ; i++)
	{
	    fInfo[i][id] = cache_get_field_content_int(i,"id",kapcs);
		fInfo[i][X] = cache_get_field_content_float(i,"pickupX",kapcs);
		fInfo[i][Y] = cache_get_field_content_float(i,"pickupY",kapcs);
		fInfo[i][Z] = cache_get_field_content_float(i,"pickupZ",kapcs);
		fInfo[i][ar] = cache_get_field_content_int(i,"ar",kapcs);
		fInfo[i][meret] = cache_get_field_content_int(i,"meret",kapcs);
		fInfo[i][pickupID] = cache_get_field_content_int(i,"pickup",kapcs);
		fInfo[i][berletidij] = cache_get_field_content_int(i,"berletidij",kapcs);
		foldupdate(i);
	}
return 1;
}

foldupdate(i)
{
	fInfo[i][fold_pickup] = CreatePickup(fInfo[i][pickupID],1,fInfo[i][X],fInfo[i][Y],fInfo[i][Z],-1);
	FoldCount++;
}

//==============================================================================
//===============================KIFEJTETT DIALOGOK=============================
//==============================================================================
Dialog_FoldBerles(playerid,response)
{
if(!response) return 1;
	{
		SendClientMessage(playerid,feher,"Kibérelted egy napra ezt a földet!");
	}
return 1;
}

Dialog_Fold(playerid,response,listitem)     //ez a fő dialog ebben van 3 opció
{
if(!response) return 1;
switch(listitem)
{
	case 0:                                 //1. információ itt is ittvan a forciklus
	{
	    new foldMeret[128];
	    for(new i=0; i<FoldCount; i++)
	    {
	        if(i == melyikPickUp[playerid])
	        {
				SendClientMessage(playerid,feher,"  |___________________Információ__________________|");
				format(foldMeret,sizeof(foldMeret),"|Sorszáma:			%d. termőföld_______________|",fInfo[i][id]);
				SendClientMessage(playerid,feher,foldMeret);
				format(foldMeret,sizeof(foldMeret),"|Mérete:			%d hektár___________________|",fInfo[i][meret]);
				SendClientMessage(playerid,feher,foldMeret);
				format(foldMeret,sizeof(foldMeret),"|Ára:				%d Ft_______________________|",fInfo[i][ar]);
				SendClientMessage(playerid,feher,foldMeret);
				SendClientMessage(playerid,feher,"|_________________________________________________|");
			}
		}
	}
	case 1:                                 //2. Bérlés
	{
	new bDij[128];
		for(new i=0; i<FoldCount; i++)
		{
		if(jInfo[playerid][Penz] < fInfo[i][berletidij]) return SendClientMessage(playerid,piros,"((Nincs elég pénzed!))");
		    if(i == melyikPickUp[playerid])
		    {
			    format(bDij,sizeof(bDij),"Bérlés: %dFt/nap",fInfo[i][berletidij]); //Bérleti díj 39.000Ft × hektár mérete
				ShowPlayerDialog(playerid,d_FoldBerles,DIALOG_STYLE_LIST,"Föld bérlés",bDij,"Rendben","Mégsem");
			}
		}
	}
	case 2:                                 //3. Vásárlás és itt is
	{
	    new foldAr[128];
	    for(new i=0; i<FoldCount; i++)
	    {
	        if(i == melyikPickUp[playerid])
	        {
			    format(foldAr,sizeof(foldAr),"Ára: %d Ft",fInfo[i][ar]);
				SendClientMessage(playerid,feher,foldAr);
			}
		}
	}
}
return 1;
}

Dialog_TraktorBerlo(playerid,response)
{
	if(!response) return RemovePlayerFromVehicle(playerid);
	if(jInfo[playerid][Penz] < 40000)
		{
            RemovePlayerFromVehicle(playerid);
            SendClientMessage(playerid,piros,"((Nincs elég pénzed!))");
		}else
	SendClientMessage(playerid,zold,"((Mostantól 60 percig használhatod a traktort!))");
	jInfo[playerid][Penz] -= 40000;
	SetTimer("Berles",600000,false);
return 1;
}

forward Berles(playerid);
public Berles(playerid)
{
	RemovePlayerFromVehicle(playerid);
	SendClientMessage(playerid,piros,"((Lejárt a jármű bérlése!))");
}

Dialog_Nem(playerid, response, inputtext[])
{
if(!response) return 1;
{
    mysql_format(kapcs, query, 256, "UPDATE jatekosok SET neme='%d' WHERE nev='%s'",strval(inputtext),jInfo[playerid][Nev]);
    mysql_tquery(kapcs, query);
    jInfo[playerid][Nem] = strval(inputtext);
	if(jInfo[playerid][Nem] == 1)
	{
		SetPlayerSkin(playerid,158);
	}else if(jInfo[playerid][Nem] == 2) SetPlayerSkin(playerid,198);
    SendClientMessage(playerid,zold,"((Elmentve!))");
    //SpawnPlayer(playerid);
}
return 1;
}

Dialog_Varosok(playerid,response,listitem)
{
if(!response) return 1;
switch(listitem)
{
	case 0:
	{
		TogglePlayerSpectating(playerid, false);
		SetSpawnInfo(playerid,0,0,2334.3550,-18.7154,26.4844,0, 0, 0, 0, 0, 0, 0);
		SendClientMessage(playerid,lila,"((PlaominoCreek))");
		if(jInfo[playerid][Nem] == 0) ShowPlayerDialog(playerid,d_nemek,DIALOG_STYLE_INPUT,"Karakter neme.","Adja meg a karakter nemét!\nFérfi 1-es vagy Nő 2-es\n[csak a számot add meg!]","Jóváhagy","Mégsem");
		SpawnPlayer(playerid);
		if(jInfo[playerid][Nem] == 1)
		{
			SetPlayerSkin(playerid,158);
		}else if(jInfo[playerid][Nem] == 2) SetPlayerSkin(playerid,198);
	}
	case 1:
	{
		TogglePlayerSpectating(playerid, false);
		SetSpawnInfo(playerid,0,0,1314.4891,328.1817,19.5547,0, 0, 0, 0, 0, 0, 0);
		SendClientMessage(playerid,lila,"((Montgomery))");
		if(jInfo[playerid][Nem] == 0) ShowPlayerDialog(playerid,d_nemek,DIALOG_STYLE_INPUT,"Karakter neme.","Adja meg a karakter nemét!\nFérfi 1-es vagy Nő 2-es\n[csak a számot add meg!]","Jóváhagy","Mégsem");
		SpawnPlayer(playerid);
		if(jInfo[playerid][Nem] == 1)
		{
			SetPlayerSkin(playerid,158);
		}else if(jInfo[playerid][Nem] == 2) SetPlayerSkin(playerid,198);
	}
	case 2:
	{
		TogglePlayerSpectating(playerid, false);
		SetSpawnInfo(playerid,0,0,207.6687,-63.3022,1.5781,0, 0, 0, 0, 0, 0, 0);
        SendClientMessage(playerid,lila,"((BlueBerry))");
		if(jInfo[playerid][Nem] == 0) ShowPlayerDialog(playerid,d_nemek,DIALOG_STYLE_INPUT,"Karakter neme.","Adja meg a karakter nemét!\nFérfi 1-es vagy Nő 2-es\n[csak a számot add meg!]","Jóváhagy","Mégsem");
		SpawnPlayer(playerid);
		if(jInfo[playerid][Nem] == 1)
		{
			SetPlayerSkin(playerid,158);
		}else if(jInfo[playerid][Nem] == 2) SetPlayerSkin(playerid,198);
	}
	case 3:
	{
		TogglePlayerSpectating(playerid, false);
		SetSpawnInfo(playerid,0,0,-205.1110,1118.8389,19.7422,0, 0, 0, 0, 0, 0, 0);
        SendClientMessage(playerid,lila,"((FortCarson))");
		if(jInfo[playerid][Nem] == 0) ShowPlayerDialog(playerid,d_nemek,DIALOG_STYLE_INPUT,"Karakter neme.","Adja meg a karakter nemét!\nFérfi 1-es vagy Nő 2-es\n[csak a számot add meg!]","Jóváhagy","Mégsem");
		SpawnPlayer(playerid);
		if(jInfo[playerid][Nem] == 1)
		{
			SetPlayerSkin(playerid,158);
		}else if(jInfo[playerid][Nem] == 2) SetPlayerSkin(playerid,198);
	}
	case 4:
	{
		TogglePlayerSpectating(playerid, false);
		SetSpawnInfo(playerid,0,0,-252.8263,2609.6570,62.8582,0, 0, 0, 0, 0, 0, 0);
        SendClientMessage(playerid,lila,"((LasPayasadas))");
		if(jInfo[playerid][Nem] == 0) ShowPlayerDialog(playerid,d_nemek,DIALOG_STYLE_INPUT,"Karakter neme.","Adja meg a karakter nemét!\nFérfi 1-es vagy Nő 2-es\n[csak a számot add meg!]","Jóváhagy","Mégsem");
		SpawnPlayer(playerid);
		if(jInfo[playerid][Nem] == 1)
		{
			SetPlayerSkin(playerid,158);
		}else if(jInfo[playerid][Nem] == 2) SetPlayerSkin(playerid,198);
	}
	case 5:
	{
		TogglePlayerSpectating(playerid, false);
		SetSpawnInfo(playerid,0,0,-2276.7764,2326.7961,4.9683,0, 0, 0, 0, 0, 0, 0);
        SendClientMessage(playerid,lila,"((BaySide))");
		if(jInfo[playerid][Nem] == 0) ShowPlayerDialog(playerid,d_nemek,DIALOG_STYLE_INPUT,"Karakter neme.","Adja meg a karakter nemét!\nFérfi 1-es vagy Nő 2-es\n[csak a számot add meg!]","Jóváhagy","Mégsem");
		SpawnPlayer(playerid);
		if(jInfo[playerid][Nem] == 1)
		{
			SetPlayerSkin(playerid,158);
		}else if(jInfo[playerid][Nem] == 2) SetPlayerSkin(playerid,198);
	}
	case 6:
	{
		TogglePlayerSpectating(playerid, false);
	    SetSpawnInfo(playerid,0,0,-2178.9993,-2398.9255,30.6250,0, 0, 0, 0, 0, 0, 0);
        SendClientMessage(playerid,lila,"((AngelPine))");
		if(jInfo[playerid][Nem] == 0) ShowPlayerDialog(playerid,d_nemek,DIALOG_STYLE_INPUT,"Karakter neme.","Adja meg a karakter nemét!\nFérfi 1-es vagy Nő 2-es\n[csak a számot add meg!]","Jóváhagy","Mégsem");
		SpawnPlayer(playerid);
		if(jInfo[playerid][Nem] == 1)
		{
			SetPlayerSkin(playerid,158);
		}else if(jInfo[playerid][Nem] == 2) SetPlayerSkin(playerid,198);
	}
}
return 1;
}

Dialog_Regisztracio(playerid, response, inputtext[])
{
	{
        if(!response) return Kick(playerid);
        if(strlen(inputtext) < 5 || strlen(inputtext) > 32) return ShowPlayerDialog(playerid, d_reg, DIALOG_STYLE_PASSWORD, "Regisztráció", "{FFFFFF}Üdv a szerveren!\nMég nem regisztráltál!\nKérlek adj meg egy megjegyezhető és erős jelszót!\n\n{FF0000}Jelszavadnak 5-32 karakter között kell lennie!", "Regisztrál", "Kilép");
        mysql_format(kapcs, query, 256, "INSERT INTO jatekosok (nev,jelszo,penz,pont,neme) VALUES ('%e',SHA1('%e'),'0','0','0')", jInfo[playerid][Nev], inputtext);
        mysql_tquery(kapcs, query, "JatekosBeregelt", "d", playerid);
    }
return 1;
}

Dialog_Belepes(playerid, response, inputtext[])
{
	{
        if(!response) return Kick(playerid);
        if(strlen(inputtext) < 5 || strlen(inputtext) > 32) return ShowPlayerDialog(playerid, d_belep, DIALOG_STYLE_PASSWORD, "Bejelentkezés", "{FFFFFF}Üdv a szerveren!\nMár regisztráltál!\nKérlek add meg a jelszavad, amivel regisztráltáltál!\n\n{FF0000}Jelszavadnak 5-32 karakter között kell lennie!", "Belép", "Kilép");
        mysql_format(kapcs, query, 256, "SELECT * FROM jatekosok WHERE nev='%e' AND jelszo=SHA1('%e')", jInfo[playerid][Nev], inputtext);
        mysql_tquery(kapcs, query, "JatekosBelep", "d", playerid);
    }
return 1;
}
//=============================================================================================
//==================================STOCK======================================================
//=============================================================================================
stock FoldPickup(playerid)                      //ezt hívom meg az OnPlayerUpdate alatt
{
	for(new i=0; i < FoldCount; i++)
	{
		if(IsPlayerInRangeOfPoint(playerid,1.0,fInfo[i][X],fInfo[i][Y],fInfo[i][Z]))
		{
		    if(picupbanAll[playerid] == 0)
			{
				picupbanAll[playerid] = 1;
				SetTimerEx("BoltElottOld", 6000, false, "i", playerid);
				new string[128];
				melyikPickUp[playerid] = fInfo[i][id]-1;
				format(string, sizeof(string), "%d. Termőföld", fInfo[i][id]);
				ShowPlayerDialog(playerid,d_Foldek,DIALOG_STYLE_LIST,string,"Információ\nBérlés\nVásárlás","Rendben","Mégsem");
			}
		}
	}
	return 1;
}

forward BoltElottOld(playerid);
public BoltElottOld(playerid)
{
	picupbanAll[playerid] = 0;
}

//=============================================================================================
//==================================PARANCSOK==================================================
//=============================================================================================
CMD:fold(playerid, params[])
{
	new osszeg,foldmeret;
	if(sscanf(params, "ii",osszeg,foldmeret)) return SendClientMessage(playerid, lila, "Használata: /fold [ára] [mérete]");
	{
	    new Float:x, Float:y, Float:z;
    	GetPlayerPos(playerid, x, y, z);
        format(query, sizeof(query), "INSERT INTO `foldek` (`id`, `tulaj`, `pickupX`, `pickupY`, `pickupZ`, `ar`, `meret`) VALUES (NULL, '', '%f', '%f', '%f', '%d','%d')", x, y, z, osszeg,foldmeret);
		mysql_tquery(kapcs, query);
		SendClientMessage(playerid, zold, "((Elmentve!))");
	}
return 1;
}

CMD:kocsi(playerid,params[])
{
	new mID;
	if(sscanf(params,"i",mID)) return SendClientMessage(playerid,lila,"INFO: /kocsi [ID]");
	if(mID<400 || mID>611) return SendClientMessage(playerid,piros,"400-611-ig vannak csak kocsik!");

	new Float:pX,Float:pY,Float:pZ,Float:pR;
	GetPlayerPos(playerid,pX, pY, pZ);
	GetPlayerFacingAngle(playerid, pR);
	SetVehicleNumberPlate(AddStaticVehicleEx(mID,pX+4,pY,pZ,pR,142,142,-1,0), "PRB-000");
	AutoCount++;
	return 1;
}

CMD:potkocsi(playerid,params[])
{
if(IsPlayerInAnyVehicle(playerid))
	{
	new v = GetPlayerVehicleID(playerid);
	if(!IsTrailerAttachedToVehicle(v))
		{
		if(GetVehicleModel(v) == 531)
		    {
		    for(new v1=0; v1 < MAX_VEHICLES; v1++)
		    	{
		    	if(GetVehicleModel(v1) == 610)
		    	    {
		    	        new Float:x,Float:y,Float:z;
		    	        GetVehiclePos(v1,x,y,z);
		    	        if(IsPlayerInRangeOfPoint(playerid,5.0,x,y,z))
	    	        	{
							AttachTrailerToVehicle(v1,v);
							SendClientMessage(playerid,zold,"((Vontatmány felakasztva!))");
						}
						else SendClientMessage(playerid,piros,"((Nincs a közeledben eszköz!))");
					}
				}
			}else SendClientMessage(playerid,piros,"((Nem ülsz traktorban!))");
		}
	}
return 1;
}

CMD:nem(playerid,params[])
{
	if(jInfo[playerid][Nem] == 1)
	{
		SendClientMessage(playerid,feher,"Nemed: {00FFFF}Férfi");
	}
	if(jInfo[playerid][Nem] == 2)
	{
		SendClientMessage(playerid,feher,"Nemed: {00FFFF}Nő");
	}
	return 1;
}

CMD:penztarca(playerid,params[])
{
	new penz[128];
	format(penz,sizeof(penz),"(({00FFFF}%d Ft{FFFFFF} van a tárcádban.))",jInfo[playerid][Penz]);
	SendClientMessage(playerid,feher,penz);
return 1;
}
