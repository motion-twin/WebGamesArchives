package fx;
import Protocole;
import mt.bumdum9.Lib;

private typedef HPart = { sp:SP, c:Float, vr:Float, bl:gfx.BlackLight };

class BlackHole extends Fx {//}

	public static var ACTIVE = false;


	var coef:Float;
	var spc:Float;
	var dec:Float;
	var hole:gfx.BlackLight;
	var parts:Array<HPart>;

	
	public function new() {
		if( ACTIVE ) return;
		super();
		ACTIVE = true;
		sn.trq = [];
		coef = 0;
		spc = 0.001;
		dec = 0;
		
		hole = new gfx.BlackLight();
		hole.x = sn.x;
		hole.y = sn.y;
		hole.scaleX = hole.scaleY = 0.25;
		Stage.me.dm.add(hole, Stage.DP_BG);
		
		parts = [];
		
	}
	
	override function update() {
		super.update();
		coef = Math.min(coef + spc, 1);
		
		
		if( sn.rlength/sn.length < 1 ){
			
			pop();
			
			
			hole.scaleX *= 1.001;
			hole.scaleY = hole.scaleX;
			
			for( fr in Game.me.fruits ) {
				if( fr.dummy ) continue;
				new FruitToTarget(fr, 1, {x:hole.x,y:hole.y} );
			}
			
			
		}else {
			hole.scaleX *= 0.9;
			hole.scaleY = hole.scaleX;
			for( p in parts ) p.c *= 0.97;
			if( hole.scaleX < 0.02 ) kill();
		}
		
		var a = parts.copy();
		for( p in a ) {
			p.sp.scaleX *= p.c;
			p.sp.scaleY = p.sp.scaleX;
			p.sp.rotation += p.vr;
			p.bl.scaleX *= 1.08;
			p.bl.scaleY = p.bl.scaleX;
			if( p.sp.scaleX < 0.1 ) {
				parts.remove(p);
				p.sp.parent.removeChild(p.sp);

			}
		}
						
	}
	
	function pop() {
		var sp = new SP();
		var bl = new gfx.BlackLight();
		sp.addChild(bl);
		bl.x = 20 + Std.random(40);
		sp.rotation = Math.random() * 360;
		sp.x = hole.x;
		sp.y = hole.y;
		bl.scaleX = bl.scaleY = 0.03;
		parts.push( { sp:sp, bl:bl, c:0.85 + Math.random() * 0.1, vr:2+Math.random()*4 } );
				
		Stage.me.dm.add(sp, Stage.DP_BG);
	}
	
	override function kill() {
		ACTIVE = false;
		hole.parent.removeChild(hole);
		while(parts.length > 0) {
			var sp = parts.pop().sp;
			sp.parent.removeChild(sp);
		}
		super.kill();
	}

	

	
	

		
	
//{
}
