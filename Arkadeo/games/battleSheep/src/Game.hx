import mt.bumdum9.Lib ;
using mt.bumdum9.MBut ;
import mt.bumdum9.Tools ;

import api.AKApi ;
import api.AKProtocol ;
import api.AKConst ;
import TitleLogo ;

import flash.display.Bitmap ;
import flash.display.BitmapData ;
import flash.display.MovieClip ;
import flash.display.Sprite ;
import flash.display.BlendMode ;
import flash.ui.Keyboard ;
import mt.flash.Key ;

import mt.deepnight.SpriteLib ;
import Spot.Building ;


typedef Coord = {
	var x : Float ;
	var y : Float ;
}


enum Race {
	None ; 
	Auk ; 
	Sheep ;
	Pig ;
}


enum Step {
	Init ;
	Choice_Building ;
	Play ;
	Transition ;
	GameOver ;
}



typedef Diff = {
	var iaLvl : Array<Int> ;
	var pPop : Int ;
	var oppPop : Int ;
	var oppSpots: Int ;
	var mPop : Int ;
	var lEnd : Null<Array<Int>> ;
}


@:bitmap("gfx/images/tiles.png") class GfxTiles extends BitmapData { }
@:bitmap("gfx/images/bg.jpg") class GfxBg extends BitmapData { }
@:bitmap("gfx/images/plateau.png") class GfxFg extends BitmapData { }


@:build(mt.data.Texts.build("texts.fr.xml"))
class Text{}


class Game extends SP {

	public static var MIN_DIST = 30 ; //pixels between two statics elements
	public static var MIN_BORDER = 65 ;
	public static var MIN_Y = 45 ;

	//main dm
	public static var MDP_ARTWORK = 0 ;
	public static var MDP_SPOT_INFO = 1 ;
	public static var MDP_TIP = 2 ;
	public static var MDP_STAGE = 3 ;

	//local stage
	public static var DP_BG = 1 ;
	public static var DP_SLOW_FX = 2 ;
	public static var DP_SPOT_BG = 4 ;
	public static var DP_WAR_SHADOWS = 5 ;
	public static var DP_WARFIELD =	6 ;
	public static var DP_INTER = 	7 ;
	public static var DP_MASK = 	8 ;
	public static var DP_FX = 		9 ;
	public static var DP_FX_2 = 	10 ;
	public static var DP_POP =	 	11 ;
	public static var DP_BG_CLICK = 12 ;
	public static var DP_CLICK = 	13 ;
	public static var DP_FG = 		14 ;
	public static var DP_VICT = 	15 ;

	public static var WIDTH = 600 ;
	public static var HEIGHT = 480 ;


	public static var LEAGUE_POP_POINT = api.AKApi.const(100) ;
	public static var LEAGUE_BONUS_POINT = api.AKApi.const(30) ;
	public static var LEAGUE_STAGE_POINT = api.AKApi.const(6000) ;

	public static var PROG_BUILDINGS = [0, 0, //2
										1, 1, 1, //5
										2, 2, 2, 2, //9
										3, 3, 3, 3, //13
										4, 4, 4, 4, //17
										5, 5, 5, 5, //21
										6, 6, 6, 6, 6, //26
										7, 7, 7, 7, 7, //31
										8, 8, 8, 8, 8, //36
										9, 9, 9, 9, 9,//41
										] ;

	public var tiles : SpriteLib ;
	public var ia : IA ;

	public static var me : Game ;
	var bg : SP ;
	var fg : SP ;

	public var mdm : mt.DepthManager ;
	public var dm : mt.DepthManager ;
	public var fxm : mt.fx.Manager ;

	public var stages : Array<{st : Sprite, bg : BitmapData, dm : mt.DepthManager}> ;

	public var leagueLevel : mt.flash.Volatile<Int> ;
	public var leagueSpotInfo : {>MC, _text : TF} ;
	var leagueLastCount : Int ;
	public var leagueSpotInfoEnnemy : {>MC, _text : TF} ;

	public var seed : mt.Rand ;
	
	var timer : Null<Float> ;
	public var level : Int ;
	public var mode : GameMode ;
	public var races : Array<Race> ;
	public var spots : Array<Spot> ;
	public var swarms : Array<Swarm> ;

	var step : Step ;

	public var curTip : Sprite ;
	public var curTipClick : Sprite ;
	public var plagueSP : Sprite ;
	public var slowSP : Sprite ;

	public var gameOver : Bool ;

	public var selectedSpot : Null<Spot> ;
	public var canUnselectOnUp : Null<Spot> ;

	public var progPool : Array<Null<Int>> ;
	public var curPool : Int ;

	var avKPoints : Array<api.SecureInGamePrizeTokens> ;
	var progLastKPoint : Null<Float> ;
	public var curKPoints : Array<KPoint> ;

	public var spChoice : Sprite  ;
	public var avChoices : Array<{idx : Int, sp : DSprite}> ;

	public var spVict : { bg : SP,
							txt : {>MC, _text : TF},
							bonus : {>MC, _text : TF}
							} ;

		
	public function new() {
		super() ;

		haxe.Log.setColor(0xFFFF00) ;
		haxe.Firebug.redirectTraces() ;

		me = this ;
		level = 0 ;
		gameOver = false ;
		//haxe.Log.setColor(0xFFFFFF) ;
		stages = [] ;
		step = Init ;

		var raw = haxe.Resource.getString("texts."+AKApi.getLang()+".xml") ;
		if( raw == null ) raw = haxe.Resource.getString("texts.en.xml") ;
		Text.init( raw ) ;
		
		var sd = AKApi.getSeed() ;
		#if debug
		//sd = 90881 ; //### DEBUG
		#end
		seed = new mt.Rand(sd) ;
		#if debug

		trace("seed : " + sd )  ;
		#end

		mode = AKApi.getGameMode() ;
		level = AKApi.getLevel() ;

		avKPoints = api.AKApi.getInGamePrizeTokens().copy() ;

		
		progLastKPoint = isProgression() ? 0.55 : null ;
		curKPoints = [] ;

		races = [Sheep, Auk] ;
		
		fxm = new mt.fx.Manager() ;
		mdm = new mt.DepthManager(this) ; 
		
		var artwork = new Sprite() ;
		artwork.addChild(new Bitmap(new GfxBg(0, 0))) ;
		artwork.cacheAsBitmap = true ;

		mdm.add(artwork, MDP_ARTWORK) ;

		initTiles() ;

		var choiceSeed = random(999) ;


		leagueLastCount = 0 ;
		leagueSpotInfo = cast new gfx.Pop2() ;
		mdm.add(leagueSpotInfo, Game.DP_POP) ;
		leagueSpotInfo.scaleX = leagueSpotInfo.scaleY = 2.0 ;
		leagueSpotInfo.x = 35 ;
		leagueSpotInfo.y = 15 ;

		leagueSpotInfoEnnemy = cast new gfx.Pop1() ;
		mdm.add(leagueSpotInfoEnnemy, Game.DP_POP) ;
		leagueSpotInfoEnnemy.scaleX = leagueSpotInfoEnnemy.scaleY = 2.0 ;
		leagueSpotInfoEnnemy.x = WIDTH - 35 ;
		leagueSpotInfoEnnemy.y = 15 ;
		
		switch(AKApi.getGameMode()) {
			case GM_PROGRESSION : 
				setGameState() ;
				
				if (level == 1 && curPool > 0) {
					curPool = 0 ;
					progPool = [] ;
				}

				saveGameState() ;

				var maxPool = PROG_BUILDINGS[Std.int(level)] ;

				if (curPool == 0 && maxPool - curPool > 1) {
					//mission : generate random buildings
					curPool = maxPool ;
					for (i in 0...maxPool) {
						var idx = random(7) ;
						if (progPool[idx] == null)
							progPool[idx] = 0 ;
						progPool[idx]++ ;
					}
					start() ;

				} else if (curPool < maxPool)
					prepareProgChoice(choiceSeed) ;
				else 
					start() ;

			case GM_LEAGUE : 
				setLeagueLevel(0) ;

				start() ;

				checkEnd() ;
				//new mt.fx.Spawn(leagueSpotInfo) ;

				//trace(leagueSpotInfo._text.text) ;


			default : //mission/clan ???
		}
	}


	function setLeagueLevel(l : Int) {
		leagueLevel = l ;
		AKApi.setStatusText(Text.statusInfo({ _LVL : Std.int(leagueLevel + 1) })) ;
	}

