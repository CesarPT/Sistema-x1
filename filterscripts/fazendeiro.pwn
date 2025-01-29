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
//Definir outro numero de dialog se houver existente
#define DIALOG_TFAZENDEIRO 1

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


// MATRIZES

enum Jogadores {
    idT,
    nomeT[MAX_PLAYER_NAME],
    BlockT,
	campo[10],
	tipoPlanta[50]
}

new mJogadores[MAX_PLAYERS][Jogadores];

enum ChecksCampo1 {
    x,
    y,
    z
};

new Checks[][ChecksCampo1] = {
    {-187.0076,-77.6673,3.1172},
    {-166.5206,-25.5533,3.1172},
    {-141.8818,37.9951,3.1172}
};

// Matriz das armas x1
new PlayerChecks[MAX_PLAYERS][sizeof Checks][ChecksCampo1];



CMD:ct(playerid)
{
if (mJogadores[playerid][BlockT] != 0){
   resetT();
    SendClientMessage(playerid, 0xFF55FF55, "Cancelou o trabalho de fazendeiro.");
} else {
	SendClientMessage(playerid, 0xFF55FF55, "[ERRO] Não tem nenhum trabalho em aberto.");
}
}


CMD:t(playerid, params[]){

	//Verificações
	if(mJogadores[playerid][BlockT] == 1) return SendClientMessage(playerid, -1, "{FFFF00}[ERRO] {FF0000}Já iniciou o trabalho. Plante com o trator e o acoplado");

	mJogadores[playerid][idT] = playerid;
    GetPlayerName(playerid, mJogadores[playerid][nomeT], sizeof(mJogadores));

	new texto[1024];
	format(texto, sizeof(texto),
    "{FFFFFF}Café\tCampo 1\n\
     {FFFFFF}Algodão\tCampo 2");


	ShowPlayerDialog(playerid, DIALOG_TFAZENDEIRO, DIALOG_STYLE_TABLIST, "Selecione uma plantação",texto,"Comecar", "Sair");
	return 1;
}


/*==============================================================================
Resposta dos dialogs (Trabalho iniciado)
==============================================================================*/

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
if(dialogid == DIALOG_TFAZENDEIRO)
{
    if(response) // clicou Comecar
    {
    switch (listitem){
		case 0: {
		mJogadores[playerid][BlockT] = 1;
 		format(mJogadores[playerid][campo], 10, "1");
		format(mJogadores[playerid][tipoPlanta], 50, "Café");

		format(texto, sizeof(texto), "Vá até ao campo %s e plante %s", mJogadores[playerid][campo], mJogadores[playerid][tipoPlanta]);
		SendClientMessage(playerid, -1, texto);
		

		format(texto, sizeof(texto), "Check 1: %f %s %d", PlayerChecks[playerid][0][x], PlayerChecks[playerid][0][x], PlayerChecks[playerid][0][x]);
		SendClientMessage(playerid, -1, texto);
		
		SetPlayerCheckpoint(playerid, PlayerChecks[playerid][0][x], PlayerChecks[playerid][0][y], PlayerChecks[playerid][0][z], 5.0);
		}
		case 1: {
		mJogadores[playerid][BlockT] = 1;
		format(mJogadores[playerid][campo], 10, "2");
		format(mJogadores[playerid][tipoPlanta], 50, "Algodão");

		format(texto, sizeof(texto), "Vá até ao campo %s e plante %s", mJogadores[playerid][campo], mJogadores[playerid][tipoPlanta]);
		SendClientMessage(playerid, -1, texto);
		}

		}

    }
    else // ESC ou clicou cancelar
    {
    }
    return 1;
}

return 0;
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
    resetT();
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{

    // Check that the killerid is valid before doing anything with it
    if (killerid != INVALID_PLAYER_ID)
    {
   	resetT(playerid);
    }


    return 1;
}

/*==============================================================================
FUNÇÕES CRIADAS
==============================================================================*/
strcmpEx(const string1[], const string2[], bool:ignorecase=false, length=cellmax)
{
    if((!strlen(string1) && !strlen(string2))) return 0;
    if((!strlen(string1) || !strlen(string2))) return -1;
    return strcmp(string1, string2, ignorecase, length);
}

resetT(playerid){
	SetPlayerPos(idT, -169.5776,-77.8714,3.1200);
	SetPlayerInterior(idT, 0);
    TextDrawHideForPlayer(idT, TempoRestante);
    TextDrawHideForPlayer(idT, dMinutos);
	KillTimer(timeId);
	KillTimer(timeId2);
	mJogadores[playerid][BlockT] = 0;
	return 1;
}

