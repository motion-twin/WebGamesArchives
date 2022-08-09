import Protocole;
import mt.bumdum9.Lib;

class Card
{//}
	public static var WIDTH = 	43;
	public static var HEIGHT = 	62;
	public static var FLIP_SPEED = 0.08;
	public var type:_CardType;
	public var sprite:flash.display.Sprite;
	
	public var data:DataCard;
	public var id:mt.flash.Volatile<Int>;
	public var mojo:mt.flash.Volatile<Int>;
	
	public var active:mt.flash.Volatile<Bool>;
	
	public var gfx:GfxCard;
	
	public var shade:pix.Element;
	
	public var coef:mt.flash.Volatile<Float>;
	public var z:Float;
	public var dz:Float;
	public var cooldown:mt.flash.Volatile<Int>;
	public var cooldownMax:mt.flash.Volatile<Int>;
		
	var mcKey:pix.Element;
	var mcDark:pix.Element;
	var key:Int;
	var keyFlash:Null<Float>;
	
	
	
	public function new(t:_CardType) {
		data = Data.CARDS[Type.enumIndex(t)];
		type = t;
		sprite = new pix.Element();
		mojo = data.mojo;
		
		if(  Game.me!= null && data.time != null ) key = Game.me.getFreeKey();
		
		
		genSprite();
		coef = 0;
		active = false;
		z = 0;
		dz = 0;
		cooldown = 0;

	}
	
	//
	public function update() {
		if ( cooldown > 0 ) {
			cooldown--;
			majDark();
		}
		updateKeyFlash();
	}
	
	// GFX
	public function genSprite() {
		
		gfx = new GfxCard();
		gfx.setType(type);
		
		
		// SHADE
		shade = new pix.Element();
		shade.y += 1;
		shade.drawFrame(Gfx.main.get(0, "cards"));
		Col.setPercentColor(shade, 1, 0x308015);
		
		// ADD
		sprite.addChild(shade);
		sprite.addChild(gfx);

	}
	public function majSprite() {
		//gfx.coef = coef;
		//gfx.majSprite();
		gfx.coef = 0.75 - coef * 0.5;
		gfx.majSprite();
		

		
		var face = gfx.face;
		var back = gfx.back;
		
		//face.scaleX = Num.mm(0, Snk.sin( ((1-(coef-0.5))/0.5)*1.57), 1 );
		//back.scaleX = Num.mm(0, Snk.cos( (coef / 0.5) * 1.57), 1 );
		
		dz = -Snk.sin(coef * 3.14)*8;
		
		// SHADE
		shade.x = -dz * 1.7;
		shade.y = -dz * 0.4 + 1;
		shade.scaleX = 1 - Snk.sin(coef * 3.14 ) * 0.5; //dz  //Math.max(face.scaleX, back.scaleX);
		shade.alpha = 1 - Snk.sin(coef * 3.14 ) * 0.75;
		
		var ec = -6;
		face.x = Snk.sin(coef * 3.14) * ec;
		back.x = Snk.sin(coef * 3.14) * ec;
		
		face.y = z + dz;
		back.y = z + dz;

		var bright = 120;
		Col.setColor( face, 0, Std.int(bright*(1-face.scaleX)) );
		Col.setColor( back, 0, -Std.int(bright * (1 - back.scaleX)) );
		

		
	}
	
	public function flipIn() {
		if ( active ) return;
		flip();
			
	}
	public function flipOut() {
		if ( !active ) return;
		flip();
	}
	
	public function flip() {
		active = !active;
		if( Game.me != null ){
			if( active) onActive();
			if(!active) onDeactive();
		}
		sprite.addEventListener(flash.events.Event.ENTER_FRAME, updateFlip);
	}
	function updateFlip(e) {
		var sens = active?1: -1;
		coef = Num.mm( 0, coef + sens * FLIP_SPEED, 1 );
		majSprite();
		if(coef == 0 || coef == 1) 	sprite.removeEventListener(flash.events.Event.ENTER_FRAME, updateFlip);
	}
	
	//public var chrono:flash.text.TextField;
	public function displayChrono() {
		/*
		if( chrono == null ){
			chrono = Cs.getField(0xFFFFFF, 8,-1);
			chrono.y = 12;
			chrono.text = "24:00'00";
			chrono.width = Card.WIDTH;
			chrono.x = -Std.int(chrono.width * 0.5);
			chrono.blendMode = flash.display.BlendMode.OVERLAY;
			sprite.addChild(chrono);
			chrono.filters = [ new flash.filters.GlowFilter(0x555555,1,2,2,100)];
		}
		chrono.visible = true;
		*/
		Col.setPercentColor(gfx, 0.75, 0x004400);

	}
	public function removeChrono() {
		//if( chrono == null ) return;
		//chrono.visible = false;
		Col.setPercentColor(gfx, 0, 0);
	}
	

