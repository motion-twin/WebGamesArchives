package mt.motion;

import mt.deepnight.slb.HSprite;
import mt.deepnight.slb.BLib;

/**
 * ...
 * @author Tipyx
 */

typedef DataJSON = {
	var _frameRate:Int;
	var textureGroups:Array<TextureGroup>;
	var _movies:Array<Movie>;
}

typedef TextureGroup = {
	var _atlases:Array<Atlas>;
	var _scaleFactor:Int;
}

typedef Atlas = {
	var _textures:Array<Texture>;
	var _file:String;
}

typedef Texture = {
	var _symbol:String;
	var _rect:Array<Int>;
	var _origin:Array<Int>;
}

typedef Movie = {
	var _layers:Array<Layer>;
	var _id:String;
}

typedef Layer = {
	var _name:String;
	var _keyframes:Array<KeyFrame>;
}

typedef KeyFrame = {
	var _duration:Int;
	var _index:Int;
	var _ref:String;
	var _tweened:Bool;
	var _loc:Array<Float>;			// 0:X/1:Y
	var _pivot:Array<Float>;		// 0:X/1:Y
	var _alpha:Float;				// alpha
	var _skew:Array<Float>;			// 0:skewY/1:skewX
	var _scale:Array<Float>;		// 0:ScaleX/1:ScaleY
	var _ease:Float;				// easing
}
 
class FlumpTP // Bon pour Obfu o/
{
	static var AR_LIB		: Array<{name:String, blib:BLib, data:DataJSON}>	= [];
	
	public static function CREATE(name:String, jsonPath:String, blib:BLib) {
		for (lib in AR_LIB)
			if (lib.name == name)
				return;
				
		var js = openfl.Assets.getBytes(jsonPath);
		var jsString = js.toString();
		jsString = ~/"([A-Z0-9_]+)":/gi.replace(jsString,"\"_$1\":");
		//trace(jsString);
		var stringJson:DataJSON = haxe.Json.parse(jsString);
		
		AR_LIB.push( { name:name, blib:blib, data:stringJson } );
	}

	public static function GET(nameLib:String, nameMovie:String, loop:Bool):FlumpElement {
		var dataJS:DataJSON = null;
		var blib = null;
		
		for (lib in AR_LIB)
			if (lib.name == nameLib) {
				dataJS = lib.data;
				blib = lib.blib;
			}
		
		var feOut = new FlumpElement();
		feOut.loop = loop;
		
	// The movie asked is a Texture
		if (blib.exists(nameMovie)) {
			var hs = blib.h_get(nameMovie);
			hs.filter = true;
			hs.emit = true;
			feOut.s.addChild(hs);
			
			feOut.arTexture.push(hs);
			
			feOut.nameLib = nameLib;
			feOut.nameMovie = nameMovie;
			
			return feOut;		
		}
		
		for (m in dataJS._movies) {
			if (nameMovie == m._id) {
				feOut.nameLib = nameLib;
				feOut.nameMovie = nameMovie;
				feOut.arLayers = m._layers;
			}
		}
		
		return feOut;
	}
	
	public static function DESTROY() {
		AR_LIB = [];
	}
}

class FlumpElement {
	
	public var nameMovie	: String;
	public var nameLib		: String;
	public var loop			: Bool;
	public var isTexture	: Bool;
	
	public var s			: h2d.Sprite;
	public var arFE			: Array < { fe:FlumpElement, 
										tx:mt.motion.Tween,
										ty:mt.motion.Tween,
										tr:mt.motion.Tween,
										tscaleX:mt.motion.Tween,
										tscaleY:mt.motion.Tween } > ;
	//public var arTexture	: Array<h2d.Bitmap>;
	public var arTexture	: Array<HSprite>;
	
	public var arLayers		: Array<Layer>;
	
	public var tweener		: mt.motion.Tweener;
	
	public var buildTween	: FlumpElement->Void;
	public var init			: FlumpElement->Void;
	
	public var rx			: Float;
	public var ry			: Float;
	public var px			: Float;
	public var py			: Float;
	public var initX		: Float;
	public var initY		: Float;
	public var arChildPivot	: Array<Float>;
	
	public var duration		: Int;
	var c					: Int;
	
	var isPaused			: Bool;
	
