class WheelLoader extends DefaultLoader {
	
	public var wheel : Wheel ;
	
	
	function new( root : flash.MovieClip ) {
		super(root) ; 
		wheel = new Wheel(root, this) ;
		flash.Lib.current.onEnterFrame = wheel.loop ;
	}
	
	
	static override function main() {
		new WheelLoader(flash.Lib.current) ;
	}
	
	
	override public function initLoading(?c : Int, ?x : Float, ?y : Float) {
		super.initLoading(c) ;
		
		if (loading != null)
			return ;
		
		loading = Wheel.me.mdm.attach("loading", Wheel.DP_LOADING) ;
		loading.smc.smc.gotoAndStop(Std.random(15) + 1) ;
		loading._x = DefaultLoader.WIDTH / 2 ; 
		loading._y = DefaultLoader.HEIGHT / 2 ; 
	}



}
