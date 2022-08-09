package mt.bumdum;
import mt.bumdum.Lib;

class Phys extends Sprite {//}

	public var frict:Float;

	public var vx:Float;
	public var vy:Float;
	public var vr:Float;
	public var fr:Float;
	public var vsc:Float;
	public var sleep:Float;
	public var timer:Float;
	public var alpha:Float;
	public var weight:Float;
	public var fadeLimit:Float;
	public var fadeType:Int;


	public function new(?mc:flash.MovieClip){
		super(mc);
		vx = 0;
		vy = 0;
		fadeLimit = 10;
		alpha = 100;
	}

	public function setAlpha(n){
		alpha = n;
		root._alpha = alpha;
	}

	public override function update(){

		if(sleep!=null){
			sleep --;
			if(sleep<0){
				sleep = null;
				root._visible = true;
				root.play();
			}
			return;
		}

		if(weight!=null){
			vy += weight*mt.Timer.tmod;
		}

		if(frict!=null){
			var f = Math.pow(frict,mt.Timer.tmod);
			vx *= f;
			vy *= f;
		}

		x += vx*mt.Timer.tmod;
		y += vy*mt.Timer.tmod;

		if(vr!=null)root._rotation += vr*mt.Timer.tmod;
		if(fr!=null)vr*= Math.pow(fr,mt.Timer.tmod);
		if(vsc!=null){
			root._xscale *= Math.pow(vsc,mt.Timer.tmod);
			root._yscale = root._xscale;
		}

		if(timer!=null){
			timer -= mt.Timer.tmod;
			if(timer<fadeLimit){
				var c = timer/fadeLimit;
				switch(fadeType){
					case -1:
					case 0:
						root._xscale = c*scale;
						root._yscale = c*scale;
					case 1:
						root._visible = Std.int(timer)%4 > 1 ;
					case 2:
						root.play();
					case 3:
						root._yscale = c*scale;
					case 4:
						var n = (1-c)*16;
						Filt.blur(root,n,0);
						root._alpha = c*alpha;
					case 5:
						root._xscale = c*scale;

					default:
						root._alpha = c*alpha;
				}
				if(timer<=0){

					kill();
				}
			}

		}

		super.update();
	}

	public function towardSpeed(o:{x:Float,y:Float},c:Float,?lim){
		if(lim==null)lim=1/0;
		var dx = o.x - x;
		var dy = o.y - y;
		vx += Num.mm(-lim,dx*c,lim);
		vy += Num.mm(-lim,dy*c,lim);
	}

	public override function kill(){

		super.kill();
	}


//{
}

