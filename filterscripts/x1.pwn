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

#define DIALOG_TIPOSX1 1
#define DIALOG_TIPOSX1_2 2
#define DIALOG_TIPOSX1_3 3
#define DIALOG_X1 4
#define DIALOG_X1_2 5
#define rBox1      5452 // Cuidado conflitos.

#pragma warning disable 239

new CounterCountdown, timeId;

//==============================================================================

new
    pConvidou,
    pConvidouNome[MAX_PLAYER_NAME + 1],
    pDesafiado,
    pDesafiadoNome[MAX_PLAYER_NAME + 1],
//Vida e colete
    Float:vida,
    Float:colete,
	vConvidou,
	cConvidou,
	vDesafiado,
	cDesafiado,
//Valores do x1
    Xocupado,
    BlockDuelo,
    tipoX1[100],
	arma[200],
	idarma,
	texto[1024],
	texto2[1024],
//Valores de funcoes criadas
	estado
;




CMD:tiposx1(playerid)
{
   ShowPlayerDialog(playerid, DIALOG_TIPOSX1, DIALOG_STYLE_LIST, "Tipos X1", "RUN 1\nWALK\n{FFFF00}Armas individuais\nMinigun", "Fechar", #);
}



CMD:x1(playerid, params[]){
	new desafiado;

	//Verificações
	if (Xocupado == 1) return SendClientMessage(playerid, 0xA9A9A9AA, "[INFO] O x1 já está ocupado. Aguarde até terminar.");
	if (sscanf(params, "d", desafiado)) return SendClientMessage(playerid, 0xA9A9A9AA, "[ERRO] Insira um ID de jogador válido.");
	//if (desafiado == playerid) return SendClientMessage(playerid, 0xA9A9A9AA, "[ERRO] Não pode duelar com você mesmo.");
	if(!IsPlayerConnected(desafiado)) return SendClientMessage(playerid, 0xA9A9A9AA, "[ERRO] Jogador offline.");

	pConvidou = playerid;
	pDesafiado = desafiado;

	GetPlayerName(pConvidou, pConvidouNome, sizeof(pConvidouNome));
	GetPlayerName(pDesafiado, pDesafiadoNome, sizeof(pDesafiadoNome));

    //dialog escolha de arma + premio (1000 a 20k)
    ShowPlayerDialog(playerid, DIALOG_X1, DIALOG_STYLE_LIST, "Tipos X1", "RUN\nWALK\n{FFFF00}Armas individuais\nArmas personalizadas", "Próximo", "Cancelar x1");


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
        if(response){ //Voltar
        ShowPlayerDialog(playerid, DIALOG_TIPOSX1, DIALOG_STYLE_LIST, "Tipos X1", "RUN\nWALK\n{FFFF00}Armas individuais\nArmas personalizadas", "Fechar", #);

		return 1;
        }
        return 1;
   }
   


if(dialogid == DIALOG_X1){

    switch(listitem){
        case 0:{
		tipoX1 = "run";
		arma = "9mm Pistol, Sawn-Off Shotgun, Tec9";
		duelo();
		}
        case 1:{
		tipoX1 = "walk";
		arma = "Desert Eagle, Shotgun, MP5, AK47, Sniper Rifle";
		duelo();
		}
        case 2:{
		tipoX1 = "individual";
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
		ShowPlayerDialog(playerid, DIALOG_TIPOSX1_3, DIALOG_STYLE_TABLIST_HEADERS, "X1 Armas personalizadas", "Arma\tEstado\n\
		Chainsaw (Motoserra)\t{FF0000}Desativado\n\
		Silenced Pistol\t{FF0000}Desativado\n\
		Pistol\t{FF0000}Desativado\n\
		Desert Eagle\t{FF0000}Desativado\n\
		Shotgun\t{FF0000}Desativado\n\
		Sawn-off Shotgun\t{FF0000}Desativado\n\
		Combat Shotgun\t{FF0000}Desativado\n\
		Tec-9\t{FF0000}Desativado\n\
		UZI\t{FF0000}Desativado\n\
		MP5\t{FF0000}Desativado\n\
		AK-47\t{FF0000}Desativado\n\
		M4\t{FF0000}Desativado\n\
		Rifle\t{FF0000}Desativado\n\
		Sniper Rifle\t{FF0000}Desativado\n\
		Molotov Cocktail\t{FF0000}Desativado\n\
		Frag Grenade\t{FF0000}Desativado", "Iniciar x1", "Cancelar");
		tipoX1 = "Personalizado";
		arma = "";
		//duelo();
		}
   }

    return 1;
}

if(dialogid == DIALOG_X1_2){
	if (response){
		switch (listitem){

		case 0: {  idarma = 9;  arma = "Chainsaw (Motoserra)"; }
		case 1: {  idarma = 23; arma = "Silenced Pistol"; }
		case 2: {  idarma = 22; arma = "Pistol"; }
		case 3: {  idarma = 24; arma = "Desert Eagle"; }
		case 4: {  idarma = 25; arma = "Shotgun"; }
		case 5: {  idarma = 26; arma = "Sawn-off Shotgun"; }
		case 6: {  idarma = 27; arma = "Combat Shotgun"; }
		case 7: {  idarma = 32; arma = "Tec-9"; }
		case 8: {  idarma = 28; arma = "UZI"; }
		case 9: {  idarma = 29; arma = "MP5"; }
		case 10: { idarma = 30; arma = "AK-47"; }
		case 11: { idarma = 31; arma = "M4"; }
		case 12: { idarma = 33; arma = "Rifle"; }
		case 13: { idarma = 34; arma = "Sniper Rifle"; }
		case 14: { idarma = 18; arma = "Molotov Cocktail"; }
		case 15: { idarma = 16; arma = "Frag Grenade"; }

		}

	duelo(playerid);
	}

return 1;
}


/*==============================================================================
Aceitar ou não o duelo x1
==============================================================================*/

if(dialogid == rBox1) {
 	// ACEITOU O DUELO
    if(response) {
		if (Xocupado == 1) return SendClientMessage(pConvidou, 0xA9A9A9AA, "[INFO] O x1 já está ocupado. Aguarde até terminar.");
        SendClientMessageToAll(0x1357FFFF, sprintf("*************** DUELO X1 ***************"));
        SendClientMessageToAll(0x1357FFFF, sprintf("| [X1 %s] O jogador %s aceitou o x1 de %s.", tipoX1, pDesafiadoNome, pConvidouNome));
        SendClientMessageToAll(0x1357FFFF, sprintf("| [Armas] %s", arma));
/*[X1 %s] O jogador %s (V: %0.2f C: %0.2f ) venceu o jogador %s (V: %0.2f C: %0.2f) no x1.
        foreach(new i : Player) {
            TextDrawShowForPlayer(i, textoX1);
        }
*/
		Xocupado = 1;

	//Jogador convidou
	SetPlayerPos(pConvidou, -1415.230468, 1246.040283, 1040);
    SetPlayerInterior(pConvidou, 16);
    TogglePlayerControllable(pConvidou, false);
   	SetPlayerFacingAngle(pConvidou, 269.655395);
    ResetPlayerWeapons(pConvidou);
    SetPlayerTeam(pConvidou, 255);
   	SetPlayerHealth(pConvidou, 100);
   	SetPlayerTeam(pDesafiado, 254);

	//Jogador desafiado
    SetPlayerPos(pDesafiado, -1380.088745, 1245.889404, 1040);
    SetPlayerInterior(pDesafiado, 16);
    TogglePlayerControllable(pDesafiado, false);
   	SetPlayerFacingAngle(pDesafiado, 87.003707);
    ResetPlayerWeapons(pDesafiado);
    SetPlayerTeam(pDesafiado, 255);
   	SetPlayerHealth(pDesafiado, 100);
   	SetPlayerTeam(pDesafiado, 255);

	if (tipoX1 = "individual"){
		GivePlayerWeapon(pConvidou, idarma, 1000);
 		GivePlayerWeapon(pDesafiado, idarma, 1000);
	}

    CounterCountdown = 6;
    timeId = SetTimer("count_x1", 1000, true);
    return 1;

	} else {
        SendClientMessage(pConvidou, 0xA9A9A9AA, "[INFO] O jogador não aceitou o duelo.");
    }
}

  return 1;
}


/*==============================================================================
CALLBACKS CRIADAS
==============================================================================*/


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
		resetX1();

	} else if (pDesafiado == playerid){
		format(szString, sizeof szString, "O duelo x1 foi terminado porque o jogador %s saiu.", pDesafiadoNome);
        SendClientMessageToAll(0x1357A6FF, szString);
        estado = 0;
 	    resetX1();
        
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
          SendClientMessageToAll(0x1357FFFF, sprintf("[X1 %s] O jogador %s (V: %0.2f C: %0.2f ) venceu o jogador %s no x1.", tipoX1, pConvidouNome, vida, colete, pDesafiadoNome));
      	  SendClientMessageToAll(0x1357FFFF, sprintf("*************** DUELO X1 ***************"));
      	  	estado = 0;
          	resetX1();
        } else if (pDesafiado == killerid){
          SendClientMessageToAll(0x1357FFFF, sprintf("[X1 %s] O jogador %s (V: %0.2f C: %0.2f ) venceu o jogador %s no x1.", tipoX1, pDesafiadoNome, vida, colete, pConvidouNome));
      	  SendClientMessageToAll(0x1357FFFF, sprintf("*************** DUELO X1 ***************"));
			estado = 1;
			resetX1();
        }
    }


    return 1;
}

