import Protocole;
import mt.bumdum9.Lib;
import mt.bumdum9.Rush;
import mt.deepnight.Interface;
using mt.bumdum9.MBut;

enum GameStep {
	GS_PLAY(step:RoundStep);
}
enum RoundStep {
	RS_INIT;

	RS_TURN;
	RS_HERO_UPKEEP;

	RS_MONSTER_TURN;
	RS_MONSTER_UPKEEP;

	RS_END;
}


class Game extends SP {//}

	public static var DP_HINTS = 		10;

	public static var DP_FX = 			8;

	public static var DP_BOARDS = 		7;
	public static var DP_FRONT = 		6;
	public static var DP_INTER = 		5;

	public static var DP_ELEMENTS = 	2;
	public static var DP_BG = 			1;
	public static var DP_UNDER = 		0;

	var scene:Scene;
	
	public var refillCount:Int;
	public var side:Int;
	public var xpsum:Int;
	public var gtimer:Int;
	public var active:Bool;
	public var waitRefill:Bool;

	public var heroes:Array<Hero>;
	public var monster:Monster;
	public var opponents:Array<MonsterType>;

	public var core:ac.Action;
	public var uc:ac.struct.UserChoice;

	public var help:inter.HelpBox;
	public var info:TF;

	public var fxm:mt.fx.Manager;
	public var dm:mt.DepthManager;
	public static var me:Game;
	public var seed:mt.Rand;
	public var onFinish:GameClose-> Void;
	public var ballStats:Array<{n:mt.flash.Volatile<Int>}>;

	public var fgs:Array<Ui>;
	public var ambient:AmbiLight;
	public var opp:fx.OppQueue;

	public function new(idata:GameInit) {
		this.opponents = idata.opponents;
		super();
		me = this;
		active = false;
		waitRefill = false;
		haxe.Log.setColor(0xFFFFFF);

		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, update);
		seed = new mt.Rand(42);
		seed = new mt.Rand(Std.random(48000));
		fxm = new mt.fx.Manager();
		mt.fx.Fx.DEFAULT_MANAGER = fxm;
		dm = new mt.DepthManager(this);

		gtimer = 0;
		xpsum = 0;
		refillCount = 0;
		core = new ac.Action();
		
		ballStats = [];


		// BG
		var bg = new SP();
		bg.mouseEnabled = false;
		dm.add(bg, DP_BG);
		var gfx  = bg.graphics;
		gfx.beginFill(0x442200);
		gfx.drawRect(0, 0, Cs.mcw, Cs.mch);

		// HELP
		help = new inter.HelpBox(this);
		help.x = Cs.mcw + 2;
		help.y = Scene.HEIGHT + 2;
		help.toggle();
		flash.Lib.current.addChild(help);

		// AMBIENT
		ambient = new AmbiLight();
		ambient.y = Scene.HEIGHT;
		ambient.height = Cs.mch - Scene.HEIGHT;
		ambient.mouseEnabled = ambient.mouseChildren = false;
		dm.add( ambient, DP_BG );
		//ambient.blendMode = flash.display.BlendMode.OVERLAY;

		// FG
		fgs  = [];
		for ( i in 0...2 ){
			var fg = new Ui();
			fg._infoBox.x = (Cs.mcw >> 1) + 160;
			fg._timeline.x = (Cs.mcw >> 1);
			fg.mouseEnabled = fg.mouseChildren = false;
			dm.add( fg, DP_INTER );
			fgs.push(fg);
			if ( i == 1 ) {
				fg.filters = [ new flash.filters.GlowFilter(0, 1, 7, 7, 1.5, 1, false, true)];
				fg.blendMode = flash.display.BlendMode.OVERLAY;
				fg.alpha = 0.6;
			}
		}
		
		/*

		*/

		// BOARD / SCENE
		scene = new Scene(idata.loc);
		scene.mask = scene.getMask();
		dm.add(scene, DP_ELEMENTS);
		dm.add(scene.mask, DP_ELEMENTS);

		// OPP QUEUE
		opp = new fx.OppQueue(idata.opponents);
		
		// INFO
		info = Cs.getField();
		dm.add(info, DP_INTER);
		info.y = Scene.HEIGHT;
		info.width = 110;
		info.x = Cs.mcw-info.width;
		info.blendMode = flash.display.BlendMode.OVERLAY;

		// ENTS
		this.heroes = [];
		for ( gh in idata.heroes ) 	addHero( gh );
		if ( groupHave(LEATHER_ARMORS) ) for( h in this.heroes ) h.incArmor(1);

		var dec = 150;
		for ( h in this.heroes ) h.folk.x -= dec -= 50;


		//
		initInter();
		majPanels();


