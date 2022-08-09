package fx;
import mt.bumdum9.Lib;
import mt.bumdum9.Rush;

class Life extends mt.fx.Part<SP> {//}

	var field:TF;

	public function new(inc:Int,x:Float,y:Float) {
	
		super( new SP() );
		
		if ( y < 20 ) y = 20;
		
		field = TField.get(0xFFFFFF, 14, "verdana");
		field.height = 24;
		root.addChild(field);
		
		var str = "" + inc;
		if ( inc > 0 ) str = "+" + str;
		field.text = str;
		
		field.x = - Std.int(field.textWidth * 0.5);
		
		setPos(Std.int(x), Std.int(y));
		
		vy = -5;
		frict = 0.8;
		weight = -0.02;
		fitPix = true;
		timer = 40;
		fadeType = 0;
		
		
		Scene.me.dm.add(root, Scene.DP_FX);
		
		var color = 0;
		Filt.glow(root, 2, 8, 0);
		
		
		
	}
	

	override function update() {
		super.update();
		
		
	}
	
	
	
	
	
	

	
//{
}


