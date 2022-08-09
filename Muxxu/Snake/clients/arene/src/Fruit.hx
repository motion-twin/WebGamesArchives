import Protocole;
import mt.bumdum9.Lib;

typedef FruitNearData = { rank:Int, dif:Int };

class Fruit extends Part
{//}
	public static var POOL:Array<Fruit> = [];

	public static var boxes:Array<flash.geom.Rectangle> = [];
	
	public var edible:Bool;
	public var light:Bool;
	public var rotten:Bool;
	public var dummy:Bool;
	public var etheral:Bool;
	public var star:Bool;
	
	public var death:Bool;
	public var active:Bool;
	
	public var gid:Int;
	public var baseScore:Int;
	
	var scale:Float;
	public var rx:Float;
	public var ry:Float;
	public var scoreCoef:Float;
	public var calCoef:Float;
	public var vitCoef:Float;
	public var data:DataFruit;
	
	public var box:flash.geom.Rectangle;
	

	function new(?rank) {
		super();
		backPool = Fruit.POOL;
		initFruit(rank);
	}
	public function initFruit(?rank) {
		edible = true;
		light = false;
		death = false;
		rotten = false;
		etheral = false;
		dummy = false;
		star = false;
		if( rank == null ) rank = Game.me.getRandomFruitRank();
		data = getData(rank);
		gid = getId(rank);
		baseScore = getAverageScore(rank);
		Game.me.fruits.push(this);
		
		//
		rx = 14;
		ry = 14;
		//
		x = 0;
		y = 0;
		z = 0;
		scale = 1;
		ray = 0;
		weight = 0.2;
		frictBounceZ = 0.75;
		frict = 0.95;
		
		scoreCoef = 1;
		calCoef = 1;
		vitCoef = 1;
		
		active = true;
		weightSleep = true;
		
		// TIME
		var t = Cs.FRUIT_TIMER * data.sta * 0.075;//0.1;
		if ( (data.score < 0 || Game.me.have(OGM) ) && !has(Shit) && Game.me.have(DESHERBANT,true)) 	t *= 0.4;
		if( Game.me.have(HOURGLASS) ) 										t *= 2;
		if( has(Shit) && Game.me.have(KLEENEX) ) 							t *= 0.6;
		if ( has(Shit) && Game.me.have(BROOM) ) 							t *= 0.6;
		timer = Std.int(t);
		
		// CARDS
		if( data.score < 0 ) Game.me.have(IDOL, true);
		
		// GFX
		var fr = Gfx.fruits.get(gid, "main");
		sprite.drawFrame(fr);
		Stage.me.dm.add(sprite, Stage.DP_FRUITS);
		dropShade(true);
		setBox();
		
		// CARDS
		var plunger = Game.me.numCard(PLUNGER);
		if(  plunger > 0 ) new fx.DragFruit(this, plunger);
	}
	
	static public function get(?rank) {
		if( Fruit.POOL.length == 0 ) return new Fruit(rank);
		var p = Fruit.POOL.pop();
		p.init();
		p.initFruit(rank);
		return p;
	}
	
	override function update() {
		if ( timer < Cs.TIME_BLINK ) blink(2);
		super.update();
	}
	override function updatePos() {
		super.updatePos();
		sprite.pxx();
	}

	override function timeUp() {
		
		// GREEN HOUSE
		if ( Game.me.have(GREEN_HOUSE) ) {
			var next = null;
			if ( has(Green) ) 	next = Red;
			if ( has(Red) && Game.me.have(OGM) ) 	next = Blue;
			if ( next != null ){
				var fr = Fruit.get(Fruit.getNearest(data.rank, next));
				fr.x = x;
				fr.y = y;
				fr.launch(0, 0, -2);
				fr.updatePos();
				kill();
				return;
			}
		}
				
		var penalty = true;
		
		if( has(Shit)  ) penalty = false;
		
		if ( has(Leaf) && Game.me.have(ZIPPO,true) ) {
			penalty = false;
			fxBurn();
			
		}else if( Game.me.have(MUSHROOM,true) ) {
			var score = -getScore();
			Game.me.incScore( score );
			var p = new fx.Score(x, y, score );
		}
		
		if ( fx.Virus.me != null ) fx.Virus.me.onFruitVanish(this);
		
		
		
		if ( (data.score < 0 || Game.me.have(OGM) ) && Game.me.have(DESHERBANT) ) penalty = false;
		
		fx.Wotp.GRAVEYARD.push(data.rank);
		
		
		if( penalty ){
			if( Game.me.protect() ) {
				fxProtect();
			} else {
				Game.me.incFrutipower( -6);
				fxCrane();
			}
		}
		
		super.timeUp();
	}
	
