import Protocole;
import mt.bumdum9.Lib;

typedef DataBonus= { id:BonusType, weight:Int };


class Bonus extends Part
{//}
	static public var POOL:Array<Bonus>  = [];

	public static var boxes:Array < flash.geom.Rectangle> = [];
	public var type:BonusType;
	public var box:flash.geom.Rectangle;
	

	public function new(t) {
		super();
		backPool = Bonus.POOL;
		initBonus(t);
	}
	public function initBonus(t) {
		
		type = t;
		timer = 500;
		Game.me.bonus.push(this);
		
		timer = Cs.BONUS_TIMER;
		weight = 0.6;
		frictBounceZ = 0.5;
		
		// CARDS
		if( (type == BONUS_DYNAMITE || type == BONUS_MATCHES) && Game.me.have(BUCKET, true) ) timer = 50 ;
		
		//
		var gid = Type.enumIndex(t);
		sprite.drawFrame( Gfx.bonus.get(gid) );
		Stage.me.dm.add(sprite, Stage.DP_FRUITS);
		dropShade(true);
		//
		setBox();
	}
	static public function get(t) {
		if( Bonus.POOL.length == 0 ) return new Bonus(t);
		var p = Bonus.POOL.pop();
		p.init();
		p.initBonus(t);
		return p;
	}
	
	override function update() {
		
		if ( timer < 80 ) 	blink(2);
		super.update();
	}
	
	override function updatePos() {
		super.updatePos();
		sprite.pxx();
	}

	
	public function vanish() {
		
		kill();
	}
	override function timeUp() {
		if( Game.me.have(KLEENEX, true) ) Game.me.incScore(3500, x, y);
		super.timeUp();
	}
	override function kill() {
		super.kill();
		Game.me.bonus.remove(this);
		
	}
	
	// USE
	public function trig() {
		
		
		
		Game.me.gameLog.bonus.push(type);
		var sn = Game.me.snake;
		var seed = Game.me.seed;
		
		switch(type) {
			case BONUS_DYNAMITE :
				Game.me.dynamiteCount++;
				var n = 6 * Game.me.dynamiteCount;
				if ( Game.me.have(ZIPPO, true) ) n *= 2;
				sn.explode(n);
			
			case BONUS_SCISSOR :
				sn.cut( Std.int(sn.length * 0.1), true, true);
				
			case BONUS_CHEST :
				var max = 8;
				var speed = 5;
				if( Game.me.have(LASSO, true) ) speed = 1;
				for( i in 0...max) {
					var a = i / max * 6.28;
					var fr = Fruit.get( Game.me.getRandomFruitRank() );
					fr.x = x;
					fr.y = y;
					fr.z = -(fr.box.height*0.5+1);
					fr.timer *= 2;
					fr.launch( a, seed.rand() * speed, -(0.5 + seed.rand() * 3) );
				}
			
			case BONUS_FLUTE :
				new fx.FruitPath(x,y,sn.angle, Game.me.getRandomFruitRank() );
				
			case BONUS_GUITAR :
				var rank = Game.me.getRandomFruitRank();
				for( i in 0...4 ) new fx.FruitPath(x,y, (i/4)*6.28 + 0.77, rank );
			
			case BONUS_TRUMPET :
				var rank = Game.me.getRandomFruitRank();
				for( i in 0...4 ) new fx.FruitPath(x,y, (i/3)*1.57+ sn.angle - 0.77, rank );
			
			case BONUS_RING :
				var max = 8;
				var ray = 30;
				
				var rank = 0;
				var fr = sn.getNearestFruit();
				if( fr != null ) rank = fr.data.rank;
				for( i in 0...max ) {
					var a = i / max * 6.28;
					var nx = x + Snk.cos(a) * ray;
					var ny = y + Snk.sin(a) * ray;
					if( !Stage.me.isIn(nx, ny, 10) ) continue;
					var fr = Fruit.get( rank );
					fr.x = nx;
					fr.y = ny;
					fr.specialSpawn();
					fr.setSleep(i);
					fr.updatePos();
				}
			
			case BONUS_PILLULE :
				Game.me.incScore(3000, x, y - 14);
				if ( Game.me.have(ECSTASY, true) ) Game.me.incFrutipower(8);
				new fx.Pillule();
			
			case BONUS_MOLECULE :
				Game.me.incFrutipower(6);
			
			case BONUS_BIG_MOLECULE :
				Game.me.incFrutipower(18);
				
			case BONUS_ROD :
				var fr = Fruit.get();
				var p = Stage.me.getRandomPos(30, 60);
				fr.setScale(3);
				fr.x = p.x;
				fr.y = p.y;
				fr.launch(0, 0, 0);
				fr.z = -70;
				fr.scoreCoef *= 10;
				fr.calCoef *= 10;
				
				var fx = new fx.Sparkling(fr.sprite, 60, 2 );
				fx.ray = fr.getRay();
				
			case BONUS_CARD :
				if( Game.me.cards.length > 0 ){
					var card = Game.me.cards[seed.random(Game.me.cards.length)];
					card.flip();
				}
			case BONUS_SHIELD_BLUE :
				Game.me.incScore( Game.me.shield * 4000, x , y );
			
			case BONUS_MATCHES :	new fx.Matches();
			case BONUS_GRAIN :		new fx.Grain(x, y);
			case BONUS_BELL :		new fx.Bell();
			case BONUS_SHIELD :		new fx.ShieldBoost(1);
			case BONUS_VIET:		new fx.DrainFrutipower(2);
			
			case BONUS_AMULET_RED :		new fx.ExploSpawnFruit(x, y, Red, 10 );
			case BONUS_AMULET_GREEN :	new fx.ExploSpawnFruit(x, y, Green, 10 );
			case BONUS_AMULET_BLUE :	new fx.ExploSpawnFruit(x, y, Blue, 10 );
			
			case BONUS_GETA :
				
			
		}
		
		
		// ON BONUS TRIG
		if ( Game.me.have(BRAKE, true) ) new fx.Brake();
		if ( Game.me.have(MAGIC_POWDER) && Game.me.have(DETONATOR) ) new fx.MagicPowder(6);
		
		
		//
		kill();
		
	}
	
