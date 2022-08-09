package mt.deepnight;

#if !macro
import flash.display.Bitmap;
import flash.display.BitmapData;
import haxe.xml.Fast;
#end

import haxe.macro.Expr;
import haxe.macro.Context;


#if !macro 
typedef LibGroup = {id:String, wid:Int, hei:Int, frames:Array<{x:Int, y:Int}>, anim:Array<Int> };
#end


/** SPRITE *******************************************************************************************
 * 
 * 
 * 
 * 
 * 
 * */

#if !macro
class BSprite extends flash.display.Sprite
{
	public static var ALL : List<BSprite> = new List();
	
	public var lib(default,null)		: SpriteLibBitmap;
	public var group(default,null)		: Null<LibGroup>;
	public var groupName(default,null)	: Null<String>;
	public var frame(default,null)		: Int;
	public var destroyed(default, null ): Bool;
	
	var bmp				: Bitmap;
	
	var pt0				: flash.geom.Point;
	
	public var animCursor(default, null): Int;
	
	var curFrameCpt		: Float;
	var isPlaying		: Bool;
	//var animId			: Null<String>;
	var animFrames		: Array<Int>;
	var animPlays		: Int;
	
	public var onEndAnim		: Null<Void->Void>;
	public var onLoopAnim		: Null<Void->Void>;
	var killAfterAnim			: Bool;
	
	var needUpdate		: Bool;
	
	var pivotCoord		: Null<{x:Float, y:Float}>; // pixel coordinates, excluses pivotCoord 
	var pivotFactor		: Null<{xr:Float, yr:Float}>; // homogeneous coordinates : 0-1 (based on actual width/height) excludes pivotFactor
	
	public function new(l:SpriteLibBitmap, ?g:String, ?frame=0) {
		super();
		isPlaying = false;
		destroyed = false;
		killAfterAnim = false;
		this.cacheAsBitmap = false;
		pt0 = new flash.geom.Point(0, 0);
		curFrameCpt = 0;
		
		bmp = new Bitmap(flash.display.PixelSnapping.NEVER, false);
		addChild(bmp);
		
		setGroup(l, g, frame);
		setCenter(lib.defaultCenterX, lib.defaultCenterY);
	}
	
	public override function toString() {
		return "BSprite_"+groupName+"["+frame+"]";
	}
	
	public inline function applyFilter(f:flash.filters.BitmapFilter) {
		bmp.bitmapData.applyFilter(bmp.bitmapData, bmp.bitmapData.rect, pt0, f);
	}
	
	public function setGroup(?l:SpriteLibBitmap, g:String, ?frame=0) {
		if( l!=null )
			lib = l;
		groupName = g;
		
		if( isReady() ) {
			group = lib.getGroup(groupName);
			stopAnim();
			initBitmap();
			setFrame(frame);
		}
	}
	
	public function getAnimDuration() {
		var a = getAnim();
		return a!=null ? a.length : 0;
	}
	
	inline function getAnim() {
		return isReady() && group.anim.length>0 ? group.anim : null;
	}
	
	inline function hasAnim() {
		return getAnim()!=null;
	}
	
	public function getBitmapData() {
		return bmp.bitmapData;
	}
	
	public inline function isPlayingAnim() {
		return isPlaying;
	}
	
	public function isGroup(k) {
		return groupName==k;
	}
	
	function initBitmap() {
		if( !isReady() )
			return;
			
		if( bmp.bitmapData!=null && bmp.bitmapData.width==group.wid && bmp.bitmapData.height==group.hei ) {
			bmp.bitmapData.fillRect(bmp.bitmapData.rect, 0x0);
			return;
		}
		
		if( bmp.bitmapData!=null ) {
			#if debug
			trace("WARNING"+groupName+": re-allocation of bitmapdata occured");
			#end
			bmp.bitmapData.dispose();
		}
		
		bmp.bitmapData = new BitmapData(group.wid, group.hei, true, 0x0);
		applyPivot();
	}
	
	public inline function randomFrame(?rndFunc:Int->Int) {
		if( isReady() ) {
			if( rndFunc==null )
				rndFunc = Std.random;
			setFrame( rndFunc(lib.countFrames(groupName)) );
		}
	}
	
	public inline function setFrame(f:Int) {
		frame = f;
		if( isReady() )
			bmp.bitmapData.copyPixels( lib.source, lib.getRectangle(groupName, f), pt0, false );
	}
	
	public inline function setPivotCoord(x:Float, y:Float) {
		pivotCoord = {x:x, y:y}
		pivotFactor = null;
		applyPivot();
	}
	
