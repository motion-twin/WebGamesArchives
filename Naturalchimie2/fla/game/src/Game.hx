import flash.Key ;
import mt.bumdum.Lib ;
import mt.bumdum.Part ;
import mt.bumdum.Sprite ;
import mt.bumdum.Phys ;
import GameData._ArtefactId ;
import GameData._GameData ;
import anim.Transition ;
import anim.Anim.AnimType ;
import mode.GameMode ;



enum GameStep {
	Loading ;
	Wait ;
	Play ;
	Fall ;
	Transform ;
	Destroy ;
	ArtefactInUse ;
	GameOver ;
	Mode ;
}



class Game {
	
	public var loader : Load ;
	public static var me : Game ;
	
	static public var objectsList : Array<StageObject> = new Array() ;
	
	public var rdm : mt.DepthManager ;
	public var mdm : mt.DepthManager ;
	public var out : {>flash.MovieClip, bmp : flash.display.BitmapData} ;
	public var missionDone : flash.MovieClip ;
	public var missionPopup : {>flash.MovieClip, _byes : {>flash.MovieClip, _field : flash.TextField}, _bno : {>flash.MovieClip, _field : flash.TextField}, _selected : Int} ;
	public var pausePanel : {>flash.MovieClip, _volMc : {>flash.MovieClip, _cursor : flash.TextField}, _vol : flash.MovieClip, _music : flash.MovieClip, _sfx : flash.MovieClip, _quit : flash.MovieClip} ;
	var pauseMask : flash.MovieClip ;
	public var root : flash.MovieClip ;
	public var mc : flash.MovieClip ;
	public var bg : flash.MovieClip ;
	public var bmpFile : flash.MovieClip ;
	public var bgInfos : {x : Int, y : Int} ;
	public var preLoadObject : ObjectMc ;
	public var toJs : List<Void -> Void> ;
	
	//interface
	public var gui : {>flash.MovieClip, 
						_score 			: {>flash.MovieClip, _field : flash.TextField},
						_apascore 			: {>flash.MovieClip, _field : flash.TextField},
						_spirit_box 	: {>flash.MovieClip, _spmask : flash.MovieClip, _spirit : flash.MovieClip, _wheel : flash.MovieClip},
						_next_elements 	: {>flash.MovieClip , _elem : flash.MovieClip},
						_next_spirit : flash.MovieClip,
						_inventory_slot : {>flash.MovieClip, _obj1 : flash.MovieClip , _obj2 : flash.MovieClip , _obj3 : flash.MovieClip , _obj4 : flash.MovieClip },
						_group_mask : flash.MovieClip,
						_force_group_mask : flash.MovieClip,
						_pause : flash.MovieClip,
						_vol : flash.MovieClip,
						_volMc : {>flash.MovieClip, _cursor : flash.MovieClip}
					} ;
					
	public var spiritStep : Int ;
	public var spiritTimer : Float ;
	public var lastSpiritFrame : String ;
		
	//public var mcNext : flash.MovieClip ;
	public var mcSpiritBox : flash.MovieClip ;
		
	public var spirit : Spirit ;
	public var spiritAnims : {onStage : Bool ,l : List<String>} ;
	
	public var artefact : Array<StageObject> ;
	public var onEndFall : Array<Void -> Void> ;
	
	public var id : Int ;
	public var uid : Int ;
	public var data : _GameData ;	
	public var step : GameStep ;
	public var score : mt.flash.Volatile<Int> ;
	public var apaScore : mt.flash.Volatile<Int> ;
	public var gameOver : Bool ;
	public var missionOk : Bool ;
	public var missionPopedUp : Bool ;
	public var mode : mode.GameMode ;
	public var inventory : Inventory ;
	public var stage : Stage ;
	public var picks : Array<PickUp> ;
	public var goPick : PickUp ; //specila pick for quest create on GameOver
	public var log : Log ;
	public var sound : SoundManager ;
	public var playCount : mt.flash.Volatile<Int> ;
	public var pause : Bool ;
	public var started : Bool ;
	
	public var pLeft : Bool ;
	public var pRight : Bool ;
		
	
	public var goStep : Int ;
	public var goAnim : anim.Anim ;
	public var goMc : flash.MovieClip ;
	//public var goMc2 : flash.MovieClip ;
	var goPicks : Array<StageObject> ;
	
