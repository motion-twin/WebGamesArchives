/************************
 *	KALUGA CREDITS	*
 ************************/


function init(){

	initTimer(32);
	
	//flags
	
	apple=false;
	kaluga=false;
	piwali=false;
	nalika=false;
	gomola=false;
	makulo=false;
	
	first=false;
	
	
	
	compt=0;
	
	vitBg=0.5;
	
	vitTz=5.5;
	
	music = new Sound(this);
	
	music.attachSound("music");

	music.start();


}


function main(){
	
	mainTimer();

	// INDICATEURS

	indic1=compt;
	indic2=tmod;

	if(sub.bg1._x<=-(sub.bg1._width)){
		
		sub.bg1._x=sub.bg2._width-vitBg;
		
	}
	
	if(sub.bg2._x<=-(sub.bg2._width)){
		
		sub.bg2._x=sub.bg1._width-vitBg;
		
	}
	
	sub.bg2._x-=vitBg*tmod;
	sub.bg1._x-=vitBg*tmod;
	
	


	compt=math.round(compt+tmod);

	switch (compt) {
		
		
	case 1:
		
	apple=true;
		
	break;
		
		
	case 230:
		sub.bg1.gotoAndPlay(2);
		sub.bg2.gotoAndPlay(2);
		kaluga=true;
		
		break;
	case 345:


		piwali=true;
		
		break;
	case 460:

		
		nalika=true;

		break;
		
	case 585:

		
		gomola=true;

		break;
		
	case 690:

		
		first=true;

		break;
		
		
	default:

	
	}
	
	if(apple==true){
	
		sub.appleAnim._x+=vitTz/1.7*tmod;
		sub.appleAnim._y=160;
		sub.appleAnim.apple2.apple._rotation+=vitTz*tmod;
		
// 		sub.appleShad._x+=vitTz/1.5;
// 		sub.appleShad._y=135;
// 		sub.appleShad._rotation+=vitTz;
		
	}
	
	if(kaluga==true){
	
		sub.kaluga._x+=vitTz*tmod;
		sub.kaluga._y=135;
		
	}
	
	if(piwali==true){
	
		sub.piwali._x+=vitTz*tmod;
		sub.piwali._y=135;
		
	}
	
	if(nalika==true){
	
		sub.nalika._x+=vitTz*tmod;
		sub.nalika._y=135;
		
	}
	
	if(gomola==true){
	
		sub.gomola._x+=vitTz*tmod;
		sub.gomola._y=135;
		
	}
	
	
	if(first){
		
		first();
		
	}


}

function first(){
	
	
	
}




tzList = new Array();

function genTz(){
	if(random(Tz.length)<2){
		createTz();
	}
}

function createTz(){
	d=(d+1)%100;
	sub.attachMovie("tz","tz"+d,d);
	var mc = sub["tz"+d];
	var scale = 10+random(170/10);
	mc._xscale = scale;
	mc._yscale = scale;
	mc._alpha = scale+10;
	mc._x = random(450);
	mc._y = 400+(mc._height/2);
	mc.vity=-(scale*0.05+random(10)/10);
	tzList.push(mc);
	return mc;
}

function moveTz(){
	for(var i=0; i<tzList.length; i++){
		var mc = tzList[i];
		mc._y+=mc.vity;
		if(mc._y<-mc._height/2){
			mc.removeMovieClip("");
			tzList.splice(i,1);
			i--;
		}
		
	}
}

for(i=0; i<20;i++){
	mc = createTz();
	mc._y=random(400);
}




