import mt.bumdum.Phys;
import mt.bumdum.Lib;

class Option extends Phys {//}

	public static var AIMANT = 		0;
	public static var BLINDAGE = 		1;
	public static var COLLE =		2;
	public static var DIMINUTION =		3;
	public static var EXTENSION =		4;
	public static var FLAMME =		5;
	public static var GLACE =		6;
	public static var HALO =		7;
	public static var INDIGESTION =		8;
	public static var JAVELOT =		9;
	public static var KAMIKAZE =		10;
	public static var LASER =		11;
	public static var MULTIBALL =		12;
	public static var NOUVELLE_BALLE =	13;	// 	SWAP ( COLOR )
	public static var OUVRE =		14;
	public static var PROVISION =		15;
	public static var QUASAR =		16;
	public static var RALLENTISSEMENT =	17;
	public static var SAUVETAGE =		18;	// 	SWAP
	public static var TRANSFORMEUR =	19;
	public static var ULTRA_VIOLET =	20;
	public static var VOLT =		21;
	public static var WHISKY =		22;
	public static var XANAX =		23;
	public static var YOYO =		24;	// 	:-/
	public static var ZELE =		25;



	public static var SUM = 0;
	public static var FALL_SPEED = 3;
	public static var PROB = [
		5,	// A IMANT
		1,	// B LINDAGE
		12,	// C OLLE
		10,	// D IMINUTION
		30,	// E XTENSION
		10,	// F LAMME
		7,	// G LACE
		5,	// H ALO
		5,	// I DISGESTION
		10,	// J AVELOT
		0.5,	// K AMIKAZE
		5,	// L ASER
		36,	// M ULTIBALL
		15,	// N OUVELLE BALLE
		3,	// O UVERTURE
		0,	// P ROVISION
		2,	// Q UASAR
		2,	// R EGENERATION
		3,	// S AUVETAGE
		10,	// T RANSFORMEUR
		0,	// U LTRAVIOLET
		10,	// V OLT
		2,	// W HISKY
		5,	// X ANAX
		1,	// Y OYO
		5,	// Z ELE
	];

	public var id:Int;
	public var flItem:Bool;
	public var color:Int;
	static public var prob:Array<Float>;

	var sdm:mt.DepthManager;

	var skin:{>flash.MovieClip, scroll:{>flash.MovieClip, field:flash.TextField,icon:flash.MovieClip}};

	public function new(mc){
		super(mc);
		Game.me.options.push(this);
		vy = FALL_SPEED ;
		skin = cast root;


	}

	static public function getRandomId(seed){
		//if( SUM==0 )for( n in PROB )SUM+=Std.int(n*100);
		var rnd = seed.random(SUM);
		var sum = 0;
		for( i in 0...prob.length ){
			sum+=Std.int(prob[i]*10);
			if(sum>rnd)return i;
		}
		return null;
	}

	static public function genProb(level:Level){

		prob = PROB.copy();

		// PROVISION

		prob[PROVISION] = Num.mm( 10, 10-level.dst*0.5 , 0.3 );
		//if( Cs.pi.missileMax == 0 ) prob[PROVISION]=0;

		// EASY START
		if( level.dst < 3 ){
			prob[DIMINUTION] = 0;
			prob[WHISKY] = 0;
			prob[BLINDAGE] = 0;
			prob[ZELE] = 0;
			prob[YOYO] = 0;
			prob[INDIGESTION] = 0;
			prob[HALO] = 0;

		}
		//trace("DST:"+level.dst);
		if( level.dst < 4 )	prob[FLAMME] = 0;
		if( level.dst < 5 )	prob[PROVISION] = 0;
		if( level.dst < 6 )	prob[VOLT] = 0;
		if( level.dst < 8 )	prob[TRANSFORMEUR] = 0;
		if( level.dst < 10 )	prob[GLACE] = 0;


		// SUM
		SUM = 0;
		for( n in prob )SUM+=Std.int(n*10);

	}

