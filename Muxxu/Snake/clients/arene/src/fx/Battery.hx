package fx;
import Protocole;
import Snake;
typedef WallRing = { ring:QRing, dist:Float };

class Battery extends CardFx {//}


	public static var LIMIT = 30;
	public static var ACTIVE = false;
	public static var coef:Float;
	
	public var layer:flash.display.Sprite;
	
	public function new(ca) {
		if( ACTIVE ) return;
		super(ca);
		ACTIVE = true;
		coef = 1;
		
		layer = new flash.display.Sprite();
		layer.blendMode = flash.display.BlendMode.ADD;
		Stage.me.dm.add(layer, Stage.DP_BG);
		
		
	}
	
	override function update() {
		super.update();

		
		var dif =  getWallDist(sn.x, sn.y);
		coef = 0.1+Math.min(1,dif / LIMIT)*0.9;
	
		fxQueue();

		
	}
	function fxQueue() {
		if( sn.queue == null ) return;
		var gfx = layer.graphics;
		gfx.clear();
		
		var a:Array<WallRing> = [];
		for( o in sn.queue ) {
			var dist = getWallDist(o.x, o.y);
			if( dist < LIMIT ) a.push({dist:dist,ring:o});
		}
		a.sort(sortRings);
		if( a.length == 0 ) return;
		
		
		if( Game.me.gtimer%1 == 0 ) {
			var coef = Math.pow(Math.random(), 2);
			var ring = a[Std.int(coef * a.length)].ring;
			new fx.Arc( ring.pos, layer.graphics );

		}
	}
	
	function sortRings(a:WallRing,b:WallRing) {
		if( a.dist < b.dist ) return -1;
		return 1;
	}
	
	function getWallDist(x, y) {
		var ddx = Math.min(x, Math.abs(Stage.me.width - x));
		var ddy = Math.min(y, Math.abs(Stage.me.height - y));
		return Math.min(ddx, ddy);
	}
	
	
	override function kill() {
		layer.parent.removeChild(layer);
		ACTIVE = false;
		super.kill();
	}
	


	
//{
}












