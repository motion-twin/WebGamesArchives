import mt.bumdum.Phys;
import mt.bumdum.Lib;

class Part extends Phys{//}

	static var SHADE_ALPHA = 20;

	public var z:Float;
	public var vz:Float;
	public var shade:flash.MovieClip;
	public var zw:Float;
	public var bhl:Array<Int>;

	public function new(?mc){
		if(mc==null)mc = Game.me.mdm.attach("mcParts",Game.DP_SKY_PARTS);
		super(mc);
		z = 0;
		vz = 0;
		zw = 1;
		Filt.glow(root,2,1,0);
	}

	public function initShade(){
		shade = Game.me.mdm.attach("mcParts",Game.DP_GROUND);
		Col.setPercentColor(shade,100,0);
		shade.gotoAndStop(root._currentframe);
		shade._alpha = SHADE_ALPHA;
		shade._xscale = shade._yscale = scale;
	}


	public function update(){

		// GESTION Z
		vz += zw*mt.Timer.tmod;
		if(frict!=null)vz*= Math.pow(frict,mt.Timer.tmod);
		z += vz*mt.Timer.tmod;

		if(z>0){
			vr *= -Math.random()*0.8;
			z=0;
			vz *= -0.8;
			vx *= 0.9;
			vy *= 0.9;
		}

		// UPDATE GFX
		super.update();

		// DISPLAY Z
		root._x += z*0.1;
		root._y += z*0.5;
		root._yscale = root._xscale = scale-z;

		// SHADE
		if(shade!=null){
			shade._x = x;
			shade._y = y;
			shade._rotation = root._rotation;
			shade._alpha = SHADE_ALPHA*(root._alpha/100);
			//shade._yscale = shade._xscale = root._yscale;
		}

		// BEHAVIOUR

		for( bh  in bhl){
			switch(bh){
				case 0:

					var a = Math.atan2(vy,vx);
					var p = new Phys(Game.me.mdm.attach("partFlame",Game.DP_PARTS));
					p.x = root._x+(Math.random()*2-1)*4;
					p.y = root._y+(Math.random()*2-1)*4;
					p.root._xscale = p.root._yscale = root._xscale;
					p.vx = vx*( 0.5 +Math.random()*0.2 );
					p.vy = vy*( 0.5 +Math.random()*0.2 );
					p.root._rotation = a/0.0174-90;

					break;
			}
		}


	}

	public function kill(){
		shade.removeMovieClip();
		super.kill();
	}


//{
}







