/*-----------------------------------------

			FRUTIBOUILLE

-----------------------------------------*/

// GENERIC

// ma bouille 0a0602000000020000

#include "../code62.as"

next = 1;
flStop = true;


if(emoteEye==undefined)emoteEye=0;
if(emoteMouth==undefined)emoteMouth=0;

// FONCTIONS STANDARDS
	

function applyEmote( id ){
	//_root.test += "FBOUILLE.applyEmote("+id+")\n";
	emoteEye = emoteList[id][0];
	emoteMouth = emoteList[id][1];
	emote();
}


function action(id){
	//_root.test+="\naction("+id+")\n"
	next = id;
	if(flStop)playAnim(next);

}
function endAnim(){
	parent.endAnim();
};
