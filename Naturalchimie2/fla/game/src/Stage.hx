import flash.Key ;
import mt.bumdum.Lib ;
import mt.bumdum.Part ;
import mt.bumdum.Sprite ;
import anim.Anim.AnimType ;
import anim.Transition ;
import Game.GameStep ;
import mode.GameMode.TransformInfos ;
import GameData._ArtefactId;



enum TempEffect {
	FxDaltonian ; //group.init ==> gameMode
	FxTriplex ; //gameMode.getNext
	FxDelorean ; //gameMode.transformInfo
	FxDollyxir ; //Stage/Element.transform ==> transformInfos
	FxJeseleet3 ; //group.init ==> gameMode
	FxJeseleet4 ; //group.init ==> gameMode
}



class Stage {
	
	static public var MCEFFECT_HIDE_Y = -91 ;
	static public var ICON_EFFECT_X = /*27*/ 24 ;
	static public var ICON_EFFECT_Y = 56 ;
	static public var WIDTH = 6 ;
	static public var HEIGHT = 11 ;
	static public var DIFF_SPLIT = 0 ;
	static public var LIMIT = 7 ;
	static public var X = 10 ; //old : 4
	static public var Y = 22 ;
	static public var BY = 5 ;
	static public var LIMIT_Y = Const.HEIGHT - (Stage.BY + (LIMIT) * Const.ELEMENT_SIZE) ;
	
	
	public var mc : flash.MovieClip ;
	public var dm : mt.DepthManager ;

	public var next : Group ;
	public var nexts : List<Group> ;
	public var lastNextSize : Int ;
		
	public var effect : {fx : TempEffect, leftPlays : Int, from : StageObject} ;
	
	//public var mcEffect : {>flash.MovieClip, _field : flash.TextField, icon : {>flash.MovieClip, bmp : flash.display.BitmapData}} ;
	var animEffect : Array<anim.Anim> ;
	var curAnimEffect : anim.Anim ;
	public var mcEffect : {>flash.MovieClip, 
						from : StageObject,
						toHide : Bool,
						_help : flash.TextField, 
						_nb : flash.TextField, 
						_icon : flash.MovieClip,
						_wheel_1 : flash.MovieClip,
						_wheel_2 : flash.MovieClip,
						_wheel_3 : flash.MovieClip,
						_wheel_4 : flash.MovieClip,} ;
	public var rWheels : Array<{wmc : flash.MovieClip, step : Int, values : Array<Float>, wait : Float}> ;
	public var dmEffect : mt.DepthManager ;
	public var animMasks : Array<flash.MovieClip> ;
		
	public var comboCount : mt.flash.Volatile<Int> ;
	public var shakeTimer : Float ;
		