	function start() {
		initLevel() ;
		step = Play ;
	}



	public function isProgression() {
		return Type.enumEq(mode, GM_PROGRESSION) ;
	}



	public function isPlaying() : Bool {
		return Type.enumEq(step, Play) ;
	}


	public function initTiles() {

		var w = 16 ;
		var h = 16 ;

		tiles = new SpriteLib( new GfxTiles(0,0) ) ;
		tiles.setDefaultCenter(0.5, 0.5) ;
		tiles.setUnit(w, h) ;

		tiles.sliceUnit("sheep", 0, 0) ;
		tiles.sliceUnit("sheep_run", 1, 0, 4) ;
		tiles.setAnim("sheep_run_anim", 0, [0, 1, 2, 3], [3, 3, 3, 4]) ;

		tiles.sliceUnit("pig", 0, 1) ;
		tiles.sliceUnit("pig_run", 1, 1, 4) ;
		tiles.setAnim("pig_run_anim", 0, [0, 1, 2, 3], [3, 3, 3, 3]) ;

		tiles.sliceUnit("auk", 0, 2) ;
		tiles.sliceUnit("auk_run", 1, 2, 5) ;
		tiles.setAnim("auk_run_anim", 0, [0, 1, 2, 3, 4], [3, 3, 3, 3, 3]) ;


		tiles.sliceUnit("shadow_sheep", 0, 3) ;
		tiles.sliceUnit("shadow_pig", 1, 3) ;
		tiles.sliceUnit("shadow_auk", 2, 3) ;
		tiles.sliceUnit("footprint", 3, 3) ;

		tiles.sliceUnit("hit", 4, 3, 3) ;
		tiles.setAnim("hit_anim", 0, [0, 1, 2], [2, 2, 4]) ;

		tiles.sliceUnit("heart", 7, 3) ;
		tiles.sliceUnit("bonusHead", 8, 3) ;


		tiles.slice("field_0", w, 8*h, 2*w, 3*h) ;
		tiles.slice("field_1", w, 12*h, 3*w, 4*h) ;
		tiles.slice("field_2", w, 17*h, 56, 64) ;
		tiles.slice("field_3", w, 22*h, 72, 80) ;

		tiles.slice("fence_0", w, 10*h + 6, 2*w, 10) ;
		tiles.slice("fence_1", w, 15*h+6, 3*w, 10) ;
		tiles.slice("fence_2", w, 20*h+6, 56, 10) ;
		tiles.slice("fence_3", w, 26*h+6, 72, 10) ;

		tiles.slice("shadow_0", 6*w, 9*h, 3*w, 3*h) ;
		tiles.slice("shadow_1", 6*w, 13*h, 4*w, 4*h) ;
		tiles.slice("shadow_2", 6*w, 17*h, 4*w, 5*h) ;
		tiles.slice("shadow_3", 6*w, 22*h, 5*w, 6*h) ;

		/*tiles.slice("ground_0_pig", 11*w, 8*h, 4*w, 4*h) ;
		tiles.slice("ground_1_pig", 11*w, 12*h, 5*w, 5*h) ;
		tiles.slice("ground_2_pig", 11*w, 17*h, 5*w, 5*h) ;
		tiles.slice("ground_3_pig", 11*w, 22*h, 6*w, 6*h) ;*/

		tiles.slice("ground_0_sheep", 18*w, 8*h, 4*w, 4*h) ;
		tiles.slice("ground_1_sheep", 18*w, 12*h, 5*w, 5*h) ;
		tiles.slice("ground_2_sheep", 18*w, 17*h, 5*w, 5*h) ;
		tiles.slice("ground_3_sheep", 18*w, 22*h, 6*w, 6*h) ;

		tiles.slice("ground_0_none", 11*w, 8*h, 4*w, 4*h) ;
		tiles.slice("ground_1_none", 11*w, 12*h, 5*w, 5*h) ;
		tiles.slice("ground_2_none", 11*w, 17*h, 5*w, 5*h) ;
		tiles.slice("ground_3_none", 11*w, 22*h, 6*w, 6*h) ;

		/*tiles.slice("ground_0_sheep", 11*w, 8*h, 4*w, 4*h) ;
		tiles.slice("ground_1_sheep", 11*w, 12*h, 5*w, 5*h) ;
		tiles.slice("ground_2_sheep", 11*w, 17*h, 5*w, 5*h) ;
		tiles.slice("ground_3_sheep", 11*w, 22*h, 6*w, 6*h) ;

		tiles.slice("ground_0_pig", 18*w, 8*h, 4*w, 4*h) ;
		tiles.slice("ground_1_pig", 18*w, 12*h, 5*w, 5*h) ;
		tiles.slice("ground_2_pig", 18*w, 17*h, 5*w, 5*h) ;
		tiles.slice("ground_3_pig", 18*w, 22*h, 6*w, 6*h) ;*/

		tiles.slice("ground_0_auk", 25*w, 8*h, 4*w, 4*h) ;
		tiles.slice("ground_1_auk", 25*w, 12*h, 5*w, 5*h) ;
		tiles.slice("ground_2_auk", 25*w, 17*h, 5*w, 5*h) ;
		tiles.slice("ground_3_auk", 25*w, 22*h, 6*w, 6*h) ;

		tiles.slice("select_0", 32*w - 4, 8*h, 48, 37) ;
		tiles.slice("select_1", 32*w - 4, 12*h, 64, 52) ;
		tiles.slice("select_2", 32*w - 4, 17*h, 72, 60) ;
		tiles.slice("select_3", 32*w - 4, 22*h, 88, 76) ;

		//###
		tiles.slice("front_select_0", 32*w - 4, 10*h + 5, 48, 13) ;
		tiles.slice("front_select_1", 32*w - 4, 15*h + 4, 64, 13) ;
		tiles.slice("front_select_2", 32*w - 4, 20*h + 12, 72, 13) ;
		tiles.slice("front_select_3", 32*w - 4, 26*h + 12, 88, 13) ;


		tiles.slice("target_select_0", 39*w - 7, 8*h - 4, 60, 41) ;
		tiles.slice("target_select_1", 39*w - 7, 12*h - 4, 76, 56) ;
		tiles.slice("target_select_2", 39*w - 7, 17*h - 4, 84, 64) ;
		tiles.slice("target_select_3", 39*w - 7, 22*h - 4, 100, 80) ;

		//###
		tiles.slice("target_front_select_0", 39*w - 7, 10*h + 5, 60, 16) ;
		tiles.slice("target_front_select_1", 39*w - 7, 15*h + 4, 76, 16) ;
		tiles.slice("target_front_select_2", 39*w - 7, 20*h + 12, 84, 16) ;
		tiles.slice("target_front_select_3", 39*w - 7, 26*h + 12, 100, 16) ;

		tiles.slice("sheep_explode", 11*w, 0, 2*w, 2*h, 7) ;
		tiles.slice("pig_explode", 11*w, 2*h, 2*w, 2*h, 7) ;
		tiles.slice("auk_explode", 11*w, 4*h, 2*w, 2*h, 7) ;
		tiles.setAnim("race_explode", 0, [0, 1, 2, 3, 4, 5, 6], [2, 2, 2, 2, 2]) ;

		tiles.slice("sheep_art", 31*w, 32*h, 3*w, 3*h) ;
		tiles.slice("auk_art", 35*w + 9, 32*h, 50, 3*h) ;

		//### CLASH 
		tiles.slice("cloud_0", 0, 29 * h, 3*w, 3*h, 5) ;
		tiles.slice("cloud_1", 0, 32 * h, 3*w, 3*h, 5) ;
		tiles.slice("cloud_2", 0, 35 * h, 3*w, 3*h, 5) ;
		tiles.setAnim("cloud_anim", 0, [0, 1, 2, 3, 4], [3, 3, 3, 3, 3]) ;

		tiles.slice("clash_sheep", 15*w, 29*h, 3*w, 3*h, 5) ;
		tiles.slice("clash_pig", 15*w, 32*h, 3*w, 3*h, 5) ;
		tiles.slice("clash_auk", 15*w, 35*h, 3*w, 3*h, 5) ;
		tiles.setAnim("clash_anim", 0, [0, 1, 2, 3, 4], [3, 3, 3, 3, 3]) ;


		//### BUILDINGS
		tiles.slice("bld_Bunker", w-3, 39*h, 2*w+3, 3*h + 3) ;
		tiles.slice("bld_Watch", 4*w-3, 38*h, 2*w+3, 4*h + 3) ;
		tiles.slice("bld_Fast", 7*w-3, 40*h, 2*w+3, 2*h + 3) ;
		tiles.slice("bld_Bonus", 10*w-7, 40*h, w+8, 2*h + 7) ;

		tiles.slice("bld_Box", 24*w-3, 39*h, 2*w+3, 3*h + 3) ;
		tiles.slice("bld_TinyBox", 24*w-3, 44*h, w+7, 2*h + 3) ;

		tiles.slice("kPoint_0", 27*w, 44*h+7, w+3, 2*h-7) ;
		tiles.slice("kPoint_1", 29*w, 44*h+7, w+3, 2*h-7) ;
		tiles.slice("kPoint_2", 31*w, 44*h+7, w+3, 2*h-7) ;
		tiles.slice("kPoint_3", 33*w, 44*h+7, w+3, 2*h-7) ;
		tiles.slice("kPoint_shadow", 35*w, 44*h+13, w+3, 2*h-13) ;

		tiles.slice("bld_Rage", 9*w, 43*h - 3, w+6, 3*h + 3, 7) ;
		tiles.setAnim("bld_Rage_anim", 0, [0, 1, 2, 3, 4, 5, 6], [5, 5, 5, 5, 5, 5, 5]) ;
		
		tiles.slice("bld_Plague", w - 9, 46*h, w+9, 3*h + 9, 8) ;
		tiles.setAnim("bld_Plague_anim", 0, [0, 1, 2, 3, 4, 5, 6, 7], [120, 6, 6, 12, 3, 3, 3, 3]) ;

		tiles.slice("bld_MoreSex", w - 3, 50*h, 2*w+3, 3*h + 3, 8) ;
		tiles.setAnim("bld_MoreSex_anim", 0, [0, 1, 2, 1, 0, 1, 2, 1, 4, 5, 6], [18, 18, 18, 18, 18, 18, 240, 40, 12, 12, 12]) ;

		tiles.slice("bld_Slow", w - 3, 54*h, 2*w + 3, 2*h + 11, 5) ;
		tiles.setAnim("bld_Slow_anim", 0, [0, 1, 2, 3, 4], [6, 6, 6, 6, 6]) ;
	}




