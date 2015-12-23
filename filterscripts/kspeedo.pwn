/**
* (C) Karagon 2012
* Use With Permission.
* Leave author credits.
*
* Licenses:
* This work is licensed under the Creative
* Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
* To view a copy of this license,
* visit http://creativecommons.org/licenses/by-nc-nd/3.0/
* or send a letter to
* Creative Commons,
* 444 Castro Street,
* Suite 900, Mountain View,
* California, 94041, USA.
*
* THIS SOFTWARE IS PROVIDED BY THE AUTHORS ''AS IS'' AND ANY EXPRESS
* OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
* ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE
* LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
* SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
* BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
* OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
* EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
#include <a_samp>
#include <ZCMD>
#include <sscanf2>

//Now, redefine MAX_PLAYERS for what you need:
#undef MAX_PLAYERS
#define MAX_PLAYERS 200 //Right now, it's for 200. If your server needs more, just put the number there.
#define WHITE 0xFFFFFFAA
#define GREY 0xAFAFAFAA
#define RED 0xFF0000AA
#define YELLOW 0xFFFF00FF
#define LIGHTBLUE 0x33CCFFAA
#define BLUE 0x0000FFFF
#define GREEN 0x33AA33AA
#define ORANGE 0xFF9900AA
#pragma tabsize 0

// Variables for the Text Draw.
//It's done in 4 text draws to make it easier to modify.
new Text:speedo1[MAX_PLAYERS];
new Text:speedo2[MAX_PLAYERS];
new Text:speedo3[MAX_PLAYERS];
new Text:speedo4[MAX_PLAYERS];

//Variables for the distance counter
new CarFuel[MAX_VEHICLES]; //Holds the fuel for each vehicle.
new Float:PlayerPos[3][MAX_PLAYERS]; //Holds the player's last posistion.
new PlayerTotalDistance[MAX_PLAYERS]; //Total player distance for each section they drive. (To reduce the fuel)
//For messaging:
new GotFuelMessage[MAX_PLAYERS];

//This is stuff that you can change.
#define DEF_GAS             	(100) //Default gas level for the vehicles in the server when the filterscript is loaded. (DEFAULT: 100)
#define DISTANCE            	(250) //Distance in which FUEL_INCREMENT will be removed from the fuel (DEFAULT: 250)
#define FUEL_INCREMENT      	(1) //The value that will be removed from the fuel when DISTANCE is met. (DEFAULT: 1)
#define TEXT_DRAW_FONT      	(2) //Font for the text draw. It's recomended that you not change this. (DEFAULT: 2)
#define TEXT_DRAW_X_FACTOR  	(0.4) // Font size X factor (DEFAULT: 0.4) (RECOMENDED NOT TO CHANGE)
#define TEXT_DRAW_Y_FACTOR  	(0.8) // Font size Y factor (DEFAULT: 0.8) (RECOMENDED NOT TO CHANGE)
#define EXIT_VEHICLE_ON_NO_GAS  (true) // If the player should exit the vehicle when the fuel is 0, set this true.
#define WARNING                 (2) // Number at which to send a warning to the player. (DEFAULT: 20)
#define WARNING_LIMIT           (10000) // Time to wait before sending another message about low fuel. (DEFAULT: 10000)

//Do not change anything past this point unless you are sure of what you are doing.
//Also, by doing this, you certify that you do not need help from Karagon.
//As he will not help you past this point.
#define dcmd(%1,%2,%3) if ((strcmp((%3)[1], #%1, true, (%2)) == 0) && ((((%3)[(%2) + 1] == 0) && (dcmd_%1(playerid, "")))||(((%3)[(%2) + 1] == 32) && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1



//The following array is a list of vehicle names.
new CarName[][] =
{
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel",
    "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
    "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
    "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection",
    "Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus",
    "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
    "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral",
    "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
    "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "Berkley's RC Van",
    "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale",
    "Oceanic","Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy",
    "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX",
    "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper",
    "Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking",
    "Blista Compact", "Police Maverick", "Boxvillde", "Benson", "Mesa", "RC Goblin",
    "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher", "Super GT",
    "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt",
    "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra",
    "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck", "Fortune",
    "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer",
    "Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent",
    "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo",
    "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite",
    "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratium",
    "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
    "Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper",
    "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400",
    "News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
    "Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "Police Car",
    "Police Car", "Police Car", "Police Ranger", "Picador", "S.W.A.T", "Alpha",
    "Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs", "Boxville",
    "Tiller", "Utility Trailer"
};

public OnFilterScriptInit()
{
	print("\n Justricsi sebessegmero es benzin rendszere");
	print("\n \t---- Betoltve ----");
	
	for (new i = 0; i <MAX_VEHICLES; i++) {
	    //Loop through all the vehicles and set their fuel levels at DEF_GAS
		CarFuel[i] = DEF_GAS;
	}
	for (new i = 0; i < MAX_PLAYERS; i++) {
		GotFuelMessage[i] = -1;
	}
	ManualVehicleEngineAndLights();
	return 1;
}

public OnFilterScriptExit()
{
	for ( new i = 0; i < MAX_PLAYERS; i++) {
	    //Hide all the text draws for the players
        TextDrawHideForPlayer(i, speedo1[i]);
	    TextDrawHideForPlayer(i, speedo2[i]);
	    TextDrawHideForPlayer(i, speedo3[i]);
	    TextDrawHideForPlayer(i, speedo4[i]);
	    TextDrawDestroy(speedo1[i]);
		TextDrawDestroy(speedo2[i]);
		TextDrawDestroy(speedo3[i]);
		TextDrawDestroy(speedo4[i]);
	}
	print("\n Justricsi sebessegmero es benzin rendszere");
	print("\n Kikapcsol....");
	
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	for ( new i = 0; i < MAX_PLAYERS; i++)
	{
        TextDrawHideForPlayer(i, speedo1[i]);
	    TextDrawHideForPlayer(i, speedo2[i]);
	    TextDrawHideForPlayer(i, speedo3[i]);
	    TextDrawHideForPlayer(i, speedo4[i]);
	    TextDrawDestroy(speedo1[i]);
		TextDrawDestroy(speedo2[i]);
		TextDrawDestroy(speedo3[i]);
		TextDrawDestroy(speedo4[i]);
	}
	return 1;
}


// #### Stocks ####
//Do not modify these.

//Gets the player's speed in KM/H
//Credits to whom who made it.
stock Float:GetPlayerSpeed(playerid, bool:Z = true) //km.h
{
    new Float:SpeedX, Float:SpeedY, Float:SpeedZ;
    new Float:Speed;
    if(IsPlayerInAnyVehicle(playerid)) GetVehicleVelocity(GetPlayerVehicleID(playerid), SpeedX, SpeedY, SpeedZ);
    else GetPlayerVelocity(playerid, SpeedX, SpeedY, SpeedZ);
    if(Z) Speed = floatsqroot(floatadd(floatpower(SpeedX, 2.0), floatadd(floatpower(SpeedY, 2.0), floatpower(SpeedZ, 2.0))));
    else Speed = floatsqroot(floatadd(floatpower(SpeedX, 2.0), floatpower(SpeedY, 2.0)));
    Speed = floatround(Speed * 100 * 1.61);
    return Speed;
}

//Damage color - Gets the color of the damage percentage.
//Credits to Me
stock DamageColor(Float: h) {
	new str[5];
	if (h <= 30)
		format(str, sizeof(str), "r");
	else if (h < 60)
	    format(str, sizeof(str), "y");
	else
	    format(str, sizeof(str), "g");
	return str;
}
//FuelColor - Gets the color of the fuel percentage
//Credits to me
stock FuelColor(vid) {
	new str[5];
	if (CarFuel[vid] <= 20)
	    format(str, sizeof(str), "r");
	else if (CarFuel[vid] < 40)
	    format(str, sizeof(str), "y");
	else
	    format(str, sizeof(str), "g");
	return str;
}

//Use of the distance formula, using 3D space.
//Credits to who made it.
stock GetDistance( Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2 )
{
    return floatround( floatsqroot( ( ( x1 - x2 ) * ( x1 - x2 ) ) + ( ( y1 - y2 ) * ( y1 - y2 ) ) + ( ( z1 - z2 ) * ( z1 - z2 ) ) ) ) ;
}


// #### Public Functions ####
// Do not edit this stuff unless you know what you're doing.
// I won't help you edit it either.

//We'll call OnPlayerUpdate for this. We're only doing this because it's a small amount of code to process
//And shouldn't lag the server. If you have lag issues, you should transfer it to a global loop in the server.
//Preferably, a 1-1.5 second loop. This will give the best result.
public OnPlayerUpdate(playerid) {
	if (IsPlayerInAnyVehicle(playerid)) {
	    new Float:vh, Float:s;
	    new vid = GetPlayerVehicleID(playerid),engine, lights, alarm, doors, bonnet, boot, objective;
	    new h, string[80];
	    //SetVehicleParamsEx( vid, 1, lights, alarm, doors, bonnet, boot, objective);
	    GetVehicleHealth(vid, vh);
	    h = floatround(vh) / 10;
	    format(string, sizeof(string), "Allapot: ~%s~%d \%", DamageColor(h), h); //55 -> Orange, 30 -> Red
	    TextDrawSetString(speedo2[playerid], string);

	    s = GetPlayerSpeed(playerid);
	    new ss = floatround(s);
	    format(string, sizeof(string), "Sebesseg: ~g~%d km/h", ss);
	    TextDrawSetString(speedo3[playerid], string);


	    new Float:x, Float:y, Float:z;
	    GetPlayerPos(playerid, x, y, z);
	    format(string, sizeof(string), "Benzin: ~%s~%d \%", FuelColor(vid), CarFuel[vid]);
	    TextDrawSetString(speedo4[playerid], string);
	    new distance = GetDistance(x, y, z, PlayerPos[0][playerid], PlayerPos[1][playerid], PlayerPos[2][playerid]);
	    PlayerPos[0][playerid] = x;
	    PlayerPos[1][playerid] = y;
	    PlayerPos[2][playerid] = z;

		PlayerTotalDistance[playerid] += distance;
		if (PlayerTotalDistance[playerid] > DISTANCE) {
			if(GetVehicleModel(vid) != 481 && GetVehicleModel(vid) != 509 && GetVehicleModel(vid) != 510){
				CarFuel[vid] -= FUEL_INCREMENT;
			}
			PlayerTotalDistance[playerid] = 0;
		}
		if (CarFuel[vid] < WARNING) {
			if ( (GetTickCount() - GotFuelMessage[playerid]) > WARNING_LIMIT) {
				GotFuelMessage[playerid] = GetTickCount();
				SendClientMessage(playerid, -1, "Fogytán a benzin, menj tankolni!");
			}
		}
		if (CarFuel[vid] == 0)
		{
			GetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective);
   			SetVehicleParamsEx(vid, 0, lights, alarm, doors, bonnet, boot, objective), SendClientMessage(playerid, -1, "Elfogyott a benzin!");
			/*#if defined EXIT_VEHICLE_ON_NO_GAS
			SendClientMessage(playerid, -1, "Elfogyott a benzin!");
			RemovePlayerFromVehicle(playerid);
			#endif*/
		}
	}
	return 1;
}

