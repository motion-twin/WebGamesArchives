import flash.Key ;
import mt.bumdum.Lib ;
import mt.bumdum.Part ;
import mt.bumdum.Sprite ;
import mt.bumdum.Phys ;
import GameData.ArtefactId ;
import anim.Transition ;


enum GameStep {
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
	
	public static var me : Game ;
	
	static public var objectsList : mt.flash.PArray<StageObject> = new mt.flash.PArray() ;
	
	public var rdm : mt.DepthManager ;
	public var mdm : mt.DepthManager ;
	public var out : {>flash.MovieClip, bmp : flash.display.BitmapData} ;
	public var root : flash.MovieClip ;
	public var mc : flash.MovieClip ;
	public var bg : flash.MovieClip ;
	
	//interface
	public var gui : {>flash.MovieClip, 
						_score 			: {>flash.MovieClip, _field : flash.TextField},
						_spirit_box 	: {>flash.MovieClip, _spirit : flash.MovieClip , _wheel : flash.MovieClip},
						_next_elements 	: {>flash.MovieClip, _next_spirit : flash.MovieClip , _elem : flash.MovieClip},
						_inventory_slot : {>flash.MovieClip, _obj1 : flash.MovieClip , _obj2 : flash.MovieClip , _obj3 : flash.MovieClip , _obj4 : flash.MovieClip },
						_group_mask : flash.MovieClip,
						_force_group_mask : flash.MovieClip
					} ;
	
	public var mcChain : Array<ObjectMc> ;
	public var artefact : mt.flash.PArray<StageObject> ;
	public var onEndFall : Array<Void -> Void> ;
	
	public var data : GameData ;	
	public var step : GameStep ;
	public var score : mt.flash.Volatile<Int> ;
	public var gameOver : Bool ;
	public var mode : mode.GameMode ;
	public var stage : Stage ;
	var gTimer : Float ;
	var kl : Dynamic ;
	var ckl : Dynamic ;
	public var picks : mt.flash.PArray<PickUp> ;
	
	public var pLeft : Bool ;
	public var pRight : Bool ;

	
	public function new(mc : flash.MovieClip) {
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces() ;
		
		root = mc ;
		me = this ;
		gameOver = false ;
		artefact = new mt.flash.PArray() ;
		onEndFall = new mt.flash.PArray() ;
		score = 0 ;
		step = Fall ;
		picks = new mt.flash.PArray() ;
		
		pLeft = false ;
		pRight = false ;

		
		rdm = new mt.DepthManager(root) ;
		this.mc = rdm.empty(2) ;
		mdm = new mt.DepthManager(this.mc) ;
		initKeyListener() ;	
		
		loadData() ;
		init() ;
		start() ;
	}
	
	function init() {	
		initBg() ;
		initInterface() ;
		initGame() ;
	}
	
	
	function initGame() {
		mode = mode.GameMode.get(data) ;
	}
	
	public function start() {
		stage = new Stage() ;
		stage.init(null) ;
	}
	
