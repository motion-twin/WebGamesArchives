package mt.heaps.slib;

import mt.MLib;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;

#else

import mt.heaps.slib.SpriteInterface;
import h2d.SpriteBatch;

#end

typedef FrameData = {
	x			: Int,
	y			: Int,
	wid			: Int,
	hei			: Int,
	realFrame	: {x:Int, y:Int, realWid:Int, realHei:Int},
	?pX			: Float,
	?pY			: Float,
	?tile		: Null<h2d.Tile>,
}

typedef LibGroup = {
	id		: String,
	maxWid	: Int,
	maxHei	: Int,
	frames	: Array<FrameData>,
	anim	: Array<Int>,
};

enum SLBError {
	NoGroupSelected;
	GroupAlreadyExists(g:String);
	InvalidFrameDuration(s:String);
	EndFrameLower(s:String);
	InvalidFrames(s:String);
	NoCurrentGroup;
	AnimFrameExceeds(id:String, anim:String, frame:Int);
	AssetImportFailed(e:Dynamic);
	NotSameSLBFromBatch;
}


/** LIBRARY ********************************************************************************************/

class SpriteLib {
	#if !macro
	var groups					: Map<String, LibGroup>;
	//var frameRandDraw			: Map<String, Array<Int>>;
	public var defaultCenterX(default, null)	: Float;
	public var defaultCenterY(default, null)	: Float;

	// Slicer variables
	var currentGroup			: Null<LibGroup>;
	var gridX					: Int;
	var gridY					: Int;
	var children				: Array<SpriteInterface>;

	public var bitmapData(default,null)	: Null<hxd.BitmapData>;
	public var tile(default,null)		: h2d.Tile;
	//public var texture(get,never)		: h3d.mat.Texture; inline function get_texture() return tile.getTexture();

	public function new(t:h2d.Tile, ?bd:hxd.BitmapData) {
		groups = new Map();
		//frameRandDraw = new Map();
		defaultCenterX = 0;
		defaultCenterY = 0;
		gridX = gridY = 16;
		children = [];

		this.tile = t;
		this.bitmapData = bd;
	}


	public function reloadUsing(l:SpriteLib) {
		trace("old="+tile.width+"x"+tile.height);
		trace("new="+l.tile.width+"x"+l.tile.height);
		//tile = h2d.Tile.fromTexture( l.tile.getTexture() );
		tile.switchTexture(l.tile);
		groups = l.groups;
		currentGroup = null;

		for(s in children) {
			if( !exists(s.groupName) )
				throw "Group "+s.groupName+" is missing from the target SLib";
			s.set(this, s.groupName, s.frame>=countFrames(s.groupName) ? 0 : s.frame, false);
			trace(s);
			if( s.anim.hasAnim() )
				s.anim.getCurrentAnim().frames = getGroup(s.groupName).anim;
		}
	}


	public function destroy() {
		if( tile!=null)
			tile.dispose();
		tile = null;

		while( children.length>0 )
			children[0].remove();
	}

	public function sameTile(t:h2d.Tile) {
		return tile.getTexture().id==t.getTexture().id;
	}


	public inline function setDefaultCenterRatio(rx:Float,ry:Float) {
		defaultCenterX = rx;
		defaultCenterY = ry;
	}

	public function setSliceGrid(w,h) {
		gridX = w;
		gridY = h;
	}

	public inline function getGroup(?k:String) {
		return
			if(k==null )
				currentGroup;
			else
				groups.get(k);
	}

	public inline function getGroups() {
		return groups;
	}

	public inline function getAnim(k) {
		return getGroup(k).anim;
	}

	public inline function getAnimDurationF(k) {
		return getAnim(k).length;
	}

	public function createGroup(k:String) {
		if( groups.exists(k) )
			throw SLBError.GroupAlreadyExists(k);
		groups.set(k, {
			id		: k,
			maxWid	: 0,
			maxHei	: 0,
			frames	: new Array(),
			anim	: new Array(),
		});
		return setCurrentGroup(k);
	}

	inline function setCurrentGroup(k:String) {
		currentGroup = getGroup(k);
		return getGroup();
	}


	public inline function getFrameData(k:String, ?frame = 0) : Null<FrameData> {
		var g = getGroup(k);
		if( g==null )
			return null;
		else
			return g.frames[frame];
	}

