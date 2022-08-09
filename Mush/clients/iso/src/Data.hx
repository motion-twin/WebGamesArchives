package ;

import mt.bumdum9.Lib;
import mt.pix.Store;
import mt.pix.Element;
import IsoProtocol;
import Protocol;

import Data;
import Dirs;
import Types;
using Ex;

class BmpGfx extends BMD { }
class BmpGfx2 extends BMD { }
class BmpGfxFx extends BMD { }
class BmpGfxChar extends BMD { }

class BmpMap extends BMD { }
class BmpShipMapS1 extends BMD { }

#if dev
class BmpMapDev extends BMD { }
#end

class BmpTables extends BMD { }
class BmpChairs extends BMD { }

class BmpMidFill extends BMD { }
class BmpMidFill2 extends BMD { }
class BmpSmallFill extends BMD { }
class BmpBigFill extends BMD { }
class BmpBigFill2 extends BMD { }
class BmpGfxDev extends BMD { }
class BmpMasks extends BMD { }


enum _AcceptedData
{
	_Pathable;
	_Door;
	_Chair;
	_Equipment;
	_Blocker;
	_Decal;
	_Target;
	_Locker;
}


class Data
{
	static var sheets: EnumHash<Sheet,Store> = new EnumHash(Sheet);
	static public var slices : Hash<PixSlice> = new Hash();
	static public var col2Slice : IntHash< PixSetup > = new IntHash();
	
	static var mapData
	#if dev
	: BmpMapDev
	#else
	: BmpMap
	#end
	;
	
	static var tiles : haxe.xml.Fast;
	static var upgrades : haxe.xml.Fast;
	static public var debug: { tileOfs: Null<Int> } = { tileOfs:null };
	
	
	