	public inline function setCenter(xRatio:Float, yRatio:Float) {
		pivotCoord = null;
		pivotFactor = {xr:xRatio, yr:yRatio};
		applyPivot();
	}
	
	inline function applyPivot() {
		if( pivotCoord!=null ) {
			bmp.x = -Math.round(pivotCoord.x);
			bmp.y = -Math.round(pivotCoord.y);
		}
		else if( pivotFactor!=null ) {
			bmp.x = Std.int(-bmp.width*pivotFactor.xr);
			bmp.y = Std.int(-bmp.height*pivotFactor.yr);
		}
	}
	
	public function totalFrames() {
		return group.frames.length;
	}
	
	inline function startUpdates() {
		if( !needUpdate )
			ALL.push(this);
		needUpdate = true;
	}
	inline function stopUpdates() {
		if( needUpdate )
			ALL.remove(this);
		needUpdate = false;
	}
	
	public function destroy() {
		if( !destroyed ) {
			destroyed = true;
			if(parent!=null)
				parent.removeChild(this);
			if( bmp.bitmapData!=null )
				bmp.bitmapData.dispose();
			stopUpdates();
		}
	}
	
	public function restartAnim(?plays=999999) {
		playAnim(groupName, plays);
	}
	
	public function stopAnim(?frame:Int) {
		animFrames = new Array();
		isPlaying = false;
		if( frame!=null )
			setFrame(frame);
		stopUpdates();
	}
	
	inline function isReady() {
		return !destroyed && groupName!=null;
	}
	
	public function playAnim(g:String, ?plays=999999, ?killAfterPlay=false) {
		if( groupName==g )
			return;
			
		setGroup(g);
		
		var a = getAnim();
		
		if( a==null )
			return;
			
		killAfterAnim = killAfterPlay;
		
		isPlaying = true;
		curFrameCpt = 0;
		animCursor = 0;
		animPlays = plays;
		animFrames = a;
		startUpdates();
		setFrame(animFrames[0]);
	}
	
	public inline function offsetAnimFrame(?randFunc:Int->Int) {
		if( randFunc==null )
			animCursor = Std.random(animFrames.length);
		else
			animCursor = randFunc(animFrames.length);
	}
	
	inline function updateAnim(?tmod=1.0) { // requis seulement en cas d'anim
		if( animFrames.length>0 ) {
			curFrameCpt += tmod;
			
			while( !destroyed && curFrameCpt>1 ) {
				curFrameCpt--;
				animCursor++;
				if( animCursor>=animFrames.length ) {
					animCursor = 0;
					animPlays--;
					if(animPlays<=0) {
						if( killAfterAnim )
							destroy();
						else
							stopAnim();
							
						if( onEndAnim!=null ) {
							var cb = onEndAnim;
							onEndAnim = null;
							cb();
						}
					}
					else {
						setFrame(animFrames[animCursor]);
						if( onLoopAnim!=null )
							onLoopAnim() ;
					}
				}
				else
					setFrame(animFrames[animCursor]);
			}
		}
	}
	
	//DE : deprecate this to get it into module's main class
	public static inline function updateAll(?tmod=1.0) {
		for(s in ALL)
			s.updateAnim(tmod);
	}

	
}
#end




/** LIBRARY ********************************************************************************************/

class SpriteLibBitmap {
	#if !macro
	public var source			: BitmapData;
	var groups					: Hash<LibGroup>;
	var currentGroup			: Null<LibGroup>;
	var frameRandDraw			: Hash<Array<Int>>;
	public var defaultCenterX(default, null)	: Float;
	public var defaultCenterY(default, null)	: Float;
	var gridX					: Int;
	var gridY					: Int;
	
	public function new(bd:BitmapData) {
		source = bd;
		groups = new Hash();
		frameRandDraw = new Hash();
		defaultCenterX = 0;
		defaultCenterY = 0;
		gridX = gridY = 16;
	}
	
	
	public function get(k:String, ?frame=0) : BSprite {
		return new BSprite(this, k, frame);
	}
	
	public function getAndPlay(k:String, ?plays=99999, ?killAfterPlay=false) : BSprite {
		var s = new BSprite(this);
		s.playAnim(k, plays, killAfterPlay);
		return s;
	}
	
	
	public inline function setDefaultCenter(cx,cy) {
		defaultCenterX = cx;
		defaultCenterY = cy;
	}
	
	public function setSliceGrid(w,h) {
		gridX = w;
		gridY = h;
	}
	
