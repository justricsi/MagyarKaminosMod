// This is a comment
// uncomment the line below if you want to write a filterscript
#define FILTERSCRIPT

#include <a_samp>
#include <ZCMD>
#include <sscanf2>

#pragma tabsize 0

#define MAX_LABELS                       50
#define DEFAULT_LABEL_VIEW_THREW_OBJECTS 0
#define DEFAULT_LABEL_VIEW_DISTANCE      20.0
//============================= [Colors] =======================================
#define green                                                         0x00FF28FF
#define darkgreen                                                     0x5FB700FF
#define lightgreen                                                    0x23FF00FF
#define red                                                    		  0xFF0000FF
#define yellow                                                        0xF5FF00FF
#define darkyellow                                                    0xF5DE00FF
#define orange                                                        0xF5A300FF
#define darkblue                                                      0x0037FFFF
#define blue                                                          0x1400FFFF
#define lightblue                                                     0x00FFF0FF
#define grey                                                          0xB4B4B4FF
#define white                                                         0xF0F0F0FF
#define purple                                                        0x9C00AFFF
//=============================== [RRGGBB] =====================================
#define lgreen 														  "{6EF83C}"
#define lwhite 														  "{FFFFFF}"
#define lyellow                                                       "{FFFF22}"
#define lblue                                                         "{2255FF}"
#define lpink                                                         "{FF0077}"
#define lorange                                                       "{FF6622}"
#define lred                                                          "{FF0000}"
#define lgrey                                                         "{BEBEBE}"
#define lyellow2                                                      "{E1DE1C}"

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

main()
{
	print("\n----------------------------------");
	print(" Blank Gamemode by your name here");
	print("----------------------------------\n");
}

#endif

enum dialog{
	d_foablak,
	d_ujtext,
	d_textszerk,
	d_szovegcsere,
	d_tavcsere,
	d_szincsere
};

enum labelsinfo
{
	Text[256],
	Color,
	Float:POSX,
	Float:POSY,
 	Float:POSZ,
 	Float:Distance,
 	World
}
new Text3D:LInfo[MAX_LABELS][labelsinfo];


new Labelcount = 0;
new Text3D:LabelID[MAX_LABELS];

/*public OnGameModeInit()
{
	SetGameModeText("Blank Script");
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 34, 500, 0, 0, 0, 0);
	return 1;
}

public OnGameModeExit()
{
	return 1;
}*/

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerConnect(playerid)
{
	SendClientMessage(playerid,green,"Ebben a módban ingame lehet textlabelt hozzáadni a játékhoz.\nHasználd a /tlabel");
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
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

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
        case d_foablak: Dialog_Foablak(playerid, response, listitem);
        case d_ujtext: Dialog_Ujtextlabel(playerid, inputtext);
        case d_textszerk: Dialog_Textlabelszerk(playerid, response, listitem);
    }
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

Dialog_Foablak(playerid, response, listitem)
{
	if(!response) return 1;
	switch (listitem)
	{
	    case 0:
		{
		    ShowPlayerDialog(playerid,d_ujtext,DIALOG_STYLE_INPUT,"Új textlabel hozzáadása","Írdbe label szövegét!","Rendben","");
		}
		case 1:
		{
			ShowPlayerDialog(playerid,d_textszerk,DIALOG_STYLE_LIST,"Textlabel szerkeztése","Szöveg cseréje\nDraw distance állítás\nSzín csere","Rendben","");
		}
	}
return 1;
}

Dialog_Ujtextlabel(playerid, inputtext[])
{
	new Float:x,Float:y,Float:z,ID = Labelcount;
	GetPlayerPos(playerid,x,y,z);
	LabelID[ID] = Create3DTextLabel(inputtext,white,x,y,z,DEFAULT_LABEL_VIEW_DISTANCE,GetPlayerVirtualWorld(playerid),DEFAULT_LABEL_VIEW_THREW_OBJECTS);
	format(LInfo[ID][Text],10,"%s",inputtext);
	LInfo[ID][POSX] = x;
	LInfo[ID][POSY] = y;
	LInfo[ID][POSZ] = z;
	LInfo[ID][Distance] = DEFAULT_LABEL_VIEW_DISTANCE;
	LInfo[ID][World] = GetPlayerVirtualWorld(playerid);
	LInfo[ID][Color] = white;
	Labelcount++;
	SendClientMessage(playerid,orange,"[ ! ] Sikeres létrehozás!");
return 1;
}

Dialog_Textlabelszerk(playerid, response, listitem)
{
	if(!response) return 1;
	switch (listitem)
	{
	case 0:
		{
			ShowPlayerDialog(playerid,d_szovegcsere,DIALOG_STYLE_INPUT,"Textlabel szerkeztése","Írdbe label szövegét!","Rendben","");
		}
	case 1:
		{
			ShowPlayerDialog(playerid,d_tavcsere,DIALOG_STYLE_INPUT,"Távolság állítása","Lecserélheted a távolságot.","Rendben","");
		}
	case 2:
		{
            ShowPlayerDialog(playerid,d_szincsere,DIALOG_STYLE_LIST,"Textlabel színcseréje","{FF0000}Piros\n{FFFFFF}Fehér\n{6EF83C}Zöld\n{FFFF22}Citromsárga\n{FF6622}Narancssárga\n{2255FF}Kék\n{FF0077}Rózsaszín","Rendben","");
		}
	}
return 1;
}

CMD:tlabel(playerid,params[])
{
	ShowPlayerDialog(playerid,d_foablak,DIALOG_STYLE_LIST,"Textlabel szerkeztõ","Új text label\nText label szerkeztése","Ok","Mégsem");
	return 1;
}