	//returns null if has nos deps
	public function new()
	{
		mapData = new #if dev BmpMapDev #else BmpMap #end (0, 0, false);
		
		tiles = new haxe.xml.Fast( Xml.parse( haxe.Resource.getString( "tiles")).firstElement() );
		upgrades = new haxe.xml.Fast( Xml.parse( haxe.Resource.getString( "up_xml")).firstElement() );
		
		var retSheet = function(str)
		return tiles.node.tiles.nodes.sheet.find( function(e)
		{
			return e.att.src == str;
		});
		
		try
		{
			debug.tileOfs = Std.parseInt( "0x"+ tiles.node.debug.node.tileOfs.att.colorId );
		}
		catch(d:Dynamic)
		{
			Debug.MSG(d);
		}
		
		
		var gfx : Store;
		{
			var bmp = new BmpGfx2(0, 0);
			gfx = new mt.pix.Store(bmp);
			//gfx.makeTransp(0xFFFF00FF);
			
			var sheet = AYAME;
			sheets.set( sheet, gfx);
			
			addToStore( sheet, retSheet("BmpGfx2"));
		}
		
		{
			var sheet = FX_SHEET;
			var bmp = new BmpGfxFx(0, 0,true);
			gfx = new mt.pix.Store(bmp);
			gfx.makeTransp(0x00000000);
			
			sheets.set(sheet, gfx);
			addToStore( sheet, retSheet("BmpGfxFx"));
		}
		
		{
			var bmp = new BmpGfxChar(0, 0);
			gfx = new mt.pix.Store(bmp);
			gfx.makeTransp(0xFFffFFff);
			var sheet =  CHAR_SHEET;
			sheets.set(sheet, gfx);
			
			//addToStore( sheet, retSheet("BmpGfxChar"));
			
			{
				var nbFr;
				var idx = "COSMO_MALE";
				var sl : PixSlice = {
					sheet : sheet,
					index:idx,
					ofsX:2,
					ofsY:-12,
					prioOfs:0,
					animable:true,
					autoAnim:false,
				};
				gfx.addIndex( idx );
				gfx.slice( 2, 960, 40, 48,nbFr=5 );
				registerSlice( sl );
				
				function anmRythm() return Iota.splat( 2, nbFr);
				gfx.addAnim( idx, Iota.int_range( 0, nbFr ).array(), anmRythm());
			}
			
			{
				var nbFr;
				var idx = "COSMO_FEMALE";
				var sl : PixSlice = {
					sheet : sheet,
					index:idx,
					ofsX:2,
					ofsY:-12,
					prioOfs:0,
					animable:true,
					autoAnim:false,
				};
				gfx.addIndex( idx );
				gfx.slice( 2, 1008, 40, 48,nbFr=5 );
				registerSlice( sl );
				
				function anmRythm() return Iota.splat( 2, nbFr);
				gfx.addAnim( idx, Iota.int_range( 0, nbFr ).array(), anmRythm());
			}
				
		
			var w = 32;
			var h = 48;
			
			function regChar(charId : HeroId,sk:Int,x:Int,y:Int){
				var idx = Protocol.heroesIdList[charId.index()].id;
				var suffix = (sk == 0) ? "" : "$" + sk;
				idx += suffix;
				
				var sl : PixSlice = {
					sheet : sheet,
					index:idx,
					ofsX:2,
					ofsY:-12,
					prioOfs:0,
					animable:false,
					autoAnim:false,
				};
				
				gfx.addIndex( idx );
				
				gfx.addFrame( x, y, w, h, false,false);
				gfx.addFrame( x, y, w, h, true, false);
				
				gfx.addFrame( x+w, y, w, h, false,false);
				gfx.addFrame( x+w, y, w, h, true, false);
				
				gfx.addFrame( x+w*2, y, w, h, false,false);
				gfx.addFrame( x+w*2, y, w, h, true, false);
				
				gfx.addFrame( x+w*3, y, w, h, false,false);
				gfx.addFrame( x+w*3, y, w, h, true, false);
				
				registerSlice( sl );
				
				var xwr = x + w * 4;
				var nbAnimFrames = 6;
				function anmRythm()
					return Iota.splat( 2, nbAnimFrames);
				
				var id =  idx + "_WALK_RIGHT";
				gfx.addIndex( id );
				gfx.slice( xwr, y, w, h, nbAnimFrames);
				registerSlice( sl );
				var st = gfx.index.get( id );
				gfx.addAnim( "#" + id, Iota.int_range( 0, nbAnimFrames ).array(), anmRythm());
				
				id =  idx + "_WALK_DOWN";
				gfx.addIndex( id );
				gfx.slice( xwr, y, w, h, nbAnimFrames,1,true);
				registerSlice( sl );
				var st = gfx.index.get( id );
				gfx.addAnim( "#"+id, Iota.int_range( 0, nbAnimFrames ).array(), anmRythm());
				
				var xwl = xwr + w * nbAnimFrames;
				id =  idx + "_WALK_LEFT";
				gfx.addIndex( id );
				gfx.slice( xwl, y, w, h, nbAnimFrames);
				registerSlice( sl );
				var st = gfx.index.get( id );
				gfx.addAnim( "#" + id, Iota.int_range( 0, nbAnimFrames ).array(), anmRythm());
				
				id =  idx + "_WALK_UP";
				gfx.addIndex( id );
				gfx.slice( xwl, y, w, h, nbAnimFrames,1,true);
				registerSlice( sl );
				var st = gfx.index.get( id );
				gfx.addAnim( "#"+id, Iota.int_range( 0, nbAnimFrames ).array(), anmRythm());
				
				var xt = xwl + w * 6;
				gfx.addIndex( idx + "_TIED" );
				gfx.addFrame( xt, y, w, h);
				registerSlice( sl );
				
				var xl = xt + w;
				var lw = 64;
				gfx.addIndex( idx + "_LAID" );
				gfx.addFrame( 544, y, 64, 48);
				registerSlice( sl );
				
				gfx.addIndex( idx + "_LAID_FLIPPED" );
				gfx.addFrame( 544, y, 64, 48, true);
				registerSlice( sl );
			}
			
			var x = 0;
			var y = 0;
			
			for( char in Protocol.heroesList )
			{
				if ( char.id == ADMIN ) break;
				regChar(char.id,0,x,y);
				y += h;
			}
			
			var s = 1776;
			regChar(DEREK_HOGAN, 0, 0, s);
			s += 48;
			regChar(ANDIE_GRAHAM, 0, 0	, s);
			
			//ADD SKIN HERE
			for( k in Protocol.heroSkins ) regChar( k.hid, k.sk, x, k.y);
			
			{
				var idx = "CHAR_ANON_FEMALE";
				var sl : PixSlice = {
					sheet : sheet,
					index:idx,
					ofsX:2,
					ofsY:-12,
					prioOfs:0,
					animable:false,
					autoAnim:false,
				};
				
				gfx.addIndex( idx );
				
				gfx.addFrame( x, y, w, h, false,false);
				gfx.addFrame( x, y, w, h, true, false);
				
				gfx.addFrame( x+w, y, w, h, false,false);
				gfx.addFrame( x + w, y, w, h, true, false);
				
				gfx.addFrame( x+w*2, y, w, h, false,false);
				gfx.addFrame( x+w*2, y, w, h, true, false);
				
				gfx.addFrame( x+w*3, y, w, h, false,false);
				gfx.addFrame( x+w*3, y, w, h, true, false);
				
				registerSlice( sl );
				
				var id =  idx + "_WALK_RIGHT";
				gfx.addIndex( id );
				gfx.addFrame( x, y, w, h, false,false);
				registerSlice( sl );
				var st = gfx.index.get( id );
				gfx.addAnim( "#" + id, Iota.int_range( 0, 1 ).array());
				
				id =  idx + "_WALK_DOWN";
				gfx.addIndex( id );
				gfx.addFrame( x, y, w, h, false,false);
				registerSlice( sl );
				var st = gfx.index.get( id );
				gfx.addAnim( "#" + id, Iota.int_range( 0, 1 ).array());
				
				id =  idx + "_WALK_LEFT";
				gfx.addIndex( id );
				gfx.addFrame( x, y, w, h, false,false);
				registerSlice( sl );
				var st = gfx.index.get( id );
				gfx.addAnim( "#" + id, Iota.int_range( 0, 1 ).array());
				
				id =  idx + "_WALK_UP";
				gfx.addIndex( id );
				gfx.addFrame( x, y, w, h, false,false);
				registerSlice( sl );
				var st = gfx.index.get( id );
				gfx.addAnim( "#" + id, Iota.int_range( 0, 1 ).array());
				
				gfx.addIndex( idx + "_TIED" );
				gfx.addFrame( x, y, w, h);
				registerSlice( sl );
				
				gfx.addIndex( idx + "_LAID" );
				gfx.addFrame( x, y, w, h);
				registerSlice( sl );
				
				
				y += h;
			}
			
			//skip admin male
			y += h;
			
		
			{
				
				var idx = "CAT";
				var sl : PixSlice = {
					sheet : sheet,
					index:idx,
					ofsX:2,
					ofsY:-12,
					prioOfs:0,
					animable:false,
					autoAnim:false,
				};
				
				gfx.addIndex( idx );
				
				gfx.addFrame( x, y, w, h, false,false);
				gfx.addFrame( x, y, w, h, true, false);
				
				gfx.addFrame( x+w, y, w, h, false,false);
				gfx.addFrame( x + w, y, w, h, true, false);
				
				var nx = x + w ;
				gfx.addFrame( nx, y, w, h, false,false);
				gfx.addFrame( nx, y, w, h, true, false);
				
				gfx.addFrame( nx+w, y, w, h, false,false);
				gfx.addFrame( nx+w, y, w, h, true, false);
				
				registerSlice( sl );
				y += h;
			}
			
			
			
			{
				var idx = "MUTATED";
				var sl : PixSlice = {
					sheet : sheet,
					index:idx,
					ofsX:2,
					ofsY:-12,
					prioOfs:0,
					animable:false,
					autoAnim:false,
				};
				
				gfx.addIndex( idx );
				
				gfx.addFrame( x, y, w, h, false,false);
				gfx.addFrame( x, y, w, h, true, false);
				
				gfx.addFrame( x+w, y, w, h, false,false);
				gfx.addFrame( x + w, y, w, h, true, false);
				
				var xwr = x + w * 4;
				var nbAnimFrames = 6;
				function anmRythm()
					return Iota.splat( 2, nbAnimFrames);
				
				var id =  idx + "_WALK_RIGHT";
				gfx.addIndex( id );
				gfx.slice( xwr, y, w, h, nbAnimFrames);
				registerSlice( sl );
				var st = gfx.index.get( id );
				gfx.addAnim( "#" + id, Iota.int_range( 0, nbAnimFrames ).array(), anmRythm());
				
				id =  idx + "_WALK_DOWN";
				gfx.addIndex( id );
				gfx.slice( xwr, y, w, h, nbAnimFrames,1,true);
				registerSlice( sl );
				var st = gfx.index.get( id );
				gfx.addAnim( "#"+id, Iota.int_range( 0, nbAnimFrames ).array(), anmRythm());
				
				var xwl = xwr + w * nbAnimFrames;
				id =  idx + "_WALK_LEFT";
				gfx.addIndex( id );
				gfx.slice( xwl, y, w, h, nbAnimFrames);
				registerSlice( sl );
				var st = gfx.index.get( id );
				gfx.addAnim( "#" + id, Iota.int_range( 0, nbAnimFrames ).array(), anmRythm());
				
				id =  idx + "_WALK_UP";
				gfx.addIndex( id );
				gfx.slice( xwl, y, w, h, nbAnimFrames,1,true);
				registerSlice( sl );
				var st = gfx.index.get( id );
				gfx.addAnim( "#"+id, Iota.int_range( 0, nbAnimFrames ).array(), anmRythm());
				
				registerSlice( sl );
				Debug.MSG("mt " + x + " " + y);
				y += h;
				
			}
			
			
		}
		
		
		
		{
			var bmp = new BmpMidFill(0, 0);
			gfx = new mt.pix.Store(bmp);
			var sheet =  MID_FILL_SHEET;
			sheets.set(sheet, gfx);
			addToStore( sheet, retSheet("BmpMidFill"));
		}
		
		{
			var bmp = new BmpMidFill2(0, 0);
			gfx = new mt.pix.Store(bmp);
			var sheet =  MID_FILL_SHEET2;
			sheets.set(sheet, gfx);
			addToStore( sheet, retSheet("BmpMidFill2"));
		}
		
		{
			var bmp = new BmpSmallFill(0, 0);
			gfx = new mt.pix.Store(bmp);
			var sheet =  SMALL_FILL_SHEET;
			sheets.set(sheet, gfx);
			addToStore( sheet, retSheet("BmpSmallFill"));
		}
		
		
		{
			var bmp = new BmpBigFill(0, 0);
			gfx = new mt.pix.Store(bmp);
			var sheet =  BIG_SHEET;
			sheets.set(sheet, gfx);
			addToStore( sheet, retSheet("BmpBigFill"));
		}
		
		{
			var bmp = new BmpMasks(0, 0);
			gfx = new mt.pix.Store(bmp);
			var sheet =  MASK_SHEET;
			sheets.set(sheet, gfx);
			addToStore( sheet, retSheet("BmpMasks"));
		}
		
		{
			var bmp = new BmpBigFill2(0, 0);
			gfx = new mt.pix.Store(bmp);
			var sheet =  BIG_SHEET2;
			sheets.set(sheet, gfx);
			addToStore( sheet, retSheet("BmpBigFill2"));
		}
		
		{
			var bmp = new BmpGfxDev(0, 0);
			gfx = new mt.pix.Store(bmp);
			var sheet =  DEV_SHEET;
			sheets.set(sheet, gfx);
			addToStore( sheet, retSheet("BmpGfxDev"));
		}
		
		
	}
	