	public inline function exists(k:String,?frame=0) {
		return k!=null && frame>=0 && groups.exists(k) && groups.get(k).frames.length>frame;
	}

	public inline function getRandomFrame(k:String, ?rndFunc:Int->Int) {
		return (rndFunc==null ? Std.random : rndFunc)( countFrames(k) );

		//if(rndFunc==null)
			//rndFunc = Std.random;

		//return
			//if(frameRandDraw.exists(k)) {
				//var a = frameRandDraw.get(k);
				//a[ rndFunc(a.length) ];
			//}
			//else
				//rndFunc(countFrames(k));
	}

	public inline function countFrames(k:String) {
		if( !exists(k) )
			throw "Unknown group "+k;
		return getGroup(k).frames.length;
	}



	/******************************************************
	* ATLAS INIT FUNCTIONS
	******************************************************/

	public function sliceCustom(groupName:String, frame:Int, x:Int, y:Int, wid:Int, hei:Int, ?realFrame:{x:Int, y:Int, realWid:Int, realHei:Int}, ?pX:Float,?pY:Float) {
		var g = if( exists(groupName) ) getGroup(groupName) else createGroup(groupName);
		g.maxWid = MLib.max( g.maxWid, wid );
		g.maxHei = MLib.max( g.maxHei, hei );

		if( realFrame==null )
			realFrame = {x:0, y:0, realWid:wid, realHei:hei}

		g.frames[frame] = { x:x, y:y, wid:wid, hei:hei, realFrame:realFrame, pX:pX, pY:pY };
	}

	public function slice(groupName:String, x:Int, y:Int, wid:Int, hei:Int, ?repeatX=1, ?repeatY=1) {
		var g = createGroup(groupName);
		setCurrentGroup(groupName);
		g.maxWid = MLib.max( g.maxWid, wid );
		g.maxHei = MLib.max( g.maxHei, hei );
		for(iy in 0...repeatY)
			for(ix in 0...repeatX)
				g.frames.push({ x : x+ix*wid, y : y+iy*hei, wid:wid, hei:hei, realFrame:{x:0,y:0,realWid:wid,realHei:hei} });
	}

	public function sliceGrid(groupName:String, gx:Int, gy:Int, ?repeatX=1, ?repeatY=1) {
		var g = createGroup(groupName);
		setCurrentGroup(groupName);
		g.maxWid = MLib.max( g.maxWid, gridX );
		g.maxHei = MLib.max( g.maxHei, gridY );
		for(iy in 0...repeatY)
			for(ix in 0...repeatX)
				g.frames.push({ x : gridX*(gx+ix), y : gridY*(gy+iy), wid:gridX, hei:gridY, realFrame:{x:0,y:0,realWid:gridX,realHei:gridY} });
	}

	public function sliceAnim(groupName:String, frameDuration:Int, x:Int, y:Int, wid:Int, hei:Int, ?repeatX=1, ?repeatY=1) {
		slice(groupName, x, y, wid, hei, repeatX, repeatY);
		var frames = [];
		for(f in 0...repeatX*repeatY)
			for(i in 0...frameDuration)
				frames.push(f);
		__defineAnim(groupName, frames);
	}

	public function sliceAnimGrid(groupName:String, frameDuration:Int, gx:Int, gy:Int, ?repeatX=1, ?repeatY=1) {
		sliceGrid(groupName, gx, gy, repeatX, repeatY);
		var frames = [];
		for(f in 0...repeatX*repeatY)
			for(i in 0...frameDuration)
				frames.push(f);
		__defineAnim(groupName, frames);
	}

	//public function sliceMore(x:Int, y:Int, ?repeatX=1, ?repeatY=1) {
		//var g = getGroup();
		//for(iy in 0...repeatY)
			//for(ix in 0...repeatX)
				//g.frames.push({ x : x+ix*g.wid, y : y+iy*g.hei, wid:g.wid, hei:g.hei });
	//}

	public function multiplayAllAnimDurations(factor:Int) {
		for(g in getGroups())
			if( g.anim.length>0 ) {
				var old = g.anim.copy();
				g.anim = [];
				for(f in old)
					for(i in 0...factor)
						g.anim.push(f);
			}
	}


	//public function offsetOneBasedFrames() {
		//for(g in groups) {
			//for(i in 1...g.frames.length)
				//g.frames[i-1] = g.frames[i];
			//g.frames.pop();
				//
			//for(i in 0...g.anim.length)
				//g.anim[i] = g.anim[i]-1;
		//}
	//}



