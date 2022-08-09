import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.bumdum9.Lib;
import Protocole;

enum GameMode {
	GM_CONTROL;
	GM_REPLAY;
}

class Game {//}
	
	static public var DP_BG = 		0;
	static public var DP_CARDS =	1;
	static public var DP_INTER =	2;
	static public var DP_STAGE =	3;
	static public var DP_FX =		4;
	
	static public var FRUTIPOWER_PREVIEW = false;
	
	static public var COLOR_BG = 		0xADE76B;
	static public var COLOR_SHADE = 	0x80BC60;
	
	static public var MARGIN = 56;
	static public var TOP = 12;
	static public var BOTTOM = 4;
	
	public var id:			mt.flash.Volatile<Int>;
	public var score:		mt.flash.Volatile<Int>;
	public var frutipower:	mt.flash.Volatile<Float>;
	var frutipowerMax:		mt.flash.Volatile<Int>;
	
	var frutiRangePenalty:	mt.flash.Volatile<Int>;
	var	freqFruit:			mt.flash.Volatile<Int>;
	
	public var shield:		mt.flash.Volatile<Int>;
	public var shieldMax:	mt.flash.Volatile<Int>;
	public var shieldCoef:	mt.flash.Volatile<Float>;
	
	public var speed:		mt.flash.Volatile<Float>;
	
	public var bloodColor:Int;
	public var gore:Bool;
	public var goreSpots:Bool;
	public var frutiLock:Bool;
	
	public var demo:mt.flash.Volatile<Bool>;
	public var training:mt.flash.Volatile<Bool>;
	
	public var mode:GameMode;
	public var mtimer:mt.flash.Volatile<Int>;
	public var gtimer:mt.flash.Volatile<Int>;
	public var rgtimer:mt.flash.Volatile<Int>;
	public var recordIndex:Int;
	public var accTimer:Int;
	public var timer:mt.flash.Volatile<Int>;
	public var dynamiteCount:mt.flash.Volatile<Int>;
	
	var replaySpeed:Null<Int>;
	
	var stage:Stage;
	var freeKeys:Array<Int>;
	var hand:Array<_CardType>;
	
	public var action:Void -> Void;
	public var cards:Array<Card>;
	public var fruits:Array<Fruit>;
	public var bonus:Array<Bonus>;
	public var obstacles:Array<Obstacle>;
	public var parts:Array<Part>;
	public var effects:Array<Fx>;
	public var nextPos:Array<flash.geom.Point>;
	
	public var gameLog:_GameLog;
	public var inter:Inter;
	public var controlType:ControlType;
	
	public var seed:mt.Rand;
	public var seedNum:Int;
	public var snake:Snake;
	
	var shaker: { dx:Float, dy:Float, fr:Float };

	public var fxm:mt.fx.Manager;
	public var dm:mt.DepthManager;
	var root:flash.display.Sprite;
	public var screen:pix.Screen;
	public static var me:Game;
	
	public function new( id : Int, a:Array < _CardType > , s:Int, ?rec:haxe.io.Bytes, demo=false ) {
		
		this.demo = demo;
		training  = Lambda.has(a, TRAINING);
		me = this;
		root = new flash.display.Sprite();
		dm = new mt.DepthManager(root);
		fxm = new mt.fx.Manager();
		mt.fx.Fx.DEFAULT_MANAGER = fxm;
		this.id = id ;
		this.hand = a;
		
		seedNum = s;
		seed = new mt.Rand(s);
		mode = GM_CONTROL;
		recordIndex = 0;
		record = [];
		for( i in 0...300000 ) record.push(0);
		nextPos = [];
		//
		if ( FRUTIPOWER_PREVIEW ) BOTTOM += 10;
		// BG
		initBg();
		//root.stage.quality = flash.display.StageQuality.HIGH;

		// STAGE
		var width = Cs.mcw - MARGIN * 2;
		if( demo ) width = 198;
		stage  = new Stage( width, Cs.mch - (TOP + BOTTOM) );
		stage.setPos(MARGIN, TOP);
		stage.root.y = 1000;
		//
		if ( rec != null ) initReplay(rec);
		//
		gtimer = 0;
		rgtimer = 0;
		mtimer = 0;
		dynamiteCount = 0;

		
		gameLog = {
			fruits:[],
			bonus:[],
			rec:null,
			score:0,
			frutipowerMax:0.0,
			lengthMax:0.0,
			chrono:0.0,
		};
		
		// VARIABLES
		parts = [];
		fruits  = [];
		bonus  = [];
		obstacles  = [];
		effects  = [];
		freeKeys = Cs.DEFAULT_KEYS.copy();
		score = 0;
		frutipower = 0;
		frutipowerMax = Cs.FRUTIPOWER_MAX;
		frutiRangePenalty = Cs.FRUTIPOWER_PENALTY;
		freqFruit = Cs.FREQ_FRUIT;
	
		speed = 0;
		accTimer = 0;
		shield = 0;
		shieldCoef = 0;
		shieldMax = 3;
		frutiLock = false;

		Bonus.cloneData();
		
		initCards(a);
		initInter();
		//Keyb.TRACE = true;
		Keyb.init();
		Keyb.actions[80] = togglePause;			// P-AUSE : met le jeu en pause
		Keyb.pressCancel = togglePause;			// Escape : met le jeu en pause
		Keyb.actions[13] = togglePause;			// Enter : met le jeu en pause
		Keyb.actions[68] = toggleDebug;			// D-EBUG : affiche le panneau de debug
		if( replaySpeed != null ) {
			Keyb.actions[109] = callback(incReplaySpeed,-1);	// - : diminue la vitesse du replay
			Keyb.actions[107] = callback(incReplaySpeed, 1);		// + : augmente la vitesse du replay
		}
		#if dev
		Keyb.actions[83] = toggleReplay;		// S-AVE : sauve/arrete le replay
		#end
		
		
		// LAUNCH
		var so = flash.net.SharedObject.getLocal("snake");
	
		
		if( training ) {
			new panel.Info( Lang.TRAINING_GAME, Lang.TRAINING_INSTRUCTION, 8);
		}else if( (so.data.controlRepeat == null || so.data.controlRepeat < 8 ) && !demo && mode == GM_CONTROL ) {
			new panel.Control(initIntro);
		}else {
			initIntro();
		}
		

		// EVENTS
		flash.Lib.current.stage.addEventListener(flash.events.Event.DEACTIVATE, 	onDeactivate);
		
		// SCREEN
		var sc = 2;
		screen = new pix.Screen(root, Cs.mcw*sc, Cs.mch*sc, sc);
		Main.dm.add(screen, 1);
		screen.update();
		

	}
	

