package mt.deepnight.retro;

#if flash
import flash.display.Bitmap;
import flash.display.BitmapData;
#end

import haxe.macro.Expr;
import haxe.macro.Context;


/** SPRITE ********************************************************************************************/

#if flash
class BSprite extends flash.display.Sprite {
	public static var ALL : List<BSprite> = new List();
	
	public var lib(default,null)		: Null<SpriteLibBitmap>;
	public var libGroup(default,null)	: Null<String>;
	public var frame(default,null)		: Int;
	var bmp				: Bitmap;
	var destroyed		: Bool;
	
	var pt0				: flash.geom.Point;
	
	var animCursor		: Int;
	var frameCpt		: Float;
	var animId			: Null<String>;
	var animFrames		: Array<Int>;
	var animPlays		: Int;
	
	public var onEndAnim		: Null<Void->Void>;
	public var onLoopAnim		: Null<Void->Void>;
	public var killAfterAnim	: Bool;
	public var defaultAnim		: Null<String>;
	
	var needUpdate		: Bool;
	var pivotCoord		: Null<{x:Float, y:Float}>; // coordinates
	var pivotFactor		: Null<{xr:Float, yr:Float}>; // 0-1 (based on actual width/height)
	//var centerX			: Float;
	//var centerY			: Float;
	//var pivotMode		: Bool;
	
	public function new(?l:SpriteLibBitmap, ?g:String, ?frame=0) {
		super();
		lib = l;
		libGroup = g;
		destroyed = false;
		//pivotMode = false;
		
		bmp = new Bitmap(flash.display.PixelSnapping.NEVER, false);
		addChild(bmp);
		
		if( lib!=null )
			setCenter(lib.defaultCenterX, lib.defaultCenterY);
		else
			setCenter(0,0);
			
		if( libGroup!=null )
			initBitmap();
			
		frameCpt = 0;
		killAfterAnim = false;
		pt0 = new flash.geom.Point(0, 0);
		cacheAsBitmap = true;
		setFrame(frame);
	}
	
	public inline function applyFilter(f:flash.filters.BitmapFilter) {
		bmp.bitmapData.applyFilter(bmp.bitmapData, bmp.bitmapData.rect, pt0, f);
	}
	
	public function swap(?lib:SpriteLibBitmap, k:String, ?frame=0) {
		if( lib!=null )
			this.lib = lib;
		if( lib==null && this.lib==null )
			throw "This sprite is not associated with any lib";
		libGroup = k;
		initBitmap();
		setFrame(frame);
		stopAnim();
	}
	
	function initBitmap() {
		if( bmp.bitmapData!=null )
			bmp.bitmapData.dispose();
		
		var g = lib.getGroup(libGroup);
		bmp.bitmapData = new BitmapData(g.wid, g.hei, true, 0x0);
		applyPivot();
	}
	
	public override function toString() {
		return "BSprite_"+libGroup+"["+frame+"]";
	}
	
	public inline function randomFrame(?rndFunc:Int->Int) {
		if( lib!=null && libGroup!=null ) {
			if( rndFunc==null )
				rndFunc = Std.random;
			setFrame( rndFunc(lib.countFrames(libGroup)) );
		}
	}
	
