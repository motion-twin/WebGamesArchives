import mt.bumdum.Lib;

class Part extends Element {//}

	public var ray:Float;

	public var vr:Float;
	public var fr:Float;
	public var vsc:Float;
	public var scale:Float;
	public var sleep:Float;
	public var timer:Float;
	public var alpha:Float;
	public var bounceFrict:Float;
	public var fadeLimit:Float;
	public var fadeType:Int;


	public function new(?mc:flash.MovieClip){
		super(mc);
		fadeLimit = 10;
		alpha = 100;
		ray  = 0;
		bounceFrict = -0.75;
	}

	public function setAlpha(n){
		alpha = n;
		root._alpha = alpha;
	}

	override function update(){

		if(sleep!=null){
			sleep --;
			if(sleep<0){
				sleep = null;
				root._visible = true;
				root.play();
			}
			return;
		}

		if(vr!=null)root._rotation += vr;
		if(fr!=null)vr*= fr;
		if(vsc!=null){
			root._xscale *= vsc;
			root._yscale = root._xscale;
		}

		if(timer!=null){
			timer --;
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

		var gy = Game.me.getGY(x);
		if( y>gy-ray  ){
			y = gy-ray;
			if(vy>0)vy *= bounceFrict;
			vx *= 0.95;
			if( vr !=null ){
				if(root.smc==null) vr *= -(0.5+Math.random());
				else 			root.smc._x *= 0.85;
			}
		}
		updatePos();

	}



//{
}

