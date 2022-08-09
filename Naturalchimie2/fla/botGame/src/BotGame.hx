import flash.Key ;
import mt.bumdum.Lib ;
import mt.bumdum.Part ;
import mt.bumdum.Sprite ;
import mt.bumdum.Phys ;
import GameData._ArtefactId ;
import Game.GameStep ;
import anim.Transition ;
import anim.Anim.AnimType ;
import StageObject.DestroyMethod ;


typedef Pos = {x : Int, y : Int} ;
typedef PlayParse = {pos : Pos, next : Array<Pos>} ;

typedef PlayTest = {
	var pos : Pos ;
	var o : StageObject ;
	var toParse : Array<PlayParse> ;
}



class BotGame {
	
	public static var DATADOMAIN = "http://data.naturalchimie.com" ;
	public static var DOMAIN = "http://www.naturalchimie.com" ;
	/*public static var DATADOMAIN = "http://dev.naturalchimie2.com" ;
	public static var DOMAIN = "http://dev.naturalchimie2.com" ;*/
	public var loader : Load ;
	public static var me : BotGame ;
	
	public static var FL_SPEAK  =true ;
	
	static public var objectsList : Array<StageObject> = new Array() ;
	
	public var rdm : mt.DepthManager ;
	public var mdm : mt.DepthManager ;
	public var root : flash.MovieClip ;
	public var mc : flash.MovieClip ;
	public var bmpFile : flash.MovieClip ;
	public var bg : flash.MovieClip ;
	public var bgInfos : {x : Int, y : Int} ;
	
	
	public var artefact : Array<StageObject> ;
	public var onEndFall : Array<Void -> Void> ;
	
	public var step : GameStep ;
	public var gameOver : Bool ;
	public var mode : mode.GameMode ;
	public var stage : Stage ;
	public var picks : Array<PickUp> ;
	
	public var speak : BotSpeak ;
		
	public var mcBg : {>flash.MovieClip, _bg : flash.MovieClip, _wheel_0 : flash.MovieClip, _wheel_1 : flash.MovieClip} ;
	public var rWheels : Array<{wmc : flash.MovieClip, step : Int, values : Array<Float>, wait : Float}> ;
	public var mcInterface : {>flash.MovieClip, _pnj : flash.MovieClip, _top : flash.MovieClip} ;
	public var bgc : Int ;
	public var goStep : Int ;
	public var goAnim : anim.Anim ;
	public var goMc : flash.MovieClip ;
	public var groupMask : flash.MovieClip ;
	var goPicks : Array<StageObject> ;
	
	var playInfos : {x : Int, r : Int} ;
	
	var fl_lock : Bool ;
	
	var gTimer : Float ;
	var kl : Dynamic ;
	var ckl : Dynamic ;

	
	public function new(mc : flash.MovieClip, l : BotLoader) {
		for (d in ["www","beta","data", "dev"])
			flash.system.Security.allowDomain(d+".naturalchimie.com") ;
		
		if (Reflect.field(flash.Lib._root,"dv") == "true") {
			DATADOMAIN = "http://dev.naturalchimie2.com" ;
			DOMAIN = "http://dev.naturalchimie2.com" ; 
		}
		
		Const.BOT_MODE = true ;
 		Game.me = cast this ;
		Const.WIDTH = 180 ;
		Const.HEIGHT = 260 ;
		Const.NEXTPOS = {x : 500, y : 181} ;
		Const.GROUP_Y = Const.ELEMENT_SIZE - 15 ;
		Stage.LIMIT = 6 ;
		Stage.DIFF_SPLIT = 2 ;
		Stage.X = 21 ;
		Stage.BY = -25 ;
		Const.NEXTPOS = {x : -100, y : -100} ;
		
		
		fl_lock = false ;
		root = mc ;
		loader = l ;
		me = this ;
		gameOver = false ;
		artefact = new Array() ;
		picks = new Array() ;
		onEndFall = new Array() ;
		step = Wait ;
		
		rdm = new mt.DepthManager(root) ;
		this.mc = rdm.empty(3) ;
		mdm = new mt.DepthManager(this.mc) ;
		
		ObjectMc.initMc(DATADOMAIN + "/swf/welMc.swf", mdm, 0, callback(function() { Game.me.loader.done() ; BotGame.me.start() ;})) ;				
		
		loader.initLoading(2) ;
		init() ;
	}
	