	var gTimer : Float ;
	var kl : Dynamic ;
	var ckl : Dynamic ;
	
	var debugPause : Bool ;

	
	public function new(mc : flash.MovieClip, l : Loader) {
		for (d in ["www","beta","data"])
			flash.system.Security.allowDomain(d+".naturalchimie.com") ;
		
		debugPause = false ;
		started = false ;
		
		root = mc ;
		loader = l ;
		me = this ;
		gameOver = false ;
		missionOk = false ;
		missionPopedUp = false ;
		artefact = new Array() ;
		onEndFall = new Array() ;
		toJs = new List() ;
		picks = new Array() ;
		score = 0 ;
		playCount = 0 ;
		step = Loading ;
		log = new Log() ;
		pause = false ;
		
		pLeft = false ;
		pRight = false ;


		var g = new Array() ;
		g.
		
		rdm = new mt.DepthManager(root) ;
		this.mc = rdm.empty(3) ;
		mdm = new mt.DepthManager(this.mc) ;
		loader.initLoading(4, 100, 195) ;
		initKeyListener() ;
		sound = new SoundManager() ;

	}
	
	function init() {
		initBg() ;
		
		initGame() ;
		initInterface() ;
		
		mode.initInventory(data) ;
				
		loader.done() ;
	}
	
	
	public function traceError(s : String) {
		if (uid == null || (uid != 11  && uid != 1)) 
			return ;
			
		trace(s) ;
	}
	
	function initGame() {
		mode = GameMode.get(data) ;
	}
	
	public function initStage() {
		stage = new Stage() ;
	}
	
	
	public function start() {
		stage.init(data._grid) ;
	
		var speed = 0.01 ;
		var wait = 12;
		
		if (spirit != null) {
			
			var a = new anim.Anim(spirit.mc, Translation, Elastic(-1, 1.0), {x : spirit.mc._x, y : spirit.y, speed : speed}) ;
			a.sleep = wait ;
			a.start() ;
			a = new anim.Anim(spirit.mc, Scale, Elastic(-1, 1.2), {x : 100, y : 100, speed : speed}) ;
			a.sleep = wait ;
			a.onEnd = callback(function(g : Game) {
						g.spirit.initDone = true ;
					}, this) ;
			a.start() ;		
		}
		
		if (apaScore != null) {
			gui._apascore._field.text = Std.string(apaScore) ;
			gui._apascore.smc.gotoAndStop(1) ;
			var a = new anim.Anim(gui._apascore, Alpha(1), Quint(-1), {speed : speed}) ;
			a.sleep = wait * 2;
			a.start() ;
			
		}
		
		
		sound.startMusic() ;
	}
	