	//var fieldCopies:flash.text.TextField;
	public function displayCopies(n) {
		gfx.displayCopies(n);
	}
	
	// ACTIVATION
	function onActive() {
		
		if ( data.time != null ) setupAction();
		
		switch(type) {
			case ARROSOIR :			Game.me.incFrutipower(10);
			case BARROW :			Game.me.incFrutipower(25);
			case CONCRETE_MIXER :
				Game.me.incFrutipower(50);
				new fx.AutoIncFrutipower(this,-0.1);
			
			case PICK_AXE :		new fx.IncWidth(50);
			case DETONATOR :	Bonus.incWeight( BONUS_DYNAMITE, 60 );
			case ECSTASY :		Bonus.incWeight( BONUS_PILLULE, 100 );
			case HAMBURGER :	Game.me.snake.incLength(100);
			
			case AMPLI :
				Bonus.incWeight( BONUS_FLUTE, 16 );
				Bonus.incWeight( BONUS_GUITAR, 8 );
				Bonus.incWeight( BONUS_TRUMPET, 4 );

			case GALAXY :			new fx.Fluid(this);
				
			//
			case REGLISSE :			new fx.BlackSnake(this);
			case SMILEY :			new fx.Smiley(this);
			case PIN :				new fx.Pin(this);
			case ROLLER :			new fx.Roller(this);
			case PINK_RIBBON :		new fx.PinkRibbon(this);
			case SCANNER :			new fx.Scanner(this);
			case BROOM :			new fx.Broom(this);
			case CRYSTAL_BALL :		new fx.Seer(this);
			case POTION_PINK :		new fx.FruitJump(this);
			case BATTERY :			new fx.Battery(this);
			case MAGNET :			new fx.Magnet(this);
			case STEROID :			new fx.Steroid(this);
			case GLOBE :			new fx.Globe(this);
			case FERTILIZER :		new fx.Fertilizer(this);
			case RUNE_VITAMIN :		new fx.Rune(this, 0);
			case RUNE_SLIM :		new fx.Rune(this, 1);
			case RUNE_STRENGTH :	new fx.Rune(this, 2);
			case RUNE_BOOST :		new fx.Rune(this, 3);
			case FUNNEL :			new fx.Funnel(this);
			case PARANOIA :			new fx.Closer(this);
			case GHOST :			new fx.Chrono(this, 120, function() { new fx.Ghost(); } );
			case BLENDER :			new fx.Blender(this);
			case VIRUS :			new fx.Virus(this);
			case HORMONES :			new fx.AutoIncQueue(this);
			case FOG :				new fx.Fog(this);
			case FLAG :				new fx.Flag(this);
			
			
			case BOUNTY :
				if ( !Game.me.have(PICK_AXE) )		new fx.Bounty(this);
		
			case TRAINING : 	new fx.Training();
			
			/*
			case CROISSANT :
				var n = Game.me.getFrutipowerMinimum();
				if( Game.me.frutipower < n ) {
					Game.me.frutipower = n;
					Game.me.incFrutipower(0);
				}
				*/

				
			default:
		}
		Game.me.incFrutipower(0);
		checkHand();
	}
	function onDeactive() {
		switch(type) {
			case ARROSOIR :			Game.me.incFrutipower(-10);
			case BARROW :			Game.me.incFrutipower(-25);
			case CONCRETE_MIXER :	Game.me.incFrutipower(50);
			case PICK_AXE :			new fx.IncWidth(-50);
			case DETONATOR :		Bonus.incWeight( BONUS_DYNAMITE, -60 );
			case ECSTASY :			Bonus.incWeight( BONUS_PILLULE, -100 );
			case HAMBURGER :		Game.me.snake.incLength( -100);
			
			case AMPLI :
				Bonus.incWeight( BONUS_FLUTE, -16 );
				Bonus.incWeight( BONUS_GUITAR, -8 );
				Bonus.incWeight( BONUS_TRUMPET, -4 );

				
			case REGLISSE, SMILEY, PIN, ROLLER, PINK_RIBBON, SCANNER, BROOM :		// AUTO;
			default:
		}
	
		checkHand();
		
	}
	
