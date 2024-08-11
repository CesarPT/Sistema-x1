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
#define DIALOG_X1_3 6
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
    BlockDuelo = 1,
    tipoX1[100],
	arma[200],
	texto[1024],
	texto2[1024],
//Valores do dialog
    armas[35] = false,
//Valores de funcoes criadas
	estado
;


enum ArmaInfo {
    ArmaID,         // ID da arma
    ArmaNome[32],   // Nome da arma (até 31 chars + null terminator)
    ArmaEstado          // Ativado/Desativado 1/0
}

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

CMD:resetx1(playerid)
{
   resetX1();
   SendClientMessage(playerid, 0xFF55FF55, "Os valores do x1 foram resetados.");
}

CMD:fecharx1(playerid)
{
if (BlockDuelo != 1){
   BlockDuelo = 1;
   SendClientMessageToAll(0xFF55FF55, "Os duelos x1 foram bloqueados.");
} else {
	SendClientMessage(playerid, 0xFF55FF55, "O x1 já está fechado.");
}
}

CMD:abrirx1(playerid)
{
if (BlockDuelo != 0){

   BlockDuelo = 0;
   SendClientMessageToAll(0xFF55FF55, "Os duelos x1 foram liberados. Use /x1 id");
} else {
	SendClientMessage(playerid, 0xFF55FF55, "O x1 já está aberto.");
}
}



