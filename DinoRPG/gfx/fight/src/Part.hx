
class Part extends Phys {

	public var timer:Float;
	public var alpha:Float;
	public var freeze:Float;
	public var fadeLimit:Int;
	public var fadeType:Int;


	public function new( mc ){
		super(mc);
		fadeLimit = 10;
	}
	
	public function setAlpha(n){
		alpha = n;
		root._alpha = alpha;
	}

	public override function update(){
		if(freeze!=null){
			freeze -= mt.Timer.tmod;
			if( freeze < 0  ){
				freeze = null;
				root.play();
				root._visible = true;
			} else {
				return;
			}
		}
		super.update();
		// TIMER
		if(timer != null){
			timer -= mt.Timer.tmod;
			if( timer < fadeLimit) {
				var c = timer / fadeLimit;
				switch(fadeType){
					case 0:
						root._xscale = root._yscale = c*scale;
					default:
						root._alpha = c*alpha;
				}
			}
			if( timer < 0 )kill();
		}
	}
}