	public function setType(n){
		/*
		if(n==null){
			n = getRandomId();
			while( isBad(n) && Game.me.level.lvl==0 )n = getRandomId();
		}
		*/

		id = n;


		// COLOR
		var col = getCol(id);
		Col.setColor(skin.smc,col);
		Col.setColor(skin.scroll.smc,col);
		//Col.setColor(cast skin.scroll.field,col);
		var o = Col.colToObj(col);
		var inc = -200;
		o.r = Std.int(Math.max(o.r+inc,0));
		o.g = Std.int(Math.max(o.g+inc,0));
		o.b = Std.int(Math.max(o.b+inc,0));

		Filt.glow(cast skin.scroll.field,2,20,0xFFFFFF);
		color = col;

		if(n<26){
			skin.scroll.stop();
			skin.scroll.field.text = String.fromCharCode(65+n).toUpperCase();
			skin.scroll.field.textColor = Col.objToCol(o);
		}else{

			skin.scroll.gotoAndStop(2+(n-26));
			switch(n){
				case 26:	// MISSILE
					skin.scroll.icon.gotoAndStop(Game.me.missileType+1);
			}

			Filt.glow(root.smc,2,4,0xFFFFFF);
		}

		//



	}
	public function setItem(n){
		Game.me.flItemFall = true;
		id = n;
		flItem = true;
		skin.scroll.gotoAndStop(id+1);

		sdm = new mt.DepthManager(root.smc);
		root.smc.blendMode = "add";
		for( i in 0...16 )newRay();

		Game.me.dm.over(root);
		Filt.glow(root.smc,10,2,0xFFFFFF);
		Filt.glow(skin.scroll,5,2,0xFFFFFF,true);
		Filt.glow(skin.scroll,10,2,0xFFFFFF);

		//skin.scroll._xscale = skin.scroll._yz = 150;

	}

	override public function update(){
		super.update();



		//
		if(flItem){
			newRay();
		}else{
			// SCROLL
			skin.scroll._y += mt.Timer.tmod;
			if( skin.scroll._y > -5 )skin.scroll._y-= 26;
		}

		// COLS
		if( Math.abs(y-(Game.me.pad.y+Cs.BH*0.5))<Cs.BH && Math.abs(x-Game.me.pad.x)<Game.me.pad.ray+Cs.BW*0.5 ){
			apply();
		}

		if( y > Cs.mch + 30 )kill();


	}
	function apply(){

		// PARTS
		var max = Std.int(24*Cs.PREF_GFX);
		for( i in 0...max ){
			var p = new fx.LineUp(Game.me.dm.attach("partLineUp",Game.DP_PARTS));
			p.y = y + (Math.random()*2-1)*Cs.BH*0.5;
			p.x = x + (Math.random()*2-1)*Cs.BW*0.5;
			//p.vx = ((Std.random(2)*2-1)*(h-Math.abs(p.y-y)))*0.5;
			p.vx = (Math.random()*2-1)*5;
			p.factor = 8;
			p.timer = 10+Math.random()*10;
			p.frict = 0.9;


		}

		var mc = Game.me.dm.attach("mcOnde",Game.DP_UNDERPARTS);
		mc._x = x;
		mc._y = y;



		if(flItem){
			Game.me.flItemCollected = true;
			Game.me.newTitle(Text.get.ITEM_NAMES[id].toUpperCase(), 0x000044, null, 60 );
		}else{
			Game.me.getOption(id);
		}
		kill();
	}

	// FX
	function newRay(){
		var sp = new Phys(sdm.attach("mcRayWaveGrow",0));
		sp.vr = (Math.random()*2-1)*1.5;
		//sp.fr = 0.95;
		sp.root._rotation = Math.random()*360;
		sp.root._xscale = 30+Math.random()*40;
		sp.root._yscale = sp.scale = 40;
		sp.root._alpha = 50;
		sp.timer = 10+Math.random()*20;
		sp.fadeType = 3;
		sp.updatePos();

	}

	//
	override public function kill(){
		if(flItem)Game.me.flItemFall = false;
		Game.me.options.remove(this);
		super.kill();
	}

	public static function getCol(id){
		if(id>=26)return 0x444466;

		var co = Col.getRainbow(id/26);
		co.r = Std.int( Math.max(co.r-(id%3)*50, 0));
		co.g = Std.int( Math.max(co.g-(id%3)*50, 0));
		co.b = Std.int( Math.max(co.b-(id%3)*50, 0));
		return Col.objToCol(co);
	}
	public static function isBad(id){
		return id == 1 || id == 3 || id == 6 || id == 8 || id == 13 || id == 22 || id == 23 || id == 25;
	}





//{
}













