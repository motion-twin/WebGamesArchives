package mt.bumdum;

//

class Trick {//}

	public static function makeButton(mc:flash.MovieClip,?f,?f2){

		mc.onRollOut = 	callback(mc.gotoAndStop,1);
		mc.onRollOver = callback(mc.gotoAndStop,2);
		mc.onPress = 	function(){ mc.gotoAndStop(3);f();};

		mc.onRelease = 		function(){ mc.gotoAndStop(1);f2();};
		mc.onReleaseOutside = 	mc.onRollOut;

		mc.onDragOver = 	mc.onRollOver;
		mc.onDragOut = 		mc.onRollOut;

		mc.stop();
	}

	public static function butAction( mc:flash.MovieClip, f:Void->Void, ?f2:Void->Void, ?f3:Void->Void, ?f4:Void->Void ){

		mc.onPress = 	f;
		mc.onRollOver = f2;
		mc.onRollOut = 	f3;
		mc.onRelease = 	f4;

		mc.onReleaseOutside = 	mc.onRollOut;
		mc.onDragOver = 	mc.onRollOver;
		mc.onDragOut = 		mc.onRollOut;

		if(f4==null)mc.onRelease = mc.onRollOver;

		mc.useHandCursor = true;

	}

	public static function butKill(mc:flash.MovieClip){
		mc.onPress = 	null;
		mc.onRollOver = null;

		mc.onRelease = 		null;
		mc.onReleaseOutside = 	null;
		mc.onDragOver = 	null;
		mc.onDragOut = 		null;

		mc.useHandCursor = false;
	}

	public static function squarize(a:Float,rx:Float,?ry:Float){
		if(ry==null)ry=rx;

		var vx = Math.cos(a);
		var vy = Math.sin(a);
		var cx = vx/rx;
		var cy = vy/ry;

		if(Math.abs(cx)>Math.abs(cy)){
			var sens = vx>0?1:-1;
			return { x:rx*sens, y:Math.tan(a)*rx*sens };
		}else{
			var sens = vy>0?1:-1;
			return { x:ry/Math.tan(a)*sens, y:ry*sens };
		}

	}


//{
}