	public function new() {
		tweener = new mt.motion.Tweener();
		
		s = new h2d.Sprite();
		
		arFE = [];
		
		arLayers = [];
		
		arTexture = [];
		
		arChildPivot = [0, 0];
		
		duration = 0;
		c = 0;
		
		initX = initY = rx = ry = px = py = 0;
		
		isPaused = true;
		isTexture = false;
	}
	
	public function setPivot() {
		
		
		for (fe in arFE) {
			fe.fe.px = -arChildPivot[0];
			fe.fe.py = -arChildPivot[1];
		}
		
		for (t in arTexture) {
			t.x = -arChildPivot[0];
			t.y = -arChildPivot[1];
		}
	}
	
	public function launchAnim() {
	// RESET
		for (fe in arFE) {
			fe.fe.destroy();
			fe.fe = null;
		}
		
		tweener.dispose();
		
		tweener = new mt.motion.Tweener();
		
		arFE = [];
	
		duration = c = 0;
		
		for (l in arLayers) {
			var subFE = FlumpTP.GET(nameLib, l._keyframes[0]._ref, true);
			
		// INIT
			var k = l._keyframes[0];
			subFE.arChildPivot = k._pivot != null ? k._pivot : [0, 0];
			subFE.rx = (k._loc != null ? k._loc[0] : 0);
			subFE.ry = (k._loc != null ? k._loc[1] : 0);
			subFE.s.rotation = (k._skew != null ? k._skew[0] : 0);
			subFE.s.scaleX = (k._scale != null ? k._scale[0] : 1);
			subFE.s.scaleY = (k._scale != null ? k._scale[1] : 1);			
			
			var tx = null;
			var ty = null;
			var tr = null;
			var tscaleX = null;
			var tscaleY = null;
			
			var kf = l._keyframes;
			
		// ANIM
			for (i in 0...kf.length) {
				var k = kf[i];
				if (i < kf.length - 1) {
					var kp = kf[i + 1];
					// X/Y
					if (tx == null)
						tx = tweener.create();
					tx.to(k._duration, subFE.rx = (kp._loc != null ? kp._loc[0] : 0))/*.delay(2)*/;
					if (ty == null)
						ty = tweener.create();
					ty.to(k._duration, subFE.ry = (kp._loc != null ? kp._loc[1] : 0))/*.delay(2)*/;
					// ROTATION
					if (tr == null)
						tr = tweener.create();
					tr.to(k._duration, subFE.s.rotation = (kp._skew != null) ? kp._skew[0] : 0)/*.delay(2)*/;
					// SCALE
					if (tscaleX == null)
						tscaleX = tweener.create();
					tscaleX.to(k._duration, subFE.s.scaleX = kp._scale != null ? kp._scale[0] : 1)/*.delay(2)*/;
					if (tscaleY == null)
						tscaleY = tweener.create();
					tscaleY.to(k._duration, subFE.s.scaleY = kp._scale != null ? kp._scale[1] : 1)/*.delay(2)*/;
				}
			}
			
			var lastKF = l._keyframes[l._keyframes.length - 1];
			if (lastKF._duration + lastKF._index > duration)
				duration = lastKF._duration + lastKF._index;
			
			arFE.push( { fe:subFE, tx:tx, ty:ty, tr:tr, tscaleX:tscaleX, tscaleY:tscaleY } );
			
			s.addChild(subFE.s);
			
			subFE.launchAnim();
		}
		
		isPaused = false;
		
		setPivot();
	}
	
	public function pause() {
		isPaused = true;
		for (fe in arFE)
			fe.fe.pause();
	}
	
	public function resume() {
		isPaused = false;
		for (fe in arFE)
			fe.fe.resume();
	}
	
	public function destroy() {
		for (fe in arFE) {
			fe.fe.destroy();
		}
		
		arFE = [];
		
		for (t in arTexture) {
			t.dispose();
			t = null;
		}
		
		arTexture = [];
		
		s.dispose();
		s = null;
		
		tweener.dispose();
	}
	//
	public function update() {
		if (!isPaused) {
			if (c > 0)
				tweener.update();
				
			for (fe in arFE) {
				fe.fe.update();
			}
			
			c++;
			
			if (c == duration + 1 && duration > 0) {
				if (loop) {
					launchAnim();
					
					update();
					
					return;
				}
				else
					for (fe in arFE)
						fe.fe.pause();
			}
		}
		
		s.x = Std.int(initX + rx + px);
		s.y = Std.int(initY + ry + py);
	}
}