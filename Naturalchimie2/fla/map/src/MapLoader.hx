class MapLoader extends DefaultLoader {

	var map : Map ;

	function new( root : flash.MovieClip ) {
		super(root) ; 
		
		map = new Map(root, this) ;
		flash.Lib.current.onEnterFrame = map.loop ;
	}
	
	
	static override function main() {
		new MapLoader(flash.Lib.current) ;
	}
	

	override public function initLoading(?c : Int, ?x : Float, ?y : Float) {
		super.initLoading(c) ;
		
		loading = Map.me.mdm.attach("loading", Map.DP_LOADING) ;
		loading.smc.smc.gotoAndStop(Std.random(15) + 1) ;
		loading._x = DefaultLoader.WIDTH / 2 ;
		loading._y = DefaultLoader.HEIGHT / 2 ;
	}

	
	

}