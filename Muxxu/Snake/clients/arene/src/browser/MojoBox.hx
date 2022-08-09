package browser;
import Protocole;
import mt.bumdum9.Lib;

class MojoBox extends pix.Element { //}
	
	static public var WIDTH = 76;
	static public var HEIGHT = 62;
	static public var SPEED = 16;
	
	public var over:Bool;

	public var tween:Tween;
	var coef:Float;
	var spc:Float;
	
	//var but:flash.display.Sprite;
	
	var field:flash.text.TextField;
	var desc:flash.text.TextField;
	var play:flash.text.TextField;

	
	public function new() {
		super();
		Browser.me.dm.add(this, 2);
		
		x = (Cs.mcw - WIDTH) * 0.5;
		y = Browser.me.getHandY();
	
		// FIELDS
		var f = Cs.getField(0xFFBBBB, 8, -1, "nokia");
		addChild(f);
		f.wordWrap = true;
		f.multiline = true;
		f.x = 1;
		f.y = 3;
		f.text = Lang.MOJO_LEFT;
		f.width = WIDTH - 1;
		f.height = 32;
		f.filters = [ new flash.filters.GlowFilter(Gfx.col("red_1"), 1, 2, 2, 40)];
		desc = f;
		
		var f = Cs.getField( Gfx.col("green_2"), 16, -1, "nokia");
		addChild(f);
		f.y = 17;
		f.text = Lang.PLAY;
		f.width = f.textWidth + 3;
		f.x = Std.int((WIDTH - f.width) * 0.5);
		f.filters = [ new flash.filters.GlowFilter(Gfx.col("green_0"), 1, 4, 4 , 40)];
		play = f;
		
		var f = Cs.getField(0xFFBBBB, 40, 0, "upheavel");
		addChild(f);
		f.y = 12;
		f.text = "6";
		f.width = WIDTH;
		var tf = f.getTextFormat();
		field = f;
		
		//
		ready = true;
		setReady(false);
		//
		setValue(6);
		
	}
	
	public function update() {
		
		if( tween != null ) {
			coef = Math.min(coef + spc, 1);
			var p = tween.getPos(coef);
			x = p.x;
			y = p.y;
			if( coef == 1 ) {
				tween = null;
			}
		}
		
		
		var xm = (mouseX - x) * 0.5;
		var ym = (mouseY - y) * 0.5;
		over = xm > 0 && xm < WIDTH && ym > 0 && ym < HEIGHT;
		
		
		if( ready ){
			filters = [];
			blendMode = flash.display.BlendMode.NORMAL;
			alpha = 1;
			if( over ) {
				blendMode = flash.display.BlendMode.ADD;
				alpha = 0.6;
				Filt.glow(this, 8, 1, 0xFFFFFF);
			}
		}
		
		
		
	}
	
	public function moveTo(ex:Float, ey:Float) {
		var dx = ex - x;
		var dy = ey - y;
		var dist = Math.sqrt(dx * dx + dy * dy);
		tween = new Tween( x, y, ex, ey );
		coef = 0;
		spc = SPEED / dist;
	}

	public function setValue(n) {
		desc.text = Lang.MOJO_LEFT;
		
		var m = [
			0, 1, 0, 0, 80,
			0, 0, 1, 0, 0,
			1, 0, 0, 0, 0,
			0, 0, 0, 1, 0,
		];
		filters  = [ new flash.filters.ColorMatrixFilter(m)];
		
		if( n < 0 ) {
			n *= -1;
			desc.text = Lang.MOJO_FULL;
			filters  = [];
		}
		var str = Std.string(n);
		field.text = str;
		
		//desc.x = Std.int((MojoBox.WIDTH*0.5 - field.textWidth) * 0.5)-2;
		desc.x = Std.int((MojoBox.WIDTH - desc.textWidth) * 0.5);
		desc.y = 10 - Std.int(desc.textHeight * 0.5);
		
	}

	public function majPos() {
		var max = Browser.me.getHandTotal();
		var ec = 3;
		var ww = max * Card.WIDTH + (max - 1) * ec + MojoBox.WIDTH;
		var bx = Std.int((Cs.mcw - ww) * 0.5);
		moveTo( bx, Browser.me.getHandY() );
	}
	
	var ready:Bool;
	public function setReady( fl) {
		if( fl == ready  ) return;
		ready = fl;
		drawFrame( Gfx.main.get(ready?1:0, "mojo"),0,0);
		field.visible = !ready;
		desc.visible = !ready;
		play.visible = ready;
	}
	
	public function isAction() {
		return ready && over;
	}
	
//{
}