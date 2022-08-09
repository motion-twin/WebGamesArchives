package mt.pix;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import haxe.EnumFlags;

enum ElementFlags {
	EF_FLIP_X;
	EF_FLIP_Y;
}

class Element extends flash.display.Sprite {

	public static var DEFAULT_ALIGN_X = 0.5;
	public static var DEFAULT_ALIGN_Y = 0.5;
	public static var DEFAULT_STORE:Store;

	public static var MAT = new Matrix();
	
	public var store:Store;
	public var frameAlignX:Float;
	public var frameAlignY:Float;
	public var currentFrame:Frame;
	
	// ANIM
	public var anim:Anim;
	public var currentAnimString:String;
	public var flags : haxe.EnumFlags<ElementFlags>; //any write should trigger a redraw
	
	#if(nme||flax)
	public var nmeChunk : Array<Float> = null;
	#end
	
	public var copy : Bool = false;
	public var bmp : Bitmap;
	
	public function new( ?store) {
		super();
		frameAlignX = DEFAULT_ALIGN_X;
		frameAlignY = DEFAULT_ALIGN_Y;
		this.store = store==null?DEFAULT_STORE:store;
	
		flags = EnumFlags.ofInt(0);
		
		#if(nme||flax)
		nmeChunk = [];
		this.store.reg( this );
		#end
	}
	
	public function redraw() {
		if( currentFrame!=null) {
			drawFrame(currentFrame, frameAlignX, frameAlignY );
			if( anim != null ) stop();
		}
	}
	
	// V2
	public function goto(?id:Int,?str:String,?fx:Float,?fy:Float) {
		drawFrame(store.get(id, str), fx, fy);
		if( anim != null ) stop();
	}
	
	public function shuffleDir() {
		rotation = Std.random(4) * 90;
		scaleX = Std.random(2) * 2 - 1;
		scaleY = Std.random(2) * 2 - 1;
	}
	
	// ANIM
	public function play(str:String, loop = true, frame=0) {
		if( !store.timelines.exists(str) ) throw( "anim " + str + " not found !");
		if( anim == null ) ANIMATED.push(this);
		anim = new Anim(this);
		anim.loop = loop;
		anim.timeline = store.getTimeline(str);
		anim.goto(frame);
		drawFrame(anim.getCurrentFrame());
		currentAnimString = str;
	}
	
	public function stop() {
		if( anim == null )return;
		anim = null;
		ANIMATED.remove(this);
	}
	
	public function hasAnim(str) {
		return store.timelines.exists(str);
	}
	
	public function updateAnim() {
		anim.update();
		if( anim != null && visible ) {
			var fr = anim.getCurrentFrame();
			if( fr != currentFrame )
				drawFrame(fr);
		}
	}
	
	public function swapAnim(newAnim:mt.pix.Anim) {
		newAnim.cursor = 	anim.cursor;
		newAnim.loop = 		anim.loop;
		anim = newAnim;
	}
	public inline function isPlaying() { return anim != null; }
	
	// HIT TEST
	public function hitTest( x:  Float , y : Float )  {
       var bmp :flash.display.BitmapData = currentFrame.texture;
       var fr = currentFrame;
       var ox = -Std.int(fr.width * frameAlignX);
       var oy = -Std.int(fr.height * frameAlignY);
       ox += fr.ddx;
       oy += fr.ddy;
       var tx = fr.x - ox +x;
       var ty = fr.y - oy +y;
       var pix = bmp.getPixel32( Std.int(tx), Std.int(ty));
       return (pix & 0xFF000000) != 0;
   }
	
