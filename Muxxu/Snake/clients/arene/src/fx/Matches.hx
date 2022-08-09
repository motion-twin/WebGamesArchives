package fx;
import mt.bumdum9.Lib;
import Protocole;

class Matches extends Fx{//}


	var timer:Int;
	
	public function new( ) {
		super();
		timer = 90;
		if ( Game.me.have(ZIPPO) ) timer *= 2;
	}
	
	override function update() {
	
		if( sn.dead) {
			kill();
			return;
		}
				
		
		if( Game.me.gtimer % 10 == 0 ) {
			var q = sn.cut( 8 );
			q.setBurn();
		}
	
		// FX
		var ring = sn.getRingData(sn.length).ring;
		var ec = 8;
		var p = Stage.me.getPart("miniflame");
		p.x = ring.x + (Math.random() - 0.5) * ec;
		p.y = ring.y + (Math.random() - 0.5) * ec;
		p.weight = -0.1;
		
		
		
		
		if( timer-- == 0 ) kill();
	}

//{
}