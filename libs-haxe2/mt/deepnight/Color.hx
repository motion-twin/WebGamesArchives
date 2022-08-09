package mt.deepnight;

import Type;

typedef Col = {
	r	: Int, // 0-255
	g	: Int, // 0-255
	b	: Int, // 0-255
}
typedef ColHsl = {
	h	: Float, // 0-1
	s	: Float, // 0-1
	l	: Float, // 0-1
}

typedef Col32 = {
	>Col,
	a	: Int, // 0-255
}

typedef Pal = Array<Col>;
typedef PalInt = Array<Int>;

class Color {
	public static var BLACK = intToRgb(0x0);
	public static var WHITE = intToRgb(0xffffff);
	public static var MEDIAN_GRAY = intToRgb(0x808080);

	public static inline function hexToRgb(hex:String) : Col {
		if ( hex==null )
			throw "hexToColor with null";
		if ( hex.indexOf("#")==0 )
			hex = hex.substr(1,999);
		return {
			r	: Std.parseInt("0x"+hex.substr(0,2)),
			g	: Std.parseInt("0x"+hex.substr(2,2)),
			b	: Std.parseInt("0x"+hex.substr(4,2)),
		}
	}

	public static inline function hexToInt(hex:String) {
		return Std.parseInt( "0x"+hex.substr(1,999) );
	}

	public static inline function hexToInta(hex:String) {
		return Std.parseInt( "0xff"+hex.substr(1,999) );
	}

	public static inline function rgbToInt(c:Col) : Int{
		return (c.r << 16) | (c.g<<8 ) | c.b;
	}
	
	public static inline function rgbToHex(c:Col) : String {
		return intToHex( rgbToInt(c) );
	}
	
	public static inline function rgbToHsl(c:Col) : ColHsl {
		var r = c.r/255;
		var g = c.g/255;
		var b = c.b/255;
		var min = if(r<=g && r<=b) r else if(g<=b) g else b;
		var max = if(r>=g && r>=b) r else if(g>=b) g else b;
		var delta = max-min;
		
		var hsl : ColHsl = { h:0., s:0., l:0. };
		hsl.l = max;
		if( delta!=0 ) {
			hsl.s = delta/max;
			var dr = ( (max-r)/6 + (delta/2) ) / delta;
			var dg = ( (max-g)/6 + (delta/2) ) / delta;
			var db = ( (max-b)/6 + (delta/2) ) / delta;
			
			if( r==max ) hsl.h = db-dg;
			else if( g==max ) hsl.h = 1/3 + dr-db;
			else if( b==max ) hsl.h = 2/3 + dg-dr;
			
			if( hsl.h<0 ) hsl.h++;
			if( hsl.h>1 ) hsl.h--;
		}
			
		return hsl;
	}
	
	public static inline function hslToRgb(hsl:ColHsl) : Col {
		var c : Col = {r:0, g:0, b:0};
		var r = 0.;
		var g = 0.;
		var b = 0.;
		
		if( hsl.s==0 )
			c.r = c.g = c.b = Math.round(hsl.l*255);
		else {
			var h = hsl.h*6;
			var i = Math.floor(h);
			var c1 = hsl.l * (1 - hsl.s);
			var c2 = hsl.l * (1 - hsl.s * (h-i));
			var c3 = hsl.l * (1 - hsl.s * (1 - (h-i)));
			
			if( i==0 )		{ r = hsl.l; g = c3; b = c1; }
			else if( i==1 )	{ r = c2; g = hsl.l; b = c1; }
			else if( i==2 )	{ r = c1; g = hsl.l; b = c3; }
			else if( i==3 )	{ r = c1; g = c2; b = hsl.l; }
			else if( i==4 )	{ r = c3; g = c1; b = hsl.l; }
			else 			{ r = hsl.l; g = c1; b = c2; }
			c.r = Math.round(r*255);
			c.g = Math.round(g*255);
			c.b = Math.round(b*255);
		}
		
		return c;
	}
	public static inline function rgbToMatrix(c:Col) {
		var matrix = new Array();
		matrix = matrix.concat([c.r/255, 0, 0, 0, 0]); // red
		matrix = matrix.concat([0, c.g/255, 0, 0, 0]); // green
		matrix = matrix.concat([0, 0, c.b/255, 0, 0]); // blue
		matrix = matrix.concat([0, 0, 0, 1.0, 0]); // alpha
		return matrix;
	}
	
