class Game {//}
	
	static var STAND_ALONE =false//false;
	//
	static var DP_MAIN_BG = 0
	static var DP_MAP = 2
	static var DP_INTER = 3
	//
	static var DP_BASE = 2
	static var DP_PART = 4
	
	//	
	static var SCROLL_MARGIN = 60
	static var SCROLL_SPEED = 20
	
	static var BUILD_TILES_LAP = 100
	static var BUILD_PLATS_LAP = 1
	
	var flGotoTestMode:bool;
	
	
	var buildStep:int;
	var buildIndex:int;	
	var step:int;
	var lastSave:String;
	
	var sList:Array<Sprite>
	var dm:DepthManager;
	var mdm:DepthManager;
	var bg:MovieClip;
	var root:MovieClip;
	var mcBg:MovieClip;
	
	var xml:Xml;
	
	var waitPress:void->void;
	var waitRelease:void->void;
	var pressStartTimer:float;
	var pressTimer:float;

	var fadeList:Array< { >MovieClip, fade:float, sens:int} >
	var omp:{x:float,y:float}
	var mDist:float
	var level:LevelData

	var slv:LoadVars;
	var elv:LoadVars;

	function new(mc) {
		LoaderInterface.init();	
		Log.setColor(0x000000)
		Cs.game = this
		mdm = new DepthManager(mc);
		root = mc;
		Lib.setRoot(mdm.empty(DP_MAIN_BG));
		
		mdm.attach("mcUpBar",4)
		
		// HACK
		//downcast(Manager.root_mc).$artwork = "0,10,11,12,13"

		sList = new Array();
		fadeList = new Array();
		mDist = 0
		initStep(0)
	}
	
	function initStep(n:int){
		step = n
		switch(step){
			case 0: // LOAD
				if( STAND_ALONE ){
					xml = new Xml("graouph!");
					xml.onLoad = callback(this,onXmlLoaded)
					xml.load("../levels/test.xml");
				}else{
					slv = LoaderInterface.loadLevel(callback(this,onLevelLoaded));
				}
				break;
				
			case 1: // BUILD
				Inter.init();
				Level.init()
				bg = mdm.attach("bg",DP_MAIN_BG);
				bg.gotoAndStop(string(Level.did+1))				
				buildIndex = 0
				buildStep = 0
				root._visible = false;
				break;
				
			case 2: // EDIT
				
				//Log.trace("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa!")
				Inter.initMode(0)
				root._visible = true;
				Level.root._visible = true;
				Inter.root._visible = true;
				initKeyListener();
				initMouseListener();
				LoaderInterface.startGame();
				break;
				
			case 3: // INITIALISATION
				
				LoaderInterface.startGame();
				Inter.initPanel()
				break;
		}		
	}
	
	function onXmlLoaded(fl){
		var str = xml.firstChild.toString();
		level = new PersistCodec().decode(str)
		
		var card = [
			[ 0,	10	],
			[ 1,	1	],
			[ 2,	50	],
		
			[ 50,	10	],
			[ 51,	3	],
			[ 52,	3	],
		
			[ 100,	5	],
			[ 101,	5	],
			[ 102,	5	],
			[ 103,	5	],
			[ 104,	5	],
			[ 105,	10	],
			[ 106,	10	],
			[ 107,	10	],
			[ 108,	10	],
			[ 109,	10	],
			[ 110,	10	],
			[ 111,	10	],
			[ 112,	3	],
			[ 113,	2	],
			[ 114,	1	],

			[ 310,	1	],
			[ 313,	1	],
		]
		
		Inter.initLim(card);
		
		initStep(1)
	}
	
	function onLevelLoaded(x:Xml) : void {
		var base = x.firstChild;
		base = base.nextSibling
		var node = base.firstChild

		//*
		while(node!=null){
			switch(node.nodeName){
				case "$data".substring(1):
					var str = node.firstChild.nodeValue
					if(str!=null){
						level = new PersistCodec().decode(str);
					}
					break;

				case "$cards".substring(1):
					var a = node.firstChild.nodeValue.split(",");
					var card = new Array();
					//Log.trace("!cards!")
					//Log.trace(node.firstChild.nodeValue)
					for( var i=0; i<a.length; i++){
						var a2 = a[i].split(":")
						card.push( [ int(a2[0]), int(a2[1]) ] )
					}
					Inter.initLim(card);
					break;	
			}
			node = node.nextSibling
		}
		
		//*/
	
		if(level==null){
			initStep(3);
		}else{
			initStep(1);
		}
	}
		
