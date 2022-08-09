package fx;
import Protocole;
import mt.bumdum9.Lib;



class MorphHelp extends mt.fx.Fx {//}
	
	var help:inter.HelpBox;
	var active:Bool;	
	var tw:Tween;
	
	public function new(hlp,flag) {
		help = hlp;
		active = flag;
		super();
		
		var sx = inter.HelpBox.SQUARE_SIZE;
		var sy = inter.HelpBox.SQUARE_SIZE;
		var ex = inter.HelpBox.STD_WIDTH;
		var ey = inter.HelpBox.STD_HEIGHT;
		
		if( active ) 	tw = new Tween( help.mcw, help.mch, ex, ey );
		else			tw = new Tween( help.mcw, help.mch, sx, sy );
		
	}

	
	// UPDATE
	override function update() {
		super.update();
		coef = Math.min(coef + 0.1, 1);
		
		var p = tw.getPos(coef);
		
		help.mcw = Std.int(p.x);
		help.mch = Std.int(p.y);
		help.drawBg();
		
		//board.majPos();
		help.maj();
		
		if ( coef == 1 ) {
			help.setActive(active);
			kill();
		}
		
	}

	
	
//{
}