	// REPLAY
	function initReplay(rec:haxe.io.Bytes) {
		

		var a = [];
		var o = rec.getData();
		o.uncompress();
		for( i in 0...o.length ) a.push( o.readByte() );
		
		record = a;
		mode = GM_REPLAY;
		
		if( !demo ){
			var p = new pix.Sprite();
			p.setAlign(0, 0);
			stage.dm.add(p, Stage.DP_FX);
			p.setAnim(Gfx.fx.getAnim("record"));
			replaySpeed = 0;
		}
	}
	function incReplaySpeed(inc) {
		replaySpeed += inc;
		if( replaySpeed < 0 ) replaySpeed = 0;
		if( replaySpeed > 5 ) replaySpeed = 5;
	}
	
	//BG
	var bg:SP;
	function initBg() {
		bg = new flash.display.Sprite();
		dm.add(bg,DP_BG);

		// INTER
		setBgColor(Gfx.col("green_1"));
		
	
		
		
	}
	function setBgColor(col) {
		bg.graphics.clear();
		bg.graphics.beginFill(col);
		bg.graphics.drawRect(0, 0, Cs.mcw, Cs.mch);
		bg.graphics.endFill();
	}

	// PARAMS
	public function initParams() {
		var so = flash.net.SharedObject.getLocal("snake");
		setControl( Snk.getEnum( ControlType, so.data.controlType) );
		setGore(so.data.gore);
		goreSpots = true;
		bloodColor = gore?0xFF0000:0xCCFF88;
	}
	public function setControl(ct) {
			
		if( controlType != null ){
			switch(controlType) {
				case CT_MOUSE :
					flash.Lib.current.stage.removeEventListener(flash.events.MouseEvent.MOUSE_DOWN, onMouseDown);
					flash.Lib.current.stage.removeEventListener(flash.events.MouseEvent.MOUSE_UP, onMouseUp);
					//fx.MouseString.me.kill();
				default:
			}
		}
		
		controlType = ct;
		if( controlType == null) controlType = CT_STANDARD;
		switch(controlType) {
			case CT_MOUSE :
				flash.Lib.current.stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onMouseDown);
				flash.Lib.current.stage.addEventListener(flash.events.MouseEvent.MOUSE_UP, onMouseUp);
				//new fx.MouseString();
			default:
		}
		

