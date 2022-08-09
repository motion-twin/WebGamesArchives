package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

class Rune extends CardFx {//}

	static var COLORS = [0xec5e60,0x4d7afd,0xe34d02,0x9B00F4];
	static var LIST:Array<Rune> = [];
	
	var count:Int;
	var step:Int;
	var type:Int;
	var runes:Array<pix.Element>;
	public var rune:pix.Element;
	
	
	
	public function new(ca, type) {
		
		super(ca);
		this.type = type;
		count = 10;
		step = 0;
		//
		init();
		LIST.push(this);
		
	}
	
	override function update() {
		super.update();
		switch(step) {
			case 0:
				if( Game.me.have(PICK_AXE) ) count--;
				if( count-- <= 0 )	light();
			
			case 1:
				var dx = sn.x - rune.x;
				var dy = sn.y - rune.y;
				if( Math.sqrt(dx * dx + dy * dy) < 20 ) grab();
		}


		
	}
	
	function init() {
		
		var pos = getFreePos();
		var dd = Math.sqrt(2);
		dd = 1;
		runes = [];
		for( i in 0...3 ){
			var rune = new pix.Element();
			runes.push(rune);
			rune.drawFrame(Gfx.fx.get(type,"runes"));
			rune.x = pos.x;
			rune.y = pos.y;
			
			switch(i) {
				case 0 :
					Stage.me.ground.addChild(rune);
					rune.visible = false;
				case 1 :
					Stage.me.relief.addChild(rune);
					rune.filters  = [new flash.filters.DropShadowFilter(dd, 225, 0, 1, 0, 0, 1, 0, false, true, true)];
				case 2 :
					Stage.me.relief.addChild(rune);
					rune.filters  = [new flash.filters.DropShadowFilter(dd, 45, 0xFFFFFF, 1, 0, 0, 1, 0, false, true, true)];

					
			}
		}
		rune = runes[0];
		render();
	}

	function getFreePos() {
		while(true){
			var p = Stage.me.getRandomPos(12);
			var ok = true;
			for( o in LIST ) {
				var dx = o.rune.x - p.x;
				var dy = o.rune.y - p.y;
				if( Math.sqrt(dx * dx + dy * dy) < 20 ) {
					ok = false;
					break;
				}
			}
			if( ok ) return p;
		}
		return null;
	}
	
	function light() {
		rune.visible = true;
		//new Flash(rune, 0.02);
		step++;
		render();
		
		var p = new pix.Part();
		p.setPos( rune.x, rune.y);
		p.timer = 10;
		p.fadeType = 1;
		p.drawFrame(Gfx.fx.get(type, "runes"));
		Stage.me.dm.add(p, Stage.DP_RELIEF);
		Col.setPercentColor(p, 1, 0xFFFFFF);
		
	}
	
	function grab() {
		
		rune.visible = false;
		render();
		step = 0;
		
		
		switch(type) {
			case 0 :
				Game.me.incFrutipower(3);
				count = Game.me.seed.random(800) + 800;
			case 1 :
				new fx.Reduce(20, 2);
				count = Game.me.seed.random(300) + 300;
				
			case 2 :
				var sc = 500;
				sc += Game.me.numCard(SCISSOR) * 100;
				if( Game.me.have(BIG_SCISSOR) ) sc *= 2;
				Game.me.incScore(sc, rune.x, rune.y);
				count = Game.me.seed.random(100) + 100;
				
			case 3 :
				var a = Game.me.fruits.copy();
				for ( f in a ) f.evolve( (Game.me.have(PIN)?12:3) +Game.me.seed.random(2) );
				count = Game.me.seed.random(100) + 100;
				
		}
		
		
		// FX
		var max = 32;
		var cr = 2;
		for( i in 0...max ) {
			var speed = Math.random() * 3;
			var an  = i * 6.28 / max;
			var p = Part.get();
			p.sprite.drawFrame(Gfx.fx.get("cross"));
			Stage.me.dm.add(p.sprite, Stage.DP_UNDER_FX);
			p.vx = Snk.cos(an)*speed;
			p.vy = Snk.sin(an)*speed;
			p.vz = -Math.random() * 3;
			p.setPos( rune.x + p.vx * cr, rune.y + p.vy * cr );
			p.frict = 0.92;
			p.sleep = Std.random(6);
			p.sprite.visible = false;
			p.timer = 10 + Std.random(20);
			
			p.weight = (0.5 + Math.random()) * 0.25;
			p.ray = 1;
			p.dropShade(false);
			
			Col.setColor(p.sprite, Col.shuffle(COLORS[type], 40));
			
		}
		//
		for( i in 0...2 ) {
			var onde = new mt.fx.ShockWave(20+i*10, 40+i*40,0.1+i*0.1);
			onde.setPos( rune.x, rune.y);
			Stage.me.dm.add(onde.root, Stage.DP_UNDER_FX);
		}
		
		
	}
	
	function render() {
		Stage.me.renderBg( runes[0].getBounds(Stage.me.bg) );
	}
	
	override function kill () {
		LIST.remove(this);
		while( runes.length > 0 ) runes.pop().kill();
		super.kill();
	}
	
	
	
//{
}












