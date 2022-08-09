import Protocol;
import mt.bumdum.Lib;


class HeroShot extends Phys {//}


	public var damage:Float;

	public function new(mc){
		super(mc);
		damage = 1;
		ray = 4;
		Game.me.shots.push(this);
	}

	public function update(){

		checkCols();


		if( x<-ray || x>Cs.mcw+ray ||  y<-ray || y>Cs.mch+ray ){
			kill();
		}

		super.update();
	}

	function checkCols(){
		var px = Cs.getPX(x);
		var py = Cs.getPY(y);

		var list = Game.me.bgrid[px][py];
		for( bad in list ){
			var dx = (bad.x-x);
			var dy = (bad.y-y)/bad.scy;
			var dist = Math.sqrt(dx*dx+dy*dy);
			if( dist < ray+bad.ray ){
				bad.impact(this);
				kill();
			}

		}
	}

	public function kill(){
		Game.me.shots.remove(this);
		super.kill();
	}

	//
	public function fxImpact(){
		var mc = Game.me.dm.attach("mcImpact",Game.DP_FX);
		mc._x = x+(Math.random()*2-1)*4;
		mc._y = y+(Math.random()*2-1)*4;
		mc._rotation = Math.random()*360;
	}

	public function fxBounce(bad:Bad){

		var mc = Game.me.dm.attach("partBounce",Game.DP_FX);
		mc._x  = x;
		mc._y  = y;
		mc._rotation = Math.random()*306;
		Filt.glow(mc,4,1,0x00FFFF);

		for( i in 0...4 ){


			/*
			var p = new mt.bumdum.Phys(Game.me.dm.attach("partBounce",Game.DP_FX));
			p.x = x;
			p.y = y;
			var dx = p.x - bad.x;
			var dy = p.y - bad.y;
			var a = Math.atan2(dy,dx) + (Math.random()*2-1)*0.5;

			var sp = 1+Math.random()*3;
			p.vx = Math.cos(a)*sp;
			p.vy = Math.sin(a)*sp;

			p.updatePos();
			*/

		}




	}



//{
}






