CMD:tiposx1(playerid)
{
   ShowPlayerDialog(playerid, DIALOG_TIPOSX1, DIALOG_STYLE_LIST, "Tipos X1", "RUN\nWALK\n{FFFF00}Armas individuais\nMinigun", "Fechar", #);
}



CMD:x1(playerid, params[]){
	new desafiado;

	//Verificações
	if(BlockDuelo == 1) return SendClientMessage(playerid, -1, "{FFFF00}[ERRO] {FF0000}O sistema de X1 está desativado pelo administrador.");
	//if (Xocupado == 1) return SendClientMessage(playerid, 0xA9A9A9AA, "[INFO] O x1 já está ocupado. Aguarde até terminar.");
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
        if(response){
        ShowPlayerDialog(playerid, DIALOG_TIPOSX1, DIALOG_STYLE_LIST, "Tipos X1", "RUN\nWALK\n{FFFF00}Armas individuais\nArmas personalizadas", "Fechar", #);

		return 1;
        } else {
        resetArmas();
        return 1;
        }
   }
   


if(dialogid == DIALOG_X1){
if (response) {
    switch(listitem){
        case 0:{
        tipoX1 = "run";
		duelo(playerid);
		}
        case 1:{
        tipoX1 = "walk";
		duelo(playerid);
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
		tipoX1 = "Personalizado";
		armasPers(playerid);

		}
   }
}
    return 1;
}

if(dialogid == DIALOG_X1_2){
	if (response){
		switch (listitem){
		case 0: {  Armas[0][ArmaEstado] = true; }
		case 1: {  Armas[1][ArmaEstado] = true; }
		case 2: {  Armas[2][ArmaEstado] = true; }
		case 3: {  Armas[3][ArmaEstado] = true; }
		case 4: {  Armas[4][ArmaEstado] = true; }
		case 5: {  Armas[5][ArmaEstado] = true; }
		case 6: {  Armas[6][ArmaEstado] = true; }
		case 7: {  Armas[7][ArmaEstado] = true; }
		case 8: {  Armas[8][ArmaEstado] = true; }
		case 9: {  Armas[9][ArmaEstado] = true; }
		case 10: { Armas[10][ArmaEstado] = true; }
		case 11: { Armas[11][ArmaEstado] = true; }
		case 12: { Armas[12][ArmaEstado] = true; }
		case 13: { Armas[13][ArmaEstado] = true; }
		case 14: { Armas[14][ArmaEstado] = true; }
		case 15: { Armas[15][ArmaEstado] = true; }

		}

	duelo(playerid);
	} else {
		resetArmas();
	}

return 1;
}


if (dialogid == DIALOG_X1_3){
if (response){
	switch(listitem){
		case 0: {Armas[0][ArmaEstado] = !Armas[0][ArmaEstado];armasPers(playerid);}
		case 1: {Armas[1][ArmaEstado] = !Armas[1][ArmaEstado];armasPers(playerid);}
		case 2: {Armas[2][ArmaEstado] = !Armas[2][ArmaEstado];armasPers(playerid);}
		case 3: {Armas[3][ArmaEstado] = !Armas[3][ArmaEstado];armasPers(playerid);}
		case 4: {Armas[4][ArmaEstado] = !Armas[4][ArmaEstado];armasPers(playerid);}
		case 5: {Armas[5][ArmaEstado] = !Armas[5][ArmaEstado];armasPers(playerid);}
		case 6: {Armas[6][ArmaEstado] = !Armas[6][ArmaEstado];armasPers(playerid);}
		case 7: {Armas[7][ArmaEstado] = !Armas[7][ArmaEstado];armasPers(playerid);}
		case 8: {Armas[8][ArmaEstado] = !Armas[8][ArmaEstado];armasPers(playerid);}
		case 9: {Armas[9][ArmaEstado] = !Armas[9][ArmaEstado];armasPers(playerid);}
		case 10: {Armas[10][ArmaEstado] = !Armas[10][ArmaEstado];armasPers(playerid);}
		case 11: {Armas[11][ArmaEstado] = !Armas[11][ArmaEstado];armasPers(playerid);}
		case 12: {Armas[12][ArmaEstado] = !Armas[12][ArmaEstado];armasPers(playerid);}
		case 13: {Armas[13][ArmaEstado] = !Armas[13][ArmaEstado];armasPers(playerid);}
		case 14: {Armas[14][ArmaEstado] = !Armas[14][ArmaEstado];armasPers(playerid);}
		case 15: {Armas[15][ArmaEstado] = !Armas[15][ArmaEstado];armasPers(playerid);}
		//Iniciar x1
		case 16: {
		duelo(playerid);
		}
	}
} else {
	resetArmas();
}


}

/*==============================================================================
Aceitar ou não o duelo x1
==============================================================================*/

if(dialogid == rBox1) {
 	// ACEITOU O DUELO
    if(response) {
		//if (Xocupado == 1) return SendClientMessage(pConvidou, 0xA9A9A9AA, "[INFO] O x1 já está ocupado. Aguarde até terminar.");
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
	SetPlayerPos(pConvidou, -1415.230468, 1246.040283, 1040.3010);
    SetPlayerInterior(pConvidou, 16);
    TogglePlayerControllable(pConvidou, false);
   	SetPlayerFacingAngle(pConvidou, 269.655395);
    ResetPlayerWeapons(pConvidou);
    SetPlayerTeam(pConvidou, 255);
   	SetPlayerHealth(pConvidou, 100);
   	SetPlayerTeam(pDesafiado, 254);

	//Jogador desafiado
    SetPlayerPos(pDesafiado, -1380.088745, 1245.889404, 1040.3010);
    SetPlayerInterior(pDesafiado, 16);
    TogglePlayerControllable(pDesafiado, false);
   	SetPlayerFacingAngle(pDesafiado, 87.003707);
    ResetPlayerWeapons(pDesafiado);
    SetPlayerTeam(pDesafiado, 255);
   	SetPlayerHealth(pDesafiado, 100);
   	SetPlayerTeam(pDesafiado, 255);
	if (strcmpEx(tipoX1, "run") == 0){
		GivePlayerWeapon(pConvidou, 22, 1000);
		GivePlayerWeapon(pConvidou, 26, 1000);
		GivePlayerWeapon(pConvidou, 32, 1000);
		GivePlayerWeapon(pDesafiado, 22, 1000);
		GivePlayerWeapon(pDesafiado, 26, 1000);
		GivePlayerWeapon(pDesafiado, 32, 1000);
	}
	if (strcmpEx(tipoX1, "walk") == 0){
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
	if (strcmpEx(tipoX1, "individual") == 0){
		darArmas();
	}
	if (strcmpEx(tipoX1, "Personalizado") == 0){
  		darArmas();
	}

    CounterCountdown = 4;
    timeId = SetTimer("count_x1", 1000, true);
    return 1;

	} else {
        SendClientMessage(pConvidou, 0xA9A9A9AA, "[INFO] O jogador não aceitou o duelo.");
        resetArmas();
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

/*==============================================================================
FUNÇÕES CRIADAS
==============================================================================*/
strcmpEx(const string1[], const string2[], bool:ignorecase=false, length=cellmax)
{
    if((!strlen(string1) && !strlen(string2))) return 0;
    if((!strlen(string1) || !strlen(string2))) return -1;
    return strcmp(string1, string2, ignorecase, length);
}


darArmas(){

		for (new i=0; i<16; i++){
				if (Armas[i][ArmaEstado] == 1){
 					GivePlayerWeapon(pConvidou, Armas[i][ArmaID], 1000);
 					GivePlayerWeapon(pDesafiado, Armas[i][ArmaID], 1000);
				}
		    }
}


duelo(playerid){

arma="";
new buffer[400];
	if (strcmpEx(tipoX1, "run") == 0){
	    arma = "9mm Pistol, Sawn-Off Shotgun, Tec9";

	} else if (strcmpEx(tipoX1, "walk") == 0){
		arma = "Desert Eagle, Shotgun, MP5, AK47, Sniper Rifle";

	} else if ( (strcmpEx(tipoX1, "individual") == 0) || (strcmpEx(tipoX1, "Personalizado") == 0) ){
		for (new i=0; i<16; i++){
				if (Armas[i][ArmaEstado] == 1){
					format(buffer, sizeof(buffer), " - %s ", Armas[i][ArmaNome], " - ");
					strcat(arma, buffer);
				}
		    }

	}
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
	resetArmas();
	return 1;
}

resetArmas(){
    for (new i = 0; i < 16; i++) {
        Armas[i][ArmaEstado] = 0;
    }
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
        return 1;
    }
    return 1;
}


armasPers(playerid){
	    texto2 = "";


format(texto2, sizeof(texto2), "Arma\tEstado\n\
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
        (Armas[0][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (Armas[1][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (Armas[2][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (Armas[3][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (Armas[4][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (Armas[5][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (Armas[6][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (Armas[7][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (Armas[8][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (Armas[9][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (Armas[10][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (Armas[11][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (Armas[12][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (Armas[13][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (Armas[14][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"),
        (Armas[15][ArmaEstado] ? "{00FF00}Ativado\n" : "{FF0000}Desativado\n"));

  		ShowPlayerDialog(playerid, DIALOG_X1_3, DIALOG_STYLE_TABLIST_HEADERS, "X1 Armas personalizadas", texto2, "Duelo", "Cancelar x1");

}