		// PATCH TRAINING
		if( fx.Training.me != null ) fx.Training.me.update();
		
	}
	public function setGore(flag:Null<Bool>) {
		if( flag == null ) flag = true;
		gore = flag;
		
		var red:Float = 	0xFFC50202;
		var green:Float =	 0xFFCCFF88;
		var green_dark:Float = 0xFFA3F359;

		red = 4291101186;
		green = 4291624840;
		//green_dark = 4288934745;
		
		if( gore ) 		Gfx.replaceCol( Gfx.bmpFx, green, red );
		else		 	Gfx.replaceCol( Gfx.bmpFx, red, green );
	}
	
	// CARDS
	function initCards(a:Array < _CardType >) {
		cards = [];
		for ( type in a ) {
			var card = new Card(type);
			card.id = cards.length;
			var sp = card.sprite;
			//var pos = card.getGamePos();
			var pos = getCardPos(card.id);
			sp.x = pos.x;
			sp.y = pos.y;
			//sp.x = bx;
			//sp.y = my+4 + (Card.HEIGHT+3) * y;
			dm.add(sp,DP_CARDS);
			cards.push(card);
			/*
			y++;
			if( y == 3 ) {
				y = 0;
				bx = Cs.mcw - bx;
			}
			*/
			
		}
	}
	public static function getCardPos(id) {
		var ecy = 6;
		var my = Std.int((Cs.mch - (3 * Card.HEIGHT + 2 * ecy)) * 0.5);
		
		var sens = Std.int(id / 3) * 2 - 1;
		var ww = Cs.mcw * 0.5;
		
		var x = ww + (ww - (6 + Card.WIDTH * 0.5) ) * sens;
		var y = my + Card.HEIGHT * 0.5 + (id % 3) * (Card.HEIGHT + ecy);
		
		return {x:Std.int(x), y:Std.int(y) };
				
	}
	
	
		
	// INTER
	function initInter() {
		
		inter = new Inter();

		// SHIELDBARRE
		/*
		var tw = Cs.mcw - (2 * MARGIN);
		var ww = tw;
		var mma = 4;
		shieldbar = new Frutibar( Std.int(ww), 1 );
		shieldbar.x = MARGIN+ww+mma;
		shieldbar.y = 2 + Cs.mch - BOTTOM;
		incShield(0);
		*/
		
		
		
	}
	public function incScore(inc,?x,?y) {
		score += inc;
		if (score < 0) score = 0;
		
		// INTER;
		inter.majScore();
		
		// FX
		if( x != null && !Game.me.have(EGG_SHELL) )	new fx.Score(x, y, inc );
	
		
	}
	public function incFrutipower(inc) {
		if ( frutiLock ) return;
		var min = getFrutipowerMinimum();
		frutipower = Num.mm(min, frutipower + inc, frutipowerMax);
		inter.majFrutipower( frutipower / frutipowerMax );
		gameLog.frutipowerMax = Math.max(frutipower, gameLog.frutipowerMax);
	}
	public function incSpeed(inc) {
		speed = Num.mm(0, speed + inc, 10000);
		//shieldbar.set(speed / 100);
	}
	public function incShield(inc) {
		if( shield == shieldMax ) return;
		shieldCoef += inc;
		if( shieldCoef >= 1 ) {
			shieldCoef = 0;
			shield++;
		}
		inter.majShields();
	}
	public function protect() {
		
		if( shield <= 0 ) return false;
		shield--;
		inter.majShields();
		if ( have(WRENCH, true) )								incFrutipower(1 * numCard(WRENCH));
		if ( Game.me.have(MUSTARD) && have(EGG_SHELL,true))		Game.me.specialSpawn(Nut);
		
		
		return true;
		
	}
	public function getFrutipowerMinimum() {
		var min = 0;
		if ( Game.me.have(CROISSANT) ) min = 30+10*numCard(SHOOTING_STAR);
		return min;
	}
	
	// UPDATE
	public var willDraw:Bool;
	public function updateAll(e) {
		
		var loop = 1;
		if( replaySpeed != null ) loop = Std.int( Math.pow(2,replaySpeed));
		for( i in 0...loop) {
			willDraw = i == (loop - 1);
			update();
		}
		
	}
	
	public function update() {
		
		mtimer++;
		
		if( pause != null ) {
			pause.update();
			if ( screen != null ) screen.update();
			return;
		}

		if ( action != null ) action();
		
		//
		flash.Lib.current.stage.focus = flash.Lib.current.stage;
		
		// EFFECTS
		var a = effects.copy();
		for ( e in a ) e.update();
		
		// FX mt.FX
		fxm.update();
		
		// CARDS
		for ( card in cards ) card.update();
		
		// SPRITES
		var a = pix.Sprite.all.copy();
		for ( sp in a ) sp.update();
		
		// PARTS
		var a  = parts.copy();
		for ( p in a ) p.update();

		// SCREEN
		if ( screen != null && willDraw ) screen.update();

		// SHAKER
		if ( shaker != null ) updateShake();
		
		// DEMO
		if( demo ) updateDemo();
		
		
	}

	// INTRO
	var stepIntro:Int;
	public function initIntro() {
		
		action = updateIntro;
		timer = 0;
		stepIntro = 0;
		
		inter.root.y -= 15;
		//
		snake = new Snake( );
		
		
		//
		initParams();
		if( demo ) initDemo();
		
	}
	function updateIntro() {
		
		switch(stepIntro) {
			case 0 :
				timer++;
				var lim = 20;
				var cc = timer / lim;
				var c = 0.5-Snk.cos(cc * 3.14)*0.5;
				stage.root.y = TOP + 400 * (1 - cc);
				inter.root.y = -Std.int( 14 * (1-c) );
				
				if( timer == lim ) {
					timer = 0;
					stepIntro++;
				}
				
				
			
			case 1 :
				timer++;
				if ( timer > 5 ) {
					var next = true;
					for( c in cards ){
						if ( !c.active ) {
							next = false;
							c.flipIn();
							break;
						}
					}
					timer = 0;
					if ( next ) initPlay();
				}
		}

		//
	}

	// DEMO
	var promo:Promo;
	function initDemo() {
		stepIntro = 1;
		stage.root.y = TOP;
		inter.root.y = 0;
		
		// PROMO
		promo = new Promo();
		promo.x = MARGIN + 203;
		promo.y = 5;
		dm.add(promo, DP_BG);
		
		// FLASH
		var fx = new fx.Flash( stage.root, 0.1);
		fx.update();
	}
	function updateDemo() {
		promo.update();
	}
	
	// PLAY
	public var playTime:Float;
	public function initPlay() {
		playTime = Date.now().getTime();
		action = updatePlay;
		cardEvent = [];
		snake.dead = false;
		
	}
	function updatePlay() {
		

		gtimer++;
		rgtimer++;
		if( mode == GM_CONTROL ) 	control();
		if( mode == GM_REPLAY ) 	replay();
		snake.update();
		
		// INTER
		inter.updateChrono( Game.me.getTime() );
		inter.frutibar.update();
		inter.updateMouseIcon();
				
		// ACC
		if( accTimer++ == 100 ) {
			accTimer = 0;
			incSpeed(Cs.SNAKE_AUTO_ACC);
		}
		
		// FRUIT POS
		while( nextPos.length < 5 ) {
			var p = stage.getRandomPos(20, 40);
			nextPos.push(p);
		}
		
		// SPAWNER
		var max = 0;
		for( fr in fruits ) if( !fr.has(Shit) ) max++;

		if ( have(ACE_SPADES) ) max -= numBackCards();
		if ( have(SMALL_BELLS) && max <= 1 + numCard(SQUIRREL) ) max=0;
		if ( max < 0 ) max = 0;
		var rnd = max * freqFruit;
		
		if ( seed.random(rnd) == 0 )	spawnFruit();
		Bonus.trySpawn();
		
		// PHASE
		if( gtimer % 10 == 0 ) {
			incShield(0.015);
		}
		
		
		//
		
		// BAR
		
		
	}


	public function getTime() {
		return gtimer * 25;
	}
	
	public function getRandomFruitRank(?c,k=0) {
		if ( c == null ) c = seed.rand();
		if ( have(TRAINING) ) return 5;
		
		var frutiRangeMin = 0;
		if( have(PAILLASON) ) frutiRangeMin = Std.int( (frutipower/frutipowerMax) * 60);
		
		var exp = 300 / (100 + frutipower*2);
		var c = Math.pow( c, exp );
		var max = (DFruit.LIST.length-1) - (1 - frutipower / frutipowerMax) * frutiRangePenalty;
		var range = max - frutiRangeMin;
		
		var rank = frutiRangeMin + Math.round(c * range);
		
		// RARE FRUIT
		var data = Fruit.getData(rank);
		if ( Game.me.seed.random(data.freq) > 0 && k < 20 ) return getRandomFruitRank(c, k + 1);
		
		// VIRUS
		if ( fx.Virus.me != null && !fx.Virus.me.isOk(data) ) return getRandomFruitRank(null, k + 1);
		
		// IDOL
		if( Game.me.have(IDOL) && seed.random(8) == 0 ) rank = Fruit.getNearest(rank,null);
	
		// BOYCOTT
		if( Game.me.have(BOYCOTT) && rank == 0 && k<20 ) return getRandomFruitRank(null, k + 1);
		
		// ALL_GREEN
		if( Game.me.have(GREEN_HOUSE) && Game.me.have(VINE_LEAF) )  rank = Fruit.getNearest(rank,Green);
		
		// DEBUG
		if ( Cs.TEST_FRUIT.length > 0 ) return Cs.TEST_FRUIT[Game.me.seed.random(Cs.TEST_FRUIT.length)];
		if ( Cs.TEST_FRUIT_WITH != null && seed.random(3) != 0 ) rank = Fruit.getNearest(rank, Cs.TEST_FRUIT_WITH);

		
		
		
		return rank;
	}
	public function spawnFruit() {
		
		var rank = getRandomFruitRank();
		var special = false;
		
		if( Game.me.have( SURPRISE ) && seed.random(5) == 0 && gtimer > 100 ) {
			var n = Std.int(DFruit.LIST.length * 0.4);
			rank = DFruit.LIST.length - (12 + Game.me.seed.random(n));
			if ( Game.me.have(DOLPHIN) ) rank = 50 + Game.me.seed.random(100);
			
			Game.me.getCard( SURPRISE ).flip();
			special = true;
		}
		
		
		var fr = Fruit.get(rank);
		var p = nextPos.shift();
		fr.x = p.x;
		fr.y = p.y;
		fr.updatePos();
		if( special ) fr.specialSpawn();
		// FX
		/*
		var e = stage.getPart("onde");
		e.x = p.x;
		e.y = p.y;
		e.sprite.scaleX = e.sprite.scaleY = 2;
		*/

	}
	public function specialSpawn(?type) {
		var rank = getRandomFruitRank();
		if( type != null ) rank = Fruit.getNearest(rank,type);
		var fr = Fruit.get(rank);
		var p = stage.getRandomPos(20, 40);
		fr.x = p.x;
		fr.y = p.y;
		fr.updatePos();
		fr.specialSpawn();
	}
	
	
	// CONTROL
	public var record:Array<Int>;
	public var cardEvent:Array<Card>;
	public function control() {
		
		var left = false;
		var right = false;
		var thrust = false;
		
		switch(controlType) {
			case CT_STANDARD :
				left = Keyb.isLeft();
				right = Keyb.isRight();
				thrust = Keyb.isUp();
			case CT_ORTHO :
				var ta:Null<Float> = null;
				if( Keyb.isLeft() )		ta = -3.14;
				if( Keyb.isRight() )	ta = 0;
				if( Keyb.isUp() )		ta = -1.57;
				if( Keyb.isDown() )		ta = 1.57;
				if( ta != null ) {
					var da = Num.hMod(ta - snake.angle, 3.14);
					var lim = 0.05;
					if( da < -lim )	left = true;
					if( da > lim )	right = true;
				}
				if( Keyb.isAction() )	thrust = true;
				
			case CT_MOUSE :
				var turn = getMouseTurn(snake.x,snake.y,snake.angle);
				left = 	turn == -1;
				right = turn == 1;
				if( click )	thrust = true;
			
			case CT_BRAIN :
		}
		
		
		// TURN
		if ( left ) {
			snake.turn( -1);
			recInput(1);
		}else if ( right ) {
			snake.turn( 1);
			recInput(2);
		}else {
			recInput(0);
		}
		
		// SPEED
		if ( thrust ) {
			snake.thrusting = true;
			recInput(3);
		}
		Inter.me.setThrust(thrust);
		
		// ACTIONS
		for ( card in cardEvent ) {
			card.action();
			recInput(4 + card.id);
		}
		cardEvent = [];
	}
	public function recInput(n) {
		record[recordIndex] = n;
		recordIndex++;
	}

	public function getMouseTurn(x:Float,y:Float,an:Float) {
		var m = Cs.getMousePos(Stage.me.root);
		m.x += fx.Brandy.DECAL.x;
		m.y += fx.Brandy.DECAL.y;
		
		var dx = m.x - x;
		var dy = m.y - y;
		var ta = Math.atan2(dy, dx);
		var da = Num.hMod(ta - an, 3.14);
		var lim = 0.05;
		var turn = 0;
		if( da < -lim )	turn = -1;
		if( da > lim )	turn = 1;
		return turn;
	}
	public function replay() {
		

		// TURN
		var turn = record.shift();
		switch(turn) {
			case 0:
			case 1:	snake.turn( -1);
			case 2: snake.turn( 1);
			default : //trace("replay error : " + turn + " is not a valid turn command.");
		}
		
		// SPEED + ACTIONS
		while( record.length>0 ){
			var next = record[0];
			if ( next <= 2 ) break;
			record.shift();
			switch(next) {
				case 3 :					snake.thrusting = true;
				case 4, 5, 6, 7, 8, 9 :		cards[next - 4].action();
				default :
			}
		}
		
		
		
		
	}
	
	// CLICK
	public var click:Bool;
	function onMouseDown(e) {
		click = true;
	}
	function onMouseUp(e) {
		click = false;
	}
	
	// GAMEOVER
	public function stopPlay() {
		playTime = Date.now().getTime() - playTime;
		for( c in cards ) c.onDeath();
		action = null;
	}
	public function gameover() {
		Inter.me.setThrust(false);
		stopPlay();
		timer  = 0;
		action = updateGameover;
		
		// FX
		snake.fxBloodSpot(0);
		
		if( Game.me.have(ANKH, true) ) 	new fx.Ankh();
		if( Game.me.have(TRAINING) ) 	new fx.TrainingDeath();
		
	}
	function updateGameover() {
		timer++;
		snake.death();
		if ( timer >= 100  && snake.queue.length == 0) endGame();
	
	}
	public function kill() {
		pix.Sprite.all = [];
		screen.kill();
		screen = null;
		Main.game = null;
	}
		
	// EXIT
	var step:Int;
	public function exit() {
		for( c in cards ) c.onDeath();
		timer = 0;
		step = 0;
		action = updateExit;
		
	}
	function updateExit() {
		timer++;
		switch(step) {
			case 0 :
				var coef = timer / 20;
				snake.fxGlow(coef);
				if( timer == 20 ) {
					var dif = Std.int(score * 0.2);
					incScore(dif, snake.x, snake.y);
					snake.fxAllSparkDust();
					snake.kill();
					timer = 0;
					step++;
				}
			case 1:
				if( timer > 20 ) endGame();
		}
	}
	
	// ENDGAME
	var box:LoadingBox;
	var checkTimer:haxe.Timer;
	public function endGame() {
		while( effects.length > 0 ) effects.pop().kill();
		cleanStage();
		
		gameLog.score = score;
		
		// RECORD
		record = record.slice(0, recordIndex);
		var o = new flash.utils.ByteArray();
		for(n in record ) o.writeByte(n);
		o.compress();
		gameLog.rec = haxe.io.Bytes.ofData(o);

		//
		action = updateEndGame;
		step = 0;
		timer = 0;
		
		// MOUSE
		flash.ui.Mouse.show();
		
		// DEBUG RECORD
		#if dev
		if( saveReplayToSharedObject ){
			var so = flash.net.SharedObject.getLocal("snake_replay");
			var o:_DataReplay = { _rec:gameLog.rec, _id:id, _sid:seedNum, _hand:hand, _player:{_name:"bumdum",_avatar:"hale.gif",_id:0,_rank:11}, _score:score, _dateString:"23/03/78" }
			var str = haxe.Serializer.run( o );
			so.data.str = str;
			so.flush();
			return;
			/*
			* var save = function(e) { flash.system.System.setClipboard(str); trace("copy dataReplay !");	};
			var but = new But("sauver", save);
			dm.add(but, 10);
			but.x = Cs.mcw * 0.5;
			but.y = Cs.mch * 0.5;
			*/
			
		}
		#end
		//
		
	

		
		if( demo ) {
			step = 10;
		}

	}
	public function updateEndGame() {
		timer++;
		switch(step) {
			case 0:
				var lim = 50;
				var c = timer / lim;
								
				Col.setPercentColor(Stage.me.root, c, Gfx.col("green_1"));
				inter.root.y -= Std.int(c * 16);
				
				for( card in cards ) {
					
					var mal = card.id * 0.1;
					var cc = Num.mm(0, (c-mal)/(1-mal) , 1);
					
					var sens = Std.int(card.id / 3) * 2 - 1;
					var sp = card.sprite;
					sp.x += Std.int(cc * 16)*sens;
					
				}
				
				if( timer == lim ) {
					step++;
					timer = 0;
					box = Cs.getLoadingBox();
					dm.add(box.base, 3);
					sendInfos(box.n);
					stage.kill();
					
					checkTimer = new haxe.Timer(Data.CNX_RETRY_TIME);
					checkTimer.run = checkSend;
					
					//haxe.Timer.delay( function() { me.debriefing( { _progression:a } ); }, 6000 );
				}
			case 1:
			
			case 10: // DEMO
			
				var lim = 30;
				var cid = Std.int(timer / 5);
				if( cid < cards.length ) {
					var card = cards[cid];
					if( card.active ) card.flipOut();
				}
				if( timer == lim ) {
					
					timer = 0;
					step++;
				}
			case 11 :
				Col.setColor( stage.root, 0, timer * 30 );
				if( timer > 10 ) {
					Main.emptyPools();
					Main.launchDemo();
				}
				
				
		}
	}
	public function sendInfos(tr) {
		
		var data:_GEndSend = {
			_id: id,
			_score:score,
			_fruits:gameLog.fruits,
			_record:gameLog.rec,
			_tr:tr,
			_pt:playTime,
			_tra:(rgtimer*Data.MS_PER_FRAME )/playTime,
		}
		//trace(gameLog.rec.length+"<---->"+gtimer );
		//trace( Std.int((gameLog.rec.length * Data.MS_PER_FRAME) / 1000 ) );
		//trace( "playtime:" + Std.int(playTime / 1000 ) );
		//trace( "playTime:" + playTime );
		//trace( "timeRatio:" + data._tra );
		//trace( "gtimer:" + Std.int(gtimer * Data.MS_PER_FRAME / 1000 ) );
		//trace( "rgtimer:" + Std.int(rgtimer * Data.MS_PER_FRAME / 1000 ) );
				
		// TOTEST
		switch(mode) {
			
			case GM_CONTROL :
				#if dev
					var me = this;
					var a = [];
					var max = 1 + Std.random(10);
					for( i in 0...max ) a.push({_id:Std.random(160),_lvl:Std.random(5)+1});
					haxe.Timer.delay( function() { me.debriefing( { _progression:a, _err:0 } ); }, 1000 );
				#else
					Codec.displayError = function(e) {} ;
					Codec.load(Main.domain + "/end", data, debriefing) ;
				#end
			case GM_REPLAY :
				debriefing( { _progression:[], _err :0 } );
				
		}
	}
	
	public function checkSend() {
		if( box == null ) return;
		
		box.n++;
		var text = Lang.CNX_TRY+" " + box.n + " / " + Data.CNX_RETRY_MAX;
		if( box.n > Data.CNX_RETRY_MAX ) {
			text = Lang.CNX_IMPOSSIBLE;
		}else {
			sendInfos(box.n);
		}
		var f = box.field;
		f.text = text;
		f.width = f.textWidth + 3;
		f.x = -Std.int(f.width * 0.5);
		
	}
	
	// CARD EFFECS
	public function toggleFrutiLock() {
		frutiLock = !frutiLock;
		inter.frutibar.filters = [];
		Filt.grey(inter.frutibar,frutiLock?1:0);
		inter.frutibar.blendMode = frutiLock?flash.display.BlendMode.OVERLAY:flash.display.BlendMode.NORMAL;
	}

	// DEBRIEFING
	inline function debugDebriefing() {
		box = Cs.getLoadingBox();
		inter.root.visible = false;
		for( c in cards ) c.sprite.visible = false;
		
		gameLog.score = Std.random(3500) * 10;
		gameLog.lengthMax = Math.random() * 300;
		gameLog.frutipowerMax = Math.random() * 100;
		gameLog.chrono = Math.random() * 180000;
		
		var max = Std.random(7);
		for( i in 0...max ) {
			var bon:BonusType = Cs.getEnum(BonusType, Std.random(10));
			gameLog.bonus.push( bon );
		}
		
		var a = [];
		var max = 1 + Std.random(12);
		for( i in 0...max ) a.push({_id:Std.random(160),_lvl:Std.random(5)+1});
		
		debriefing( { _progression:a, _err :0 } );
	}
	public function debriefing(data:_GEndReceive) {
		if(box != null ) {
			box.base.parent.removeChild(box.base);
			box = null;
		}
		if( checkTimer != null ) checkTimer.stop();
		
		var a  = [];
		var max = 3;
		
		var color = Gfx.col("green_1");
		
		// EASTER EGGS - MENU + COLORS
		var seed = new mt.Rand(0);
		seed.initSeed(getHandId());
		var menu = null;
		if( seed.random(128) == 0 ) {
			menu = [];
			var max = 1 + seed.random(6);
			for( i in 0...max ) menu.push( seed.random(DFruit.MAX) );
		}
		if( seed.random(128) == 0 ) {
			color = Col.getRainbow2(seed.rand());
			color = Col.brighten(color, 160-seed.random(320));
		}
		
		
		setBgColor(color);
		for( i in 0...max ){
			var ff = new FruitFaller(Cs.mcw, Cs.mch);
			ff.menu = menu;
			dm.add(ff, 1);
			a.push(ff);
			var c = i / (max);
			Col.setPercentColor( ff, (1 - c) * 0.75, color );
		}
		
		var str = null;
		if( demo ) {
			var dataReplay : _DataReplay = { _rec:gameLog.rec, _id:id, _sid:seedNum, _hand:hand, _player:{_name:"bumdum",_avatar:"hale.gif",_id:0,_rank:11},_score:score, _dateString:"23/03/78" };
			str = haxe.Serializer.run( dataReplay );
		}
		var deb = new Debriefing(data, gameLog, str);
		
		action = function() {
			deb.update();
			for( ff in a ) ff.update();
			
		};
		
	}
	
	// CLEAN STAGE
	function cleanStage() {
		var a = fruits.copy();
		for( f in a ) f.vanish();
		var a = bonus.copy();
		for( b in a )b.vanish();
	}
	
	// CARDS
	public function have(cardType, show = false, readyOnly = false ) {
		var ok = false;
		for ( c in cards ) if ( c.type == cardType ) {
			if( c.active ){
				if( !readyOnly || c.cooldown == 0  ) {
					ok = true;
					if( show ) 	c.fxUse();
				}
			}
		}
		return ok;
	}
	public function haveMany(a:Array<_CardType>) {
		for( ct in a ) if( !have(ct) ) return false;
		return true;
	}
	public function numCard(cardType) {
		var n = 0;
		for ( c in cards ) if ( c.type == cardType && c.active ) n++;
		return n;
	}
	public function getCard(cardType, checkCooldown=false ) {
		for ( c in cards ) if ( c.type == cardType && c.active && (c.cooldown == 0 || !checkCooldown )   ) return c;
		return null;
	}
	public function getHandId() {
		var n = 0;
		for( c in cards ) n += Type.enumIndex(c.type);
		return n;
	}
	public function numBackCards() {
		var n = 0;
		for ( c in cards ) if ( !c.active ) n++;
		return n;
	}
	
	// CONTROL
	public function getFreeKey() {
		return freeKeys.shift();
	}
	
	// OBSTACLE
	public function addObstacle(x,y,ray,?f) {
		var obs = { x:x, y:y, ray:ray, collide:f };
		obstacles.push(obs);
		return obs;
	}
	public function removeObstacle(obs) {
		obstacles.remove(obs);
	}
	
	// PAUSE
	public var pause:panel.Pause;
	public function togglePause() {
		#if !dev
		if( Main.bdata == null || Main.bdata._draft != null ) return;
		#end
		if( (action != updatePlay || demo ) && pause == null ) return;
		if( pause == null ) {
			pause = new panel.Pause();
			return;
		}
		pause.fadeOut();
	}
	function onDeactivate(e) {
		if(pause==null 	&& !demo && replaySpeed == null)togglePause();
	}
	
	// FX
	public function shake(dx, dy, fr = 0.5) {
		shaker = { dx:dx,dy:dy, fr:fr };
	}
	public function updateShake() {
		if ( mtimer % 2 == 0 ) return;
		screen.x = shaker.dx;
		screen.y = shaker.dy;
		shaker.dx *= -shaker.fr;
		shaker.dy *= -shaker.fr;
		if ( Math.abs(shaker.dx) + Math.abs(shaker.dy) < 1 ) {
			shaker = null;
			screen.x = screen.y = 0;
		}
	}
	
	// DEBUG
	var deb:panel.Debug;
	function toggleDebug() {
		if( !Keyb.isShift() ) return;
		if( deb == null ) {
			deb = new panel.Debug();
			return;
		}
		deb.kill();
		deb = null;
	}
	
	// SHOW
	public function showPlayer(data:_DataPlayer,score:Int,date:String) {
		//trace(data);
		if( date == null) date = "???";
		var sp = new SP();
		var hh = 31;
		
		// AVATAR
		var av = new Avatar(hh,data._avatar);
		sp.addChild(av);
		
		// NAME
		var fn = Cs.getField(0xFFFFFF,8,-1,"nokia");
		fn.alpha = 0.8;
		fn.text = data._name;
		fn.width = fn.textWidth + 3;
		fn.y = -1;
		sp.addChild(fn);
		
		// SCORE
		var f = Cs.getField(0xFFFFFF, 8, -1, "nokia");
		f.text = Std.string(score);
		f.width = f.textWidth + 3;
		f.y = 10;
		sp.addChild(f);
		f.filters =  [new flash.filters.GlowFilter(0, 0.4, 2, 2, 1)];
		
		// DATE
		var fd = Cs.getField(0xFFFFFF, 8, -1);
		fd.text = date;
		fd.width = fd.textWidth + 3;
		fd.y = 21;
		sp.addChild(fd);
		fd.filters =  [new flash.filters.GlowFilter(0, 0.4, 2, 2, 1)];
		
		// BG
		var ma = 2;
		var line = 11;
		var ww = hh + Math.max(Math.max(fn.width, f.width), fd.width );
		sp.graphics.beginFill(Gfx.col("green_0"));
		sp.graphics.drawRect(0, 0, ww, hh);
		sp.graphics.beginFill(Gfx.col("red_0"));
		sp.graphics.drawRect(0, 0, ww, line);
		sp.graphics.beginFill(Col.brighten(Gfx.col("green_0"),-20));
		sp.graphics.drawRect(0, 22, ww, 9);
		
		sp.x = Cs.mcw - ww - ma;
		sp.y = Cs.mch - hh - ma;
		dm.add(sp, DP_STAGE );
		Filt.glow(sp, 2, 40, 0xFFFFFF);
		
		// FIEL POS
		fn.x = hh + Std.int( ((ww - hh) - fn.width) * 0.5 );
		fd.x = hh + Std.int( ((ww - hh) - fd.width) * 0.5 );
		f.x = hh + Std.int( ((ww - hh) - f.width) * 0.5 );
		
		//
		
		
		
	}
	

	
	
	// TEST
	#if dev
	var saveReplayToSharedObject:Null<Bool>;
	function toggleReplay() {
		var so = flash.net.SharedObject.getLocal("snake_replay");
		switch(mode) {
			case GM_CONTROL :
				saveReplayToSharedObject = true;
				
			case GM_REPLAY :
				so.data.str = null;
				so.flush();
				Main.launchGame(0, Cs.START_CARDS, Std.random(999));
	
		}
	}
	public function testFruitSpawn() {
		var max = 22;
		for ( i in 0...max) {
			var c = i / max;
			trace( (Std.int(c * 100) / 100) + " : " + getRandomFruitRank(c) );
		}
	}
	
	var frutipowerPreview:Array<pix.Element>;
	public function majFrutipowerPreview() {
		if (  frutipowerPreview == null )  frutipowerPreview = [];
		while (frutipowerPreview.length > 0) frutipowerPreview.pop().kill();
		
		var ec = 16;
		var max = Std.int((Cs.mcw-MARGIN*2)/ec);
		for ( i in 0...max ) {
			var e = new pix.Element();
			var rank = getRandomFruitRank(i / (max - 1));
			//var data = Fruit.getData(rank);
			var id = Fruit.getId(rank);
			e.drawFrame( Gfx.fruits.get(id));
			root.addChild(e);
			e.x = MARGIN + (i + 0.5) * ec;
			e.y = Cs.mch - ec * 0.5;
			frutipowerPreview.push(e);
		}
	}
	
	
	public function logNew() {
		//return;
		haxe.Log.clear();
		trace("");
		trace("");
		trace("        Part.POOL --> "+Part.POOL.length);
		trace("        Fruit.POOL --> "+Fruit.POOL.length);
		trace("        part.Line.POOL --> " + part.Line.POOL.length);
		/*
		trace("");
		trace("        fxm.length "+fxm.fxs.length);
		trace("        effects --> "+effects.length);
		trace("        fruits --> "+fruits.length);
		trace("        bonus --> "+bonus.length);
		*/
	}
	
	
	
	#end

	
//{
}


// TODO :
// GFX = pxx sur les fruitfall;
// Gerer les enum dans data.ods;








