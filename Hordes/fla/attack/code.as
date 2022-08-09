/********************************
 *	ZOMBIES ATTACK !!!	*
 ********************************/
 
 
 
 function init(){
	 
	 
	lightVit = 5;
	 
	 zList = new Array();
	 zMax = 50;
	 zNum = 0;
	 dp_z = 0;
	 
	 coolZ = 50;
	 
	 
	 
	 dList = new Array();
	 dMax = 80;
	 dNum = 0;
	 dp_d = 0;
	 
	 coolD = 50;
	 
	 
	  lList = new Array();
	 lMax = 80;
	 lNum = 0;
	 dp_l = 0;
	 
	 coolL = 50;
	 
	  
	
	 
	//shake
	
	elastikS = 0;
	elastikS2 = 0;
	elastikS3 = 0;
	elastikS4 = 0;
	
	factor = 0.5;	
	depass = 0.65;
	 
}



 function main(){
	 
	 indic = coolL;
	 light();
	 nois();
	 
	
	 coolZ --;
	 coolD --;
	 coolL --;

	
	 if(coolZ <=0){
		createZombie();
		  coolNoise = random(130);
		 coolZ = Random(15)+5;
		
	}
	
	
	if(coolD <=0){
		createDirt();
// 		  coolNoise = random(130);
		 coolD = Random(5)+2;
		
	}
	
	if(coolL <=0){
		createLittle();
// 		  coolNoise = random(130);
		 coolL = Random(100)+2;
		
	}
	
	 
	  shakeM();
	 moveZombie();
	 moveDirt();
	 moveLittle();

	 
	 
 }
 
 function light(){
	 
	 mov.cam.lamp._alpha += lightVit; 
	 mov.cam.lamp2._alpha += lightVit;
	 var coolDown = random(150);
	 
// 	 createZombie ();
	 
	 
	if(coolDown >= 118){ 

		// 		 mov.lamp._alpha = random(40)+60;
		lightVit = -30;
	}else{
		lightVit = 10;
	}
	
	if(mov.cam.lamp._alpha >= 95){ 
		 mov.cam.lamp._alpha = 95;
		 mov.cam.lamp2._alpha = 95;
	}
}


 function nois(){
	 

	
	 

	 
	 
	if(coolNoise >= 118){ 

		// 		 mov.lamp._alpha = random(40)+60;
		noise._alpha = 100;
		
	}else{
		noise._alpha = 6;
	}
	
// 	if(mov.cam.lamp._alpha >= 95){ 
// 		 mov.cam.lamp._alpha = 95;
// 	}
}

function createZombie() {
    zNum = zNum + 1 % zMax;

var mc = mov.cam.attachMovie("zombClip","zombClip" + zNum,dp_z + zNum + 300);
	

	mc.s = random(90)+40;
	mc._xscale = mc.s;
	mc._yscale = mc.s;
	mc._x = 600;
	mc._y =100 + mc._xscale /2;
	mc.filters = [new flash.filters.BlurFilter(mc.s-100,0)];
	mov._y += mc.s/10;
	if(mc.s >= 100){
		mov.gotoAndPlay("start1");
		
	}
	if(mc.s < 100 && mc.s >=60){
		
	}
    zList.push(mc)

    return mc
    }
function moveZombie() {
	
	 for ( i = 0; i < zList.length; i++){
        var mc = zList[i];
        mc.vitx = mc._xscale /3;
        mc._x -= mc.vitx;
		 
		 if(mc._x <=-300){
			 mc.removeMovieClip()
                zList.splice(i,1);
			 i--;
		}

        }
}
	
	
function createDirt() {
    dNum = dNum + 1 % dMax;

var mc = mov.cam.attachMovie("dirt","dirt" + dNum,dp_d + dNum + 200);
	

	mc.s = random(90)+40;
	mc._xscale = mc.s;
	mc._yscale = mc.s;
	mc._x = 600;
	mc._y =50 + mc._xscale /2;
	mc.filters = [new flash.filters.BlurFilter(mc.s-100,0)];
		
    dList.push(mc)

    return mc
}
function moveDirt() {
	 for ( i = 0; i < dList.length; i++){
		var mc = dList[i];
		mc.vitx = mc._xscale / 13;
		mc._x -= mc.vitx;
		 
		 if(mc._x <=-300){
			 mc.removeMovieClip()
                dList.splice(i,1);
			 i--;
		}
	}
}


function createLittle() {
    lNum = lNum + 1 % lMax;

var mc = mov.cam.zomb.attachMovie("little","little" + lNum,dp_l + lNum);
	

	mc.s = random(90)+40;
	mc._xscale = mc.s;
	mc._yscale = mc.s;
	mc._x = 600;
	mc._y = 60 + mc._xscale /4;
	mc._alpha = mc.s;
	mc.gotoAndStop(random(2)+1);

	
    lList.push(mc)

    return mc
}
function moveLittle() {
	 for ( i = 0; i < lList.length; i++){
		var mc = lList[i];
		 if(mc._currentframe == 1){
			mc.vitx = mc._xscale / 65;
		 }
		 if(mc._currentframe == 2){
			mc.vitx = mc._xscale / 45;
		 }
		mc._x -= mc.vitx;
		 
		 if(mc._x <=-300){
			 mc.removeMovieClip()
                lList.splice(i,1);
			 i--;
		}
	}
}

function shakeM(){
	
	
	elastikS = (-30 - mov._y) * factor + depass * elastikS;
	mov._y += elastikS;
	
}


function shakeR(){
	
	
	elastikS2 = (8 - mov.cam._rotation) * 0.2+ 0.8 * elastikS2;
	mov.cam._rotation += elastikS2;
	
	
}
	