	function prepareProgChoice(localSeed : Int) {

		initStage() ;
		if (leagueSpotInfo != null)
			leagueSpotInfo.alpha = 0.0 ;
		if (leagueSpotInfoEnnemy != null)
			leagueSpotInfoEnnemy.alpha = 0.0 ;
		initBg(false) ;

		step = Choice_Building ;

		var cSeed = new mt.Rand(localSeed) ;
		cSeed.random(999) ;

		var av = [] ;
		for (i in 0...7)
			av.push(i) ;

		avChoices = [] ;
		for (i in 0...2) {

			var b = av[cSeed.random(av.length)] ;
			av.remove(b) ;
			//trace("choice : " + b + " # " +  av.length) ;
			avChoices.push({idx : b, sp : null}) ;
		}

		spChoice = new Sprite() ;
		dm.add(spChoice, DP_WARFIELD) ;

		//YOUR COLLECTION 


		var bc = getBldColl(true, true) ;
		if (bc != null) {
			var bldColl = bc.coll ;
		
			bldColl.alpha = 0.75 ;
			spChoice.addChild(bldColl) ;
			bldColl.x = (WIDTH - bldColl.width) / 2 ;
			bldColl.y = 420 ;
		}


		var f = new flash.text.TextFormat();
		f.font = "TrebuchetMS" ;
		f.size = 24 ;
		f.align = CENTER ;
		f.bold = true ;
		f.color = 0xffffff ;
	

		var tf = new TF() ;
		tf.mouseEnabled = tf.selectable = false ;
		tf.defaultTextFormat = f ;
		tf.text = Text.choice_choose_one ;
		tf.width = WIDTH ;
		tf.height = 50 ;

		tf.x = 0 ;
		tf.y =  80 ;

		
		tf.filters = [new flash.filters.DropShadowFilter(2, 75, 0x111111,0.7, 1, 1, 5)] ;

		spChoice.addChild(tf) ;

		var pos = [230, 370] ;
		for (i in 0...2) {
			var bIdx = Std.int(avChoices[i].idx) ;

			var building = Type.createEnumIndex(Building, bIdx) ;
			var bInfos = Spot.BUILDING_INFOS[bIdx] ;

			var bName = "bld_" + bInfos.id ;

			/*if (bInfos.anim) {
				avChoices[i].sp = Game.me.tiles.getSpriteAnimated(bName, bName + "_anim") ;
				avChoices[i].sp.offsetAnimFrame() ;
			} else*/
			avChoices[i].sp = Game.me.tiles.getSprite(bName) ;


			spChoice.addChild(avChoices[i].sp) ;

			avChoices[i].sp.scaleX = avChoices[i].sp.scaleY = 2.0 ;

			avChoices[i].sp.x = pos[i] ;
			avChoices[i].sp.y = 250 - avChoices[i].sp.height / 2 ;

			avChoices[i].sp.onClick(callback(chooseBldClick, bIdx)) ;
			avChoices[i].sp.onOver(callback(function(s : Sprite, b : Building) { 
										Filt.glow(s, 7, 10, 0xFFFFFF) ;
										Game.me.showBuildingInfo(null, b) ;
									} , avChoices[i].sp, building)) ;
			avChoices[i].sp.onOut(callback(function(s : Sprite, b : Building) { 
										s.filters = [] ;
										Game.me.hideBuildingInfo() ;
									} , avChoices[i].sp, building)) ;
		}
	}


	public function getBldColl(?allGrey = false, ?withDesc = false, ?f : Int -> Void) : {coll : Sprite, click : Sprite} {
		var sp = new Sprite() ;
		var spc : Sprite = null ;
		if (f != null)
			spc = new Sprite() ;

		var w = 0 ;
		var delta = 46 ;

		var found = false ;

		var spDesc = null ;

		for (i in 0...progPool.length) {
			if (progPool[i] == null)
				continue ;

			found = true ;

			var bInfos = Spot.BUILDING_INFOS[i] ;

			var building = Type.createEnumIndex(Building, i) ;
			var bName = "bld_" + bInfos.id ;
			var sBld = null ;

			/*if (bInfos.anim) {
				sBld = Game.me.tiles.getSpriteAnimated(bName, bName + "_anim") ;
				sBld.offsetAnimFrame() ;
			} else*/
			sBld = Game.me.tiles.getSprite(bName) ;
			sp.addChild(sBld) ;


			var sc : Sprite = null ;
			if (f != null) {
				sc = new Sprite() ;
				sc.graphics.beginFill(0xFFFFFF, 0.0) ;
				sc.graphics.drawRect(-sBld.width / 2, -sBld.height / 2, sBld.width, sBld.height) ;
				sc.graphics.endFill() ;
				spc.addChild(sc) ;
			}


			if (progPool[i] > 0) {
				if (allGrey)
					Filt.grey(sBld) ;

				if (f != null) {

					sc.onClick(callback(f, i)) ;
					sc.onOver(callback(function(s : Sprite, b : Building, g : Bool, d : Bool) { 
											if (g)
												s.filters = [] ;
											Filt.glow(s, 3, 5, 0xFFFFFF) ;
											if (d)
												Game.me.showBuildingInfo(null, b) ;
										} , sBld, building, allGrey, withDesc)) ;
					sc.onOut(callback(function(s : Sprite, b : Building, g : Bool, d : Bool) { 
											s.filters = [] ;
											if (g)
												Filt.grey(s) ;
											if (d) 
												Game.me.hideBuildingInfo() ;
										} , sBld, building, allGrey, withDesc)) ;
				}

				var snb : {>MC, _text : TF} = cast new gfx.Pop2() ;
				sBld.addChild(snb) ;
				snb.scaleX = snb.scaleY = 1.0 ;
				snb._text.text = Std.string(progPool[i]) ;
				snb.x = 12 ;
				snb.y = sBld.height / 2 - 5 ;

			} else {
				Filt.grey(sBld) ;
				var snb : {>MC, _text : TF} = cast new gfx.Pop3() ;
				sBld.addChild(snb) ;
				snb.scaleX = snb.scaleY = 1.0 ;
				snb._text.text = "0" ;
				snb.x = 12 ;
				snb.y = sBld.height / 2 - 5 ;

				if (f != null) {
					sc.onOver(callback(function(s : Sprite, b : Building, d : Bool) { 
											if (d)
												Game.me.showBuildingInfo(null, b) ;
										} , sBld, building, withDesc)) ;
					sc.onOut(callback(function(s : Sprite, b : Building, d : Bool) { 
											if (d)
												Game.me.hideBuildingInfo() ;
										} , sBld, building, withDesc)) ;
				}
			}

			var lw = delta ;
			if (i == 3 || i == 4)
				lw = Std.int(delta / 3 * 2) ;

			sBld.y = -sBld.height / 2 ;
			sBld.x = w + lw / 2  ;

			if (sc != null) {
				sc.x = sBld.x ;
				sc.y = sBld.y ;
			}

			w += lw ;
		}

		if (!found)
			return null ;

		return {coll : sp, click : spc} ;
	}


