class CauldronLoader extends DefaultLoader {
	
	public var cauldron : Cauldron ;
	
	
	function new( root : flash.MovieClip ) {
		super(root) ; 

		haxe.Serializer.USE_ENUM_INDEX = true ;

		cauldron = new Cauldron(root, this) ;
		flash.Lib.current.onEnterFrame = cauldron.loop ;
	}
	
	
	static override function main() {
		new CauldronLoader(flash.Lib.current) ;
	}
	
	
	override public function initLoading(?c : Int, ?x : Float, ?y : Float) {
		super.initLoading(c) ;
		
		if (loading != null)
			return ;
		
		loading = Cauldron.me.mdm.attach("loading", Cauldron.DP_LOADING) ;
		loading.smc.smc.gotoAndStop(Std.random(15) + 1) ;
		loading._x = DefaultLoader.WIDTH / 2 ; 
		loading._y = DefaultLoader.HEIGHT / 2 ; 
	}



}
