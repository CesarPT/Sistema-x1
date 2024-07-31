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
#define rBox1      5452 // Cuidado conflitos.

//==============================================================================

new
    pConvidou,
    pConvidouNome[MAX_PLAYER_NAME + 1],
    pDesafiado,
    pDesafiadoNome[MAX_PLAYER_NAME + 1],
    Xocupado,
    BlockDuelo
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
	
    // O jogador inseriu um ID válido
    format(texto, sizeof(texto), "Você convidou o jogador %s para um duelo x1. Aguarde pela resposta.", pConvidouNome);
	SendClientMessage(playerid, -1, texto);
    SendClientMessage(playerid, 0xA9A9A9AA, "[AVISO] Se ele não aceitar o convite em 10 segundos, você é spawnado.");
	
	
	//Mensagem para o convidado
	GameTextForPlayer(pDesafiado, "~b~~h~Aguardando Resposta~w~...",2000,3);
    ShowPlayerDialog(pDesafiado, rBox1, DIALOG_STYLE_MSGBOX, "Você foi desafiado.", sprintf("{B9BCCC}- Você foi convidado pelo jogador {6495ED}%s{B9BCCC} para um desafio (x1).\n\n - * {6495ED}[Prêmio: R$ ]{B9BCCC} *\n\n - Você aceita?", pConvidouNome), "Sim", "Não");

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


