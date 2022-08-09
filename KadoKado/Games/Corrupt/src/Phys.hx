import mt.bumdum.Lib;
typedef Label = { >flash.MovieClip, field:flash.TextField, timer:Float, sy:Int, dec:Float, col:Int }

class Phys extends Sprite {//}


	public var ray:Float;
	public var frict:Float;
	public var vx:Float;
	public var vy:Float;
	public var vr:Float;
	public var mcLabel:Label;


	public function new(mc){
		super(mc);
		vx = 0;
		vy = 0;
		ray = 1;

	}

	public function update(){

		if(vr!=null)root._rotation += vr;
		if(frict!=null){
			vx*=frict;
			vy*=frict;
		}

		x += vx;
		y += vy;

		super.update();
		if(mcLabel!=null)updateLabel();
	}

	public function kill(){
		mcLabel.removeMovieClip();
		super.kill();
	}


//{
}