	function initInterface() {
		
		var skin = rdm.attach("mcBg", 1) ;
		skin._x  = 0 ;
		skin._y  = 0 ;
		
		var mcInterface = mdm.empty(Const.DP_INTERFACE) ;
		
		var idm = new mt.DepthManager(mcInterface) ;
		
		gui = cast idm.attach("gui", 1) ;
		gui._inventory_slot.gotoAndStop(1);
				
		gui._group_mask = mdm.attach("group_mask", Const.DP_GROUP_BOX) ;
		gui._group_mask._alpha = 0 ;
		gui._group_mask._x = Const.GROUP_MASK_X ;
		gui._group_mask._y = Const.GROUP_MASK_Y ;
		
		gui._force_group_mask = mdm.attach("group_mask", Const.DP_GROUP_BOX) ;
		gui._force_group_mask._alpha = 0 ;
		gui._force_group_mask._x = Const.GROUP_MASK_X ;
		gui._force_group_mask._y = Const.GROUP_MASK_Y ;
		
		
		/*var m = mdm.attach("group_mask", Const.DP_GROUP_BOX) ;
		m._x = 204 ;
		m._y = 152 ;
		*/
		//mcNext = gui.next_elements;
		//mcInventory = gui.inventory_slot;
		
		
	/*	var sdm = new mt.DepthManager(gui._spirit_box._spirit) ;
		
		var sf = callback(function(g : Game) {
			g.spirit.initGamePos();
			Reflect.setField(g.spirit.mc, "_next", g.spiritNextAnim) ;
		}, this) ;
		
		spirit = new Spirit(Std.string(1), sdm, 2, sf) ;
		spiritAnims = {onStage : false, l : new List()} ;*/
		
		mcChain = new Array() ;
		var cx = 237.5 ;
		var cy = 115.8 ;
		for (i in 0...12) {
			var omc = new ObjectMc(Elt(i), mdm, i + 5) ;
			omc.mc._x = cx ;
			omc.mc._y = cy ;
			
			cy += 14.1 ;

			omc.mc._xscale = omc.mc._yscale = 56.4 ;
			
			if (i > 2)
				Col.setPercentColor(omc.mc, 84, Const.HIDE_CHAIN_COL) ; 
			
			mcChain.push(omc) ;
		}
		
		
	}
	
	
	public function setSpiritState(c : Int) {
		/*var s = if (c >= 4) 
				"_bravo"
			else 
				"_combo" + Std.int(Math.max(0, c)) ;

		if (s != null)
			spiritAnims.l.add(s) ;
		
		
		if (!spiritAnims.onStage)
			spiritNextAnim() ;*/
	}
	
	
	public function spiritNextAnim() {
		/*var a = spiritAnims.l.pop() ;
		
		spiritAnims.onStage = a != null ;
		
		if (a == null)
			a = "_stand" ;
		
		spirit.play(a) ;*/
	}
	
	
	function initBg() {
		bg = mdm.attach("bg", Const.DP_BG) ;
		bg._x = 0 ;
		bg._y = 0 ;
	}
	
	
	public function loadData() {
		data = Const.getDataGame() ;
	}
	
	public function updateScore() {
		KKApi.setScore(mode.updateScore()) ;
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
		/*step = s ;
		if (step == ArtefactInUse)
			artefact.push(a) ;
		else  {
			artefact = [] ;
		}*/
		
		if (s == ArtefactInUse) {
			step = s ;
			artefact.push(a) ;
		} else {
			if (artefact.length == 0)
				step = s ;
			/*else 
				trace("error : step " + s +  " with living artefactInUse") ;*/
		}
	}
	
