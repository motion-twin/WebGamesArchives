package ;
import flash.display.DisplayObject;
import mt.kiroukou.motion.Tween;
class Fx
{
	inline public static function whiteBlink( o:DisplayObject, duration:Int )
	{
		Tween.tween(o, duration).fx( TLoop ).onUpdate( function(t, k) {
			var ke = t.getInterpolation();
			var ct = mt.deepnight.Color.getColorizeCT(0xFFFFFF, ke);
			o.transform.colorTransform = ct; 
		}).start();
	}
	
	inline public static function gradientRadiate(o:DisplayObject, duration, color, ?blur:Int=50, ?strength:Int=10)
	{
		var filter = gradientGlowFilter(blur, strength, color);
		o.filters = [filter];
		Tween.tween(o, duration).fx( TLoop ).onUpdate( function(t, k) {
			var ke = t.getInterpolation();
			filter.strength = ke * strength;
			o.filters = [filter];
		}).start();
	}
	
	inline public static function gradientGlowFilter( blur:Int, strength:Int, color:Int):flash.filters.GradientGlowFilter
	{
		var distance  = 0;
        var angleInDegrees = 45;
        var colors     = [color, color, 0xFFFFFF];
        var alphas     = [0, 0.5, 1.];
        var ratios     = [0, 128, 255];
        var blurX     = 60;
        var blurY     = 60;
        var strength  = 10;
        var quality   = flash.filters.BitmapFilterQuality.HIGH;
        var type      = flash.filters.BitmapFilterType.OUTER;
        var knockout = false;
		return new flash.filters.GradientGlowFilter(distance,
                                          angleInDegrees,
                                          colors,
                                          alphas,
                                          ratios,
                                          blurX,
                                          blurY,
                                          strength,
                                          quality,
                                          type,
                                          knockout);
	}
}