   public inline function xor(v0,v1) {
		if( v0 != v1 )
			return true;
		else
			return false;
   }

	
	// DRAW FROM FRAME
	public function drawFrame(fr:Frame, ?fax:Float, ?fay:Float) {
		
		if(fax != null) frameAlignX = fax;
		if(fay != null) frameAlignY = fay;
		
		var ox = -Std.int(fr.width * frameAlignX);
		var oy = -Std.int(fr.height * frameAlignY);
		ox += fr.ddx;
		oy += fr.ddy;
		var x = - (fr.x - ox);
		var y = - (fr.y - oy);
		currentFrame = fr;
				
		#if(nme||flax)
		switch( store.nmeDrawTileMode  ) 
		{
			case NTM_NO_DRAW: return;
			case NTM_NONE:
				
			case NTM_SINGLE:
			#if !flax
			graphics.clear();
			graphics.lineStyle();
			store.nmeTs.drawTiles( graphics,  [ox, oy, fr.nmeFr] );
			#else throw "unsupported"; #end
			return;
			
			case NTM_COMMIT_TO_STORE:
			#if !flax
			nmeChunk = [this.x, this.y, fr.nmeFr];
			currentFrame = fr;
			#else throw "unsupported"; #end
			return;
		}
		#end
		
		if ( fr.rot !=null && fr.rot !=0 ) {
			copy = false;
		}
		
		var swapX = xor( fr.swapX, flags.has(EF_FLIP_X));
		var swapY = xor( fr.swapY, flags.has(EF_FLIP_Y));
		
		if ( !copy ) {
			if ( bmp != null) {
				if ( bmp.parent != null ) bmp.parent.removeChild( bmp );
				bmp.bitmapData.dispose();
				bmp.bitmapData = null;
				bmp = null;
			}
			
			var m = MAT;
			m.identity();
			m.translate(x, y);
			if( swapX ) 		m.scale( -1, 1);	// BUG : WORK ONLY WITH ALIGN 0.5
			if( swapY ) 		m.scale( 1, -1);	// BUG : WORK ONLY WITH ALIGN 0.5
			if( fr.rot != null )	m.rotate(fr.rot);	// BUG : WORK ONLY WITH ALIGN 0.5
			
			graphics.clear();
			graphics.lineStyle();
			graphics.beginBitmapFill(fr.texture, m );
			graphics.drawRect(ox, oy, fr.width, fr.height);
			graphics.endFill();
		}
		else {
			graphics.clear();
			var clearBmp = false;
			
			if( bmp!=null){
				if ( bmp.width != fr.width ) clearBmp = true;
				if ( bmp.height != fr.height ) clearBmp = true;
				
				//copy = false;
				//drawFrame(fr, fax, fay );
				//return;
			}
			
			if (clearBmp && bmp != null) { 
				if ( bmp.parent != null ) bmp.parent.removeChild( bmp );
				bmp.bitmapData.dispose();
				bmp.bitmapData = null;
				bmp = null;
			}
			
			if ( bmp == null ) {
				var h = fr.height == 0?1:fr.height;
				var w = fr.width == 0?1:fr.width;
				bmp = new Bitmap( new BitmapData(w,h), PixelSnapping.NEVER, false);
				addChild(bmp);
			}
			
			if ( !swapX)	bmp.x = -bmp.width * 0.5;
			else 			bmp.x = bmp.width * 0.5;
			
			if ( !swapY)	bmp.y = -bmp.height*0.5;
			else			bmp.y = bmp.height*0.5;
			
			rsrc.x = fr.x;
			rsrc.y = fr.y;
			rsrc.width = fr.width;
			rsrc.height = fr.height;
			
			//pdst.x = x;
			//pdst.y = y;
			bmp.scaleX = !swapX?1.0: -1.0;
			bmp.scaleY = !swapY?1.0: -1.0;
			bmp.bitmapData.copyPixels( fr.texture, rsrc, pdst);
		}
	}
	
	public static var rsrc = new Rectangle();
	public static var pdst = new flash.geom.Point();
	
	
	public function setAlign(x, y) {
		frameAlignX = x;
		frameAlignY = y;
	}
	
	public function pxx() {
		x = Math.round(x);
		y = Math.round(y);
	}
	
	public inline function dispose() kill();
	public function kill() {
		stop();
		if (parent != null) parent.removeChild(this);
		#if nme 
		store.unreg(this);
		#end
	}
	
	// ANIMATOR
	static public var ANIMATED:Array<Element> = [];
	public static function updateAnims() {
		var a = ANIMATED.copy();
		for( el in  a ) el.updateAnim();
	}
}
