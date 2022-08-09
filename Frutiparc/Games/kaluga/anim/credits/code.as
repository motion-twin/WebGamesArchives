/************************
 *	KALUGA CREDITS	*
 ************************/


function init(){


	//flags


	apple=true;
	kaluga=false;
	piwali=false;
	nalika=false;
	gomola=false;
	makulo=false;

// 	step2=false;
	rand1=false;
	portrait=true;
	portrait2=true;
	portrait3=true;
	portrait4=true;

	last2=false;

	changeBg=true;
	changeBg2=true;

	kalugaAt=false;

	all=false;

	//init var

	tzScale=20;
	mainCompt=0;
	comptNum=0;
	d=50;
	comptS=random(3)+1;
	comptS2=random(3)+1;
	vitx=1;
	vity=1;
// 	first=false;


	enableTz = true;
	
	appleEndFlag = false; 

// elastik


	amort=0.8;
	ressort=1.8;


	Std.cast(Std).wantedFPS = 40;


	compt=0;

	vitBg=0.5;

	vitTz=4.8;

	music = new Sound(this);

	music.attachSound("music");

	

	tzList = new Array();
	speedList = new Array();
	scaleList = new Array();
	
	depthList = new Array();
	
	for(i=0;i<100;i++){
		depthList[i]=i;
	}

}


function main(){

// 	kalugaAttach();

	if(mainCompt == 0){
		music.start();
	}
	
	shake();

	vit=vitTz*tmod;

	Std.update();

	tmod=Std.tmod;//*(1+Key.isDown(Key.SPACE)*10);

	mainCompt+=tmod;

	
	
	if(mainCompt>=1650){
		last2=true;
	}


	if(mainCompt>=2340){
		sub.gotoAndStop(3);
		sub.bg1.gotoAndStop(43);
		sub.bg2.gotoAndStop(43);
		last2=false;
	}
	if(mainCompt>=2740){
		all=true;
	}
	if(mainCompt>=1790 && portrait==true){
		portrait=false;
		killTz();
// 		step2=true;
		sub.gotoAndStop(2);
	}
	if(mainCompt>=1926 && portrait2==true){
			sub.pic.gotoAndStop(2);
			sub.pic._x=0;
			portrait2=false;
	}
	if(mainCompt>=2070 && portrait3==true){
			sub.pic.gotoAndStop(3);
			sub.pic._x=0;
			portrait3=false;
	}
	if(mainCompt>=2205 && portrait4==true){
			sub.pic.gotoAndStop(4);
			sub.pic._x=0;
			portrait4=false;
	}
	if(mainCompt>=3390){

		if(kalugaAt==false){
			kalugaAttach();
			kalugaAt=true;
		}
		kalugaFinal();
		
	}

	if(sub.kaluga2._x>=1983){

		sub.gotoAndStop(4);
		killTz();
		enableTz = false;		
	}
	
	appleEnd();
	
	

	// INDICATEURS

// 	indic2 = depthList.length
	
// 	indic1=int(mainCompt);
// 	indic2=sub.kaluga._x;

// 	if(sub.bg1._x<=-(sub.bg1._width)){

// 		sub.bg1._x=sub.bg2._width-vitBg;

// 	}

// 	if(sub.bg2._x<=-(sub.bg2._width)){

// 		sub.bg2._x=sub.bg1._width-vitBg;

// 	}
//
// 	sub.bg2._x-=vitBg;
	sub.bg1._x-=vitBg*tmod;
	
	
	if(sub.bg1._x <= -132){
		
		sub.bg1._x = 0;
	}



	if(sub.appleAnim._x>=600){

		if(changeBg==true){
			sub.bg1.gotoAndPlay(2);

			changeBg=false;
		}
		kaluga=true;


// 		rand1=true;

	}



	if(sub.kaluga._x>=600){
		piwali=true;
	}
	
		



	if(sub.piwali._x>=600){


		nalika=true;
	}



	if(sub.nalika._x>=600){


		gomola=true;

	}

	if(sub.gomola._x>=600){


// 		gomola=true;

		rand1=true;

	}






	if(apple==true){

		sub.appleAnim._x+=vitTz/1.9*tmod;
		sub.appleAnim._y=160;
		sub.appleAnim.apple2.apple._rotation+=vitTz*tmod;
		
		if(sub.appleAnim._x >= 800){
			sub.appleAnim._x = 800;
		}


	}

	if(kaluga==true){

		sub.kaluga._x+=vit;
		sub.kaluga._y=135;
		
		if(sub.kaluga._x >= 800){
			sub.kaluga._x = 800;
		}

	}

	if(piwali==true){

		sub.piwali._x+=vit;
		sub.piwali._y=135;
		
		if(sub.piwali._x >= 800){
			sub.piwali._x = 800;
		}

	}

	if(nalika==true){

		sub.nalika._x+=vit;
		sub.nalika._y=135;
		
		if(sub.nalika._x >= 800){
			sub.nalika._x = 800;
		}

	}

	if(gomola==true){

		sub.gomola._x+=vit;
		sub.gomola._y=135;
		
		if(sub.gomola._x >= 800){
			sub.gomola._x = 800;
		}
// 		rand1=true;

	}


	if(rand1==true){

// 		r1();
		if(last2==false){
			if(enableTz){
				genTz();
			}
		}
		if(changeBg2==true){
			sub.bg1.gotoAndPlay(16);
			
			changeBg2=false;
		}


	}


	if(enableTz){
		moveTz();
	}
}