	public function setProgressionScore() {


		if (!Type.enumEq(step, Play))
			return ;

		var your = 0 ;
		var adv = 0 ;

		for (s in spots) {
			if (s.isNeutral())
				continue ;
			if (s.ennemy)
				adv++ ;
			else 
				your++ ;
		}

		var lim = 0.25 ;

		var sc = lim + Math.max(-lim, ((your - adv) / your - lim)) ;

		AKApi.setProgression(sc) ;

		if (sc <= progLastKPoint || avKPoints.length == 0)
			return ;

		if (random(3) == 0)
			return ;

		
		if (addKPoint(avKPoints[0])) {
			progLastKPoint = sc ;
			avKPoints.shift() ;
		}
	}


	public function addKPoint(k : api.SecureInGamePrizeTokens) : Bool {

		var coord : Coord = null ;
		var debug = 100 ;
		var from = spots[random(spots.length)] ;

		var avSpots = spots.copy() ;
		avSpots.remove(from) ;

		while(coord == null && avSpots.length > 0&& debug > 0) {
			debug-- ;

			var to = avSpots[random(avSpots.length)] ;
			avSpots.remove(to) ;

			if (Game.dist(from.getCoord(), to.getCoord()) < 100)
				continue ; //spots are too close

			var points = [] ;

			var fc = from.getCoord() ;
			var tc = to.getCoord() ;

			for (i in 1...4) {
				var tp = {x : from.x + (to.x - from.x) * i / 4,
						y : from.y + (to.y - from.y) * i / 4} ;

				points.push(tp) ;

				var dPerp = Swarm.getNextPoint(fc, {x : fc.x - (tc.y - fc.y), y : fc.y + tc.x - fc.x}, 11) ;
				dPerp = {x : dPerp.x - fc.x, y : dPerp.y - fc.y} ;

				var pas = 5 ;
				var pp = {	x : tp.x - pas / 2 * dPerp.x,
						y : tp.y - pas / 2 * dPerp.y } ;

				for(j in 0...pas) {
					points.push(pp) ;

					pp.x += dPerp.x ;
					pp.y += dPerp.y ;
				}
			}

			var p = null ;
			while(points.length > 0) {
				p = points[random(points.length)] ;
				points.remove(p) ;

				var cancel = false ;

				/*for (ck in curKPoints) {
					if (Game.dist(p, {x : ck.sp.x, y : ck.sp.y}) < 30) {
						cancel = true ;
						break ;
					}
				}*/

				if (cancel) {
					p = null ;
					continue  ;
				}

				var spTest = new ark.gfx.InGamePK() ;
				spTest.scaleX = spTest.scaleY = 0.6 ;
				spTest.x = p.x ;
				spTest.y = p.y ;

				dm.add(spTest, DP_WARFIELD) ; 

				for (s in spots) {
					if (spTest.hitTestObject(s.hitBox)) {
						cancel = true ;
						break ;
					}
				}

				spTest.parent.removeChild(spTest) ;

				if (cancel) {
					p = null ;
					continue  ;
				}

				if (p != null)
					break ;
			}

			coord = p ;

		}
		
		if (coord == null) 
			return false ;

		var kp = new KPoint(k) ;
		
		curKPoints.push(kp) ;
		kp.setPos(coord) ;
		kp.pop() ;
		return true ;
	}



	public function chooseBld(idx : Int) {
		if (!Type.enumEq(step, Choice_Building))
			return ;

		hideBuildingInfo() ;

		for (i in 0...avChoices.length) {
			avChoices[i].sp.removeEvents() ;
			
			avChoices[i].sp.filters = [] ;

			if (idx != avChoices[i].idx) {
				var v = new mt.fx.Vanish(avChoices[i].sp, 10, 10, true) ;
			} else {
				var sp = avChoices[i].sp ;
				var tw = new mt.fx.Tween(sp, WIDTH / 2, sp.y, 0.05) ;
				tw.curveInOut() ;

				tw.onFinish = function() {
								start() ;
								startTransition() ;
							}

				if (progPool[idx] == null)
					progPool[idx] = 0 ;
				progPool[idx]++ ;
				curPool++ ;

				saveGameState() ;
			}
		}
	}


	public function saveGameState() {
		AKApi.saveState( { 	pool : progPool, 
							nbPool : curPool } ) ;
	}


	public function setGameState() {
		var runState = AKApi.getState() ;
		if (runState != null) {
			progPool = runState.pool.copy() ;
			curPool = runState.nbPool ;
		} else {
			progPool = [] ;
			curPool = 0 ;
		}
	}


	public function random(n) : Int {
		return seed.random(n) ;
	}


	public function updateWatch() {
		var canSee = canSeeOtherPop() ;

		for (s in spots) {
			if (s.ennemy) 
				s.showPop(canSee) ;
		}
	}



	public function hasActiveBuilding(b : Building) {
		for (s in spots) {
			if (s.isNeutral() || s.ennemy)
				continue ;
			if (s.hasBuilding(b))
				return true ;
		}
		return false ;
	}


	public function canSeeOtherPop() : Bool {
		return hasActiveBuilding(Watch) ;
	}


	public function isEnnemy(r : Race) : Bool {
		return !Type.enumEq(r, races[0]) ;
	}



	function initStage() {
		spots = new Array() ;
		swarms = new Array() ;

		var st = new Sprite() ;
		st.x = stages.length * WIDTH ;
		st.y = 0 ;

	
		mdm.add(st, MDP_STAGE) ;

		dm = new mt.DepthManager(st) ;
		stages.push({st : st, bg : null, dm : dm}) ;
	}


	function initBg(?action = true) {
		// BG
		var bg = new Sprite() ;
		var bpData = new GfxFg(0, 0) ;

		var deltaY = 43 ;
		
		stages[stages.length - 1].bg = bpData ;

		bg.addChild(new Bitmap(bpData)) ;
		bg.y = deltaY ;
		
		dm.add(bg, DP_BG) ;
		bg.cacheAsBitmap = true ;

		if (!action)
			return ;

		var bgClick = new Sprite() ;
		bgClick.graphics.beginFill(0xFFFFFF, 0.0) ;
		bgClick.graphics.drawRect(0, deltaY, WIDTH, HEIGHT - deltaY) ;
		bgClick.graphics.endFill() ;

		dm.add(bgClick, DP_BG_CLICK) ;

		bgClick.onMouseDown(callback(Game.me.spotDown, 0)) ;


	}


