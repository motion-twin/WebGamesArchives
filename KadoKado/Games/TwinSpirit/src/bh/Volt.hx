package bh;
import Protocol;
import mt.bumdum.Lib;

class Volt extends Behaviour{//}

	var charge:Int;
	var inc:Int;
	var parts:Float;

	public function new(){
		super();

		inc = 1;


	}

	public function init(b){
		super.init(b);
		charge = 0;
		parts = 0;
	}

	public function update(){

		charge += inc;
		parts += Math.max(charge*0.15-8, 0);

		// FX
		while( parts>0 ){
			var mc = Game.me.dm.attach("mcVolt",Game.DP_FX);
			mc._x = b.x + (Math.random()*2-1)*b.ray;
			mc._y = b.y + (Math.random()*2-1)*b.ray;
			mc.blendMode ="add";
			mc._rotation = Math.random()*360;
			Filt.glow(mc,4,2,0xFFFF00);
			parts--;
		}


		// SHOOT
		if( charge > 100 ){
			charge = -b.seed.random(50);
			var dest = [ShotType(STVolt)];
			for( i in 0...20 ){
				dest.push( ShotPos( (b.seed.rand()*2-1)*b.ray, (b.seed.rand()*2-1)*b.ray  ) );
				dest.push( Aim(0.01,8+b.seed.rand()*6 ) );
				dest.push( Wait(0.25) );
			}
			//var dest = [ Aim(0.1,2+b.seed.rand()*3 ), Wait(1), Back(2,20) ];
			b.addDestiny(dest);
		}

		// FUTUR TUENR BH
		b.root.smc.smc._rotation += b.vx*10;


	}

	public function nextWp(){

	}






//{
}