	public inline function setFrame(f:Int) {
		frame = f;
		if( !destroyed && lib!=null && libGroup!=null )
			bmp.bitmapData.copyPixels( lib.source, lib.getRectangle(libGroup, f), pt0, false );
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
	
	public inline function totalFrames() {
		return lib.getGroup(libGroup).frames.length;
	}
	
	inline function startUpdates() {
		if(!needUpdate)
			ALL.push(this);
		needUpdate = true;
		cacheAsBitmap = false;
	}
	inline function stopUpdates() {
		if(needUpdate)
			ALL.remove(this);
		needUpdate = false;
		cacheAsBitmap = true;
	}
	
	inline public function destroy() {
		if( !destroyed ) {
			destroyed = true;
			if(parent!=null)
				parent.removeChild(this);
			if( bmp.bitmapData!=null )
				bmp.bitmapData.dispose();
			stopUpdates();
		}
	}
	
	public function stopAnim(?frame:Int) {
		animFrames = new Array();
		animId = null;
		if( frame!=null )
			setFrame(frame);
		stopUpdates();
		if( defaultAnim!=null )
			playAnim(defaultAnim);
	}
	
	public function playAnim(id:String, ?plays=999999) {
		if(id==animId || lib==null || libGroup==null)
			return;
		animId = id;
		frameCpt = 0;
		animCursor = 0;
		animPlays = plays;
		animFrames = lib.getAnim(libGroup, id);
		startUpdates();
		setFrame(animFrames[0]);
	}
	
	public inline function offsetAnimFrame(?randFunc:Int->Int) {
		if( randFunc==null )
			animCursor = Std.random(animFrames.length);
		else
			animCursor = randFunc(animFrames.length);
	}
	
	public inline function isPlaying(id) {
		return animId==id;
	}
	
	public inline function hasAnim() {
		return animId!=null;
	}
	
	inline function updateAnim(?tmod=1.0) { // requis seulement en cas d'anim
		if( animFrames.length>0 ) {
			frameCpt+=tmod;
			
			while( !destroyed && frameCpt>1 ) {
				frameCpt--;
				animCursor++;
				if(animCursor>=animFrames.length) {
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
	
	
	public static inline function updateAll(?tmod=1.0) {
		var all = ALL;
		for(s in all)
			s.updateAnim(tmod);
	}
}
#end



/** LIBRARY ********************************************************************************************/

#if flash
typedef SpriteBitmapGroup = {wid:Int, hei:Int, frames:Array<{x:Int, y:Int}>, anims:Hash<Array<Int>> };
#end

class SpriteLibBitmap {
	#if flash
	public var source			: BitmapData;
	var groups					: Hash<SpriteBitmapGroup>;
	var currentGroup			: Null<SpriteBitmapGroup>;
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
	
	public inline function getAnim(k, id) {
		var g = getGroup(k);
		if( !g.anims.exists(id) )
			throw "Unknown anim '"+id+"' in '"+k+"'";
		else
			return g.anims.get(id);
	}
	
	public inline function getAnimDuration(k, id) {
		return getAnim(k, id).length;
	}
	
	public function createGroup(k:String, wid:Int, hei:Int) {
		if( groups.exists(k) )
			throw "group "+k+" already exists";
		groups.set(k, {
			wid		: wid,
			hei		: hei,
			frames	: new Array(),
			anims	: new Hash(),
		});
		return setCurrentGroup(k);
	}
	
	inline function setCurrentGroup(k:String) {
		currentGroup = getGroup(k);
		return getGroup();
	}
	
	public inline function getRectangle(k:String, ?frame=0) {
		var g = getGroup(k);
		return new flash.geom.Rectangle(g.frames[frame].x, g.frames[frame].y, g.wid, g.hei);
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
	
	public inline function get(k:String, ?frame=0) : BSprite {
		return new BSprite(this, k, frame);
	}
	
	public inline function getAndPlay(k:String, animId:String, ?plays=9999999) : BSprite {
		var s = new BSprite(this, k);
		s.playAnim(animId, plays);
		return s;
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
			var a = 0;
			for(ak in g.anims)
				a++;
			l.push(k+" ("+g.wid+"x"+g.hei+") : "+g.frames.length+" frame(s), "+a+" anim(s)");
		}
		return l.join("\n");
	}
		
	#end
	
	public function __defineAnim(name:String, anim:Array<{f:Int, d:Int}>) {
		#if flash
		if( currentGroup==null )
			throw "No current group.";
			
		var a = [];
		for(af in anim)
			for(i in 0...af.d) {
				if( af.f>=currentGroup.frames.length )
					throw "Anim frame exceeds max frame in this group";
				a.push(af.f);
			}
			
		currentGroup.anims.set(name, a);
		#end
	}
	
	
	
	/** SHOEBOX IMPORT ********************************************************************************************/
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
	public static function parseShoeBoxXml2(xmlString:String, ?importSequencesAsFrames=true) {
		var slices = new Array();
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
							slices.push({k:id2, f:frame, x:x, y:y, w:wid, h:hei});
							//lib.sliceCustom(id2, frame, x,y, wid,hei);
						}
						else
							slices.push({k:id, f:0, x:x, y:y, w:wid, h:hei});
							//lib.slice(id, x,y, wid,hei );
					}
					else
						slices.push({k:id, f:0, x:x, y:y, w:wid, h:hei});
						//lib.slice(id, x,y, wid,hei );
				}
			}
		}
		catch(e:Dynamic) {
			throw "Failed to parse ShoeBox XML : "+e;
		}

		return slices;
	}
	
	
	@:macro public static function importShoeBox(xmlUrl:String) {
		var p = Context.currentPos();
		
		xmlUrl = StringTools.replace(xmlUrl, "\\", "/");
		var path = xmlUrl.indexOf("/")>=0 ? xmlUrl.substr(0, xmlUrl.lastIndexOf("/")) : "";
		
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
		
		// Slice name references
		//var slices = parseShoeBoxXml2(fileContent);
		//var sliceNames = Lambda.array(
			//Lambda.map( slices, function(s) return {field:s.k, expr:{expr:EConst(CString(s.k)), pos:p}} )
		//);
		//var t = { expr:EObjectDecl(sliceNames), pos:p };
		
		var fileContentExpr = { expr:EConst(CString(fileContent)), pos:p }
		return macro mt.deepnight.SpriteLibBitmap.parseShoeBoxXml($fileContentExpr, $newSourceExpr);
	}
	
