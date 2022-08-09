package mt.deepnight;

import mt.flash.DepthManager;
import mt.MLib;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

typedef UnsignedInt = #if flash UInt #else Int #end;

class Buffer {
	// **** à ajouter à la display list
	public var render(default,null)	: Sprite;

	var container			: Sprite;

	public var width(default,null)		: Int;
	public var height(default,null)		: Int;
	public var upscale(default,null)	: Float;

	public var graphics			: flash.display.Graphics;
	public var dm				: DepthManager;
	public var rect(get, never)	: flash.geom.Rectangle;
	var pt0						: flash.geom.Point;

	var pixelRatio				: Float; // =width/height (ex: =2/1)

	var bdCont					: Sprite;
	var renderBD				: BitmapData;
	public var texture			: Null<Bitmap>;
	public var postFilters		: Array<flash.filters.BitmapFilter>;
	public var colorTransform	: Null<flash.geom.ColorTransform>;

	public var fl_transparent(default,null)		: Bool;
	public var bgColor(default,null)			: Int;
	public var fl_scale2x(default,null)			: Bool;

	public var alphaLoss		: Float;
	public var onRender			: Null< Void->Void >;
	#if flash11_3
	public var drawQuality		: Null<flash.display.StageQuality>;
	#end

	public function new(w:Float,h:Float,up, fl_transp:Bool, col:Int, ?useScale2x=false, ?pixelRatio=1.0) {
		width = MLib.ceil(w);
		height = MLib.ceil(h);
		upscale = up;
		postFilters = new Array();
		container = new Sprite();
		graphics = container.graphics;
		alphaLoss = 1;
		pt0 = new flash.geom.Point(0, 0);
		fl_scale2x = useScale2x;
		this.pixelRatio = pixelRatio;
		#if flash11_3
		if( Lib.getFlashVersion()>=11.3 )
			drawQuality = flash.display.StageQuality.MEDIUM;
		#end

		dm = new DepthManager(container);

		fl_transparent = fl_transp;
		bgColor = col;

		render = new Sprite();
		bdCont = new Sprite();
		render.addChild(bdCont);
		if(fl_scale2x) {
			var sqrt = Math.sqrt(upscale);
			var up = Std.int(upscale);
			if( upscale<2 || up!=upscale || up & (up-1) != 0 )
				throw "BUFFER : upscale must a power of 2 to use Scale2X (2,4,8,...)";

			if( width % 2!=0 || height % 2!=0 )
				throw "BUFFER : width & height must be multiples of 2";

			renderBD = new BitmapData(Std.int(width*upscale), Std.int(height*upscale), fl_transparent, bgColor);
			var bmp = new Bitmap(renderBD);
			bdCont.addChild( bmp );
		}
		else {
			renderBD = new BitmapData(width, height, fl_transparent, bgColor);
			var bmp = new Bitmap(renderBD, flash.display.PixelSnapping.ALWAYS, false);
			bdCont.addChild(bmp);
			bdCont.scaleX = upscale;
			bdCont.scaleY = upscale / pixelRatio;
		}
	}

	public function toString() {
		return width+"x"+height+"x"+upscale;
	}

	public function resize(w:Float, h:Float, up) {
		if( fl_scale2x )
			throw "Not supported for scale2x yet";

		width = MLib.ceil(w);
		height = MLib.ceil(h);
		upscale = up;

		if( renderBD!=null )
			renderBD.dispose();
		renderBD = new BitmapData(width, height, fl_transparent, bgColor);

		bdCont.removeChildren();
		bdCont.addChild( new Bitmap(renderBD, flash.display.PixelSnapping.ALWAYS, false) );
		bdCont.scaleX = upscale;
		bdCont.scaleY = upscale / pixelRatio;
	}

	public function setScale(s:Float) {
		upscale = s;
		bdCont.scaleX = upscale;
		bdCont.scaleY = upscale / pixelRatio;
	}

	public function createSimilarBitmap(?transparent:Bool) {
		return new BitmapData(width, height, if(transparent!=null) transparent else fl_transparent, bgColor);
	}

	public function clone() {
		var bd = new BitmapData(width, height, fl_transparent, bgColor);
		copyPixels(bd);
		return bd;
	}