	public function toString() {
		var l = [];
		for ( k in getGroups().keys() ) {
			var g = getGroup(k);
			l.push(
				k+" ("+g.maxWid+"x"+g.maxHei+")" +
				( g.frames.length>1 ? " "+g.frames.length+"f" : "" ) +
				( g.anim.length>1 ? " animated("+g.anim.length+"f)" : "" )
			);
		}
		l.sort(function(a,b) return Reflect.compare(a,b));
		return "| "+l.join("\n| ");
	}


	public function listAnims() {
		var l = [];
		for ( k in getGroups().keys() ) {
			var g = getGroup(k);
			if( g.anim.length>1 )
				l.push(k+" ("+g.maxWid+"x"+g.maxHei+") : "+g.frames.length+" frame(s), anim("+g.anim.length+"f)" );
		}
		l.sort(function(a,b) return Reflect.compare(a,b));
		return l;
	}


	public function addChild(s:SpriteInterface) {
		children.push(s);
	}

	public function removeChild(s:SpriteInterface) {
		children.remove(s);
	}

	public inline function countChildren() {
		return children.length;
	}

	public function updateChildren(dt:Float) {
		for(bs in children)
			if( !bs.destroyed ) {
				bs.anim.update(dt);
				if( bs.beforeRender!=null )
					bs.beforeRender();
			}
	}



	/******************************************************
	* HEAPS API
	******************************************************/

	public inline function h_get(k:String, ?frame=0, ?xr=0., ?yr=0., ?filter:Null<Bool>, ?p:h2d.Sprite) : HSprite {
		var s = new HSprite(this, k, frame);
		if( p!=null )
			p.addChild(s);
		s.setCenterRatio(xr,yr);
		if( filter!=null )
			s.filter = filter;
		return s;
	}

	public inline function h_getRandom(k, ?rndFunc, ?p:h2d.Sprite) : HSprite {
		return h_get(k, getRandomFrame(k, rndFunc), p);
	}

	public inline function h_getAndPlay(k:String, ?plays=99999, ?killAfterPlay=false, ?p:h2d.Sprite) : HSprite {
		var s = h_get(k, p);
		s.anim.play(k, plays);
		if( killAfterPlay )
			s.anim.killAfterPlay();
		return s;
	}



	public inline function hbe_get(sb:SpriteBatch, k:String, ?frame=0, ?xr=0., ?yr=0.) : HSpriteBE {
		var e = new HSpriteBE(sb, this, k, frame);
		e.setCenterRatio(xr,yr);
		return e;
	}

	public inline function hbe_getRandom(sb:SpriteBatch, k, ?rndFunc) : HSpriteBE {
		return hbe_get(sb, k, getRandomFrame(k, rndFunc));
	}

	public inline function hbe_getAndPlay(sb:SpriteBatch, k:String, plays=99999, ?killAfterPlay=false) : HSpriteBE {
		var s = hbe_get(sb, k);
		s.anim.play(k, plays);
		if( killAfterPlay )
			s.anim.killAfterPlay();
		return s;
	}

	public function be_get(k:String, ?f=0, ?xr=0., ?yr=0.) : BatchElement {
		var e = new h2d.SpriteBatch.BatchElement( getTile(k,f) );
		e.t.setCenterRatio(xr,yr);
		return e;
	}

	public inline function be_getRandom(k:String, ?f=0, ?xr=0., ?yr=0., ?rndFunc) : BatchElement {
		return be_get(k, getRandomFrame(k, rndFunc));
	}

