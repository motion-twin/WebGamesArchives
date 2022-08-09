class BotLoader extends DefaultLoader {
	
	public var botGame : BotGame;
	
	
	function new( root : flash.MovieClip ) {
		super(root) ;		
		botGame = new BotGame(root, this) ;
		flash.Lib.current.onEnterFrame = botGame.loop ;
	}
	
	
	static override  function main() {
		new BotLoader(flash.Lib.current) ;
	}
	
	override public function initLoading(?c : Int, ?x : Float, ?y : Float) {
		super.initLoading(c) ;
		
		loading = BotGame.me.mdm.attach("loading", Const.DP_LOADING) ;
		loading._x = 110 ;
		loading._y = 150 ;
	}
	
	
	override public function done() {
		if( --count > 0 )
			return null ;
		BotGame.me.hideLoading(loading) ;
		return count == 0 ;
	}

}