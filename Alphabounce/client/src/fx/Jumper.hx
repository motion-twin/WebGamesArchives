package fx;
import mt.bumdum.Phys;
import mt.bumdum.Lib;

class Jumper extends Phys{//}

	public var bl:Block;
	var tx:Int;
	var ty:Int;

	var sx:Float;
	var sy:Float;
	var ex:Float;
	var ey:Float;

	var c:Float;

	public function new(mc){
		super(mc);

		//seekTrg();

		Filt.glow(root,2,4,0xFFFFFF);
		Filt.glow(root,10,2,0xFFFFFF);

	}

	override public function update(){

		var ox = x;
		var oy = y;

		c = Math.min(c+0.1*mt.Timer.tmod,1);
		x = sx*(1-c) + ex*c;
		y = sy*(1-c) + ey*c - Math.sin(c*3.14)*20;
		super.update();

		// QUEUE
		var mc = Game.me.bdm.attach("mcQueueJumper",0);
		mc._x = ox;
		mc._y = oy;
		var dx = x-ox;
		var dy = y-oy;
		mc._rotation = Math.atan2(dy,dx)/0.0174;
		mc._xscale = Math.sqrt(dx*dx+dy*dy);

		// CHECK END
		if( c==1 ){
			if( Game.me.grid[tx][ty] != null ){
				seekTrg();
			}else{
				bl.setPos(tx,ty);
				bl.register();
				bl.root._visible = true;
				Game.me.bdm.over(bl.root);
				kill();
			}
		}





	}


	public function seekTrg(){
		tx = null;
		var to = 0;
		while(to++<200){
			var x = Std.random(Cs.XMAX);
			var y = Std.random(Game.me.level.ymax);
			if( Game.me.grid[x][y] == null ){
				tx = x;
				ty = y;
				break;
			}
		}
		if(tx==null){
			bl.root.removeMovieClip();
			kill();
			return;
		}


		sx = x;
		sy = y;
		ex = Cs.getX(tx+0.5);
		ey = Cs.getY(ty+0.5);

		c = 0;

	}




//{
}