	public function getExtra() : haxe.xml.Fast
	{
		return tiles.node.extras;
	}
	
	public function getUpgades() : haxe.xml.Fast
	{
		return upgrades.node.upgrades;
	}
	
	public function getSheet(sh)
	{
		return slices.filter( function(s) return s.sheet == sh );
	}
	
	public function init( )
	{
		makeMap();
	}
	
	
	public static function mkSetup( i : String, ?s : Sheet, f : Int = 0 ) : PixSetup
	{
		if( s == null )
		{
			s = slices.get( i ).sheet;
		}
		return { sheet:s, frame:f, index:i };
	}
	
	public function dependDirs(index)
	{
		switch(index)
		{
			case "DOOR_BACK2LEFT": return [ UP ];
			case "DOOR_BACK2RIGHT": return [ RIGHT ];
			default:return null;
		}
	}
	
	public function hasTileFlag(index)
	{
		var sl = slices.get( index );
		if( sl.data == null ) return false;
		
		return sl.data != null;
	}
	
	public function testTileFlag( ac : _AcceptedData, index : String )
	{
		var sl = slices.get( index );
		if( sl.data == null ) return false;
		
		return sl.data.has( Std.string(ac).toLowerCase() );
	}
	
	public static inline function spriteOfs( index : String  )
	{
		var e = slices.get( index );
		return { x:e.ofsX, y:e.ofsY };
	}
	
