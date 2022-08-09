package mt;

import haxe.rtti.Meta;

typedef Palette256 = Array<ColorCode>;

/**********************************************
 * Color tools
 */

class Color {
	public static function hue(c:ColorCode, f:Float, ?loop=true) {
		var hsl = c.toHsl();
		hsl.h+=f;
		if( loop ) {
			while( hsl.l>1 ) hsl.l--;
			while( hsl.l<0 ) hsl.l++;
		}
		else {
			if( hsl.h>1 ) hsl.h = 1;
			if( hsl.h<0 ) hsl.h = 0;
		}
		return ColorCode.fromHsl(hsl);
	}
			
	public static inline function saturation(c:ColorCode, delta:Float) { // [-1, 1]
		var hsl = c.toHsl();
		hsl.s+=delta;
		if( hsl.s>1 ) hsl.s = 1;
		if( hsl.s<0 ) hsl.s = 0;
		return ColorCode.fromHsl(hsl);
	}
			
	public static inline function brightness(c:ColorCode, delta:Float) {
		var hsl = c.toHsl();
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
		return ColorCode.fromHsl(hsl);
	}

	public static inline function interpolate(from:ColorCode, to:ColorCode, ratio:Float) : ColorCode {
		var from = from.toRgb();
		var to = to.toRgb();
		ratio = Math.min(1, Math.max(0, ratio) );
		return ColorCode.fromRgb({
			r	: from.r + (to.r-from.r)*ratio,
			g	: from.g + (to.g-from.g)*ratio,
			b	: from.b + (to.b-from.b)*ratio,
		});
	}
		

	public static inline function setLuminosity(c:ColorCode, lum:Float) {
		var hsl = c.toHsl();
		hsl.l = lum;
		return ColorCode.fromHsl(hsl);
	}

	public static inline function getAlpha(c:ColorCode) : Float {
		return c.toRgba().a;
	}

	public static inline function setAlpha(c:ColorCode, a:Float) : ColorCode {
		return (c & 0x00ffffff) | (Std.int(a*0xff)<<24);
	}

	public static inline function addAlpha(c:ColorCode, ?a:Float=1.0) : ColorCode {
		return Std.int(a*255)<<24 | c;
	}
	
	public static inline function capHsl(c:ColorCode, maxSat:Float, maxLum:Float) {
		var hsl = c.toHsl();
		if( hsl.s>maxSat ) hsl.s = maxSat;
		if( hsl.l>maxLum ) hsl.l = maxLum;
		return ColorCode.fromHsl(hsl);
	}
	
	public static inline function capLuminosity(c:ColorCode, maxLum:Float) {
		var hsl = c.toHsl();
		if( hsl.l>maxLum ) {
			hsl.l = maxLum;
			return ColorCode.fromHsl(hsl);
		}
		else
			return c;
		
	}
	
	public static inline function makeColor(hue:Float, ?sat=1.0, ?lum=1.0) {
		return ColorCode.fromHsl({
			h	: hue,
			s	: sat,
			l	: lum,
		});
	}
	
	public static inline function getPerceptiveLuminance(c:ColorCode) { // 0-1, tient compte de la luminance réelle
		var rgb = c.toRgb();
		return Math.sqrt( 0.241*(rgb.r*rgb.r) + 0.691*(rgb.g*rgb.g) + 0.068*(rgb.b*rgb.b) ) / 255;
	}
	
	public static inline function autoContrast(c:ColorCode, ifDark:ColorCode, ifLight:ColorCode) {
		return getPerceptiveLuminance(c)>=0.5 ? ifLight: ifDark;
	}
	

	#if flash9
	// ColorCode transforms
	
	public static inline function getDarkenCT(ratio:Float) {
		var ct = new flash.geom.ColorTransform();
		ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = 1-ratio;
		return ct;
	}
	
	public static inline function getSimpleCT(c:ColorCode, ?alpha:Null<Float>) {
		var rgb = c.toRgb();
		var ct = new flash.geom.ColorTransform();
		ct.redOffset = (rgb.r*255) - 127;
		ct.greenOffset = (rgb.g*255) - 127;
		ct.blueOffset = (rgb.b*255) - 127;
		if( alpha!=null )
			ct.alphaMultiplier = alpha;
		return ct;
	}
	
	public static inline function getColorizeCT(c:ColorCode, ratio:Float) {
		var rgb = c.toRgb();
		var ct = new flash.geom.ColorTransform();
		ct.redOffset = rgb.r*255*ratio;
		ct.greenOffset = rgb.g*255*ratio;
		ct.blueOffset = rgb.b*255*ratio;
		ct.redMultiplier = 1-ratio;
		ct.greenMultiplier = 1-ratio;
		ct.blueMultiplier = 1-ratio;
		return ct;
	}
	
	public static inline function getInterpolatedCT(from:ColorCode, to:ColorCode, ratio:Float) {
		return getSimpleCT( interpolate(from, to, ratio) );
	}

