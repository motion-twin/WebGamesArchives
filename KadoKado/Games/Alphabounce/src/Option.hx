import mt.bumdum.Phys;
import mt.bumdum.Lib;

class Option extends Phys {//}

	public static var FALL_SPEED = 3;
	public static var PROB = [
		4,	// A IMANT
		1,	// B LINDAGE
		12,	// C OLLE
		10,	// D IMINUTION
		30,	// E XTENSION
		10,	// F LAMME
		7,	// G LACE
		5,	// H ALO
		3,	// I NVERSION
		10,	// J AVELOT
		0.5,	// K AMIKAZE
		5,	// L ASER
		36,	// M ULTI-BALL
		6,	// N ERVEUX
		4,	// O UVRE
		3,	// P ROTECTION
		2,	// Q UASAR
		5,	// R ALLENTISSEMENT
		5,	// S AUVETAGE
		10,	// T EMPORALITE
		0.5,	// U NIFICATION
		2,	// V AGUE
		2,	// W HISKY
		1,	// X ENOPHOBIE
		1,	// Y OYO
		5,	// Z ELE
	];

	public var id:Int;
	public var color:Int;
	var skin:{>flash.MovieClip, scroll:{>flash.MovieClip, field:flash.TextField}};

	public function new(mc){
		super(mc);
		Game.me.options.push(this);
		vy = FALL_SPEED ;
		skin = cast root;
	}

	function getRandomId(){
		var sum:Int = 0;
		for( n in PROB )sum+=Std.int(n*10);
		var rnd = Std.random(sum);
		sum = 0;
		for( i in 0...PROB.length ){
			sum+=Std.int(PROB[i]*10);
			if(sum>rnd)return i;
		}
		return null;

	}
	public function setType(n){
		if(n==null){
			n = getRandomId();
			while( isBad(n) && Game.me.lvl==0 )n = getRandomId();
		}
		id = n;
		skin.scroll.field.text = String.fromCharCode(65+n).toUpperCase();

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
		skin.scroll.field.textColor = Col.objToCol(o);
		Filt.glow(cast skin.scroll.field,2,20,0xFFFFFF);
		color = col;


	}

	override public function update(){
		super.update();

		// SCROLL
		skin.scroll._y += 1;
		if( skin.scroll._y > -5 )skin.scroll._y-= 26;

		// COLS
		if( Math.abs(y-(Game.me.pad.y+Cs.BH*0.5))<Cs.BH && Math.abs(x-Game.me.pad.x)<Game.me.pad.ray+Cs.BW*0.5 ){
			apply();

		}

	}
	function apply(){
		//
		//Game.me.pad.powerUp();
		///
		// PARTS
		for( i in 0...16 ){
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

		Game.me.getOption(id);
		kill();
	}

	//
	override public function kill(){
		Game.me.options.remove(this);
		super.kill();
	}

	public static function getCol(id){
		var co = Col.getRainbow(id/26);
		co.r = Std.int( Math.max(co.r-(id%3)*50, 0));
		co.g = Std.int( Math.max(co.g-(id%3)*50, 0));
		co.b = Std.int( Math.max(co.b-(id%3)*50, 0));
		return Col.objToCol(co);
	}

	public static function isBad(id){
		return id == 1 || id == 3 || id == 6 || id == 8 || id == 13 || id == 22 || id == 23 || id == 25;
	}








	public static var NAMES = [
		"AIMANT",
		"BLINDAGE",
		"COLLE",
		"DIMINUTION",
		"EXTENSION",
		"FLAMME",
		"GLACE",
		"HALO",
		"INVERSION",
		"JAVELOT",
		"KAMIKAZE",
		"LASER",
		"MULTI-BALL",
		"NERVEUX",
		"OUVRE",
		"PROTECTION",
		"QUASAR",
		"RALLENTISSEMENT",
		"SAUVETAGE ACTIF",
		"TEMPORALITE",
		"UNIFICATION",
		"VAGUE",
		"WHISKY",
		"XENOPHOBIE",
		"YOYO",
		"ZELE"
	];

//{
}













