package mt.bumdum9;
import mt.bumdum9.Lib;

class Phys extends Sprite<flash.display.MovieClip> {//}

	public var frict:Null<Float>;

	public var vx:Float;
	public var vy:Float;
	public var vr:Null<Float>;
	public var fr:Null<Float>;
	
	public var vsc:Null<Float>;
	public var sleep:Null<Float>;
	public var timer:Null<Float>;
	public var alpha:Float;
	public var weight:Null<Float>;
	public var fadeLimit:Float;
	public var fadeType:Int;
	
	public var gy:Null<Float>;
	public var groundCol:Void->Void;
	public var bounceFrict:Float;

	public function new(?mc){
		super(mc);
		vx = 0;
		vy = 0;
		fadeLimit = 10;
		alpha = 1;
		bounceFrict = 0.5;
	}

	public function setAlpha(n){
		alpha = n;
		root.alpha = alpha;
	}

	override function update(){
		if(sleep!=null){
			sleep --;
			if(sleep<0){
				sleep = null;
				root.visible = true;
				//root.play();
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

		if(vr!=null)root.rotation += vr*mt.Timer.tmod;
		if(fr!=null)vr*= Math.pow(fr,mt.Timer.tmod);
		if(vsc!=null){
			root.scaleX *= Math.pow(vsc,mt.Timer.tmod);
			root.scaleY = root.scaleX;
		}
		
		if( gy != null ) {
			if( y > gy ) {
				y = gy;
				vy *= -bounceFrict;
				if( groundCol != null ) groundCol();
			}
		}

		if(timer!=null){
			timer -= mt.Timer.tmod;
			if(timer<fadeLimit){
				var c = timer/fadeLimit;
				switch(fadeType){
					case 0:
						root.scaleX = c*scale;
						root.scaleY = c*scale;
					case 1:
						root.visible = Std.int(timer)%4 > 1 ;
					case 2:
						//root.play();
					case 3:
						root.scaleY = c*scale;
					default:
						root.alpha = c*alpha;
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



//{
}

