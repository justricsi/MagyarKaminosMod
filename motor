/* ---------------------------------- */
// By: KimGuan
// Release Date: November 19,2013
/* ---------------------------------- */
// Includes
#include <a_samp>
#include <zcmd>
/* ---------------------------------- */

/* ---------------------------------- */
// Defines / Variables
new Engine[MAX_VEHICLES];
new Lights[MAX_VEHICLES];
/* ---------------------------------- */

/* ---------------------------------- */
// Color Defines
#define COLOR_AQUA        0x7CFC00AA
#define COLOR_GREY        0xAFAFAFAA
#define COLOR_GREEN 	  0x33AA33AA
#define COLOR_BRIGHTRED   0xFF0000AA
#define COLOR_DARKRED 	  0xC60000FF
#define COLOR_YELLOW 	  0xFFFF00AA
/* ---------------------------------- */

public OnFilterScriptInit()
{
    ManualVehicleEngineAndLights();
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	Engine[vehicleid] = 0;
	Lights[vehicleid] = 0;
	return 1;
}

CMD:carengine(playerid, params[])
{
    if(strcmp(params,"on",true) == 0)
    {
    	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    	{
			new Vehicle = GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective;
			GetVehicleParamsEx(Vehicle, engine, lights, alarm, doors, bonnet, boot, objective);
			SendClientMessage(playerid, COLOR_YELLOW, "You have turned your engine >{FFFFFF} ON");
			Engine[Vehicle] = 1, SetVehicleParamsEx(Vehicle, 1, lights, alarm, doors, bonnet, boot, objective);
		}
	}
	if(strcmp(params,"off",true) == 0)
	{
		 if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    	{
			new Vehicle = GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective;
			GetVehicleParamsEx(Vehicle, engine, lights, alarm, doors, bonnet, boot, objective);
			SendClientMessage(playerid, COLOR_YELLOW, "You have turned your engine >{FFFFFF} OFF");
			Engine[Vehicle] = 0, SetVehicleParamsEx(Vehicle, 0, lights, alarm, doors, bonnet, boot, objective);
		}
	}
	return 1;
}

CMD:carlights(playerid, params[])
{
    if(strcmp(params,"on",true) == 0)
    {
    	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    	{
			new Vehicle = GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective;
			GetVehicleParamsEx(Vehicle, engine, lights, alarm, doors, bonnet, boot, objective);
			SendClientMessage(playerid, COLOR_YELLOW, "You have turned your lights >{FFFFFF} ON");
			Lights[Vehicle] = 1, SetVehicleParamsEx(Vehicle, engine, 1, alarm, doors, bonnet, boot, objective);
		}
	}
	if(strcmp(params,"off",true) == 0)
	{
		 if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    	{
			new Vehicle = GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective;
			GetVehicleParamsEx(Vehicle, engine, lights, alarm, doors, bonnet, boot, objective);
			SendClientMessage(playerid, COLOR_YELLOW, "You have turned your lights >{FFFFFF} OFF");
			Lights[Vehicle] = 0, SetVehicleParamsEx(Vehicle, engine, 0, alarm, doors, bonnet, boot, objective);
		}
	}
	return 1;
}