	public inline function getGroup(?k:String) {
		return
			if(k==null ) {
				if( currentGroup==null )
					throw "No group selected previously";
				else
					currentGroup;
			}
			else
				if(groups.exists(k))
					groups.get(k);
				else
					throw "Unknown group "+k;
	}
	
	public inline function getGroups() {
		return groups;
	}
	
	public inline function getAnim(k) {
		return getGroup(k).anim;
	}
	
	public inline function getAnimDuration(k) {
		return getAnim(k).length;
	}
	
	public function createGroup(k:String, wid:Int, hei:Int) {
		if( groups.exists(k) )
			throw "group "+k+" already exists";
		groups.set(k, {
			id		: k,
			wid		: wid,
			hei		: hei,
			frames	: new Array(),
			anim	: new Array(),
		});
		return setCurrentGroup(k);
	}
	
	inline function setCurrentGroup(k:String) {
		currentGroup = getGroup(k);
		return getGroup();
	}
	
	
	public inline function getRectangle(k:String,?frame:Int=0) {
		var g = getGroup(k);
		var fr = g.frames[frame];
		if ( fr == null) throw "no such frame " + frame + " in group " + k;
		return new flash.geom.Rectangle(fr.x, fr.y, g.wid, g.hei);
	}
	
	public inline function getRandomFrame(k:String, ?randFunc:Int->Int) {
		if(randFunc==null)
			randFunc = Std.random;
			
		return
			if(frameRandDraw.exists(k)) {
				var a = frameRandDraw.get(k);
				a[ randFunc(a.length) ];
			}
			else
				randFunc(countFrames(k));
	}
	
	public inline function countFrames(k:String) {
		return getGroup(k).frames.length;
	}
	
	public inline function exists(k, ?frame=0) {
		if( !groups.exists(k) )
			return false;
		else if( frame>=getGroup(k).frames.length )
			return false;
		else
			return true;
	}
	
	public inline function getRandom(k:String, ?randFunc:Int->Int) : BSprite {
		return get(k, getRandomFrame(k, randFunc));
	}
	
	public inline function getMovieClip(k:String, ?frame=0, ?centerX, ?centerY) : flash.display.MovieClip {
		var mc = new flash.display.MovieClip();
		drawIntoGraphics(mc.graphics, k, frame, centerX, centerY);
		return mc;
	}
	
	public inline function drawIntoGraphics(g:flash.display.Graphics, k:String, ?frame=0, ?centerX, ?centerY) {
		if(centerX==null)	centerX = defaultCenterX;
		if(centerY==null)	centerY = defaultCenterY;
		var rect = getRectangle(k, frame);
		var m = new flash.geom.Matrix();
		m.translate(Std.int(-rect.x - centerX*rect.width), Std.int(-rect.y - centerY*rect.height));
		g.beginBitmapFill(source, m, false, false);
		g.drawRect(Std.int(-centerX*rect.width), Std.int(-centerY*rect.height), rect.width, rect.height);
		g.endFill();
	}
	
	public inline function drawIntoBitmap(bd:flash.display.BitmapData, x:Float,y:Float, k:String, ?frame=0, ?centerX, ?centerY) {
		if(centerX==null)	centerX = defaultCenterX;
		if(centerY==null)	centerY = defaultCenterY;
		var r = getRectangle(k, frame);
		bd.copyPixels(
			source, r,
			new flash.geom.Point(x-Std.int(r.width*centerX), y-Std.int(r.height*centerY)),
			true
		);
	}
	
	public function getBitmapData(k:String, ?frame=0, ?padding=0) {
		var r = getRectangle(k, frame);
		var bd = new BitmapData(Std.int(r.width+padding*2), Std.int(r.height+padding*2), true, 0x0);
		drawIntoBitmap(bd, padding,padding, k,frame, 0,0);
		return bd;
	}
	
	
	
	function sliceCustom(groupName:String, frame:Int, x:Int, y:Int, wid:Int, hei:Int) {
		var g = if( exists(groupName) ) getGroup(groupName) else createGroup(groupName, wid, hei);
		
		if( wid!=g.wid )
			throw "ERROR: width mismatch for frame "+frame+" in group "+groupName;
			
		if( hei!=g.hei )
			throw "ERROR: height mismatch for frame "+frame+" in group "+groupName;
			
		g.frames[frame] = { x:x, y:y };
	}
	
	public function slice(groupName:String, x:Int, y:Int, wid:Int, hei:Int, ?repeatX=1, ?repeatY=1) {
		var g = createGroup(groupName, wid, hei);
		setCurrentGroup(groupName);
		for(iy in 0...repeatY)
			for(ix in 0...repeatX)
				g.frames.push({ x : x+ix*g.wid, y : y+iy*g.hei});
	}
	