	function initLevel() {

		MBut.removeAllEvents() ;

		var diff = getDifficulty() ;

		//trace(diff) ;

		initStage() ;
		initBg(); 

		ia = new IA(WIDTH, diff.iaLvl[0], diff.iaLvl[1]) ;

		curKPoints = [] ;

		var xZones = [180, 260, 180] ;

		var sizeProbs = [30, 30, 25, 15] ;

		var nSpots = 12 ;

		var zones = [] ;

		var minX = 0 ;
		var maxX = 0 ;
		for (i in 0...xZones.length) {
			maxX += xZones[i] ;
			var localSpots = [] ;
			zones.push(localSpots) ;
			
			//var ns = Std.int(Math.round(nSpots * (maxX - minX) / WIDTH)) ;
			var ns = Std.int(Math.round( nSpots / xZones.length)) ;


			for (j in 0...ns) {
				var m = minX ;
				var w = maxX - minX ;

				var coord = null ;
				var count = 200 ;

				var sz = randomProbs(sizeProbs) ;
				sizeProbs[sz] = Std.int(Math.max(1, sizeProbs[sz] - 3)) ; 

				while(coord == null && count > 0) {
					count-- ;
					var c : Coord = {	x : m + random(w),
										y : MIN_Y + random(HEIGHT - MIN_Y) } ;
					
					var fail = false ;

					var iRadius = Spot.getInitRadius(sz) ;

					//BORDER X CHECK
					var rd = 10 ;
					if (i == 0) {
						if (c.x < iRadius)
							c.x = iRadius + MIN_DIST + random(rd) ;
					} else if (i == xZones.length - 1) {
						if (c.x > WIDTH - iRadius)
							c.x = WIDTH - iRadius - MIN_DIST - random(rd) ;
					}
					//BORDER Y CHECK
					if (c.y < MIN_Y + iRadius)
						c.y = MIN_Y + iRadius + random(rd) ;
					else if (c.y > HEIGHT - iRadius - 60) { //extra pixels for spot buttons
						c.y = HEIGHT - iRadius - 60 - random(rd) ;

					}


					//SPOT DIST CHECK
					for (s in spots) {
						if (dist(c, s.getCoord()) >= Spot.getMinDist(sz, s.size))
							continue ;
						fail = true ;
						break ;
					}

					if (!fail) {
						coord = c ;
						break ;
					}
				}

				if (coord != null) {
					var spot = new Spot(spots.length, sz) ;
					spot.setPos(Std.int(Math.round( coord.x )), Std.int(Math.round( coord.y ))) ;

					spots.push(spot) ;
					localSpots.push(spot) ;
				} 
			}


			minX = maxX ;
		}


		var n = diff.mPop ;
		var pops = new Array() ;
		for (i in 0...spots.length) {
			var r = 1 + ( (n <= 0) ? random(5) : ( (random(3) == 0) ? random(55) : random(30)) ) ;
			if (n > 0) 
				n -= r ;
			pops.push(r) ;
		}

		

		while (n > 0) {
			var r = 2 + random(6) ;
			n -= r ; 
			pops[random(pops.length)] += r ;

		}

		var sp = spots.copy() ;
		while (pops.length > 0) {
			var p = pops.shift() ;
			var s = sp[random(sp.length)] ;
			sp.remove(s) ;
			s.setPop(p) ;
		}


		//### BUILDINGS

		var noLevel0 = isProgression() ;
		var noBuildings = noLevel0 && curPool == 0 ;

		if (!noBuildings) {
			var tn = [1, 2, 1] ;
			for (i in 0...tn.length) {
				var n = tn[i] ;
				var debug = 50 ;
				while (n > 0 && debug > 0) {
					var spot = zones[i][random(zones[i].length)] ;
					debug-- ;

					if (!spot.isNeutral() || spot.building != null || (noLevel0 && spot.size == 0))
						continue ;

					spot.initBuilding( (isProgression()) ? TinyBox : null , true) ; 
					n-- ;
				}
			}
		}

		for (s in spots)
			s.initAnimals() ;

		//you : 
		zones[0].sort(function(a, b) { return (a.size >= b.size) ? -1 : 1 ; }) ;
		for (i in 0...zones[0].length) {
			if (zones[0][i].building != null)
				continue ;
			zones[0][i].setOwner(races[0]) ;
			zones[0][i].setPop(diff.pPop) ;
			break ;
		}

		/*for (sp in zones[0]) {
			sp.setOwner(races[0]) ;
		}

		for (sp in zones[2]) {
			sp.setOwner(races[1]) ;
		}*/


		//ennemy
		zones[2].sort(function(a, b) { return (a.size >= b.size) ? -1 : 1 ;  }) ;

		var totalSpots = diff.oppSpots ;
		var ePop = Std.int(Math.round(diff.oppPop / totalSpots)) ;

		for (j in 0...totalSpots) {
			for (i in 0...zones[2].length) {
				if (zones[2][i].building != null && totalSpots == 1)
					continue ;
				if (!zones[2][i].isNeutral())
					continue ;
				zones[2][i].setOwner(races[1]) ;
				zones[2][i].setPop(ePop) ;
				break ;
			}
		}


		if (isProgression())
			Game.me.setProgressionScore() ;
		else if (Type.enumEq(Game.me.mode, GM_LEAGUE)) {
			for (s in spots) {
				if (!s.isNeutral())
					continue ;
				s.initBonus() ;
			}
			checkEnd() ;
		}
		
	}


	public function addLeagueScore(s : Int, ?inGame = true) {

		if (inGame && hasActiveBuilding(Bonus))
			s *= 2 ;

		var sc = api.AKApi.const(s) ;
		api.AKApi.addScore(sc) ;

		
		if (avKPoints.length == 0)
			return ;		

		if (avKPoints[0].score.get() > api.AKApi.getScore())
			return ;
		if (random(3) == 0)
			return ;

		if (addKPoint(avKPoints[0]))
			avKPoints.shift() ;
	} 


	public function selectFrom(sp : Spot) {
		if (sp.isNeutral() || sp.ennemy)
			return ;

		if (selectedSpot != null) {
			selectedSpot.unselect() ;
		}

		canUnselectOnUp = null ;

		selectedSpot = sp ;
		selectedSpot.select() ;

		if (sp.canBeBuilded())
			showBuildingList(sp) ;
	}


	public function selectTo(sp : Spot) {
		if (selectedSpot == null) 
			return ;

		/*if (selectedSpot == sp) {
			forceUnselect() ;
			hideBuildingInfo() ;
			return ;
		}*/


		if (!selectedSpot.ennemy)
			sendSwarm(selectedSpot, sp) ;

		sp.unselect() ;
		forceUnselect() ;
		hideBuildingInfo() ;

	}


	public function sendSwarm(from : Spot, to : Spot) {
		var pop = from.getSendPop() ;
		if (pop == 0)
			return ;

		/*if (!to.isNeutral())
			pop = 3 ;*/

		from.addPop(-1 * pop) ;
		var swarm = new Swarm(from, to, pop) ;
	}


	public function spotDown(id : Int) {
		if (AKApi.isReplay())
			return ;

		AKApi.emitEvent( id ) ;
	}


	public function spotUp(id : Int) {
		if (AKApi.isReplay())
			return ;

		AKApi.emitEvent( 1000 + id ) ;
	}


	public function chooseBldClick(idx : Int) {
		if (AKApi.isReplay())
			return ;

		AKApi.emitEvent( idx ) ;
	}


	public function buildClick(idx : Int) {
		if (AKApi.isReplay())
			return ;

		AKApi.emitEvent( 100 + idx ) ;
	}



	function readClick(r : Int) {

		switch(step) {
			case Choice_Building : 
				chooseBld(r) ;

			case Play : 
				if (r == 0) { //unselect all
					if (selectedSpot != null) {
						forceUnselect() ;
						hideBuildingInfo() ;
					}
				} else if (r >= 1000) { //mouse up
					var spot = spots[r - 1001] ;
					if (selectedSpot != null) {
						if (selectedSpot != spot)
							selectTo(spot) ;
						else {
							if (canUnselectOnUp == selectedSpot) {
								forceUnselect() ;
								hideBuildingInfo() ;
							}
						}
					}

				} else if (r >= 100) { //construct a building 
					build(r - 100) ;
				} else { //mouse down
					var spot = spots[r - 1] ;
					if (selectedSpot != null) {
						if (selectedSpot != spot)
							selectTo(spot) ;
						else
							canUnselectOnUp = selectedSpot ;
					} else 
						selectFrom(spot) ;
					
				}

			default : //nothing to do 

		}
	}

	
	function update(draw : Bool) {
		fxm.update() ;

		switch(step) {

			case Init : 

			case Choice_Building : 

				var rid = AKApi.getEvent() ;
				if (rid != null)
					readClick(rid) ;

			case Play : 

				var rid = AKApi.getEvent() ;
				if (rid != null)
					readClick(rid) ;

				ia.update() ;

				for (s in swarms.copy())
					s.update() ;

				for (s in spots)
					s.update() ;

				if (swarms.length > 0)
					dm.ysort(DP_WARFIELD) ;

				checkEnd() ;

				if (draw) {
					DSprite.updateAll() ;
					plaguePart() ;
				}


			case Transition : 

				if (timer != null) {
					timer-- ;
					if (timer <= 0) {
						timer = null ;
						startTransition() ;
					}

				}

			case GameOver : //nothing to do 

		}
	}