// We will use OnPlayerStateChange to detect if the player is in a vehicle.
// Here, the text draw will be created and placed for the player.
public OnPlayerStateChange(playerid, newstate, oldstate) {
	//if ( (newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER) && oldstate == PLAYER_STATE_ONFOOT ) {
		if (newstate == PLAYER_STATE_DRIVER && oldstate == PLAYER_STATE_ONFOOT ) {
		new str[50];
		new vid = GetPlayerVehicleID(playerid);
		format(str, sizeof(str), "Jarmu: ~g~%s", CarName[GetVehicleModel(vid)-400]);
		speedo1[playerid] = TextDrawCreate(470.0, 390.0, " ");
		TextDrawSetString(speedo1[playerid], str);
		TextDrawSetShadow(speedo1[playerid], false);
		TextDrawSetOutline(speedo1[playerid], 1);
		TextDrawLetterSize(speedo1[playerid], TEXT_DRAW_X_FACTOR, TEXT_DRAW_Y_FACTOR);
		TextDrawSetProportional(speedo1[playerid], 1);
		TextDrawFont(speedo1[playerid], TEXT_DRAW_FONT);
		TextDrawShowForPlayer(playerid, speedo1[playerid]);

		new Float:vh;
		GetVehicleHealth(vid, vh);
		new h = floatround(vh) / 10;
		format(str, sizeof(str), "Allapot: ~g~%d \%", h);
		speedo2[playerid] = TextDrawCreate(470.0, 400.0, " ");
		TextDrawSetString(speedo2[playerid], str);
		TextDrawSetShadow(speedo2[playerid], false);
		TextDrawSetOutline(speedo2[playerid], 1);
		TextDrawLetterSize(speedo2[playerid], TEXT_DRAW_X_FACTOR, TEXT_DRAW_Y_FACTOR);
		TextDrawSetProportional(speedo2[playerid], 1);
		TextDrawFont(speedo2[playerid], TEXT_DRAW_FONT);
		TextDrawShowForPlayer(playerid, speedo2[playerid]);


		new Float:s = GetPlayerSpeed(playerid);
		new ss = floatround(s);
		format(str, sizeof(str), "Sebesseg: ~%s~%d km/h", DamageColor(h), ss);
		speedo3[playerid] = TextDrawCreate(470.0, 410.0, " ");
		TextDrawSetString(speedo3[playerid], str);
		TextDrawSetShadow(speedo3[playerid], false);
		TextDrawSetOutline(speedo3[playerid], 1);
		TextDrawLetterSize(speedo3[playerid], TEXT_DRAW_X_FACTOR, TEXT_DRAW_Y_FACTOR);
		TextDrawSetProportional(speedo3[playerid], 1);
		TextDrawFont(speedo3[playerid], TEXT_DRAW_FONT);
		TextDrawShowForPlayer(playerid, speedo3[playerid]);
		if(GetVehicleModel(vid) != 481 && GetVehicleModel(vid) != 509 && GetVehicleModel(vid) != 510)
		{
			format(str, sizeof(str), "Benzin: ~%s~%d \%", FuelColor(vid), CarFuel[vid]);
			speedo4[playerid] = TextDrawCreate(470.0, 420.0, " ");
			TextDrawSetString(speedo4[playerid], str);
			TextDrawSetShadow(speedo4[playerid], false);
			TextDrawSetOutline(speedo4[playerid], 1);
			TextDrawLetterSize(speedo4[playerid], TEXT_DRAW_X_FACTOR, TEXT_DRAW_Y_FACTOR);
			TextDrawSetProportional(speedo4[playerid], 1);
			TextDrawFont(speedo4[playerid], TEXT_DRAW_FONT);
			TextDrawShowForPlayer(playerid, speedo4[playerid]);
		}

		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		PlayerPos[0][playerid] = x;
		PlayerPos[1][playerid] = y;
		PlayerPos[2][playerid] = z;
	}
	//if (newstate == PLAYER_STATE_ONFOOT && ( oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_ONFOOT ) ) {
	if (newstate == PLAYER_STATE_ONFOOT && oldstate == PLAYER_STATE_DRIVER )
	{
	    TextDrawHideForPlayer(playerid, speedo1[playerid]);
	    TextDrawHideForPlayer(playerid, speedo2[playerid]);
	    TextDrawHideForPlayer(playerid, speedo3[playerid]);
	    TextDrawHideForPlayer(playerid, speedo4[playerid]);
	}
	return 1;
}