	function init() {	
		initInterface() ;
		initBg() ;
		initGame() ;
		
		speak = new BotSpeak(mcInterface._pnj) ;
		
		loader.done() ;
	}
	
	
	function initInterface() {
		mcBg = cast mdm.attach("intro", Const.DP_BG) ;
		mcInterface = cast mdm.attach("inter", Const.DP_INTERFACE) ;
		mcInterface._pnj.gotoAndStop(Std.random(4) + 1) ;
		
		Filt.glow(mcInterface._pnj, 2, 2, 0x1A1612, true) ;
		Filt.glow(mcInterface._pnj, 6, 0.5, 0x1A1612) ;
		
		rWheels = [{wmc : mcBg._wheel_0, step : 0, wait : 10.0, values : [16.0, -3.0, 4.0]},
				{wmc : mcBg._wheel_1, step : 0, wait : 10.0, values : [6.0 ,-2, 2.0]}] ;
		
		groupMask = mdm.attach("play_mask", Const.DP_GROUP_BOX) ;
		groupMask._alpha = 0 ;
		
	}
	
	function initBg() {
		bmpFile = mcBg._bg ;
		
		var mcl = new flash.MovieClipLoader() ;
		var me = this ;
		mcl.onLoadError = function(_,err) {
			me.loader.reportError(err);
		}
		
		#if halloween
			var dispBgs = [{src : "intro/jzclai2.jpg", x : 5, y : 14}] ;
		#elseif xmas
			var dispBgs = [{src : "intro/apfbg2.jpg", x : 5, y : 14}] ;
		#else
			var dispBgs = [{src : "intro/gmprai2.jpg", x : 5, y : -5},
					{src : "intro/guildian2.jpg", x : -5, y : -40},
					{src : "intro/jzcata2.jpg", x : -5, y : -5},
					{src : "intro/sktupu2.jpg", x : -5, y : -5}] ;
		#end
		
		bgc = Std.random(dispBgs.length) ;
					
		bmpFile._x = dispBgs[bgc].x ;
		bmpFile._y = dispBgs[bgc].y ;
					
		mcl.onLoadInit = function(_) {
			Filt.blur(BotGame.me.bmpFile,1.3,1.3);
		} ;

		mcl.loadClip(DATADOMAIN + "/img/bg/" + dispBgs[bgc].src, bmpFile) ;	
	}

	
	
	function initGame() {
		mode = new mode.GameMode() ;
		var e = [_Elt(0), _Elt(1), _Elt(2), _Elt(3), _Elt(4), _Elt(5), _Elt(6), _Elt(7), _Elt(8), _Elt(9), _Elt(10), _Elt(11)] ;
		mode.setChain(e, [18, 18, 18, 18, 12, 8, 7, 5, 4, 1, 1, 0]) ;
		mode.level = Std.random(7) + 3 ;
		mode.chainKnown = 12 ;
		
		var mult = 1 ;
		
		mode.useBonus = -1 ;
		
		
		#if halloween
			var arts = [{_id : _Elts(2, _Pumpkin(0)), _freq : 1500},
					{_id : _Elts(2, _Pumpkin(1)), _freq : 1500},
					{_id : _Elts(2, _Pumpkin(2)), _freq : 1500}] ;
		#elseif xmas
			var arts = [{_id : _Elts(2, _NowelBall), _freq : 2000},
					{_id : _Elts(2, _Choco), _freq : 1250},
					{_id : _Elts(2, _SnowBall), _freq : 1250}] ;
		#else
			var arts = [{_id : _Elts(2, null), _freq : 4000}] ;
		#end
			
		arts = arts.concat([{_id : _Dynamit(0), _freq : 95 * mult},
			{_id : _Dynamit(1), _freq : 95 * mult},
			{_id : _Dynamit(2), _freq : 40 * mult},
			{_id : _PearGrain(0), _freq : 50 * mult},
			{_id : _PearGrain(1), _freq : 80 * mult},
			{_id : _MentorHand, _freq : 50 * mult},
			{_id : _Alchimoth, _freq : 70 * mult}]) ;
		mode.setArtefacts(arts) ;
	}
	
	
	public function releaseArtefact(a : StageObject) : Bool {
		return artefact.remove(a) ;
	}
	
	
	public function initPickUp(?forceNew = false, ?m : flash.MovieClip, ?c : {x : Float, y : Float}) {
		if (!forceNew) {
			if (picks.length > 0)
				return picks[picks.length - 1] ;
		} 
		
		var np = new PickUp(m, c) ;
		picks.push(np) ;
		return np ;
	}
	
	
	public function start() {
		//mcInterface._top.useHandCursor = true ;
		/*mcInterface._top.onRelease = callback(function(b : BotGame) {
				var lv = new flash.LoadVars() ;
				lv.send(BotGame.DOMAIN + "/user/demoSub", "_self") ;
				b.loader.initLoading(1) ;
				(cast b.loader).loading._alpha = 0 ;
				var a = new anim.Anim((cast b.loader).loading, Alpha(1), Quint(1), {speed : 0.1}) ;
				a.start() ;
			}, this) ;*/
		
		stage = new Stage() ;
		
		var grid = null ;
		
		stage.init(grid) ;
		step = Play ;
	}
	
	
	public function hideLoading(mc : flash.MovieClip) {
		var a = new anim.Anim(mc, Alpha(-1), Quint(-1), {speed : 0.1}) ;
		a.onEnd = callback(function(m : flash.MovieClip) { m.removeMovieClip() ;}, mc) ;
		a.start() ;
	}
	
	
	