	function main() {

		//Log.print(Inter.flButWait)
		
		// SPRITE
		var list = sList.duplicate();
		for( var i=0; i<list.length; i++ ){
			list[i].update();
		}
		switch(step){
			case 0:
				break;
			
			case 1:
				buildLevel()
				break;
			
			case 2: //EDITION
				// SCROLL
				checkScroll();
				
				// INTER
				Inter.update();
				
				// PRESS
				if( pressStartTimer!=null ){
					pressTimer = Std.getTimer()-pressStartTimer;
				}			
				// MINIMAP
				
				//
				updateFader();
				
				break;
		}

	}

	function updateFader(){
		
		for( var i=0; i<fadeList.length; i++ ){
			
			var mc = downcast(fadeList[i])
			if( mc.fade==null )mc.fade = 0;
			mc.fade = Cs.mm( 0, mc.fade+mc.sens*0.2*Timer.tmod ,1 )
			var c = mc.fade
	
			var m = []
			for( var n=0; n<Cs.CM_STD.length; n++ ){
				m[n] = Cs.CM_GREY[n]*c + Cs.CM_STD[n]*(1-c)
			}
			
			if( c==0 ){
				mc.filters = []
			}else{
				var fl = new flash.filters.ColorMatrixFilter();
				fl.matrix= m;
				mc.filters = [fl]	
			}
			
			if( c==0 || c==1 ){
				fadeList.splice(i--,1)
			}
		}
	}
	
	
	//
	function checkScroll(){
		
		var mp = {x:root._xmouse,y:root._ymouse}
		if(omp!=null){
			mDist += Cs.getDist(mp,omp)
			
		}
		mDist =Cs.mm(0,mDist-20*Timer.tmod,300)
		omp = mp
		
		//Log.print(mDist)
		if(mDist>0)return;
		
		var dx = 0
		var dy = 0
		
		var mch = Cs.mch//-Cs.INTERFACE_MARGIN
		if( root._xmouse<SCROLL_MARGIN ){
			var c = 1 - root._xmouse/SCROLL_MARGIN
			dx = c*SCROLL_SPEED
		}else if( root._xmouse>Cs.mcw-SCROLL_MARGIN ){
			var c = 1 - (Cs.mcw-root._xmouse)/SCROLL_MARGIN
			dx = -c*SCROLL_SPEED
		}		
		if( root._ymouse<SCROLL_MARGIN ){
			var c = 1 - root._ymouse/SCROLL_MARGIN
			dy = c*SCROLL_SPEED
		}else if( root._ymouse>Cs.mch-SCROLL_MARGIN ){
			var c = 1 - (Cs.mch-root._ymouse)/SCROLL_MARGIN
			dy = -c*SCROLL_SPEED
		}			
		if(!Key.isDown(Key.SHIFT)){
			if(Key.isDown(Key.LEFT))	dx=SCROLL_SPEED;
			if(Key.isDown(Key.RIGHT))	dx=-SCROLL_SPEED;
			if(Key.isDown(Key.UP))		dy=SCROLL_SPEED;
			if(Key.isDown(Key.DOWN))	dy=-SCROLL_SPEED;		
		}
		if( dx!=0 || dy!=0 ){

		}
		
		var olx = Level.root._x
		var oly = Level.root._y
		
		Level.root._x = Cs.mm( -(Level.width-Cs.mcw),	Level.root._x+dx, 0 )
		Level.root._y = Cs.mm( -(Level.height-(mch-Cs.INTERFACE_MARGIN)),	Level.root._y+dy, 0 )
	
		if( Math.abs(olx-Level.root._x)+Math.abs(oly-Level.root._y) > 0.5 ){
			if(Inter.minimap==null)Inter.initMinimap();
			Inter.minimap.timer = 20
			Inter.minimap._alpha = 100
		}
		
		
	}
	
