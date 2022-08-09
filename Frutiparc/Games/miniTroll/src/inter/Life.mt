class inter.Life extends Inter{//}

	var max:int;
	var hList:Array<{>MovieClip, bg:MovieClip, c:MovieClip}>
	var fi:FaerieInfo;

	var skinFrame:int;
	
	function new(b){
		//max = 7;
		width = 100;
		height = 18;
		super(b);
		hList = new Array();
		//init();
	}
	
	function init(){
		link = "interLife";
		super.init();
	}

	function initHeart(){
		while(hList.length>0){
			hList.pop().removeMovieClip();
		}
		var ec = 14
		var m = (width-(ec*max))*0.5
		for( var i=0; i<max; i++ ){
			var mc = downcast( Std.attachMC(skin,"mcHeart",10-i) ) 
			mc._x = m+ec*i-1
			mc.bg.gotoAndStop( string(skinFrame) )
			hList.push(mc)
		}		
	}
		
	function setFaerie(f){
		fi = f;
		fi.intLife = this;
		max = fi.carac[Cs.LIFE]
		initHeart();
		updateGFX();
		//Manager.log(faerie.life)
	}
	
	function updateGFX(){
		for(var i=0; i<max; i++){
			var frame = 1
			if( i < fi.fs.$life )frame++;
			hList[i].gotoAndStop(string(frame));
		}
	}
	
	function setHealth(n){
		var mc = hList[fi.fs.$life-1].c
		mc._xscale = 10+n*0.9
		mc._yscale = mc._xscale
	}
	
	
	
	
	
	
	
//{	
}