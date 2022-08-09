import Protocole;
import mt.bumdum9.Lib;


class ButTab extends ButText {//}
	

	public var sepColors:Array<Int>;
	public function new(f:Void->Void,str) {
	sepColors = [0, 0, 0, 0, 0];

		super(f,str);
		
		
	}
	

	
	override function setState(n) {
		super.setState(n);
		
		// BG
		if( n < 2 ){
			graphics.beginFill( sepColors[n] );
			graphics.drawRect( -ww * 0.5, hh * 0.5 - 1, ww, 1);
		}else {
			/*
			graphics.beginFill( sepColors[0] );
			graphics.drawRect( -(ww * 0.5),-(hh * 0.5), ww, hh);
			var ma = 1;
			graphics.beginFill( bgColors[n] );
			graphics.drawRect( ma - (ww * 0.5), ma - (hh * 0.5), ww - 2 * ma, hh - ma);
			*/
		}
	}
	
	
	
//{
}