	override function checkBorderBounce() {
		if ( x < rx|| x > Stage.me.width - rx ) {
			vx *= -frictBounceZ;
			x = Num.mm( rx, x, Stage.me.width - rx);
		}
		if ( y < ry || y > Stage.me.height - ry ) {
			vy *= -frictBounceZ;
			y = Num.mm( ry, y, Stage.me.height - ry);
		}
	}
	
	// GET
	public function getScore() {
		
		var sc = baseScore * data.score * 0.1;
		var h = Game.me.have;
		
		
		// SWAP
		var lim = 50 + (h(WINDMILL_SMALL)?100:0) + (h(WINDMILL_BIG)?300:0);
		if( sc < lim && h(KETCHUP, true) ) sc = lim;
		
		// ADD
		sc += 100*Game.me.numCard(SALT);
		sc += 200 * Game.me.numCard(PEPPER);
		sc += 200 * Game.me.numCard(MUSTARD) * Game.me.shield;
		sc += fx.MagicPowder.MAX;
		
		// MULTIPLY
		sc *= scoreCoef;
		if ( Game.me.snake.rainbow )								sc *= 2;
		if( h(OGM) )												sc *= 2;
		if( h(BULL, false) ) 										sc *= 2;
		if( has(Nut) &&						h(SQUIRREL, true) ) 	sc *= 10;
		if( has(Sugar) &&					h(CANDY, true) ) 		sc *= 1.5;
		if( has(Flower) && 					h(HONEYPOT, true) ) 	sc *= 5;
		if( has(Leaf) &&					h(VINE_LEAF, true) ) 	sc *= 0.5;
		if( timer < Cs.TIME_BLINK &&		h(CANDLE, true) )		sc *= (2*Game.me.numCard(CANDLE));
		if( data.rank < 50 && 				h(LADLE, true) ) 		sc *= (2*Game.me.numCard(LADLE));
		if( has(Red) && 					h(POTION_RED, true) ) 	sc *= (2*Game.me.numCard(POTION_RED));
		if( Game.me.getTime() < 90000 &&	h(LOUD_SPEAKER, true) )	sc *= (2*Game.me.numCard(LOUD_SPEAKER));
		if( fx.Soap.ACTIVE &&				h(SOAP, true) )			sc *= 2;

		// SPECIFIC
		if ( has(Red) && sc > 0 && h(BULL,true)	) 				sc *= -1;

		return Std.int(sc);
	}
	public function getCal() {
		if( light ) return 0.0;
		
		var cal = data.cal * 1.0 * calCoef;

		if ( has(Leaf) && 								Game.me.have(VINE_LEAF ) ) 				cal *= 0.0;
		if ( data.rank < 50+Game.me.numCard(BAT)*50 && 	Game.me.have( SERINGUE, true ) ) 		cal *= 0.0;
		if ( Game.me.seed.random(3) == 0 &&				Game.me.have( WORM, true ) ) 			cal *= 0.0;
		if ( has(Blue) &&								Game.me.have( DOLPHIN, true ) ) 		cal *= 0.0;
		if ( data.score < 0 && 							Game.me.have( HAY_STACK, true )	)		cal *= 0.0;
		if (  Game.me.have(OGM) && 						Game.me.have(HAMBURGER,true) )			cal *= 2.0;
		return cal;
	}
	public function getVit() {
		if( rotten ) return 0.0;
		var vit = data.vit * 0.1 * vitCoef;
		vit *= 0.4;
		if ( Game.me.have(STEROID) ) 	vit *= 2;
		if(  Game.me.have(OGM) )		vit *= 0.5;
		if( Game.me.have( HAY_STACK) && data.score < 0 ) vit += 2;
		return vit;
	}

	
	public function unregister() {
		active = false;
		Game.me.fruits.remove(this);
	}
	public function vanish() {
		kill();
	}
	override function kill() {
		death = true;
		unregister();
		super.kill();
	}
	
	// COMMANDS
	public function specialSpawn() {
		timer *= 2;
		launch(0, 0, -1.5);
		new fx.Flash(sprite);
		new fx.Sparkling(sprite,15);
		
	}
	public function setScale(sc) {
		scale = sc;
		sprite.scaleX = sc;
		sprite.scaleY = sc;
		shade.scaleX = sc;
		shade.scaleY = sc;
		setBox();
	}
	public function evolve(inc=3) {
		var newRank = data.rank + inc;//getNearest(rank);
		var fruitMax = 280;
		while ( newRank < fruitMax && getData(newRank).freq > 1 ) newRank++;
		if ( newRank > fruitMax ) newRank = fruitMax;
		var fr = Fruit.get(newRank);
		fr.x = x;
		fr.y = y;
		fr.updatePos();
		fr.timer = timer+50;
		kill();
		
		
		var e =new fx.Sparkling(fr.sprite, 20,3);
		e.anim = "line_fade";
		
		var e = new mt.fx.Flash(fr.sprite,0.05);
		e.curveIn(2);
		
		var onde = new mt.fx.ShockWave(20, 40,0.1);
		onde.setPos( fr.x, fr.y);
		Stage.me.dm.add(onde.root, Stage.DP_UNDER_FX);
		

		
		
	}
	