	// ColorCode matrix filters
	
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
	#end

	
	public static inline function getDesaturateMatrix( ?ratio=1.0 ) { // Renvoie une matrice pour utiliser avec un ColorMatrixFilter
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
	private static inline function interpolateArrays( ary1:Array<Float>, ary2:Array<Float>, t:Float ) {
		// Credit : http://www.senocular.com/flash/source/?id=0.169
		var result = new Array();
		for (i in 0...ary1.length)
			result[i] = ary1[i] + (ary2[i] - ary1[i])*t;
		return result;
	}
	
	

	#if flash9
	
	public static inline function replaceChannel(bd:flash.display.BitmapData, r:Bool, g:Bool, b:Bool, c:ColorCode, ?brightness=1.5) {
		var pt = new flash.geom.Point(0,0);
		var r_chan = if (r) extractChannel( bd, r, false, false ) else null;
		var g_chan = if (g) extractChannel( bd, false, g, false ) else null;
		var b_chan = if (b) extractChannel( bd, false, false, b ) else null;
		
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
			// remplacement avec 1 seul channel
			if (r) diff = r_chan;
			if (g) diff = g_chan;
			if (b) diff = b_chan;
		}

		// on remplace le canal demandé
		var rgb = c.toRgb();
		var fact = if (fl_2channels) 0.5 else 1;
		var r_ratio = fact * rgb.r * brightness;
		var g_ratio = fact * rgb.g * brightness;
		var b_ratio = fact * rgb.b * brightness;
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
		var mask : ColorCode = ColorCode.fromRgba({ a:0, r:(r?0:1.), g:(g?0:1.), b:(b?0:1.) });
		chan.threshold(chan, chan.rect, new flash.geom.Point(0, 0),
			">", 0x00000000, 0x00000000, mask);
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
	
	public static inline function getChannelMask( r:Float, g:Float, b:Float ) {
		return ColorCode.fromRgba({ a:0, r:r, g:g, b:b });
	}
		
	public static inline function makeNicePalette(c:ColorCode, ?dark:ColorCode=0x0, ?light:ColorCode=0xFFFFFF, ?withAlpha=false) : Palette256 {
		var rgb = c.toRgb();
		var dark = dark.toRgb();
		var light = light.toRgb();
		var pal : Palette256 = new Array();
		var lightLimit = 200;
		var lightRange = 256-lightLimit;
		for (i in 0...256) {
			if (i < lightLimit)
				pal[i] = interpolate(dark, c, i/lightLimit);
			else
				pal[i] = interpolate(c, light, (i-lightLimit)/lightRange);
			if( withAlpha )
				pal[i] = 0xff<<24 | pal[i];
		}
		return pal;
	}
	
	public static inline function makePalette(fewColors:Array<ColorCode>) : Palette256 { // du sombre au clair
		var pal : Palette256 = [];
		var stepLength = 256/(fewColors.length-1);
		for (i in 0...256) {
			var step = i/stepLength;
			var col0 = fewColors[Std.int(step)];
			var col1 = fewColors[Std.int(step)+1];
			pal[i] = interpolate(col0, col1, step-Std.int(step));
		}
		return pal;
	}
	#end
	
	#if flash10
	public static function paintBitmap(bd:flash.display.BitmapData, redReplace:Palette256, greenReplace:Palette256, blueReplace:Palette256, ?yellowReplace:Palette256, ?pinkReplace:Palette256, ?cyanReplace:Palette256) {
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
							if (g==0 && b==0)		redReplace[r];
							else if (r==0 && b==0)	greenReplace[g];
							else if (r==0 && g==0)	blueReplace[b];
							else if (r!=0 && g!=0)	yellowReplace[r];
							else if (r!=0 && b!=0)	pinkReplace[r];
							else if (g!=0 && b!=0)	cyanReplace[g];
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
		
	#if flash9
	public static function drawPalette(colors:Palette256, g:flash.display.Graphics, ?wid=2, ?hei=32) {
		for(i in 0...colors.length) {
			g.beginFill(colors[i], 1);
			g.drawRect(i*wid, 0, wid,hei);
			g.endFill();
		}
	}
	#end
}



/*********************************************
 * ColorCode type definition
 */

 enum StandardColors {
	@col(0xFFFFFF) White;
	@col(0x000000) Black;
	@col(0x808080) Gray;
	@col(0x808080) Grey;
	
	@col(0xFF0000) Red;
	@col(0x00FF00) Green;
	@col(0x0000FF) Blue;
	
	@col(0xFF00FF) Pink;
	@col(0xFFFF00) Yellow;
	@col(0x00FFFF) Cyan;
	@col(0xFF8000) Orange;
 }

abstract ColorCode(UInt) from UInt to UInt {
	public inline function new(c:UInt) {
		this = c;
	}
	
	@:to public static inline function toString(c:ColorCode):String {
		var h = StringTools.hex(Std.int(c));
		var rgba = c.toRgba();
		while (h.length < (rgba.a==0 ? 6 : 8))
			h="0"+h;
		return "#"+h;// return '#$h ( R: ${Math.round(rgba.r*100)/100},  G: ${Math.round(rgba.g*100)/100},  B: ${Math.round(rgba.b*100)/100},  A:${Math.round(rgba.a*100)/100} )';
	}
	
	//@:from public static inline function fromEnum(cenum:StandardColors) { // !!!!!!!!!!! TODO BUG !!!!!!!!!!!!!!!!!
		//var m = Meta.getFields(mt.Color.StandardColors);
		//var c : UInt = Reflect.field(m, Std.string(cenum)).col;
		//return new ColorCode(c);
	//}
	
	
	// Hex
		
	@:from public static inline function fromHex(c:String) {
		if( c.charAt(0)!="#" )
			throw "Missing # at the beginning";
			
		var c = c.substr(1);
		if( c.length!=6 && c.length!=8 )
			throw "Invalid color code length (should be 6 or 8)";
		
		var ci = Std.parseInt("0x" + c);
		if( Math.isNaN(ci) )
			throw "Invalid color code "+c;
		return new ColorCode(ci);
	}
	@:to public static inline function toHex24(c:ColorCode) {
		var h = StringTools.hex(Std.int(c));
		while (h.length>6)
			h = h.substr(1);
		while (h.length<6)
			h="0"+h;
		return "#"+h;
	}
	@:to public static inline function toHex32(c:ColorCode) {
		var h : String = StringTools.hex(Std.int(c));
		while (h.length<8)
			h="0"+h;
		return "#"+h;
	}
	
	
	// RGB
	
	@:from public static inline function fromRgb(c:{r:Float, g:Float, b:Float}) : ColorCode {
		var u : UInt = (Std.int(c.r*255) << 16) | (Std.int(c.g*255)<<8 ) | Std.int(c.b*255);
		return u;
	}
	@:to public static inline function toRgb(c:UInt) : {r:Float, g:Float, b:Float} {
		return {
			r	: ((c>>16) & 0xFF) / 255,
			g	: ((c>>8) & 0xFF) / 255,
			b	: (c & 0xFF) / 255,
		};
	}
	
	// RGBA
	
	@:from public static inline function fromRgba(c:{r:Float, g:Float, b:Float, a:Float}) : ColorCode {
		return (Std.int(c.a*255) << 24) | (Std.int(c.r*255) << 16) | (Std.int(c.g*255)<<8 ) | Std.int(c.b*255);
	}
	@:to public static inline function toRgba(c:UInt) {
		return {
			a	: (c>>>24) / 255,
			r	: ((c>>16)&0xFF) / 255,
			g	: ((c>>8)&0xFF) / 255,
			b	: (c&0xFF) / 255,
		};
	}
	
	// HSL
	
	@:from public static inline function fromHsl(hsl:{h:Float, s:Float, l:Float}) {
		var rgba = {r:0., g:0., b:0., a:1.};
		
		if( hsl.s==0 )
			rgba.r = rgba.g = rgba.b = Math.round(hsl.l*255);
		else {
			var h = hsl.h*6;
			var i = Math.floor(h);
			var c1 = hsl.l * (1 - hsl.s);
			var c2 = hsl.l * (1 - hsl.s * (h-i));
			var c3 = hsl.l * (1 - hsl.s * (1 - (h-i)));
			
			if( i==0 )		{ rgba.r = hsl.l;	rgba.g = c3;		rgba.b = c1; }
			else if( i==1 )	{ rgba.r = c2;		rgba.g = hsl.l;		rgba.b = c1; }
			else if( i==2 )	{ rgba.r = c1;		rgba.g = hsl.l;		rgba.b = c3; }
			else if( i==3 )	{ rgba.r = c1;		rgba.g = c2;		rgba.b = hsl.l; }
			else if( i==4 )	{ rgba.r = c3;		rgba.g = c1;		rgba.b = hsl.l; }
			else 			{ rgba.r = hsl.l;	rgba.g = c1;		rgba.b = c2; }
		}
		
		var c : ColorCode = rgba;
		return c;
	}
	
	@:to public static inline function toHsl(c:ColorCode) {
		var rgb = c.toRgb();
		
		var min = if(rgb.r<=rgb.g && rgb.r<=rgb.b) rgb.r else if(rgb.g<=rgb.b) rgb.g else rgb.b;
		var max = if(rgb.r>=rgb.g && rgb.r>=rgb.b) rgb.r else if(rgb.g>=rgb.b) rgb.g else rgb.b;
		var delta = max-min;
		
		var hsl = { h:0., s:0., l:0. };
		hsl.l = max;
		if( delta!=0 ) {
			hsl.s = delta/max;
			var dr = ( (max-rgb.r)/6 + (delta/2) ) / delta;
			var dg = ( (max-rgb.g)/6 + (delta/2) ) / delta;
			var db = ( (max-rgb.b)/6 + (delta/2) ) / delta;
			
			if( rgb.r==max ) hsl.h = db-dg;
			else if( rgb.g==max ) hsl.h = 1/3 + dr-db;
			else if( rgb.b==max ) hsl.h = 2/3 + dg-dr;
			
			if( hsl.h<0 ) hsl.h++;
			if( hsl.h>1 ) hsl.h--;
		}
			
		return hsl;
	}
	
}