		// START
		var next = new ac.NextMonster(true);
		core.add(next);
		next.onFinish = callback(start, idata);
		

		
		

	}
	function start(idata:GameInit) {
		
		if( idata.tuto ){
			var tuto = new ac.Tuto();
			tuto.onFinish = initRound;
			core.add( tuto );
		}else {
			initRound();
		}
	}
	
	function initRound() {
		var round = new ac.struct.Round();
		round.onFinish = initRound;
		core.add( round );
	}


	function update(e) {
		gtimer++;
		fxm.update();
		core.update();

		for ( h in heroes ) h.board.update();
		if ( monster != null ) monster.update();
		
		//trace(gtimer);
		mt.player.Clip.doAnimate();
		mt.player.Clip.doSync();
	}

	function addHero(gh:HeroGhost) {

		var hero = new Hero(this, gh);
		heroes.push(hero);

	}

	public function nextMonster(first = false) {
		
		monster = new Monster(this, opponents.shift());
		majPanels();
		side = 1;
		new fx.MoveAll(this);
		info.text = "monstre restant(s): " + opponents.length;

		// AMBUSH
		if ( first && Game.me.groupHave(AMBUSH) ) {
			//trace("!!");
			monster.firstChain.unshift(AC_FREEZE);
		}
		monster.majInter();
		
		




	}


	// PANEL
	public function majPanels(tween=false) {



		// BOARD
		var my = Scene.HEIGHT;
		var tot = Cs.mcw;
		var ma = 12;
		for ( h in heroes ) tot -= h.board.getWidth();
		tot -= (heroes.length-1)* ma;
		var x = tot >> 1;
		var ym = 0;


		var a = [];
		for ( h in heroes ) {
			//h.board.x = x;
			a.push(x);

			var hh = h.board.ymax * Ball.SIZE;
			var y = my+ ((Cs.mch - (my + hh+13 )) >> 1) + hh ;
			if ( y > ym ) ym = y;
			x += h.board.getWidth()+ma;// + ma;
		}



		for ( h in heroes ) {
			var bx = a.shift();
			var by = ym - h.board.ymax * Ball.SIZE;
			if( tween ){
				var move = new mt.fx.Tween(h.board, bx, by );
				move.curveInOut();
			}else {
				h.board.x = bx;
				h.board.y = by;
			}
		}

	}


	//
	public function getActiveEnts() {
		var ents:Array<Ent> = [];
		if ( side == 0 ) for ( h in heroes ) ents.push(h);
		else ents.push(monster);
		return ents;
	}


	// INTERFACE
	public function activate(uc) {
		this.uc = uc;
		active = true;
		if ( heroes.length == 0 ) throw("arrgh");
		for ( h in heroes ) {
			h.board.activate();
			h.board.inter.maj();
		}





	}
	public function deactivate() {
		active = false;
		for ( h in heroes ) {
			h.board.deactivate();
			h.board.inter.maj();
		}

	}

	function initInter() {
		
		
		if ( !Main.ADMIN ) return;
		
		#if dev
		
		// Abandon
		var a = [Main.refill, scene.nextWorld, scene.nextBg, scene.nextMood, scene.nextLight, scene.nextSeed, scene.randomize ];

		for ( id in 0...a.length ) {
			var but = new EL();
			but.goto(id == 6 ? 0 :id,"text_buts",0,0);
			dm.add(but, DP_INTER);
			but.x = Cs.mcw - (but.width + 2)*(id+1);
			but.y = Cs.mch - (but.height + 2);
			but.makeBut(a[id]);
		}
	
		#end

	}

	//
	public function getFirst() {
		return heroes[heroes.length - 1];
	}

	// END
	public function end(victory) {
		Main.log(victory?"VICTORY":"GAMEOVER");
		if( onFinish != null)	{
			var st = [];
			for ( h in heroes ) {
				var o =  { _id : h.ghost.id, _s : [], _g : h.board.balls.length };
				for ( b in h.board.balls ) {
					//b.unfreeze();
					if ( b.data.skill )
						o._s.push(b.data.id);
				}
				st.push(o);
			}
			
			var val:Array<Null<Int>> = [];
			for ( o in ballStats ) {
				if ( o == null )	val.push(null);
				else 				val.push(o.n);
			}
			
			onFinish({_w:victory,_st:st,_val:val, _rf:refillCount});
		}
	}
	public function kill() {
		parent.removeChild(this);
		help.parent.removeChild(help);
		if ( mask != null ) mask.parent.removeChild(mask);
		flash.Lib.current.removeEventListener(flash.events.Event.ENTER_FRAME, update);
	}

	//
	public function groupHave(sk) {
		for ( h in heroes ) if ( h.have(sk) ) return true;
		return false;
	}
	public function groupHaveBall(bt) {
		for ( h in heroes )
			if ( h.haveBall(bt ) )
				return true;
		return false;
	}
	
	// FX
	public function getPart(mc:SP) {
		var p = new mt.fx.Part(mc);
		dm.add(p.root, DP_FX);
		return p;
	}

	// MASK
	public function initMask() {
		var msk = new SP();
		msk.graphics.beginFill(0xFF0000);
		msk.graphics.drawRect(0, 0, Cs.mcw, Cs.mch );
		flash.Lib.current.addChild(msk);
		mask = msk;

	}

	// EXTERNAL TIPS
	public dynamic function showExternalTips(str) {

	}
	public dynamic function hideExternalTips() {

	}
	public dynamic function majRunes(id:Int, balls:Int, max:Int) {
		try {
			flash.external.ExternalInterface.call("od.updateLife", id, balls, max);
		} catch( e : Dynamic ) {
		}
	}
	
	// MAKE HINT
	public function makeHint(mc:SP, hint:String) {
		#if dev
		Main.path = "../../../www";
		mt.bumdum9.Hint.me.addItem(mc, hint);
		#else
		mc.makeBut(null, function() showExternalTips(hint), function() hideExternalTips() );
		#end

	}

	// ALIEN INTERVENTION
	public function isRefillable() {
		if( waitRefill ) return false;
		// one hero with <50% grid
		for( h in heroes ) {
			var gr = Gameplay.getGridSize(h.ghost);
			if( h.board.balls.length / (gr.height * gr.width) <= 0.5 )
				return true;
		}
		return false;
	}

	
	
	// CLB
	public static function paint(mc:MC, type:BallType) {
		Ball.draw(mc, type, 0);
	}
	
	
	
//{
}

typedef Arrow = SP;
















