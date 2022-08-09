package mt.bumdum9;



#if flash

typedef TF = flash.text.TextField;
typedef TFO = flash.text.TextFormat;
typedef MC = flash.display.MovieClip;
typedef SP = flash.display.Sprite;
typedef BMD = flash.display.BitmapData;
typedef BMP = flash.display.Bitmap;
typedef MX = flash.geom.Matrix;
typedef CT = flash.geom.ColorTransform;
typedef PT = flash.geom.Point;
typedef SEG = { p1:PT, p2:PT };

#if bumdum
typedef EL = mt.pix.Element;
typedef PC = mt.player.Clip;
#end

#if playerclip
typedef PC = mt.player.Clip;
#end

#end

#if flash

class Col {

	public static var CHANNEL_LUM = [ 0.241, 0.691, 0.068 ];

	static public function colToObj(col){
		return {
			r:col>>16,
			g:(col>>8)&0xFF,
			b:col&0xFF
		};
	}
	
	static public function objToCol(o:{r:Int,g:Int,b:Int}){
			return (o.r << 16) | (o.g<<8 ) | o.b;
	}
	
	static public function colToObj32(col){
		return {
			a:col>>>24,
			r:(col>>16)&0xFF,
			g:(col>>8)&0xFF,
			b:col&0xFF
		};
	}
	
	static public function objToCol32(o:{a:Int,r:Int,g:Int,b:Int}){
			return (o.a << 24) | (o.r << 16) | (o.g<<8 ) | o.b;
	}

	static public function setPercentColor( mc:flash.display.DisplayObject, c:Float, col, ?inc:Float ){
		if(inc == null) inc = 0;
		var color = colToObj(col);
		var cp  = 1 - c;
		var ct = new flash.geom.ColorTransform( cp, cp, cp, 1, Std.int(c*color.r + inc ), Std.int(c*color.g + inc ), Std.int(c*color.b + inc ), 0 );
		mc.transform.colorTransform = ct;
	}
	
	static public function setColor( mc:flash.display.DisplayObject, col, dec =-255 ){
		var o = colToObj32(col);
		var ct = new flash.geom.ColorTransform( 1, 1, 1, 1, Std.int(o.r+dec ), Std.int(o.g+dec ), Std.int(o.b+dec ), 0 );
		mc.transform.colorTransform = ct;
	}
	
	static public function overlay ( mc:flash.display.DisplayObject, col, dec =-128 ) {
		var o = colToObj32(col);
		var a = 1;
		var b = 2;
		var ct = new flash.geom.ColorTransform( a, a, a, 1, Std.int( (o.r + dec)* b ) , Std.int( (o.g + dec)* b ) , Std.int( (o.b + dec)*b ), 0 );
		mc.transform.colorTransform = ct;
	}
	
	static public function overlay2 ( mc:flash.display.DisplayObject, col, dec =-128 ) {
		var o = colToObj32(col);
		var a = 2;
		var b = 1;
		var ct = new flash.geom.ColorTransform( a, a, a, a, Std.int( (o.r + dec)* b ) , Std.int( (o.g + dec)* b ) , Std.int( (o.b + dec)*b ), 0 );
		mc.transform.colorTransform = ct;
	}

	static public function overlay3 ( mc:flash.display.DisplayObject, col, ?dec:Null<Int>, luminosityEqualizer=true) {
		if( dec == null ) dec = -255;
		var o = colToObj32(col);
		if( luminosityEqualizer ){
			var lum = ( o.r * CHANNEL_LUM[0] + o.g * CHANNEL_LUM[1] + o.b * CHANNEL_LUM[2] );
			dec += 128-Std.int(lum);
		}
		var a = 2;
		var b = 1;
		var ct = new flash.geom.ColorTransform( a, a, a, a, Std.int( (o.r + dec)* b ) , Std.int( (o.g + dec)* b ) , Std.int( (o.b + dec)*b ), 0 );
		mc.transform.colorTransform = ct;
	}