	public static function frame(index:String, frame : Int = 0) : PixSetup
	{
		mt.gx.Debug.assert( slices.get( index ) != null, "Missing slice " + index );
		var sh = slices.get( index ).sheet;
		return { sheet: sh, index:index, frame:frame };
	}
	
	public static function setup2( el : Element, px : PixSetup )
	{
		setup( el, px.sheet, px.frame, px.index );
	}
	
	public static function fromScratch(s:PixSetup) : TileEntry
	{
		Debug.ASSERT( s != null );
		//Debug.MSG( "scratching " + s.index );
		var nu : TileEntry =
		{
			setup: s,
			el: cast new ElementEx()
		}
		setup( nu.el, nu.setup.sheet, nu.setup.frame, nu.setup.index );
		return nu;
	}
	
	public static function getElement(index:String) : ElementEx
	{
		var el =  new ElementEx();
		var set = frame( index );
		setup( el, set.sheet,set.frame,set.index );
		return el;
	}
	
	public static function setup(el : Element, sheet : Sheet , frame = 0, ?index : String )
	{
		var d = spriteOfs( index );
		
		el.store = sheets.get( sheet);
		el.goto( frame, index);
		el.x = d.x;
		el.y = d.y;
		el.visible = true;
	}
	

	public function addToStore( sheet : Sheet, xmlSheet : haxe.xml.Fast)
	{
		Debug.ASSERT( sheet !=null );
		var st : Store = sheets.get( sheet );
		Debug.ASSERT( st != null );
		
		//xmlSheet.att.
		
		var rv = function( str : String ) : Array<Int>
		{
			var s = str.trimWhiteSpace();
			var as = s.split(",");
			var astmp = as.map( function(s) return Ex.dflt( Std.parseInt(s), 1 ) );
			return astmp.array();
		}
		
		var root = xmlSheet;
		if( root == null )
		{
			Debug.MSG("no xml for sprite sheet " + sheet);
			return;
		}
		
		for( s in root.nodes.slice )
		{
			var int = Std.parseInt;
			var prms = s.att.params.split(",");
			var ofsAtt  = s.has.ofs ? s.att.ofs : "";
			var ofs = ofsAtt.split(",");
			
			var flipX = Ex.dflt( StdEx.parseBool( s.has.flipX ? s.att.flipX : null), false);
			var flipY = Ex.dflt( StdEx.parseBool( s.has.flipY ? s.att.flipY : null), false);
			var rot = Ex.dflt( int( s.has.rot ? s.att.rot : null ), 0);
			var id = s.att.id;
			
			st.addIndex(id);
			
			var nbX = Ex.dflt(int(prms[4]), 1);
			var nbY = Ex.dflt(int(prms[5]), 1);
			
			st.slice( 	int(prms[0]),
						int(prms[1]),
						int(prms[2]),
						int(prms[3]),
						nbX,
						nbY,
						flipX,
						flipY,
						rot);
				
			var frameInfos = null;
			var frames = s.nodes.frame;
			if( frames.length > 0)
			{
				frameInfos = [];
				var i = 0;
				for(f in frames)
				{
					var n : { col:Null<Int>,grdOfsY:Null<Int>} = { col:null, grdOfsY:null };
					if( f.has.color )
					{
						n.col = int("0x" + f.att.color);
						
						if( col2Slice.get( n.col) != null) throw "Assert, data defines color " + StringTools.hex(n.col) + " more than once in xml";
						
						col2Slice.set( n.col, { index:id, frame:i,sheet:sheet } );
					}
					
					if ( f.has.grdOfsY )
						n.grdOfsY = Ex.dflt(int(f.att.grdOfsY), 0);
						
					frameInfos.push( n );
					i++;
				}
			}
			
			var data : List<String>= null;
			if (s.has.data)
			{
				var asep = s.att.data.split(",");
				//data = asep.map( StringEx.trimWhiteSpace ).map( function(s) return s.toLowerCase() ).list();
				data = asep.list().map( StringEx.trimWhiteSpace ).map( function(s) return s.toLowerCase() ).list();
			}
				
			var deps = null;
			if(s.hasNode.dep )
			{
				var depVec = rv( s.node.dep.innerData);
				deps = new V2I( depVec[0], depVec[1]);
			}
			
			var curSlice : PixSlice = { 	sheet:sheet,
											index:id,
											ofsX: Ex.dflt(int( ofs[0]),0),
											ofsY: Ex.dflt(int( ofs[1]),0),
											frames: frameInfos,
											data:data,
											deps:deps,
											prioOfs:0,
											animable:false,
											autoAnim:false,
											};
			slices.set( id, curSlice );
			
			if (s.has.prio)
				curSlice.prioOfs = Std.parseInt( s.att.prioOfs );
			
			if (s.has.engine)
				switch( s.att.engine )
				{
					case "prewall": curSlice.engine = UsePreWall;
					case "tile","wall": curSlice.engine = UseTile;
					case "entity": curSlice.engine = UseEntity;
					case "post","postfx": curSlice.engine = UsePostFx;
					case "postwall": curSlice.engine = UsePostWall;
					default: throw "error" + s.att.engine;
				}
				
			if (s.has.dir )
				curSlice.dir = Dirs.parse( s.att.dir );
				
			if(s.hasNode.modulePad )
			{
				var vec = rv( s.node.modulePad.innerData );
				curSlice.modulePad= new V2I( vec[0],vec[1] );
			}
								
			if( frameInfos != null)
				Debug.ASSERT( frameInfos.length <= nbX * nbY,"There are more frame definitions than product of frame rows and frame columns, please adjust the value" );
				
			if(s.nodes.anim.length > 0 )
			{
				var several  = (s.nodes.anim.length > 1);
				var i = 0;
				for ( anim in s.nodes.anim)
				{
					var arr = rv( anim.att.range );
					var rhythm = 	(!anim.has.rhythm)
								?	null
								: 	rv( anim.att.rhythm );
					
					var aid = several ? id + "#" + i: id;
					st.addAnim( aid, arr, rhythm);
					//trace("creating anim " + aid);
					i++;
				}
				curSlice.autoAnim = s.node.anim.has.auto ? StdEx.parseBool( s.node.anim.att.auto ) : false;
				curSlice.animable = true;
			}
		}
		
	}
	
