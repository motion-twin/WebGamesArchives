package fx;
import mt.bumdum9.Lib;
import mt.bumdum9.Rush;
import Protocol;

class Score extends mt.fx.Part<SP> {//}

	static var GRADIENT:BMD;
	var color:Int;

	public function new(x,y,score:Int) {
		var mc = new SP();
		Game.me.dm.add(mc,Game.DP_FX);
		super(mc);
	
		setPos(x, y);
		vy = -3.5;
		frict = 0.8;
		timer = 40;

		
		if( GRADIENT == null ) {
			var gr = new gfx.ScoreGradient();
			GRADIENT = new BMD( 100, 10, false, 0xFF0000 );
			GRADIENT.draw(gr);
		}
		
		//var color = Col.hsl2Rgb(x*2 / Cs.WIDTH,1,0.25);
		
		
		var gx = Std.int(Num.mm(0,(score-30)*0.75,100));
		color = GRADIENT.getPixel(gx, 5);

		var f = TField.get(Col.brighten(color, -100), 22, "coaster");
		root.addChild(f);
		f.text = Std.string(score);
		
		Filt.glow(f, 4, 2, color, true);
		Filt.glow(f, 2, 6, 0xFFFFFF);
		
		
		f.x = - f.textWidth * 0.5;
		f.y = -12;
		f.width = 80;
		f.height = 40;
		
		fadeType = 2;
		fadeLimit = 16;
		
		
	
	}
	
	override function update() {
		super.update();
		if( Game.me.gtimer % 3 != 0 ) return;
		
		//var mc = new gfx.Spark();
		//mc.gotoAndPlay(Std.random(mc.currentFrame));
		var mc = new gfx.LightTriangle();
		//mc.blendMode = flash.display.BlendMode.ADD;
		//Col.setPercentColor(mc, 0.75, [0xFF0000,0xCC00FF,0x4400FF][Std.random(3)]);
		Filt.glow(mc, 4, 1, color);
		
		var ec = 10*scale;
		var p = new mt.fx.Part( mc );
		p.setPos(x+(Math.random()*2-1)*ec,y+4+(Math.random()*2-1)*ec);
		Game.me.dm.add(p.root, Game.DP_FX);
		p.weight = -(0.05 + Math.random() * 0.1);
		p.frict = 0.98;
		p.timer = 16;
		p.twist(10, 0.98);
		p.setScale(Math.random() + 0.5);

		p.fadeType = 2;

	}

}