	var i = 5;
	
	
	/** MACRO ********************************************************************************************/
	// SYNTAX: frame(duration) > start-end(duration > frame(duration)
	// EXAMPLE: defineAnim( "walk", 0-5(2) > 6(1) > 7(2) );
	@:macro public function defineAnim(ethis:Expr, animName:Expr, ?baseFrame:Expr, ?def:Expr) : Expr {
		
		// Parameters
		if( isNull(def) && isNull(baseFrame) )
			error("animation definition is required", def.pos);
		if( isNull(def) ) {
			def = baseFrame;
			baseFrame = {pos:ethis.pos, expr:EConst(CInt("0"))}
		}
		else
			parseInt(baseFrame); // checks if it's an Int
			
		// Parsing
		var frames : Array<{f:Expr, d:Expr}> = [];
		parseFrameDef(frames, def);
		
		// Construction du paramètre "anim" pour __defineAnim()
		var eframes = [];
		for(f in frames) {
			var ef = f.f;
			eframes.push({
				pos		: ethis.pos,
				expr	: EObjectDecl([
					{field:"f", expr:macro $baseFrame + $ef},
					{field:"d", expr:f.d},
				]),
			});
		}
		var earray : Expr = {pos:ethis.pos, expr:EArrayDecl(eframes)};
		
		return macro $ethis.__defineAnim($animName, $earray);
	}
	
	
	#if macro
	static function parseFrameDef(frames: Array<{f:Expr, d:Expr}>, def:Expr, ?depth=0) {
		//var indent = ""; for(i in 0...depth+1) indent+="___ ";
		//trace(indent + def.expr);
		switch( def.expr ) {
			case ECall(c,p) :
				frames.push({
					f	: {pos:def.pos, expr:EConst(CInt(Std.string(parseInt(c))))},
					d	: p[0],
				});
			case EBinop(op, e1, e2) :
				switch(op) {
					//case OpDiv :
						//frames.push({f:e1, d:e2});
					case OpGt :
						parseFrameDef(frames, e1, depth+1);
						parseFrameDef(frames, e2, depth+1);
					case OpSub :
						var start = parseInt(e1);
						var end;
						var eduration;
						switch( e2.expr ) {
							case ECall(c,p) :
								end = parseInt(c);
								eduration = p[0];
							default :
								error("unexpected sub "+e2.expr, e2.pos);
						}
						for(i in start...end+1)
							frames.push({
								f	: {pos:def.pos, expr:EConst(CInt(Std.string(i)))},
								d	: eduration,
							});
					default :
						error("unexpected operator "+op, def.pos);
				}
			default :
				error("unexpected expression", def.pos);
		}
		return {f:0, d:0};
	}
	
	static function error( ?msg="", p : Position ) {
		haxe.macro.Context.error("ERROR: "+msg,p);
	}
	
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
	static function parseInt(e:Expr) {
		switch(e.expr) {
			case EConst(c) :
				switch( c ) {
					case CInt(v) : return Std.parseInt(v);
					default :
						error("constant Int required", e.pos);
						return null;
				}
			default :
				error("const needed here", e.pos);
				return null;
		}
	}
	#end
}