	public var grid : Array<Array<StageObject>> ;
	public var falls : Array<StageObject> ;
	public var groups : Array<Array<StageObject>> ;
	public var killParasits : Array<StageObject> ;
	public var transforms : Array<StageObject> ;
	public var toDestroy : Array<StageObject> ;
	public var reserved : Array<StageObject> ;

	
	public function new() {
		mc = Game.me.mdm.attach("playArea", Const.DP_STAGE) ;
		mc._x = 0 ;
		mc._y = 0 ;
		dm = new mt.DepthManager(mc.smc) ;
	
		createBg() ;
		
		mcEffect = cast dm.attach("help", Const.DP_EFFECT) ;
		mcEffect.gotoAndStop(1) ;
		mcEffect._wheel_1.gotoAndStop(Std.random(15) + 1) ;
		mcEffect._wheel_2.gotoAndStop(Std.random(15) + 1) ;
		mcEffect._wheel_3.gotoAndStop(Std.random(15) + 1) ;
		mcEffect._wheel_4.gotoAndStop(Std.random(15) + 1) ;
		mcEffect._y = MCEFFECT_HIDE_Y ;
		dmEffect = new mt.DepthManager(mcEffect) ;
		
		rWheels = [{wmc : mcEffect._wheel_1, step : 0, wait : 10.0, values : [16.0, -3.0, 4.0]},
				{wmc : mcEffect._wheel_2, step : 0, wait : 10.0, values : [7.0, -2.0, 2.0]},
				{wmc : mcEffect._wheel_3, step : 0, wait : 10.0, values : [8.0, -3, 3.0]},
				{wmc : mcEffect._wheel_4, step : 0, wait : 10.0, values : [6.0 ,-2, 2.0]}] ;
		
		shakeTimer = 0.0 ;
		
		comboCount = -1 ;
		
		grid = new Array() ;
		nexts = new List() ;
		falls = new Array() ;
		groups = new Array() ;
		toDestroy = new Array() ;
		animEffect = new Array() ;
		for (i in 0...WIDTH) {
			grid[i] = new Array() ;
		}
		
		animMasks = new Array() ;
		for (i in 0...2) {
			var animMask = Game.me.mdm.empty(Const.DP_MASK) ;
			animMask._x = 0 ;
			animMask._y = 0 ;
			animMask.beginFill(1, 0) ;
			
			if (!Const.BOT_MODE) {
				animMask.moveTo(X, 0) ;
				animMask.lineTo(X + Stage.WIDTH * Const.ELEMENT_SIZE, 0) ;
				animMask.lineTo(X + Stage.WIDTH * Const.ELEMENT_SIZE, Const.HEIGHT - BY) ;
				animMask.lineTo(X, Const.HEIGHT - BY) ;
				animMask.lineTo(X, 0) ;
			} else {
				var sx = 20.6 ;
				var sy = 15.0 ;
				animMask.moveTo(sx, sy) ;
				animMask.lineTo(197.7, 25.8) ;
				animMask.lineTo(200.8, 282.3) ;
				animMask.lineTo(22.1, 284.6) ;
				animMask.lineTo(sx, sy) ;
			}
			animMask.endFill() ;
			
			animMasks.push(animMask) ;
		}
		
		//forceGrid() ;
		//forceComboGrid([10, 9, 8, 7, 6]) ;
	}
	
	
	public function createBg() {
		Game.me.bg = dm.empty(Const.DP_WALLPAPER);
	}
	
	
	public function initBgImg() {
		//Game.me.bg = dm.empty(Const.DP_WALLPAPER);
		var bi = Game.me.data._bg.split(":") ;
		Game.me.bg._x = Game.me.bgInfos.x ;
		Game.me.bg._y = Game.me.bgInfos.y ;	

		
		var mcl = new flash.MovieClipLoader() ;
		var me = Game.me ;
		mcl.onLoadInit = function(_) {
			Filt.blur(Game.me.bg,1.3,1.3);
		}
		mcl.loadClip(Game.me.loader.dataDomain + "/img/bg/" + bi[2] + ".jpg", Game.me.bg ) ;
		

		setFader();
		setLimit() ;
	}
	
	
	function setLimit() {
		var l = dm.attach("limite", Const.DP_LIMITE) ;
		l._x = 0 ;
		l._y = LIMIT_Y ;
	}
	function setFader() {
		var f = dm.attach("fader", Const.DP_FADER) ;
		f.blendMode = "overlay";
	}
	
	public function init(gridStart) {
		if (gridStart != null)
			initGrid(gridStart) ;
		else 
			Game.me.mode.initStage(this) ;
		
		//nexts.push(new Group(true)) ;
		initNext() ;
	}
	
	public function initNext() {
		if (nexts.length > 0) {
			for (g in nexts)
				g.kill() ;
		}
		
		nexts.push(new Group()) ;
		getNext() ;
	}
	
	
	function initGrid(g : Array<{_id : _ArtefactId, _x : Int, _y : Int}>) {
		if (g == null)
			return ;
		
		forceEmpty() ;
		
		for (e in g) {
			var chain_Index = Game.me.mode.isInChain(e._id) ;
			var o = if (chain_Index != null)
						new Element(chain_Index, dm, Stage.HEIGHT - e._y) ;
					else
						StageObject.get(e._id, dm, Stage.HEIGHT - e._y) ;
			
			var cx = next.col + o.x ;
			var cy = HEIGHT - (Const.GROUP_LINE + o.y) ;
			var yy = Const.HEIGHT - (Stage.BY + (cy + 1 - (if( next.isVertical()) 0.5 else 0)) * Const.ELEMENT_SIZE) ;

			o.place(e._x, e._y, X + e._x * Const.ELEMENT_SIZE , Const.HEIGHT - (Stage.BY + (e._y + 1) * Const.ELEMENT_SIZE)) ;
			
			add(o) ;
		}
	}
	
	
	public function startFall() {
		var news = new Array() ;
		if (next != null)
			news = split() ;
		
		var cut = false ;
		for (o in news) {
			cut = cut || o.onFall() ;
		}
		
		if (cut)
			return ;
		
		Game.me.sound.play("chute") ;
		comboCount++ ;
		
		targetFalls() ;
		Game.me.setStep(Fall) ;
	}
	
	
	function split() {
		var res = new Array() ;
		var i = 0 ;
		
		lastNextSize = next.objects.length ;
		
		for (o in next.objects) {
			var no = reserved.shift() ;
			var b = o.omc.mc.smc.getBounds(mc) ;
			
			var cx = next.col + o.x ;
			var cy = HEIGHT - DIFF_SPLIT - (Const.GROUP_LINE + o.y) ;
			var yy = Const.HEIGHT - (Stage.BY + (cy + 1 - (if( next.isVertical()) 0.5 else 0)) * Const.ELEMENT_SIZE) ;

			no.place(cx, cy, X + cx * Const.ELEMENT_SIZE , yy) ;
			
			add(no) ;
			res.push(no) ;
			i++ ;
		}
		next.kill() ;
		next = null ;
		
		return res ;
	}
	
	
	public function add(o : StageObject) {
		grid[o.x][o.y] = o ;
	}
	