	// UTILS
	public function has(tag) {
		for ( t in data.tags ) if ( t == tag ) return true;
		return false;
	}
	public function hitTest(tx:Float,ty:Float,ray) {
		//if( z < -5 ) return false;
		var dx = tx - x;
		var dy = ty - y;
		return Math.sqrt(dx * dx + dy * dy) < ray + 12 ;
	}
	public function hitTest2(rect:flash.geom.Rectangle,rz=0.0) {
		
		if( Math.abs(rz - z) > box.height*0.5 ) return false;
		var r = box.clone();
		r.offset(x, y);
		return r.intersects(rect);
	}
		
	// FX
	public function fxBurn() {
		var p = Stage.me.getPart("burn");
		p.setPos(x, y);
	}
	public function fxProtect() {
		var p = Part.get();
		p.sprite.drawFrame( Gfx.fx.get("big_shield"));
		p.x = x;
		p.y = y;
		
		p.fadeType = 1;
		p.timer = 15;
		p.fadeLimit = p.timer;
		p.updatePos();
		Stage.me.dm.add(p.sprite, Stage.DP_FX);
		
		p.sprite.blendMode = flash.display.BlendMode.ADD;
		Filt.glow(p.sprite, 8, 0.5, 0xFFFFFF);
		
	}
	public function fxCrane() {
		
		var p = Stage.me.getPart("crane");
		p.x = x;
		p.y = y;
		p.fadeType = 1;
		p.timer = 16;
		p.vy = - 0.5;
		p.updatePos();
		
		p.sprite.blendMode = flash.display.BlendMode.ADD;
		Filt.glow(p.sprite, 8, 0.4, 0xFFFFFF);
	}
	public function fxShade(color, ?blendMode) {
		if( blendMode == null ) blendMode = flash.display.BlendMode.NORMAL;
		var shade = Part.get();
		shade.sprite.drawFrame( Gfx.fruits.get(gid) );
		Stage.me.dm.add(shade.sprite, Stage.DP_SHADE);
		shade.x = sprite.x;
		shade.y = sprite.y;
		shade.timer = 10;
		shade.fadeType = 1;
		Col.setPercentColor(shade.sprite, 1, color );
		//shade.sprite.blendMode = flash.display.BlendMode.OVERLAY;
		shade.sprite.blendMode = blendMode;
		shade.updatePos();
		return shade;
	}

	
	// BOX
	public function setBox() {
		if( boxes[gid] != null ) {
			box = boxes[gid];
		}else{
			var bmp = new flash.display.BitmapData(32,32, true, 0);
			var fr = Gfx.fruits.get(gid);
			fr.drawAt(bmp, 0, 0);
			box = bmp.getColorBoundsRect(0xFFFFFFFF, 0, false);
			box.offset( -16, -16);
			boxes[gid] = box;
		}
		box = box.clone();
		
		
		box.x *= scale;
		box.y *= scale;
		box.width *= scale;
		box.height *= scale;
		

	}
	public function getRay() {
		var n = Math.max( -box.x, -box.y );
		n = Math.max( n, box.width - box.x );
		n = Math.max( n, box.height - box.y );
		return n;
	}
	
	// STATS
	public static var tagStats:Array<Array<Int>>;
	public static var negatives:Array<Int>;
	static public function init() {
		var a = Type.getEnumConstructs(FTag);
		var en = [];
		for ( str in a ) en.push( Type.createEnum(FTag,str)) ;
		tagStats = [];
		negatives = [];
		for( str in en ) tagStats.push([]);
		for(data in DFruit.LIST ) {
			for( id in  0...en.length  ) {
				if( data.score < 0 ) negatives.push(data.rank);
				if( Lambda.has(data.tags, en[id] ) ) tagStats[id].push(data.rank);
			}
		}
	}
	static public function getNearest(rank, ? tag:FTag) {
		if( tag == null ) return getNearInList(rank, negatives );
		return getNearInList(rank, tagStats[Type.enumIndex(tag)] );
	}
	
	
	
	static public function getNearInList(rank:Int, a:Array<Int>) {
		var cur = 0;
		var dif = 9999;
		rankLimit = rank;
		a.sort( rankLimitSort );
		while( Game.me.seed.random( Fruit.getData(a[0]).freq ) > 0 ) a.shift();
		return a[0];

	}
	static var rankLimit:Int;
	static function rankLimitSort(a:Int,b:Int) {
		if( Math.abs(rankLimit - a) < Math.abs(rankLimit - b) ) return -1;
		return 1;
	}
	
	
	static public function getClassic(rank) {
		while( rank < DFruit.LIST.length && Game.me.seed.random(Fruit.getData(rank).freq) > 0  ) rank++;
		return rank;
	}
	
