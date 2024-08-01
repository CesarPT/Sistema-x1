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

//==============================================================================

#define SSCANF_NO_NICE_FEATURES

#define DIALOG_TIPOSX1 1
#define DIALOG_TIPOSX1_2 2
#define DIALOG_X1 3
#define DIALOG_X1_2 4
#define rBox1      5452 // Cuidado conflitos.

//==============================================================================

new
    pConvidou,
    pConvidouNome[MAX_PLAYER_NAME + 1],
    pDesafiado,
    pDesafiadoNome[MAX_PLAYER_NAME + 1],
    Xocupado,
    BlockDuelo,
    tipoX1[100],
	arma
;




CMD:tiposx1(playerid)
{
   ShowPlayerDialog(playerid, DIALOG_TIPOSX1, DIALOG_STYLE_LIST, "Tipos X1", "RUN\nWALK\n{FFFF00}Armas individuais\nMinigun", "Fechar", #);
}



CMD:x1(playerid, params[]){
	new desafiado, texto[1024];

	if (sscanf(params, "d", desafiado)) return SendClientMessage(playerid, 0xA9A9A9AA, "[ERRO] Insira um ID de jogador válido.");
	//if (desafiado == playerid) return SendClientMessage(playerid, 0xA9A9A9AA, "[ERRO] Não pode duelar com você mesmo.");
	if(!IsPlayerConnected(desafiado))
	return SendClientMessage(playerid, 0xA9A9A9AA, "[ERRO] Jogador offline.");

	pConvidou = playerid;
	pDesafiado = desafiado;

	GetPlayerName(pConvidou, pConvidouNome, sizeof(pConvidouNome));
	GetPlayerName(pDesafiado, pDesafiadoNome, sizeof(pDesafiadoNome));

    //dialog escolha de arma + premio (1000 a 20k)
    ShowPlayerDialog(playerid, DIALOG_X1, DIALOG_STYLE_LIST, "Tipos X1", "RUN\nWALK\n{FFFF00}Armas individuais\nMinigun", "Próximo", "Cancelar x1");


	return 1;
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]){
	new texto[1024], textoX1;

	if(dialogid == DIALOG_TIPOSX1){

	switch(listitem){
        case 2:
		{
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
		ShowPlayerDialog(playerid, DIALOG_TIPOSX1_2, DIALOG_STYLE_MSGBOX, "Tipos de X1", texto, "Voltar", "Fechar");
		}
   }
	return 1;
   }

   if(dialogid == DIALOG_TIPOSX1_2){
        if(response){ //Voltar
        ShowPlayerDialog(playerid, DIALOG_TIPOSX1, DIALOG_STYLE_LIST, "Tipos X1", "RUN\nWALK\n{FFFF00}Armas individuais\nMinigun", "Fechar", #);
            
		return 1;
        }
        return 1;
   }


if(dialogid == DIALOG_X1){

    switch(listitem){
        case 0:{
		tipoX1 = "run";
		}
        case 1:{
		tipoX1 = "walk";
		}
        case 2:{
		tipoX1 = "individual";
		strcat(texto, "{FF00FF}Chainsaw (Motoserra)\n\
        {FFFFFF}Silenced Pistol\n\
		{FFFFFF}Pistol\n\
		{FFFFFF}Desert Eagle\n\
		{FFFF00}Shotgun\n\
		{FFFF00}Sawn-off Shotgun\n\
		{FFFF00}Combat Shotgun\n\
		{00FF00}Tec-9\n\
		{00FF00}Micro SMG\n\
		{00FF00}SMG\n\
		{00FFFF}AK-47\n\
		{00FFFF}M4\n\
        {558099}Sniper Rifle\n\
        {558099}Rifle\n\
		{505050}Molotov Cocktail\n\
		{505050}Frag Grenade");
		ShowPlayerDialog(playerid, DIALOG_X1_2, DIALOG_STYLE_TABLIST, "Tipos de armas", texto, "Duelo", "Cancelar x1");
		}
		
	    case 3:{
		tipoX1 = "minigun";

		}
   }

    return 1;
}

if(dialogid == DIALOG_X1_2){
	if (response){

    // O jogador inseriu um ID válido
    format(texto, sizeof(texto), "Você convidou o jogador %s para um duelo x1. Aguarde pela resposta.", pConvidouNome);
	SendClientMessage(playerid, -1, texto);
    SendClientMessage(playerid, 0xA9A9A9AA, "[AVISO] Se ele não aceitar o convite em 10 segundos, você é spawnado.");
	duelo();
	return 1;
	}

return 1;
}

//Aceitar ou não o duelo x1
if(dialogid == rBox1) {
    if(response) { // Sim
        TextDrawSetString(textoX1, sprintf("O jogador %s aceitou o x1 de %s.", pDesafiadoNome, pConvidouNome));

        foreach(new i : Player) {
            TextDrawShowForPlayer(i, textoX1);
        }
    } else {
        SendClientMessage(pConvidou, 0xA9A9A9AA, "[INFO] O jogador não aceitou o duelo.");
    }
}

  return 1;
}


duelo(){
	//Mensagem para o convidado
	GameTextForPlayer(pDesafiado, "~b~~h~Aguardando Resposta~w~...",2000,3);
    ShowPlayerDialog(pDesafiado, rBox1, DIALOG_STYLE_MSGBOX, "Você foi desafiado.", sprintf("{B9BCCC}- Você foi convidado pelo jogador {6495ED}%s{B9BCCC} para um desafio (x1).\n\n Tipo de x1:%s\n\nArmas:%s\n\n - * {6495ED}[Prêmio: R$ ]{B9BCCC} *\n\n - Você aceita?", pConvidouNome, tipoX1, arma), "Sim", "Não");
}