	public function sliceGrid(groupName:String, gx:Int, gy:Int, ?repeatX=1, ?repeatY=1) {
		var g = createGroup(groupName, gridX, gridY);
		setCurrentGroup(groupName);
		for(iy in 0...repeatY)
			for(ix in 0...repeatX)
				g.frames.push({ x : g.wid*(gx+ix), y : g.hei*(gy+iy) });
	}

	public function sliceMore(x:Int, y:Int, ?repeatX=1, ?repeatY=1) {
		var g = getGroup();
		for(iy in 0...repeatY)
			for(ix in 0...repeatX)
				g.frames.push({ x : x+ix*g.wid, y : y+iy*g.hei});
	}

	public function applyPermanentFilter(k:String, filter:flash.filters.BitmapFilter) {
		for( frame in 0...countFrames(k) ) {
			var r = getRectangle(k, frame);
			source.applyFilter(source, r, r.topLeft, filter);
		}
	}
	
	public function toString() {
		var l = [];
		for( k in getGroups().keys() ) {
			var g = getGroup(k);
			l.push(k+" ("+g.wid+"x"+g.hei+") : "+g.frames.length+" frame(s), "+(g.anim.length==0 ? "noAnim" : "animated("+g.anim.length+"f)" ));
		}
		return l.join("\n");
	}
		
	#end
	
	public static function parseAnimDefinition(animDef:String,?timin=1) {
		animDef = StringTools.replace(animDef, ")", "(");
		var frames : Array<Int> = new Array();
		var parts = animDef.split(",");
		for (p in parts) {
			var curTiming = timin;
			if( p.indexOf("(")>0 ) {
				var t = Std.parseInt( p.split("(")[1] );
				if( Math.isNaN(t) )
					throw "invalid frame duration in "+p;
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
					throw "end frame lower than start frame in "+p;
				while( from<to ) {
					for(i in 0...curTiming)
						frames.push(from);
					from++;
				}
				continue;
			}
			throw "invalid frames in "+p;
		}
		return frames;
	}
	
			
	public function __defineAnim(?group:String, anim:Array<Int>) {
		#if flash
		if( currentGroup==null && group==null )
			throw "No current group.";
		
		if( group!=null )
			setCurrentGroup(group);
			
		var a = [];
		for(f in anim) {
			if( f>=currentGroup.frames.length )
				throw "Anim frame "+f+" exceeds max frame in group "+currentGroup.id+" ("+currentGroup.frames.length+"f)";
			a.push(f);
		}
			
		currentGroup.anim = a;
		#end
	}
	
	
	
	
	#if macro
	static function error( ?msg="", p : Position ) {
		haxe.macro.Context.error("ERROR: "+msg,p);
	}
	#end
	
	
	/* MACRO: Shoebox import ********************************************************************************************
	 *
	 * NOTE: if found, "fileName.anims.xml" will also be imported
	 * EXAMPLE: importShoeBox("sheet.xml"); // will also look for sheet.anims.xml and use it for anims declaration
	 * ANIMATION XML FORMAT:
		<animations>
			<a group="idle"> 0-5 </a>
			<a group="run"> 0(2), 1-2(2), 3-10(1) </a>
			<a group="hit"> 0-2 </a>
			<a group="attack"> 0-5(2) </a>
		</animations>
		
		optionally you can specify the base frame timing i.e. 
		<a group="attack" timing="1"> 0-5(2) </a>
		
		will specify that base animtion timing is "repeat all frames one
		
		<a group="attack" timing="66"> 0-5(2) </a>
		
		will specify that base animtion timing is "repeat all frames 66 times 
		
		Base Timing is one.
	 */
	