	public function canPlay() {
		return step == Play ;
	}
	
	
	public function cheatDetected() : Bool {
		
		if (objectsList != null && objectsList.cheat)
			return true ;
		if (picks != null && picks.cheat)
			return true ;
		if (artefact != null && artefact.cheat)
			return true ;
		
		
		
		if (stage != null) {
			/*if (stage.grid != null && stage.grid.cheat) {
				return true ;
			}
			if (stage.grid != null) {
				for (l in stage.grid) {
					if (l.cheat) {
						return true ;
					}
				}
			}*/
			if (stage.next != null && stage.next.objects != null && stage.next.objects.cheat)
				return true ;
			if (stage.falls != null && stage.falls.cheat)
				return true ;
			if (stage.groups != null && stage.groups.cheat)
				return true ;
			if (stage.killParasits != null && stage.killParasits.cheat)
				return true ;
			if (stage.transforms != null && stage.transforms.cheat)
				return true ;
			if (stage.toDestroy != null && stage.toDestroy.cheat)
				return true ;
		}
		
		if (mode != null) {
			if (mode.chain != null && mode.chain.cheat)
				return true ;
			if (mode.chWeight != null && mode.chWeight.cheat)
				return  true ;
		}
			
		
		
		

		return false ;
	}
	
	
	public function update() {
		if (cheatDetected()) {
			trace("cheat") ;
			KKApi.flagCheater() ;
		}
		
		updateSprites() ;
		updateObjects() ;
		updateMoves() ;
		
		if (picks.length > 0) {
			for( p in picks.copy()) {
				p.update() ;
			}
		}
		
		if (stage == null)
			return ;
		
		stage.updateEffect() ;
		stage.fall() ;
		
		/*if (Const.FL_DEBUG)
			updateDebug() ;*/
		
		
		switch(step) {
			case Wait :
				
			case Play :
				if (stage.next != null)
					stage.next.update() ;
				
			case Fall :
				if (!stage.isFalling()) {
					if (!stage.check()) {
						if (!mode.checkFallEnd()) {
							stage.startPlay() ;
							updateScore() ;
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
				//nothing to do
				
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
		KKApi.gameOver({}) ;
		setStep(GameOver) ;
	}
	
	public function isGameOver() {
		return step == GameOver ;
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
				
		}
	}

/*
	function updateDebug() {
		if (Key.isDown(50))  //2 doublon
			forceGroup(Elts(2, null)) ;

		if (Key.isDown(51)) //3 triplet
			forceGroup(Elts(3, null)) ;

		if (Key.isDown(52)) //3 carré
			forceGroup(Elts(4, null)) ;

		if (Key.isDown(53)) //5 doublon with neutral
			forceGroup(Elts(2, Neutral)) ;

		if (Key.isDown(54)) //6 triplet with neutral
			forceGroup(Elts(3, Block(1))) ;

		if (Key.isDown(55)) //7 carré with neutral
			forceGroup(Elts(4, Block(2))) ;
		
		if (Key.isDown(65))  //A alchimite
			forceGroup(Alchimoth) ;
		
		if (Key.isDown(66))  //B Dynamite Bomberman
			forceGroup(Dynamit(3)) ;
		
		if (Key.isDown(68))  //D dynamit
			forceGroup(Dynamit(0)) ;

		if (Key.isDown(86)) //V dynamit verticale
			forceGroup(Dynamit(1)) ;

		if (Key.isDown(88)) //X destroyer 
			forceGroup(Destroyer(null)) ;
		
		if (Key.isDown(79)) //O Protoplop
			forceGroup(Protoplop(0)) ;

		if (Key.isDown(80)) //P Protoplop level 2
			forceGroup(Protoplop(1)) ;

		if (Key.isDown(78)) //N Neutral(true) élément neutre qui tombe dans une colonne au hasard
			forceGroup(Neutral) ;

		if (Key.isDown(83)) //S DaltonianParadise(15) 
			forceGroup(Dalton) ;

		if (Key.isDown(87)) //W WombatAttack
			forceGroup(Wombat) ;

		if (Key.isDown(77)) //M MentorHand
			forceGroup(MentorHand) ;
		
		if (Key.isDown(71)) //G PearGrain(0)
			forceGroup(PearGrain(0)) ;
		
		if (Key.isDown(72)) //H PearGrain(1) (souche)
			forceGroup(PearGrain(1)) ;
		
		if (Key.isDown(74)) //J Jeseleet(0) (souche)
			forceGroup(Jeseleet(0)) ;
		
		if (Key.isDown(75)) //K Jeseleet(1) (souche)
			forceGroup(Jeseleet(1)) ;
		
		if (Key.isDown(90)) //Z Dollyxir(0)
			forceGroup(Dollyxir(0)) ;
		
		if (Key.isDown(69)) //E Delorean
			forceGroup(Delorean(0)) ;
		
		if (Key.isDown(82)) //R Detartrage
			forceGroup(Detartrage) ;
		
		if (Key.isDown(84)) //R RazKroll
			forceGroup(RazKroll) ;
		
		if (Key.isDown(67)) //C Charcleur
			forceGroup(Grenade(0)) ;
		
		if (Key.isDown(81)) //Q Charcleur à retardement
			forceGroup(Grenade(1)) ;
		
		if (Key.isDown(70)) //F Charcleur à retardement
			forceGroup(PolarBomb) ;
		
		if (Key.isDown(76)) //L Charcleur à retardement
			forceGroup(Tejerkatum) ;
		
		if (Key.isDown(191)) //, Pistonide
			forceGroup(Pistonide) ;
		
		if (Key.isDown(190)) //, Patchinkrop
			forceGroup(Patchinko) ;
		
		if (Key.isDown(89)) // ! Teleport
			forceGroup(Teleport) ;
		

		
		if (Key.isDown(Key.END)) // >< forceComboGrid
			stage.forceComboGrid([10, 9, 8, 7, 6, 5]) ;
		
		if (Key.isDown(46)) //suppr empty stage
			stage.forceEmpty() ;
		
	}
	
	
	public function forceGroup(e : ArtefactId) {
		var g = stage.nexts.pop() ;
		g.kill() ;
		stage.nexts.push(new Group(e)) ;
	}
*/

}
