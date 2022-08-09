package ;
import mt.bumdum9.Lib;
import flash.Lib;
import Manager;
import Bubble;
import Diver;
import BonusManager;
import Background;

enum GameStep {
	GAME;
	NEWLEVEL;
}
enum Size {
	LITTLE;
	MEDIUM;
	BIG;
}

typedef MC = flash.display.MovieClip
typedef TF = flash.text.TextField;


typedef Bonus = {
	mc		: McBonus,
	rayon	: Float,
	dx		: Float,
	dy		: Float,
	type	: TypeBonus,
}

class Game {//}

	public static var mcw =300;
	public static var mch = 300;
	public static var GRAVITY = 0.1;
	public static var FROTTEMENT = 0.96;
	public static var SPEED = 0.18;
	public static var TIME = 1350;			// temps/lvl alloué
	public static var SEUIL_LVL = 270;		// seuil a partir duquel les bulles arretent de pop
	
	public var step		: GameStep;
	
	public static var me: Game;
	public var dm		: mt.DepthManager;
	public var root		: flash.display.MovieClip;
	var bg				: Background;
	
	public var player 	: Diver;
	var bonus			: Array<Bonus>;
	public var bub  	: Array<Bubble>;
	var scroller 		: Float;
	public var level 	: Int;
	var palierMax		: Float;
	public var speed 	: Float;
	
	var sablier			: MC;
	public var timer	: Int;
	var cdPop			: Float;
	var bm				: BonusManager;
	var moreBub			: Int;
	var cdBub			: Int;
	public var cdBonus	: Int;
	
	
	
	public function new(mc:flash.display.MovieClip) {
		level = 0;
		
		me = this;
		
		bonus = new Array();
		bub = new Array();
		mt.flash.Key.init();
		
		root = mc;
		root.graphics.beginFill(0xFFF8DC);
		root.graphics.drawRect(0, 0, 300, 300);
		dm = new mt.DepthManager(root);
		
		player = new Diver();
		initTimer();
		bg = new Background();
		dm.add(bg, 0);
		
		makeBubble(10);
		initGame();
	}
	
	// A TOUTES LES FRAMES
	public function update() {
		
		switch(step) {
			case GAME 		: updateGame();
			case NEWLEVEL 	: updateLevel();
		}
		
		var a = mt.bumdum9.Sprite.spriteList.copy();
		for( sp in a ) sp.update();
	}
	
	// GAME
	public function initGame() {
		cdPop = 0;
		scroller = 0;
		cdBub = 15;
		moreBub = cdBub;
		timer = TIME - 100*level;
		bm = new BonusManager();
		speed = SPEED;
		level ++;
		palierMax = 1;
		player.dy = 0;
		step = GAME;
	}
	
	public function updateGame() {
		pourBen();
		bm.updateBonus();
		updateScore();
		updateTimer();
		player.update();
		popBubble();
		popBonus();
		player.dy -= GRAVITY;
		moveIA();
		testCollapse();
	}
	
	//LEVEL
	public function updateLevel() {
		if (player.mc.y <= mch + player.coteY + 10 && scroller == 0) {
			player.mc.y += 0.5;
			player.mc.rotation *= 0.9;
			popBubble();
			moveIA();
		}
		else if (scroller < 30) {
			if (scroller == 0) {
				makeV2(10 + Std.random(Std.int(5 + level)));
				resetDiver();
			}
			bg.scroll(10);
			player.mc.y -= 10.5;
			moveIA(10);
			scroller += 1;
		}
		if (scroller >= 30)
		{
			if (player.mc.y > mch){
				updateTimer();
				KKApi.addScore(  KKApi.const( 100) );
			}
			popBubble();
			moveIA();
			if (player.mc.y > player.coteY / 2) {
				initGame();
			}
		}
	}
	
	public function pourBen() {
		
		if (mt.flash.Key.isDown(96))
			makeBonus(TypeBonus.BUMP);
		if (mt.flash.Key.isDown(97))
			makeBonus(TypeBonus.PACMAN);
		if (mt.flash.Key.isDown(98))
			makeBonus(TypeBonus.BOMB);
		if (mt.flash.Key.isDown(99))
			makeBonus(TypeBonus.ACC);
		if (mt.flash.Key.isDown(100))
			makeBonus(TypeBonus.TIME);
		if (mt.flash.Key.isDown(101))
			makeBonus(TypeBonus.STOP_SPAWN);
	}
		
	
	//SCORING
	public inline function updateScore() {
		var newPos = player.mc.y;
		if (newPos > palierMax) {
			if (Std.int(newPos / 10) > Std.int(palierMax / 10) ) {
				KKApi.addScore(  KKApi.const( 100) );
			}
			palierMax = newPos;
		}
	}
	
	//TIMER
	public inline function updateTimer() {
		timer --;
		sablier.scaleY = timer / TIME;
		if (timer <= 0) {
			timer = 0;
			KKApi.gameOver( { } );
		}
	}
	
	//MOUVEMENT DES BULLES - PIEUVRES
	private inline function moveIA(?nbPx) {
		if (nbPx != null){
			for (b in bub)	b.mc.y -= nbPx;
			for (b in bonus)b.mc.y -= nbPx;
		}
		else{
		var a = bub.copy();
		for ( b in a ) {
			b.incre();
			b.mc.x = b.x + Math.sin(b.d) * b.range;
			b.mc.y += b.dy;
			if (b.mc.y < -(b.diam/2)){
				b.kill();
			}
		}
		var p = bonus.copy();
		for ( b in p ) {
			b.dx += Std.random(50)/100;
			b.mc.x += Math.sin(b.dx);
			b.mc.y += b.dy;
			if (b.mc.y < -20){
				b.mc.parent.removeChild(b.mc);
				bonus.remove(b);
			}
		}
		}
	}
	