	function checkEnd() {

		var count = {you : {spot : 0, swarm : 0}, opp : {spot : 0, swarm : 0} } ;

		var yourRaces = getRaces() ;

		for (s in spots) {
			if (s.isNeutral())
				continue ;

			if (Lambda.exists(yourRaces, function(x) { return Type.enumEq(x, s.owner) ; }))
				count.you.spot++ ;
			else 
				count.opp.spot++ ;
		}

		for (s in swarms) {
			if (Lambda.exists(yourRaces, function(x) { return Type.enumEq(x, s.owner) ; }))
				count.you.swarm++ ;
			else 
				count.opp.swarm++ ;
		}


		switch(Game.me.mode) {

			case GM_PROGRESSION : //all ennemy dead
				var toPossess = getDifficulty().lEnd ; 

				trace("TOPOSSESS : " + toPossess) ;

				leagueSpotInfoEnnemy._text.text = Std.string(count.opp.spot) + "/" + Std.string(toPossess[1]) ;

				leagueSpotInfo._text.text = Std.string(count.you.spot) + "/" + Std.string(toPossess[0]) ;
				if (count.you.spot > leagueLastCount)
					new mt.fx.Flash(leagueSpotInfo)  ;
				leagueLastCount = count.you.spot ;

				if (count.opp.spot >= toPossess[1] || (count.you.swarm == 0 && count.you.spot == 0)) {
					AKApi.gameOver(false) ;
					gameOver = true ;
				} else if ((count.you.spot >= toPossess[0]) || (count.opp.spot == 0 && count.opp.swarm == 0)) { //STAGE CLEAR
					AKApi.gameOver(true) ;
					gameOver = true ;
				}

				/*if (count.opp.spot == 0 && count.opp.swarm == 0) {
					AKApi.gameOver(true) ;
					gameOver = true ;
				} else if (count.you.spot == 0 && count.you.swarm == 0) {
					AKApi.gameOver(false) ;
					gameOver = true ;
				}*/

			case GM_LEAGUE : 
				var toPossess = getDifficulty().lEnd ; 

				leagueSpotInfoEnnemy._text.text = Std.string(count.opp.spot) + "/" + Std.string(toPossess[1]) ;

				leagueSpotInfo._text.text = Std.string(count.you.spot) + "/" + Std.string(toPossess[0]) ;
				if (count.you.spot > leagueLastCount)
					new mt.fx.Flash(leagueSpotInfo)  ;
				leagueLastCount = count.you.spot ;

				if (count.opp.spot >= toPossess[1] || (count.you.swarm == 0 && count.you.spot == 0)) {
					AKApi.gameOver(false) ;
					gameOver = true ;
				} else if ((count.you.spot >= toPossess[0]) || (count.opp.spot == 0 && count.opp.swarm == 0)) { //STAGE CLEAR
					gotoNextStage() ;
					
				}
		}


		if (gameOver) {
			step = GameOver ;
			forceUnselect() ;
			stopAllAnims() ;
		}
	}




	public function plaguePart() {
		var sprites = [[2], [1, 2, 4], [2, 4]] ;

		for (s in spots) {
			if (!s.hasBuilding(Plague))
				continue ;

			if (Std.random(10) > 0)
				continue ;


			var idx = Std.random(sprites.length) ;

			var sp = new Sprite() ;
			sp.graphics.beginFill(0x38e310) ;
			sp.graphics.drawRect(-2, 2, 2, 2) ;
			sp.graphics.endFill() ; 

			sp.blendMode = flash.display.BlendMode.OVERLAY ;
			

			var x = s.sp.x + (Std.random(2) * 2 - 1) * (Spot.BUILDING_RADIUS * 0.5) * Math.random() ;
			var y = s.sp.y + (Std.random(2) * 2 - 1) * (Spot.BUILDING_RADIUS* 0.5) * Math.random() ;

			var pp = new Sprite() ;
			pp.addChild(sp) ;

			pp.x = x ;
			pp.y = y ;

			dm.add(pp, DP_FX) ;

			pp.alpha = 0.8 ;

			var p = new mt.fx.Part(pp) ;
			p.vy = -0.5 ;
			p.frict = 1.02 ;

			p.fadeType = 1 ;
			p.fadeLimit = 20  ;

			//p.fadeIn(10 + Std.random(10)) ;
			p.timer = 30 + Std.random(30) ;

			new mt.fx.Flash(pp) ;


		}

	}

	public function updatePlagueFx(sp : Spot) {
		var color = 0x38e310 ;

		if (plagueSP == null) {
			var alpha = 1.0 ;		

			plagueSP = new Sprite() ;

			plagueSP.alpha = alpha ;
			Game.me.dm.add(plagueSP, Game.DP_FX) ;
			
			plagueSP.filters = [new flash.filters.GlowFilter(color , 0.20, 80, 80, 3, 3, true, true),
								new flash.filters.BlurFilter(6, 0)] ;
			plagueSP.blendMode = flash.display.BlendMode.OVERLAY ;

		}
		
		
		var circle = new Sprite() ;
		plagueSP.addChild(circle) ;
		circle.graphics.beginFill(color) ;
		circle.graphics.drawCircle(0, 0, Spot.BUILDING_RADIUS) ;
		circle.graphics.endFill() ; 
		circle.x = sp.sp.x ;
		circle.y = sp.sp.y ;


		var spawn = new mt.fx.Spawn(circle, 0.05, true, true) ; 
	 	spawn.curveInOut() ;
		/*var blob = new mt.fx.Blob(circle, 0.02, 0.05) ;
		blob.curveInOut() ;*/
		
	}



	public function updateSlowFx(sp : Spot) {
		var color = 0x6f4700 ;

		if (slowSP == null) {
			var alpha = 0.22 ;
			slowSP = new Sprite() ;
			slowSP.alpha = alpha ;
			Game.me.dm.add(slowSP, Game.DP_SLOW_FX) ;

			slowSP.filters = [new flash.filters.GlowFilter(color , 0.5, 12, 12, 5)] ;
			slowSP.blendMode = flash.display.BlendMode.DARKEN ;
		}

		
		var circle = new Sprite() ;
		slowSP.addChild(circle) ;
		circle.graphics.beginFill(color) ;
		circle.graphics.drawCircle(sp.sp.x, sp.sp.y, Spot.BUILDING_RADIUS) ;
		circle.graphics.endFill() ; 

		var spawn = new mt.fx.Spawn(circle, 0.01, true) ; 
		spawn.curveInOut() ;
	}


	function stopAllAnims() {
		for (s in spots)
			if (s.sBld != null)
				s.sBld.stopAnim(s.sBld.getFrame()) ;

		for (sw in swarms)
			sw.stopAnims() ;

	}



	function gotoNextStage() {
		setLeagueLevel(leagueLevel+1) ;

		fxm.clean() ;

		if (plagueSP != null) {
			var pv = new mt.fx.Vanish(plagueSP, 10, 10, true) ;
			plagueSP = null ;
		}
		if (slowSP != null) {
			var pv = new mt.fx.Vanish(slowSP, 10, 10, true) ;
			slowSP = null ;
		}


		addLeagueScore(LEAGUE_STAGE_POINT.get()) ;
		forceUnselect() ;
		initLevel() ;
		showVictory() ;
		step = Play ;
		//start() ;

	}


	function forceUnselect() {
		if (selectedSpot != null) {
			selectedSpot.unselect() ;
			selectedSpot = null ;
		}
	}