// function r1(){
//
// 	comptNum--;
//
// 	if(comptNum<=0){
// 		duplicateMovieClip("tzongre","tz"+d,d);
// 		var mc=this["tz"+d];
// 		mc.gotoAndStop(random(5));
// 		mc._y=135;
// 		mc._x=-50;
// 		d++;
// 		comptNum=random(40)+20;
//
// 		tzList.push(mc);
//
// 	}
//
// 	for(i=0;i<=50;i++){
// 		 var mc = tzList[i];
// 		mc._x+=vitTz*tmod;
// 	}
//
//
// }






function genTz(){
	comptNum--;
	if(!all){
		ecart=15;
	}
	if(all){
		ecart=1;
	}
	if(comptNum<=0){
		createTz();
		comptNum=random(30)+ecart;
	}
}

function createTz(){
	d=(d+1)%100;
	if(!all){
		scale = 100;
	}
	if(all){
		var index = random(depthList.length);
		d = depthList[index];
		depthList.splice(index,1);
// 		scale = random(tzScale)*10+tzScale/2;
		scale = d*2;
	}
	sub.attachMovie("tz","tz"+d,d);
	var mc = sub["tz"+d];
	
	mc._xscale = scale;
	mc._yscale = scale;
// 	mc._alpha = scale+10;
	mc._x = -(mc._width/2);
	if(all){
		mc._y = 135+scale/3;
		mc.d = d;

	}else{
		
		mc._y = 135;
	}


	mc.gotoAndStop(random(13)+1);

	mc.sub.tz.gotoAndStop(random(6)+1);
	last=mc._currentframe();
	mc.vity=-(scale*0.05+random(10)/10);
	tzList.push(mc);
	//speedList.push(scale);
	return mc;
}

function moveTz(){
	
	for(var i=0; i<tzList.length; i++){
		var mc = tzList[i];
		//var speed = speedList[i];
		var speed = 5;
		if( mc.d != undefined ) speed = mc.d*0.1;
		mc._x+= speed*tmod//(vit*(speed/100));

		if(mc._x>=700+mc._width/2){
			if(mc.d!=undefined)depthList.push(mc.d);
			mc.removeMovieClip("");
			tzList.splice(i,1);
			//speedList.splice(i,1);
			i--;
		}

	}
}


function killTz(){

	for(var i=0; i<tzList.length; i++){
		var mc = tzList[i];
		mc.removeMovieClip();
	}
	tzList = new Array()
	


}


function shake(){

	comptS--;
	if(comptS<=0){

		coordY=random(10)*(random(2)*2-1);
		comptS=random(5)+3;
	}


	comptS2--;
	if(comptS2<=0){


		coordX=random(20)*(random(2)*2-1);
		comptS2=random(3)+2;
	}


	elastiky = (coordY - sub.pic._y) * 0.06 + 0 * elastiky ;

// 	coordX+=2;
	fact=random(100)/100;
	sub.pic._x+=fact;

// 	sub.pic._x+=elastikx;
	sub.pic._y+=elastiky;


	elastikx = (coordX - sub.lens._xscale+100) * 0.06 + 0 * elastikx ;

	sub.lens._xscale+=elastikx;
	sub.lens._yscale=sub.lens._xscale;


}


function kalugaAttach(){

	sub.attachMovie("kaluga2","kaluga2",5000000);
	sub.kaluga2._x=-500;

	sub.kaluga2._xscale=-1321;
	sub.kaluga2._yscale=1321;
	sub.kaluga2._y=173;

}

function kalugaFinal(){


	sub.kaluga2._x+=30*tmod;





}


function AppleEnd(){
	
	if(mainCompt >=3425){
		if(!appleEndFlag){
			attachMovie("appleClip","appleClip",100);
			appleEndFlag = true;
		}
		
		appleClip._x+=vitTz/1.5*tmod;
		appleClip._y=360;
		appleClip.apple2.apple._rotation+=vitTz/1.5*tmod;
	}
	
	if(appleClip._x>=350){
		attachMovie("happyEndo","happyEndo",150);
		happyEndo._x = appleClip._x;
		happyEndo._y = appleClip._y;
		
		appleClip.removeMovieClip("");
		
	}
	
}