	//
	function buildLevel(){
		
		
		
		switch(buildStep){
			case 0: // TILES
				for( var i=0; i<BUILD_TILES_LAP; i++){
					if(buildIndex==level.tiles.length){
						buildStep++
						buildIndex = 0
						break;
					}
					var o = level.tiles[buildIndex]
					Level.addTile(o.x,o.y,o.id)			
					buildIndex++
	
				}
				break;
			case 1:	// PLATFORMS
				for( var i=0; i<BUILD_PLATS_LAP; i++){
					
					if( buildIndex == level.platforms.length ){
						buildStep++
						buildIndex = 0
						break;
					}
					var o = level.platforms[buildIndex]
					if(o.rid>Cs.ARTWORK_MAX){
						Level.addPlat(o.x,o.y,o.w,o.rid,o.rot,null)
					}else if( o.list!=null ){
						Level.addLine(o.x,o.y,o.w,o.list)
					
					}else{
						if(o.rid!=0){
							Level.addArtwork(o.x,o.y,o.w,o.rot,o.rid);
						}else{
							Log.trace("ERROR 5343694")
						}
					}
					
					buildIndex++
					
				}			
				break;
			case 2: // CAISSES
				for( var i=0; i<level.caisse.length; i++){
					var a = level.caisse[i]
					Level.addCaisse(a[0],a[1],a[2],a[3]);
				}
				
				// PIOU
				for( var i=0; i<level.piou.length; i++){
					var a = level.piou[i]
					Level.addPiou(a[0],a[1],a[2]);
				}
				
				// OUT
				for( var i=0; i<level.out.length; i++){
					var a = level.out[i]
					Level.addOut(a[0],a[1]);
				}
				
				/*
				// ARTWORKS
				for( var i=0; i<level.artworks.length; i++){
					var o = level.artworks[i]
					if(o.fr>0){
						Level.addArtwork(o.x,o.y,o.sc,o.rot,o.fr)
					}
				}
				*/
				
				
				
				// ACTION
				for( var i=0; i<level.action.length; i++){
					var a = level.action[i]
					Inter.action[i] = {id:a[0],num:a[1]}
				}
				
				
				
				//
				
				/*
				actionList = new Array();
				for( var i=0; i<level.action.length; i++){
					var a = level.action[i]
					actionList.push(a[0])
					var n = int(a[1])
					if( a[1] > 0 ){
						Inter.addAction(a[0],a[1])
					}
				}
				*/
				initStep(2)
				break;

				
		}
	}
	
	// KEYS
	function initKeyListener(){
		var kl = {
			onKeyDown:callback(this,onKeyPress),
			onKeyUp:callback(this,onKeyRelease)
		}
		Key.addListener(kl)
		
	}
	
	function onKeyPress(){

		var n = Key.getCode();
		
		
		if(n>=96 && n<107 ){
			
		}
		if(n>=49 && n<52 ){
		}		
		if(n>=52 && n<55 ){

		}
		
		switch(n){
			case 17: // CONTROL
				if(Inter.platMode==1 && Inter.mode==1){
					Inter.endPlat(true)
				}
				break;
			
			case Key.SPACE:
				Inter.incMode();
				break;
				
			case Key.ENTER:
				break;
				
			case 46: // SUPPRIME				
				if( Inter.hand != null ){
					Level.endPaint();
				}
				break;				
			case 222:
				Inter.multiSnap(2);
				break;
			case 83: // S
				saveData( Level.buildDaBigString() )
				break;
			case Key.LEFT:
				Level.moveAll(-Inter.snap,0);
				break;
			case Key.RIGHT:
				Level.moveAll(Inter.snap,0);
				break;
			case Key.UP:
				Level.moveAll(0,-Inter.snap);
				break;
			case Key.DOWN:
				Level.moveAll(0,Inter.snap)
				break;
				
		}
	

	}
	
	function onKeyRelease(){
		
	}	
	
	// MOUSE
	function initMouseListener(){
		var ml = {
			onMouseDown:callback(this,onMousePress),
			onMouseUp:callback(this,onMouseRelease),
			onMouseWheel:null,
			onMouseMove:null
		}
		Mouse.addListener(ml)
	}
	
	function onMousePress(){
		pressStartTimer = Std.getTimer();
		if(waitPress!=null){
			waitPress();
		}
	}
		
	function onMouseRelease(){
		if(waitRelease!=null){
			waitRelease();
		}
		pressStartTimer = null
		pressTimer = null
	}

	// SAVE
	function saveData(data){
		if(data == lastSave)return false;
		lastSave = data
		
		//
		var mc = Cs.game.mdm.attach("mcSavingPanel",DP_INTER)
		mc.gotoAndStop(string(Lang.id+1))
		
		//
		var self = this;
		elv = LoaderInterface.saveLevel(data, fun(){ self.onSave(mc); });
		/*
		var url = downcast(Std.getRoot()).$saveUrl;
		elv = downcast(new LoadVars());
		Std.cast(elv)[Std.cast("$act".substring(1))] = downcast(Std.getRoot()).$saveAct;
		elv.$data = data;
		elv.onData = callback(this,onSave, mc )
		elv.sendAndLoad(url, elv, "POST");
		*/
		return true;
	}
	
	function onSave(mc){
		//Log.trace("data saved !");
		mc.removeMovieClip();
		if(flGotoTestMode){
			redirect( downcast(Std.getRoot()).$testUrl );
		}else{
			Inter.flButWait = false;
		}
	}
	
	function redirect(url){
		new LoadVars().send(url,"_self","POST")
	}
//{
}