	function showVictory() {
		step = Transition ;

		spVict = {bg : new Sprite(),
				txt : cast new gfx.Victoire(),
				bonus :  cast new gfx.VictoireBonus()} ;


		spVict.bg.graphics.beginFill(0x000000, 0.75) ;
		spVict.bg.graphics.drawRect(0, 0, WIDTH * 2, HEIGHT) ;
		spVict.bg.graphics.endFill() ;

		spVict.bg.x = -WIDTH ;

		spVict.txt._text.text = Text.victory({ _LVL : Std.int(leagueLevel) }) ;
		spVict.bonus._text.text = "+" + Std.string(LEAGUE_STAGE_POINT.get()) + " pts" ;

		spVict.txt.x = -WIDTH + WIDTH / 2 ;
		spVict.txt.y = 220 - 300 ;

		spVict.bonus.x = -WIDTH + 30 ;
		spVict.bonus.y = 220 + 300  ;

		ia.setPause(true) ;

		var black = new mt.fx.Spawn(spVict.bg, 0.065) ;
		black.curveIn(3) ; 

		black.onFinish = callback(function(g : Game) {
							var tw = new mt.fx.Tween(g.spVict.txt, g.spVict.txt.x, 200, 0.04) ;
							tw.curveIn(4) ;
							var tw2 = new mt.fx.Tween(g.spVict.bonus, g.spVict.bonus.x, 220, 0.04) ;
							tw2.curveIn(4) ;
							
							tw.onFinish = callback(function(g2 : Game) {
								new mt.fx.Flash(g2.spVict.txt, 0.07) ;
								new mt.fx.Flash(g2.spVict.bonus, 0.07) ;
								new mt.fx.Flash(g2.spVict.bg, 0.1, null, 0.5) ;
								new mt.fx.Shake(g2.stages[0].st, 3, 3) ;

								g2.startTransition(true) ;								
							}, g) ;
						}, this) ;

		dm.add(spVict.bg, DP_FG) ;
		dm.add(spVict.txt, DP_FG) ;
		dm.add(spVict.bonus, DP_FG) ;


		for (sw in swarms.copy())
			sw.kill(true) ;
	}


	function startTransition(?fromVictory = false) {
		step = Transition ;

		if (stages.length < 2) {
			#if debug 
			trace("invalid transition") ;
			#end
			return ;
		}



		if (fromVictory) {
			timer = 40 ;
			return ;
		}


		if (spVict != null)
			var vh = new mt.fx.Vanish(spVict.bg, 20, 20, true) ;

		for (i in 0...stages.length) {
			var st = stages[i].st ;
			var tw = new mt.fx.Tween(st, st.x - WIDTH, st.y, 0.038) ;
			tw.curveIn(2) ;

			if (i == stages.length - 1)
				tw.onFinish = endTransition ;
		}
	}


	public function endTransition() {
		if (!Type.enumEq(step, Transition)) {
			trace("invalid end transition") ;
			return ;
		}


		if (spVict != null) {
			//spVict.bg.parent.removeChild(spVict.bg) ;
			spVict.txt.parent.removeChild(spVict.txt) ;
			spVict.bonus.parent.removeChild(spVict.bonus) ;

		}


		while (stages.length > 1) {
			var st = stages.shift() ;
			st.bg.dispose() ;
			st.st.parent.removeChild(st.st) ;

			for (i in 0...15)
				st.dm.clear(i) ;

			st.dm.destroy() ;
		}


		var sk = new mt.fx.Shake(stages[0].st, 3, 3) ;


		for (s in spots) {
			if (s.isNeutral())
				continue ;
			s.jumpAll() ;
		}
		

		ia.setPause(false) ;
		step = Play ;


		leagueSpotInfo.alpha = 1.0 ;
		new mt.fx.Spawn(leagueSpotInfo) ;
		leagueSpotInfoEnnemy.alpha = 1.0 ;
		new mt.fx.Spawn(leagueSpotInfoEnnemy) ;

	}


	public function showBuildingList(s : Spot) {
		if (curTip != null)
			hideBuildingInfo() ;

		curTip = new Sprite() ;
		curTip.y = 80 ;
		mdm.add(curTip, MDP_TIP) ;

		var tip = new gfx.Tooltip() ;
		curTip.addChild(tip) ;			

		var bldColl = getBldColl(false, false, buildClick) ;
		if (bldColl == null)
			return ;

		tip.addChild(bldColl.coll) ;
		bldColl.coll.x = (WIDTH - bldColl.coll.width) / 2 ;
		bldColl.coll.y = 35 ;

		var tw = new mt.fx.Tween(curTip, 0,  curTip.y - 70, 0.15) ;
		tw.curveInOut() ;

		if (bldColl.click != null) {
			curTipClick = bldColl.click ;
			dm.add(curTipClick, DP_CLICK) ;
			curTipClick.x = bldColl.coll.x ;
			curTipClick.y = curTip.y + bldColl.coll.y - 70 ;

			curTipClick.visible = false ;

			tw.onFinish = function() {if (curTipClick != null) curTipClick.visible = true ; } ;
		}
	}


	public function build(idx : Int) {
		if (progPool[idx] == null || progPool[idx] < 0)
			return ;
		if (selectedSpot == null || !selectedSpot.canBeBuilded())
			return ;

		progPool[idx]-- ;

		selectedSpot.revealBuilding( Type.createEnumIndex(Building, idx) ) ;

		forceUnselect() ;
		hideBuildingInfo() ;
	}


	public function showBuildingInfo(s : Spot, ?forceBld : Building) {
		if (curTip != null)
			hideBuildingInfo() ;

		curTip = new Sprite() ;
		curTip.y = 80 ;
		mdm.add(curTip, MDP_TIP) ;


		var b = (forceBld != null) ? forceBld : s.building ;
		
		var tip = new gfx.Tooltip() ;
		curTip.addChild(tip) ;
		var bld = tiles.getSprite("bld_" + Spot.BUILDING_INFOS[Type.enumIndex(b)].id) ;
		bld.x = 178 ;

		var bName = "" ;
		var bDesc = "" ;

		switch(b) {
			case Bunker : 
				bld.y = 7 ; 
				bName = Text.bld_Bunker_name ;
				bDesc = Text.bld_Bunker({_PC : Std.string(Spot.BUNKER_PC)}) ;
			case Watch : 
				bld.y = 17 ;
				bName = Text.bld_Watch_name ;
				bDesc = Text.bld_Watch ;
			case Fast : 
				bld.y = 13 ;
				bName = Text.bld_Fast_name ;
				bDesc = Text.bld_Fast ;
			case Rage : 
				bld.y = 13 ;
				bName = Text.bld_Rage_name ;
				bDesc = Text.bld_Rage({_PC : Std.string(Spot.RAGE_PC)}) ;
			case MoreSex : 
				bld.y = 17 ;
				bName = Text.bld_MoreSex_name ;
				bDesc = Text.bld_MoreSex ;
			case Slow : 
				bld.y = 17 ;
				bName = Text.bld_Slow_name ;
				bDesc = Text.bld_Slow ;
			case Bonus : 
				bld.y = 12 ;
				bName = Text.bld_Bonus_name ;
				bDesc = Text.bld_Bonus ;
			case Plague :
				bld.y = 7 ;
				bName = Text.bld_Plague_name ;
				bDesc = Text.bld_Plague ;

			case Box : 
				bld.y = 7 ;
				bName = "" ;
				bDesc = (isProgression()) ? Text.bld_Box_Build : Text.bld_Box_Unknown ;

			case TinyBox :
				bld.y = 12 ;
				bName = "" ;
				bDesc = (isProgression()) ? Text.bld_Box_Build : Text.bld_Box_Unknown ;
		}


		tip._text.htmlText = ( (bName == "") ? "" : ("<i>" + bName + " : </i>") ) + bDesc ;

		curTip.addChild(bld) ;


		/*if (s != null && !s.isNeutral()) {
			var art = tiles.getSprite(getSpriteName(s.owner) + "_art") ;
			curTip.addChild(art) ;
			art.y = 14 ;
			if (s.ennemy) {
				art.scaleX = -1 ;
				art.x = WIDTH - 30 - art.width / 2 ;
			} else 
				art.x = 50  ;
		}*/

		var tw = new mt.fx.Tween(curTip, 0,  curTip.y - 70, 0.15) ;
		tw.curveInOut() ;
	}


	public function hideBuildingInfo() {
		if (curTip == null)
			return ;

		var sp = curTip ;
		curTip = null ;

		if (curTipClick != null) {
			curTipClick.parent.removeChild(curTipClick) ;
			curTipClick = null ;
		}

		var tw = new mt.fx.Tween(sp, sp.x, sp.y + 100) ;
		tw.onFinish = callback(function(x : Sprite) { x.parent.removeChild(x) ; }, sp) ;
	}


	public function onWin() {
		
	}


	public function getRaces(ennemy = false) : Array<Race> {
		if (ennemy)
			return [ races[1] ] ;
		else 
			return [ races[0] ] ;
	}


	public static function getSpriteName(r : Race, ?forceDefault = false ) : String {
		return switch(r) {
				case None : 	(forceDefault) ? "none" : null ;
				case Auk : 		"auk" ;
				case Sheep : 	"sheep" ;
				case Pig : 		"pig" ;
		}
	}