	function initInterface() {
		
		var skin = rdm.attach("mcBg", 1) ;
		skin._x  = 0 ;
		skin._y  = 0 ;
		
		var mcInterface = mdm.empty(Const.DP_INTERFACE) ;
		var idm = new mt.DepthManager(mcInterface) ;
		
		var limitBorder = mdm.attach("limitBorder", Const.DP_GROUP) ;
		limitBorder._x = 7 ;
		limitBorder._y = Stage.LIMIT_Y ;
		
		gui = cast idm.attach("gui", 1) ;
		gui._score._field.text = "0";	
		gui._apascore._alpha = 0 ;
		gui._inventory_slot.gotoAndStop(1);
		
		gui._volMc._visible = false ;
		
		gui._next_spirit._visible = false ;
				
		gui._group_mask = mdm.attach("group_mask", Const.DP_GROUP_BOX) ;
		gui._group_mask._alpha = 0 ;
		gui._group_mask._x = 204 ;
		gui._group_mask._y = 152 ;
		
		gui._force_group_mask = mdm.attach("group_mask", Const.DP_GROUP_BOX) ;
		gui._force_group_mask._alpha = 0 ;
		gui._force_group_mask._x = 204 ;
		gui._force_group_mask._y = 152 ;
		
		if (!mode.hideSpirit) {
			spirit = new Spirit("1", gui._spirit_box._spirit, spiritNextAnim) ;
			spiritAnims = {onStage : false, l : new List()} ;
			
			spirit.mc._y += 70 ;
			spirit.mc._xscale= 50 ;
			spirit.mc._yscale= spirit.mc._xscale ;
		} else 
			gui._spirit_box._spirit._visible = false ;
		
		
		gui._pause.smc.gotoAndStop(1) ;
		gui._pause.gotoAndStop(1) ;
		gui._pause.onRollOver = callback(function(g : Game) {g.gui._pause.gotoAndStop(2) ;}, this) ;
		gui._pause.onRollOut = callback(function(g : Game) {g.gui._pause.gotoAndStop(1) ;}, this) ;
		gui._pause.onReleaseOutside = gui._pause.onRollOut ;
		gui._pause.onRelease = sound.switchPause ;
		
		gui._vol.smc.gotoAndStop(1) ;
		gui._vol.gotoAndStop(1) ;
		gui._vol.onRollOver = callback(function(g : Game) {if (g.gui._vol._currentframe == 1) g.gui._vol.gotoAndStop(2) ;}, this) ;
		gui._vol.onRollOut = callback(function(g : Game) {if (g.gui._vol._currentframe == 2) g.gui._vol.gotoAndStop(1) ;}, this) ;
		gui._vol.onReleaseOutside = gui._vol.onRollOut ;
		gui._vol.onRelease = callback(sound.setTinyVolume, null) ;
	}
	
	
	public function setSpiritState(c : Int) {
		if (spirit == null || c > 4)
			return ;
		
		var s = if (c == 4) 
				"_bravo"
			else if (c == null)
				null
			else
				"_combo" + Std.int(Math.max(0, c)) ;
			
		/*trace("####") ;
		trace(s) ;*/

		lastSpiritFrame = switch(c) {
			case 0 :  "_combo0_end" ;
			case 1 :  "_combo1_end" ;
			case 2, 3 : "_bravo" ;
			default : "_stand" ;
		}
		
		if (s != null && lastSpiritFrame != null)
			spiritAnims.l.add(s) ;
		
		if (!spiritAnims.onStage)
			spiritNextAnim() ;
	}
	
	
	public function spiritNextAnim() {
		if (spirit == null)
			return ;
		
		var a = spiritAnims.l.pop() ;
		
		spiritAnims.onStage = a != null ;
		
		if (a == null) {
			//trace("a is null") ;
			a = lastSpiritFrame ;
			lastSpiritFrame = "_stand" ;
		}
		//trace(spiritAnims.onStage + " =====> PLAY : " + a) ; 
		spirit.play(a) ;
	}
	
	
	function initBg() {
		//bg = mdm.empty(Const.DP_BG) ;
		//bg = stage.dm.empty(Const.DP_BG) ;
		
		bmpFile = mdm.empty(Const.DP_BG) ;
		
		var bi = data._bg.split(":") ;
		bgInfos = {x : -1 * Std.parseInt(bi[0]), y : -1 * Std.parseInt(bi[1])} ;
		bmpFile._x = bgInfos.x ;
		bmpFile._y = bgInfos.y ;
		
		var mcl = new flash.MovieClipLoader() ;
		var me = this ;
		mcl.onLoadError = function(_,err) {
			me.loader.reportError("#" + err);
		}
		mcl.onLoadInit = function(_) {
			me.loader.done() ;
			me.bmpFile.removeMovieClip();
		}
		mcl.loadClip(loader.dataDomain + "/img/bg/" + bi[2] + ".jpg", bmpFile) ;	
	}
	

