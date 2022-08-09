import mt.bumdum.Sprite;
import mt.bumdum.Lib;
import Game.InCase ;


class Coin {
	
	
	public var id : mt.flash.Volatile<Int> ;
	public var mc : flash.MovieClip ;
	public var myCase : InCase ;
		
	
	public function new(i : Int, ?pm : flash.MovieClip) {
		id = i ;
		if (pm == null)
			return ;
		mc = pm.attachMovie("coin", "coin", 0) ;
		mc.cacheAsBitmap = true ;
		mc.gotoAndStop(id + 1) ;
		
		/*mc._x = Std.random(3) * (Std.random(2) * 2 - 1) ;
		mc._y = Std.random(3) * (Std.random(2) * 2 - 1) ;*/
	}
	
	
	public function copy(dm : mt.DepthManager, ?d = 1) : Coin {
		var c = new Coin(id) ;
		c.mc = dm.attach("coin", d) ;
		c.mc.gotoAndStop(id + 1) ;
		return c ;
	}
	
	
	public function kill() {
		mc.removeMovieClip() ;
		if (myCase != null) {
			myCase.coin = null ;
		}
		
	}
	
}