public OnGameModeInit()
{
    ConnectNPC("[BOT]Pilot", "pilot");
    return 1;
}

/*==============================================================================
FUNÇÕES CRIADAS
==============================================================================*/


duelo(playerid){
    // O jogador inseriu um ID válido
    format(texto, sizeof(texto), "Você convidou o jogador %s para um duelo x1. Aguarde pela resposta.", pDesafiadoNome);
	SendClientMessage(playerid, -1, texto);
    SendClientMessage(playerid, 0xA9A9A9AA, "[AVISO] Se ele não aceitar o convite em 10 segundos, você é spawnado.");

	//Mensagem para o convidado
	GameTextForPlayer(pDesafiado, "~b~~h~Aguardando Resposta~w~...",2000,3);
    ShowPlayerDialog(pDesafiado, rBox1, DIALOG_STYLE_MSGBOX, "X1 - Convite", sprintf("{B9BCCC}- Você foi convidado pelo jogador {6495ED}%s{B9BCCC} para um desafio (x1).\nTipo de x1: {A52A2A}%s\n\n{B9BCCC}Armas: %s \n[Prêmio: R$ ]{B9BCCC} *\n\n - Você aceita?", pConvidouNome, tipoX1, arma), "Sim", "Não");
}


resetX1(){
 	if (estado == 0) {
	SetPlayerPos(pConvidou, 0.0, 0.0, 3.0);
	SetPlayerInterior(pConvidou, 0);
	} else {
	SetPlayerPos(pDesafiado, 0.0, 0.0, 3.0);
	SetPlayerInterior(pDesafiado, 0);
	}
	pConvidou = -1;
	pDesafiado = -1;
	Xocupado = 0;
	return 1;
}


forward count_x1();

public count_x1()
{
    new string[20];

    if(CounterCountdown > 0)
    {
        CounterCountdown--;

        format(string, sizeof(string), "%i", CounterCountdown);
        GameTextForPlayer(pConvidou, string, 999, 5);
        GameTextForPlayer(pDesafiado, string, 999, 5);
        PlayerPlaySound(pConvidou, 1056, 0.0, 0.0, 0.0);
   	    PlayerPlaySound(pDesafiado, 1056, 0.0, 0.0, 0.0);
    }

    if(CounterCountdown == 0)
    {
        format( string, sizeof(string), "~w~GO GO GO");
    	GameTextForPlayer(pConvidou, string, 500, 3 );
    	GameTextForPlayer(pDesafiado, string, 500, 3 );
   	    PlayerPlaySound(pConvidou, 1057, 0.0, 0.0, 0.0);
   	    PlayerPlaySound(pDesafiado, 1057, 0.0, 0.0, 0.0);
        TogglePlayerControllable(pConvidou, true);
        TogglePlayerControllable(pDesafiado, true);
        KillTimer(timeId);
        return 1;
    }
    return 1;
}


