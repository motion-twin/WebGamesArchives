

class Part extends mt.bumdum.Phys{//}


	public var z:Float;
	public var vz:Float;
	public var zw:Float;
	public var ray:Float;
	public var bounceFrict:Float;

	var shade:flash.MovieClip;


	public function new(mc){
		super(mc);
		z = 0;
		vz = 0;
		zw = 1;
		ray = 0;
		bounceFrict = 1;
		Game.me.elements.push(root);
	}

	override function update(){

		vz += zw*mt.Timer.tmod;
		if(frict!=null)vz *= Math.pow( frict, mt.Timer.tmod );
		z += vz*mt.Timer.tmod;

		var c = 1.0;
		if( timer!=null ){
			c = Math.min(timer/fadeLimit,1);
			if( c<1 ){
				shade._xscale = shade._yscale = ray*2*c;
			}
		}


		var r = ray*c;
		if( z>-r ){
			z = -r;
			vz *= -bounceFrict;
		}


		super.update();
	}

	override function updatePos(){
		super.updatePos();
		shade._x = root._x;
		shade._y = root._y;
		root._y += z;



	}

	public function dropShadow(){
		shade = Game.me.sdm.attach("mcShade",0);
		shade._xscale = shade._yscale = ray*2;
		shade._yscale *= 0.75;
	}

	override function kill(){
		Game.me.elements.remove(root);
		shade.removeMovieClip();
		super.kill();
	}


//{
}