	static public function dist(c0 : Coord, c1 : Coord) {
		return Math.sqrt( (c0.x - c1.x) * (c0.x - c1.x) + (c0.y - c1.y) * (c0.y - c1.y) ) ;
	}


	static public function randomProbs(t : Array<Int>) : Int {
		var n = 0 ;
		for(e in t) {
		    n += e ;
		}
		n = Game.me.random(n) ;
		var i = 0 ;
		
		while( n >= t[i]) {
			n -= t[i] ;
			i++ ;
		}
		
		return i ;
	}
	
/*
typedef Diff = {
	var iaLevel : Int ;
	var yourPop : Int ;
	var oppPop : Int ;
	var oppSpots: Int ;
}
*/


	public function getDifficulty() : Diff {

		var dfltPop = 80 ;
		var minPop = 50 ;

		switch(Game.me.mode) {
			case GM_LEAGUE :
				var lvl = leagueLevel - 1 ;
				var diff = {iaLvl : [2, 2], pPop : dfltPop, oppPop : Std.int(dfltPop - 5), oppSpots : 1, mPop : 180, lEnd : [7, 11]} ;
				
				diff.iaLvl[1] += lvl ;

				//diff.mPop = Std.int(Math.min(diff.mPop + 5 * lvl, 250)) ;

				diff.pPop = Std.int(Math.max(minPop, dfltPop - 5 * lvl)) ;

				diff.oppPop = diff.oppPop + (4 + lvl) * lvl ;
				if (lvl > 6)
					diff.oppPop = diff.oppPop + 10 * (lvl - 6) ;

				var i = leagueLevel ;
				while (diff.lEnd[0] < 12 && i > 0) {
					diff.lEnd[0]++ ;
					diff.lEnd[1]-- ;
					i-- ;
				}

				return diff ;


			case GM_PROGRESSION :
				var lvl = AKApi.getLevel() ;

				var diffs =[null,
					{iaLvl : [0, 1], pPop : 80, oppPop : 70, oppSpots : 1, mPop : 180, lEnd : [12, 12]}, //1
					{iaLvl : [0, 2], pPop : 80, oppPop : 70, oppSpots : 1, mPop : 180, lEnd : [12, 12]}, //2
					{iaLvl : [1, 1], pPop : 80, oppPop : 75, oppSpots : 1, mPop : 180, lEnd : [12, 12]}, //3
					{iaLvl : [1, 2], pPop : 80, oppPop : 80, oppSpots : 1, mPop : 180, lEnd : [12, 12]}, //4 	X
					{iaLvl : [1, 3], pPop : 80, oppPop : 80, oppSpots : 1, mPop : 180, lEnd : [12, 12]}, //5
					{iaLvl : [1, 4], pPop : 80, oppPop : 85, oppSpots : 1, mPop : 180, lEnd : [12, 12]}, //6
					{iaLvl : [2, 1], pPop : 80, oppPop : 85, oppSpots : 1, mPop : 180, lEnd : [12, 12]}, //7 	X
					{iaLvl : [2, 1], pPop : 80, oppPop : 90, oppSpots : 1, mPop : 180, lEnd : [12, 12]}, //8 	
					{iaLvl : [2, 2], pPop : 80, oppPop : 90, oppSpots : 1, mPop : 180, lEnd : [12, 12]}, //9 	X
					{iaLvl : [2, 2], pPop : 80, oppPop : 90, oppSpots : 1, mPop : 180, lEnd : [12, 12]}, //10 	X
					{iaLvl : [2, 3], pPop : 80, oppPop : 95, oppSpots : 1, mPop : 180, lEnd : [12, 12]}, //11 	
					{iaLvl : [2, 3], pPop : 80, oppPop : 95, oppSpots : 1, mPop : 180, lEnd : [12, 12]}, //12
					{iaLvl : [2, 3], pPop : 80, oppPop : 100, oppSpots : 1, mPop : 180, lEnd : [12, 12]}, //13 	X 	
					{iaLvl : [2, 4], pPop : 80, oppPop : 105, oppSpots : 1, mPop : 180, lEnd : [12, 12]}, //14	XX
					{iaLvl : [2, 4], pPop : 80, oppPop : 110, oppSpots : 1, mPop : 180, lEnd : [12, 12]}, //15 	
					{iaLvl : [2, 4], pPop : 80, oppPop : 115, oppSpots : 1, mPop : 180, lEnd : [12, 12]}, //16 X
					{iaLvl : [2, 5], pPop : 80, oppPop : 120, oppSpots : 1, mPop : 180, lEnd : [12, 12]}, //17 XXX
					{iaLvl : [2, 5], pPop : 80, oppPop : 125, oppSpots : 1, mPop : 180, lEnd : [12, 12]}, //18 X
					{iaLvl : [2, 5], pPop : 80, oppPop : 130, oppSpots : 1, mPop : 180, lEnd : [12, 12]}, //19 X	
					{iaLvl : [2, 5], pPop : 80, oppPop : 140, oppSpots : 1, mPop : 180, lEnd : [12, 12]}, //20 XX

					{iaLvl : [2, 5], pPop : 80, oppPop : 145, oppSpots : 1, mPop : 180, lEnd : [12, 11]}, //21 
					{iaLvl : [2, 5], pPop : 75, oppPop : 145, oppSpots : 1, mPop : 180, lEnd : [12, 11]}, //22 
					{iaLvl : [2, 5], pPop : 75, oppPop : 150, oppSpots : 1, mPop : 180, lEnd : [12, 11]}, //23 
					{iaLvl : [2, 5], pPop : 75, oppPop : 150, oppSpots : 1, mPop : 180, lEnd : [12, 10]}, //24 
					{iaLvl : [2, 5], pPop : 70, oppPop : 155, oppSpots : 1, mPop : 180, lEnd : [12, 10]}, //25 
					{iaLvl : [2, 5], pPop : 70, oppPop : 155, oppSpots : 1, mPop : 180, lEnd : [12, 10]}, //26 
					{iaLvl : [2, 5], pPop : 70, oppPop : 160, oppSpots : 1, mPop : 180, lEnd : [12, 9]}, //27 
					{iaLvl : [2, 5], pPop : 65, oppPop : 160, oppSpots : 1, mPop : 180, lEnd : [12, 9]}, //28 
					{iaLvl : [2, 5], pPop : 65, oppPop : 165, oppSpots : 1, mPop : 180, lEnd : [12, 9]}, //29 
					{iaLvl : [2, 5], pPop : 65, oppPop : 165, oppSpots : 1, mPop : 180, lEnd : [12, 8]}, //30 
					{iaLvl : [2, 5], pPop : 60, oppPop : 170, oppSpots : 1, mPop : 180, lEnd : [12, 8]}, //31 
					{iaLvl : [2, 5], pPop : 60, oppPop : 170, oppSpots : 1, mPop : 180, lEnd : [12, 8]}, //32 
					{iaLvl : [2, 5], pPop : 60, oppPop : 175, oppSpots : 1, mPop : 180, lEnd : [12, 8]}, //33 
					{iaLvl : [2, 5], pPop : 55, oppPop : 175, oppSpots : 1, mPop : 180, lEnd : [12, 7]}, //34 
					{iaLvl : [2, 5], pPop : 55, oppPop : 180, oppSpots : 1, mPop : 180, lEnd : [12, 7]}, //35 
					{iaLvl : [2, 5], pPop : 55, oppPop : 180, oppSpots : 1, mPop : 180, lEnd : [12, 7]}, //36 
					{iaLvl : [2, 5], pPop : 50, oppPop : 185, oppSpots : 1, mPop : 180, lEnd : [12, 6]}, //37 
					{iaLvl : [2, 5], pPop : 50, oppPop : 185, oppSpots : 1, mPop : 180, lEnd : [12, 6]}, //38 
					{iaLvl : [2, 5], pPop : 50, oppPop : 190, oppSpots : 1, mPop : 180, lEnd : [12, 6]}, //39 
					{iaLvl : [2, 5], pPop : 50, oppPop : 200, oppSpots : 1, mPop : 180, lEnd : [12, 6]}, //40 
						] ;

				var d = diffs[lvl] ;
				d.mPop = 180 ;

				return d ;

			default : return null ;
		}


	}
}












