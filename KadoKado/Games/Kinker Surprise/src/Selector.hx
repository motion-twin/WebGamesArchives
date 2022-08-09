import mt.bumdum.Lib;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;


class Selector extends Rel {//}


	var mcSelector:flash.MovieClip;

	var pos:Array<Int>;


	var charge:Array<Float>;

	public function new(mc:flash.MovieClip){
		super(mc);
		charge = [0.0,0.0];		// >_<
		root._alpha = 0;
	}

	//
	public function update(){

		super.update();

	}


	public function initPos(x,y){
		pos = [x,y];
	}
	public function run(){

		var c = 0.005;
		var dx = Game.me.root._xmouse - Game.mcw*0.5;
		var dy = Game.me.root._ymouse - Game.mch*0.5;

		charge[0] += dx*c*mt.Timer.tmod;
		charge[1] += dy*c*mt.Timer.tmod;

		var ax = Math.abs(charge[0]);
		var ay = Math.abs(charge[1]);
		var sx = Math.floor(charge[0]/ax);
		var sy = Math.floor(charge[1]/ay);

		if( ax>0 && Game.me.grid[Game.gx(pos[0]+sx)][pos[1]] != Game.EMPTY ) charge[0]=0;
		if( ay>0 && Game.me.grid[pos[0]][Game.gy(pos[1]+sy)] != Game.EMPTY ) charge[1]=0;




		for( i in 0...charge.length ){
			var ch = charge[i];
			var  ach = Math.abs(ch);
			while( ach >=1 ){
				var sens = Math.floor(ch/ach);
				charge[i] -= sens;
				var p = pos.copy();
				p[i] = Math.floor( Num.sMod( p[i]+sens, Game.me.xmax ) );
				pos[i] = Math.floor( Num.sMod( pos[i]+sens, Game.me.xmax ) );
				Game.me.paint(pos[0],pos[1]);
				ach--;
			}
		}

		x = Rel.getRelX( (pos[0]+charge[0]+0.5)*Game.me.size  );
		y = Rel.getRelY( (pos[1]+charge[1]+0.5)*Game.me.size  );

	}





//{
}
















