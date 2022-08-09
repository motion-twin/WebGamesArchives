package fx;
import Protocole;
import mt.bumdum9.Lib;

class Seer extends CardFx {//}

	static var LIST:Array<Seer> = [];

	
	
	public function new(ca) {
		LIST.push(this);
		super(ca);
		
	}
	
	override function update() {
		super.update();
		if( LIST[0] != this ) return;
		if( Game.me.gtimer % 12 != 0 ) return;
		var alpha = 1.0;
		var id = 0;
		for( pos in Game.me.nextPos ){
			var p = Stage.me.getPart("onde_slow",Stage.DP_BG);
			p.x = pos.x;
			p.y = pos.y;
			p.sprite.alpha = 1/(id+1);
			p.updatePos();
			id++;
			if( id == LIST.length ) break;
		}
		
	}
	
	override function kill() {
		LIST.remove(this);
		super.kill();
	
	}
	

	

	
	

		
	
//{
}