	function checkHand() {
		
		var sn = Game.me.snake;
		sn.queueType = Q_STANDARD;
		
		// RAINBOW
		sn.rainbow = false;
		if( Game.me.haveMany([POTION_RED, POTION_ORANGE, POTION_YELLOW, POTION_GREEN, POTION_BLUE, POTION_PINK]) ) {
			sn.rainbow = true;
			sn.queueType = Q_RAINBOW(0.05, 0.6);
		}
		
		//
		/*
		if( Game.me.have(RAINBOW) ) {
			sn.queueType = Q_BONES;
		}
		*/
	

	}
	
	
	// ACTION
	function setupAction() {
		switch(type) {
			case RESSORT, GLOTTIS, BELT : return;
			default:
		}
		
		Keyb.actions[key] = registerAction;
		
		// GFX
		mcKey = new pix.Element();
		mcKey.drawFrame(Gfx.main.get(0, "round_key"));
		gfx.face.addChild(mcKey);
		mcKey.x = WIDTH * 0.5 - 5;
		mcKey.y = HEIGHT * 0.5 - 6;
		mcKey.pxx();
		
		/*
		var field = new flash.text.TextField();
		var tf = new flash.text.TextFormat("04b03", 8, 0x440000, true);
		field.defaultTextFormat = tf;
		*/
		var field = Cs.getField(0x550000, 8, -1, "nokia");
		//var field = Cs.getField(0x440000, 8, -1, "nokia");
		field.text = Std.string( Keyb.getKeyName(key).toUpperCase() );
		field.x = -2-Std.int(field.textWidth*0.5);
		field.y = -8;
		mcKey.addChild(field);

	
	}
	public function registerAction() {
		if( Game.me.cardEvent == null || Game.me.gtimer < 10 ) return;
		Game.me.cardEvent.push(this);
	}
	
	public function action() {
		if ( !active ) return;
		if ( cooldown > 0 ) return;
		keyFlash = 1;
		var snake = Game.me.snake;
		
		var cdown = data.time;
		switch(type) {

				
			case FRUCTWINER :
				var a  = Game.me.fruits.copy();
				if( a.length < 100 ){
					for ( fr in a ) {
						var nfr = Fruit.get(fr.data.rank);
						nfr.x = fr.x;
						nfr.y = fr.y;
						nfr.timer = fr.timer;
						var an = Game.me.seed.rand() * 6.28;
						for ( i in 0...2 ) {
							var cfr = [fr, nfr][i];
							cfr.launch( an+ i * 3.14 , 3, -3);
						}
						nfr.etheral = true;
					}
				}
			
			case TRONCONNEUSE:
				var n =  60 + Game.me.seed.random(60);
				snake.cut(n,true,true);
				
			case SAW :
				snake.cut(70, true, true);
				if ( Game.me.have(BRAKE) && Game.me.cards.length<=3 ) new fx.IncWidth(5);
				Game.me.incSpeed(3);
				
			case BIG_SCISSOR :
				var n = Std.int(snake.length * 0.3);
				snake.cut(n,true,true);
				
			case BOOTS :
				Game.me.incSpeed( -Std.int(Game.me.speed));
				
			case SCISSOR :
				var n = Std.int(snake.length * 0.1);
				snake.cut(n, true, true);
				
			case BLENDER :
				snake.cut(50, true, true);
				
			case SWORD :
				var n = Std.int(snake.length * 0.5);
				snake.cut(n, true, true);
				Game.me.incFrutipower( - Std.int(Game.me.frutipower * 0.5));
			
			case WATCH :
				if( Game.me.gtimer < 100 ) return;
				new fx.Watch();

			case PIPE :
				snake.reverse();
				if ( Game.me.have(POTION_YELLOW) ) for ( i in 0...3 ) Game.me.specialSpawn(Yellow);
				
			case PIRATE :
				var b = Bonus.spawn(BONUS_CHEST);
				b.launch(0, 0, -4);
				new fx.Flash(b.sprite);
				if ( Game.me.have(PIRATE) ) cdown -= 200;
				
			case DOLPHIN :
				var b = Bonus.spawn(BONUS_RING);
				b.launch(0, 0, -4);
				new fx.Flash(b.sprite);
				
			case SMALL_CHEST :
				var max = 3 + Game.me.numCard(PIRATE);
				for( i in 0...max ){
					var b = Bonus.spawn([BONUS_AMULET_BLUE,BONUS_AMULET_GREEN,BONUS_AMULET_RED][i%3]);
					b.launch(0, 0, -4);
					new fx.Flash(b.sprite);
				}
				
			case THORNS :
				Game.me.specialSpawn(Flower);
			
			case HAMMER :
				var n = Std.int(snake.length * 0.75);
				snake.cut(n, true, true);
				new fx.IncWidth( -50);
				
			case TENNIS_BALL :
				var max = 1 + Game.me.numCard(LADLE);
				for( i in 0...max ) new fx.TennisBall(i);
			
			case POTION_GREEN :
				for( o in snake.stomach ) o.sens = -1;
				
			case HONEYPOT :
				new fx.ExploSpawnFruit(snake.x, snake.y, Sugar, 10 );
				
			case SQUIRREL :
				Bonus.spawnRandom();
				
			case LOCK:
				Game.me.toggleFrutiLock();
			
			case SOUP :
				new fx.Soup();
				if ( Game.me.have(BUCKET) ) cdown >>= 1;
				
			
			case HORN :
				new fx.Horn(snake.x, snake.y);
				if ( Game.me.have(POTION_ORANGE) ) cdown -= 200;
				
			case BLACK_HOLE :
				new fx.BlackHole();
				if ( Game.me.have(GALAXY) ) cdown >>= 1;
				
			case WOT_WISP :		new fx.Wotp();
			case KAZOO :		new fx.FruitPath(snake.x, snake.y, snake.angle, Game.me.getRandomFruitRank(), 7-Game.me.numCard(AMPLI)*2 );
			case TONGUE :		new fx.Tongue();
			case GALAXY :		new fx.Retro();
			case EXIT :			new fx.Exit(0.3);
			case BOMB :			new fx.Bomb();
			case POISON : 		new fx.Poison();
			case MAGIC_HAT :	new fx.MagicHat();
			case SPONGE :		new fx.Sponge();
			case DIJONCTOURS :	new fx.Dijonctours();
			case CHAUSSON :		new fx.Chausson();
			case SOAP:			new fx.Soap();
			case FLAG:			fx.Flag.me.bet();
			
							
			default:
		}
		
		// COOLDOWN
		switch( cdown ) {
			case -2 :
			case -1 : flip();
			default : setCooldoown(cdown);
		}
		
	}

