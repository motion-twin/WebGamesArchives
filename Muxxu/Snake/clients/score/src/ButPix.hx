import Protocole;
import mt.bumdum9.Lib;


class ButPix extends But {//}
	
	

	public var ax:Float;
	public var ay:Float;
	public var frames:Array<pix.Frame>;
	var gfx:pix.Element;


	public function new(f:Void->Void,fr) {

		super(f);
		frames = fr;
		while(frames.length < 5) frames.push(fr[0]);
		ax = 0.5;
		ay = 0.5;
		ww = 21;
		hh = 22;
		//
		
		
		
		//
		gfx = new pix.Element();
		addChild(gfx);
		
		//
		out();

	}
	
	
	
	override function setState(n) {
		super.setState(n);
		var fr = frames[n];
		if( fr == null ) return;
		gfx.drawFrame(fr, ax, ay);
		ww = fr.width;
		hh = fr.height;
		
	}
	
	


	
//{
}












