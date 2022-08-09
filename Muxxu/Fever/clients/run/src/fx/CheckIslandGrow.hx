package fx;
import Protocole;
class CheckIslandGrow extends mt.fx.Fx{//}
	
	
	var island:world.Island;
	var elements:Array<IslandElement>;
	var stain:McStain;
	var timer:Int;
	var sq:world.Square;
	
	public function new(isl,?stain,?sq) {
		super();
		this.sq = sq;
		this.stain = stain;
		island = isl;
		elements = [];
		for( sq in island.zone ) for( el in sq.elements ) elements.push(el);
		timer = 26;

	}
	
	override function update() {

				
		var a = elements.copy();
		for(el in a){
			
			var p = el.sp.localToGlobal(new flash.geom.Point(0,0));
			var touch = island.dirt.hitTestPoint(p.x, p.y, true);

			
			var vis = touch;
			if( el.type == 1 ) vis = !touch;
			
			if( el.sp.visible != vis ) {
				var fx = new fx.Grow(el.sp, vis );
				elements.remove(el);
				if( stain == null ) fx.coef = 1;
			}
		}
		
		if( stain == null ) {
			kill();
			return;
		}
		
		timer--;
		//if( timer%4 == 0 )World.me.map.paintOceans(sq,timer/26);
		if( timer > 0 ) return;
		
		stain.scaleX -= 0.01;
		stain.scaleX *= 0.95;
		stain.scaleY = stain.scaleX ;
		if( stain.scaleX < 0.05 ) kill();
		
		
		
	}
	
	
//{
}