	function updateWheels(?quick = false) {
		
		for (i in 0...rWheels.length) {
			var w = rWheels[i] ;
			var v = (if (quick) 15.0 else 1.0) * mt.Timer.tmod ;
				
			if (quick && w.step != 0)
				w.step = 0 ;
			
			switch(w.step) {
				case 0 : //rotate
					w.wmc._rotation =  (w.wmc._rotation + v) % 360 ;
					w.wait = Math.max(w.wait - v, 0.0) ;
					if (w.wait == 0.0 && !quick) {
						w.step = 1 ;
						w.wait = Math.abs(w.values[w.step]) ;
					}
				case 1 : //un rotate
					w.wmc._rotation = (w.wmc._rotation - v) % 360 ;
					w.wait = Math.max(w.wait - v, 0.0) ;
					if (w.wait == 0.0) {
						w.step = 2 ;
						w.wait = w.values[w.step] ;
					}
					
				case 2 :
					w.wait = Math.max(w.wait - 0.1 * mt.Timer.tmod, 0.0) ;
					if (w.wait == 0.0) {
						w.step = 0 ;
						w.wait = w.values[w.step] ;
					}
			}
		}
	}
	
	
	
	
	public function loop() {
		mt.Timer.update() ;
		//trace(mt.Timer.fps() + " # " + mt.Timer.tmod) ;
		updateSprites() ;
		updateObjects() ;
		updateMoves() ;
		updateWheels() ;
		
		if (speak != null)
			speak.update() ;
		
		if (flash.Key.isDown(Key.SHIFT))
			fl_lock = false ;
		else if (flash.Key.isDown(Key.CONTROL))
			fl_lock = true ;
		
		if (fl_lock)
			return ;
				
		if (picks.length > 0) {
			for( p in picks.copy()) {
				p.update() ;
			}
		}
		
		if (stage == null)
			return ;
		
		stage.updateEffect() ;
		stage.fall() ;
		
		switch(step) {
			case Loading :
			
			case Wait :
				/*if (stage.next != null) {
					stage.next.update() ;
				}*/
				
			case Play :
				if (stage.next != null)
					stage.next.update() ;
				
				if (stage.next.col == playInfos.x && stage.next.r == playInfos.r && !stage.next.isMoving && !stage.next.isRotating) {
					//trace(stage.next.col + " # " + playInfos.x + " # " + stage.next.r + " # " + playInfos.r + " # " + stage.next.isMoving + " # " + stage.next.isRotating) ;
					playInfos = null ;
					stage.release() ;
				} else {
					if (stage.next.r != playInfos.r && !stage.next.isRotating)
						stage.rotate() ;
				}

				
			case Fall :
				if (!stage.isFalling()) {
					if (!stage.check()) {
						if (!mode.checkFallEnd()) {
							stage.updateStaticScore() ;
							stage.startPlay() ;
						}
					} else {
						mode.onTransform() ;
						stage.startTransformation() ;
					}
				}
				
			case Transform :
				if (!stage.transform())
					stage.startFall() ;
				
			case Destroy : 
				if (!stage.destroy())
					stage.startFall() ;
				
			case ArtefactInUse :
				if (artefact.length == 0)
					stage.startFall() ;
				else {
					for (a in artefact) {
						a.updateEffect() ;
					}
				}
				
			case GameOver :
				if (stage.toDestroy.length == 0) {
					stage.kill() ;
					initGame() ;
					start() ;
					return ;
				}
				
			
				for (o in stage.toDestroy.copy()) {
					o.updateDestroy() ;
				}
				
				
			case Mode : 
				mode.loop() ;
		}
	}
	
	
	function updateSprites() {
		var list = Sprite.spriteList.copy() ; 
		for (s in list) s.update() ;
	}
	
