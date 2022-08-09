package world;
import mt.bumdum9.Lib;
import Protocole;

class FeverHead extends flash.display.Sprite {//}
	
	var base:pix.Element;
	var by:Float;
	var dec:Float;
	var tsink:Float;
	var sink:Float;
	var first:Bool;
	
	public function new(island:Island,sq:Square,seed:mt.Rand) {
		
		super();
		first = true;
		
		blendMode = flash.display.BlendMode.LAYER;
		x = (sq.x+1) * 16;
		y = sq.y * 16 +1;
		
		// BASE
		base = new pix.Element();
		base.drawFrame(Gfx.world.get(seed.random(4), "fever_head"),0.5,1);

		
		var bby = 8;
		var hh = 56;
		var mask = new flash.display.Sprite();
		mask.graphics.beginFill(0xFF0000,0.5);
		mask.graphics.drawRect(-16, bby, 32, hh);
		mask.graphics.endFill();
		mask.graphics.beginFill(0xFF0000,0.5);
		mask.graphics.drawEllipse(-16, hh+bby-8,32,16);
		
		mask.x = 0;
		mask.y = - hh;
		
		
		
		
		// ASSEMBLAGE
		base.mask = mask;
		addChild(base);
		addChild(mask);

		// WAVES
		
		for( i in 0...2 ) {
			var msq = island.grid[sq.x + i][sq.y];
			msq.feverHead = this;
			/*
			var p = new pix.Sprite();
			p.frameAlignX = 0;
			p.frameAlignY = 0;
			p.setAnim(Gfx.world.getAnim("waves_2"));
			p.x = (i-1)*16;
			p.y = 0;
			p.anim.goto( world.Island.getSynchro(msq.x,msq.y) );
			addChild(p);
			msq.pushOcean(p);
			*/
		}
		
		
		//
		by = base.y;
		dec = seed.rand() * 6.28;
		sink = 0;
		tsink = 0;
		
	}
	public function setSink(n) {
		tsink = n;
		if( first ) {
			first = false;
			sink = tsink;
			if( sink == 1 ) visible = false;
		}
	}
	
	public function update() {
		var loop = 128;
		var c = (World.me.timer % loop) / loop;

		var dc = Math.cos(dec + c * 6.28);
		base.y = Std.int(by + dc * 4 + sink*42);

		var ds = tsink - sink;
		sink += ds * 0.03;
		if( sink > 0.95 ) alpha-=0.01;
		if( alpha <= 0 ) visible = false;
	
	}
	

	
//{
}








