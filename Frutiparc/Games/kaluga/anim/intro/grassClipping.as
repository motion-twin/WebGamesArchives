/************************
 *	CLIPPING	*
 ************************/
 
 
 function init(){
	 
	 clipInit();
	
	 
}


function main(){
	
	
	Std.update();
	tmod=Std.tmod;
	
	
	// DEBUG
	
	indic1=d;
	indic2=tmod;
	
	genClip();
	moveClip();
	

}








function clipInit(){
	
	Std.cast(Std).wantedFPS = 40;
	 
	 d=1;
	 
	 // dimensions de la scene
	 
	 mcw = 700;
	 mch = 480;
	 
	 
	 // direction du scroll
	 
	 dir="L"	// L --> vers la gauche ; R --> vers la droite
	 	 
	 
	 // vitesse
	 if(dir == "L"){
		vitClip=-3;
	 }
	  if(dir == "R"){
		vitClip=3;
	 }
	 
	 
	 clipNum = 15	// nombre de tranches
	 
	 mirrorSlice = false;
	 
	 numSliceInit=7;
	 
	 clip = "panneauGrass";
	 
	 clipList=new Array();
	 
	  initPosition();
	
}

function genClip(){
	
	if(mc._x <= mcw-mc._width-vitClip && dir == "L"){
		createClip();
	}
	if(mc._x >= -vitClip && dir == "R"){
		createClip();
	}
	
	
}

function createClip(){
	if(d >= clipNum){
		d=0;
	}
	d++;
	
	attachMovie(clip,clip+d,d);
	mc = this[clip+d];
	
	if(dir == "L"){
			
		if(d == 2){
			mc._x=mcw+vitClip;
			
		}else{
			mc._x=this[clip+(d-1)]._x+this[clip+(d-1)]._width;
		}
		if(last == true){
			this[clip+2]._x=this[clip+15]._x+this[clip+15]._width;
		}
	}
	if(dir == "R"){
		mc._xscale=-100;
		if(d == 1){
			mc._x=mcw;
			
		}else{
			mc._x=this[clip+(d-1)]._x-this[clip+(d-1)]._width;
		}
	}
	mc.gotoAndStop(d-1);
	
	clipList.push(mc);
	
	return mc;
	
}

function moveClip(){
	
	for(var i=0; i<clipList.length; i++){
		mc = clipList[i];
		mc._x+=vitClip*tmod*_parent._parent._parent.vitFor;
	
		if(dir == "L"){
			if(mc._x<=-mc._width){
	 			mc.removeMovieClip("");
 	 			clipList.splice(i,1);
 	 			i--;
 	 		}
		}
		if(dir == "R"){
			if(mc._x>=mcw){
	 			mc.removeMovieClip("");
 	 			clipList.splice(i,1);
 	 			i--;
 	 		}
		}
		
	}
	
}



function initPosition(){
	
	clip1._x=0;
	for(var i=0;i<=numSliceInit;i++){
		
		if(d >= clipNum){
			d=0;
		}
		d++;
		
		attachMovie(clip,clip+d,d);
		mc = this[clip+d];
		mc._x=this[clip+(d-1)]._x+this[clip+(d-1)]._width;
		mc.gotoAndStop(d-1);
		clipList.push(mc);
		
	}
	
		
}