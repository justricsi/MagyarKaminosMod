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
	meret
}
new fInfo[100][FoldInfo];

public OnGameModeInit()
{
	mysql_log(LOG_ALL, LOG_TYPE_HTML);
	kapcs = mysql_connect("localhost", "root", "farmerrp", "");
	if(mysql_errno(kapcs) != 0) printf("MySQL hiba! Hibak�d: %d", mysql_errno(kapcs));
	mysql_tquery(kapcs, "SELECT * FROM `foldek`","FoldLoad");
	
	UsePlayerPedAnims();         			//Norm�l fut�s
	DisableInteriorEnterExits(); 			//Interior kikapcs
	EnableStuntBonusForAll(0);              //ugrat� p�nz kikapcs
	SetGameModeText("GazdaM�d 0.1");

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
    for(new a; JatekosInfo:a < JatekosInfo; a++) jInfo[playerid][JatekosInfo:a] = 0;    //Null�zzuk az enumjait
    GetPlayerName(playerid, jInfo[playerid][Nev], 25);                                  //Lek�rj�k a nev�t.
    if(strfind(jInfo[playerid][Nev], "_") == -1)                                        //Nem tartalmaz als�von�st.
    for(new a; a < strlen(jInfo[playerid][Nev]); a++) if(jInfo[playerid][Nev][a] == '_') jInfo[playerid][Nev][a] = ' ';//V�gigfutunk a nev�n. Ha az egyik karaktere '_', kicser�li ' '-re.
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
    if(sorok_szama == 0) ShowPlayerDialog(playerid, d_reg, DIALOG_STYLE_PASSWORD, "Regisztr�ci�", "{FFFFFF}�dv a szerveren!\nM�g nem regisztr�lt�l!\nK�rlek adj meg egy jelsz�t!", "Regisztr�l", "Kil�p");
    else ShowPlayerDialog(playerid, d_belep, DIALOG_STYLE_PASSWORD, "Bejelentkez�s", "{FFFFFF}�dv a szerveren!\n\nK�rlek add meg a jelszavad, amivel regisztr�lt�lt!", "Bel�p", "Kil�p");
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	mysql_format(kapcs, query, 384, "UPDATE jatekosok SET penz='%d',pont='%d' WHERE nev='%s'", jInfo[playerid][Penz],jInfo[playerid][Pont],jInfo[playerid][Nev]);
	mysql_tquery(kapcs, query);
	new szDisconnectReason[3][] =
    {
        "Timeout",
        "Exit",
        "Kick/Ban"
    };

    new msg[128];
    format(msg, sizeof(msg), "%s kil�pett a j�t�kb�l! (%s)", jInfo[playerid][Nev], szDisconnectReason[reason]);
    SendClientMessageToAll(feher, msg);
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
	ShowPlayerDialog(playerid,d_traktorBerles,DIALOG_STYLE_MSGBOX,"{289AD0}J�rm� b�rl�se","Szeretn�d kib�relni?\n\n{FF8040}40.000Ft/�ra","Igen","Nem");
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
	FoldPickup(playerid);		//itt h�vom meg, hogy mit csin�ljon ha bele�ll a pickupba
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
        case d_Foldek: Dialog_Fold(playerid,response,listitem);     //ez a dialog amit a pickup megjelen�t
		case d_FoldBerles: Dialog_FoldBerles(playerid,response);    //ez csak a b�rl�s men�pontja a f� dialognak
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
    SendClientMessage(playerid, zold, "Sikeresen regisztr�lt�l!");
    ShowPlayerDialog(playerid,d_varos,DIALOG_STYLE_LIST,"Kezd� v�rosok","PalominoCreek\nMontgomery\nBlueBerry\nFortCarson\nLasPayasadas\nBaySide\nAngelPine","V�laszt","M�gsem");
    return 1;
}

