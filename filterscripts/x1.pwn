/* SA:MP PAWN Debug -
 *  Debugging filterscript used
 *  for creation of gamemode.
 *
 *  Simon Campbell
 *  10/03/2007, 6:31pm
 *
 *  17/11/2011
 *    Updated to 0.5d which supports SA:MP 0.3d
*/

//==============================================================================

#include <a_samp>
#define SSCANF_NO_NICE_FEATURES
#include "../../include/sscanf2.inc"
#include "../../include/pawncmd.inc"
#include "../../include/strlib.inc"
#include "../../include/foreach.inc"
#include "../../include/FCNPC.inc"

//==============================================================================

#define SSCANF_NO_NICE_FEATURES

#define MAX_STRING 20
#define DIALOG_TIPOSX1 1
#define DIALOG_TIPOSX1_2 2
#define DIALOG_TIPOSX1_3 3
#define DIALOG_X1 4
#define DIALOG_X1_2 5
#define DIALOG_X1_3 6
#define rBox1      5452 // Cuidado conflitos.

#pragma warning disable 239

//Textdraws
new CounterCountdown, CounterDuel, timeId, timeId2;

//==============================================================================

new
    pConvidou = -1,
    pConvidouNome[MAX_PLAYER_NAME],
    pDesafiado = -1,
    pDesafiadoNome[MAX_PLAYER_NAME],
//Vida e colete
    Float:vida,
    Float:colete,
	vConvidou,
	cConvidou,
	vDesafiado,
	cDesafiado,
//Valores do x1
    Xocupado,
    BlockDuelo = 1,
    x1colete = 1,
    gtipoX1[144],
	arma[200],
	texto[1024],
	texto2[1024],
 	TempoSpawn[MAX_PLAYERS],
	TempoMinutos,
	Minutos,
	Segundos,
	Text:TempoRestante = Text:INVALID_TEXT_DRAW,
    Text:dMinutos = Text:INVALID_TEXT_DRAW,
//Valores do dialog
    armas[35] = false,
//Valores de funcoes criadas
	estado
;


enum ArmaInfo {
    ArmaID,         // ID da arma
    ArmaNome[50],   // Nome da arma
    bool:ArmaEstado          // Ativado/Desativado 1/0
};

new Armas[][ArmaInfo] = {
    {9,  "Chainsaw (Motoserra)", 0},
    {23, "Silenced Pistol", 0},
    {22, "Pistol", 0},
    {24, "Desert Eagle", 0},
    {25, "Shotgun", 0},
    {26, "Sawn-off Shotgun", 0},
    {27, "Combat Shotgun", 0},
    {32, "Tec-9", 0},
    {28, "UZI", 0},
    {29, "MP5", 0},
    {30, "AK-47", 0},
    {31, "M4", 0},
    {33, "Rifle", 0},
    {34, "Sniper Rifle", 0},
    {18, "Molotov Cocktail", 0},
    {16, "Frag Grenade", 0}
};

// Matriz das armas x1
new PlayerArmas[MAX_PLAYERS][sizeof Armas][ArmaInfo];

enum Jogadores {
    idConvidou,
    idDesafiado,
    nomeConvidou[MAX_PLAYER_NAME],
    nomeDesafiado[MAX_PLAYER_NAME],
    tipoX1
}

//Matriz de jogadores x1
new mJogadores[MAX_PLAYERS][Jogadores];


CMD:resetx1(playerid)
{
   resetX1(playerid);
   SendClientMessage(playerid, 0xFF55FF55, "Os valores do x1 foram resetados.");
}

CMD:fecharx1(playerid)
{
if (BlockDuelo != 1){
   BlockDuelo = 1;
   SendClientMessageToAll(0xFF55FF55, "Os duelos x1 foram bloqueados.");
} else {
	SendClientMessage(playerid, 0xFF55FF55, "O x1 j� est� fechado.");
}
}

CMD:abrirx1(playerid)
{
if (BlockDuelo != 0){

   BlockDuelo = 0;
   SendClientMessageToAll(0xFF55FF55, "Os duelos x1 foram liberados. Use /x1 id");
} else {
	SendClientMessage(playerid, 0xFF55FF55, "O x1 j� est� aberto.");
}
}



