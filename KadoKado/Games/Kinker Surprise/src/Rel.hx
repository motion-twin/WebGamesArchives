import mt.bumdum.Lib;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;


class Rel extends Phys {//}
	
	public static var ZW:Float;
	public static var ZH:Float;

	public var relType:Int;
	public var flNoRel:Bool;
	public var relPoint : {x:Float,y:Float};
	
	
	public function new(mc:flash.MovieClip){
		super(mc);

	}
		
	//
	public function update(){
		if(flNoRel){
			super.update();
			return;
		}
		
		x = getRelX(x);
		y = getRelY(y);
		
		super.update();
		
		if(relPoint!=null){
			var dx = Num.hMod(relPoint.x-x,ZW*0.5);
			var dy = Num.hMod(relPoint.y-y,ZH*0.5);
			root._x = relPoint.x-dx;
			root._y = relPoint.y-dy;
		}
		
	}
	
	
	// TOOLS
	public function getDist(o:{x:Float,y:Float}){
		var dx = Num.hMod(o.x-x,ZW*0.5);
		var dy = Num.hMod(o.y-y,ZH*0.5);
		return Math.sqrt( dx*dx + dy*dy );
	}
	public function getAng(o:{x:Float,y:Float}){
		var dx = Num.hMod(o.x-x,ZW*0.5);
		var dy = Num.hMod(o.y-y,ZH*0.5);
		return Math.atan2( dy, dx );
	}	
	public function toward(o:{x:Float,y:Float},c:Float,?lim){
		if(lim==null)lim=1/0;
		var dx = Num.hMod(o.x-x,ZW*0.5);
		var dy = Num.hMod(o.y-y,ZH*0.5);
		x += Num.mm(-lim,dx*c,lim);
		y += Num.mm(-lim,dy*c,lim);
	}	
	
	public static function getRelX(x){
		return Num.sMod(x,ZW);
	}
	public static function getRelY(y){
		return Num.sMod(y,ZH);
	}
	
	//
	public function kill(){
		
		super.kill();
	}
	

//{
}
