forward JatekosBelep(playerid);
public JatekosBelep(playerid)
{
    new sorok_szama = cache_get_row_count();
    if(sorok_szama == 0) return ShowPlayerDialog(playerid, d_belep, DIALOG_STYLE_PASSWORD, "Bejelentkez�s", "{FFFFFF}�dv a szerveren!\nK�rlek add meg a jelszavad, amivel regisztr�lt�lt!\n\n{FF0000}Hib�s jelsz�!", "Bel�p", "Kil�p");
    //Az elobb, ha hib�s volt a jelsz� visszat�rt�nk volna, sz�val innenztol ami lefut k�d, az m�r j� jelsz�val fut le:
    SendClientMessage(playerid, zold, "Sikeresen bejelentkezt�l!");
	jInfo[playerid][Nem] = cache_get_field_content_int(0, "neme",kapcs);
	jInfo[playerid][Penz] = cache_get_field_content_int(0, "penz",kapcs);
    jInfo[playerid][Pont] = cache_get_field_content_int(0, "pont",kapcs);
    
   	if(jInfo[playerid][Nem] == 1)
	{
		SetPlayerSkin(playerid,158);
	}else if(jInfo[playerid][Nem] == 2) SetPlayerSkin(playerid,198);
	ShowPlayerDialog(playerid,d_varos,DIALOG_STYLE_LIST,"Kezd� v�rosok","PalominoCreek\nMontgomery\nBlueBerry\nFortCarson\nLasPayasadas\nBaySide\nAngelPine","V�laszt","M�gsem");
    return 1;
}

forward FoldLoad();
public FoldLoad()
{
if(!cache_get_row_count()) return printf("cache_get_row_count returned false. Nincsennek bet�ltend� sorok.");
 	for(new i, j = cache_get_row_count(); i < j ; i++)
	{
	    fInfo[i][id] = cache_get_field_content_int(i,"id",kapcs);
		fInfo[i][X] = cache_get_field_content_float(i,"pickupX",kapcs);
		fInfo[i][Y] = cache_get_field_content_float(i,"pickupY",kapcs);
		fInfo[i][Z] = cache_get_field_content_float(i,"pickupZ",kapcs);
		fInfo[i][ar] = cache_get_field_content_int(i,"ar",kapcs);
		fInfo[i][meret] = cache_get_field_content_int(i,"meret",kapcs);
		fInfo[i][pickupID] = cache_get_field_content_int(i,"pickup",kapcs);
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
		SendClientMessage(playerid,feher,"Kib�relted egy napra ezt a f�ldet!");
	}
return 1;
}