	@:macro public static function importShoeBox(xmlUrl:String) {
		var p = Context.currentPos();
		
		xmlUrl = StringTools.replace(xmlUrl, "\\", "/");
		var path = xmlUrl.indexOf("/")>=0 ? xmlUrl.substr(0, xmlUrl.lastIndexOf("/")) : "";
		
		// XML parsing
		var file = try Context.resolvePath(xmlUrl) catch( e : Dynamic ) { error("File not found", p); null; }
		var fileContent = neko.io.File.getContent(file);
		var xml = new haxe.xml.Fast( Xml.parse(fileContent) );
		
		var sourceName = xml.node.TextureAtlas.att.imagePath;
		var r = ~/\.(png|gif|jpeg|jpg)/gi;
		var sourceType = {
			pos : p,
			pack : [],
			name : "_BITMAP_"+r.replace(sourceName, ""),
			meta : [{ name : ":bitmap", pos : p, params : [{ expr : EConst(CString(path+"/"+sourceName)), pos : p }] }],
			params : [],
			isExtern : false,
			fields : [],
			kind : TDClass({ pack : ["flash","display"], name : "BitmapData", params : [] }),
		};
		Context.defineType(sourceType);
		
		var zeroExpr = { expr:EConst(CInt("0")), pos:p }
		var newSourceExpr = { expr : ENew({pack:sourceType.pack, name:sourceType.name, params:[]}, [zeroExpr,zeroExpr]), pos:p }
		
		var fileContentExpr = { expr:EConst(CString(fileContent)), pos:p }

		
		// OPTIONAL: anim file
		var animUrl = StringTools.replace( xmlUrl, ".xml", ".anims.xml" );
		var animFile = try Context.resolvePath(animUrl) catch( e : Dynamic ) { null; }
		if( animFile!=null ) {
			var blockContent : Array<Expr> = [];
			// New lib declaration
			blockContent.push(
				macro var _lib = mt.deepnight.SpriteLibBitmap.parseShoeBoxXml($fileContentExpr, $newSourceExpr)
			);
			
			var fileContent = neko.io.File.getContent(animFile);
			var xml = new haxe.xml.Fast( Xml.parse(fileContent).firstChild() );
			var ecalls : Array<Expr> = [];
			for( a in xml.nodes.a ) {
				// Anim parsing
				var group = a.att.group;
				var frames = try{ parseAnimDefinition(a.innerHTML, a.has.timing ? Std.parseInt(a.att.timing):null); } catch(e:Dynamic) { error(animUrl+" parse error for group "+group.toUpperCase()+": "+e, p); null; };
				var egroup = { pos:p, expr:EConst(CString(group)) }
				var eframes = Lambda.array(Lambda.map( frames, function(f) return { pos:p, expr:EConst(CInt(""+f)) } ));
				var eframesArray = { pos:p, expr:EArrayDecl(eframes) };
				
				// Anim definition call
				blockContent.push(
					macro _lib.__defineAnim($egroup, $eframesArray)
				);
			}
			
			// block return
			blockContent.push( macro _lib );
			
			return { pos:p, expr:EBlock(blockContent) }
		}
		else
			return macro mt.deepnight.SpriteLibBitmap.parseShoeBoxXml($fileContentExpr, $newSourceExpr);
	}
	
	
	#if !macro
	public static function parseShoeBoxXml(xmlString:String, source:BitmapData, ?importSequencesAsFrames=true) {
		var lib = new SpriteLibBitmap(source);
		var xml = new haxe.xml.Fast( Xml.parse(xmlString) );
		try {
			for(atlas in xml.nodes.TextureAtlas) {
				for(sub in atlas.nodes.SubTexture) {
					var id = sub.att.name;
					var x = Std.parseInt(sub.att.x);
					var y = Std.parseInt(sub.att.y);
					var wid = Std.parseInt(sub.att.width);
					var hei = Std.parseInt(sub.att.height);
					var r = ~/\.(png|gif|jpeg|jpg)/gi;
					id = r.replace(id, "");
					if( importSequencesAsFrames ) {
						var r = ~/([0-9]*)$/;
						r.match(id);
						var frame = Std.parseInt(r.matched(1));
						if( !Math.isNaN(frame) ) {
							// Multiple frames
							var id2 = id.substr(0, r.matchedPos().pos);
							while( id2.length>0 && id2.charAt(id2.length-1)=="_" )
								id2 = id2.substr(0, id2.length-1);
							lib.sliceCustom(id2, frame, x,y, wid,hei);
						}
						else
							lib.slice(id, x,y, wid,hei );
					}
					else
						lib.slice(id, x,y, wid,hei );
				}
			}
		}
		catch(e:Dynamic) {
			throw "Failed to parse ShoeBox XML : "+e;
		}

		return lib;
	}
	#end
	
	
	
	
	/* MACRO : Animation declaration ********************************************************************************************
	 *
	 * SYNTAX 1: frame[(optional_duration)], frame[(optional_duration)], ...
	 * SYNTAX 2: begin-end[(optional_duration)], begin-end[(optional_duration)], ...
	 *
	 * EXAMPLE: defineAnim( "walk", "0-5, 6(2), 7(1)" );
	 */
	@:macro public function defineAnim(ethis:Expr, ?groupName:String, ?baseFrame:Int, ?animDefinition:Expr) : Expr {
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
	
	#if !macro
	public static inline function updateAll(?tmod=1.0) {
		mt.deepnight.BSprite.updateAll( tmod );
	}
	#end
}



