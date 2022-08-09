class ZoneLoader extends DefaultLoader {
	
	public var zone : Zone ;
	
	
	function new( root : flash.MovieClip ) {
		super(root) ;		
		zone = new Zone(root, this) ;
		flash.Lib.current.onEnterFrame = zone.loop ;
	}
	
	
	static override  function main() {
		new ZoneLoader(flash.Lib.current) ;
	}
	
	override public function initLoading(?c : Int, ?x : Float, ?y : Float) {
		super.initLoading(c) ;
				
		loading = Zone.me.mdm.attach("loading", Zone.DP_LOADING) ;
		loading.smc.smc.gotoAndStop(Std.random(15) + 1) ;
		loading._x = DefaultLoader.WIDTH / 2 ; 
		loading._y = DefaultLoader.HEIGHT / 2 ;
	}

}