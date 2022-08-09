package fx;
import Protocole;
import mt.bumdum9.Lib;

class Dijonctours extends Fx {//}
	

	public function new() {
		super();
		
		var a = Game.me.fruits.copy();
		
		for( fr in a ) {
			var rank = Game.me.getRandomFruitRank();
			if( fr.has(Shit) ) {
				burstShit(fr);
				continue;
			}
			var nfr = Fruit.get(rank);
			nfr.setPos( fr.x, fr.y, fr.z );
			nfr.launch(Game.me.seed.rand() * 6.28, Game.me.seed.rand(), -(Game.me.seed.rand() + 1.5));
			var ray = 16;
			new fx.Volt(nfr.sprite, ray, ray, 0.05 );
			new fx.Flash(nfr.sprite, 0.1);
			fr.kill();
		}
		kill();
		
	}
	
	public function burstShit(fr) {
		fr.kill();
		
		var sc = 1 + Math.random() * 0.5;
		sc = 1;
		
		var p = new pix.Element();
		p.drawFrame(Gfx.fx.get(0, "blood"));
		p.x = fr.x;
		p.y = fr.y;
		Stage.me.ground.addChild(p);
		var bmp = Stage.me.gore.bitmapData;
		var m = new flash.geom.Matrix();
		var mx = Std.random(2)*2-1;
		var my = Std.random(2)*2-1;
		m.scale(sc*mx, sc*my);
		m.translate(p.x, p.y);
		bmp.draw(p, m, new CT(0,0,0,1,90+Std.random(40),50+Std.random(30),0) );
		//Col.setPercentColor(p, 1, 0x804000);
		p.kill();
		Stage.me.renderBg(p.getBounds(Stage.me.bg));
		
		var max = 8;
		for( i in 0...max ) {
			var a = 6.28 * i / max;
			var sp = Math.random() * 2.5;
			var p = part.BloodDrop.get();
			//p.setColor(Col.shuffle(0xCCBB00,30));
			p.setColor(Col.shuffle(0x887700,30));
			//p.setColor(0x00FFFF);
			p.x = fr.x;
			p.y = fr.y;
			p.vx = Snk.cos(a) * sp;
			p.vy = Snk.sin(a) * sp;
			p.vz = -(1+Math.random()*2);
		}

	}
	
	
//{
}