	public function registerSlice( sl : PixSlice )
	{
		slices.set( sl.index, sl );
	}
	
	public function getDebugStart() : RoomId
	{
		if( !tiles.node.debug.hasNode.start) return null;
		if( !tiles.node.debug.node.start.has.roomId ) return null;
		
		return IsoProtocol.trackbackRid( tiles.node.debug.node.start.att.roomId );
	}
	
	var cloneMask : FlagsArray<RoomId>;
	var rectCache : EnumHash<RoomId, Coll.Rect>;
	
	//HERE IS PATROL SHIP ADDING
	function makeClones()
	{
		cloneMask = new FlagsArray( RoomId );
		cloneMask.clear();
		
		for(r in Protocol.roomList.filter(function(r) return r.type == PATROL_SHIP && r.id !=  PATROL_SHIP_AA_1))
			cloneMask.set(r.id,true);
			
	}
	
	function makeMap()
	{
		makeClones();
		var conf = tiles.node.bitmap;
		rectCache = new EnumHash(RoomId);
		
		var maxX = Std.parseInt( conf.att.maxRoomWidth );
		var maxY = Std.parseInt(conf.att.maxRoomHeight);
		var curY = 0;
		
		
		for(r in RoomId.array())
		{
			//Debug.MSG("making " + r+" cy="+curY );
			var cloneMode = cloneMask.get( r ) ;
			var base : Coll.Rect = { x:Std.parseInt(conf.att.startX), y:curY, width: maxX, height: maxY };
			rectCache.set( r, base);
			
			var props = Reflect.copy( base );
			props.x += maxX;
			
			var nonPathableProps = Reflect.copy( props );
			nonPathableProps.x += maxX;
			
			var thrash = Reflect.copy( nonPathableProps );
			thrash.x += maxX;
			
			var gr = Main.ship.buildRoomBmp( r, mapData, [base, props, nonPathableProps,thrash] );
			
			if(!cloneMode)
				curY += maxY;
		}
		
		
	}
	