	public static inline function intToHex(c:Int, ?leadingZeros=6) {
		var h = StringTools.hex(c);
		while (h.length<leadingZeros)
			h="0"+h;
		return "#"+h;
	}

	public static inline function intToRgb(c:Int) : Col {
		return {
			r	: (c>>16),
			g	: (c>>8)&0xFF,
			b	: c&0xFF,
		}
	}

	public static inline function intToRgba(c:Int) : Col32 {
		return {
			a	: (c>>24),
			r	: (c>>16)&0xFF,
			g	: (c>>8)&0xFF,
			b	: c&0xFF,
		}
	}
	
	public static inline function intToHsl(c:Int) : ColHsl {
		return rgbToHsl( intToRgb(c) );
	}
	public static inline function hslToInt(c:ColHsl) : Int {
		return rgbToInt( hslToRgb(c) );
	}

	public static inline function rgbaToInt(c:Col32) : Int {
		return (c.a << 24) | (c.r<<16 ) | (c.g<<8) | c.b;
	}
	
	public static inline function rgbaToRgb(c:Col32) : Col {
		return { r:c.r, g:c.g, b:c.b };
	}
	
	public static inline function multiply(c:Col, f:Float) {
		return {
			r	: Std.int(c.r*f),
			g	: Std.int(c.g*f),
			b	: Std.int(c.b*f),
		}
	}
		
	public static function saturation(c:Col, delta:Float) {
		var hsl = rgbToHsl(c);
		hsl.s+=delta;
		if( hsl.s>1 ) hsl.s = 1;
		if( hsl.s<0 ) hsl.s = 0;
		return hslToRgb(hsl);
	}
	
	public static inline function saturationInt(c:Int, delta:Float) {
		return rgbToInt( saturation(intToRgb(c), delta) );
	}
	
	public static function capBrightness(c:Col, maxLum:Float) : Col {
		var hsl = rgbToHsl(c);
		if( hsl.l>maxLum ) {
			hsl.l = maxLum;
			return hslToRgb(hsl);
		}
		else
			return c;
	}
	
	public static function capBrightnessInt(cint:Int, maxLum:Float) : Int {
		var hsl = intToHsl(cint);
		if( hsl.l>maxLum ) {
			hsl.l = maxLum;
			return hslToInt(hsl);
		}
		else
			return cint;
	}
	
	public static function cap(c:Col, sat:Float, lum:Float) {
		var hsl = rgbToHsl(c);
		if( hsl.s>sat ) hsl.s = sat;
		if( hsl.l>lum ) hsl.l = lum;
		return hslToRgb(hsl);
	}
	
	public static function capInt(c:Int, sat:Float, lum:Float) {
		var hsl = intToHsl(c);
		if( hsl.s>sat ) hsl.s = sat;
		if( hsl.l>lum ) hsl.l = lum;
		return hslToInt(hsl);
	}
	
	public static function hue(c:Col, f:Float) {
		var hsl = rgbToHsl(c);
		hsl.h+=f;
		if( hsl.h>1 ) hsl.h = 1;
		if( hsl.h<0 ) hsl.h = 0;
		return hslToRgb(hsl);
	}
	
	public static inline function hueInt(c:Int, f:Float) {
		return rgbToInt( hue(intToRgb(c), f) );
	}
	
	public static function brightnessInt(cint:Int, delta:Float) {
		return rgbToInt( brightness( intToRgb(cint), delta ) );
	}
	public static function brightness(c:Col, delta:Float) {
		var hsl = rgbToHsl(c);
		if( delta<0 ) {
			// Darken
			hsl.l+=delta;
			if( hsl.l<0 ) hsl.l = 0;
		}
		else {
			// Brighten
			var d = 1-hsl.l;
			if( d>delta )
				hsl.l += delta;
			else {
				hsl.l = 1;
				hsl.s -= delta-d;
				if( hsl.s<0 ) hsl.s = 0;
			}
		}
		return hslToRgb(hsl);
	}
	

