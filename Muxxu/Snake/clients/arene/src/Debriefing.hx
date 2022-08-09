import Protocole;
import mt.bumdum9.Lib;


class Debriefing extends flash.display.Sprite {//}
	
	static var WIDTH = 160;
	static var HEIGHT = 200;

	static var TEMPO = 3;
	
	static var WHITE  		= 0xFFFFFF;
	static var GREEN_LIGHT  = 0xFFFFFF;
	
	var cy:Int;
	var log:_GameLog;
	var data:_GEndReceive;
	var statId:Int;
	
	var dataReplay:String;
	var butReplay:But;
	var dm:mt.DepthManager;

	public function new(data, log:_GameLog, ?str:String) {
		dataReplay = str;
		this.data = data;
		this.log = log;
		super();
		
		Game.me.dm.add(this, 3);
		dm = new mt.DepthManager(this);
		
		if( data._err < 0 ) {
			var f = Cs.getField(0xFFFFFF,8,-1,"nokia");
			dm.add(f, 0);
			f.multiline = true;
			f.wordWrap = true;
			f.width = HEIGHT;
			switch(data._err) {
				case -1 :	f.text = "Le tournoi s'est terminé avant la fin de votre partie.\nCe score ne peut être enregistré.";
			}
			f.x = (Cs.mcw - f.width) * 0.5;
			f.y = (Cs.mch - f.textHeight ) * 0.5;
			return;
		}
		


		// PALLETE
		var white = 0xFFFFFF;
		var gr0 = Gfx.col("green_0");
		var gr0b = Col.brighten(gr0, 20);
		var gr0b = Col.desaturate(gr0b, 0.1);
		var gr1 = Gfx.col("green_1");
		var gr1b = Col.brighten(gr1, 20);
		var gr2 = Gfx.col("green_2");
		var gr2b = Col.brighten(gr2, 20);
		GREEN_LIGHT = Col.brighten(Gfx.col("green_0"), 50);
		
		// POS
		x = (Cs.mcw - WIDTH) * 0.5;
		y = (Cs.mch - HEIGHT) * 0.5;
		cy = 7;
		
		// BG
		graphics.beginFill(Gfx.col("green_0"));
		graphics.drawRect(0, 0, WIDTH, HEIGHT);
	
		
		// STATS
		statId = 0;
		step = 1;
		timer = 0;
		
	
	}
	function band(y, h) {
		var gr0 = Gfx.col("green_0");
		var gr0b = Col.brighten(gr0, 20);
		gr0b = Col.desaturate(gr0b, 0.1);
		graphics.beginFill(gr0b);
		graphics.drawRect(0, y, WIDTH, h);
	}

	function displayScore() {
		step++;
		timer = 5;
		
		var f = Cs.getField(WHITE, 20, -1, "upheavel");
		dm.add(f,0);
		f.y = cy;
		f.text = Std.string(log.score);
		f.filters = [new flash.filters.DropShadowFilter(1, 90, Gfx.col("green_1"), 1, 0, 0, 1)];
		center(f);
		band(f.y + 4, 16);
		cy += 25;
		
		flashRect(0, f.y+4, WIDTH, 16);
		
	}
	function displayNextStat() {
		
		var id = statId++;
		
		var time = Cs.formatTime(log.chrono);
		var fruits = Std.string(log.fruits.length);
		var fbar = Std.string( Std.int(log.frutipowerMax) ) + "%";
		var length =  Std.string(Std.int(log.lengthMax)) + Lang.LENGTH_UNIT;
		var value = [time,fruits,fbar,length];
		
		var title = Cs.getField(GREEN_LIGHT, 8, -1);
		title.x = 0;
		title.y = cy;
		title.width = WIDTH;
		title.text = Lang.STATS[id];
		
		var val = Cs.getField(WHITE, 8, 1);
		val.x = 0;
		val.y = cy;
		val.width = WIDTH;
		val.text = value[id];
		
		dm.add(title,0);
		dm.add(val,0);

		// FX
		flashRect(0, cy + 2, WIDTH, 8);
		
		//
		cy += 8;
		
	}
	
	// PROGRESSION
	var work:Array<pix.Sprite>;
	var maxElement:Int;
	function displaySection(name,max) {
		// TITLE
		cy += 18;
		setTitle(name);
		cy += 27;
		
		// BAND
		band(cy - 8,16);
		
		// INIT
		step++;
		timer = 0;
		work = [];
		
		//FX
		flashRect(0, cy - 8, WIDTH, 16);
		
		
		maxElement = max;
		
	}
	