	public function updateStaticScore() {
		Game.me.mode.addToScore(Std.int(Math.max((comboCount - 1) * Const.COMBO_BONUS, 0))) ;
		comboCount = -1 ;
	}
	
	public function startPlay() {
		
		if (Game.me.checkQuest()) {
			Game.me.setMissionCompleted() ;
			return ;
		}
			
		if (checkEnd()) {
			Game.me.setGameOver() ;
			return ;
		}
		
		//Game.me.setStep(Fall) ;
		//Game.me.setSpiritState(null) ;
		getNext() ;
	}
	
	
	public function startTransformation() {
		Game.me.sound.play("transmutation_start") ;
		transforms = new Array() ;
		
		for (g in groups) {			
			if (!bigEnough(g)) {
				continue ;
			}
			
			var tt = Game.me.mode.transformInfos(cast g) ;
			for (t in tt) {
				for (o in t.g) {
					var e : Element = cast o ;
					e.onTransform() ;
					e.initTransform(t.t) ;
					transforms.push(e) ;
				}
			}
			
		}
		
		var t = flash.Lib.getTimer() ;
		if (killParasits.length > 0)
			Game.me.sound.play("transmutation_destructrice") ;
		
		for (n in killParasits) {
			if (n.isParasit) {
				n.onTransform() ;
				(cast n).initKill() ;
			} else if (n.isPickable) {
				n.onTransform() ;
				n.initPickUp(t) ;
			}
		}
		
		Game.me.setSpiritState(comboCount) ;
		
		Game.me.setStep(Transform) ; 
	}
	
	
	public function transform() {
		if (transforms.length == 0 && killParasits.length == 0)
			return false ;
		
		for (e in transforms) {
			if (!e.updateTransform())
				transforms.remove(e) ;
		}
		
		updatePick() ;
		/*for (n in killParasits) {
			if ((n.isParasit && !(cast n).updateKill()) || (n.isPickable && !n.updatePickUp()))
				killParasits.remove(n) ;
		}*/
		return true ;
	}
	
	public function updatePick() {
		for (n in killParasits) {
			if ((n.isParasit && !(cast n).updateKill()) || (n.isPickable && !n.updatePickUp()))
				killParasits.remove(n) ;
		}
	}
	
	
	public function destroy() {
		if (toDestroy.length == 0)
			return false ;
		
		//trace("############") ;
		
		for (e in toDestroy) {
		//	trace(Std.string(e.getArtId())) ;
			e.updateDestroy() ;
		}
		return true ;
	}
	
	
	public function remove(o : StageObject, ?noKill : Bool = false) {		
		grid[o.x][o.y] = null ;
		falls.remove(o) ;
		if (noKill || Game.me.hasInUse(o))
			return ;
		o.onStageKill() ;
		o.kill() ;
	}
	
	
	public function targetFalls() {
		var done = [] ;
		for (x in 0...WIDTH)
			done[x] = false ;
		
		for (y in 0...HEIGHT) {
			for (x in 0...WIDTH) {
				if (done[x])
					continue ;
				
				if (grid[x][y] != null)
					continue ;
				
				var s = 1 ;
				while(y + s < HEIGHT && grid[x][y + s] == null)
					s++ ;
				
				if (y + s == HEIGHT ) {
					done[x] = true ;
					//trace("nothing for " + x + ", " + y) ;
					continue ;
				}
				
				var o = null ;
				for (dy in (y + 1)...HEIGHT) {
					if (grid[x][dy] == null)
						continue ;
					o = grid[x][dy] ;
					grid[x][dy] = null ;
					grid[x][dy - s] = o ;
					if (o != null)
						o.setFall(x, dy - s)  ;
				}
				
				if (o != null)
					o.prepareBounce(s) ;
			}
		}
		
		//force x depth 
		forceXDepth() ;
	}
	
	
	public function forceXDepth() {
		for (y in 0...HEIGHT) {
			dm.compact(y) ;
			var x = WIDTH - 1 ;
			while (x >= 0) {
				var o = grid[x][y] ;
				if (o != null)
					dm.over(o.omc.mc) ;
				x-- ;
			}
		}
	}
	
	
	public function isFalling() : Bool {
		return falls.length != 0 ;
	}
	