	public static function parseCond(s:String): Null<CrossCondition>
	{
		s = StringEx.trimWhiteSpace( s );
		var andSplit : Array<String> = s.split("&&");
		if ( andSplit.length >= 2 )
			return CC_And( parseCond(andSplit[0]), parseCond(andSplit[1]) );
		
		var orSplit = s.split(' ').join(' ').split("||");
		if ( orSplit.length >= 2 )
			return CC_Or( parseCond(orSplit[0]), parseCond(orSplit[1]) );
			
		s = StringEx.trimWhiteSpace( s );
		
		var split = StringEx.readWord( s );
		var param = split.rest.readParen();
		if ( param == null)
			return null;
			
		switch(split.word.toLowerCase())
		{
			case "projectunlocked":
				var v = IsoProtocol.trackbackProjectId( param);
				return ( v == null ) ? null : CC_ProjectUnlocked( v );
				
			case "roomitemhas":
				var v = IsoProtocol.trackbackIid( param);
				return ( v == null ) ? null : CC_RoomItemHas( v );
				
			case "researchunlocked":
				var v = IsoProtocol.trackbackResearchId( param);
				return ( v == null) ? null : CC_ResearchUnlocked( v );
				
			case "pilgredunlocked":
				return CC_PilgredUnlocked;
				
			case "icaruslanded":
				return CC_IcarusLanded;
				
			case "true":
				return CC_True;
			
			case "false":
				return CC_False;
				
			case "not":
				return CC_Not( parseCond( param ) );
				
			case "testpatrol": return CC_TestPatrol( param  );
		}
		
		return null;
	}
	
}