	static public function getRainbow(?c){
		if(c == null) c = Math.random();
		var max = 3;
		var a:Array<Float> = [0.0,0.0,0.0];
		var part =  (1/max*2);
		for( i in 0...max ){
			var med = part+i*2*part;
			var dif = Num.hMod( med-c, 0.5 );
			a[i] = Math.min( 1.5-Math.abs(dif)*3 ,1);
		}
		return objToCol({
			r:Std.int(a[0]*255),
			g:Std.int(a[1]*255),
			b:Std.int(a[2]*255)
		});
	}
	
	static public function getRainbow2(?c){
		if(c == null) c = Math.random();
		var lim = 1 / 3;
		var a = [];
		for( i in 0...3 ) {
			var coef = Math.abs(Num.hMod(c - lim*i, 0.5))*2;
			a.push( Std.int(coef*255));
		}
		return objToCol({ r:a[0], g:a[1], b:a[2] });
	}

	static public function mergeCol(col:Int,col2:Int,?c){
		if(c == null) c = 0.5;
		var o = Col.colToObj(col);
		var o2 = Col.colToObj(col2);
		var o3 = {
			r:Std.int(o.r*c+o2.r*(1-c)),
			g:Std.int(o.g*c+o2.g*(1-c)),
			b:Std.int(o.b*c+o2.b*(1-c))
		}
		return Col.objToCol(o3);
	}
	
	static public function mergeCol32(col:Int,col2:Int,?c){
		if(c == null) c = 0.5;
		var o = Col.colToObj32(col);
		var o2 = Col.colToObj32(col2);
		var o3 = {
			r:Std.int(o.r*c+o2.r*(1-c)),
			g:Std.int(o.g*c+o2.g*(1-c)),
			b:Std.int(o.b*c+o2.b*(1-c)),
			a:Std.int(o.a*c+o2.a*(1-c))
		}
		return Col.objToCol32(o3);
	}
	
	static public function desaturate(col, c=0.5) {
		var o = colToObj(col);
		var average = (o.r + o.g + o.b) / 3;
		o.r = Std.int(o.r * (1 - c) + average * c);
		o.g = Std.int(o.g * (1 - c) + average * c);
		o.b = Std.int(o.b * (1 - c) + average * c);
		return objToCol(o);
	}
	
	static public function brighten(col,inc) {
		var o = colToObj(col);
		o.r = Std.int( Num.mm(0, o.r + inc, 255) );
		o.g = Std.int( Num.mm(0, o.g + inc, 255) );
		o.b = Std.int( Num.mm(0, o.b + inc, 255) );
		return objToCol(o);
	}

	static public function shuffle(col:Int,inc:Int){
		var o  = colToObj(col);
		o.r = Std.int( Num.mm( 0, o.r+(Math.random()*2-1)*inc ,255 ) );
		o.g = Std.int( Num.mm( 0, o.g+(Math.random()*2-1)*inc ,255 ) );
		o.b = Std.int( Num.mm( 0, o.b+(Math.random()*2-1)*inc ,255 ) );
		return objToCol(o);
	}

	public static function rgb2Hex( r: Int, g : Int, b : Int ) {
		return (r << 16) + (g << 8) + b;
	}
	
	public static  function getWeb(col){
		return "#"+StringTools.hex(col);
	}

	public static function hsl2Rgb(hue = 0.0, sat=1.0, lum=0.5) {
		var r:Float;
		var g:Float;
		var b:Float;
		if(lum == 0) {
			r = g = b = 0;
		} else {
			if(sat == 0){
				r = g = b = lum;
			} else {
				var t2 = (lum<=0.5)? lum*(1+sat):lum+sat-(lum*sat);
				var t1 = 2 * lum - t2;
				var t3 = [hue + 1 / 3, hue, hue - 1 / 3];
				var clr = [0.0, 0.0, 0.0];
				for( i in 0...3 ) {
					if(t3[i] < 0)	t3[i] += 1;
					if(t3[i] > 1)	t3[i] -= 1;

					if(6 * t3[i] < 1)			clr[i] = t1 + (t2 - t1) * t3[i] * 6;
					else if(2 * t3[i] < 1)		clr[i] = t2;
					else if(3 * t3[i] < 2)		clr[i] = (t1 + (t2 - t1) * ((2 / 3) - t3[i]) * 6);
					else						clr[i] = t1;
				}
				r = clr[0];
				g = clr[1];
				b = clr[2];
			}
		}
		return rgb2Hex( Std.int(r * 255), Std.int(g * 255), Std.int(b * 255));
	}

