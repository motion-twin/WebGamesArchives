import mt.bumdum9.Lib;

class Phys extends Sprite {//}

	public var frict:Null<Float>;
	public var vx:Float;
	public var vy:Float;
	public var vr:Float;
	public var fr:Float;
	public var vsc:Null<Float>;
	public var sleep:Null<Int>;
	public var timer:Null<Int>;
	public var alpha:Float;
	public var weight:Null<Float>;
	public var fadeLimit:Float;
	public var fadeType:Int;
	public var endFunc : Void -> Void;

	public var gy:Null<Float>;
	public var groundCol:Void->Void;
	public var bounceFrict:Float;
	
	public function new(?mc){
		super(mc);
		vx = 0;
		vy = 0;
		fadeLimit = 10;
		alpha = 100;
		vr = 0;
		fr = 1;
		bounceFrict = 0.5;
	}

	public function setAlpha(n){
		alpha = n;
		root.alpha = alpha;
	}

	public override function update(){

		if(sleep!=null){
			sleep --;
			if(sleep<0){
				sleep = null;
				root.visible = true;
				root.play();
			}
			return;
		}

		if(weight!=null)vy += weight;

		if(frict!=null){
			vx *= frict;
			vy *= frict;
		}

		x += vx;
		y += vy;

		root.rotation += vr;
		vr *= fr;
		
		if(vsc!=null){
			root.scaleX *= vsc;
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
			timer --;
			if(timer<fadeLimit){
				var c = timer/fadeLimit;
				switch(fadeType){
					case -1:
					case 0:
						root.scaleX = c*scale;
						root.scaleY = c*scale;
					case 1:
						root.visible = Std.int(timer)%4 > 1 ;
					case 2:
						root.play();
					case 3:
						root.scaleY = c*scale*0.01;
					case 4:
						var n = (1-c)*16;
						Filt.blur(root,n,0);
						root.alpha = c*alpha;
					case 5:
						root.scaleX = c*scale*0.01;

					default:
						root.alpha = c*alpha;
				}
				if(timer<=0) {
					if( endFunc != null ) endFunc();
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