	public function removeFall(o : StageObject) {
		var oldLength = falls.length ;
		falls.remove(o) ;
		if (oldLength > 0 && falls.length == 0)
			Game.me.mode.onGround() ;
		
	}
	
	
	public function fall() {
		for (o in falls) {
			o.fall() ;
		}
	}
	
	
	public function getLastColElement(x : Int) : {o : _ArtefactId, y : Int} {
		var res = {o : null, y : 0 } ;
		var laste : StageObject  = null ;
		for (e in grid[x]) {
			if (e == null)
				break ;
			laste = e ;
			res.y++ ;
		}
		
		res.o = laste.getArtId() ;
		
		if (res.o == null)
			return null ;
		return res ;
	}
	
	
	//check new transforms
	public function check() {
		resetGroups() ;
		
		var gs = new Array() ;
		
		var transmut = false ;
		
		for (type in [0, 1]) {
			var done = [] ;
			for (x in 0...WIDTH)
				done[x] = false ;
			
			for (x in 0...WIDTH) {
				for (y in 0...HEIGHT) {
					if (done[x])
						continue ;
					var e = grid[x][y] ;
					if (e == null) {
						done[x] = true ;
						continue ;
					}
									
					if (!e.isElement() || e.group != null)
						continue ;
					
					if (type == 0) { //special searchs
						if (Game.me.mode.haveToParse())
							Game.me.mode.startParse(e, e, this) ;
						
						if (e.group == null) {
							if (Type.enumEq(e.getArtId(), _Empty))
								parseEmptyGroup(cast e, cast e) ;
						}
					} else { //normal searchs
						parseGroup(cast e, getNewGroup()) ;
					}
					
					if (e.group != null)
						gs.push(e.group) ;
				}
			}
		}
		
		
		for (g in gs) {
			/*trace("#### :  " + Std.string(g.length)) ;
			for (o in g)
				trace(o.getArtId() + " # " + o.x + " , " + o.y) ;
			*/
			
			if (bigEnough(g)) {
					//trace("big : " + e.x + ", " + e.y + "###" + e.group.length) ;
					getCollaterals(g) ;
					transmut = true ;
				}
			
		}
		
		return transmut ;
	}
	
	
	function getCollaterals( g : Array<StageObject>) {
		for(o in g) {
			for(d in 0...4) {
				var neighbour =  getNeighbour(o, d) ;
				
				if (neighbour == null || (!neighbour.isCollateral(o.getArtId())) || (cast neighbour).toKill)
					continue ;
			
				neighbour.toKill = true ;
				killParasits.push(neighbour) ;
			}
		}
	}
	
	
	public function getNeighbour(o :StageObject, d : Int) {
		if (o == null)
			return null ;
		switch(d) {
			case 0 : //left
				return  grid[o.x - 1][o.y] ;
			case 1 :  //down
				return grid[o.x][o.y - 1] ;
			case 2 : //right 
				return grid[o.x + 1][o.y] ;
			case 3 : //up
				return grid[o.x][o.y + 1] ;
			default : 
				trace("invalid direction") ;
				return null ;
		}
	}
	
	
	function parseGroup(o : Element, g) {
		o.setGroup(g) ;
		
		for(d in 0...4) {
			var neighbour = getNeighbour(o, d) ;
			
			if (neighbour == null || !neighbour.isElement() || neighbour.group != null || (cast neighbour).index != o.index)
				continue ;
			
			parseGroup(cast neighbour, g) ;
		}
	}
	
	
	function parseEmptyGroup(o : Element, emp : artefact.Empty) {
		emp.initParse() ;
		
		var g = getNewGroup() ;
		emp.setGroup(g) ; 
		
		while (emp.nextTest()) {
			//trace("########################################################## NEW TEST") ;
			if (parseEG(o, emp)) {
				for (oo in emp.curSearch) {
					oo.setGroup(g, true) ;
				}
				break ;
			}
		}
		
	}
	
	
	function parseEG(o : StageObject, emp : artefact.Empty) : Bool {
		var r = false ;
		
		var parsing = if (o != emp) [[0, 1, 2, 3]] else artefact.Empty.parsingWays ;
		
		for (p in parsing) {
			if (o == emp) {
				//trace("################# NEW WAY : " + Std.string(p)) ;
				emp.nextWay() ;
			}
			
			for(d in p) {
				//trace("###NEW DIR : " + d + " # " + o.getArtId()) ;
				
				var neighbour = getNeighbour(o, d) ;
					
				if (neighbour == null || Lambda.exists(emp.curSearch, function(x) { return x == neighbour ;}))
					continue ;
				
				//trace("neighbour : " + neighbour.getArtId() + " # " + neighbour.x + ", " + neighbour.y) ;

				var res = emp.check(neighbour) ;
				//trace("res : " + res + " --------------- " + Std.string(Lambda.map(emp.curSearch, function(x : StageObject) { return x.getArtId() ;}) )) ;
				switch(res) {
					case -1 : 
						continue ;
					case 0 : 
						//emp.curSearch.push(neighbour) ;
						r = r || parseEG(neighbour, emp) ;
						if (r)
							break ;
					case 1 : 
						//emp.curSearch.push(neighbour) ;
						r = true ;
						break ;
				}
			}
			
			if (r)
				break ;
		}
		
		return r ;
	}

	
	public static function bigEnough(g : Array<StageObject>) {
		if (g == null) {
			trace("group is null") ;
			throw "group is null" ;
		}
		return !Game.me.mode.isEndChain(cast g[0]) && g.length >= Const.TRANSMUT_LIMIT ;
	}
	
	
	//get nextGroup to play
	public function getNext() {
		next = nexts.pop() ;

		effectCheckFall() ;
	
		nexts.add(new Group(true)) ;

		var f = callback(function(s : Stage) {
			var o = s.nexts.first() ;
			o.toNextBox() ;
			//s.nexts.add(new Group(true)) ;
			Game.me.setStep(Play) ;
		}, this) ;
		Game.me.setStep(Wait) ;
		reserve(next) ;
		
		var ff = callback(function(n : Group, fff : Void -> Void) {
			n.toStage(fff) ;
		}, next, f) ;
		
		next.move(next.mc._x, next.mc._y + 100, false, ff, Linear, 0.12) ;
	}
	
	
	//copy elements of group on dm and hide them. ==> preload for fall on stage
	public function reserve(g : Group) {
		if (reserved == null)
			reserved = new Array() ;
		
		for (o in g.objects) {
			var no = o.copy(dm, 1) ;
			no.place(-10, -10, -100, -100) ;
			reserved.push(cast no) ;
		}
		
	}
	
	
	