	// COLLISION
	public function hitTest2(rect:flash.geom.Rectangle,rz=0.0) {
		var r = box.clone();
		r.offset(x, y);
		return r.intersects(rect);
	}
	public function setBox() {
		var gid = Type.enumIndex(type);
		if( boxes[gid] != null ) {
			box = boxes[gid];
		}else{
			var bmp = new flash.display.BitmapData(32,32, true, 0);
			var fr = Gfx.bonus.get(gid);
			fr.drawAt(bmp, 0, 0);
			box = bmp.getColorBoundsRect(0xFFFFFFFF, 0, false);
			box.offset( -16, -16);
			boxes[gid] = box;
		}
		box = box.clone();
	}
	
	//
	override function checkBorderBounce() {
		var ray = 12;
		if ( x < ray|| x > Stage.me.width - ray ) {
			vx *= -frictBounceZ;
			x = Num.mm( ray, x, Stage.me.width - ray);
		}
		if ( y < ray || y > Stage.me.height - ray ) {
			vy *= -frictBounceZ;
			y = Num.mm( ray, y, Stage.me.height - ray);
		}
	}
	
	// GENERATION
	static public function cloneData() {
		data = [];
		for( o in DATA ) data.push( { id:o.id, weight:o.weight } );
	}
	static public function trySpawn() {
		
		var n = 10;
		if( Game.me.gtimer % n > 0 || Game.me.have(TRAINING) ) return;

		#if dev
		if( Game.me.bonus.length == 0 && Cs.TEST_BONUS.length > 0 ) {
			var t = Cs.TEST_BONUS[0];
			if( Cs.TEST_BONUS.length > 1 ) Cs.TEST_BONUS.shift();
			spawn(t);
			return;
		}
		#end
		

		
		var nothing = Cs.FREQ_BONUS * 1.0;
		
		if( Game.me.have( WINDMILL_SMALL ) ) 	nothing *= 0.9;
		if( Game.me.have( WINDMILL_BIG ) ) 		nothing *= 0.6;
		//trace( "tirage " + (Std.int((sum/(sum+nothing)) * 1000)/10) + " %");
		
		spawnRandom(Std.int(nothing));
		//spawnRandom();
	}
	static public function spawnRandom(nothing = 0) {
		var sum = nothing;
		for( o in data ) sum += o.weight;
	
		var rnd = Game.me.seed.random(sum);
		sum = 0;
		for( o in data ) {
			sum += o.weight;
			if( sum > rnd ) {
				spawn(o.id);
				break;
			}
		}
	}
	
	static public function spawn(t) {
		if( t == BONUS_SCISSOR || t == BONUS_FLUTE || t == BONUS_GUITAR || t == BONUS_TRUMPET ) {
			if( Game.me.have(BAT,true) ) return null;
		}
		var b = new Bonus(t);
		var p = Stage.me.getRandomPos(20, 40);
		b.x = p.x;
		b.y = p.y;
		return b;
	}
	
	static public function incWeight(type, inc) {
		
		for( o in data ) {
			if( o.id == type ) {
				o.weight += inc;
				return;
			}
		}
	}
	
	static var data:Array<DataBonus>;
	static public var DATA:Array<DataBonus> = [
		{ id:BONUS_DYNAMITE, 		weight:24 },
		{ id:BONUS_SCISSOR, 		weight:24 },
		{ id:BONUS_CHEST, 			weight:12 },
		{ id:BONUS_FLUTE, 			weight:6 },
		{ id:BONUS_GUITAR, 			weight:4 },
		{ id:BONUS_TRUMPET, 		weight:2 },
		{ id:BONUS_RING, 			weight:6 },
		{ id:BONUS_PILLULE, 		weight:10 },
		{ id:BONUS_MOLECULE, 		weight:8 },
		{ id:BONUS_BIG_MOLECULE, 	weight:1 },
		{ id:BONUS_ROD, 			weight:1 },
		{ id:BONUS_MATCHES, 		weight:6 },
		{ id:BONUS_GRAIN, 			weight:4 },
		{ id:BONUS_BELL, 			weight:1 },
		{ id:BONUS_SHIELD, 			weight:6 },
		{ id:BONUS_VIET, 			weight:1 },
		{ id:BONUS_AMULET_RED, 		weight:2 },
		{ id:BONUS_AMULET_GREEN, 	weight:2 },
		{ id:BONUS_AMULET_BLUE, 	weight:2 },
		{ id:BONUS_CARD, 			weight:3 },
		{ id:BONUS_SHIELD_BLUE, 	weight:0 },
	];



	
//{
}












