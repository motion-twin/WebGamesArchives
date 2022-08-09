package mt.heaps;

/**
* This library is meant for ergonomics not speed 
* * If you want more speed, you have to bind the traversed callback and close the drawable trans typing test ...
* This library is best used with a Using Api2D
*/
class Api2D {
	
	public static function setAlpha( h : h2d.Sprite, c : Float) {
		if( h==null) return;
		h.traverse( function (s) {
			var d = Std.instance( s , h2d.Drawable);
			if ( d !=null) 
				d.alpha = c;
		});
	}
	
	public static function setColorMatrix( h : h2d.Sprite, m : h3d.Matrix){
		if( h==null) return;
		h.traverse( function(s:h2d.Sprite){
			var d = Std.instance( s , h2d.Drawable);
			if( d!=null)
				d.colorMatrix = m;
		});
	}
	
}