	//GENERATEUR DE BULLES
	private inline function popBubble() {
		(moreBub > 0)?moreBub --:moreBub = cdBub;
		if (moreBub == 0 && bm.cdSpawn == 0 && player.mc.y <= SEUIL_LVL) {			//cd doit etre a 0, pas de bonus freeze activé player en dessous du seuil max
			makeBubble();
		}
		setCdBub();
	}
	
	//GERE LA DIFFICULTEE DU POP
	private function setCdBub() {
		cdBub = 20 - (level*2);
	}
	
	
	//GENERATEUR DE PIEUVRES
	private inline function popBonus() {
		var rand = Std.random(300);
		if(rand == 0 ) {
			makeBonus();
		}
	}
	
	//CREATION DES BONUS
	private function makeBonus(?tb:TypeBonus) {
		if(cdBonus == 0){
			if (tb == null)tb = bm.getBonus();
			var mc = new McBonus();
			dm.add(mc, 10);
			var b : Bonus = {
				mc 		: mc,
				rayon 	: 15.0,
				dx		: 1.0,
				dy		: -(Math.random() * 2 +1),
				type	: tb,
			}
			
			mc.gotoAndStop(Type.enumIndex(b.type)+1);
			b.mc.x = Std.random(mcw-10);
			b.mc.y = mch+b.rayon;
			bonus.push(b);
			
			//
			cdBonus = 20;
			//
		}
	}
	
	//CREATION DES BULLES
	private function makeBubble(?nb:Int) {
		if (nb == null)
			nb = 1;
		for(i in 0...nb){
			cdPop ++;
			var t = [LITTLE, LITTLE, LITTLE, LITTLE, LITTLE,
					MEDIUM, MEDIUM,
					BIG];
			var b = new Bubble(t[Std.random(t.length)]);
			if (cdPop == 4) {
				var r = Std.random(16) - 30;
				b.mc.x = player.mc.x + r;
				b.x = b.mc.x;
				cdPop = 0;
			}
			else{
				b.mc.x = Std.random(mcw - 10);
				b.x = b.mc.x;
			}
		
			if (nb != 1) {
				b.mc.y = (mch*0.6)+(Std.random(Std.int(mch/2)));
			}
			else
				b.mc.y = mch + (b.diam / 2);
		}
	}
	
	//NETOYAGE DES ARRAYS
	public function cleanBub() {
		while (bub.length > 0) bub.pop().burst();
		bub = new Array();
		for (i in 0...bonus.length) {
			bonus[i].mc.parent.removeChild(bonus[i].mc);
			bonus[i] = null;
		}
		bonus = new Array();
	}
	
	//MOTEUR DE COLLISIONS
	private function testCollapse() {
		var a = bub.copy();
		if(bm.invul == 0){
			for (b in a) {
				var lx 	= Math.pow((b.mc.x - player.mc.x),2);
				var ly	= Math.pow((b.mc.y - player.mc.y), 2);
				var d 	= Math.pow(player.coteX / 2 + b.diam / 2, 2);
				if ( lx + ly <= d) {
					if (Math.sqrt(lx) + Math.sqrt(ly) <= Math.sqrt(d)) {
						if(! b.pacmanable){
							var angle = Math.atan2(player.mc.y - b.mc.y, player.mc.x - b.mc.x);
							player.dy += -(Math.abs(Math.sin(angle) * b.rebond)) ;
							player.dx += Math.cos(angle) * b.rebond ;
							player.hit(b);
						}
						if (b.pacmanable)	
							KKApi.addScore(KKApi.const(50));
						b.burst();
					}
				}
			}
		}
	
		var c = bonus.copy();
		for (b in c) {
			var lx 	= Math.pow((b.mc.x - player.mc.x),2);
			var ly	= Math.pow((b.mc.y - player.mc.y),2);
			var d 	= Math.pow(player.coteX/2   + b.rayon, 2);
			if ( lx + ly <= d) {
				if (Math.sqrt(lx) + Math.sqrt(ly) <= Math.sqrt(d)) {
					bm.useBonus(b.type, b.mc.x, b.mc.y);
					b.mc.parent.removeChild(b.mc);
					bonus.remove(b);
				}
			}
		}
	}
	
	private function initTimer() {
		sablier = dm.empty(0);
		dm.add(sablier, 20);
		sablier.graphics.beginFill(0xFF0000);
		sablier.graphics.drawRect(0, 0, 10, TIME / 20);
		sablier.graphics.endFill();
		sablier.x = 10;
		sablier.y = 10;
	}

	
	
	private function makeV2(nb) {
		for(i in 0...nb){
			cdPop ++;
			var t = [LITTLE, LITTLE, LITTLE, LITTLE, LITTLE,
					MEDIUM, MEDIUM,
					BIG];
			var b = new Bubble(t[Std.random(t.length)]);
			if (cdPop == 4) {
				var r = Std.random(16) - 30;
				b.mc.x = player.mc.x + r;
				b.x = b.mc.x;
				cdPop = 0;
			}
			else{
				b.mc.x = Std.random(mcw - 10);
				b.x = b.mc.x;
			}
			b.mc.y = ((mch * 0.6) + (Std.random(Std.int(mch / 2))))+300;
		}
	}
	
	private function resetDiver() {
		var x = player.mc.x;
		var y = player.mc.y;
		player.mc.parent.removeChild(player.mc);
		player = new Diver();
		player.mc.x = x;
		player.mc.y = y;
	}
	
	
	
	// NE PAS TOUCHER
	static function main() { }
	
//{
}