Dialog_Fold(playerid,response,listitem)     //ez a f� dialog ebben van 3 opci�
{
if(!response) return 1;
switch(listitem)
{
	case 0:                                 //1. inform�ci� itt is ittvan a forciklus
	{
	    new foldMeret[128];
	    for(new i=0; i<FoldCount; i++)
	    {
	        if(i == melyikPickUp[playerid])
	        {
				SendClientMessage(playerid,feher,"|___________________Inform�ci�__________________|");
				format(foldMeret,sizeof(foldMeret),"|M�rete:____________%d. term�f�ld___________________|",fInfo[i][id]);
				SendClientMessage(playerid,feher,foldMeret);
				format(foldMeret,sizeof(foldMeret),"|M�rete:____________%d hekt�r___________________|",fInfo[i][meret]);
				SendClientMessage(playerid,feher,foldMeret);
				format(foldMeret,sizeof(foldMeret),"|M�rete:____________�ra: %d Ft___________________|",fInfo[i][ar]);
				SendClientMessage(playerid,feher,foldMeret);
				SendClientMessage(playerid,feher,"|_______________________________________________|");
			}
		}
	}
	case 1:                                 //2. B�rl�s
	{
	if(jInfo[playerid][Penz] < 900000) return SendClientMessage(playerid,piros,"((Nincs el�g p�nzed!))");
		ShowPlayerDialog(playerid,d_FoldBerles,DIALOG_STYLE_LIST,"B�rl�s","900.000 Ft/nap","Rendben","M�gsem");
	}
	case 2:                                 //3. V�s�rl�s �s itt is
	{
	    new foldAr[128];
	    for(new i=0; i<FoldCount; i++)
	    {
	        if(i == melyikPickUp[playerid])
	        {
			    format(foldAr,sizeof(foldAr),"�ra: %d Ft",fInfo[i][ar]);
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
            SendClientMessage(playerid,piros,"((Nincs el�g p�nzed!))");
		}else
	SendClientMessage(playerid,zold,"((Mostant�l 60 percig haszn�lhatod a traktort!))");
	jInfo[playerid][Penz] -= 40000;
	SetTimer("Berles",600000,false);
return 1;
}

forward Berles(playerid);
public Berles(playerid)
{
	RemovePlayerFromVehicle(playerid);
	SendClientMessage(playerid,piros,"((Lej�rt a j�rm� b�rl�se!))");
}

Dialog_Nem(playerid, response, inputtext[])
{
if(!response) return 1;
{
	printf("%d", strval(inputtext));
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
		if(jInfo[playerid][Nem] == 0) ShowPlayerDialog(playerid,d_nemek,DIALOG_STYLE_INPUT,"Karakter neme.","Adja meg a karakter nem�t!\nF�rfi 1-es vagy N� 2-es\n[csak a sz�mot add meg!]","J�v�hagy","M�gsem");
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
		if(jInfo[playerid][Nem] == 0) ShowPlayerDialog(playerid,d_nemek,DIALOG_STYLE_INPUT,"Karakter neme.","Adja meg a karakter nem�t!\nF�rfi 1-es vagy N� 2-es\n[csak a sz�mot add meg!]","J�v�hagy","M�gsem");
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
		if(jInfo[playerid][Nem] == 0) ShowPlayerDialog(playerid,d_nemek,DIALOG_STYLE_INPUT,"Karakter neme.","Adja meg a karakter nem�t!\nF�rfi 1-es vagy N� 2-es\n[csak a sz�mot add meg!]","J�v�hagy","M�gsem");
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
		if(jInfo[playerid][Nem] == 0) ShowPlayerDialog(playerid,d_nemek,DIALOG_STYLE_INPUT,"Karakter neme.","Adja meg a karakter nem�t!\nF�rfi 1-es vagy N� 2-es\n[csak a sz�mot add meg!]","J�v�hagy","M�gsem");
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
		if(jInfo[playerid][Nem] == 0) ShowPlayerDialog(playerid,d_nemek,DIALOG_STYLE_INPUT,"Karakter neme.","Adja meg a karakter nem�t!\nF�rfi 1-es vagy N� 2-es\n[csak a sz�mot add meg!]","J�v�hagy","M�gsem");
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
		if(jInfo[playerid][Nem] == 0) ShowPlayerDialog(playerid,d_nemek,DIALOG_STYLE_INPUT,"Karakter neme.","Adja meg a karakter nem�t!\nF�rfi 1-es vagy N� 2-es\n[csak a sz�mot add meg!]","J�v�hagy","M�gsem");
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
		if(jInfo[playerid][Nem] == 0) ShowPlayerDialog(playerid,d_nemek,DIALOG_STYLE_INPUT,"Karakter neme.","Adja meg a karakter nem�t!\nF�rfi 1-es vagy N� 2-es\n[csak a sz�mot add meg!]","J�v�hagy","M�gsem");
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
        if(strlen(inputtext) < 5 || strlen(inputtext) > 32) return ShowPlayerDialog(playerid, d_reg, DIALOG_STYLE_PASSWORD, "Regisztr�ci�", "{FFFFFF}�dv a szerveren!\nM�g nem regisztr�lt�l!\nK�rlek adj meg egy megjegyezhet� �s er�s jelsz�t!\n\n{FF0000}Jelszavadnak 5-32 karakter k�z�tt kell lennie!", "Regisztr�l", "Kil�p");
        mysql_format(kapcs, query, 256, "INSERT INTO jatekosok (nev,jelszo,penz,pont,neme) VALUES ('%e',SHA1('%e'),'0','0','0')", jInfo[playerid][Nev], inputtext);
        mysql_tquery(kapcs, query, "JatekosBeregelt", "d", playerid);
    }
return 1;
}

Dialog_Belepes(playerid, response, inputtext[])
{
	{
        if(!response) return Kick(playerid);
        if(strlen(inputtext) < 5 || strlen(inputtext) > 32) return ShowPlayerDialog(playerid, d_belep, DIALOG_STYLE_PASSWORD, "Bejelentkez�s", "{FFFFFF}�dv a szerveren!\nM�r regisztr�lt�l!\nK�rlek add meg a jelszavad, amivel regisztr�lt�lt�l!\n\n{FF0000}Jelszavadnak 5-32 karakter k�z�tt kell lennie!", "Bel�p", "Kil�p");
        mysql_format(kapcs, query, 256, "SELECT * FROM jatekosok WHERE nev='%e' AND jelszo=SHA1('%e')", jInfo[playerid][Nev], inputtext);
        mysql_tquery(kapcs, query, "JatekosBelep", "d", playerid);
    }
return 1;
}
//=============================================================================================
//==================================STOCK======================================================
//=============================================================================================
stock FoldPickup(playerid)                      //ezt h�vom meg az OnPlayerUpdate alatt
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
				format(string, sizeof(string), "%d. Term�f�ld", fInfo[i][id]);
				ShowPlayerDialog(playerid,d_Foldek,DIALOG_STYLE_LIST,string,"Inform�ci�\nB�rl�s\nV�s�rl�s","Rendben","M�gsem");
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
	if(sscanf(params, "ii",osszeg,foldmeret)) return SendClientMessage(playerid, lila, "Haszn�lata: /fold [�ra] [m�rete]");
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
	new rsz[50];
	format(rsz,sizeof(rsz),"{000000}%c%c%c-%i%i%i",(65+random(26)),(65+random(26)),(65+random(26)),random(10),random(10),random(10));
	SetVehicleNumberPlate(AddStaticVehicleEx(mID,pX+4,pY,pZ,pR,3,3,-1,0), rsz);
	AutoCount++;
	return 1;
}

CMD:kocsiszin(playerid,params[])
{
	new mID;
	new col1, col2;
	if(sscanf(params,"iii",mID,col1,col2)) return SendClientMessage(playerid,lila,"INFO: /kocsi [ID] [szin1] [szin2]");
	if(mID<400 || mID>611) return SendClientMessage(playerid,piros,"400-611-ig vannak csak kocsik!");
	if(col1<0 || col1>168 && col2<=0 || col2>168) return SendClientMessage(playerid,piros,"0-t�l 168-ig van sz�n!");

	new Float:pX,Float:pY,Float:pZ,Float:pR;
	GetPlayerPos(playerid,pX, pY, pZ);
	GetPlayerFacingAngle(playerid, pR);
	new rsz[50];
	format(rsz,sizeof(rsz),"{000000}%c%c%c-%i%i%i",(65+random(26)),(65+random(26)),(65+random(26)),random(10),random(10),random(10));
	SetVehicleNumberPlate(AddStaticVehicleEx(mID,pX-4,pY,pZ,pR,col1,col2,-1,1), rsz);
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
							SendClientMessage(playerid,zold,"((Vontatm�ny felakasztva!))");
						}
						else SendClientMessage(playerid,piros,"((Nincs a k�zeledben eszk�z!))");
					}
				}
			}else SendClientMessage(playerid,piros,"((Nem �lsz traktorban!))");
		}
	}
