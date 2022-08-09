class Game extends MovieClip{//}

	// CONSTANTE
	static var DP_FRONT = 		7;
	static var DP_PART = 		6;
	static var DP_SPRITE = 		4;
	static var DP_SPRITE2 = 	3;
	static var DP_BACKGROUND = 	1;
	
	// VARIABLES
	var flFreezeResult:bool
	var flTimeProof:bool
	var mainStep:int
	var step:int;
	var gameTime:float;
	var endTimer:float;
	var flWin:bool;
	var airFrict:float;
	var airFriction:float;
	var gravite:float;
	var dif:float;
	var mcList:Array< Array < {} > >;
		
	var dm:DepthManager;
		
	// REFERENCES
	var base:Base;
	
	function new(){
		dm = new DepthManager(this);
		initDefault();
	}

	function init(){
		base.flWin = null;
		//
		Log.setColor(0x000000)
		//Log.trace( "[GAME] init()\n" );
		//super.init();
		initMcList();
		//initMouse();
		flFreezeResult = false;
		flTimeProof = false;
		step = 0;
		mainStep = 0;
		startGame();
	};

	function initDefault(){
		airFriction = 0.99;
		gravite = 1;
	}
	
	function initMcList(){
		mcList = new Array();
		for(var i=0; i<Cs.MAX_SPRITE_TYPE; i++ )mcList[i] = new Array();
	}	
	
	function startGame(){
		mainStep = 1;
		step = 1
	}
	
	function click(){
	
	}
	
	function release(){
	
	}
	//
	function update(){
		//super.update();
		airFrict = Math.pow(airFriction, Timer.tmod)
		moveSprite()
		switch(mainStep){
			case 2 :
				if(endTimer < 0 ){
					mainStep = 3
					base.setWin(flWin)
				}else{
					endTimer -= Timer.tmod
					if( Std.random(2)==0 && flWin && Manager.fruitList.length<10 ){
						Manager.genFruit();
					}
					
				}
				break;
		}
		
	}
	//
	function moveSprite(){
		var list = glSprite().duplicate();
		for (var i=0; i<list.length; i++ ){
			//Log.trace(">"+Std.cast(list[i].update))
			list[i].update();
		}	
	}

	function setWin(flag){
		if(mainStep==1 && !flFreezeResult ){
			mainStep = 2
			flWin = flag;
			endTimer = 16
		}	
	}

	function outOfTime(){
		if(!flTimeProof)setWin(false);
	}
	
	// NEW
	function newSp(link,sp,d):Sprite{
		var mc = downcast( dm.attach( link, d ) );
		sp.game = this;
		sp.setSkin(mc);
		return sp;
	}
	
	function newSprite(link):Sprite{
		var sp = new Sprite();
		return newSp( link, sp, Game.DP_SPRITE );
	}
	
	function newPhys(link):sp.Phys{
		var sp = new sp.Phys();
		return Std.cast( newSp( link, sp, Game.DP_SPRITE ) );
	}		
	
	function newPart(link):sp.phys.Part{
		var sp = new sp.phys.Part();
		return Std.cast( newSp( link, sp, Game.DP_PART ) );
	}

	// GET LIST
	function glSprite():Array<Sprite>{
		return Std.cast(mcList[Cs.SPRITE]);
	}
	
	function glPhys():Array<sp.Phys>{
		return Std.cast(mcList[Cs.PHYS]);
	}
	
	function glPart():Array<sp.phys.Part>{
		return Std.cast(mcList[Cs.PART]);
	}

	//
	function kill(){
		removeMovieClip()
	}

	
	
//{	
}
