	public inline function getBitmapData() {
		return renderBD;
	}

	public inline function copyPixels( target:BitmapData, ?rect:flash.geom.Rectangle ) {
		if( rect==null )
			rect = new flash.geom.Rectangle(0,0,width,height);
		target.copyPixels(renderBD, rect, pt0, true);
	}

	public function setTexture(t:BitmapData, alpha:Float, ?blendMode:flash.display.BlendMode, fl_disposeBitmap:Bool) {
		if(blendMode==null)
			blendMode = flash.display.BlendMode.OVERLAY;
		var w = Std.int( width*upscale );
		var h = Std.int( height*upscale );
		if (texture!=null) {
			texture.bitmapData.dispose();
			texture.bitmapData = null;
			texture.parent.removeChild(texture);
		}
		texture = new Bitmap( new BitmapData(w, h) );
		render.addChild(texture);
		var spr = new Sprite();
		var g = spr.graphics;
		g.beginBitmapFill(t, true, false);
		g.drawRect(0,0,w, h);
		g.endFill();
		texture.bitmapData.draw(spr);
		texture.blendMode = blendMode;
		texture.alpha = alpha;
		if (fl_disposeBitmap)
			t.dispose();
	}

	public static function makeScanline(h:Float, ?col=0x0) {
		var h = mt.MLib.round(h);
		var bd = new BitmapData(h,h, false, 0x808080);
		for(x in 0...10)
			bd.setPixel(x, h-1, col);
		return bd;
	}

	public static function makeMosaic(wid:Float, ?white=1.0, ?black=1.0) {
		var wid = Std.int(wid);
		var bd = new BitmapData(wid,wid, true, 0x808080);

		var w = Color.addAlphaF(0xE0E0E0, white);
		var b = Color.addAlphaF(0x0, black);

		bd.setPixel32(0, 0, w);
		bd.setPixel32(wid-1, wid-1, b);
		for(x in 1...wid-1) {
			bd.setPixel32(x, 0, w);
			//bd.setPixel32(x, 1, 0xffffff);
			bd.setPixel32(x, wid-1, b);
		}
		var w = Color.addAlphaF(0xFFFFFF, white);
		for(y in 1...wid-1) {
			bd.setPixel32(0, y, w);
			bd.setPixel32(wid-1, y, b);
		}
		return bd;
	}

	public static function makeMosaic2(wid:Float, ?col=0xffffff) {
		var wid = Std.int(wid);
		var bd = new BitmapData(wid,wid, true, 0xff808080);

		var w = Color.addAlphaF(col);

		for(x in 1...wid-1)
			bd.setPixel32(x, 0, w);
		return bd;
	}

	public static function makeGrid(wid:Float, hei:Float, ?col=0x0) {
		var wid = mt.MLib.round(wid);
		var hei = mt.MLib.round(hei);
		var bd = new BitmapData(wid,hei, true, 0xff808080);

		var c = Color.addAlphaF(col);

		for(x in 0...wid)
			bd.setPixel32(x, 0, c);

		for(y in 0...hei)
			bd.setPixel32(0, y, c);

		return bd;
	}

	public inline function get_rect() {
		return new flash.geom.Rectangle(render.x, render.y, width, height);
	}

	public inline function addChild(o:flash.display.DisplayObject) {
		container.addChild(o);
	}

	public inline function addStaticChild(o:flash.display.DisplayObject) {
		o.cacheAsBitmap = true;
		container.addChild(o);
	}

	public inline function addChildAt(o:flash.display.DisplayObject, idx:Int) {
		container.addChildAt(o, idx);
	}

	public function destroyed() {
		return renderBD==null;
	}

	public inline function getContainer() {
		return container;
	}

	public function destroy() {
		renderBD.dispose();
		renderBD = null;
		graphics = null;
		container = null;
		if (render.parent!=null)
			render.parent.removeChild(render);
	}

	public inline function getRealScale() {
		return if(fl_scale2x) upscale else 1;
	}


	public function setHandCursor(b:Bool) {
		render.useHandCursor = render.buttonMode = b;
	}

