/*------------------------------------------

				LECTEUR

------------------------------------------*/



//test="000"
#include "../code62.as"


function init(){
	


	carMax = 8
	emoteEyeMax = 5
	emoteMouthMax = 6
	famId= 0;

	// CARACTERES
	car=new Array()
	car[0]=0;
	for(var i=1; i<=carMax; i++){
		car[i]=0;
		attachMovie("permuteur","permuteur"+i, 100+i)
		var mc = this["permuteur"+i]
		mc._x = 82+50*i;
		mc._y = 55;
		mc.id=i;
	}

	// ACTIONS
	actionList=["stop","parler","rire","mdr","langue","rougir","regard","sifflote","gum"]
	for(var i=0; i<actionList.length; i++){
		attachMovie("action","action"+i, 200+i)
		var mc = this["action"+i]
		mc._x = 5 + (i%5)*100;
		mc._y = 152 + Math.floor(i/5)*30
		mc.id=i;
		mc.nom=actionList[i]
	}
	
	loadFamily("famille0")
	
};

function loadFamily(nom){

	this.createEmptyMovieClip("frutibouille",1)
	frutibouille._x = 5;
	frutibouille._y = 5;

	loadMovie("../"+nom+"/"+nom+".swf",frutibouille);
	familyInput.text = nom;
	
	gotoAndPlay("loading");
}



function initBouille(){
	
	applyString()
	frutibouille.genInfo()
	for(var i=1; i<=carMax; i++){
		var mc = this["permuteur"+i]
		mc.palette = frutibouille.carInfo[i].palette
		if(mc.palette){
			mc.gotoAndStop(2);
			setColor(mc.col,car[i],mc.palette-1)
		}else{
			mc.gotoAndStop(1);
		}
		
	}
	attachMovie("fond","mask",2)
	frutibouille.setMask(mask)
	mask._x=5;
	mask._y=5;

}


function applyString(){

	s = new String();
	for(var i=0; i<=carMax; i++){
		var s2 = car[i].encode62();
		if(s2.length<2)s2="0"+s2
		s += s2;	
	}
	frutibouille.apply(s);
	frutibouille.genInfo();
	frutibouille.action(0);
	
	//-------------- SPECIAL LECTEUR -----------------
	for(var i=1; i<=carMax; i++){
		var mc = this["permuteur"+i]
		if(mc.palette){
			setColor(mc.col,car[i],mc.palette-1)
		}else{
			mc.txt = car[i]
		}
	}
	//------------------------------------------------

}