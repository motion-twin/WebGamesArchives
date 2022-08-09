import Protocole;
import mt.bumdum9.Lib;


class ButText extends But {//}
	
	public var field:flash.text.TextField;
	
	public var bgColors:Array<Int>;
	public var textColors:Array<Int>;
	public var hBordColors:Array<Null<Int>>;
	
	public function new(f:Void->Void,str) {

		super(f);
		
		bgColors = [0, 0x880000, 0, 0x440000];
		textColors = [0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF];
		hBordColors = [null,null,null,null];
		
		
		field = Snk.getField(0xFFFFFF, 8, -1, "nokia");
		field.y -= 7;
		field.text = str;
		
		addChild(field);
		
		over();

	}
	
	override function setSize(w:Int,h:Int) {
		field.width = w;
		field.x = -Std.int((field.textWidth+3) * 0.5);
		super.setSize(w, h);
	}
	
	
	
	override function setState(n) {
		super.setState(n);
		
		// BG
		graphics.clear();
		
		var hbc = hBordColors[n];
		if( hbc != null) {
			var ma = 1;
			graphics.beginFill( hbc );
			graphics.drawRect( -ww * 0.5, -(ma+hh * 0.5), ww, hh+2*ma);
		}
		
		graphics.beginFill( bgColors[n] );
		graphics.drawRect( -ww * 0.5, -hh * 0.5, ww, hh);
	
		
		// TEXT
		field.textColor = textColors[n];
		
	}



	
//{
}