	//public function addBatchElement(sb:SpriteBatch, k:String, frame:Int, ?xr=0.0, ?yr=0.0) : Null<h2d.SpriteBatch.BatchElement> {
		//if (sb.tile.getTexture() != tile.getTexture())
			//throw SLBError.NotSameSLBFromBatch;
//
		//var be = sb.alloc(tile);
		//var fd = getFrameData(k, frame);
		//if( fd==null )
			//throw 'Unknown group $k#$frame!';
//
		//be.t.setPos(fd.x, fd.y);
		//be.t.setSize(fd.wid, fd.hei);
//
		//#if fixCenter
		//be.t = be.t.center(
			//Std.int(fd.realFrame.x + fd.realFrame.realWid*xr),
			//Std.int(fd.realFrame.y + fd.realFrame.realHei*yr)
		//);
		//#else
		//be.t = be.t.center(fd.realFrame.x, fd.realFrame.y);
		//be.t.setCenterRatio(xr,yr);
		//#end
//
		//return be;
	//}
//
	//public function addColoredBatchElement(sb:SpriteBatch, ?priority=0, k:String, col:UInt, ?alpha=1.0) {
		//var e = addBatchElement(sb, priority, k, 0);
		//e.color = h3d.Vector.fromColor( Color.addAlphaF(col, alpha), 1 );
		//return e;
	//}
//
	//public function addBatchElementRandom(sb:SpriteBatch, k:String, ?xr=0.0, ?yr=0.0, ?rndFunc:Int->Int) : Null<h2d.SpriteBatch.BatchElement> {
		//return addBatchElement(sb, k, getRandomFrame(k, rndFunc), xr,yr);
	//}
//
//
//
	//public inline function getColoredH2dBitmap(k:String, col:UInt, ?alpha=1.0, ?filter:Null<Bool>, ?parent:h2d.Sprite) {
		//var e = getH2dBitmap(k, filter, parent);
		//e.color = h3d.Vector.fromColor(mt.deepnight.Color.addAlphaF(col, alpha),1);
		//return e;
	//}
//
	//public inline function getH2dBitmap(k:String, ?frame=0, ?xr=0.0, ?yr=0.0, ?filter:Null<Bool>, ?parent:h2d.Sprite, ?sh:h2d.Drawable.DrawableShader) : h2d.Bitmap {
		//if( !exists(k,frame) )
			//throw "Unknown group "+k+"#"+frame;
		//var b = new h2d.Bitmap( getTile(k,frame), sh );
		//if( parent!=null )
			//parent.addChild(b);
//
		//var fd = getFrameData(k,frame);
		//#if fixCenter
		//b.tile = b.tile.center(
			//Std.int(fd.realFrame.x + fd.realFrame.realWid*xr),
			//Std.int(fd.realFrame.y + fd.realFrame.realHei*yr)
		//);
		//#else
		//b.tile.setCenterRatio(xr,yr);
		//#end
//
		//if( filter!=null )
			//b.filter = filter;
		//return b;
	//}

	public function getTile(g:String, ?frame=0, ?px:Float=0.0,?py:Float=0.0) : h2d.Tile {
		return updTile(tile.clone(),g,frame,px,py);
	}

	public function updTile(t:h2d.Tile,g:String, ?frame=0, ?px:Float=0.0,?py:Float=0.0) : h2d.Tile {
		var fd = getFrameData(g, frame);
		if ( fd == null)
			throw 'Unknown group $g#$frame!';
		
		t.setPos(fd.x, fd.y);
		t.setSize(fd.wid, fd.hei);

		t.dx = -Std.int( (fd.realFrame.realWid + fd.realFrame.x)*px );
		t.dy = -Std.int( (fd.realFrame.realHei + fd.realFrame.y)*py );

		return t;
	}


	public function getBitmapData(k:String, ?f=0 ) : Null<hxd.BitmapData> {
		if( bitmapData==null )
			return null;

		var fd = getFrameData(k,f);
		return bitmapData.sub(fd.x, fd.y, fd.wid, fd.hei);
	}

	public function getTileRandom(g:String, ?px:Float=0.0,?py:Float=0.0, ?rndFunc) : h2d.Tile {
		return getTile(g, getRandomFrame(g,rndFunc), px, py);
	}
	
	public function getCachedTile( g:String, ?frame=0 ) : h2d.Tile {
		var fd = getFrameData(g, frame);
		if ( fd == null)
			throw 'Unknown group $g#$frame!';
		if( fd.tile == null )
			fd.tile = getTile(g,frame);
		return fd.tile;
	}
	
	public function getCachedTileRandom( g: String , ?rndFunc ) : h2d.Tile {
		return getCachedTile(g, getRandomFrame(g,rndFunc));
	}

	//public function getTileWithPivot(g:String, ?frame = 0) : h2d.Tile {
		//var fd = getFrameData(g, frame);
		//if ( fd.pX == null && fd.pY == null ) return getTile(g, frame);
//
		//#if debug
		//if ( fd == null)
			//throw 'Unknown group $g#$frame!';
		//#end
		//var t = tile.clone();
		//t.setPos(fd.x, fd.y);
		//t.setSize(fd.wid, fd.hei);
		//t.setCenterRatio( fd.pX==null?0:fd.pX, fd.pX==null?0:fd.pY );
//
		//return t;
	//}