	public function getAvailableElements() : Array<_ArtefactId> {
		var done = [] ;
		for (x in 0...WIDTH)
			done[x] = false ;
		
		var res = new Array() ;
		
		for (x in 0...WIDTH) {
			for (y in 0...HEIGHT) {
				if (done[x])
					continue ;
				var e = grid[x][y] ;
				if (e == null) {
					done[x] = true ;
					continue ;
				}
				if (!e.isElement())
					continue ;
				
				var e : Element = cast e ;
				 if (Lambda.exists(res, function(x) { return x == e.getArtId() ;}))
					continue ;
				
				res.push(e.getArtId()) ;
			}
		}
		return res ;
	}
	
	
	public function hasArtefact(o : _ArtefactId) : Bool {
		var done = [] ;
		for (x in 0...WIDTH)
			done[x] = false ;
		
		for (x in 0...WIDTH) {
			for (y in 0...HEIGHT) {
				if (done[x])
					continue ;
				var e = grid[x][y] ;
				if (e == null) {
					done[x] = true ;
					continue ;
				}
				
				if (Type.enumConstructor(e.getArtId()) == Type.enumConstructor(o))
					return true ;
			}
		}
		return false ;
	}
	
	
	
	public function getAllElements(?eid : Int) : Array<Element> {
		var done = [] ;
		for (x in 0...WIDTH)
			done[x] = false ;
		
		var res = new Array() ;
		
		for (x in 0...WIDTH) {
			for (y in 0...HEIGHT) {
				if (done[x])
					continue ;
				var e = grid[x][y] ;
				if (e == null) {
					done[x] = true ;
					continue ;
				}
				if (!e.isElement())
					continue ;
				
				var e : Element = cast e ;
				if (eid == null || e.getId() == eid)
					res.push(e) ;
			}
		}
		return res ;
	}
	
	
	public function getAll() : Array<StageObject> {
		var done = [] ;
		for (x in 0...WIDTH)
			done[x] = false ;
		
		var res = new Array() ;
		
		for (x in 0...WIDTH) {
			for (y in 0...HEIGHT) {
				if (done[x])
					continue ;
				var e = grid[x][y] ;
				if (e == null) {
					done[x] = true ;
					continue ;
				}
				
				res.push(e) ;
			}
		}
		return res ;
	}
	
	
	public function getPoints() : Int {
		var done = [] ;
		for (x in 0...WIDTH)
			done[x] = false ;
		
		var score = 0 ;
		
		for (x in 0...WIDTH) {
			for (y in 0...HEIGHT) {
				if (done[x])
					continue ;
				var e = grid[x][y] ;
				if (e == null) {
					done[x] = true ;
					continue ;
				}
				if (!e.isElement())
					continue ;
				
				var index = (cast e).index ;
				if (index != null && Const.POINTS[index] != null) //due to Empty extension 
					score += Const.POINTS[index] ;
				
			}
		}
		return score ;
	}
	
	
	public function rotate() {
		if (next == null)
			return ;
		next.startRotate() ;
	}
	
	
	public function release() {
		if (next == null || !Game.me.canPlay() || !next.canFall())
			return ;

		//trace(grid) ;
		
		Game.me.setStep(Wait) ; 
		Game.me.playCount++ ;
		startFall() ;
		Game.me.mode.onRelease() ;
	}
	
	
	public function getNewGroup() : Array<StageObject> {
		var g = new Array() ;
		groups.push(g) ;
		return g ;
	}
	
	
	public function resetGroups() {
		for (x in 0...WIDTH) {
			for (y in 0...HEIGHT) {
				var o = grid[x][y] ;
				if (o == null || !o.isElement())
					continue ;
				o.ungroup() ;
			}
		}
		groups = new Array() ;
		killParasits = new Array() ;
		transforms = new Array() ;
	}
	
	
	public function checkEnd() {
		for (x in 0...WIDTH) {
			if (grid[x][LIMIT] != null)
				return true ;
		}
		
		if (Game.me.mode.checkEnd())
			return true ;
		
		return false ;
	}
	
	
	//TempEffects
	public function addEffect(e : TempEffect, so : StageObject, ?c : Int) {
		effect = {fx : e, 
					leftPlays : if (c != null) c else null,
					from : so
				} ;
		Game.me.sound.play("special_start") ;
		Game.me.sound.play("special_loop", true) ;
				
		
		forceEffect(so, c) ;
	}
	
