

function loadingInit(){
	logText =""
	
	// BASE
	attachMovie("loadingProcess","lp",512);
	
	// Icon preload
	this.createEmptyMovieClip("icon",5);
	icon.loadMovie("http://"+_root.domain+"fileIcon.swf");
	
	lp.coef = 0;
	
	lp.b1.gotoAndStop(1)
	lp.bgb1.gotoAndStop(2)
	lp.mid.gotoAndStop(1)
	lp.bgmid.gotoAndStop(2)
	lp.b2.gotoAndStop(1)
	lp.bgb2.gotoAndStop(2)
	
	updateLoadingSize();
}

function updateLoadingSize(){
	
	var margin = 32
	var sideWidth = 9	
	var x = margin+sideWidth
	var y = _global.mch/2
	
	// TITLE
	lp.title._x = _global.mcw/2;
	lp.title._y = y-24;
	
	// INFOTEXT
	lp.info._x = _global.mcw/2;
	lp.info._y = y+32;
	
	// INFO
	lp.fieldInfo._x = margin;
	lp.fieldInfo._y = y+16;
	
	// BAR
	lp.midMax = _global.mcw-(margin+sideWidth)*2
	
	lp.b1._x = x
	lp.b1._y = y

	lp.bgb1._x = x
	lp.bgb1._y = y
	
	lp.mid._x = x
	lp.mid._y = y
	
	lp.bgmid._x = x
	lp.bgmid._y = y
	lp.bgmid._width = lp.midMax

	lp.b2._y = y
	
	lp.bgb2._x = lp.bgb1._x + lp.bgmid._width
	lp.bgb2._y = y
	
	loadingLoop();
}



function loadingLoop(){
	
	lp.iTotal = icon.getBytesTotal();
	lp.iLoaded = icon.getBytesLoaded();
	
	// iTotal < 1K: on connais pas encore la taille du swf des icones, on fait une estimation
	
	if(lp.iTotal < 1024){
		lp.iLoaded = 0;
		lp.iTotal = 110000;
	}
	
	lp.mTotal = this.getBytesTotal();
	lp.mLoaded = this.getBytesLoaded();
	
	if(lp.mTotal == lp.mLoaded && lp.iTotal == lp.iLoaded && lp.coef>0.995){
		gotoAndPlay("fin");
		flLoading=false;
		icon.removeMovieClip();
		lp.removeMovieClip("")
	}else{
		lp.ratio = (lp.mLoaded + lp.iLoaded)/(lp.mTotal + lp.iTotal);
		lp.coef = lp.coef*0.9 + lp.ratio*0.1
		lp.pourcentage = Math.round((1-lp.coef)*100)+"%";
		lp.mid._width = lp.coef*lp.midMax;
		lp.b2._x = lp.b1._x + lp.mid._width
		lp.fieldInfo.text = "fichiers restants : "+lp.pourcentage
		
		//logText = "coef("+coef+") ratio("+ratio+")\n"
	}
}

this.loadingInit();