	public static function getPal(cl:Class<Dynamic>,size=8):Array<UInt> {
		var mc:SP = Type.createInstance(cl, []);
		var bmp = new BMD(Std.int(mc.width), Std.int(mc.height), false, 0xFFFF00);
		bmp.draw(mc);
		var a = [];
		var c = size >> 1;
		for( x in 0...10 ) 	a.push( bmp.getPixel(x*size + c, c) );
		bmp.dispose();
		return a;
	}
}

#if flash
class Filt {

	static public function glow(mc:flash.display.DisplayObject,?bl:Float,?str:Float,?col,?inner) {

		if(bl==null)	bl=2;
		if(str==null)	str=10;
		if(col==null)	col=0;
		if(inner==null)	inner=false;
		var fl = new flash.filters.GlowFilter();
		fl.blurX = bl;
		fl.blurY = bl;
		fl.strength = str;
		fl.color = col;
		fl.inner = inner;

		var a = mc.filters;
		a.push(fl);
		mc.filters = a;

	}

	/**
	 * Make blur
	 * @param	mc		Target DisplayObject
	 * @param	?blx	Blur X
	 * @param	?bly	Blur Y
	 */
	static public function blur(mc:flash.display.DisplayObject,?blx:Float,?bly:Float){
		if(blx==null)blx = 0;
		if(bly==null)bly = 0;

		var fl = new flash.filters.BlurFilter();
		fl.blurX = blx;
		fl.blurY = bly;

		var a = mc.filters;
		a.push(fl);
		mc.filters = a;
	}

	/**
	 * Switch to gray scales
	 * @param	mc		Target DisplayObject
	 * @param	?c
	 * @param	?inc
	 * @param	?o
	 * @param	?m1
	 */
	static public function grey( mc:flash.display.DisplayObject, ?c:Float, ?inc:Int, ?o:{r:Int,g:Int,b:Int}, ?m1 ){
		if(c==null)	c = 1;
		if(inc==null)	inc = 0;
		if(o==null)	o = {r:0,g:0,b:0};

		var m0 = [
			1,	0,	0,	0,	0,
			0,	1,	0,	0,	0,
			0,	0,	1,	0,	0,
			0,	0,	0,	1,	0
		];

		if(m1==null){
			/*
			var r = 0.25;
			var g = 0.15;
			var b = 0.6;
			*/
			var r = 0.35;
			var g = 0.45;
			var b = 0.2;

			m1 = [
				r,	g,	b,	0,	o.r+inc,
				r,	g,	b,	0,	o.g+inc,
				r,	g,	b,	0,	o.b+inc,
				0,	0,	0,	1,	0,
			];
		}

		var m = [];
		for( i in 0...m0.length ){
			m[i] = m0[i]*(1-c) + m1[i]*c;
		}

		var fl = new flash.filters.ColorMatrixFilter();
		fl.matrix = m;

		var a = mc.filters;
		a.push(fl);
		mc.filters = a;
	}
}

#end//flash

#end

class Arr {

	static public function shuffle < A > (a:Array < A > , ?rnd:mt.Rand) {
		var f = Std.random;
		if ( rnd != null ) f = rnd.random;
		var b = [];
		while (a.length > 0) b.push(a.pop());
		while (b.length > 0) {
			a.insert( f(a.length + 1), b.pop());
		}
	}

}

class Tween {

	public var sx:Float;
	public var sy:Float;
	public var ex:Float;
	public var ey:Float;
	public var coef:Float;
	
	/**
	 * Define start pos and end pos
	 */
	public function new(?sx:Float,?sy:Float,?ex:Float,?ey:Float){
		this.sx = sx;
		this.sy = sy;
		this.ex = ex;
		this.ey = ey;
		coef = 0;
	}
	
	/**
	 * Tween positions with value between 0 and 1
	 * @param	?c
	 */
	public function getPos(?c:Float) {
		if ( c == null ) c = coef;
		return {
			x : sx + (ex-sx)*c,
			y : sy + (ey-sy)*c,
		};
	}
	
	public function getVelocity(c:Float) {
		return {
			vx : (ex-sx)*c,
			vy : (ey-sy)*c,
		};
	}

