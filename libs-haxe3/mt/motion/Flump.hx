package mt.motion;

/**
 * ...
 * @author Tipyx
 */

typedef DataJSON = {
	var frameRate:Int;
	var textureGroups:Array<TextureGroup>;
	var movies:Array<Movie>;
}

typedef TextureGroup = {
	var atlases:Array<Atlas>;
	var scaleFactor:Int;
}

typedef Atlas = {
	var textures:Array<Texture>;
	var file:String;
}

typedef Texture = {
	var symbol:String;
	var rect:Array<Int>;
	var origin:Array<Int>;
}

typedef Movie = {
	var layers:Array<Layer>;
	var id:String;
}

typedef Layer = {
	var name:String;
	var keyframes:Array<KeyFrame>;
}

typedef KeyFrame = {
	var duration:Int;
	var index:Int;
	var ref:String;
	var tweened:Bool;
	var loc:Array<Float>;		// 0:X/1:Y
	var pivot:Array<Float>;		// 0:X/1:Y
	var alpha:Float;			// alpha
	var skew:Array<Float>;		// 0:skewY/1:skewX
	var scale:Array<Float>;		// 0:ScaleX/1:ScaleY
	var ease:Float;				// easing
}
 
class Flump
{
	static var AR_MOVIES	: Array<FlumpElement>		= [];
	static var AR_TEXTURE	: Array<FlumpElement>		= [];
	
	static var AR_LIB		: Array<{name:String, arTile:Array<{tile:h2d.Tile, id:String}>, data:DataJSON}>	= [];
	
	public static function CREATE(arPngPath:Array<String>, jsonPath:String, name:String) {
		for (lib in AR_LIB)
			if (lib.name == name)
				return;
		
		var arTile = [];
		
		for (pngPath in arPngPath) {
			var s = pngPath.split("/");
			var id = s[s.length - 1];
			
			var bd = openfl.Assets.getBitmapData(pngPath);
			var tilePNG = h2d.Tile.fromBitmap(hxd.BitmapData.fromNative(bd));
			
			arTile.push( { tile:tilePNG, id:id } );
		}
		
		var js = openfl.Assets.getBytes(jsonPath);
		var stringJson:DataJSON = haxe.Json.parse(js.toString());
		
		AR_LIB.push( { name:name, arTile:arTile, data:stringJson } );
	}

	public static function GET(nameLib:String, nameMovie:String, loop:Bool):FlumpElement {
		var data = null;
		var arTile = [];
		
		for (lib in AR_LIB)
			if (lib.name == nameLib) {
				data = lib.data;
				arTile = lib.arTile;
			}
		
		var feOut = new FlumpElement();
		feOut.loop = loop;
		
	// The movie asked is a Texture
		for (tg in data.textureGroups) {
			for (a in tg.atlases) {
				for (t in a.textures) {
					if (t.symbol == nameMovie) {
						for (tile in arTile) {
							if (tile.id == a.file) {
								
								var tile = tile.tile.sub(t.rect[0], t.rect[1], t.rect[2], t.rect[3]);
								var bmp = new h2d.Bitmap(tile);
								bmp.filter = true;
								feOut.s.addChild(bmp);
								
								feOut.arTexture.push(bmp);
								
								feOut.nameLib = nameLib;
								feOut.nameMovie = nameMovie;
								
								return feOut;								
							}
						}
					}
				}
			}
		}
		
		for (m in data.movies) {
			if (nameMovie == m.id) {
				feOut.nameLib = nameLib;
				feOut.nameMovie = nameMovie;
				feOut.arLayers = m.layers;
			}
		}
		
		return feOut;
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
	public var arTexture	: Array<h2d.Bitmap>;
	
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
			var subFE = Flump.GET(nameLib, l.keyframes[0].ref, true);
			
		// INIT
			var k = l.keyframes[0];
			subFE.arChildPivot = k.pivot != null ? k.pivot : [0, 0];
			subFE.rx = (k.loc != null ? k.loc[0] : 0);
			subFE.ry = (k.loc != null ? k.loc[1] : 0);
			subFE.s.rotation = (k.skew != null ? k.skew[0] : 0);
			subFE.s.scaleX = (k.scale != null ? k.scale[0] : 1);
			subFE.s.scaleY = (k.scale != null ? k.scale[1] : 1);			
			
			var tx = null;
			var ty = null;
			var tr = null;
			var tscaleX = null;
			var tscaleY = null;
			
			var kf = l.keyframes;
			
		// ANIM
			for (i in 0...kf.length) {
				var k = kf[i];
				if (i < kf.length - 1) {
					var kp = kf[i + 1];
					// X/Y
					if (tx == null)
						tx = tweener.create();
					tx.to(k.duration, subFE.rx = (kp.loc != null ? kp.loc[0] : 0))/*.delay(2)*/;
					if (ty == null)
						ty = tweener.create();
					ty.to(k.duration, subFE.ry = (kp.loc != null ? kp.loc[1] : 0))/*.delay(2)*/;
					// ROTATION
					if (tr == null)
						tr = tweener.create();
					tr.to(k.duration, subFE.s.rotation = (kp.skew != null) ? kp.skew[0] : 0)/*.delay(2)*/;
					// SCALE
					if (tscaleX == null)
						tscaleX = tweener.create();
					tscaleX.to(k.duration, subFE.s.scaleX = kp.scale != null ? kp.scale[0] : 1)/*.delay(2)*/;
					if (tscaleY == null)
						tscaleY = tweener.create();
					tscaleY.to(k.duration, subFE.s.scaleY = kp.scale != null ? kp.scale[1] : 1)/*.delay(2)*/;
				}
			}
			
			var lastKF = l.keyframes[l.keyframes.length - 1];
			if (lastKF.duration + lastKF.index > duration)
				duration = lastKF.duration + lastKF.index;
			
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