	public function isCurrentEffect(so : StageObject) : Bool {
		return effect != null && effect.from == so ;
	}
	
	public function hasCurrentEffect() : Bool {
		return effect != null && effect.leftPlays >= 0 ;
	}
	
	
	public function forceCurrentEffect() {
		if (effect == null)
			return ;
		
		forceEffect(effect.from, effect.leftPlays) ;

	}
	
	
	public function forceEffect(so : StageObject, ?c : Int) {
		//mcEffect.toHide = true ;
		
		if (c != null) {
			mcEffect.gotoAndStop(2) ;
			mcEffect._nb.text = Std.string(c + 1) ;
		} else
			mcEffect.gotoAndStop(1) ;
		
		
		var o = new ObjectMc(so.getArtId(), dmEffect, 2, null,null, null, null, 75) ;
		/*o.f = callback(function(s : Stage, oo : ObjectMc) {
			Filt.grey(oo.mc, 0.7) ;
			oo.mc._xscale = oo.mc._yscale = 75 ;
			
			if (s.mcEffect._icon != null)
				s.mcEffect._icon.removeMovieClip() ;
			s.mcEffect._icon = oo.mc ;
			s.mcEffect._icon._x = ICON_EFFECT_X ;
			s.mcEffect._icon._y= ICON_EFFECT_Y ;
			s.mcEffect.toHide = false ;
		
		}, this, o) ;*/
		Filt.grey(o.mc, 0.7) ;
			
		if (mcEffect._icon != null)
			mcEffect._icon.removeMovieClip() ;
		mcEffect._icon = o.mc ;
		mcEffect._icon._x = ICON_EFFECT_X ;
		mcEffect._icon._y= ICON_EFFECT_Y ;
		mcEffect.toHide = false ;
		
		mcEffect._help.text = "" ;
		
		if (so.helpTxt != null)
			mcEffect._help.text = so.helpTxt ;
		
		mcEffect.from = so ;

	}
	
	
	public function isVisibleMcEffect() {
		return mcEffect.from != null ;
	}
	
	
	public function isMcSpecialEffect() {
		return effect != null && mcEffect.from == effect.from ;
	}
	
	
	public function showMcEffect(so : StageObject, ?c : Int) {
		Game.me.sound.play("interface_in") ;

		mcEffect.gotoAndStop(1) ;
		
		if (c != null) {
			mcEffect.gotoAndStop(2) ;
			mcEffect._nb.text = Std.string(c + 1) ;
		}
		
		var mi = new ObjectMc(so.getArtId(), dmEffect, 2, null, null, null, null, 75) ;
		
		//mcEffect._icon = so.copy(dmEffect, 2).omc.mc ;
		mcEffect._icon = mi.mc ;
		mcEffect._icon._x = ICON_EFFECT_X ;
		mcEffect._icon._y= ICON_EFFECT_Y ;
		Filt.grey(mcEffect._icon, 0.7) ;
		
		mcEffect._help.text = "" ;
		if (so.helpTxt != null) {
			mcEffect._help.text = so.helpTxt ;
		}
		
		
		var aEffect = new anim.Anim(mcEffect, Translation, Elastic(-1, 0.27), {x : mcEffect._x, y : -10, speed : /*0.025*/0.026}) ;
		aEffect.onStart = callback(function(s : Stage, soo) {
			s.mcEffect.from = soo ;
		}, this, so) ;
		aEffect.onEnd = callback(function(s : Stage) {
					s.curAnimEffect = null ;
				}, this) ;
		animEffect.push(aEffect) ; 

		//animEffect.start() ;
	}
	
	
	