CMD:tiposx1(playerid)
{
   ShowPlayerDialog(playerid, DIALOG_TIPOSX1, DIALOG_STYLE_LIST, "Tipos X1", "RUN\nWALK\n{FFFF00}Armas individuais\nMinigun", "Fechar", #);
}



CMD:x1(playerid, params[]){
	new desafiado;

	//Verifica??es
	if(BlockDuelo == 1) return SendClientMessage(playerid, -1, "{FFFF00}[ERRO] {FF0000}O sistema de X1 est� desativado pelo administrador.");
	//if (Xocupado == 1) return SendClientMessage(playerid, 0xA9A9A9AA, "[INFO] O x1 j? est? ocupado. Aguarde at? terminar.");
	if (sscanf(params, "d", desafiado)) return SendClientMessage(playerid, 0xA9A9A9AA, "[ERRO] Insira um ID de jogador v�lido.");
	//if (desafiado == playerid) return SendClientMessage(playerid, 0xA9A9A9AA, "[ERRO] N?o pode duelar com voc? mesmo.");
	if(!IsPlayerConnected(desafiado)) return SendClientMessage(playerid, 0xA9A9A9AA, "[ERRO] Jogador offline.");
	//if(!IsPlayerSpawned(playerid)) return SendClientMessage(playerid, -1, "{FFFF00}[ERRO] {FF0000}Voc? n?o nasceu");

	mJogadores[playerid][idConvidou] = playerid;
	mJogadores[playerid][idDesafiado] = desafiado;

	GetPlayerName(playerid, mJogadores[playerid][nomeConvidou], sizeof(mJogadores));
	GetPlayerName(mJogadores[playerid][idDesafiado], mJogadores[playerid][nomeDesafiado], sizeof(mJogadores));

    //dialog escolha de arma + premio (1000 a 20k)
    ShowPlayerDialog(playerid, DIALOG_X1, DIALOG_STYLE_LIST, "Tipos X1", "RUN\nWALK\n{FFFF00}Armas individuais\nArmas personalizadas", "Pr�ximo", "Cancelar x1");

	return 1;
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]){
	new textoX1;

	if(dialogid == DIALOG_TIPOSX1){

	switch(listitem){
        case 2:
		{
		texto = "";
		strcat(texto, "X1  - Armas individuais.\n\n\
		~> Arma corpo a corpo\n\
		Chainsaw (Motoserra)\n\
		\n\
		~> Arma pistola\n\
        Silenced Pistol\n\
		Pistol\n\
		Desert Eagle\n\
		\n\
		~> Arma espingarda\n\
		Shotgun\n\
		Sawn-off Shotgun\n\
		Combat Shotgun\n\
		\n\
		~> Arma Submetralhadora\n\
		Tec-9\n\
		Micro SMG\n\
		SMG\n\
		\n\
		~> Arma de assalto\n\
		AK-47\n\
		M4\n\
		\n\
		~> Arma de sniper\n\
        Sniper Rifle\n\
        Rifle\n\
		\n\
		~> Explosivos\n\
		Molotov Cocktail\n\
		Frag Grenade");
		ShowPlayerDialog(playerid, DIALOG_TIPOSX1_2, DIALOG_STYLE_MSGBOX, "Tipos de X1", texto, "Voltar", "Cancelar");


		}
   }
	return 1;
   }

   if(dialogid == DIALOG_TIPOSX1_2 || dialogid == DIALOG_TIPOSX1_3){
        if(response){
        ShowPlayerDialog(playerid, DIALOG_TIPOSX1, DIALOG_STYLE_LIST, "Tipos X1", "RUN\nWALK\n{FFFF00}Armas individuais\nArmas personalizadas", "Fechar", #);

		return 1;
        } else {
        resetArmas(playerid);
        return 1;
        }
   }



if(dialogid == DIALOG_X1){
if (response) {
    switch(listitem){
        case 0:{
        format(mJogadores[playerid][tipoX1], 15, "run");
		duelo(playerid);
		}
        case 1:{
        format(mJogadores[playerid][tipoX1], 15, "walk");
		duelo(playerid);
		}
        case 2:{
        format(mJogadores[playerid][tipoX1], 15, "individual");
		texto2 = "";
		strcat(texto2, "{FF00FF}Chainsaw (Motoserra)\n\
        {FFFFFF}Silenced Pistol\n\
		{FFFFFF}Pistol\n\
		{FFFFFF}Desert Eagle\n\
		{FFFF00}Shotgun\n\
		{FFFF00}Sawn-off Shotgun\n\
		{FFFF00}Combat Shotgun\n\
		{00FF00}Tec-9\n\
		{00FF00}UZI\n\
		{00FF00}MP5\n\
		{00FFFF}AK-47\n\
		{00FFFF}M4\n\
        {558099}Rifle\n\
		{558099}Sniper Rifle\n\
		{505050}Molotov Cocktail\n\
		{505050}Frag Grenade");
		ShowPlayerDialog(playerid, DIALOG_X1_2, DIALOG_STYLE_TABLIST, "Tipos de armas", texto2, "Duelo", "Cancelar x1");
		}
		//dialog armas personalizadas: ativado/desativado
	    case 3:{
		format(mJogadores[playerid][tipoX1], 15, "personalizado");
		armasPers(playerid);

		}
   }
}
    return 1;
}

if(dialogid == DIALOG_X1_2){
	if (response){
		switch (listitem){
		case 0: {  PlayerArmas[playerid][0][ArmaEstado] = true; }
		case 1: {  PlayerArmas[playerid][1][ArmaEstado] = true; }
		case 2: {  PlayerArmas[playerid][2][ArmaEstado] = true; }
		case 3: {  PlayerArmas[playerid][3][ArmaEstado] = true; }
		case 4: {  PlayerArmas[playerid][4][ArmaEstado] = true; }
		case 5: {  PlayerArmas[playerid][5][ArmaEstado] = true; }
		case 6: {  PlayerArmas[playerid][6][ArmaEstado] = true; }
		case 7: {  PlayerArmas[playerid][7][ArmaEstado] = true; }
		case 8: {  PlayerArmas[playerid][8][ArmaEstado] = true; }
		case 9: {  PlayerArmas[playerid][9][ArmaEstado] = true; }
		case 10: { PlayerArmas[playerid][10][ArmaEstado] = true; }
		case 11: { PlayerArmas[playerid][11][ArmaEstado] = true; }
		case 12: { PlayerArmas[playerid][12][ArmaEstado] = true; }
		case 13: { PlayerArmas[playerid][13][ArmaEstado] = true; }
		case 14: { PlayerArmas[playerid][14][ArmaEstado] = true; }
		case 15: { PlayerArmas[playerid][15][ArmaEstado] = true; }

		}

	duelo(playerid);
	} else {
		resetArmas(playerid);
	}

return 1;
}

 // L�gica para verificar se o mesmo tipo de arma pode ser ativada
if (dialogid == DIALOG_X1_3){
if (response){
	switch(listitem){
		case 0: {PlayerArmas[playerid][0][ArmaEstado] = !PlayerArmas[playerid][0][ArmaEstado];armasPers(playerid);}
//(pistolas)
		case 1: {
        PlayerArmas[playerid][2][ArmaEstado] = false;
        PlayerArmas[playerid][3][ArmaEstado] = false;
		PlayerArmas[playerid][1][ArmaEstado] = !PlayerArmas[playerid][1][ArmaEstado];armasPers(playerid);
		}
		case 2: {
		PlayerArmas[playerid][1][ArmaEstado] = false;
        PlayerArmas[playerid][3][ArmaEstado] = false;
		PlayerArmas[playerid][2][ArmaEstado] = !PlayerArmas[playerid][2][ArmaEstado];armasPers(playerid);
		}
		case 3: {
		PlayerArmas[playerid][1][ArmaEstado] = false;
        PlayerArmas[playerid][2][ArmaEstado] = false;
		PlayerArmas[playerid][3][ArmaEstado] = !PlayerArmas[playerid][3][ArmaEstado];armasPers(playerid);
		}
//(shotguns)
		case 4: {
		PlayerArmas[playerid][5][ArmaEstado] = false;
        PlayerArmas[playerid][6][ArmaEstado] = false;
		PlayerArmas[playerid][4][ArmaEstado] = !PlayerArmas[playerid][4][ArmaEstado];armasPers(playerid);
		}
		case 5: {
		PlayerArmas[playerid][4][ArmaEstado] = false;
        PlayerArmas[playerid][6][ArmaEstado] = false;
		PlayerArmas[playerid][5][ArmaEstado] = !PlayerArmas[playerid][5][ArmaEstado];armasPers(playerid);
		}
		case 6: {
		PlayerArmas[playerid][4][ArmaEstado] = false;
        PlayerArmas[playerid][5][ArmaEstado] = false;
		PlayerArmas[playerid][6][ArmaEstado] = !PlayerArmas[playerid][6][ArmaEstado];armasPers(playerid);
		}
//(metrelhadoras)
		case 7: {
		PlayerArmas[playerid][8][ArmaEstado] = false;
        PlayerArmas[playerid][9][ArmaEstado] = false;
		PlayerArmas[playerid][7][ArmaEstado] = !PlayerArmas[playerid][7][ArmaEstado];armasPers(playerid);
		}
		case 8: {
		PlayerArmas[playerid][7][ArmaEstado] = false;
        PlayerArmas[playerid][9][ArmaEstado] = false;
		PlayerArmas[playerid][8][ArmaEstado] = !PlayerArmas[playerid][8][ArmaEstado];armasPers(playerid);
		}
		case 9: {
		PlayerArmas[playerid][7][ArmaEstado] = false;
        PlayerArmas[playerid][8][ArmaEstado] = false;
		PlayerArmas[playerid][9][ArmaEstado] = !PlayerArmas[playerid][9][ArmaEstado];armasPers(playerid);
		}
//(ak47 e m4)
		case 10: {
		PlayerArmas[playerid][11][ArmaEstado] = false;
		PlayerArmas[playerid][10][ArmaEstado] = !PlayerArmas[playerid][10][ArmaEstado];armasPers(playerid);
		}
		case 11: {
		PlayerArmas[playerid][10][ArmaEstado] = false;
		PlayerArmas[playerid][11][ArmaEstado] = !PlayerArmas[playerid][11][ArmaEstado];armasPers(playerid);
		}
//(rifles)
		case 12: {
		PlayerArmas[playerid][13][ArmaEstado] = false;
		PlayerArmas[playerid][12][ArmaEstado] = !PlayerArmas[playerid][12][ArmaEstado];armasPers(playerid);
		}
		case 13: {
		PlayerArmas[playerid][12][ArmaEstado] = false;
		PlayerArmas[playerid][13][ArmaEstado] = !PlayerArmas[playerid][13][ArmaEstado];armasPers(playerid);
		}
//(especiais)
		case 14: {
		PlayerArmas[playerid][15][ArmaEstado] = false;
		PlayerArmas[playerid][14][ArmaEstado] = !PlayerArmas[playerid][14][ArmaEstado];armasPers(playerid);
		}
		case 15: {
		PlayerArmas[playerid][14][ArmaEstado] = false;
		PlayerArmas[playerid][15][ArmaEstado] = !PlayerArmas[playerid][15][ArmaEstado];armasPers(playerid);
		}
		//Iniciar x1
		case 16: {
		duelo(playerid);
		}
	}
} else {
	resetArmas(playerid);
}


}

/*==============================================================================
Aceitar ou nao o duelo x1
==============================================================================*/

if(dialogid == rBox1) {
  // ACEITOU O DUELO

    if(response) {
    Xocupado = 1;
		//if (Xocupado == 1) return SendClientMessage(pConvidou, 0xA9A9A9AA, "[INFO] O x1 j� est� ocupado. Aguarde at� terminar.");
        SendClientMessageToAll(0x1357FFFF, sprintf("*************** DUELO X1 ***************"));
        SendClientMessageToAll(0x1357FFFF, sprintf("| [X1 %s] O jogador %s aceitou o x1 de %s.", gtipoX1, pDesafiadoNome, pConvidouNome));
        SendClientMessageToAll(0x1357FFFF, sprintf("| [Armas] %s", arma));

	//Jogador convidou
	SetPlayerPos(pConvidou, -1415.230468, 1246.040283, 1040.3010);
    SetPlayerInterior(pConvidou, 16);
    TogglePlayerControllable(pConvidou, false);
   	SetPlayerFacingAngle(pConvidou, 87.003707);
    ResetPlayerWeapons(pConvidou);
    SetPlayerTeam(pConvidou, 255);
   	SetPlayerHealth(pConvidou, 100);
   	SetPlayerTeam(pDesafiado, 254);

	//Jogador desafiado
    SetPlayerPos(pDesafiado, -1380.088745, 1245.889404, 1040.3010);
    SetPlayerInterior(pDesafiado, 16);
    TogglePlayerControllable(pDesafiado, false);
   	SetPlayerFacingAngle(pDesafiado, 134.655395);
    ResetPlayerWeapons(pDesafiado);
    SetPlayerTeam(pDesafiado, 255);
   	SetPlayerHealth(pDesafiado, 100);
   	SetPlayerTeam(pDesafiado, 255);

   	if(x1colete == 1){
	SetPlayerArmour(pConvidou, 100);
	SetPlayerArmour(pDesafiado, 100);
    }


	if (strcmpEx(gtipoX1, "run") == 0){
		GivePlayerWeapon(pConvidou, 22, 1000);
		GivePlayerWeapon(pConvidou, 26, 1000);
		GivePlayerWeapon(pConvidou, 32, 1000);
		GivePlayerWeapon(pDesafiado, 22, 1000);
		GivePlayerWeapon(pDesafiado, 26, 1000);
		GivePlayerWeapon(pDesafiado, 32, 1000);
	}
	if (strcmpEx(gtipoX1, "walk") == 0){
		GivePlayerWeapon(pConvidou, 24, 1000);
		GivePlayerWeapon(pConvidou, 25, 1000);
		GivePlayerWeapon(pConvidou, 29, 1000);
		GivePlayerWeapon(pConvidou, 30, 1000);
		GivePlayerWeapon(pConvidou, 34, 1000);
		GivePlayerWeapon(pDesafiado, 24, 1000);
		GivePlayerWeapon(pDesafiado, 25, 1000);
		GivePlayerWeapon(pDesafiado, 29, 1000);
		GivePlayerWeapon(pDesafiado, 30, 1000);
		GivePlayerWeapon(pDesafiado, 34, 1000);
	}
	if (strcmpEx(gtipoX1, "individual") == 0){
		darArmas();
	}
	if (strcmpEx(gtipoX1, "personalizado") == 0){
  		darArmas();
	}

    CounterCountdown = 4;
    timeId = SetTimer("count_x1", 1000, true);
    TextDrawShowForPlayer(pDesafiado, TempoRestante);
    TextDrawShowForPlayer(pConvidou, TempoRestante);

    return 1;

	} else {
        SendClientMessage(pConvidou, 0xA9A9A9AA, "[INFO] O jogador n�o aceitou o duelo.");
        resetArmas(playerid);
    }
}

  return 1;
}


/*==============================================================================
CALLBACKS CRIADAS
==============================================================================*/


public OnFilterScriptInit()
{

//Objects////////////////////////////////////////////////////////////////
new tmpobjid;
tmpobjid = CreateObject(18843, -1396.596801, 1245.939086, 1010.615295, 0.000000, 0.000000, 0.000000, 300.00);
SetObjectMaterial(tmpobjid, 0, 1419, "break_fence3", "CJ_FRAME_Glass", 0x00000000);

tmpobjid = CreateObject(19481, -1396.783691, 1216.280883, 1046.297729, 0.000000, 0.000000, 450.000000, 300.00);
SetObjectMaterialText(tmpobjid, "{FFA500}Siga Bem Caminhoneiro", 0, 120, "Engravers MT", 30, 1, 0x00000000, 0x00000000, 1);
tmpobjid = CreateObject(19481, -1396.783691, 1276.280883, 1046.297729, 0.000000, 0.000000, 270.000000, 300.00);
SetObjectMaterialText(tmpobjid, "{FFA500}Siga Bem Caminhoneiro", 0, 120, "Engravers MT", 30, 1, 0x00000000, 0x00000000, 1);
tmpobjid = CreateObject(19481, -1396.903808, 1276.370971, 1046.437866, 0.000000, 0.000000, 270.000000, 300.00);
SetObjectMaterialText(tmpobjid, "{000000}Siga Bem Caminhoneiro", 0, 120, "Engravers MT", 30, 1, 0x00000000, 0x00000000, 1);
tmpobjid = CreateObject(19481, -1396.733642, 1216.140747, 1046.477905, 0.000000, 0.000000, 450.000000, 300.00);
SetObjectMaterialText(tmpobjid, "{000000}Siga Bem Caminhoneiro", 0, 120, "Engravers MT", 30, 1, 0x00000000, 0x00000000, 1);
tmpobjid = CreateObject(19481, -1396.783691, 1216.280883, 1042.797729, 0.000000, 0.000000, 450.000000, 300.00);
SetObjectMaterialText(tmpobjid, "{FFA500}i", 0, 120, "GTAWEAPON3", 30, 1, 0x00000000, 0x00000000, 1);
tmpobjid = CreateObject(19481, -1396.783691, 1216.280883, 1042.797729, 0.000000, 0.000000, 450.000000, 300.00);
SetObjectMaterialText(tmpobjid, "{FFA500}i", 0, 120, "GTAWEAPON3", 30, 1, 0x00000000, 0x00000000, 1);
tmpobjid = CreateObject(19481, -1396.783691, 1216.280883, 1042.797729, 0.000000, 0.000000, 630.000000, 300.00);
SetObjectMaterialText(tmpobjid, "{FFA500}i", 0, 120, "GTAWEAPON3", 30, 1, 0x00000000, 0x00000000, 1);
tmpobjid = CreateObject(19481, -1396.783691, 1216.280883, 1042.797729, 0.000000, 0.000000, 630.000000, 300.00);
SetObjectMaterialText(tmpobjid, "{FFA500}i", 0, 120, "GTAWEAPON3", 30, 1, 0x00000000, 0x00000000, 1);
tmpobjid = CreateObject(19481, -1396.783691, 1276.280883, 1042.797729, 0.000000, 0.000000, 630.000000, 300.00);
SetObjectMaterialText(tmpobjid, "{FFA500}i", 0, 120, "GTAWEAPON3", 30, 1, 0x00000000, 0x00000000, 1);
tmpobjid = CreateObject(19481, -1396.783691, 1276.280883, 1042.797729, 0.000000, 0.000000, 810.000000, 300.00);
SetObjectMaterialText(tmpobjid, "{FFA500}i", 0, 120, "GTAWEAPON3", 30, 1, 0x00000000, 0x00000000, 1);
tmpobjid = CreateObject(19481, -1396.783691, 1276.280883, 1042.797729, 0.000000, 0.000000, 810.000000, 300.00);
SetObjectMaterialText(tmpobjid, "{FFA500}i", 0, 120, "GTAWEAPON3", 30, 1, 0x00000000, 0x00000000, 1);
tmpobjid = CreateObject(19481, -1396.783691, 1276.280883, 1042.797729, 0.000000, 0.000000, 630.000000, 300.00);
SetObjectMaterialText(tmpobjid, "{FFA500}i", 0, 120, "GTAWEAPON3", 30, 1, 0x00000000, 0x00000000, 1);

//textdraws
TempoRestante = TextDrawCreate(130.000000, 375.000000, "~b~] ~r~Tempo Restante ~b~]");
    TextDrawFont(TempoRestante, 2);
    TextDrawLetterSize(TempoRestante, 0.300000, 1.600000);
    TextDrawColor(TempoRestante, -1);
    TextDrawSetOutline(TempoRestante, 1);
    TextDrawSetProportional(TempoRestante, 1);

//textdraws
dMinutos = TextDrawCreate(130.000000, 390.000000, "~w~02:00");
    TextDrawFont(dMinutos, 2);
    TextDrawLetterSize(dMinutos, 0.300000, 1.600000);
    TextDrawColor(dMinutos, -1);
    TextDrawSetOutline(dMinutos, 1);
    TextDrawSetProportional(dMinutos, 1);


    return 1;
}



public OnPlayerDisconnect(playerid, reason)
{
    new
        szString[64],
        playerName[MAX_PLAYER_NAME];

    GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

	if (pConvidou == playerid){
	    format(szString, sizeof szString, "O duelo x1 foi terminado porque o jogador %s saiu.", pConvidouNome);
	    SendClientMessageToAll(0x1357A6FF, szString);
	    estado = 1;
		resetX1(playerid);

	} else if (pDesafiado == playerid){
		format(szString, sizeof szString, "O duelo x1 foi terminado porque o jogador %s saiu.", pDesafiadoNome);
        SendClientMessageToAll(0x1357A6FF, szString);
        estado = 0;
 	    resetX1(playerid);

	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{

    // Check that the killerid is valid before doing anything with it
    if (killerid != INVALID_PLAYER_ID)
    {
    GetPlayerHealth(killerid, vida);
    GetPlayerArmour(killerid, colete);

        if (pConvidou == killerid){
          SendClientMessageToAll(0x1357FFFF, sprintf("[X1 %s] O jogador %s ( {FF0000}V: %0.2f {FFFFFF}C: %0.2f{1357FF} ) venceu o jogador %s no x1.", gtipoX1, pConvidouNome, vida, colete, pDesafiadoNome));
      	  SendClientMessageToAll(0x1357FFFF, sprintf("*************** DUELO X1 ***************"));
      	  	estado = 0;
          	resetX1(playerid);
        } else if (pDesafiado == killerid){
          SendClientMessageToAll(0x1357FFFF, sprintf("[X1 %s] O jogador %s ( {FF0000}V: %0.2f {FFFFFF}C: %0.2f{1357FF} ) venceu o jogador %s no x1.", gtipoX1, pDesafiadoNome, vida, colete, pConvidouNome));
      	  SendClientMessageToAll(0x1357FFFF, sprintf("*************** DUELO X1 ***************"));
			estado = 1;
			resetX1(playerid);
        }
    }


    return 1;
}

/*==============================================================================
FUN??ES CRIADAS
==============================================================================*/
strcmpEx(const string1[], const string2[], bool:ignorecase=false, length=cellmax)
{
    if((!strlen(string1) && !strlen(string2))) return 0;
    if((!strlen(string1) || !strlen(string2))) return -1;
    return strcmp(string1, string2, ignorecase, length);
}


darArmas(){

		for (new i=0; i<16; i++){
				if (PlayerArmas[pConvidou][i][ArmaEstado] == 1){
 					GivePlayerWeapon(pConvidou, Armas[i][ArmaID], 1000);
 					GivePlayerWeapon(pDesafiado, Armas[i][ArmaID], 1000);
				}
		    }
}


duelo(playerid){
    format(texto, sizeof(texto), "Voce convidou o jogador %s para um duelo x1. Aguarde pela resposta.", mJogadores[playerid][nomeDesafiado]);
	SendClientMessage(playerid, -1, texto);
    SendClientMessage(playerid, 0xA9A9A9AA, "[AVISO] Se ele nao aceitar o convite em 10 segundos, voce e spawnado.");

    //as variaveis sao setadas como globais
    pConvidou = mJogadores[playerid][idConvidou];
    pDesafiado = mJogadores[playerid][idDesafiado];
    GetPlayerName(pConvidou, pConvidouNome, sizeof(pConvidouNome));
    GetPlayerName(pDesafiado, pDesafiadoNome, sizeof(pDesafiadoNome));

    format(gtipoX1, sizeof(gtipoX1), mJogadores[playerid][tipoX1]);

	if (strcmpEx(mJogadores[playerid][tipoX1], "run") == 0){
	    arma = "9mm Pistol, Sawn-Off Shotgun, Tec9";

	} else if (strcmpEx(mJogadores[playerid][tipoX1], "walk") == 0){
		arma = "Desert Eagle, Shotgun, MP5, AK47, Sniper Rifle";

	} else if ( (strcmpEx(mJogadores[playerid][tipoX1], "individual") == 0) || (strcmpEx(mJogadores[playerid][tipoX1], "personalizado") == 0) ){
arma="";
new buffer[400];

		for (new i=0; i<16; i++){
				if ((PlayerArmas[playerid][i][ArmaEstado]) == 1){
					format(buffer, sizeof(buffer), " %s ", Armas[i][ArmaNome], " ");
					strcat(arma, buffer);
				}
		    }

	}

	//Mensagem para o desafiado
	GameTextForPlayer(mJogadores[playerid][idDesafiado], "~b~~h~Aguardando Resposta~w~...",2000,3);
    ShowPlayerDialog(mJogadores[playerid][idDesafiado], rBox1, DIALOG_STYLE_MSGBOX, "X1 - Convite", sprintf("{B9BCCC}- Voc� foi convidado pelo jogador {6495ED}%s{B9BCCC} para um desafio (x1).\nTipo de x1: {A52A2A}%s\n\n{B9BCCC}Armas: %s \n[Pr�mio: R$ ]{B9BCCC} *\n\n - Aceita o duelo?", mJogadores[playerid][nomeConvidou], gtipoX1, arma), "Sim", "N�o");
}


resetX1(playerid){
	SetPlayerPos(pConvidou, 0.0, 0.0, 3.0);
	SetPlayerInterior(pConvidou, 0);
	SetPlayerPos(pDesafiado, 0.0, 0.0, 3.0);
	SetPlayerInterior(pDesafiado, 0);
    TextDrawHideForPlayer(pConvidou, TempoRestante);
    TextDrawHideForPlayer(pConvidou, dMinutos);
    TextDrawHideForPlayer(pDesafiado, TempoRestante);
    TextDrawHideForPlayer(pDesafiado, dMinutos);
   	resetArmas(pConvidou);
	pConvidou = -1;
	pDesafiado = -1;
	KillTimer(timeId);
	KillTimer(timeId2);
	Xocupado = 0;
	return 1;
}


resetArmas(playerid){
    for (new i = 0; i < 16; i++) {
        PlayerArmas[playerid][i][ArmaEstado] = 0;
    }
}


armasPers(playerid){

    new texto2[1024];

    // Monta o texto final para o di�logo com a l�gica atualizada
    format(texto2, sizeof(texto2),
        "Arma\tEstado\n\
        {FFFFFF}Chainsaw (Motoserra)\t%s\n\
        {FFFFFF}Silenced Pistol\t%s\n\
        {FFFFFF}Pistol\t%s\n\
        {FFFFFF}Desert Eagle\t%s\n\
        {FFFFFF}Shotgun\t%s\n\
        {FFFFFF}Sawn-Off Shotgun\t%s\n\
        {FFFFFF}Combat Shotgun\t%s\n\
        {FFFFFF}Tec-9\t%s\n\
        {FFFFFF}UZI\t%s\n\
        {FFFFFF}MP5\t%s\n\
        {FFFFFF}AK-47\t%s\n\
        {FFFFFF}M4\t%s\n\
        {FFFFFF}Rifle\t%s\n\
        {FFFFFF}Sniper Rifle\t%s\n\
        {FFFFFF}Molotov Cocktail\t%s\n\
        {FFFFFF}Frag Grenade\t%s\n\
        {FF00FF}Iniciar x1",
        (PlayerArmas[playerid][0][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (PlayerArmas[playerid][1][ArmaEstado]? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (PlayerArmas[playerid][2][ArmaEstado]? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (PlayerArmas[playerid][3][ArmaEstado]? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (PlayerArmas[playerid][4][ArmaEstado]? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (PlayerArmas[playerid][5][ArmaEstado]? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (PlayerArmas[playerid][6][ArmaEstado]? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (PlayerArmas[playerid][7][ArmaEstado]? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (PlayerArmas[playerid][8][ArmaEstado]? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (PlayerArmas[playerid][9][ArmaEstado]? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (PlayerArmas[playerid][10][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (PlayerArmas[playerid][11][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (PlayerArmas[playerid][12][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (PlayerArmas[playerid][13][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (PlayerArmas[playerid][14][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (PlayerArmas[playerid][15][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n")
    );

    // Mostra o di�logo com as informa��es das armas
    ShowPlayerDialog(playerid, DIALOG_X1_3, DIALOG_STYLE_TABLIST_HEADERS, "X1 Armas personalizadas", texto2, "Duelo", "Cancelar x1");
}






forward count_x1();

public count_x1()
{
    new string[20];

    if(CounterCountdown > 0)
    {
        CounterCountdown--;

        format(string, sizeof(string), "%i", CounterCountdown);
        GameTextForPlayer(pConvidou, string, 999, 3);
        GameTextForPlayer(pDesafiado, string, 999, 3);
        PlayerPlaySound(pConvidou, 1056, 0.0, 0.0, 0.0);
   	    PlayerPlaySound(pDesafiado, 1056, 0.0, 0.0, 0.0);
    }

    if(CounterCountdown == 0)
    {
        format( string, sizeof(string), "~y~GO GO GO");
    	GameTextForPlayer(pConvidou, string, 500, 3 );
    	GameTextForPlayer(pDesafiado, string, 500, 3 );
   	    PlayerPlaySound(pConvidou, 1057, 0.0, 0.0, 0.0);
   	    PlayerPlaySound(pDesafiado, 1057, 0.0, 0.0, 0.0);
        TogglePlayerControllable(pConvidou, true);
        TogglePlayerControllable(pDesafiado, true);
        KillTimer(timeId);

		CounterDuel = 120;
	    timeId2 = SetTimer("count_duel", 1000, true);
		TextDrawShowForPlayer(pDesafiado, dMinutos);
	    TextDrawShowForPlayer(pConvidou, dMinutos);
        return 1;
    }
    return 1;
}


forward count_duel();

public count_duel()
{
    new string[20];


    if(CounterDuel > 0)
    {
        CounterDuel--;

		// Converter o CounterDuel em minutos e segundos
        new minutos = CounterDuel / 60;
        new segundos = CounterDuel % 60;

		format(string, sizeof(string), "~w~%02d:%02d", minutos, segundos);

		TextDrawSetString(dMinutos, string);
    }

    if(CounterDuel == 0)
    {
        SendClientMessageToAll(0xFFFFFFFF, "[X1] Terminou o tempo, ningu�m venceu.");
        TextDrawHideForAll(dMinutos);
        TextDrawDestroy(dMinutos);
		resetX1();
        return 1;
    }
    return 1;
}
