class inter.Mana extends Inter{//}

	var max:int;
	var mList:Array<{>MovieClip, bg:MovieClip}>
	var fi:FaerieInfo
	
	function new(b){
		//max = 7;
		width = 100;
		height = 6;
		super(b);
		mList = new Array();
		//init();
		
	}
	
	function init(){
		link = "interMana";
		super.init();
	}

	function initMana(){
		while(mList.length>0){
			mList.pop().removeMovieClip();
		}
		var ec = 6
		var m = (width-(ec*max))*0.5
		for( var i=0; i<max; i++ ){
			var mc = downcast( Std.attachMC(skin,"mcMana",10-i) )
			mc._x = m+ec*i-1
			mc.bg.gotoAndStop( string(skinFrame) )
			mList.push(mc)
			//Manager.log(mc)
		}		
	}
		
	function setFaerie(f){
		fi = f;
		fi.intMana = this;
		max = fi.carac[Cs.MANA]*2;
		initMana();
		updateGFX();
	}
	
	function updateGFX(){
		for(var i=0; i<max; i++){
			var frame = 1
			if( i < fi.fs.$mana )frame++;
			mList[i].gotoAndStop(string(frame));
		}
	}
	
	
	
	
	
	
	
	
//{	
}