	#end // End of #if !macro


	/**********************************************
	 * MACRO SECTION
	 **********************************************/

	public static function parseAnimDefinition(animDef:String,?timin=1) {
		animDef = StringTools.replace(animDef, ")", "(");
		var frames : Array<Int> = new Array();
		var parts = animDef.split(",");
		for (p in parts) {
			var curTiming = timin;
			if( p.indexOf("(")>0 ) {
				var t = Std.parseInt( p.split("(")[1] );
				if( Math.isNaN(t) )
					throw SLBError.InvalidFrameDuration(p);
				curTiming = t;
				p = p.substr( 0, p.indexOf("(") );
			}
			if( p.indexOf("-")<0 ) {
				var f = Std.parseInt(p);
				for(i in 0...curTiming)
					frames.push(f);
				continue;
			}
			if( p.indexOf("-")>0 ) {
				var from = Std.parseInt(p.split("-")[0]);
				var to = Std.parseInt(p.split("-")[1])+1;
				if( to<from )
					throw SLBError.EndFrameLower(p);
				while( from<to ) {
					for(i in 0...curTiming)
						frames.push(from);
					from++;
				}
				continue;
			}
			throw SLBError.InvalidFrames(p);
		}
		return frames;
	}


	public function __defineAnim(?group:String, anim:Array<Int>) {
		#if !macro
		if( currentGroup==null && group==null )
			throw SLBError.NoCurrentGroup;

		if( group!=null )
			setCurrentGroup(group);

		for(f in anim)
			if( f>=currentGroup.frames.length )
				throw SLBError.AnimFrameExceeds(currentGroup.id, "["+anim.join(",")+"] "+currentGroup.frames.length, f);

		currentGroup.anim = anim;
		#end
	}




	#if macro
	static function error( ?msg="", p : Position ) {
		haxe.macro.Context.error(msg, p);
	}
	#end


	/* MACRO : Animation declaration ********************************************************************************************
	 *
	 * SYNTAX 1: frame[(optional_duration)], frame[(optional_duration)], ...
	 * SYNTAX 2: begin-end[(optional_duration)], begin-end[(optional_duration)], ...
	 *
	 * EXAMPLE: defineAnim( "walk", "0-5, 6(2), 7(1)" );
	 */
	public macro function defineAnim(ethis:Expr, ?groupName:String, ?baseFrame:Int, ?animDefinition:Expr) : Expr {
		var p = ethis.pos;
		var def = animDefinition;

		function parseError(str:String) {
			error(str + "\nSYNTAX: frame[(duration)], frame[(duration)], begin-end([duration]), ...", def.pos);
		}

		// Parameters
		if( isNull(def) && groupName==null )
			error("missing anim declaration", p);

		if( isNull(def) && groupName!=null ) {
			def = {expr:EConst(CString(groupName)), pos:p};
			groupName = null;
		}

		if( baseFrame==null )
			baseFrame = 0;

		if( isNull(def) )
			parseError("animation definition is required");

		var str = switch(def.expr) {
			case EConst(c) :
				switch( c ) {
					case CString(s) : s;
					default :
						parseError("a constant string is required here");
						null;
				}
			default :
				parseError("a constant string is required here");
				null;
		}

		var frames : Array<Int> = try{ parseAnimDefinition(str); } catch(e:Dynamic) { parseError(e); null; }

		var eframes = Lambda.array(Lambda.map(frames, function(f) return { pos:p, expr:EConst( CInt(Std.string(f)) ) } ));
		var arrayExpr = { pos:p, expr:EArrayDecl(eframes) };

		if( groupName==null )
			return macro $ethis.__defineAnim($arrayExpr);
		else {
			var groupExpr = { pos:p, expr:EConst(CString(groupName)) };
			return macro $ethis.__defineAnim($groupExpr, $arrayExpr);
		}
	}


	#if macro
	static function isNull(e:Expr) {
		switch(e.expr) {
			case EConst(c) :
				switch( c ) {
					case CIdent(v) : return v=="null";
					default :
						return false;
				}
			default :
				return false;
		}
	}
	#end
}