	function addFruit() {
		var o = data._progression.shift();
		var sp = new pix.Sprite();
		sp.drawFrame(Gfx.fruits.get(o._id));
		//
		var f = Cs.getField(0xFFFFFF, 8, -1, "nokia");
		f.text = Lang.UP_LEVEL +(o._lvl);
		//f.text = "niv." +(o._lvl);
		sp.addChild(f);
		f.x = -12;
		f.y = 11;
		
		var col = [Gfx.col("green_2"),0xFFAA00,Gfx.col("red_0"),0xBB0088,0x0066CC][o._lvl-1];
		f.filters = [new flash.filters.GlowFilter(col, 1, 2, 2, 100)];
		//
		if( maxElement > 6 ) f.y += (work.length % 2) * 8;
		//
		majElement(sp);
	}
	function addBonus() {
		var id = log.bonus.shift();
		var sp = new pix.Sprite();
		sp.drawFrame(Gfx.bonus.get(Type.enumIndex(id)));
		majElement(sp);
	}
	function majElement(sp:pix.Sprite) {
		sp.y = cy;
		dm.add(sp,0);
		work.push(sp);
		centerFruits(work);
		
		// FX FLASH
		var fx = new fx.Flash(sp,0.05,1);
		fx.glow(3, 8);
		
		// FX PARTS
		var dec = 50;
		var max = 8;
		var cr = 4;
		for( i in 0...max ) {
			var c = i / max;
			var p = Part.get();
			p.sprite.setAnim(Gfx.fx.getAnim("spark_dust"));
			dm.add(p.sprite, 2);
			p.launch( c * 6.28, Math.random()*1, 0);
			p.timer = 15 + Std.random(20);
			p.frict = 0.95;
			p.x = p.vx*cr + sp.x;
			p.y = p.vy*cr + sp.y+dec;
			p.z = -dec;
			p.weight = 0.03+Math.random()*0.05;
			p.sprite.anim.gotoRandom();
			
			p.sprite.blendMode = flash.display.BlendMode.ADD;
			Filt.glow(p.sprite, 4, 1, 0xFFFFFF);
			
		}
		
	}
	
	// UPDATE
	var step:Int;
	var timer:Int;
	public function update() {
		
		switch(step) {
			case 1:
				if( timer-- <= 0 ) displayScore();
			case 2:
				timer--;
				if( timer <= 0 ) {
					timer = TEMPO;
					displayNextStat();
					if(statId == 4) {
						cy -= 10;
						displaySection(Lang.BONUS,log.bonus.length);
					}
				}
			case 3:
				timer--;
				if( timer <= 0 ) {
					timer = TEMPO;
					if( log.bonus.length == 0 ) displaySection(Lang.ENCYLOPEFRUIT_PROGRESSION,data._progression.length);
					else addBonus();
					
					
				}
			case 4:
				timer--;
				if( timer <= 0 ) {
					timer = TEMPO;
					if( data._progression.length == 0 ) endDisplay();
					else addFruit();
				}
			case 5:
				//butBeta.update();
				butReplay.update();
		}
	}
	
	//
	function endDisplay() {
		step++;
		butReplay = getBut(Lang.PLAY_AGAIN,replay);
	}
	function getBut(str,f) {
		
		var but = new But(str, f );
		dm.add(but,0);
		but.y = HEIGHT-20;
		but.x = Std.int(WIDTH * 0.5);
		flashRect(but.x - but.width * 0.5, but.y, but.ww, but.hh);
		return but;
	}
	
	// ACTION : REPLAY
	function replay() {
		if( dataReplay != null ) {
			flash.system.System.setClipboard(dataReplay);
			trace("copy dataReplay !");
			return;
		}
		var url = new flash.net.URLRequest(Main.domain);
		flash.Lib.getURL(url,"_self");
	}
	
	// FX
	function flashRect(x,y,w,h) {
		var p = Part.get();
		var gfx = p.sprite.graphics;
		gfx.beginFill(0xFFFFFF);
		gfx.drawRect(0, 0, w, h);
		p.x = x;
		p.y = y;
		p.timer = 10;
		p.fadeType = 1;
		p.sprite.blendMode = flash.display.BlendMode.ADD;
		addChild(p.sprite);
	}
	
// TOOLS
	function center(f:flash.text.TextField, ?cx) {
		if( cx == null ) cx = WIDTH * 0.5;
		f.width = f.textWidth + 3;
		f.x = Std.int(cx - f.width * 0.5);
	}
	function centerFruits(a:Array<pix.Sprite>) {
		
		var max = maxElement;
		
		var ma = 18;
		var ec = 0.0;
		if(max > 1) ec = (WIDTH - 2 * ma) / (max - 1);
		ec = Math.min( ec, 32);
		var id = 0;
		for( f in a ) {
			f.x = WIDTH * 0.5 + (id + 0.5 - max * 0.5) * ec;
			f.pxx();
			id++;
		}
	}
	function setTitle(name) {
		var f = Cs.getField(WHITE, 8, -1, "nokia");
		addChild(f);
		f.y = cy;
		f.text = name;
		center(f);
		
		var shade = new flash.filters.DropShadowFilter(1, 90, Gfx.col("green_1"), 1, 0, 0, 1);
		f.filters = [shade];
		
	}
	
//{
}