	public function getDist() {
		var dx = ex - sx;
		var dy = ey - sy;
		return Math.sqrt(dx * dx + dy * dy);
	}
	
	/**
	 * Returns angle in radians
	 */
	public function getAngle() {
		var dx = ex - sx;
		var dy = ey - sy;
		return Math.atan2(dy, dx);
	}

	public function getModPos(?c:Float,?mx:Float,?my:Float) {
		var dx = Num.hMod( ex - sx, mx * 0.5 );
		var dy = Num.hMod( ey - sy, my * 0.5 );
		return {
			x : Num.sMod(sx + dx*c,mx),
			y : Num.sMod(sy + dy*c,my),
		};
	}
}

#if use_bmath
typedef PT = { x : Float, y : Float, z : Float };
typedef SEG = { p1:PT, p2:PT };
#end

#if (flash || use_bmath)
class BMath {
	/**
	 * Returns a point list to draw a line in pixels
	 */
	public static function bresenham( x0:Int, y0:Int, x1:Int, y1:Int ) {

		var a = [];
		var error:Int;
		var dx = x1 - x0;
		var dy = y1 - y0;
		var yi = 1;

		if( dx < dy ){
			//-- swap end points
			x0 ^= x1; x1 ^= x0; x0 ^= x1;
			y0 ^= y1; y1 ^= y0; y0 ^= y1;
		}

		if( dx < 0 ) {
			dx = -dx;
			yi = -yi;
		}

		if( dy < 0 ){
			dy = -dy;
			yi = -yi;
		}

		if( dy > dx ) {
			error = -( dy >> 1 );
			while( y1 <= y0) {		// < to <=
				a.push( { x:x1, y:y1 } );
				error += dx;
				if( error > 0 ){
					x1 += yi;
					error -= dy;
				}
				y1++;
			}
		} else {
			error = -( dx >> 1 );
			while( x0 <= x1  ) {		// < to <=
				a.push( { x:x0, y:y0 } );
				error += dy;
				if( error > 0 ) {
					y0 += yi;
					error -= dx;
				}
				x0++;
			}
		}

		return a;
	}

	public static function segment2segment( s1:SEG, s2:SEG ) {
		var s1_x = s1.p2.x - s1.p1.x;
		var s1_y =  s1.p2.y - s1.p1.y;
		var s2_x = s2.p2.x - s2.p1.x;
		var s2_y = s2.p2.y - s2.p1.y;
		var s = ( -s1_y * (s1.p1.x - s2.p1.x) + s1_x * (s1.p1.y - s2.p1.y)) / ( -s2_x * s1_y + s1_x * s2_y);
		var t = ( s2_x * (s1.p1.y - s2.p1.y) - s2_y * (s1.p1.x - s2.p1.x)) / ( -s2_x * s1_y + s1_x * s2_y);
		if (s >= 0 && s <= 1 && t >= 0 && t <= 1) return true;
		else return false;
	}
}
#end

class En {

	static public function get(e,id:Int) {
		var a = Type.getEnumConstructs(e);
		return Type.createEnum(e, a[id]);
	}
	
	static public function next<T>(e:T):T {
		return dec(e, 1);
	}
	
	static public function prev<T>(e:T):T {
		return dec(e, -1);
	}
	
	static public function dec<T>(e:T, inc):T {
		var index = Type.enumIndex(cast e) + inc;
		var en = Type.getEnum(cast e);
		var a = Type.getEnumConstructs(en);
		var n = a.length;
		while( index >= n)	index -= n;
		while( index < 0)	index += n;
		return Type.createEnum(en, a[index]);
	}
}

class Num {
	static public function mm(a,b,c){
		return Math.min(Math.max(a,b),c);
	}
	
	static public function clamp(a, b, c) {
		if ( b < a ) return a;
		if ( b > c ) return c;
		return b;
	}
	
	static public function sMod(n:Float,mod:Float){
		if( mod == 0  ) {
			trace("sMod ERROR! ("+n+","+mod+")");
			return n;
		}
		while(n >= mod) n -= mod;
		while(n < 0) n += mod;
		return n;
	}
	static public function hMod(n:Float,mod:Float){
		while(n > mod) n -= mod*2;
		while(n < -mod) n += mod*2;
		return n;
	}
}

