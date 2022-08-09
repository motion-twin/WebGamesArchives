package mt.fx;
import mt.bumdum9.Lib;

import flash.display.GradientType;

class ShockWave extends mt.fx.Part<SP> {//}

	

	var spc:Float;
	var fadeStart:Float;
	var min:Float;
	var max:Float;
	var scy:Float;
	
	public var colors:Array<UInt>;
	public var alphaRatio:Float;
	
	var hole: {  centerCoef:Float };
	
	public function new(min,max,spc=0.1, fadeStart=0.0, scy=1.0 ) {

		super(new SP());
		this.min = min;
		this.max = max;
		this.spc = spc;
		this.fadeStart = fadeStart;
		this.scy = scy;
		
		colors = [0xFFFFFF, 0xFFFFFF];
		alphaRatio = 0.5;
		curveIn(0.5);
		draw();
		maj(0);
		
	}


	public function setHole(coef=1.0) {
		hole = { centerCoef:coef };
	}
		
	public function draw() {
		
		var gfx = root.graphics;
		gfx.clear();
		
		if( colors.length > 1 ){
			var m = new flash.geom.Matrix();
			m.createGradientBox( 100, 100, 0, -50, -50);
			gfx.beginGradientFill(RADIAL, colors, [0, 1], [Std.int(alphaRatio* 0xFF), 0xFF], m);
		}else {
			
			gfx.beginFill(colors[0]);
		}
		
		
		var ray = 50;
		gfx.drawCircle(0, 0, ray);

		
		if( hole != null ) {
			var co = curve(coef);
			var hray = ray * co;
			var dist = (ray - hray) * (1 - hole.centerCoef);
			gfx.drawCircle(dist, 0, hray);
		}
		

	}
	
	
	
	override function update() {
		super.update();

		coef = Math.min(coef + spc, 1);
		
		if( hole != null ) 	draw();
		
		maj( coef );
		if( coef == 1 ) kill();
	}
	
	function maj(c:Float) {
		
		var co = curve(coef);
		root.scaleX = (min + (max - min) * co) * 0.01;
		root.scaleY = root.scaleX * scy;
		if( co > fadeStart) {
			var c = (c - fadeStart) / (1 - fadeStart);
			root.alpha = (1 - c)*alpha;
		}
		
	}
	

	
	
	
	

	
//{
}


