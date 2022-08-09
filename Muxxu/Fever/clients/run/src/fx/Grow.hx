package fx;

class Grow extends mt.fx.Fx{//}
	
	
	var mc:flash.display.DisplayObject;
	var scale:Float;
	var spc:Float;
	var fadeIn:Bool;
	

	public function new(mc,fadeIn=true,spc=0.1,sc=1.0) {
		super();
		scale = sc;
		this.fadeIn = fadeIn;
		this.spc = spc;
		this.mc = mc;
		coef = 0;
		mc.scaleX = mc.scaleY = fadeIn?0:scale;
		if( fadeIn ) mc.visible = true;

	}
	
	override function update() {
		
		coef = Math.min(coef + spc, 1);
		var c = coef;
		if( !fadeIn ) c = 1 - c;
		mc.scaleX = mc.scaleY = c * scale;
		if( coef == 1 ) {
			mc.visible = fadeIn;
			kill();
		}
		
	}
	
	
//{
}