	public function loadData() {
		try {
			data = secure.Codec.getData("d") ;
			Pnj.DATA_URL = data._pnj_url ;
			ObjectMc.initMc(data._object_url, mdm, 0, callback(function() { Game.me.loader.done() ; Game.me.init() ;})) ;	
			sound.setUserConfig(data._sound) ;
			sound.initOnDemand(data) ;
		} catch(e : Dynamic) {
			loader.reportError(e) ;
			return ;
		}
		loader.done() ;
	}

	
	/*public function loadData() {
		var dd = Reflect.field(flash.Lib._root,"d") ;
		if( dd != null ) {
			onData(dd) ;
			return;
		}
	}
	

	public function onData(dd : String) {
		try {
			var s = secure.Utils.decode(secure.Utils.getKey(loader.k, dd, loader.s, loader.n)) ;
			data = haxe.Unserializer.run(s) ;
		
			Pnj.DATA_URL = data._pnj_url ;
			ObjectMc.initMc(data._object_url, mdm, 0, callback(function() { Game.me.loader.done() ; Game.me.init() ;})) ;	
			sound.setUserConfig(data._sound) ;
			sound.initOnDemand(data) ;
		} catch( e : Dynamic ) {
			loader.reportError(e) ;
			return ;
		}
		loader.done() ;
	}*/
	
	
	public function updateScore() {
		score = mode.updateScore() ;

		gui._score._field.text = Std.string(score) ;
		
		if (apaScore == null)
			return ;
		
		gui._apascore.smc.gotoAndStop(if (score >= apaScore) 2 else 1) ;
	}
	
	
	public function releaseArtefact(a : StageObject) : Bool {
		return artefact.remove(a) ;
	}
	
	
	public function hasInUse(o : StageObject) : Bool {
		for (a in artefact) {
			if (o == a)
				return true ;
		}
		return false ;
	}
	
	
	public function addEndFall(f : Void -> Void) {
		onEndFall.push(f) ;
	}
	
	
	public function setStep(s, ?a : StageObject) {
		if (s == ArtefactInUse) {
			step = s ;
			artefact.push(a) ;
		} else {
			if (artefact.length == 0)
				step = s ;
		}
	}
	