	public function removeAction() {
		mcKey.visible = false;
		Keyb.actions[key] = null;
	}
	
	public function setCooldoown(n) {
		//var n = data.time;
		cooldownMax = n;
		cooldown = n;
		if(mcKey != null) mcKey.visible = false;
	}
	function majDark() {
		if(mcDark == null){
			mcDark = new pix.Element();
			mcDark.y = -HEIGHT * 0.5;
			mcDark.alpha = 0.75;
			gfx.face.addChild(mcDark);
		}
		if ( cooldown > 0 ) {
			
			mcDark.visible = true;
			var fr = Gfx.main.get(0, "card_dark");
			fr.height = Math.round((cooldown / cooldownMax) * HEIGHT);
			//trace(fr.height);
			mcDark.drawFrame(fr,0.5,0);
		}
		else {
			mcDark.visible = false;
			if(mcKey != null) mcKey.visible = true;
			
		}
		
	}

	// ONDEATH
	public function onDeath() {
		var sn = Game.me.snake;
		
		if( !active ) return;
		switch(type) {
			case CHRONO :
				var min = 3;
				if ( Game.me.have(FOG) ) min++;
				if( Game.me.getTime() < min*60 * 1000 )  cash(Game.me.score);
				else flipOut();
				
			case CHEESE : cash(5000);
			case SOCKS : cash(Math.ceil(Game.me.score*0.15));
	
			default :
		}
		
	}
	public function cash(score,out=true) {
		fxUse();
		if( out ) flipOut();

		var spos = getStagePos();
		Game.me.incScore(score, spos.x,spos.y);
		
	}
	
	// TOOLS

	public function getStagePos() {
		return {
			x:sprite.x - Stage.me.root.x,
			y:sprite.y - Stage.me.root.y
		}
	}
	public function getDesc() {
		//return Lang.killLatin(Lang.CARD_DESC[Type.enumIndex(selection.card.type)].toUpperCase() )
		//return Data.CARDS[Type.enumIndex(type)]._desc;
		return Data.TEXT[Type.enumIndex(type)].desc;
	}

	
	// FX
	function updateKeyFlash() {
		if ( keyFlash == null ) return;
		var inc = Std.int(keyFlash * 255);
		keyFlash *= 0.5;
		if ( inc == 0 ) keyFlash = null;
		Col.setColor(mcKey, 0, inc);
		Col.setColor(mcKey, 0, inc);
	}
	public function fxUse() {
		new fx.Flash( sprite, 0.1 );
	}
	public function fxOver() {
		Filt.glow(gfx, 2, 10, 0xAAFF00, true);
	}
	public function fxOut() {
		gfx.filters = [];
	}
	

	


	
//{
}