	public function globalToLocal(x:Float,y:Float) {
		return {
			x	: Std.int( (x-render.x)/upscale ),
			y	: Std.int( (y-render.y)/upscale ),
		}
	}

	public function localToGlobal(x:Float,y:Float) {
		return {
			x	: Std.int(x*upscale + render.x),
			y	: Std.int(y*upscale + render.y),
		}
	}
	public function localToGlobalFloat(x:Float,y:Float) {
		return {
			x	: x*upscale + render.x,
			y	: y*upscale + render.y,
		}
	}

	public function getDebugView() {
		var spr = new Sprite();
		spr.addChild(container);
		var outline = new Sprite();
		spr.addChild(outline);
		var g = outline.graphics;
		g.lineStyle(2,0xffff00,1);
		g.drawRect(0,0,width, height);
		return spr;
	}

	public inline function scale2x() {
		var t = flash.Lib.getTimer();
		var memBuf = renderBD.getPixels(new flash.geom.Rectangle(0,0,Std.int(renderBD.width/2), Std.int(renderBD.height/2)) );
		var lineLength = renderBD.width*2;
		var tlineLength = renderBD.width*4;
		var end : UnsignedInt = memBuf.position;
		var pos : UnsignedInt = lineLength;

		#if flash
		memBuf.length = memBuf.length + (renderBD.width * renderBD.height * 4 );
		#elseif nme
		var oriBuf = memBuf;
		var memBuf = new nme.utils.ByteArray( memBuf.length + (renderBD.width * renderBD.height * 4 ) );
		memBuf.writeBytes(oriBuf, 0, oriBuf.length);
		#end

		flash.Memory.select(memBuf);

		var wid = renderBD.width/2;
		var x = 0;
		var p = 0;
		var right = 0;
		var tpos = end + pos*2;

		// Scale2X algorithm (source: http://scale2x.sourceforge.net/algorithm.html)
		while(pos<end) {
			var a = flash.Memory.getI32(pos-lineLength);
			var b = flash.Memory.getI32(pos+4);
			var c = p;
			var d = flash.Memory.getI32(pos+lineLength);
			p = right;
			right = b;

			var ab = a==b;
			var ac = a==c;
			var ad = a==d;
			var bc = b==c;
			var bd = b==d;
			var cd = c==d;
			flash.Memory.setI32(tpos, (ac && !cd && !ab ? a : p)); // haut-gauche
			flash.Memory.setI32(tpos+4, (ab && !ac && !bd ? b : p)); // haut-droite
			flash.Memory.setI32(tpos+tlineLength, (cd && !bd && !ac ? c : p)); // bas-gauche
			flash.Memory.setI32(tpos+4+tlineLength, (bd && !ab && !cd ? d : p)); // bas-droite
			pos+=4;
			tpos+=8;
			if(++x==wid) {
				x = 0;
				tpos+=tlineLength;
			}
		}
		memBuf.position = end;
		renderBD.setPixels(renderBD.rect, memBuf);
		return flash.Lib.getTimer()-t;
	}


	public inline function getMouse() {
		return {
			bx	: bdCont.mouseX,
			by	: bdCont.mouseY,
		}
	}

	public function update() {
		if( !destroyed() ) {
			// Fade out
			if (alphaLoss>0)
				if (alphaLoss>=1)
					renderBD.fillRect(renderBD.rect, bgColor);
				else
					renderBD.colorTransform(renderBD.rect, new flash.geom.ColorTransform(1,1,1, 1-alphaLoss));

			#if flash11_3
			if( drawQuality!=null )
				renderBD.drawWithQuality(container, false, drawQuality);
			else
				renderBD.draw(container);
			#else
			renderBD.draw(container);
			#end

			// Filtres post-rendu
			for(f in postFilters)
				renderBD.applyFilter(renderBD, renderBD.rect, pt0, f);
			if( colorTransform!=null )
				renderBD.colorTransform(renderBD.rect, colorTransform);

			if(onRender!=null)
				onRender();
			if(fl_scale2x) {
				var pow = 1;
				while(Math.pow(2,pow)<=upscale) {
					scale2x();
					pow++;
				}
			}
		}
	}
}