	public static inline function desaturate(c:Col, ratio:Float) : Col {
		var gray = 0.3*c.r + 0.59*c.g + 0.11*c.b;
		return {
			r	: Std.int(gray*ratio + c.r*(1-ratio)),
			g	: Std.int(gray*ratio + c.g*(1-ratio)),
			b	: Std.int(gray*ratio + c.b*(1-ratio)),
		}
	}
	
	public static inline function desaturateInt(c:Int, ratio:Float) : Int {
		return rgbToInt( desaturate(intToRgb(c),ratio) );
	}

	
	public static inline function getAlpha(c:Int) : #if flash UInt #else Int #end {
		return c>>24;
	}
	public static inline function addAlphaF(c:Int, ?a=1.0) : #if flash UInt #else Int #end {
		return Std.int(a*255)<<24 | c;
	}
	public static inline function addAlphaI(c:Int, ?a=255) : #if flash UInt #else Int #end {
		return a<<24 | c;
	}
	
	public static inline function randomColor(hue:Float, ?sat=1.0, ?lum=1.0) {
		return getRainbowColor(hue,sat,lum);
	}
	public static inline function getRainbowColor(hue:Float, ?saturation=1.0, ?luminosity=1.0) : Int { // range : 0-1
		var hsl : ColHsl = {
			h : hue,
			s : saturation,
			l : luminosity,
		}
		return hslToInt(hsl);
	}
	public static inline function getRgbRatio(?cint:Int, ?crgb:Col) {
		var c = cint!=null ? intToRgb(cint) : crgb;
		//var max = rgb.r>rgb.g ? (rgb.r>rgb.b ? rgb.r : rgb.b)
		var max =
			if( c.b>c.g && c.b>c.r ) c.b;
			else if( c.g>c.r && c.g>c.b ) c.g;
			else c.r;
		return { r:c.r/max, g:c.g/max, b:c.b/max }
		//return rgb.r<=maxRed*255 && rgb.g<=maxGreen*255 && rgb.b<=maxBlue*255;
	}

	public static inline function getLuminosityPerception(c:Col) { // 0-255, tient compte de la luminance réelle
		return Math.sqrt( 0.241*(c.r*c.r) + 0.691*(c.g*c.g) + 0.068*(c.b*c.b) );
	}

	public static inline function autoContrast(c:Int, ?dark=0x0, ?light=0xffffff) { // renvoie DARK si C est clair, ou LIGHT si C est sombre
		return ( getLuminosityPerception(intToRgb(c))>=180 ) ? dark : light;
	}

	public static inline function getLuminosity(?c:Col, ?cint:Int) { // 0-1, valeur HSL
		return ( c!=null ) ? rgbToHsl(c).l : intToHsl(cint).l;
	}
	
	public static inline function setLuminosity(c:Col, lum:Float) {
		var hsl = rgbToHsl(c);
		hsl.l = lum;
		return hslToRgb(hsl);
	}
	
	public static inline function setLuminosityInt(c:Int, lum:Float) {
		var hsl = intToHsl(c);
		hsl.l = lum;
		return hslToInt(hsl);
	}

	public static inline function offsetColor(c:Col, delta:Int) : Col {
		return {
			r	: Std.int( Math.max(0, Math.min(255,c.r + delta)) ),
			g	: Std.int( Math.max(0, Math.min(255,c.g + delta)) ),
			b	: Std.int( Math.max(0, Math.min(255,c.b + delta)) ),
		}
	}
	public static inline function offsetColorRgba(c:Col32, delta:Int) : Col32 {
		return {
			r	: Std.int( Math.max(0, Math.min(255,c.r + delta)) ),
			g	: Std.int( Math.max(0, Math.min(255,c.g + delta)) ),
			b	: Std.int( Math.max(0, Math.min(255,c.b + delta)) ),
			a	: c.a,
		}
	}
	public static inline function offsetColorInt(c:Int, delta:Int) : Int {
		return rgbToInt( offsetColor(intToRgb(c), delta) );
	}

	public static inline function interpolatePal(from:Pal, to:Pal, ratio:Float) : Pal {
		var result : Pal = new Array();
		for (i in 0...from.length)
			result[i] = interpolate(from[i], to[i], ratio);
		return result;
	}
	
	public static inline function interpolate(from:Col, to:Col, ratio:Float) : Col {
		ratio = Math.min(1, Math.max(0, ratio) );
		return {
			r	: Std.int( from.r + (to.r-from.r)*ratio ),
			g	: Std.int( from.g + (to.g-from.g)*ratio ),
			b	: Std.int( from.b + (to.b-from.b)*ratio ),
		}
	}
	
	public static inline function interpolateInt(from:Int, to:Int, ratio:Float) : Int {
		return rgbToInt( interpolate(intToRgb(from), intToRgb(to), ratio) );
	}
	
	public static inline function darken(c:Int, ratio:Float) : Int {
		return rgbToInt( interpolate(intToRgb(c), BLACK, ratio) );
	}
	
	public static inline function lighten(c:Int, ratio:Float) : Int {
		return rgbToInt( interpolate(intToRgb(c), WHITE, ratio) );
	}
	
	#if flash9
	public static inline function getDarkenCT(ratio:Float) {
		var ct = new flash.geom.ColorTransform();
		ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = 1-ratio;
		return ct;
	}
	
	public static inline function getSimpleCT(?col:Col, ?colInt:Int, ?alpha:Null<Float>) {
		if (col==null)
			col = intToRgb(colInt);
		var ct = new flash.geom.ColorTransform();
		ct.redOffset = col.r-127;
		ct.greenOffset = col.g-127;
		ct.blueOffset = col.b-127;
		if(alpha!=null)
			ct.alphaMultiplier = alpha;
		return ct;
	}
	public static inline function getColorizeCT(?col:Col, ?colInt:Int, ratio:Float) {
		if (col==null)
			col = intToRgb(colInt);
		var ct = new flash.geom.ColorTransform();
		ct.redOffset = col.r*ratio;
		ct.greenOffset = col.g*ratio;
		ct.blueOffset = col.b*ratio;
		ct.redMultiplier = 1-ratio;
		ct.greenMultiplier = 1-ratio;
		ct.blueMultiplier = 1-ratio;
		return ct;
	}
	public static inline function getContrastFilter(ratio:Float) : flash.filters.ColorMatrixFilter { // -1 -> 1
		var m = 1+ratio*1.5;
		var o = -64*ratio;
		var matrix = [
			m,0,0,0,o,
			0,m,0,0,o,
			0,0,m,0,o,
			0,0,0,1,0,
		];
		return new flash.filters.ColorMatrixFilter(matrix);
	}
	public static inline function getSaturationFilter(ratio:Float) : flash.filters.ColorMatrixFilter { // -1 -> 1
		var matrix =
			if(ratio>0)
			[
				1+ratio,-ratio,0,0,0,
				-ratio,1+ratio,0,0,0,
				0,-ratio,1+ratio,0,0,
				0,0,0,1,0,
			];
			else
				getDesaturateMatrix(-ratio);
		return new flash.filters.ColorMatrixFilter(matrix);
	}
	public static inline function getInterpolatedCT(colFrom:Col, colTo:Col, ratio:Float) {
		return getSimpleCT( interpolate(colFrom, colTo, ratio) );
	}
	#end
	
	public static function getPaletteAverage(pal:Pal):Col {
		if (pal.length<0)
			return Reflect.copy(BLACK);
		var c = {r:0, g:0, b:0};
		for (p in pal) {
			c.r+=p.r;
			c.g+=p.g;
			c.b+=p.b;
		}
		return {
			r : Std.int(c.r/pal.length),
			g : Std.int(c.g/pal.length),
			b : Std.int(c.b/pal.length),
		}
	}

	#if flash9
	public static inline function getColorizeMatrixFilter(col:Int, ?ratioNewColor=1.0, ?ratioOldColor=1.0) {
		var rgb = intToRgb(col);
		var r = ratioNewColor * rgb.r/255;
		var g = ratioNewColor * rgb.g/255;
		var b = ratioNewColor * rgb.b/255;
		var matrix = [
			ratioOldColor+r, r, r, 0, 0,
			g, ratioOldColor+g, g, 0, 0,
			b, b, ratioOldColor+b, 0, 0,
			0, 0, 0, 1.0, 0,
		];
		return new flash.filters.ColorMatrixFilter(matrix);
	}
	#end
	
	// Renvoie une matrice pour utiliser avec un ColorMatrixFilter
	public static inline function getDesaturateMatrix(?ratio=1.0) {
		// Credit : http://www.senocular.com/flash/source/?id=0.169
		var redIdentity		= [1.0, 0, 0, 0, 0];
		var greenIdentity	= [0, 1.0, 0, 0, 0];
		var blueIdentity	= [0, 0, 1.0, 0, 0];
		var alphaIdentity	= [0, 0, 0, 1.0, 0];
		var grayluma		= [.3, .59, .11, 0, 0];

		var a = new Array();
		a = a.concat( interpolateArrays(redIdentity,	grayluma, ratio) );
		a = a.concat( interpolateArrays(greenIdentity,	grayluma, ratio) );
		a = a.concat( interpolateArrays(blueIdentity,	grayluma, ratio) );
		a = a.concat( alphaIdentity );
		return a;
	}
	private static inline function interpolateArrays(ary1:Array<Float>, ary2:Array<Float>, t:Float){
		// Credit : http://www.senocular.com/flash/source/?id=0.169
		var result = new Array();
		for (i in 0...ary1.length)
			result[i] = ary1[i] + (ary2[i] - ary1[i])*t;
		return result;
	}
	
	#if flash9
	
	public static inline function replaceChannel(bd:flash.display.BitmapData, r:Bool, g:Bool, b:Bool, colInt:Int, ?brightness=1.5) {
		var pt = new flash.geom.Point(0,0);
		var r_chan = if (r) extractChannel( bd, r, false, false );
		var g_chan = if (g) extractChannel( bd, false, g, false );
		var b_chan = if (b) extractChannel( bd, false, false, b );
		
		var diff : flash.display.BitmapData = null;
		
		var fl_2channels = r && g || r && b || g && b;
		
		if (fl_2channels) {
			// remplacement avec 2 channels
			diff = extractChannel( bd, r, g, b );
			if (r)	compareBitmaps(diff, r_chan);
			if (g)	compareBitmaps(diff, g_chan);
			if (b)	compareBitmaps(diff, b_chan);
		}
		else {
			// remplacemetn avec 1 seul channel
			if (r) diff = r_chan;
			if (g) diff = g_chan;
			if (b) diff = b_chan;
		}

		// on remplace le canal demandé
		var col = intToRgb(colInt);
		var fact = if (fl_2channels) 0.5 else 1;
		var r_ratio = fact * col.r/255 * brightness;
		var g_ratio = fact * col.g/255 * brightness;
		var b_ratio = fact * col.b/255 * brightness;
		var rint = r?1:0;
		var gint = g?1:0;
		var bint = b?1:0;
		var matrix = [
			rint*r_ratio, gint*r_ratio, bint*r_ratio, 0,0,
			rint*g_ratio, gint*g_ratio, bint*g_ratio, 0,0,
			rint*b_ratio, gint*b_ratio, bint*b_ratio, 0,0,
			0,0,0,1,0,
		];
		diff.applyFilter(diff, diff.rect, pt,
			new flash.filters.ColorMatrixFilter(matrix));
		bd.draw(diff);
		
		if(r_chan!=null) r_chan.dispose();
		if(g_chan!=null) g_chan.dispose();
		if(b_chan!=null) b_chan.dispose();
		diff.dispose();
	}
	
	private static inline function extractChannel(bd:flash.display.BitmapData, r:Bool, g:Bool, b:Bool) {
		var chan = bd.clone();
		var mask : Col32 = { a:0, r:(r?0:1)*255, g:(g?0:1)*255, b:(b?0:1)*255 };
		chan.threshold(chan, chan.rect, new flash.geom.Point(0, 0),
			">", 0x00000000, 0x00000000, Color.rgbaToInt(mask));
		return chan;
	}
	
	private static inline function compareBitmaps(target:flash.display.BitmapData, bd:flash.display.BitmapData) {
		var comp : Dynamic = target.compare(bd);
		target.fillRect(target.rect, 0x0);
		if (Type.typeof(comp)!=TInt) {
			target.fillRect(target.rect, 0x0);
			var comp : flash.display.BitmapData = comp;
			target.draw(comp);
			comp.dispose();
		}
	}
	
	public static inline function getChannelMask(r:Int,g:Int,b:Int) { // 0-1
		var c : Col32 = { a:0, r:r*255, g:g*255, b:b*255 }
		return rgbaToInt(c);
	}
	
	public static inline function makeNicePalette(col:Int, ?dark=0x0, ?light:Null<Int>, ?addAlpha=false) : PalInt {
		var col = intToRgb(col);
		if (light==null)
			light = rgbToInt( offsetColor(col, 100) );
		var dark = intToRgb(dark);
		var light = intToRgb(light);
		var pal : PalInt = new Array();
		var lightLimit = 200;
		var lightRange = 256-lightLimit;
		for (i in 0...256) {
			if (i<lightLimit)
				pal[i] = rgbToInt( interpolate(dark, col, i/lightLimit) );
			else
				pal[i] = rgbToInt( interpolate(col, light, (i-lightLimit)/lightRange) );
			//pal[i] = rgbToInt( interpolate(dark, col, i/255) );
			if (addAlpha)
				pal[i] = 0xff<<24 | pal[i];
		}
		return pal;
	}
	
	public static inline function makePalette(colors:Array<Int>) : PalInt { // du sombre au clair
		var pal : PalInt = [];
		var stepLength = 256/(colors.length-1);
		for (i in 0...256) {
			var step = i/stepLength;
			var col0 = colors[Std.int(step)];
			var col1 = colors[Std.int(step)+1];
			pal[i] = interpolateInt(col0, col1, step-Std.int(step));
		}
		return pal;
	}
	
	#if (flash10 && color_lab)
	public static function getFastPalette(r:PalInt, g:PalInt, b:PalInt, yellow:PalInt, pink:PalInt, cyan:PalInt) {
		var ba = new flash.utils.ByteArray();
		for (i in 0...256)	ba.writeUnsignedInt(0xff000000|0x0); // canaux 0,0,0
		for (c in r)		ba.writeUnsignedInt(0xff000000|c);
		for	(c in g)		ba.writeUnsignedInt(0xff000000|c);
		for	(c in yellow)	ba.writeUnsignedInt(0xff000000|c);
		for	(c in b)		ba.writeUnsignedInt(0xff000000|c);
		for	(c in pink)		ba.writeUnsignedInt(0xff000000|c);
		for (c in cyan)		ba.writeUnsignedInt(0xff000000|c);
		for (i in 0...256)	ba.writeUnsignedInt(0x0); // canaux 1,1,1
		ba.position = 0;
		return ba;
	}
	
	
	public static function paintBitmapFast(bd:flash.display.BitmapData, pal:flash.utils.ByteArray) {
		var bounds = if (bd.transparent) bd.getColorBoundsRect(0xff000000, 0x00000000, false) else bd.rect;
		var buffer = bd.getPixels(bounds);
		var palAddr = buffer.position;
		buffer.writeBytes(pal);
		buffer.position = 0;
		flash.Memory.select(buffer);
		var pos : UInt = 0;
		var palLength = 256*4;
		while (pos<palAddr) {
			var a = flash.Memory.getByte(pos);
			if ( a == 0 ) { pos += 4; continue; }
			var r = flash.Memory.getByte(pos+1);
			var g = flash.Memory.getByte(pos+2);
			var b = flash.Memory.getByte(pos+3);
			var idx = ( ((r>0)?1:0) | ((g>0)?2:0) | ((b>0)?4:0) );
			flash.Memory.setI32(pos, (flash.Memory.getI32(palAddr + (((idx<<8) + (r | g | b)) << 2)) & 0xFFFFFF00) | a);
			pos+=4;
		}
		bd.setPixels(bounds, buffer);
	}
	#end
	
	#if flash10
	public static function paintBitmap(bd:flash.display.BitmapData, red:PalInt, green:PalInt, blue:PalInt, ?yellow:PalInt, ?pink:PalInt, ?cyan:PalInt) {
		//var bounds = (bd.transparent ? bd.getColorBoundsRect(0xff000000, 0x00000000, false) : bd.rect);
		var bounds = bd.rect;
		var pixels = bd.getPixels(bounds);
		pixels.position = 0;
		if (pixels.bytesAvailable>0) {
			flash.Memory.select(pixels);
			
			var pos : UInt = 0;
			var max = pixels.bytesAvailable;
			while (pos<max) {
				if( flash.Memory.getByte(pos)>0 ) { // test alpha
					var r = flash.Memory.getByte(pos+1);
					var g = flash.Memory.getByte(pos+2);
					var b = flash.Memory.getByte(pos+3);
					
					if(r!=g || g!=b || r!=b) {
						var result =
							if (g==0 && b==0)		red[r];
							else if (r==0 && b==0)	green[g];
							else if (r==0 && g==0)	blue[b];
							else if (r!=0 && g!=0)	yellow[r];
							else if (r!=0 && b!=0)	pink[r];
							else if (g!=0 && b!=0)	cyan[g];
							else 0xff00ff;
						flash.Memory.setByte(pos+1, result>>16);
						flash.Memory.setByte(pos+2, result>>8);
						flash.Memory.setByte(pos+3, result);
					}
				}
				pos+=4;
			}
			bd.setPixels(bounds, pixels);
		}
	}
	#end
	
	#if flash10
	public static function paintBitmapGrays(bd:flash.display.BitmapData, pal:PalInt) {
		var bounds = bd.rect;
		var pixels = bd.getPixels(bounds);
		pixels.position = 0;
		if (pixels.bytesAvailable>0) {
			flash.Memory.select(pixels);
			
			var pos : UInt = 0;
			var max = pixels.bytesAvailable;
			while (pos<max) {
				if( flash.Memory.getByte(pos)>0 ) { // test alpha
					var r = flash.Memory.getByte(pos+1);
					var g = flash.Memory.getByte(pos+2);
					var b = flash.Memory.getByte(pos+3);
					
					if(r==g && g==b) {
						var result = pal[r];
						flash.Memory.setByte(pos+1, result>>16);
						flash.Memory.setByte(pos+2, result>>8);
						flash.Memory.setByte(pos+3, result);
					}
				}
				pos+=4;
			}
			bd.setPixels(bounds, pixels);
		}
	}
	#end
	
	
	public static function pickColor(bd:flash.display.BitmapData, rect:flash.geom.Rectangle) : Col32 {
		var ba = bd.getPixels(rect);
		var sum = {a:0., r:0., g:0., b:0.}
		var pos = 0;
		var len : Int = ba.length;
		while( pos < len ) {
			sum.a += ba[pos++];
			sum.r += ba[pos++];
			sum.g += ba[pos++];
			sum.b += ba[pos++];
		}
		var n = rect.width*rect.height;
		var rgba : Col32 = {a:Std.int(sum.a/n), r:Std.int(sum.r/n), g:Std.int(sum.g/n), b:Std.int(sum.b/n)}
		return {a:Std.int(sum.a/n), r:Std.int(sum.r/n), g:Std.int(sum.g/n), b:Std.int(sum.b/n)}
	}
	
	public static function drawPalette(g:flash.display.Graphics, ?wid=32, ?hei=32, ?aint:Array<Int>, ?acol:Array<Col>) {
		if( aint!=null )
			for(i in 0...aint.length) {
				g.beginFill(aint[i], 1);
				g.drawRect(i*wid, 0, wid,hei);
				g.endFill();
			}
		else
			for(i in 0...acol.length) {
				g.beginFill(rgbToInt(acol[i]), 1);
				g.drawRect(i*wid, 0, wid,hei);
				g.endFill();
			}
	}
	#end // Fin IF FLASH9

}

