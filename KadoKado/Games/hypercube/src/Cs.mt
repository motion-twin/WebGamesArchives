class Cs{//}


	static var mcw = 300
	static var mch = 300

	static var SHAPE_SIZE = 5
	static var SHAPE_VOLUME = 4

	static var COMBO_MIN = 3

	static var PIECE_SPEED = 5
	static var PIECE_INTERVAL = 80

	static var TIMER_MAX = 5000 //7000

	static var C100 = KKApi.const(100);

	static function setPercentColor( mc, prc, col ){
		var color = {
			r:col>>16,
			g:(col>>8)&0xFF,
			b:col&0xFF
		};
		var co = new Color(mc)
		var c  = prc/100
		var ct = {
			ra:int(100-prc),
			ga:int(100-prc),
			ba:int(100-prc),
			aa:100,
			rb:int(c*color.r),
			gb:int(c*color.g),
			bb:int(c*color.b),
			ab:0
		};
		co.setTransform( ct );
	}

	public static function makeButton(mc:MovieClip){

		mc.onRollOut = 	callback(mc,gotoAndStop,"1");
		mc.onRollOver = callback(mc,gotoAndStop,"2");
		mc.onPress = 	callback(mc,gotoAndStop,"3");

		mc.onRelease = 		mc.onRollOver;
		mc.onReleaseOutside = 	mc.onRollOut;

		mc.onDragOver = 	mc.onRollOver;
		mc.onDragOut = 		mc.onRollOut;

		mc.stop();

	}
//{
}