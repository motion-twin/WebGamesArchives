
import flash.display.StageQuality;
import mt.bumdum9.Lib;
import mt.bumdum9.CpuPro;
import Protocol;
import api.AKApi;
import api.AKProtocol;
import TitleLogo;
import mt.kiroukou.math.MLib;

import fx.UpgradeScreen.UpgradeMode;
typedef BounceFamily = { type:BadType, members:Array<Bad>, index:Int };

class BmpGfx extends BMD { }

/**
 * ARENA SHOOTER
 */

@:build(mt.kiroukou.macros.IntInliner.create([
	DP_BG,
	DP_SHADE,
	DP_UFX,
	DP_SPLINTERS,
	DP_BADS,
	DP_PLASMA,
	DP_SHOTS,
	DP_HERO,
	DP_FX,
	DP_BORDER,
	DP_SCORE,
	DP_TOP
])) class Game extends SP {

	public static var DIR = [[1, 0], [0, 1], [ -1, 0], [0, -1]];
	
	inline public static var WIDTH 			= 600;
	inline public static var HEIGHT 		= 460;
	
	inline public static var BORDER_X 		= 12;
	inline public static var BORDER_Y 		= 6;
	public static var FILTER_MAIN 			= [new flash.filters.GlowFilter(0,1,2,2,4)];
	
	public var dm:mt.DepthManager;
	public var fxm:mt.fx.Manager;
	public var seed:mt.Rand;
	
	public var bg:SP;
	public var border:gfx.Foreground;
	public var gfx:mt.pix.Store;
	
	public var step:Int;
	public var timer:Int;
	var badTimer:Int;
	var badCount:Int;

	public var stykades:Stykades;
	public var shadeLayer:SP;
	public var slime:fx.Slime;
	public var runState:RunState;
	public var plasma:BMD;
	
	public var hero:Hero;
	public var bads:Array<Bad>;
	public var shots:Array<Shot>;
	public var bounceFamilies:Array<BounceFamily>;
	public var bulletField:fx.BulletField;
	public var needRedraw(default, null):Bool;
	
	public static var me:Game;
	
	public var lowQuality : Bool;
	
	public function new() {
		super();
		me = this;
		#if sound
		Sfx.init();
		#end
		var raw = haxe.Resource.getString(AKApi.getLang());
		if( raw == null ) raw = haxe.Resource.getString("en");
		Texts.init( raw );
		#if dev
		mt.deepnight.Lib.redirectTracesToConsole('pulsar');
		#end
		//
		initGfx();
		initStatics();
		seed = new mt.Rand(AKApi.getSeed());
		//
		fxm = new mt.fx.Manager();
		dm = new mt.DepthManager(this);
		initBg();
		//
		switch(AKApi.getGameMode()) {
			case GM_PROGRESSION :
				if( AKApi.getLevel() == 1 ) {
					runState = { upgrades:[] };
					#if dev
					for( upg in Cs.TEST_UPGRADES )
						runState.upgrades.push(upg);
					#end
					initPlay();
				} else {
					runState = AKApi.getState();
					
					trace("RunState : " + runState);
					/*  MODE MISSION ? */
					/* Sélectionne en random des upgrades ET les afficher au joueur en début de partie */
					if( runState == null ) {
						runState = { upgrades:[] };
						initUpgradeScreen(UpgradeMode.UM_Auto);
					} else {
						initUpgradeScreen(UpgradeMode.UM_Choice);
					}
				}
			case GM_LEAGUE :
				runState = { upgrades:[] };
				initPlay();
			default:
				throw "unknown mode " + AKApi.getGameMode();
		}
		bulletField = new fx.BulletField();
		//
		if( AKApi.isLowQuality() ) setLowQuality();
	}
	
	function initStatics() {
		fx.Spawn.ALL = [];
		mt.fx.Fx.DEFAULT_MANAGER = null;
	}
	
	// GFX
	function initGfx() {
		gfx = new mt.pix.Store( new BmpGfx(0, 0) );
		gfx.makeTransp(0xFFFFFFFF);
		gfx.addIndex("hero");
		gfx.slice(0, 0, 16, 16);
		
		gfx.addIndex("shot");
		gfx.slice(32, 0, 8, 8, 2);
		gfx.addIndex("cross");
		gfx.slice(88, 16, 8, 8, 2);
		gfx.addIndex("border_impact");
		gfx.slice(32, 8, 8, 8, 4);
		gfx.addAnim("border_impact", [0, 1, 2, 3], [2]);
		
		gfx.addIndex("circ");
		gfx.slice(0, 16, 8, 8, 11);
		gfx.addAnim("circ", [0, 1, 2, 3, 4, 5], [1]);
		
		gfx.addIndex("score");
		gfx.slice(0, 24, 16, 8, 12);
		gfx.addIndex("powerup");
		gfx.slice(88, 8, 8, 8, 8);
		gfx.addIndex("num");
		gfx.slice(120, 0, 4, 5);
		gfx.slice(124, 0, 2, 5);
		gfx.slice(126, 0, 4, 5, 8);
		
		// MONSTER
		gfx.addIndex("bad");
		gfx.slice(16, 0, 16, 16);
		gfx.slice(64, 0, 16, 16);
		gfx.slice(80, 0, 8, 8);
		
		gfx.addIndex("diagon_point");
		gfx.slice(104, 16, 8, 8, 4);
		gfx.addAnim("diagon_point", [0, 1, 2, 3], [2, 2, 2, 12]);
		
		gfx.addIndex("diagon");
		gfx.slice(0, 32, 16, 16, 3);
		gfx.addAnim("diagon", [1, 2, 1, 0], [4, 16, 4, 1]);
		
		gfx.addIndex("diagon_egg");
		gfx.slice(0, 48, 16, 16, 3);
		gfx.addAnim("diagon_egg", [0, 1, 2, 1], [16, 2, 4, 2]);
		
		gfx.addIndex("gyro");
		gfx.slice(48, 48, 16, 16, 3);
		gfx.slice(0, 64, 16, 16, 8, 2);
		gfx.addAnim("gyro_open", [1, 2], [2]);
		
		gfx.addIndex("chaser");
		gfx.slice(96, 48, 16, 16, 2);
		
		gfx.addIndex("lord");
		gfx.slice(0, 160, 48, 48, 3, 6);
		gfx.addAnim("lord", [0, 1, 2, 1, 0, 3, 4, 5, 3], [16, 2, 4, 2, 16, 2, 2, 2, 2 ]); //42
		gfx.addAnim("lord_open", [6, 7, 8, 9, 10], [2,2,2,2,10]);
		gfx.addAnim("lord_close", [11, 12, 13, 14, 15, 0], [18, 2]);
		
		gfx.addIndex("raptor");
		gfx.slice(0, 448, 32, 32, 4, 2);
		
		gfx.addIndex("tank");
		gfx.slice(0, 512, 16, 16,4);
		gfx.addAnim("tank_fire", [1,2,3,0], [2]);
		
		gfx.addIndex("shield");
		gfx.slice(160, 160, 32, 32, 4, 2);
		
		gfx.addIndex("spawn");
		gfx.slice(48, 32, 16, 16, 4);
		gfx.addAnim("spawn", [0, 1, 2, 3, 2, 1], [2]);
		
		gfx.addIndex("hero2");
		gfx.slice(0, 96, 32, 32, 4, 2);
		
		gfx.addIndex("dalle");
		gfx.slice(128, 32, 32, 32, 8, 5);
		
		gfx.addIndex("arena_border_x");
		gfx.slice(128, 64, 12, 32, 6);
		gfx.addIndex("arena_border_y");
		gfx.slice(128, 96, 32, 6, 2, 4);
		
		gfx.addIndex("slot_upgrade");
		gfx.slice(208, 64, 80, 48);
		
		gfx.addIndex("volt_a");
		gfx.slice(128, 128, 16, 16, 9);
		gfx.addAnim("volt_a", [0, 1, 2, 3, 4, 5, 6, 7, 8], [2]);
		
		gfx.addIndex("volt_b");
		gfx.slice(128, 144, 16, 16, 6);
		gfx.addAnim("volt_b", [0, 1, 2, 3, 4, 5], [2]);
		
		gfx.addIndex("follower_ribs");
		gfx.slice(144, 160, 8, 8, 2,2);
		
		gfx.addIndex("follower_part");
		gfx.slice(80, 8, 1, 1, 4);
		gfx.addAnim("follower_part", [0, 1, 2, 3], [8, 4, 3, 2]);
		
		gfx.addIndex("shot_dead");
		gfx.slice(104, 0, 3, 3, 3, 2);
		gfx.addAnim("shot_dead", [0, 1, 2, 3, 4, 5 ], [12, 6, 3, 2, 2, 14]);
		gfx.addAnim("shot_dead_2", [1, 2, 3, 4, 5 ], [4, 3, 2, 2, 2]);
		
		EL.DEFAULT_STORE = gfx;
	}

	// INIT
	function initBg() {
		bg = new SP();
		dm.add(bg, DP_BG);
		var mc = new gfx.Background();
		mc.cacheAsBitmap = true;
		bg.addChild(mc);
		//
		plasma = new BMD(WIDTH, HEIGHT, true, 0);
		var base = new BMP(plasma);
		dm.add(base, DP_PLASMA);
		//
		border = new gfx.Foreground();
		border.mouseChildren = border.mouseEnabled = false;
		border.stop();
		dm.add(border, Game.DP_BORDER);
	}

	public function initPlay() {
		// BG
		slime = new fx.Slime();
		shadeLayer = new SP();
		shadeLayer.alpha = 0.5;
		dm.add(shadeLayer, DP_SHADE);
		// HERO
		hero = new Hero();
		bads = [];
		shots = [];
		bounceFamilies = [];
		//
		step = 1;
		badCount = 3;
		// ON START
		if( have(ELECTRIC_WALLS) ) new fx.ElectricWall();
		//
		initPlayScreen();
	}
	
	public function initUpgradeScreen(mode) {
		new fx.UpgradeScreen(mode);
		step = 1;
	}
	
	public function initPlayScreen() {
		new fx.FinalScreen(35, Texts.start_1, Texts.start_2).onFinish = function() {
			step = 0;
			timer = 0;
			badTimer = 0;
			mouseData = { x:0, y:0, move:99.9 };
			//
			new seq.PKPop();
			switch( AKApi.getGameMode() ) {
				case GM_PROGRESSION :
					stykades = new stykades.Run();
				case GM_LEAGUE :
					stykades = new stykades.Score();
				default :
			}
		}
	}
	
	function setLowQuality()
	{
		this.lowQuality = true;
		if( dm != null ) dm.clear( DP_SHADE );
		if( this.shadeLayer != null && this.shadeLayer.parent != null ) this.shadeLayer.parent.removeChild( this.shadeLayer );
		if( this.stage != null ) this.stage.quality = StageQuality.LOW;
	}
	
	// UPGRADE
	public function update(doRender = false) {
		if( AKApi.getPerf() < 0.8 ) {
			setLowQuality();	// on le force pour nettoyer		
		}
		//
		needRedraw = doRender;
		if( needRedraw )
			updatePlasma();
		
		switch(step) {
			case 0: // PLAY
				for( sh in shots.copy() ) 	sh.update();
				for( b in bads.copy() ) 	b.update();
				recalBads();
				fx.Spawn.recal();
				hero.update();
				timer ++;
			case 1: // FREEZE
				
			case 2: // NORMAL
				for( sh in shots.copy() ) 	sh.update();
				for( b in bads.copy() ) 	b.update();
				recalBads();
		}
		if( needRedraw )
			EL.updateAnims();
		
		fxm.update();
	}
	
	function updatePlasma() {
		var ct = new CT(1,1,1,1,-8,-16,-32,-2);
		plasma.colorTransform(plasma.rect, ct);
		var bl = new flash.filters.BlurFilter(4, 4);
		plasma.applyFilter(plasma, plasma.rect, new PT(0, 0), bl);
		
		var base = plasma.clone();
		var zoom = 1.00;
		plasma.fillRect(plasma.rect, 0);
		var m = new MX();
		m.scale(zoom, zoom);
		m.translate(-WIDTH*(zoom-1)*0.5, -HEIGHT*(zoom-1)*0.5);
		plasma.draw(base, m);
	}
	
	var mouseData: { x:Int, y:Int, move:Float };
	
	public function getMousePos(compress:Int=1) {
		var mx = Num.mm(0, mouseX, WIDTH-1);
		var my = Num.mm(0, mouseY, HEIGHT-1);
		var mx = Std.int(mx/compress);
		var my = Std.int(my/compress);
		var d = Std.int(HEIGHT/compress);
		var k = mx * d + my;
		k = AKApi.getCustomValue(k);
		
		return {
			x : Std.int(k / d)*compress,
			y : (k%d)*compress,
		}
	}
	
	public function genBads() {
		badTimer --;
		if( bads.length == 0 ) badTimer -= 5;
		
		if( badTimer < 0 ) {
			badTimer = 200;
			badCount++;
			var max = badCount + seed.random(3);
			var point = getRandomPointFarFromHero(120);
			for(i in 0...max) {
				var b = Bad.getRandom();
				b.x = point.x+Game.me.seed.rand();
				b.y = point.y+Game.me.seed.rand();
			}
		}
	}
	
	public function getRandomPointFarFromHero(lim) {
		var mx = BORDER_X + 8;
		var my = BORDER_Y + 8;
		var p = {
			x:mx+seed.random(WIDTH-mx*2),
			y:my+seed.random(HEIGHT-my*2),
		}
		if ( MLib.fabs(p.x - hero.x) < lim && MLib.fabs(p.y - hero.y) < lim ) return getRandomPointFarFromHero(lim);
		return p;
		
	}

	public function setFx(anim:String, x, y, ?dp) {
		if (dp == null ) dp = Game.DP_FX;
		var el = new EL();
		dm.add(el, dp);
		el.x = x;
		el.y = y;
		el.play(anim);
		el.anim.onFinish = el.kill;
		el.anim.loop = false;
		return el;
	}
	
	// HAVE
	public function have(upg) {
		if( runState == null ) return false;
		for( u in runState.upgrades )
			if( upg == u )
				return true;
		return false;
	}
	
	// TOOLS
	public function getBadList(type) {
		var a = [];
		for( b in bads )
			if( b.badType == type )
				a.push(b);
		return a;
	}
	
	public function getRandomBorderPos(){
		var ww = WIDTH - BORDER_X * 2;
		var hh = HEIGHT - BORDER_Y * 2;
		var tot = ww * 2 + hh * 2;
		var di = seed.random(4);
		if( di % 2 == 0 ) 	return { di:di, n:seed.random(hh)*1.0 };
		else 				return { di:di, n:seed.random(ww)*1.0 };
	}
	
	public function borderToPos(di, n:Float, ma=0) {
		var nn = Std.int(n);
		var mx = BORDER_X + ma;
		var my = BORDER_Y + ma;
		
		return switch(di) {
			case 0 : { x:mx, y:HEIGHT - (nn + my) };
			case 1 : { x:mx + nn, y:my };
			case 2 : { x:WIDTH - mx, y:my + nn };
			case 3 : { x:WIDTH - (nn + mx), y:HEIGHT - my };
		}
	}
	
	
	// BOUNCE FAMILIY
	function getFamily(type:BadType) {
		for( fam in bounceFamilies )
			if( fam.type == type )
				return fam;
		
		var fam:BounceFamily = { type:type, members:[], index:0 };
		bounceFamilies.push(fam);
		return fam;
	}
	
	public function addFamilyMember(b:Bad) {
		var fam = getFamily(b.badType);
		fam.members.push(b);
	}
	
	public function removeFamilyMember(b:Bad) {
		var fam = getFamily(b.badType);
		fam.members.remove(b);
	}
	
	public function recalBads() {
		for( fam in bounceFamilies ) {
			if( fam == null ) continue;
			var flength = fam.members.length;
			var max = 40;
			if( flength < max ) max = flength;
			for( i in 0...max ) {
				fam.index = (fam.index + i) % flength;
				var a = fam.members[fam.index];
				for( k in 0...flength ) {
					var b = fam.members[k];
					if( b == a || b.badType != a.badType ) continue;
					var dx = a.x - b.x;
					var dy = a.y - b.y;
					var lim = b.ray + a.ray;
					if( MLib.fabs(dx) < lim && MLib.fabs(dy) < lim ){
						var dist = Math.sqrt(dx * dx + dy * dy);
						var dif = lim - dist;
						if ( dif > 0 ) {
							if ( dif > 2 ) dif = 2;
							var an = Math.atan2(dy, dx);
							dx = Math.cos(an) * dif * 0.5;
							dy = Math.sin(an) * dif * 0.5;
							a.x += dx;
							a.y += dy;
							b.x -= dx;
							b.y -= dy;
							a.bump++;
							b.bump++;
							a.updatePos();
							b.updatePos();
						}
					}
				}
			}
		}
	}

	public function gameOver() {
		if( step != 0 ) return;
		step = 1;
		stykades.kill();
		//
		new seq.GameOver();
	}
	
	public function devMorphGfx() {
		var dir = [[1, 0], [0, 1], [ -1, 0], [0, -1]];
		var x = seed.random(gfx.texture.width);
		var y = seed.random(gfx.texture.height);
		var d = dir[seed.random(4)];
		var nx = x + d[0];
		var ny = y + d[1];
		gfx.texture.setPixel32(x,y, gfx.texture.getPixel32(nx,ny));
	}
}