	function updateObjects() {
		var list = Game.objectsList.copy() ; 
		for (s in list) s.update() ;
	}
	
	
	function updateMoves() {		
		var list = anim.Anim.onStage.copy() ; 
		for (m in list) m.update() ;
	}
	
	
	
	public function setGameOver() {
		var w = 20.0 ;
		
		
		for (iy in 0...Stage.HEIGHT) {
			var y = Stage.HEIGHT - 1 - iy ;
			for (x in 0...Stage.WIDTH) {
				var o = stage.grid[x][y] ;
				if (o == null)
					continue ;
				o.toDestroy(Flame(true), w) ;
				//trace("Destroy " + x + ", " + y + " # " + w) ;
				w += 2.0 ;
			}
		}
				
		setStep(GameOver) ;
		
		
	}
	
	
	public function setStep(s, ?a : StageObject) {
		if (s == ArtefactInUse) {
			step = s ;
			artefact.push(a) ;
		} else {
			if (artefact.length == 0)
				step = s ;
			else 
				trace("error : step " + s +  " with living artefactInUse") ;
		}
		
		if (step == Play && playInfos == null) {
			playInfos = getPlayInfos(stage.next) ;
			//trace("PLAY x : " + playInfos.x + ", r : " + playInfos.r) ;
		}
	}
	
	
	function getPlayInfos(g : Group) : {x : Int, r : Int} {
		var rTest = 4 ;
		var last= -1000 ;
		var tres = new Array() ;
		
		if (g.objects.length == 1)
			return getPlayInfosArtefact(g) ;
		
		var gInfos = new Array() ;
		for(x in 0...Stage.WIDTH) {
			gInfos.push(stage.getLastColElement(x)) ;
		}
		
		for(x in 0...Stage.WIDTH) {
			var nlast =  -1000 ;
			
			for (tr in 0...rTest) {
				var isVertical = tr == 1 || tr == 3 ;
				if (x == Stage.WIDTH - 1 && !isVertical)
					continue ;
					
				nlast = getPlayValue(g, x, tr, gInfos) ;		
				if (tres[nlast] == null)
					tres[nlast] = new Array() ;
				tres[nlast].push({x : x, r : tr}) ;
				
			}
		}
		
		var i = tres.length - 1 ;
		
	/*	trace("##################") ;
		for (i in 0...tres.length) {
			trace(i + " # " + Std.string(tres[i])) ;
		}
	*/
		while (i >= 0) {
			var r = tres[i] ;
			if (r == null || r.length == 0)
				i-- ;
			else {
				//trace("### CHOOSE IN " + i) ;
				return r[Std.random(r.length)] ;
			}
		}
		
		return {x : Std.random(Stage.WIDTH), r : 0} ;
	}
	
	
	
