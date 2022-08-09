import Common;
import mt.bumdum.Lib;



class Dash {//}

	static var SPEED = 16;

	var cosmo:pix.Cosmo;
	var angle:Float;
	var timer:Int;
	var holeBrush:flash.MovieClip;
	var mcRoll:flash.MovieClip;
	var rand:mt.OldRandSeed;



	public function new(cosmo,angle) {
		Game.me.anims.push(this);
		this.cosmo = cosmo;
		this.angle = angle;
		timer = 10;

		cosmo.root._visible = false;

		rand = new mt.OldRandSeed(cosmo.x+cosmo.y);


		holeBrush = Game.me.dm.attach("mcDashHole",0);
		holeBrush._visible = false;

		mcRoll = Game.me.mdm.attach("mcRoll",Game.DP_COSMO);
		mcRoll.gotoAndStop(cosmo.colorId+1);
		mcRoll._xscale = mcRoll._yscale =  75;

	}


	// UPDATE
	public function update(){

		timer--;

		// MOVE
		var dx = Std.int(Math.cos(angle)*SPEED);
		var dy = Std.int(Math.sin(angle)*SPEED);
		cosmo.x += dx;
		cosmo.y += dy;
		cosmo.updatePos();


		// HOLE
		var size = 16;
		var m = new flash.geom.Matrix();
		m.rotate(Math.atan2(dy,dx));
		m.translate(cosmo.x,cosmo.y);
		Game.me.mapBmp.draw( holeBrush ,m,null,"erase");

		// ROLL
		mcRoll._x = cosmo.x;
		mcRoll._y = cosmo.y;
		mcRoll._rotation = Std.random(360);

		// COL
		var list = Game.me.cosmos.copy();
		for( c in list  ){
			if(c!=cosmo && c.state != Fly ){
				var dx = (c.x+c.head.x) - cosmo.x;
				var dy = (c.y+c.head.y) - cosmo.y;
				var dist =  Math.sqrt( dx*dx + dy*dy );
				if( dist < c.ray*2 + 5 ){
					//var a = Math.atan2(dy,dx);
					var a = angle + (rand.random(2)*2-1)*(1.57 + (rand.rand()*2-1) *0.3);
					c.setState(Fly);
					var eject = 10+rand.rand()*10;
					c.vx = Math.cos(a)*eject;
					c.vy = Math.sin(a)*eject;
					c.incHp(-40);

				}

			}
		}



		if(timer==0){
			//cosmo.jump(0,0);

			cosmo.setState(Fly);
			//cosmo.setSens(1);
			//cosmo.gid = null;
			kill();
		}


	}


	public function kill(){
		mcRoll.removeMovieClip();
		cosmo.root._visible = true;
		holeBrush.removeMovieClip();
		Game.me.anims.remove(this);
	}



//{
}