	public function hideMcEffect(from : StageObject, ?f : Void -> Void, ?fast = false) {
		if (!fast)
			Game.me.sound.play("interface_out", null, null, null, 15) ;
		mcEffect.toHide = true ;
		var a = new anim.Anim(mcEffect, Translation, Elastic(1, 0.3), {x : mcEffect._x, y : MCEFFECT_HIDE_Y, speed : 0.026 + (if (fast) 0.01 else 0.0)}) ;
		a.onStart = callback(function(s : Stage) {
			s.mcEffect.from = null ;
		}, this) ;
		a.onEnd = callback(function(s : Stage, m, ff) {
					if (m._icon != null) {
						m._icon.removeMovieClip() ;
					}
					m.from = null ;
					m.toHide = false ;
					m.gotoAndStop(1) ;
					m._help.text = "" ;
					m._nb.text = "" ;
					s.curAnimEffect = null ;
					if (ff != null)
						ff() ;
				
				}, this, mcEffect, f) ;
				
		animEffect.push(a) ;
		//a.start() ;
	}
	
	
	public function isFinishedEffect() {
		return effect != null && effect.leftPlays < 0 ;
		
	}
	
	public function effectCheckFall() {
		if (effect == null || effect.leftPlays == null)
			return ;
		
		effect.leftPlays-- ;
		
		switch(effect.fx) {
			case FxDaltonian :
				if (effect.leftPlays == 0)
					effect.fx = null ;
			default : 
				//nothing to do
		}
		
		if (effect.leftPlays >= 0) // <
			//killEffect() ;
		//else
			mcEffect._nb.text = Std.string(effect.leftPlays + 1) ;
		if (effect.leftPlays < 0)
			effect.fx = null ;
	}
	
	
	public function pickCreate(tc : {_l : Array<{_id : _ArtefactId, _qty : Int, _tot : Int}>, _cAllInOne : Bool}) : Array<StageObject> {
		var res = new Array() ;
		if (tc == null || tc._l == null)
			return res ;
		
		var cDone = 0 ;
		
		for (x in 1...WIDTH + 1) {
			for (y in 1...LIMIT + 2) {
				var o = grid[WIDTH - x][LIMIT + 1 - y] ;
				if (o == null)
					continue ;
				
				for (c in tc._l) {
					if (c._qty >= c._tot)
						continue ;
					
					if (!Type.enumEq(c._id, o.getArtId()))
						continue ;
					
					var oo = o.copy(Game.me.rdm, 4) ;
					oo.omc.mc._x = Game.me.stage.mc._x + o.omc.mc._x ;
					oo.omc.mc._y = Game.me.stage.mc._y + o.omc.mc._y ;
					
					
					res.push(oo) ;
					//oo.forcePickUp() ;
					
					
					c._qty++ ;
					if (c._qty >= c._tot)
						cDone++ ;
				}
				
			}
		}
		
		
		if (tc._cAllInOne && cDone < tc._l.length) {
			for (r in res)
				r.kill() ;
			res = new Array() ;
		}
		
		return res ;
	}
	