	function getPlayValue( g : Group, x : Int, r : Int, gInfos : Array<{o : _ArtefactId, y : Int}>) : Int {
		/*trace("play value : " + x + ", " + r) ;
		trace(gInfos) ;*/
		/*
		0 : zone vide ou pas d'adjacence
		1 : 1 adjacence
		2 : 2 adjacences
		
		+ 1 pour une transmut effective
		*/
		
		var toTest = new Array() ;
		var toErase = new Array() ;
		var y = null ;
		var yMax = null ;
		
		switch(r) {
			case 0 :
				y =if (gInfos[x] == null) 0 else (gInfos[x].y) ;
				yMax = y ;
				toTest.push({o : g.objects[0], pos : {x : x, y : y}, toParse : [{pos : {x : x-1, y : y}, next : [{x : x - 2, y : y}, {x : x - 1, y : y - 1}, {x : x - 1, y : y + 1}]},
																{pos : {x : x+1, y : y}, next : [{x : x + 2, y : y}, {x : x + 1, y : y - 1}, {x : x + 1, y : y + 1}]},
																{pos : {x : x, y : y - 1}, next : [{x : x - 1, y : y - 1}, {x : x + 1, y : y - 1}, {x : x , y : y - 2}]}]}) ;
																	
																	
				stage.grid[x][y] = g.objects[0] ;
				toErase.push({x : x, y : y}) ;
																	
				y =if (gInfos[x + 1] == null) 0 else (gInfos[x + 1].y) ;
				yMax = Std.int(Math.max(yMax, y)) ;
				toTest.push({o : g.objects[1], pos : {x : x + 1, y : y}, toParse : [{pos : {x : x + 2, y : y}, next : [{x : x + 3, y : y}, {x : x + 2, y : y - 1}, {x : x + 2, y : y + 1}]},
																{pos : {x : x, y : y}, next : [{x : x - 1, y : y}, {x : x, y : y - 1}, {x : x, y : y + 1}]},
																{pos : {x : x + 1, y : y - 1}, next : [{x : x, y : y - 1}, {x : x + 2, y : y - 1}, {x : x + 1 , y : y - 2}]}]}) ;
				stage.grid[x + 1][y] = g.objects[1] ;
				toErase.push({x : x + 1, y : y}) ;
				
				
			case 1 : 
				y =if (gInfos[x] == null) 0 else (gInfos[x].y) ;
				toTest.push({o : g.objects[1], pos : {x : x, y : y}, toParse : [{pos : {x : x-1, y : y}, next : [{x : x - 2, y : y}, {x : x - 1, y : y - 1}, {x : x - 1, y : y + 1}]},
																{pos : {x : x+1, y : y}, next : [{x : x + 2, y : y}, {x : x + 1, y : y - 1}, {x : x + 1, y : y + 1}]},
																{pos : {x : x, y : y - 1}, next : [{x : x - 1, y : y - 1}, {x : x + 1, y : y - 1}, {x : x , y : y - 2}]}]}) ;
				stage.grid[x][y] = g.objects[1] ;
				toErase.push({x : x, y : y}) ;
				
				y++ ;
				yMax = y ;
				toTest.push({o : g.objects[0], pos : {x : x, y : y}, toParse : [{pos : {x : x-1, y : y}, next : [{x : x - 2, y : y}, {x : x - 1, y : y - 1}, {x : x - 1, y : y + 1}]},
																{pos : {x : x+1, y : y}, next : [{x : x + 2, y : y}, {x : x + 1, y : y - 1}, {x : x + 1, y : y + 1}]},
																{pos : {x : x, y : y - 1}, next : [{x : x - 1, y : y - 1}, {x : x + 1, y : y - 1}, {x : x , y : y - 2}]}]}) ;
				stage.grid[x][y] = g.objects[0] ;
				toErase.push({x : x, y : y}) ;
				
				
			case 2 :
				y =if (gInfos[x] == null) 0 else (gInfos[x].y) ;
				yMax = y ;
				toTest.push({o : g.objects[1], pos : {x : x, y : y}, toParse : [{pos : {x : x-1, y : y}, next : [{x : x - 2, y : y}, {x : x - 1, y : y - 1}, {x : x - 1, y : y + 1}]},
																{pos : {x : x+1, y : y}, next : [{x : x + 2, y : y}, {x : x + 1, y : y - 1}, {x : x + 1, y : y + 1}]},
																{pos : {x : x, y : y - 1}, next : [{x : x - 1, y : y - 1}, {x : x + 1, y : y - 1}, {x : x , y : y - 2}]}]}) ;
				stage.grid[x][y] = g.objects[1] ;
				toErase.push({x : x, y : y}) ;
																	
				y =if (gInfos[x + 1] == null) 0 else (gInfos[x + 1].y) ;
				yMax = Std.int(Math.max(yMax, y)) ;
				toTest.push({o : g.objects[0], pos : {x : x + 1, y : y}, toParse : [{pos : {x : x + 2, y : y}, next : [{x : x + 3, y : y}, {x : x + 2, y : y - 1}, {x : x + 2, y : y + 1}]},
																{pos : {x : x, y : y}, next : [{x : x - 1, y : y}, {x : x, y : y - 1}, {x : x, y : y + 1}]},
																{pos : {x : x + 1, y : y - 1}, next : [{x : x, y : y - 1}, {x : x + 2, y : y - 1}, {x : x + 1 , y : y - 2}]}]}) ;
				stage.grid[x + 1][y] = g.objects[0] ;
				toErase.push({x : x + 1, y : y}) ;
				
			case 3 : 
				y =if (gInfos[x] == null) 0 else (gInfos[x].y) ;
				toTest.push({o : g.objects[0], pos : {x : x, y : y}, toParse : [{pos : {x : x-1, y : y}, next : [{x : x - 2, y : y}, {x : x - 1, y : y - 1}, {x : x - 1, y : y + 1}]},
																{pos : {x : x+1, y : y}, next : [{x : x + 2, y : y}, {x : x + 1, y : y - 1}, {x : x + 1, y : y + 1}]},
																{pos : {x : x, y : y - 1}, next : [{x : x - 1, y : y - 1}, {x : x + 1, y : y - 1}, {x : x , y : y - 2}]}]}) ;
				stage.grid[x][y] = g.objects[0] ;
				toErase.push({x : x, y : y}) ;
				
				y++ ;
				yMax = y ;
				toTest.push({o : g.objects[1], pos : {x : x, y : y}, toParse : [{pos : {x : x-1, y : y}, next : [{x : x - 2, y : y}, {x : x - 1, y : y - 1}, {x : x - 1, y : y + 1}]},
																{pos : {x : x+1, y : y}, next : [{x : x + 2, y : y}, {x : x + 1, y : y - 1}, {x : x + 1, y : y + 1}]},
																{pos : {x : x, y : y - 1}, next : [{x : x - 1, y : y - 1}, {x : x + 1, y : y - 1}, {x : x , y : y - 2}]}]}) ;
				stage.grid[x][y] = g.objects[1] ;
				toErase.push({x : x, y : y}) ;
		}
		
		var res = 2 ;
		for (t in toTest) {
			res += pTest(t) ;
		}
		
		if (yMax > 4)
			res -= 4 ;
		else if (yMax > 3)
			res -= 1 ;
		
		if (res < 0)
			res = 0 ;
		
		
		for (e in toErase) {
			//trace("erase " + e.x + ", " + e.y) ;
			stage.grid[e.x][e.y] = null ;
		}
		
		return res ;
	}
	
	
	function pTest(t : PlayTest) : Int{
		var res = 0 ;
		var subRes = 0 ;
		for (p in t.toParse) {
		//	trace(p) ;
			var no = stage.grid[p.pos.x][p.pos.y] ;
			if (no == null)
				continue ;
			
			//trace(Std.string(t.o.getArtId()) + " # " + Std.string(no.getArtId())) ;
			if (!Type.enumEq(t.o.getArtId(), no.getArtId()))
				continue ;
			
			//trace("found") ;
			res ++ ;
			
			for (pt in p.next) {
				var no = stage.grid[p.pos.x][p.pos.y] ;
				if (no == null)
					continue ;
				
				if (!Type.enumEq(t.o.getArtId(), no.getArtId()))
					continue ;
				
				subRes++ ;
				break ;
			}
		}
		
		if (res > 1) //transmut directe
			res++ ;
		
		return res + subRes ;
	}
	
	
	
