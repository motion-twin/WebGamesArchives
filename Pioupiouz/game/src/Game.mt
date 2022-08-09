class Game {//}
	
	static var STAND_ALONE = false;	
	
	//
	static var DP_MAIN_BG = 0
	static var DP_MAP = 2
	static var DP_INTER = 3
	static var DP_FRONT = 4
	
	//
	static var DP_BASE = 		0
	static var DP_OUT = 		1
	static var DP_DECOR_BG =	2
	static var DP_DECOR = 		4
	static var DP_PART_2 = 		6
	static var DP_ELEMENT = 	7
	static var DP_PIOU = 		8
	static var DP_PART = 		9
	
	static var DPS_BACK = 		0
	static var DPS_DECOR = 		1
	static var DPS_FRONT = 		2
	static var DPS_PAILLETTE =	3
	
	//
	static var SCROLL_MARGIN = 20
	static var SCROLL_SPEED = 20
	
	//
	static var BUILD_TILES_LAP = 50
	static var BUILD_PLATS_LAP = 1
	//
	static var TIME_MULTI = [1,6,12]

	var flFreeze:bool;
	var flEndPanel:bool;
	var flPause:bool;
	var flHelp:bool;
	var flHint:bool;
	var flLog:bool;
	var flReplay:bool;
	var flSpeeder:bool;
	var flMouseAction:bool;
	var flAutoPauseOnStart:bool;
	var flPaillette:bool;
	
	var step:int;
	var buildStep:int;
	var buildIndex:int;
	
	var gameMode:int;
	var piouGoal:int;
	var piouIn:int;
	var piouOut:int;
	
	var pid:String;
	
	var flasher:float;
	var pauser:float;
	var timer:float;
	var btimer:int;
	
	var sList:Array<Sprite>
	var partList:Array<Part>
	var pailletteList:Array<{>Part,ec:float,vd:float,decal:float}>
	var bList:Array<Action>
	var pList:Array<Piou>
	var deathList:Array<Piou>
	var cList:Array<Caisse>
	var eList:Array<LevelElement>
	var outList:Array<MovieClip>
	var actionList:Array<int>
	var blastList:Array<{x:float,y:float,onBlast:int->int->void}>;
	
	var hintList:Array<{>MovieClip,c:float,field:TextField,sens:int,sq:MovieClip}>
	
	var wp:{x:float,y:float};
	
	var dm:DepthManager;
	var mdm:DepthManager;
	var bdm:DepthManager;
	var budm:DepthManager;
	var sdm:DepthManager;
	var bg:MovieClip;
	var root:MovieClip;
	var map:MovieClip;
	var mcSolid:MovieClip;
	
	var mcDecorBg:MovieClip
	var mcDecor:MovieClip
	
	var backBuild:MovieClip;
	var frontBuild:MovieClip;
	var mcLoading:MovieClip;
	var mcHelpPanel:MovieClip;
	var mcFlasher:MovieClip;
	var mcEndPanel:{>MovieClip, art:MovieClip, field:TextField, cross:Button, fieldTitle:TextField, fb0:TextField, fb1:TextField, b0:Button, b1:Button };
	var mcPauseComment:{>MovieClip,field:TextField,fieldTitle:TextField}
	
	var waitPress:Array<void->void>;
	var xml:Xml;
	var level:LevelData;
	var permanentHelp:String;
	
	var startTime:int;
	var endTime:int;
	var multime:int;
	var med:int;
	
	var xm:int;
	var ym:int;
	
	//var selectedPiou:Piou;
	var selectedPiou:MovieClip;
	
	var mcLog:{>MovieClip,field:TextField}
	var mcBuildLoading:{>MovieClip,field:TextField,b:MovieClip}
	
	
	var slv:LoadVars;
	var elv:LoadVars;
	
	var kl:{ onKeyDown:void->void, onKeyUp:void->void }
	var ml:{ onMouseDown : void -> void, onMouseUp : void -> void, onMouseMove : void -> void,onMouseWheel : float -> void }
	
	var history:Array<Array<int>>

	
	function new(mc) {
		LoaderInterface.init();
		
		Cs.game = this
		mdm = new DepthManager(mc);
		root = mc;
		Lib.setRoot(mdm.empty(DP_MAIN_BG));
		
		gameMode = int(downcast(Std.getRoot()).$mode)
		//Log.trace(downcast(Std.getRoot()).$mode)
		
		if(gameMode==2){
			Cs.mcw = Stage.width
			Cs.mch = Stage.height
		}
		
		// PAUSE
		flPause = false;
		flHelp = false;
		flLog = false;
		flFreeze = false;
		flSpeeder = false;
		flPaillette = false;
		flAutoPauseOnStart = true;
		
		//
		hintList = new Array();
		
		// HACK
		//downcast(Manager.root_mc).$startUrl = ""
		//downcast(Manager.root_mc).$endUrl = ""
		//downcast(Manager.root_mc).$piouz = 3
		
		endTime = 0;
		initStep(0);
		
		if(gameMode!=2 && !STAND_ALONE )mdm.attach("mcUpBar",DP_FRONT);
		

		//
		//Log.trace("! ! !");

	}
	
	function initStep(n:int){
		step = n
		switch(step){
			case 0: // LOAD INFO
				
				if(STAND_ALONE){
					
					Cs.log("load Level (standalone)")
					
					loadLevel(TutoData.level)
					
					flHint = true;
					flAutoPauseOnStart = false;

					mcBuildLoading = downcast(mdm.attach("mcLoadingPage",DP_FRONT))
					mcBuildLoading.field.text = "Décompression du niveau"
					
				}else{
					slv = Std.getGlobal("loadLevel")( callback(this,onLevelLoaded) );
				}
				
				piouIn = 0;
				piouOut = 0;
		
				break;
			
			case 1: // BUILD LEVEL
				/* handled by the loader
				mcLoading = mdm.attach("mcLoading",DP_INTER)
				mcLoading._x = (Cs.mcw-Cs.INTERFACE_MARGIN)*0.5
				mcLoading._y = Cs.mch*0.5
				mcLoading.gotoAndStop(string(Lang.id+1))
				*/
				
				sList = new Array();
				partList = new Array();
				bList = new Array();
				pList = new Array();
				cList = new Array();
				eList = new Array();
				outList = new Array();
				blastList = new Array();
				deathList = new Array();
				initMap();
				buildIndex = 0
				buildStep = 0
				map._visible = false;
				bg._visible = false;
				if(Cs.cacheLevel!=null){
						buildStep = 3;
				}
				break;
				
			case 2: // LAUNCH GAME

				initScreen();

				//
				initKeyListener();
				initMouseListener();
				
				flasher = 100
				pauser = 100
				//
				waitPress = new Array();
				
				//
				btimer = 0;
				if(gameMode==1)history = new Array();
				
				//
				if(flReplay)replay();
				//
				multime = 0
				incMultime(0);
				Inter.horloge.timer = 1;
				//
				if(!Cs.game.flPause && flAutoPauseOnStart)Cs.game.togglePause();
				
				if(permanentHelp!=null){
					setPermanentHelp(permanentHelp);
					Inter.showAction(0)
				}
				
				if(STAND_ALONE)toggleHelp();
				
				break;	
				
			case 3: // END GAME
				break;
				
			case 4: // GIVE UP
				giveUp();
				break;
				
			case 5: // FADE + END
				timer = 20
				break;
				
			case 20: // VIEWER
				initViewer();
				break;
		}
	}
	function initScreen(){
		LoaderInterface.startGame();
		map._visible = true;
		bg._visible = true;	
	}
	function onXmlLoaded(fl){
		var str = xml.firstChild.toString();
		level = new PersistCodec().decode(str)
		piouGoal = 10;
		initStep(1)
		
	}
	function loadLevel(str){
		level = new PersistCodec().decode(str)
		piouGoal = 10;
		initStep(1)
		
	}	
	
	function onLevelLoaded(xml){
		xml.ignoreWhite = true;
		var base = xml.firstChild;
		base = base.nextSibling
		var node = base.firstChild
		
		Cs.log(base.toString())
		med = int( base.get("$status".substring(1)) )
	
		flReplay = false;
		
		while(node!=null){
			switch(node.nodeName){
				case "$data".substring(1):
					var str = node.firstChild.nodeValue
					if(str!=null){
						level = new PersistCodec().decode(str);
					}
					break;
				case "$cards".substring(1):

					break;	
				case "$soluce".substring(1):
					var str = node.firstChild.nodeValue
					if(str!=null){
						history = new PersistCodec().decode(str).history;
						//Log.trace(str)
						//Log.trace("length:"+history[0].length)
						flReplay = true;
					}
					break;
				case "$tuto".substring(1):
					permanentHelp = node.firstChild.nodeValue
					break;
				
			}
			node = node.nextSibling
		}
		
		//permanentHelp = "o"
		var pg = base.get("$piouz".substring(1))
		pid = base.get("$id".substring(1));
		flHint = downcast(Std.getRoot()).$help == "1"

		
		
		piouGoal = int(pg)
		/*
		if(pg=="0"){
			//Cs.log("mode: TEST")
			piouGoal = 0
			//gameMode = 1
		}else if(pg==null){
			Cs.log("mode: VIEWER")
			//gameMode = 2
		}else{
			//Cs.log("mode: GAME")
			piouGoal = int(pg)
			//gameMode = 0
		}
		
		*/
		
		//level = new PersistCodec().decode(str)
		if(level==null){
			mdm.attach("mcNoData",DP_INTER)
			step = null
		}
		
		initStep(1)
	}
	function initMap(){
		map = mdm.empty(DP_MAP)
		dm = new DepthManager(map);
		Level.init()
		
		if(gameMode == 2 ){
	
			mcDecor = dm.empty(DP_DECOR)
			mcDecor.attachBitmap(Level.bmp,0)
	
			var mc = mdm.attach("mcBlack",DP_MAIN_BG);
			mc._xscale = Cs.mcw;
			mc._yscale = Cs.mch;
			
			bg = mdm.attach("bg",DP_MAIN_BG);
			bg.gotoAndStop(string(Level.did+1))
			//bg.onPress = callback(this,redirect)
			
			
			// RESCALE MAP
			var xs = Cs.mcw / Level.bmp.width;
			var ys = Cs.mch / Level.bmp.height;
			var c = Math.min(xs,ys)
			map._xscale = 100*c; 
			map._yscale = 100*c; 
			map._x = (Cs.mcw-map._width)*0.5
			map._y = (Cs.mch-map._height)*0.5
			
			// RESCALE BG
			bg._xscale = 100*Math.max( Cs.mcw/bg._width , Cs.mch/bg._height ); 
			bg._yscale = bg._xscale
			bg._x = (Cs.mcw-map._width)*0.5
			bg._y = (Cs.mch-map._height)*0.5
	
			// MASK
			var mask = mdm.attach("mcBlack",DP_MAIN_BG)
			mask._x = map._x
			mask._y = map._y
			mask._xscale = map._width 
			mask._yscale = map._height 
			bg.setMask(mask)
			
			// MEDAL
			
			if(med>0){
				var mmc = mdm.attach("mcMedal", DP_FRONT)
				mmc.gotoAndStop(string(med));
				mmc._x = 28; 
				mmc._y = 28; 
			}
			
		}else{
	
			mcSolid = dm.empty(DP_DECOR)
			sdm = new DepthManager(mcSolid)
			
			mcDecorBg = sdm.empty(DPS_BACK);
			backBuild = sdm.empty(DPS_BACK)
			mcDecor = sdm.empty(DP_DECOR)
			frontBuild = sdm.empty(DPS_FRONT)
	
			bdm = new DepthManager(frontBuild);
			budm = new DepthManager(backBuild);
			
			mcDecor.attachBitmap(Level.bmp,0)
	
			bg = mdm.attach("bg",DP_MAIN_BG);
			bg.gotoAndStop(string(Level.did+1))
			
			Lib.cellShadeMc(mcSolid,2,5)
		}
	}
	
	function main() {
		Timer.tmod = 1
		switch(step){
			
			case 0: // LOAD INFO
				break;
			
			case 1:	// BUILD INDEX
				buildLevel();
				break;
			
			case 2: // GAME
				Inter.update();
			
				// SCROLL
				checkScroll();
			
				// ROLLOVER PIOU
				updateRollOverPiou();
			
				// PAUSE BREAK
				if(flPause)break;
			
				// SPRITE
				moveSprites();
			
				// BEHAVIOUR
				for( var i=0; i<bList.length; i++){
					bList[i].update();
				}
				
				// BTIMER
				btimer++
				
				// REPLAY CONTROL
				if(flReplay)replay();
	
				// SPEEDER CHECK
				updateSpeeder();
			

				
				//
				if(Level.tracer!=null)Level.updateTracer();
				
				//


				break;
				
			case 3: // WAIT END
				if(pList.length==0)initStep(5);
				moveSprites();
				break;
				
			case 4: // GIVE UP
				break;
				
			case 5: // ENDGAME
				timer = Math.max(timer-1,0)
				var prc = (20-timer)*5
				Cs.setPercentColor(dm.root_mc,prc,0xFFFFFF)
				Cs.setPercentColor(bg,prc,0xFFFFFF)				
				if(timer==0 && elv==null){
					exitGame();
					//initStep(6)
				}
				moveSprites();
				break;
		}
		
		// HINT
		updateHint();
		
		if(flHint && flPause ){
			mcPauseComment._visible = !flHelp && !flEndPanel && !( root._ymouse>Cs.mch-100 && root._xmouse>30 && root._xmouse<Cs.mcw-60) 
		}

		// SCREEN
		updateScreenEffect();
		
		// PAILLETTES
		if(flPaillette){
			if(pailletteList.length<50 && Std.random(pailletteList.length)<10 ){
				var p = downcast(new Part(mdm.attach("partPetal",DPS_PAILLETTE)));
				p.x = Math.random()*Cs.mcw;
				p.y = -10;//Math.random()*Cs.mcw;
				p.vx = Math.random()*2;
				p.vy = 1+Math.random()*4;
				p.frict = 1
				p.decal = 0//Math.random()*628
				p.vd = 8+Math.random()*10
				p.ec = 0.1+Math.random()*0.6;				
				pailletteList.push(p)
				Cs.setColor( p.root, Cs.objToCol32( {r:Std.random(255),g:Std.random(255),b:Std.random(255), a:255 } ), 0 );
				var fl = new flash.filters.GlowFilter();
				fl.blurX = 8;
				fl.blurY = 8;
				fl.strength = 1;
				fl.color = 0xFFFFFF;
				p.root.filters = [fl];
					
			}
			
			for( var i=0; i<pailletteList.length; i++ ){
				var p = pailletteList[i];
				p.update();
				//Log.print(p.y)
				p.decal = (p.decal+p.vd*Timer.tmod)%628;
				p.vx += Math.cos(p.decal*0.01)*p.ec;
				
				if(p.y>Cs.mch+10){
					p.kill();
					pailletteList.splice(i--,1);
				}
				var m = 5
				if(p.x>Cs.mcw+m)p.x-=Cs.mcw+2*m;
				if(p.x<m)p.x+=Cs.mcw+2*m;
				
				
				
			}
			
		}		
		
	}
	
	function replay(){
		Log.print("btimer:"+btimer)
		Log.print("next:"+history[0][0])
		while( history[0][0] ==  btimer ){
			var action = history.shift();
			
			if(action[1]==-1){
				Inter.selectActionId( action[2] )
			}else{
				xm  = action[1]
				ym  = action[2]
				
				if(waitPress.length>0){
					while(waitPress.length>0)waitPress.pop()();
			
				}else{
				
					var o = Inter.getActionSlot(Inter.cid)
					var ac = getAction(Inter.cid,xm,ym)
					if(ac.isAvailable()){
						ac.init();
						o.num--;
						Inter.updateActionSlot(o)
					}else{
						Log.trace("REPLAY ERROR : Action not available")
					}
				}
			}
			
		}
				
		
	}
	function moveSprites(){
		var list = sList.duplicate();
		for( var i=0; i<list.length; i++ ){
			list[i].update();
		}	
	}
	function buildLevel(){
		
		switch(buildStep){
			case 0: // TILES
				for( var i=0; i<BUILD_TILES_LAP; i++){
					if(buildIndex>=level.tiles.length){
						buildStep++
						buildIndex = 0
						mcBuildLoading.field.text = "Chargement des plateformes"
						break;
					}
					
					var o = level.tiles[buildIndex]
					if( o.id>=Lib.FRONT_LIMIT[0] && o.id<Lib.FRONT_LIMIT[1] ){
						buildIndex++
					}else{
						Level.drawTile(o.x,o.y,o.id+1)			
						level.tiles.splice(buildIndex,1)
					}
	
				}
				mcBuildLoading.b._xscale = (buildIndex/level.tiles.length)*100
				break;
				
			case 1:	// PLATFORMS
				for( var i=0; i<BUILD_PLATS_LAP; i++){
					
					if( buildIndex == level.platforms.length ){
						buildStep++
						buildIndex = 0
						mcBuildLoading.field.text = "Décompression des élements du niveau"
						break;
					}
					
					
					var o = level.platforms[buildIndex]
					if( o.rid>Lib.ARTWORK_MAX ){
						Level.drawPlatform(o.x,o.y,o.w,o.rid,o.rot)
					}else if(o.list!=null){
						Level.drawLine(o.x,o.y,o.w,o.list)
					}else{
						Level.drawArtwork(o.x,o.y,o.w,o.rot,o.rid)
					}
					buildIndex++
				}
				mcBuildLoading.b._xscale = (buildIndex/level.platforms.length)*100
				break;
			case 2: // TILES LE RETOUR
				for( var i=0; i<BUILD_TILES_LAP; i++){
					if(buildIndex>=level.tiles.length){
						if(gameMode==2){
							initScreen();
							for( var k=0; k<level.piou.length; k++){
								var a = level.piou[k]
								var mc = dm.attach("mcMapPiou",DP_FRONT)
								mc._x = a[0]
								mc._y = a[1]
							}
							for( var k=0; k<level.out.length; k++){
								var a = level.out[k]
								var mc = dm.attach("mcMapOut",DP_FRONT)
								mc._x = a[0]
								mc._y = a[1]
							}							
							initStep(20);
						}else{
							buildIndex = 0
							buildStep++
						}
						
						break;
					}
					var o = level.tiles[buildIndex]
					Level.drawTile(o.x,o.y,o.id+1)			
					buildIndex++
				}
				mcBuildLoading.b._xscale = (buildIndex/level.tiles.length)*100
				break;
			case 3: // ELEMENT
				if(mcBuildLoading != null){
					mcBuildLoading.removeMovieClip();
					mcBuildLoading = null;
				}
				if(Cs.cacheLevel==null){
					Cs.cacheLevel = Level.bmp.clone();
					Cs.cacheLevelIron = Level.iron
				}
				
				Inter.init();
				

				
				// OUT
				for( var i=0; i<level.out.length; i++){
					var a = level.out[i]
					var mc = dm.attach("mcOut",DP_OUT)
					mc._x = a[0]
					mc._y = a[1]
					outList.push(mc)
					
					Level.genHole(a[0],a[1],24)
					
				}
				
				// PIOU
				for( var i=0; i<level.piou.length; i++){
					var a = level.piou[i]
					var p = new Piou(null)
					p.bouncer.setPos(a[0],a[1])
					p.updatePos();
					p.initWalk();
					p.checkExit();
					if(a[2]==-1)p.reverse();
				}
				
				// CAISSES
				for( var i=0; i<level.caisse.length; i++){
					
					var a = level.caisse[i]
					var sp = new Caisse(null);
					sp.bouncer.setPos(a[0],a[1])
					
					sp.id = a[2]
					sp.num = a[3]
					sp.updatePos();
					if(sp.num==null)sp.num = 1;
					
					
				}
				
				// ACTION
				actionList = new Array();
				for( var i=0; i<level.action.length; i++){
					var a = level.action[i]
					actionList.push(a[0])
					var n = int(a[1])
					if( a[1] > 0 ){
						Inter.addAction(a[0],a[1])
					}
				}

				
				initStep(2)
				break;

				
		}
	}
 
	//
	function genPiou(){
		
		var p = new Piou(null)
		p.bouncer.px = int(map._xmouse);
		p.bouncer.py = int(map._ymouse);
		p.x = p.bouncer.px 
		p.y = p.bouncer.py
		p.updatePos();

	}
	function newPart(link){
		var p  = new Part(dm.attach(link,DP_PART));
		return p;
	}
	function newDebris(x,y){
		var color = Level.bmp.getPixel32(int(x),int(y))
		if( !Level.isBg(color) ){
			var p = newPart("mcDebris")
			//var p = new Part(sdm.attach("mcDebris",DPS_FRONT))
			p.x = x;
			p.y = y;
			p.setScale(50+Math.random()*80)
			p.timer = 10+Math.random()*10
			p.fadeType = 0
			p.weight = 0.1+Math.random()*0.1
			Cs.setColor(p.root, color ,-255)
			return p;
		}
		return null;
	}

	//
	function blast(mc){
		for( var i=0; i<blastList.length; i++ ){
			var o = blastList[i]
			var p = {x:o.x,y:o.y}
			downcast(map).localToGlobal(p)
			if( mc.hitTest(p.x,p.y,true) ){
				o.onBlast(0,0);
			}
		}
	}
	
	// MAP
	function checkScroll(){
		
		// CONTROL
		var dx = 0
		var dy = 0
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
		
		
		if(Key.isDown(Key.LEFT))	dx=SCROLL_SPEED;
		if(Key.isDown(Key.RIGHT))	dx=-SCROLL_SPEED;
		if(Key.isDown(Key.UP))		dy=SCROLL_SPEED;
		if(Key.isDown(Key.DOWN))	dy=-SCROLL_SPEED;
		
	
		if( wp!=null ){
			var c = 0.4
			var ddx = (wp.x - map._x)
			var ddy = (wp.y - map._y)
			dx += ddx*c
			dy += ddy*c
			if( Math.abs(ddx)+Math.abs(ddy)<10 )wp = null;
		}
		
		
		if(dx!=0 || dy!=1 ){
			var mx = -(Level.bmp.width-(Cs.mcw-Cs.INTERFACE_MARGIN))
			var my = -(Level.bmp.height-Cs.mch)
			map._x = Cs.mm( mx, map._x+dx, 0 )
			map._y = Cs.mm( my, map._y+dy, 0 )
			map._x = int(map._x)
			map._y = int(map._y)
		}
	
		// BG
		//var rx = Level.bmp.width ( bg._width-(Cs.mcw-INTERFACE_MARGIN) )
		//bg._x = int(map._x*0.3)
		//bg._y = int(map._y*0.2)

		var mw = Level.bmp.width - (Cs.mcw-Cs.INTERFACE_MARGIN)
		var mh = Level.bmp.height - Cs.mch
		var bw = bg._width - (Cs.mcw-Cs.INTERFACE_MARGIN)
		var bh = bg._height - Cs.mch;

		
		bg._x = int(map._x*bw/mw)
		bg._y = int(map._y*bh/mh)
		
		
		
	}
	function scrollMapTo(x,y){
		var tx = -(x-(Cs.mcw-Cs.INTERFACE_MARGIN)*0.5)
		var ty = -(y-Cs.mch*0.5)
		var mx = -(Level.bmp.width-(Cs.mcw-Cs.INTERFACE_MARGIN))
		var my = -(Level.bmp.height-Cs.mch)
		wp = { x:Cs.mm( mx, tx, 0 ), y:Cs.mm( my, ty, 0 ) }
		
		/*
		var mc = Cs.game.dm.attach("mcMark",Game.DP_PART)
		mc._x = x;
		mc._y = y;
		Log.trace( mc  )
		*/
		
	}
	
	// PAUSE
	function togglePause(){
		if( flFreeze )return;
		if( flPause && flHelp )toggleHelp();
		flPause = !flPause
		for( var i=0; i<pList.length; i++){
			var sp = pList[i]
			if(flPause){
				downcast(sp.root).sub.stop();
			}else{			
				downcast(sp.root).sub.play();
			}
		}
		for( var i=0; i<partList.length; i++){
			var sp = partList[i]
			if(flPause){
				sp.root.stop();
			}else{			
				sp.root.play();
			}
		}
		
		if(flPause){
			pauser = 0
			if(flHint){
				mcPauseComment = downcast(mdm.attach("mcPauseComment",DP_INTER))
				mcPauseComment.fieldTitle.text = Lang.pauseComment[0]
				mcPauseComment.field.text = Lang.pauseComment[1]
				mcPauseComment._y = Cs.mch
				Lib.cellShadeMc(mcPauseComment,2,5)
			}
		}else{			
			pauser = 100
			if( startTime==null ) startTime = Std.getTimer();
			if(flHint)mcPauseComment.removeMovieClip();
		}		

		
	}
	function toggleHelp(){
		flHelp = !flHelp;
		if(flHelp){
			mcHelpPanel = mdm.attach("mcHelpPanel",DP_INTER );
			mcHelpPanel._x = (Cs.mcw-Cs.INTERFACE_MARGIN)*0.5
			mcHelpPanel._y = Cs.mch*0.5 + 4
			
			downcast( mcHelpPanel).title.gotoAndStop(string(Lang.id+1))
			
			for( var i=0; i<4; i++ ){
				var field = Std.getVar(mcHelpPanel,"$field"+i)
				field.text = Lang.helpInGame[i]
			}
			
			
			
			//
			var dm = new DepthManager(mcHelpPanel)
			var px = 0
			var py = 0
			for( var i=0; i<Inter.actionList.length; i++ ){
				var id = Inter.actionList[i].id
				var mc = downcast( dm.attach("mcHelpSlot",0) )
				mc._x = px -231
				mc._y = py -9
				var as = downcast( Std.attachMC(mc,"mcActionSlot",0) )
				as.gotoAndStop(string(id+1))
				as.txt = ""
				as._x = 1
				as._y = 1
				mc.field.text = Lang.actionDesc[id]
				py+=34
				if(py>=170){
					py = 0;
					px += 241
				}
			}
			
			//
			if(!flPause)togglePause();
			
		}else{
			mcHelpPanel.removeMovieClip();
			togglePause();
		}
	}
	
	// END PANEL
	function initEndPanel(){
		//
		if(!flPause)togglePause();
		flFreeze = true;
		Inter.flButWait = true;
		flEndPanel = true;
		
		//
		var id = 3
		if(piouIn == 0){
			id = 0;
		}else if(piouIn<piouGoal){
			id =1;
		}else if(piouIn==piouGoal){
			id = 2;
		}
		
		//
		if(STAND_ALONE){
			
			mcEndPanel = downcast(mdm.attach("mcEndStandAlone",DP_INTER ));
			mcEndPanel._x = (Cs.mcw-Cs.INTERFACE_MARGIN)*0.5;
			mcEndPanel._y = Cs.mch*0.5 + 4;
			mcEndPanel.b0.onPress = callback(this,playAgain);
			mcEndPanel.b1.onPress = callback(this,gotoPioupiouz);
			mcEndPanel.gotoAndStop(string(id+1));
			if(id==2){
				flPaillette = true;
				pailletteList = []
			}
			return
		}
		

		
		mcEndPanel = downcast(mdm.attach("mcEndPanel",DP_INTER ));
		mcEndPanel._x = (Cs.mcw-Cs.INTERFACE_MARGIN)*0.5;
		mcEndPanel._y = Cs.mch*0.5 + 4;
		
		mcEndPanel.fb0.text = Lang.endButton[0]
		mcEndPanel.b0.onPress = callback(this,reset);
		mcEndPanel.b1.onPress = callback(this,fastExit);
		
		mcEndPanel.cross.onPress = callback(this,removeEndPanel);
		
		
		var ba = [1,1,2,2]
		

		mcEndPanel.fb1.text = Lang.endButton[ba[id]]
		
		mcEndPanel.art.gotoAndStop(string(id+1))
		mcEndPanel.field.text = Lang.endComment[id]
		mcEndPanel.fieldTitle.text = Lang.endTitle[id]
		mcEndPanel.field._y = 36-mcEndPanel.field.textHeight*0.5
		
	}
	function removeEndPanel(){
		flFreeze = false;
		flEndPanel = false;
		Inter.flButWait = false;
		mcEndPanel.removeMovieClip();
		togglePause();
	};
	
	// PERMANENT HELP
	function setPermanentHelp(txt){
		var mc = downcast(mdm.attach( "mcPermanentHelp", DP_INTER ))
		mc.field.text = txt;
		mc.field._y = 40 - mc.field.textHeight*0.5;
	}
	
	// HINT
	function addHint(txt){
		if(!flHint)return;
		
		var m = 3
		
		var mc = downcast(mdm.attach("mcHint",DP_INTER))
		mc.field.text = txt;
		mc.field._width = 130
		mc.field._width = mc.field.textWidth+8
		mc.field._height = mc.field.textHeight+6
		mc.field._visible = false;
		mc.field._x = 1-mc.field._width
		mc._x = root._xmouse-15;
		
		mc._y = Cs.mm( m,root._ymouse,Cs.mch-(m+mc.field._height));		
		mc.c = 0
		mc.sens = 1
		hintList.push(mc)
	}
	function removeHint(){
		if(!flHint)return;
		var mc = hintList[hintList.length-1]
		mc.sens = -1
		mc.field._visible = false;
	}
	function makeHint(but,txt){
		if(!flHint)return;
		but.onRollOver = callback(this,addHint,txt)
		but.onRollOut = callback(this,removeHint)
		but.onDragOut = but.onRollOut 
		//but.onPress = but.onRollOut 
	}
	function updateHint(){
		if(!flHint)return;
		for( var i=0; i<hintList.length; i++ ){
			
			var mc = hintList[i]
			mc.c = Cs.mm(0,mc.c+0.34*mc.sens,1)
			if(mc.c == 0){
				mc.removeMovieClip();
				hintList.splice(i--,1)
			}else{
				mc.sq._xscale = mc.field._width*mc.c
				mc.sq._yscale = mc.field._height*mc.c
				mc.field._visible = mc.c==1
			}
		}
	}
	
	// SCREEN	
	function updateScreenEffect(){
		if( flasher!=null){
			/*
			var prc = flasher
			if(prc<5){
				prc = 0
				flasher = null;
			}
			Cs.setPercentColor(dm.root_mc,prc,0xFFFFFF)
			Cs.setPercentColor(bg,prc*0.8,0xFFFFFF)
			if(flasher!=null)flasher-= (110-flasher)
			
			*/
			if(mcFlasher==null)mcFlasher = mdm.attach("mcFlasher",DP_INTER);
			if(flasher<=0){
				mcFlasher.removeMovieClip();
				flasher = null;
				mcFlasher = null
			}else{
				mcFlasher._alpha = flasher
				if(flasher!=null)flasher-= (110-flasher)
			}
			
		}
		if(pauser!=null){
			var c = 0
			var flUpdate = pauser<100
			if(flPause){
				pauser = Math.min(pauser+(110-pauser)*0.5,100)
				c = pauser/100
			}else{
				pauser = Math.max(pauser-(120-pauser)*0.5,0)
				c = pauser/100
			}
			var m = []
			for( var i=0; i<Cs.CM_STD.length; i++ ){
				m[i] = Cs.CM_GREY[i]*c + Cs.CM_STD[i]*(1-c)
			}
			
			if( pauser==0 ){
				pauser = null;
				bg.filters = []
				map.filters = []
			}else if(flUpdate){
				var fl = new flash.filters.ColorMatrixFilter();
				fl.matrix= m;
				map.filters = [fl]		
				bg.filters = [fl]
			
			}
		}	
	}
		
	// TIME
	function incMultime(inc){
		if(inc==null){
			multime = (multime+1)%TIME_MULTI.length
		}else{
			multime = Cs.sMod(multime+inc,TIME_MULTI.length)
		}
		updateHorloge()
	}
	function updateHorloge(){
		Manager.speed = TIME_MULTI[multime]
		Inter.trigHorloge();
	}
	function updateSpeeder(){
		if(Key.isDown(Key.SHIFT)){
			if(!flSpeeder){
				flSpeeder = true;
				multime = 1
				updateHorloge()
			}
		}else{
			if(flSpeeder){
				flSpeeder = false;
				multime = 0
				updateHorloge()
			}
		}
	}
	
	// KEYS
	function initKeyListener(){
		kl = {
			onKeyDown:callback(this,onKeyPress),
			onKeyUp:callback(this,onKeyRelease)
		}
		Key.addListener(kl)
		
	}
	function onKeyPress(){
		if(step!=2)return;
		var n = Key.getCode();
		
		
		if(n>=96 && n<107 ){

			
		}
		if(n>=49 && n<52 ){
		}		
		if(n>=52 && n<55 ){

		}
		
		switch(n){
			case 80:
			case Key.SPACE:
				//Log.trace("SPACE!")
				togglePause();
				break;
			case 107:
				if(multime<2)incMultime(1);
				break;
			case 109:
				if(multime>0)incMultime(-1);
				break;
			case 84:
				incMultime(null);
				break;			
			// CHEAT
			case Key.ESCAPE:
				reset();
				break;
			case Key.ENTER:
				//genPiou()
				//Level.holeSecure("mcHole",map._xmouse, map._ymouse,1,1,0,null)
				break;
			case 82: // R
				//Level.reverse();
				break;
			case 222: // ²
				//toggleLog();
				break;			
		}
	

	}
	function onKeyRelease(){
		
	}	
	
	// MOUSE
	function initMouseListener(){
		
		ml = {
			onMouseDown:callback(this,onMousePress),
			onMouseUp:callback(this,onMouseRelease),
			onMouseWheel:null,
			onMouseMove:null
		}
		Mouse.addListener(ml)
	}
	function onMousePress(){
		if(flReplay)return;
		xm = int(map._xmouse)
		ym = int(map._ymouse)
		var flNewPause = false;
		if(root._xmouse<Cs.mcw-Cs.INTERFACE_MARGIN){
			if(waitPress.length>0){
				while(waitPress.length>0)waitPress.pop()();
				history.push([btimer,xm,ym])
			}else{
				if(Inter.cid!=null){
					var o = Inter.getActionSlot(Inter.cid)
					var ac = getAction(Inter.cid,xm,ym)
					if(ac.isAvailable()){
						flMouseAction = true;
						ac.init();
						o.num--;
						Inter.updateActionSlot(o)
						history.push([btimer,xm,ym])
						flNewPause = true
						flMouseAction = false;
					}
				}
			}
			if(Cs.game.flPause){
				togglePause();
				if(flNewPause)togglePause();
			}
			
		}
	}
	function getAction(id,x,y){
			var ac:Action = null;
			switch(id){
				
				case 0: 
					ac = new ac.piou.Jump(x,y);
					break;
				case 1:
					ac = new ac.piou.Flower(x,y);
					break;
				case 2:
					ac = new ac.piou.Grenade(x,y);
					break;
				case 3:
					ac = new ac.piou.Digger(x,y);
					break;
				case 4:
					ac = new ac.piou.Vrille(x,y);
					break;
				case 5:
					ac = new ac.piou.Crystal(x,y);
					break;
				case 6:
					ac = new ac.piou.Rainbow(x,y);
					break;
				case 7:
					ac = new ac.piou.Stair(x,y);
					break;
				case 8:
					ac = new ac.piou.BrickRoll(x,y);
					break;
				case 9:
					ac = new ac.piou.Flamer(x,y);
					break;
				case 10:
					ac = new ac.piou.CarpetRoller(x,y)
					break;
				case 11:
					ac = new ac.piou.Seed(x,y)
					break;
				case 12:
					ac = new ac.piou.Liquid(x,y)
					break;
				case 13:
					ac = new ac.piou.GumBridge(x,y)
					break;
				case 14:
					ac = new ac.piou.Double(x,y)
					break;
				case 15:
					ac = new ac.piou.FlyLeaf(x,y)
					break;
				case 16:
					ac = new ac.piou.Platform(x,y)
					break;
				case 17:
					ac = new ac.piou.Crevasse(x,y)
					break;	
				case 18:
					ac = new ac.piou.Liane(x,y)
					break;
				case 19:
					ac = new ac.piou.Reverse(x,y)
					break;
				case 20:
					ac = new ac.piou.Dash(x,y)
					break;
				case 21:
					ac = new ac.piou.Acid(x,y)
					break;
				case 22:
					ac = new ac.piou.Climber(x,y)
					break;
				case 23:
					ac = new ac.piou.Psionic(x,y)
					break;
				case 24:
					ac = new ac.piou.StuntMan(x,y)
					break;
				case 25:
					ac = new ac.piou.Runner(x,y)
					break;
				case 26:
					ac = new ac.piou.Ghost(x,y)
					break;
				case 27:
					ac = new ac.piou.LaserSlash(x,y)
					break;						
			}
			ac.id = id;
			return ac
	}
	function onMouseRelease(){
		
	}
	function updateRollOverPiou(){
		if(Key.isDown(Key.CONTROL))return;
		if(selectedPiou==null){
			selectedPiou = dm.attach("mcPiouCircle",DP_PART)
		}
		
		xm = int(map._xmouse)
		ym = int(map._ymouse)	

		var o = Inter.getActionSlot(Inter.cid)
		var ac = getAction(Inter.cid,xm,ym)
		if(ac.isAvailable()){
			var p = downcast(ac).piou
			selectedPiou._visible = true;
			selectedPiou._x = p.x
			selectedPiou._y = p.y
			//dm.over(p.root)
		}else{
			selectedPiou._visible = false;
		}
		
		/*
		if(selectedPiou!=null){
			selectedPiou.mcCircle.removeMovieClip();
			selectedPiou = null
		}
		xm = int(map._xmouse)
		ym = int(map._ymouse)		
		var o = Inter.getActionSlot(Inter.cid)
		var ac = getAction(Inter.cid,xm,ym)
		if(ac.isAvailable()){
			selectedPiou = downcast(ac).piou
			selectedPiou.mcCircle =  Std.attachMC(selectedPiou.root,"mcPiouCircle",55)
			selectedPiou.mcCircle._y -= Piou.RAY
		}
		*/
	}
	
	// DEBUG
	function toggleLog(){
		flLog = !flLog
		if(flLog){
		mcLog = downcast(mdm.attach("mcLog",11))
		mcLog.field.text = Cs.logText
		}else{
			mcLog.removeMovieClip();
		}
	}
	
	// VIEWER
	function initViewer(){
		
	}
	
	
	// EXIT GAME
	
	function reset(){
		if(flHelp)toggleHelp();
		if(flEndPanel)removeEndPanel();
		//if(flPause)togglePause()
		Inter.flButWait = true;	
		initStep(4)
			
	}
	function fastExit(){
		if(flHelp)toggleHelp();
		if(flEndPanel)removeEndPanel();
		Inter.flButWait = true;
		initStep(5)
	}
	function exitGame(){
		var data = {
			$time   : endTime,
			$piouz  : piouIn,
			$pid    : pid,
			$theme  : Level.did,
			$soluce : null
		};
		if (gameMode == 1){
			data.$soluce = new PersistCodec().encode({history:history});
		}
		elv = LoaderInterface.exitGame(data);
		Cs.log("-$time"+endTime);
		Cs.log("-$piouz"+piouIn);
		Cs.log("-$pid"+pid);
	}
	function redirect(data){
		//Cs.log("redirect to "+data.substring(4))
		new LoadVars().send(data.substring(4),"_self","POST")
	}
	function giveUp(){
		//Log.trace("giveUp!")
		piouIn = 0;
		exitGame();
		elv.onData = callback(this,reload);		
	}
	function reload(data){
		//Log.trace("Reload!")
		Mouse.removeListener(ml)
		Key.removeListener(kl)
		while(hintList.length>0)hintList.pop().removeMovieClip();
		if(mcPauseComment!=null){
			mcPauseComment.removeMovieClip();
			mcPauseComment = null;
		}
		Manager.init(Manager.root_mc);
	}
	
	//
	function playAgain(){
		mcEndPanel.removeMovieClip();
		reload(null);
		//reset();
	}
	function gotoPioupiouz(){
		var lv = new LoadVars();
		//lv.send("http://www.pioupiouz.com/?ref=tfou","_blank",null);
		lv.send("jump_page.htm","_blank",null);
	}
	
	
//{
}


// BASIC
// 0 3 7 20

// NATURE
// 1 11 15 18

// TECHNO
// 2 4 17 21

// MAGIC
// 5 6 9 16 19

// FLESH
// 10 12 13 14

// ???
// 8 22


// IDEES ACTIONS
// - power slash
// - round Lazer
// - gonflage de piou
// - racine monte demi-tour