return 1;
}

CMD:nem(playerid,params[])
{
	if(jInfo[playerid][Nem] == 1)
	{
		SendClientMessage(playerid,feher,"Nemed: {00FFFF}F�rfi");
	}
	if(jInfo[playerid][Nem] == 2)
	{
		SendClientMessage(playerid,feher,"Nemed: {00FFFF}N�");
	}
	return 1;
}

CMD:penztarca(playerid,params[])
{
	new penz[128];
	format(penz,sizeof(penz),"(({00FFFF}%d Ft{FFFFFF} van a t�rc�dban.))",jInfo[playerid][Penz]);
	SendClientMessage(playerid,feher,penz);
return 1;
}

CMD:setskin(playerid,params[])
{
	new skinID;
    if(sscanf(params,"i",skinID)) return SendClientMessage(playerid,lila,"INFO: /setskin [skinID]");
	SetPlayerSkin(playerid, skinID);
	return 1;
}

CMD:fegyver(playerid,params[]){
	new weaponID;

    if(sscanf(params,"i",weaponID)) return SendClientMessage(playerid,feher,"Haszn�lat /fegyver [id]");
    if(weaponID<0 || weaponID>47) return SendClientMessage(playerid,piros,"1-47-ig vannak csak fegyverek!");
	GivePlayerWeapon(playerid, weaponID, 64);
	return 1;
}
