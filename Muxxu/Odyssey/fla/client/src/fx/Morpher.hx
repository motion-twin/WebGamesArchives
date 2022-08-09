package fx;
import mt.bumdum9.Lib;

class Morpher extends mt.fx.Fx{//}

	public var morph:flash.display.BitmapData;
	public var screen:SP;
	
	public var bmp:flash.display.BitmapData;
	public var zoom:Float;
	public var dis:flash.filters.DisplacementMapFilter;
	
	public var fadeCoef:Float;
	public var fadeSpc:Null<Float>;
	
	public function new(z) {
		super();
		zoom = z;
	
		// BMD
		bmp = new flash.display.BitmapData(Std.int(Cs.mcw/zoom), Std.int(Scene.HEIGHT/zoom), false, 0xFF0000);
		screen = new SP();
		screen.scaleX = screen.scaleY = zoom;
		screen.addChild( new flash.display.Bitmap(bmp) );
		//Scene.me.dm.add(screen, Scene.DP_BG );
		//Scene.me.bg.addChild(screen);
				
		// MORPH
		morph = bmp.clone();

		// DRAW BG
		var m = new flash.geom.Matrix();
		m.scale(1/zoom,1/zoom);
		bmp.draw(Scene.me.bg, m);
		
		// DISPLACEMENT
		dis = new flash.filters.DisplacementMapFilter( morph, new flash.geom.Point(0, 0), 1,2, 1, 1, flash.filters.DisplacementMapFilterMode.CLAMP );
		
		//
		coef = 0;
		fadeCoef = 1;
		
		//
		Scene.me.bg.addChild(screen);
		
		
	}
	
	override function update() {
		super.update();
		if( fadeSpc != null ) {
			fadeCoef = Math.max(fadeCoef - fadeSpc, 0);
			if( fadeCoef == 0 ) kill();
		}
	}
	
	
	public function fade(spc) {
		fadeSpc = spc;
	}
	override function kill() {
		screen.parent.removeChild(screen);
		morph.dispose();
		bmp.dispose();
		super.kill();
	}
	
	
	// DEBUG
	public function showMorph() {
		Scene.me.dm.add( new flash.display.Bitmap(morph), Scene.DP_BG );
	}
	
//{
}