//Player command text
//If you wish to use this, DO NOT REMOVE THE FOLLOWING.
/*public OnPlayerCommandText(playerid, cmdtext[]) {
	dcmd(speedocredits, 13, cmdtext);
	return 0;
}

dcmd_speedocredits(playerid, params[]) {
	#pragma unused params
	SendClientMessage(playerid, -1, "*Speedometer created by Karagon (c) 2012");
	return 1;
}*/

public OnPlayerConnect(playerid) {
	GotFuelMessage[playerid] = -1;
	return 1;
}

CMD:tankol(playerid,params[])
{
new vid = GetPlayerVehicleID(playerid);
new benzin;
new bstring[128];
	if(IsPlayerInAnyVehicle(playerid))
	{
	    if(GetVehicleModel(vid) != 481 && GetVehicleModel(vid) != 509 && GetVehicleModel(vid) != 510)
	    {
			if(IsPlayerInRangeOfPoint(playerid, 10.0,2116.1753,919.9009,10.8168) || IsPlayerInRangeOfPoint(playerid, 10.0,2639.0347,1106.4211,10.8145) ||
			IsPlayerInRangeOfPoint(playerid, 10.0,2202.4346,2473.9463,10.8035) || IsPlayerInRangeOfPoint(playerid, 10.0,2147.3462,2748.0212,10.8098) ||
			IsPlayerInRangeOfPoint(playerid, 10.0,1596.6428,2198.7942,10.8044) || IsPlayerInRangeOfPoint(playerid, 10.0,615.3072,1689.8611,6.9801))
			{
				if(CarFuel[vid] == 100) return SendClientMessage(playerid,RED, "Tele a tank!");
				if(sscanf(params,"i",benzin)) return SendClientMessage(playerid,YELLOW,"Használat /tankol [mennyiség]");
					if(CarFuel[vid]+benzin <= 100)
					{
						CarFuel[vid] += benzin;
						GetPlayerMoney(GivePlayerMoney(playerid, -benzin*450));
						format(bstring, sizeof(bstring),"Megtankoltad a járművet! Ára: %dFt volt.",benzin*450);
						SendClientMessage(playerid,ORANGE, bstring);
					}
					else
					{
					    new tankolnikell = benzin-(CarFuel[vid]+benzin-100);
					    CarFuel[vid] += tankolnikell;
					    GetPlayerMoney(GivePlayerMoney(playerid, -tankolnikell*450));
						format(bstring, sizeof(bstring),"Megtankoltad a járművet! Ára: %dFt volt.",tankolnikell*450);
						SendClientMessage(playerid,ORANGE, bstring);
					}
			}else SendClientMessage(playerid,RED, "Nem vagy benzinkúton!");
		}else SendClientMessage(playerid,RED,"Biciklit nem lehet tankolni!");
	}else SendClientMessage(playerid,RED, "Nem ülsz járműben!");
return 1;
}