	public function canPlay() {
		return step == Play && !pause ;
	}
	
	
	public function loop() {
		mt.Timer.update() ;
		
		if (Const.FL_DEBUG && uid != null && (uid == 11 || uid == 1))
			updateDebug() ;
		
		if (debugPause || pause)
			return ;
		//trace(mt.Timer.fps() + " # " + mt.Timer.tmod) ;

		updateSprites() ;
		updateObjects() ;
		updateMoves() ;
		sound.update() ;
		if (spirit != null)
			spirit.update();
				
		if (picks.length > 0) {
			for( p in picks.copy()) {
				p.update() ;
			}
		}
		
		if (stage == null)
			return ;
		
		mode.updateEffect() ;
		
		stage.updateEffect() ;
		stage.fall() ;
		
		
		switch(step) {
			case Loading : 
				loader.update() ;
			
			case Wait :
				/*if (stage.next != null) {
					stage.next.update() ;
				}*/
				
			case Play :
				if (stage.next != null)
					stage.next.update() ;
				
			case Fall :
				if (!stage.isFalling()) {
					if (!stage.check()) {
						if (!mode.checkFallEnd()) {
							stage.updateStaticScore() ;
							updateScore() ;
							stage.startPlay() ;
						}
					} else {
						updateScore() ;
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
				/*goMc2._xscale = goMc._xscale ; 
				goMc2._yscale = goMc._yscale ; */
			
				if (goStep != null) {
					switch(goStep) {
						case 0 :
							var t = flash.Lib.getTimer() ;
							goPick = Game.me.initPickUp(true) ;
							for(p in goPicks) {
								p.forcePickUp(t) ;
							}
							Game.me.sound.play("transmutation_destructrice") ;
							goStep = 1 ;
						
						case 1 :
							if (goPick != null && !goPick.nearAllIsDone())
								stage.updatePick() ;
							else {
								if (goAnim != null)
									goAnim.kill() ;
								goAnim= new anim.Anim(goMc, Scale, Quart(1), {x : 0, y : 0, speed : 0.035}) ;
								goAnim.onEnd = callback(function(g : Game) {
									(cast g.loader).gameOver() ;
								}, this) ;
								goAnim.start() ;
								goStep = 2 ;
							}

						case 2  : //nothing to do
					}	
				}
				
			case Mode : 
				mode.loop() ;
		}
		
		//drawOut() ;
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
		mode.onGameOver() ;
		
		log.grid = log.getGrid() ;
		
		if (stage.mcEffect._icon != null)
			stage.mcEffect._icon.removeMovieClip() ;
		stage.dm.swap(stage.mcEffect, Stage.HEIGHT + 1) ;
		
		stage.setGameOver(missionOk) ;
		
		setSpiritState(1) ;
		setSpiritState(2) ;
		lastSpiritFrame = null ;
		
		
		if (data._quest != null && data._quest._create != null)
			goPicks = stage.pickCreate(data._quest._create) ;
		
		var bottom = rdm.attach("borderBottom", 5) ;
		bottom._x = 0 ;
		bottom._y = Const.HEIGHT ; 
		
		var sp = 0.02 ;
		goAnim = new anim.Anim(stage.mcEffect, Translation, Bounce(-1), {x : stage.mcEffect._x, y : 285, speed : sp}) ;
		goAnim.sleep = 35.0 ;
		
		Game.me.sound.stopMusic(true) ;
		Game.me.sound.play("shake") ;
		Game.me.sound.play("interface_endgame", null, null,0) ;
		
		if (goPicks.length > 0) {
			goAnim.onEnd = callback(function(g : Game) {
									g.goStep = 0 ; // to start pickUp
								}, this) ;
		} else {
			goAnim.addOnCoef(0.7, callback(function(g : Game) {
									g.spiritStep = 0 ;
									g.spiritTimer = 0.0 ;
								}, this)) ;
			goAnim.onEnd = callback(function(g : Game) {
									haxe.Timer.delay(callback(function(gg : Game) {(cast gg.loader).gameOver() ; }, g), 300) ;
								}, this) ;
		}
		
		goAnim.start() ;
		gTimer = 0.0 ;
		setStep(GameOver) ;
	}
	
	
	public function isGameOver() {
		return step == GameOver ;
	}
	
	
	
	public function checkQuest() : Bool {
		if (data._quest == null || missionOk) 
			return false ;
		
		if (data._quest._chain != null) { //### CHAIN
			return mode.level >  data._quest._chain ;
		} else if (data._quest._score != null) { //### SCORE
			return score >=  data._quest._score ;
		} else if (data._quest._create != null) { //### CREATE
			var cDone = 0 ;
			
			var tc = new Array() ;
			for (t in data._quest._create._l) {
				tc.push({_id : t._id, _from : t._qty, _qty : t._qty, _tot : t._tot}) ;
			}
			
			for (x in 0...Stage.WIDTH) {
				for (y in 0...Stage.LIMIT + 2) {
					var o = stage.grid[x][y] ;
					if (o == null)
						continue ;
					
					for (c in tc) {
						if (c._qty >= c._tot)
							continue ;
						
						if (!Type.enumEq(c._id, o.getArtId()))
							continue ;

						c._qty++ ;
						if (c._qty >= c._tot) {
							cDone++ ;
							break ;
						}
					}
				}
			}
			
			var js = "" ;
			for (t in tc) {
				if (js != "")
					js += "," ;
				js += Std.string(t._id) + ";" + Std.string(t._qty) ;
			}
			
			Game.me.addToJs(callback(function(s : String) {flash.external.ExternalInterface.call("_majq", s) ; }, js)) ; //update tpl quest values
			
			return !missionPopedUp && cDone == tc.length ;
			
		} else if (data._quest._collect != null) { //### COLLECT
			var cDone = 0 ;
			
			var tc = new Array( );
			for (t in data._quest._collect._l) {
				tc.push({_id : t._id, _from : t._qty, _qty : t._qty, _tot : t._tot}) ;
			}
			
			if (log.specialReward == null)
				return false ;
				
			for (c in tc) {
				if (c._qty >= c._tot)
					continue ;
				
				for (o in log.specialReward) {
					if (!Type.enumEq(c._id, Const.fromArt(o.obj)))
						continue ;
					//trace(c._qty + " # " + Std.string(o)) ;
					c._qty += o.ct ;
					if (c._qty >= c._tot) {
						cDone++ ;
						break ;
					}
				}
			}
			
			var js = "" ;
			for (t in tc) {
				if (js != "")
					js += "," ;
				js += Std.string(t._id) + ";" + Std.string(t._qty) ;
			}
			
			Game.me.addToJs(callback(function(s : String) {flash.external.ExternalInterface.call("_majq", s) ; }, js)) ;
			//flash.external.ExternalInterface.call("_majq", js) ; //update tpl quest values
			
			return cDone == tc.length ;
		}
		
		return false ;
	}
	
	
	public function setMissionCompleted() {
		if (missionPopedUp)
			return ;
		//trace("completed") ;
		//missionOk = true ;
		missionPopedUp = true ;
		missionDone = rdm.attach("missionCompleted", 5) ;
		missionDone._x = 100 ;
		missionDone._y = 100 ;
		missionDone._xscale = missionDone._yscale = 0 ;
		
		var finished = playCount > mode.qmin ;
		
		var a = new anim.Anim(missionDone, Scale, Elastic(-1, 1), {x : 120, y : 120, speed : 0.017}) ;
		
		if (!finished)
			setMissionPopUp() ;
		else 
			missionOk = true ;
		
		Game.me.sound.play("congelation") ;
		a.start() ;
		setStep(Wait) ;
		if (finished) 
			setGameOver() ;
	}
	
	
	public function setMissionPopUp() {
	//	trace("paf") ;
		missionPopup = cast rdm.attach("missionPopup", 5) ;
		missionPopup._alpha = 0 ;
		missionPopup._x =16 ;
		missionPopup._y =165 ;
		
		if (data._quest._create != null) {
			missionPopup.gotoAndStop(2) ;
			missionPopup._y += 25 ;
			missionDone._y -= 20 ;
		} else {
			missionPopup.gotoAndStop(1) ;
			missionOk = true ;
		}
		
		missionPopup._byes.smc.gotoAndStop(2) ;
		missionPopup._selected = 1 ; //yes selected
		
		var a = new anim.Anim(missionPopup, Alpha(1), Quint(1), {speed : 0.15}) ;
		a.sleep = 15.0 ;
		a.onEnd = callback(function(g : Game) {
							g.setMissionListener() ;
						}, this) ;
		a.start() ;
		
						
		missionPopup._byes.onRollOver = callback(setMissionSelection, 0) ;
		missionPopup._byes.onRelease = killMissionPopUp ;
		missionPopup._bno.onRollOver = callback(setMissionSelection, 1) ;
		missionPopup._bno.onRelease = killMissionPopUp ;
	}
	
	public function setMissionSelection(v : Int) {
		if (v == 0) {
			missionPopup._byes.smc.gotoAndStop(2) ;
			missionPopup._bno.smc.gotoAndStop(1) ;
			missionPopup._selected = 0 ;
		} else if (v == 1) {
			missionPopup._byes.smc.gotoAndStop(1) ;
			missionPopup._bno.smc.gotoAndStop(2) ;
			missionPopup._selected = 1 ;
		}
	}
	
	
	public function setMissionListener() {
		switchKeyListener({onKeyDown:callback(onKeyPressMission),
						onKeyUp:callback(Game.me.onKeyReleaseMission)}) ; 
	}
	
	
	public function onKeyPressMission() {
		var n = Key.getCode() ;
		switch(n) {
			case Key.LEFT :
				if (missionPopup._selected == 1)
					return ;
				setMissionSelection(1) ;
				
			case Key.RIGHT :
				if (missionPopup._selected == 0)
					return ;
				setMissionSelection(0) ;
				
		}
	}
	
	
	public function onKeyReleaseMission() {
		var n = Key.getCode() ;
		switch(n) {
			case Key.ENTER :
				killMissionPopUp() ;
		}
	}
	
	
	public function killMissionPopUp() {
		if (!missionPopedUp || missionPopup == null || missionPopup._selected == null )
			return ;
		
		var s = missionPopup._selected ;
		missionPopup._selected = null ;
	
		var sp = 0.08 ;
		if (s == 1) {
			var aa = new anim.Anim(missionDone, Alpha(-1), Quint(1), {speed : sp}) ;
			aa.start() ;
		}
		var a = new anim.Anim(missionPopup, Alpha(-1), Quint(1), {speed : sp}) ;
		
		if (s == 1) {
			missionPopup._bno.smc.gotoAndStop(3) ;
			a.onEnd = callback(function(g : Game) {
				g.stage.startPlay() ;
				g.missionPopup.removeMovieClip() ;
				g.missionDone.removeMovieClip() ;
			}, this) ;
		} else {
			missionPopup._byes.smc.gotoAndStop(3) ;
			a.onEnd = callback(function(g : Game) {
				g.missionOk = true ;
				g.setGameOver() ;
				g.missionPopup.removeMovieClip() ;
			}, this) ;
		}
		a.start() ;
		
		restoreKeyListener() ;
	}
	
	
	public function initPickUp(?forceNew = false, ?m : flash.MovieClip, ?c : {x : Float, y : Float}) {
		if (!forceNew) {
			if (picks.length > 0)
				return picks[picks.length - 1] ;
		} 
		
		if (m == null)
			m = gui._next_spirit ;
		
		
		var np = new PickUp(m, c) ;
		picks.push(np) ;
		
		return np ;
	}


	public function addToJs(f : Void-> Void) {
		toJs.push(f) ;
		
		if (toJs.length == 1)
			haxe.Timer.delay(updateToJs, Const.JS_DELAY) ;
		
	}
	
	public function updateToJs() {
		if (toJs.length == 0)
			return ;
		
		var f = toJs.pop() ;
		f() ;
		
		if (toJs.length > 0)
			haxe.Timer.delay(updateToJs, Const.JS_DELAY) ;
		
		
	}
	
	
	//### KEYS
	function initKeyListener() {
		kl = {
			onKeyDown:callback(onKeyPress),
			onKeyUp:callback(onKeyRelease)
		}
		Key.addListener(kl) ;
	}
	
	
	public function restoreKeyListener() {
		Key.removeListener(ckl) ;
		Key.addListener(kl) ;
	}
	
	
	public function switchKeyListener(k : Dynamic) {
		Key.removeListener(ckl) ;
		Key.addListener(k) ;
		ckl = k ;
	}
	
	
	public function setPause() {
		if (step == Loading || step == GameOver || !started)
			return ;
		var p = !pause ;
		
		if (p) {
			if (pausePanel == null)
				pausePanel = cast Game.me.mdm.attach("clickToStart", Const.DP_BLACK_LOADING) ;
			pausePanel.gotoAndStop(4) ;
			pauseMask =  mdm.attach("endCircle", Const.DP_STAGE_MASK) ;
			pauseMask._xscale = pauseMask._yscale = 0 ;
			
			sound.initSoundSettings() ;
			
			if (stage.next != null)
				stage.next.mc._visible = false ;
			stage.mc.setMask(pauseMask) ;
			
		} else {
			if (pausePanel != null) {
				pausePanel.removeMovieClip() ;
				pausePanel = null ;
			}
			if (stage.next != null)
				stage.next.mc._visible = true ;
			stage.mc.setMask(null) ;
			pauseMask.removeMovieClip() ;
		}
		
		pause = p ;
	}
	
	
	public function onKeyRelease() {
		var n = Key.getCode() ;
			
		switch(n) {
			case Key.LEFT : pLeft = false ;
			case Key.RIGHT : pRight = false ;
		}
	}

	
	public function onKeyPress() {
		var n = Key.getCode() ;
		switch(n) {
			case Key.UP :
				if (!canPlay())
					return ;
				stage.rotate() ;
			case Key.SPACE :
				if (!canPlay())
					return ;
				stage.rotate() ;
			case Key.DOWN : stage.release() ;
				
			case Key.LEFT : 
				if (canPlay())
					pLeft = true ;
			case Key.RIGHT : 
				if (canPlay())
					pRight = true ;
			case 80 : //P for pause
				setPause() ;
				
		}
	}

	
	function updateDebug() {
		if (Key.isDown(50))  //2 doublon
			forceGroup(_Elts(2, null)) ;

		if (Key.isDown(51)) //3 triplet
			forceGroup(_Elts(3, null)) ;

		if (Key.isDown(52)) //3 carré
			forceGroup(_Elts(4, null)) ;

		if (Key.isDown(53)) //5 doublon with neutral
			forceGroup(_Elts(2, _Neutral)) ;

		if (Key.isDown(54)) //6 triplet with neutral
			forceGroup(_Elts(3, _Block(1))) ;

		if (Key.isDown(55)) //7 carré with neutral
			forceGroup(_Elts(4, _Block(2))) ;
		
		if (Key.isDown(65))  //A alchimite
			forceGroup(_Alchimoth) ;
		
		if (Key.isDown(66))  //B Dynamite Bomberman
			forceGroup(_Dynamit(3)) ;
		
		if (Key.isDown(68))  //D dynamit
			forceGroup(_Dynamit(0)) ;

		if (Key.isDown(86)) //V dynamit verticale
			forceGroup(_Dynamit(1)) ;

		if (Key.isDown(88)) //X destroyer 
			forceGroup(_Destroyer(null)) ;
		
		if (Key.isDown(79)) //O Protoplop
			forceGroup(_Protoplop(0)) ;

		/*if (Key.isDown(80)) //P Protoplop level 2
			forceGroup(_Protoplop(1)) ;*/

		if (Key.isDown(78)) //N Neutral(true) élément neutre qui tombe dans une colonne au hasard
			forceGroup(_Neutral) ;

		if (Key.isDown(83)) //S DaltonianParadise(15) 
			forceGroup(_Dalton) ;

		if (Key.isDown(87)) //W WombatAttack
			forceGroup(_Wombat) ;

		if (Key.isDown(71)) //G PearGrain(0)
			forceGroup(_PearGrain(0)) ;
		
		if (Key.isDown(72)) //H PearGrain(1) (souche)
			forceGroup(_PearGrain(1)) ;
		
		if (Key.isDown(74)) //J Jeseleet(0) (souche)
			forceGroup(_Jeseleet(0)) ;
		
		if (Key.isDown(75)) //K Jeseleet(1) (souche)
			forceGroup(_Jeseleet(1)) ;
		
		if (Key.isDown(90)) //Z Dollyxir(0)
			forceGroup(_Dollyxir(0)) ;
		
		if (Key.isDown(69)) //E Delorean
			//forceGroup(_Delorean(0)) ;
			forceGroup(_Skater) ;
		
		if (Key.isDown(82)) //R Detartrage
			//forceGroup(_Detartrage) ;
			forceGroup(_Slide(1)) ;
		
		if (Key.isDown(84)) //T RazKroll
			//forceGroup(_RazKroll) ;
			forceGroup(_Slide(0)) ;
		
		if (Key.isDown(67)) //C Charcleur
			forceGroup(_Grenade(0)) ;
		
		if (Key.isDown(81)) //Q Charcleur à retardement
			forceGroup(_Grenade(1)) ;
		
		if (Key.isDown(70)) //F Charcleur à retardement
			forceGroup(_PolarBomb) ;
		
		if (Key.isDown(76)) //L Charcleur à retardement
			forceGroup(_Tejerkatum) ;
		
		if (Key.isDown(191)) //, Pistonide
			forceGroup(_Pistonide) ;
		
		if (Key.isDown(190)) //, Patchinkrop
			forceGroup(_Patchinko) ;
		
		if (Key.isDown(89)) // ! Teleport
			//forceGroup(_SnowBall) ; 
			forceGroup(_Teleport) ;
		
		if (Key.isDown(77))
			forceGroup(_NowelBall) ; 
			//forceGroup(_MentorHand) ; 
		
		
		if (Key.isDown(Key.CONTROL)) 
			debugPause = true ;
		if (Key.isDown(Key.ALT))
			debugPause = false ;

		
		if (Key.isDown(Key.END)) {// >< forceComboGrid
			stage.forceComboGrid([8, 7, 6, 5, 4, 3, 2]) ;
			
			/*for (x in 0...Stage.WIDTH) {
				for (y in 0...Stage.LIMIT) {
					var o = stage.grid[x][y] ;
					trace("# " + x + ", " + y + " ==> " + Std.string(o.getArtId())) ;
				}
			}*/
		}
		
		if (Key.isDown(46)) //suppr empty stage
			stage.forceEmpty() ;
		
		if (Key.isDown(Key.HOME)) {
			if ((cast mode).rotStep == null)
				(cast mode).chooseWind() ;
		}
			
		
	}
	
	
	public function forceGroup(e : _ArtefactId) {
		var g = stage.nexts.pop() ;
		g.kill() ;
		stage.nexts.push(new Group(e)) ;
	}



}