	function getPlayInfosArtefact(g : Group) : {x : Int, r : Int} {
		var a = g.objects[0].getArtId() ;
		var res = {x : 0, r : 0} ;
		var last = -1000 ;
		
		switch(a) {
			case _Dynamit(level) : 
				for (x in 0...Stage.WIDTH) {
					var c = stage.getLastColElement(x) ;
					var nlast = 0 ;
					if (c != null) {
						nlast = if (level != 1) 
									11 - c.y
								else 
									c.y ;
					}
					
					if (nlast > last) {
						res.x = x ;
						last = nlast ;
					}
				}
				
			case _PearGrain(level) : 
				if (level == 1)
					return {x : 2, r : 0} ;
					
				for (x in 0...Stage.WIDTH) {
					var c = stage.getLastColElement(x) ;
					var nlast = 0 ;
					if (c != null)
						nlast = c.y ;
					
					if (nlast > last) {
						res.x = x ;
						last = nlast ;
					}
				}
				
				
			case _Alchimoth, _MentorHand : 
				var a = new Array() ;
				for (x in 0...Stage.WIDTH) {
					var c = stage.getLastColElement(x) ;
					var nlast = 0 ;
					if (c != null)
						a.push(x) ;
				}
				
				if (a.length == 0)
					res.x = Std.random(Stage.WIDTH) ;
				else
					res.x = a[Std.random(a.length)] ;
			
			default : res.x = Std.random(Stage.WIDTH) ; //unused
		}
		
		return res ;
	}
	
	
	public function canPlay() {
		return step == Play ;
	}

	
	
}