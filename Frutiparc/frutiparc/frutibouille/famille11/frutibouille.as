/*-----------------------------------------

			FRUTIBOUILLE

-----------------------------------------*/

// HIPPO

#include "../code62.as"

next = 1;
flStop = true;


// FONCTIONS STANDARDS
function apply( s ){
	emote();
}	
function emote(){
	//face.b.b.gotoAndStop(emoteMouth+1);
	face.y.gotoAndStop(emoteEye+1);
}
function applyEmote( id ){
	emoteEye = emoteList[id][0];
	emoteMouth = emoteList[id][1];
	emote();
}
function updateInfo(){
	
}

function action(id){
	//_root.test+="\naction("+id+")\n"
	next = id;
	if(flStop)playAnim(next);

}

function playAnim(id){

	//_root.test="action "+id;
	if(id==0){
		endAnim();
		flStop = true;		
		face.gotoAndStop(1);
		face.y.gotoAndStop(emoteEye+1)
	}else if(id==1){
		flStop = false;
		face.gotoAndPlay("parle");
		face.y.gotoAndStop(emoteEye+1);
		//face.b.b.gotoAndPlay("parle0")
	}else if(id==2){		
		flStop = false;
		next = 0;
		face.compt = 5;
		face.gotoAndPlay("rire");
		face.y.gotoAndStop(4);
		//face.b.b.gotoAndPlay("rire0")
	}else if(id==3){
		flStop = false;
		next = 0;
		face.compt = 8;
		face.gotoAndPlay("mdr");
		face.y.gotoAndStop(4);
		face.b.b.gotoAndPlay("mdr0")
	}else if(id==4){
		flStop = false;
		next = 0;
		face.gotoAndPlay("langue");
		face.y.gotoAndStop(2);
		face.bouche.compt=8;
	}else if(id==5){
		flStop = false;
		next = 0;
		face.gotoAndPlay("rougir")
		face.y.gotoAndStop(3)
		face.ob.o.gotoAndStop(3)
		face.b.b.gotoAndStop(1)
		face.compt=40
	}

}


function endAnim(){
	parent.endAnim();
};


// VARIABLE STANDARD
emoteList = [
	[0,0],
	[1,2],
	[2,1],
	[0,3],
	[3,4],
	[1,4],
	[2,3]
];

actionList = [
	{name:"stop",	iconId:1},
	{name:"parle",	iconId:2},
	{name:"rire",	iconId:3},
	{name:"mdr",	iconId:4},
	{name:"langue",	iconId:5},
	{name:"rougir",	iconId:6}
];


