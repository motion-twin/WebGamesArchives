package ev;
import Floor;
import mt.bumdum.Lib;
class Shoot extends Event {//}

	public var shot:flash.MovieClip;
	var trg:Ent;
	var ent:Ent;
	public var dmg:Int;

	public var bhl:Array<Int>;


	public function new(e,t,?d){
		ent = e;
		trg = t;
		dmg = d;
		super();
		var dx = trg.x - ent.x;
		var dy = trg.y - ent.y;
		spc = 0.5/Math.sqrt(dx*dx+dy*dy);

		shot = Game.me.cfl.dm.attach( "mcShot", Floor.DP_FX );
		shot.stop();
		shot._x = -10000;
		Filt.glow(shot,2,4,0);

		bhl = [0];

	}




	override function update(){
		super.update();
		shot._x  = ( (trg.x+0.5)*coef + (ent.x+0.5)*(1-coef) )*Cs.CS;
		shot._y  = ( (trg.y+0.5)*coef + (ent.y+0.5)*(1-coef) )*Cs.CS;

		shot._rotation += 16;

		if(coef==1){
			impact();
			kill();
		}
	}

	function impact(){
		shot.removeMovieClip();

		for( bh in bhl ){
			switch(bh){
				case 0:
					trg.fxDamage(dmg);
					trg.hurt(dmg);
				case 1:
					trg.freeze();

			}
		}

	}

	override function kill(){
		Game.me.event = null;
		Game.me.gogogo();
		//Game.me.checkEvents();
	}






//{
}