	// DATA
	static public function getAverageScore(rank:Int ) {
		return DFruit.getFruitAverageScore(rank);
	}
	static public function getData(rank) {
		for ( data in DFruit.LIST ) if ( data.rank == rank ) return data;
		return null;
	}
	static public function getId(rank) {
		for ( id in 0...DFruit.LIST.length ) if ( DFruit.LIST[id].rank == rank ) return id;
		return -1;
	}
	
	/*
	static public var DATA:Array<DataFruit> = [
		{ name:"pomme shampoing",	score:8, cal:10, vit:20, sta:10, rank:4, tags:[Red,Leaf,Sugar,] },
		{ name:"groudinasse de Jauret",	score:7, cal:10, vit:10, sta:10, rank:1, tags:[Leaf,Sugar,Small,] },
		{ name:"Perpendiculine survette",	score:10, cal:10, vit:20, sta:5, rank:8, tags:[Sugar,Small,] },
		{ name:"Gromarin silmonet",	score:10, cal:20, vit:10, sta:10, rank:5, tags:[Sugar,] },
		{ name:"prunillo doré",	score:10, cal:15, vit:15, sta:10, rank:70, tags:[Small,] },
		{ name:"Bolange",	score:10, cal:10, vit:10, sta:10, rank:6, tags:[Leaf,Sugar,] },
		{ name:"frasile",	score:10, cal:10, vit:0, sta:10, rank:23, tags:[Red,Leaf,Sugar,] },
		{ name:"Garnade",	score:10, cal:10, vit:10, sta:10, rank:20, tags:[Green,] },
		{ name:"baltenaine",	score:15, cal:10, vit:10, sta:10, rank:78, tags:[] },
		{ name:"goussiniere blanche d'erythree",	score:10, cal:15, vit:20, sta:15, rank:141, tags:[Leaf,Sugar,] },
		{ name:"casperole",	score:10, cal:10, vit:10, sta:10, rank:10, tags:[Leaf,Small,] },
		{ name:"boursine autrichienne",	score:10, cal:5, vit:10, sta:7, rank:47, tags:[Sugar,] },
		{ name:"Kassenangue",	score:10, cal:15, vit:30, sta:7, rank:60, tags:[Leaf,Sugar,] },
		{ name:"baies de celine",	score:8, cal:1, vit:15, sta:5, rank:19, tags:[Leaf,Sugar,Small,] },
		{ name:"abido",	score:10, cal:15, vit:5, sta:10, rank:34, tags:[Leaf,Sugar,] },
		{ name:"chateignoux curieux",	score:15, cal:15, vit:5, sta:10, rank:36, tags:[Nut,] },
		{ name:"baies satyres",	score:10, cal:5, vit:5, sta:5, rank:42, tags:[Sugar,] },
		{ name:"Poustillou",	score:10, cal:5, vit:10, sta:10, rank:9, tags:[Red,Sugar,Small,] },
		{ name:"porêche ventura",	score:15, cal:15, vit:15, sta:10, rank:45, tags:[Red,Leaf,Sugar,] },
		{ name:"noix de zidoune",	score:10, cal:50, vit:10, sta:15, rank:32, tags:[Leaf,Nut,Sugar,Green,] },
		{ name:"kokalank",	score:10, cal:10, vit:10, sta:10, rank:142, tags:[Sugar,] },
		{ name:"chaustigne",	score:10, cal:10, vit:10, sta:10, rank:44, tags:[Red,Sugar,] },
		{ name:"pigneule cretoise",	score:10, cal:5, vit:10, sta:10, rank:73, tags:[Leaf,Nut,Sugar,] },
		{ name:"poire",	score:10, cal:10, vit:10, sta:10, rank:24, tags:[Sugar,] },
		{ name:"noix",	score:10, cal:15, vit:15, sta:10, rank:26, tags:[Nut,Small,] },
		{ name:"pilmaude",	score:10, cal:10, vit:10, sta:10, rank:2, tags:[Small,Green,] },
		{ name:"tramontine",	score:10, cal:10, vit:5, sta:10, rank:51, tags:[Leaf,Sugar,] },
		{ name:"tasteraine siffulée",	score:10, cal:10, vit:10, sta:5, rank:7, tags:[Leaf,Sugar,Small,] },
		{ name:"sourire de lepreux",	score:-10, cal:0, vit:0, sta:10, rank:25, tags:[Leaf,Small,] },
		{ name:"frubillon",	score:10, cal:10, vit:10, sta:3, rank:30, tags:[Sugar,Flower,] },
		{ name:"prunelle de sangre",	score:10, cal:5, vit:10, sta:10, rank:72, tags:[Leaf,Sugar,Small,] },
		{ name:"fastecosse",	score:10, cal:2, vit:10, sta:10, rank:15, tags:[Sugar,Small,Green,] },
		{ name:"doucejarette",	score:15, cal:30, vit:10, sta:10, rank:74, tags:[] },
		{ name:"dorepion",	score:10, cal:5, vit:10, sta:10, rank:57, tags:[Leaf,Sugar,Small,Green,] },
		{ name:"orange",	score:10, cal:10, vit:15, sta:10, rank:13, tags:[Sugar,Agrume,] },
		{ name:"Racteronce",	score:10, cal:5, vit:15, sta:30, rank:39, tags:[] },
		{ name:"mangrole",	score:10, cal:10, vit:10, sta:5, rank:91, tags:[Leaf,Sugar,] },
		{ name:"petite disette",	score:-10, cal:10, vit:10, sta:2, rank:117, tags:[Leaf,Sugar,] },
		{ name:"cissenerve",	score:15, cal:15, vit:10, sta:10, rank:21, tags:[Leaf,Green,] },
		{ name:"maugruche ",	score:10, cal:10, vit:20, sta:10, rank:111, tags:[Red,Sugar,] },
		{ name:"gland",	score:10, cal:10, vit:10, sta:20, rank:3, tags:[Nut,Small,] },
		{ name:"bolange geruvienne",	score:10, cal:5, vit:15, sta:15, rank:64, tags:[Leaf,Sugar,] },
		{ name:"olive",	score:10, cal:20, vit:20, sta:10, rank:12, tags:[Small,] },
		{ name:"courgestine",	score:10, cal:15, vit:10, sta:10, rank:31, tags:[Red,Leaf,Sugar,] },
		{ name:"prunemate d'Abidjan",	score:5, cal:10, vit:20, sta:10, rank:38, tags:[Leaf,Sugar,Small,] },
		{ name:"champoucte cruciere",	score:10, cal:10, vit:10, sta:5, rank:113, tags:[Sugar,Small,] },
		{ name:"mazoulette",	score:10, cal:20, vit:30, sta:10, rank:54, tags:[Leaf,Sugar,] },
		{ name:"pokaran",	score:10, cal:10, vit:10, sta:10, rank:0, tags:[Leaf,Sugar,Small,] },
		{ name:"petite-rave",	score:10, cal:5, vit:10, sta:10, rank:35, tags:[Sugar,Small,Leaf,] },
		{ name:"pokaran granit",	score:5, cal:10, vit:30, sta:30, rank:41, tags:[Leaf,Sugar,Small,] },
		{ name:"ephemeruine",	score:15, cal:10, vit:15, sta:3, rank:40, tags:[Leaf,Sugar,Small,] },
		{ name:"musillo",	score:5, cal:15, vit:30, sta:5, rank:77, tags:[Red,Leaf,Sugar,] },
		{ name:"carrilude",	score:10, cal:30, vit:10, sta:20, rank:18, tags:[Small,Green,] },
		{ name:"frankepoise",	score:10, cal:10, vit:20, sta:5, rank:76, tags:[Red,Leaf,Sugar,] },
		{ name:"maltechat",	score:20, cal:40, vit:10, sta:10, rank:79, tags:[Sugar,] },
		{ name:"kanstakine",	score:10, cal:10, vit:5, sta:10, rank:48, tags:[Sugar,Small,] },
		{ name:"arcosse brune",	score:10, cal:10, vit:10, sta:20, rank:80, tags:[Leaf,Sugar,] },
		{ name:"bidoulon cornu",	score:15, cal:10, vit:10, sta:10, rank:14, tags:[Red,Sugar,] },
		{ name:"rupinio",	score:10, cal:0, vit:20, sta:10, rank:81, tags:[Red,Leaf,Sugar,] },
		{ name:"ultrabricot",	score:12, cal:10, vit:5, sta:10, rank:37, tags:[Leaf,Sugar,] },
		{ name:"frozine",	score:15, cal:5, vit:0, sta:7, rank:84, tags:[Leaf,Sugar,] },
		{ name:"palmanzor",	score:20, cal:20, vit:50, sta:5, rank:179, tags:[Leaf,Sugar,] },
		{ name:"bastimolle d'octonante",	score:10, cal:10, vit:10, sta:7, rank:87, tags:[Sugar,] },
		{ name:"sageprune",	score:5, cal:10, vit:50, sta:5, rank:88, tags:[Leaf,Sugar,Small,] },
		{ name:"poirette sauvage",	score:10, cal:10, vit:10, sta:7, rank:55, tags:[Sugar,] },
		{ name:"cissenerve orientale",	score:10, cal:20, vit:10, sta:30, rank:95, tags:[Leaf,Sugar,] },
		{ name:"gourmine du clerc",	score:10, cal:15, vit:10, sta:5, rank:97, tags:[Leaf,Sugar,Red,] },
		{ name:"Epiphede de Tanzanie",	score:10, cal:10, vit:30, sta:10, rank:109, tags:[Red,Sugar,] },
		{ name:"poire elite",	score:15, cal:15, vit:10, sta:7, rank:100, tags:[Sugar,] },
		{ name:"chenibe",	score:-10, cal:10, vit:10, sta:10, rank:138, tags:[Sugar,] },
		{ name:"'i' d'oedipe",	score:10, cal:15, vit:20, sta:7, rank:33, tags:[Sugar,Green,] },
		{ name:"grande geluge",	score:7, cal:0, vit:20, sta:10, rank:75, tags:[] },
		{ name:"chank-sar",	score:10, cal:0, vit:20, sta:10, rank:144, tags:[Sugar,] },
		{ name:"bolterouge",	score:10, cal:10, vit:10, sta:10, rank:102, tags:[Red,Sugar,] },
		{ name:"kouss-pouss",	score:10, cal:10, vit:5, sta:10, rank:104, tags:[Sugar,] },
		{ name:"abricot",	score:10, cal:10, vit:10, sta:10, rank:11, tags:[Sugar,Small,] },
		{ name:"louki",	score:30, cal:15, vit:10, sta:4, rank:67, tags:[Red,Leaf,Sugar,] },
		{ name:"manguerite",	score:10, cal:5, vit:20, sta:10, rank:127, tags:[Leaf,Sugar,] },
		{ name:"pomme grande gueule",	score:15, cal:20, vit:20, sta:20, rank:27, tags:[Red,Leaf,Sugar,] },
		{ name:"citron",	score:10, cal:10, vit:15, sta:10, rank:22, tags:[Agrume,] },
		{ name:"pulminost",	score:10, cal:20, vit:10, sta:10, rank:123, tags:[Sugar,] },
		{ name:"loncourge siamoise",	score:10, cal:20, vit:10, sta:10, rank:50, tags:[Sugar,] },
		{ name:"glastouine",	score:10, cal:5, vit:5, sta:10, rank:124, tags:[Sugar,] },
		{ name:"faritiere",	score:10, cal:10, vit:15, sta:20, rank:28, tags:[Leaf,Sugar,] },
		{ name:"Pastelite",	score:10, cal:10, vit:15, sta:5, rank:17, tags:[Leaf,Sugar,] },
		{ name:"bouverest",	score:10, cal:20, vit:0, sta:100, rank:125, tags:[Red,Leaf,Sugar,] },
		{ name:"terropostule",	score:-10, cal:15, vit:10, sta:15, rank:96, tags:[Leaf,Sugar,] },
		{ name:"grosse grubine d'anniversaire",	score:10, cal:20, vit:0, sta:10, rank:129, tags:[Red,Leaf,Sugar,] },
		{ name:"pamplemouk",	score:15, cal:10, vit:15, sta:10, rank:29, tags:[Sugar,Agrume,] },
		{ name:"carcaoule",	score:10, cal:10, vit:10, sta:5, rank:132, tags:[Leaf,Sugar,] },
		{ name:"langue de vieille",	score:12, cal:10, vit:10, sta:7, rank:174, tags:[Red,Leaf,Sugar,] },
		{ name:"kogredon",	score:10, cal:5, vit:25, sta:10, rank:134, tags:[] },
		{ name:"barsouine versicolore",	score:15, cal:15, vit:40, sta:5, rank:158, tags:[Leaf,Sugar,] },
		{ name:"sertoine",	score:10, cal:0, vit:5, sta:10, rank:61, tags:[Leaf,Small,] },
		{ name:"pacoblemide",	score:10, cal:20, vit:10, sta:5, rank:66, tags:[Leaf,Sugar,Green,] },
		{ name:"boteliane d'hygrone",	score:10, cal:5, vit:10, sta:7, rank:140, tags:[Sugar,Flower,] },
		{ name:"chantegore",	score:15, cal:10, vit:0, sta:10, rank:135, tags:[Red,Flower,] },
		{ name:"mono-iote",	score:10, cal:10, vit:0, sta:20, rank:114, tags:[Leaf,Sugar,Red,] },
		{ name:"pankersh",	score:10, cal:10, vit:5, sta:5, rank:46, tags:[Sugar,] },
		{ name:"vareche du malin",	score:-10, cal:20, vit:5, sta:30, rank:65, tags:[Red,Leaf,] },
		{ name:"raisin bordelais",	score:10, cal:10, vit:10, sta:5, rank:68, tags:[Sugar,] },
		{ name:"gorgonde de Molister",	score:10, cal:20, vit:10, sta:10, rank:147, tags:[Sugar,] },
		{ name:"gencive de truie",	score:10, cal:15, vit:10, sta:10, rank:145, tags:[Leaf,Sugar,Red,] },
		{ name:"justeprune",	score:15, cal:10, vit:10, sta:10, rank:148, tags:[Leaf,Sugar,] },
		{ name:"crysto-mangue",	score:10, cal:5, vit:15, sta:10, rank:149, tags:[Leaf,Sugar,] },
		{ name:"banane",	score:10, cal:10, vit:0, sta:10, rank:43, tags:[Sugar,] },
		{ name:"dalinette",	score:15, cal:20, vit:10, sta:10, rank:99, tags:[Leaf,Sugar,] },
		{ name:"Goulumide",	score:-10, cal:20, vit:10, sta:10, rank:62, tags:[Leaf,Sugar,] },
		{ name:"taroudon",	score:10, cal:3, vit:10, sta:50, rank:98, tags:[Sugar,] },
		{ name:"vautrille",	score:10, cal:5, vit:5, sta:10, rank:146, tags:[Leaf,Sugar,] },
		{ name:"bangalosh d'Akoupi",	score:15, cal:15, vit:20, sta:10, rank:164, tags:[] },
		{ name:"gonfle gelose",	score:15, cal:10, vit:10, sta:20, rank:133, tags:[Sugar,] },
		{ name:"amande carnivore",	score:10, cal:20, vit:10, sta:10, rank:161, tags:[Leaf,Nut,] },
		{ name:"vulcanouille",	score:10, cal:20, vit:15, sta:10, rank:169, tags:[Red,Sugar,] },
		{ name:"postichonne",	score:10, cal:15, vit:10, sta:10, rank:83, tags:[Leaf,] },
		{ name:"rupekt",	score:10, cal:15, vit:10, sta:10, rank:92, tags:[Red,Sugar,] },
		{ name:"fruit-du-grouin",	score:10, cal:15, vit:10, sta:10, rank:86, tags:[Leaf,Sugar,] },
		{ name:"sac-a-bile",	score:-15, cal:0, vit:0, sta:10, rank:85, tags:[Red,Sugar,] },
		{ name:"tazerade geminite",	score:-10, cal:15, vit:10, sta:20, rank:151, tags:[Sugar,] },
		{ name:"marron strié",	score:10, cal:10, vit:10, sta:10, rank:115, tags:[Nut,] },
		{ name:"driane de Moss",	score:10, cal:15, vit:10, sta:10, rank:152, tags:[Sugar,] },
		{ name:"noix de Gernide",	score:12, cal:15, vit:20, sta:10, rank:90, tags:[] },
		{ name:"poistule",	score:15, cal:15, vit:10, sta:10, rank:153, tags:[Red,Sugar,] },
		{ name:"bonzerone",	score:-10, cal:5, vit:20, sta:10, rank:93, tags:[Sugar,Green,] },
		{ name:"triangustine",	score:10, cal:10, vit:10, sta:10, rank:89, tags:[Red,Sugar,] },
		{ name:"radoux",	score:-10, cal:10, vit:10, sta:10, rank:128, tags:[Sugar,] },
		{ name:"sadentro",	score:10, cal:5, vit:5, sta:10, rank:82, tags:[Red,Leaf,Sugar,] },
		{ name:"grogofurile",	score:10, cal:20, vit:10, sta:10, rank:122, tags:[Sugar,] },
		{ name:"lookar chapelé",	score:10, cal:5, vit:10, sta:10, rank:154, tags:[Leaf,Sugar,] },
		{ name:"sarsulene",	score:10, cal:10, vit:10, sta:20, rank:112, tags:[Leaf,Sugar,Green,] },
		{ name:"auberlune",	score:20, cal:10, vit:10, sta:10, rank:175, tags:[Leaf,Sugar,] },
		{ name:"fugione codeinée",	score:5, cal:15, vit:10, sta:10, rank:155, tags:[Red,Leaf,Sugar,] },
		{ name:"sabot d'Obyrinthe",	score:10, cal:10, vit:10, sta:10, rank:156, tags:[Leaf,Sugar,] },
		{ name:"fongiole purpide",	score:15, cal:10, vit:10, sta:10, rank:118, tags:[Red,Sugar,] },
		{ name:"boulange",	score:10, cal:10, vit:20, sta:10, rank:160, tags:[Green,] },
		{ name:"gorank-sakkar",	score:15, cal:20, vit:10, sta:10, rank:178, tags:[Leaf,Sugar,] },
		{ name:"fourmalie",	score:10, cal:0, vit:10, sta:10, rank:139, tags:[Sugar,] },
		{ name:"coustoron",	score:10, cal:15, vit:10, sta:10, rank:159, tags:[Sugar,Green,] },
		{ name:"sochon de Panurge",	score:10, cal:15, vit:10, sta:10, rank:163, tags:[Red,Sugar,] },
		{ name:"mouladre",	score:10, cal:10, vit:10, sta:20, rank:71, tags:[] },
		{ name:"sabirone craquelée",	score:10, cal:15, vit:10, sta:10, rank:165, tags:[Red,Sugar,] },
		{ name:"langolfier",	score:-10, cal:10, vit:10, sta:10, rank:56, tags:[Sugar,] },
		{ name:"pouladiche",	score:10, cal:10, vit:10, sta:10, rank:110, tags:[Sugar,] },
		{ name:"tribaie de Mireillon",	score:10, cal:15, vit:10, sta:10, rank:166, tags:[Red,Sugar,] },
		{ name:"sarule fraisière de synthèse",	score:7, cal:15, vit:10, sta:10, rank:162, tags:[Sugar,] },
		{ name:"Marveloune",	score:10, cal:15, vit:0, sta:10, rank:167, tags:[Leaf,] },
		{ name:"joint-de-boise",	score:15, cal:15, vit:15, sta:10, rank:168, tags:[Red,Sugar,] },
		{ name:"dolastige",	score:15, cal:10, vit:10, sta:10, rank:106, tags:[Red,Leaf,Sugar,] },
		{ name:"sauf-kinède",	score:15, cal:15, vit:10, sta:10, rank:173, tags:[Leaf,Sugar,Green,] },
		{ name:"personde de Bruges",	score:10, cal:15, vit:10, sta:10, rank:171, tags:[Leaf,Sugar,] },
		{ name:"picotoze",	score:-10, cal:0, vit:0, sta:10, rank:170, tags:[Leaf,Sugar,] },
		{ name:"carotte bleue de jean-prune",	score:10, cal:10, vit:10, sta:10, rank:172, tags:[Sugar,] },
		{ name:"boutignole",	score:5, cal:2, vit:10, sta:10, rank:49, tags:[Nut,] },
		{ name:"mangrume",	score:10, cal:15, vit:10, sta:10, rank:136, tags:[Red,Sugar,] },
		{ name:"kiste",	score:10, cal:5, vit:5, sta:15, rank:119, tags:[] },
		{ name:"pamplehue",	score:10, cal:0, vit:10, sta:10, rank:176, tags:[Sugar,Agrume,] },
		{ name:"pangine corsée",	score:10, cal:10, vit:10, sta:10, rank:126, tags:[Sugar,] },
		{ name:"frulonque",	score:10, cal:20, vit:10, sta:5, rank:150, tags:[Sugar,] },
		{ name:"griste veruleuse",	score:-10, cal:10, vit:10, sta:10, rank:107, tags:[Red,Leaf,Sugar,] },
		{ name:"ballon d'Emiplegianne",	score:10, cal:0, vit:15, sta:10, rank:105, tags:[Sugar,Green,] },
		{ name:"Espigoune",	score:10, cal:35, vit:10, sta:10, rank:101, tags:[Leaf,Sugar,] },
		{ name:"nonehime",	score:10, cal:10, vit:10, sta:10, rank:116, tags:[Green,] },
		{ name:"surinade",	score:-15, cal:15, vit:10, sta:10, rank:177, tags:[Sugar,] },
		{ name:"fessedange",	score:10, cal:10, vit:0, sta:10, rank:69, tags:[Sugar,] },
		{ name:"parugraine",	score:10, cal:10, vit:10, sta:10, rank:108, tags:[Red,Leaf,Sugar,] },
		{ name:"drigelon amer",	score:10, cal:10, vit:10, sta:100, rank:137, tags:[Green,] },
		{ name:"choux kibilien",	score:10, cal:10, vit:10, sta:10, rank:131, tags:[Flower,Sugar,] },
		{ name:"piligrone",	score:-10, cal:10, vit:30, sta:10, rank:16, tags:[Green,] },
		{ name:"Kramkram",	score:8, cal:5, vit:10, sta:10, rank:53, tags:[Small,] },
		{ name:"saunecosse",	score:20, cal:10, vit:10, sta:10, rank:103, tags:[Leaf,Sugar,Green,] },
		{ name:"soucixte",	score:10, cal:5, vit:10, sta:10, rank:143, tags:[Leaf,Green,] },
		{ name:"apophèse poreuse",	score:-10, cal:10, vit:10, sta:10, rank:130, tags:[Sugar,] },
		{ name:"kovak",	score:7, cal:20, vit:5, sta:15, rank:94, tags:[Sugar,] },
		{ name:"bouton d'ame",	score:15, cal:5, vit:5, sta:10, rank:63, tags:[Flower,Sugar,] },
		{ name:"chankor-pak",	score:10, cal:15, vit:10, sta:10, rank:157, tags:[Sugar,] },
		{ name:"albuzides",	score:15, cal:20, vit:50, sta:10, rank:120, tags:[Sugar,] },
		{ name:"courgeazur",	score:15, cal:10, vit:10, sta:10, rank:58, tags:[] },
		{ name:"grizline",	score:-10, cal:10, vit:5, sta:10, rank:52, tags:[] },
		{ name:"atlanteole",	score:10, cal:10, vit:5, sta:10, rank:121, tags:[Sugar,] },
		{ name:"baie d'octarus",	score:30, cal:5, vit:10, sta:10, rank:59, tags:[Small,Sugar,] },
	];
	*/

	


	
//{
}