	public function setGameOver(?hideText = false) {
		
		if (curAnimEffect != null)
			curAnimEffect.kill() ;
		if (animEffect.length > 0) {
			for(a in animEffect) {
				a.kill() ;
			}
			animEffect = [] ;
		}
		
		mcEffect.gotoAndStop(3) ;
		if (hideText)
			mcEffect._help._visible = false ;
	}
	
	
	public function updateEffect() {
		if (curAnimEffect == null && animEffect.length > 0) {
			curAnimEffect = animEffect.shift() ;
			curAnimEffect.start() ;
		}
		
		
		if (shakeTimer > 0)
			shake() ;
		
		updateWheels(Game.me.isGameOver()) ;
		
		/*if (effect == null || effect.duration == null)
			return ;
		var t = effect.duration - (flash.Lib.getTimer() - effect.start) / 1000 ;
		
		if (t <= 0) {
			killEffect() ;
			return ;
		}
		
		var r = Math.floor(t) ;
		var d = Std.string(t - r) ;
		d = d.substr(2, 2) ;
		if (d.length == 1)
			d += "0" ;
		
		mcEffect._nb.text = (if (r < 10) "0" else "") + r + ":" + d ;
		if (!mcEffect._visible)
			mcEffect._visible = true ;*/
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
	
	
	public function setShake(s : Float, ?limit : Int = 5, ?noSound = false) {
		if (shakeTimer == null || shakeTimer <= 0.0 && !noSound)
			Game.me.sound.play("shake") ;
		
		shakeTimer = Math.min(limit, shakeTimer + s) ;
		
	}
	
	
	function shake() {
		shakeTimer -= 0.3 ;
		var b = mc.smc ;
		var pos = {x : 0, y : 0} ;
		var v = 5 ;
		b._x = pos.x + Std.random(Math.round(shakeTimer * v)) / v * (Std.random(2) * 2 - 1) ;
		b._y = pos.y + Std.random(Math.round(shakeTimer * v)) / v * (Std.random(2) * 2 - 1) ;
			
		if (Game.me.bg != null) {
			Game.me.bg._x = Game.me.bgInfos.x + Std.random(Math.round(shakeTimer * v)) / v * (Std.random(2) * 2 - 1) ;
			Game.me.bg._y = Game.me.bgInfos.y + Std.random(Math.round(shakeTimer * v)) / v * (Std.random(2) * 2 - 1) ;
		}
	}
	
	
	public function chooseFreeColumn() : Int {
		var cols = getFreeColumns() ;
		if (cols.length == 0)
			return null ;
		return cols[Std.random(cols.length)] ;
		
	}
	
	
	
	public function getFreeColumns() : Array<Int> {
		var res = [] ;
		for (i in 0...WIDTH) {
			if(Game.me.stage.grid[i][Stage.LIMIT - 1] != null)
				continue ;
			res.push(i) ;
		}
		return res ;
	}
	
	
	public function killEffect(?f : Void -> Void, ?fast : Bool = false, ?noHide = false) {
		var so = effect.from ;
		effect = null ;
		stopSpecialLoop() ;
		
		if (noHide)
			true ;
		
		hideMcEffect(so, f, fast) ;
	}
	
	public function stopSpecialLoop() {
		Game.me.sound.stop("special_loop", true) ;
	}
	
	
	
	
	public function hasEffect(fx : TempEffect) : Bool {
		return effect != null && effect.fx == fx ;
	}
	
	
	//### DEV UTILS
	
	function forceGrid() {
		for (x in 0...WIDTH) {
			var n = 6 ;
			switch(x) {
				case 2 : n = 5 ;
				case 3 : n = 0 ;
			}
			for (y in 0...n) {
				
				if (grid[x][y] != null)
					continue ;
				
				var o = new Element(Std.random(10), dm, HEIGHT - y) ;
				//var o = new artefact.EnforcedBlock(Std.random(4) + 1, dm, HEIGHT - y) ;
				o.place(x, y, Stage.X + x * Const.ELEMENT_SIZE, Const.HEIGHT - (Stage.BY + (y + 1) * Const.ELEMENT_SIZE)) ;
				add(o) ;
			}
		}
	}

	
	public function forceComboGrid(?eids : Array<Int>) {
		
		/*var gg = [
		[10, 8, 6, 2, 1],
		[12, 9, 9, 2, 7, 10],
		[4, 4],
		[5, 2, 3, 1, 1, 0],
		[1, 1, 0],
		[7, 5, 7, 5, 8, 8]] ;
		
		for (x in 0...gg.length) {
			var g = gg[x] ;
			for (y in 0...g.length) {
				var o = new Element(g[y], dm, HEIGHT - y) ;
				o.place(x, y, Stage.X + x * Const.ELEMENT_SIZE, Const.HEIGHT - (Stage.BY + (y + 1) * Const.ELEMENT_SIZE)) ;
				add(o) ;
			}
		}			
		return ;*/
		
		
		if (eids == null)
			eids = [6, 5, 4, 3, 2, 1, 0] ;
		
				
		for (y in 0...eids.length) {
			/* var x = 3 ;
			while (x > 1) {
				if (grid[x][y] == null) {
					var o = new Element(eids[y], dm, HEIGHT - y) ;
					o.place(x, y, Stage.X + x * Const.ELEMENT_SIZE, Const.HEIGHT - (Stage.BY + (y + 1) * Const.ELEMENT_SIZE)) ;
					add(o) ;
				}
				
				x-- ;
			} */
			
			for (x in 2...4) {
				
				if (grid[x][y] == null) {
					var o = new Element(eids[y], dm, HEIGHT - y) ;
					o.place(x, y, Stage.X + x * Const.ELEMENT_SIZE, Const.HEIGHT - (Stage.BY + (y + 1) * Const.ELEMENT_SIZE)) ;
					add(o) ;
				}
			}
			
		}
		
	//	Game.me.forceGroup(Elt(eids[eids.length - 1])) ;
		
	}
	
	
	public function forceEmpty() {
		/*if (Game.me.step != Play)
			return ;*/
	
		for (x in 0...WIDTH) {
			for (y in 0...HEIGHT) {
				var o = grid[x][y] ;
				
				if (o == null)
					continue ;
				remove(o) ;
				
			}
		}
	}
	
	
	public function kill() {
		if (animMasks != null) {
			for (am in animMasks)
				am.removeMovieClip() ;
		}
		
		if (rWheels != null && rWheels.length > 0) {
			for (r in rWheels) 
				r.wmc.removeMovieClip() ;
		}
		
		if (mcEffect != null)
			mcEffect.removeMovieClip() ;
		
		if (nexts != null && nexts.length > 0) {
			for (n in nexts) 
				n.kill() ;
		}
		
		if (next != null)
			next.kill() ;
		
		if (mc != null)
			mc.removeMovieClip() ;
	}
	
	
}