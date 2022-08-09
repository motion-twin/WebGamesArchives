package ;
import flash.display.Bitmap;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import mt.deepnight.Lib;
import mt.fx.Flash;
import mt.fx.Spawn;
import mt.pix.Element;

import mt.pix.Store;
import Tile.TileStage;
using Ex;
import Data;
import Types;
import Dirs;
import IsoProtocol;
import Protocol;

import actor.ItemActor;
/**
 * ...
 * @author de
 */

class Updatable extends MovieClip implements Z
{
	public function getZ() return 0.0;
	public function getPrio() return 0;
	
	public function new() {
		super();
	};
	
	public function getDo() : flash.display.Sprite
	{
		return this;
	}
	
	public function update() return;
}

@:publicFields
class AIView 
{
	var g : Grid;
	var graph : algo.Graph;
	
	function new(g)
	{
		this.g = g;
	}
	
	static inline function mkNid(x:Int, y:Int) : Int return (x << 8) | y;
	static inline function nid2Coo(v:Int) : { x:Int, y:Int }
	{
		return { x:v >> 8, y:v & 255 };
	}
	
	
	function mkGrid()
	{
		graph = new algo.Graph();
		var spawns = g.tiles().filter( function( v ) return v.isWalkable() );
		for( s in spawns)
			graph.node( mkNid(s.pos.x,s.pos.y), s );
				
		for ( s in spawns )
		{
			for ( d in E_DIRS)
			{
				var px = s.pos.x + Dirs.LIST[d.index()].x;
				var py = s.pos.y + Dirs.LIST[d.index()].y;
				if ( px < 0 || py < 0 ) continue;
				
				var nid = mkNid(px, py);
				
				if ( graph.hasNode( nid ) )
					graph.edge( mkNid(s.pos.x,s.pos.y), nid, 1, true );
			}
		}
	}
	
	function updateWeights()
	{
		
		var cachePath : BitArray = new BitArray();
		
		for (x in g.tiles())
			if ( x.isWalkable())
				cachePath.set( Grid.getKey( x.pos.x, x.pos.y),true );
		
		graph.iterEdges(function(e)
		{
			var pin = nid2Coo(e.enter);
			var pout = nid2Coo(e.exit);
			
			if ( 	cachePath.has( Grid.getKey(pin.x, pin.y ))
			&&		cachePath.has( Grid.getKey(pout.x, pout.y )))
				e.w = 1;
			else
				e.w = 0;
		});
	}
	
	var dijkstra :
		{
			root: Int,
			comp : algo.Graph.DijkstraProcess,
		};
	
	public function mkPathFrom(n:Int)
	{
		dijkstra = {
			root:n,
			comp : algo.Graph.DijkstraProcess.compute( graph,n )
		};
	}
	
	function pathTo( n: Int)
	{
		return dijkstra.comp.pathTo( n );
	}
}

class Grid extends MovieClip
{
	var store : IntHash< Tile >;
	
	public var allPoses : Array<V2I>;
	public var tgtBb : Array<V2I>;
	public var bb : Array<V2I>; 
	public var poses  : Array<V2I>;
	
	//store blocs
	public var dependancies : Array< DepInfos >;
	
	var entities : EnumHash < Entities, List<Entity> > ;
	
	public var postWall : List<mt.pix.Element>;
	var postFx : List<ElementEx>;
	
	var dirty : Bool;
	
	var showExit : Bool;
	var rid : RoomId;
	var onFire:Bool;
	public var input : InputManager;
	
	var 		tempItemActorList : List<{ id:_ItemDesc,fnc:Grid->ItemActor,mark:Bool}>;
	public var 	itemActors : IntHash<actor.ItemActor>;

	public var ai : AIView;
	
	
	public function new( rid )
	{
		allPoses = null;
		tgtBb = null;
		bb = null;
		poses = null;
		store = new IntHash();
		super();
		visible = true;

		entities = new EnumHash(Entities);

		dirty = true;
		dependancies = [];
		this.rid = rid;

		fires = [];
		postFx = new List();
		postWall = new List();
		onFire =  false;
		input = new InputManager();
		itemActors = new IntHash();
		
		tileArrCache = null;
		tileCache = new Sprite();
	}
	
	public function mkAi()
	{
		ai = new AIView(this);
		ai.mkGrid();
	}
	
	public function getAi()
	{
		if ( ai == null) mkAi();
		return ai;
	}
	
	public function getRid() : RoomId	return rid;
	public function getCenter() : { min:V2D,max:V2D}
	{
		var i = 0;
		var maxX = -10000.0;
		var minX = 10000.0;
		
		var maxY = -10000.0;
		var minY = 10000.0;
		
		for(x in tiles() )
		{
			if( x.get( Ground) !=null )
			{
				var pis = x.getPixelPos();
				
				if( pis.x > maxX )
					maxX = pis.x;
				if( pis.x < minX )
					minX = pis.x;
					
				if( pis.y > maxY )
					maxY = pis.y;
				if( pis.y < minY )
					minY = pis.y;
				i++;
			}
		}
		var min = new V2D( minX, minY);
		var max = new V2D( maxX, maxY);
		return { min:min, max:max };
	}
	
	public function startItemUpdate()
	{
		tempItemActorList = new List();
	}
	
	public function endItemUpdate()
	{
		Main.infos.endItemUpdate = true;
		var i = 0;
		
		for ( it in itemActors)
			it.mark = false;
			
		for( dr in tempItemActorList )
		{
			var act = itemActors.get( dr.id.uid );
			if ( act == null ) continue;
			
			act.onData( dr );
			dr.mark = true;
			act.mark = true;
		}
		
		for ( it in itemActors)
			if ( !it.mark )
			{
				it.kill();
				itemActors.remove( it.item().uid );
			}
				
		for ( it in tempItemActorList)
			if ( !it.mark )
				itemActors.set( it.id.uid, it.fnc(this) );
		
		Main.infos.endItemUpdate = false;
	}
	
	
	public function updateItem( id : _ItemDesc  )
	{
		var dep = null;
		var fac = actor.ItemActor.factory( id );
		
		if ( fac != null){
			var t = { id:id, fnc:fac,mark:false };
			tempItemActorList.pushBack( t );
		}
		else{
			Main.state = _DependancyCheck;
			
			for( d in dependancies)
			{
				if( d.gameData !=null)
				switch(d.gameData)
				{
					case Door(here, there):
						if( id.id == DOOR){
							var tgt = Utils.getDoorTgt( id, getRid() );
							if( there == tgt ){
								dep = d;
								break;
							}
						}
					case Equipment( iid ):
						
						//key is dynamically bound
						if (id.id==CAMERA && iid == CAMERA && Utils.Bit_is( id.status, 1<< ItemStatusId.EQUIPMENT.index() )){
							d.key = id.customInfos.locate( function(ci) return switch(ci) { default:null; case _Key(k):k; } );
							dep = d;
						}
						else {
							var itemKey = id.customInfos.locate( function(ci) return switch(ci) { default:null; case _Key(k):k; } );
							if ( id.id == iid && d.key == itemKey)
							{
								dep = d;
								break;
							}
						}
					default:
						/*
						if ( d.iid == id.id){
							var itemKey = id.customInfos.locate( function(ci) return switch(ci) { default:null; case _Key(k):k; } );
							if ( id.id == iid && d.key == itemKey)
							{
								dep = d;
								break;
							}	
						}
						*/
				}
				else {
					
				}
			}
			Main.state = _DependancyChecked;
			if ( dep == null )
			{
				//Profiler.get().end("updateItem");
				return;
			}
		
			//keys are the bond between separate data, they are unified under uid which is way simpler thus
			dep.itemUid = id.uid;
			
			if ( dep.te != null && dep.tile != null)
			{
				if( Flags.test( id.status, BROKEN ) && !dep.flags.has( Smoking ) )
				{
					var slices = Data.slices.get( dep.te.setup.index ).deps;
					if ( slices !=null ) new fx.SmokeEmitter( dep.tile, dep.te, Data.slices.get( dep.te.setup.index ).deps );
					dep.flags.set( Smoking );
				}
				else if( !Flags.test( id.status, BROKEN ) && dep.flags.has( Smoking ) )
				{
					fx.SmokeEmitter.remove( dep.te.el );
					dep.flags.unset( Smoking );
				}
			}
			
			//#if !editor
			if ( dep.te.el.visible == false) {
				dep.te.el.visible = true;
				dep.te.el.alpha = 1.0;
				new mt.fx.Spawn(dep.te.el);
				//Debug.MSG('spawning '+dep.itemUid+" "+ dep.te.setup.index);
			}
			//#end
			
			Main.state = _FireChecked;
		}
		//Profiler.get().end("updateItem");
	}
	
	public function getGroundOffsetY(x:Int,y:Int) : Int
	{
		var t = get(x, y);
		if(t == null) return 0;
		
		var te = t.get( Ground );
		if( te == null) return 0;
		
		for ( d in dependancies)
			if ( d.pad!=null&&d.pad.test( function(p) return p.x == x && p.y == y ) )
			{
				var sl = Data.slices.get( d.te.setup.index );
				if ( 	sl.frames != null
					&& 	sl.frames[te.setup.frame] != null )
				{
					return sl.frames[te.setup.frame].grdOfsY;
				}
			}
			
		var sliceInfo : PixSlice = Data.slices.get( te.setup.index );
		if( sliceInfo.frames == null) return 0;
		if( sliceInfo.frames[te.setup.frame] == null) return 0;
		
		return sliceInfo.frames[te.setup.frame].grdOfsY;
	}
	

	public function addDep( tile : Tile, posList : Array<V2I>,te : TileEntry, gd , ent : Entity , debug : {pixel:V2I} ) : DepInfos
	{
		var v;
		dependancies.push( v = { tile:tile, data:posList, te:te, gameData: gd , ent :ent, flags:new Flags(0), debug:debug, } );
		return v;
	}
	
	public function reset()
	{
		for(d in dependancies)
			if( d.ent !=null)
				{
					var grPos = d.ent.getGridPos();
					d.ent.doSetup( d.ent.te.setup );
					d.ent.setPos(grPos.x,grPos.y);
				}
				
		for(t in tiles())
			for( st in t.tiles())
				if( st.setup != null )
					Data.setup2( st.el, st.setup );
	}
	
	public function addPostFx ( e : ElementEx) {
		mt.gx.Debug.assert( e != null );
		postFx.push( e );
	}
	
	public function remPostFx ( e : ElementEx) {
		mt.gx.Debug.assert( e != null );
		postFx.remove( e );
	}
	
	public function addEntity( obj : Entity , dirt = true)
	{
		if ( obj == null )
		{
			Debug.MSG( "Bad Add");
			#if debug 
				throw "assert"; 
			#end
			return;
		}
		var tag = obj.type;
		var l = entities.get(tag);
		if(l == null )
		{
			l = new List();
			entities.set(tag, l);
		}
		
		#if debug
			Debug.ASSERT( !l.has( obj ) );
		#end
		
		addChild( obj.getDo() );
		l.push( obj );
		obj.bindGrid( this );
		if (dirt) dirtSort();
		else {
			if ( obj.engine == UsePostFx ) {
				Debug.ASSERT(obj.el != null);
				addChild( obj.el );
			}
			else Debug.MSG('usupported live add');
		}
	}
	
	public function getServerData() : _RoomInfos
	{
		if( Main.actServerData == null) return null;
	
		return Main.actServerData.shipMap.get( getRid().index() );
	}
	
	public function removeEntity( obj : Entity ,dirt = true)
	{
		var l = entities.get(obj.type );
		if( l == null )
		{
			Debug.MSG( "Bad remove");
			return;
		}
		
		var ok =  l.remove(obj);
		//Debug.MSG( "removing " + obj.uid+" remains: [" + l.map(function(e) return e.uid).join(",")+"]");
		if( ok )
		{
			obj.bindGrid( null );
			if (dirt) 
				dirtSort();
				
			obj.el.detach();
		}
	}
	
	public function getEntity( tag : Entities ) : List<Entity>
	{
		var l = entities.get(tag);
		if(l == null )
		{
			l = new List();
			entities.set(tag, l);
		}
		
		return l;
	}
	
	public static function isDoor( dd : DepData)
	{
		if(dd == null) return false;
		
		switch(dd)
		{
			case Door(_, _): return true;
			default://skip
		}
		return false;
	}
	
	public function getNpc(x,y)
	{
		for ( n in Main.allHumanNPC)
		{
			var p = n.getGridPos();
			if ( n.getRid() ==rid && p.x == x && p.y == y)
				return n;
		}
		return null;
	}
	
	public function getRoomNpcs()
	{
		var f = new List();
		for ( n in Main.allHumanNPC)
			if ( n.getRid() == rid )
				f.push(n);
		return f;
	}
	
	public function randomFree()
	{
		return tiles().filter(function(r) return isSpawnable(r.getGridPos().x,r.getGridPos().y))
		.filter( function(t) return Main.ship.getNpcs( this, t.getGridPos() ).length == 0)
		.random();
	}
	
	public function nearestFree(x,y) : Tile
	{
		var cand = [];
		for ( t in tiles() )
		{
			var p = t.getGridPos();
			
			if ( 	isSpawnable(p.x, p.y )
			&&		Main.ship.getNpcs( this, p ).length <= 0 )
			{
				var dx = (p.x - x);
				var dy = (p.y - y);
				cand.pushBack( {el:t,d:dx*dx+dy*dy} );
			}
		}
		
		cand.scramble();
		var el = cand.worstNZ( function(t) return t.d );
		return (el != null)?el.el:null;
	}
	
	public function nearestWalkable(x,y) : Tile
	{
		var cand = [];
		for ( t in tiles() )
		{
			var p = t.getGridPos();
			
			if ( isWalkable(p.x,p.y) )
			{
				var dx = (p.x - x);
				var dy = (p.y - y);
				cand.pushBack( {el:t,d:dx*dx+dy*dy} );
			}
		}
		
		cand.scramble();
		var el = cand.worstNZ( function(t) return t.d );
		return (el != null)?el.el:null;
	}
	
	public function getDoorPadXY(x , y) : DepInfos
	{
		for( d in dependancies )
		{
			if( !isDoor( d.gameData ) ) continue;
			
			if( d.data.test( function(v) return v.x == x && v.y == y  ) ) return d;
		}
		return null;
	}
	
	public function getDoorPad( dep : DepInfos ) : Array<V2I>
	{
		Debug.ASSERT( dep != null );
		var pos = [ dep.data.nth(0).clone(), dep.data.nth(1).clone() ];
		var s = dep.te.setup.index;
		
		if (StringTools.startsWith( s, "DOOR_R")) 	{ pos[0].y++; pos[1].y++; }
		else if (StringTools.startsWith( s ,"DOOR_L"))	{ pos[0].x++; pos[1].x++; }
		else if (StringTools.startsWith( s, "DOOR_BL"))	{ pos[0].y--; pos[1].y--; }
		else if (StringTools.startsWith( s, "DOOR_BR"))	{ pos[0].x--; pos[1].x--; }
		else Debug.BREAK("unknown door tag");
		
		return pos;
	}
	
	public function getDoorDir( dep : DepInfos ) : Dirs.E_DIRS
	{
		var s = dep.te.setup.index;
		
		if (StringTools.startsWith( s, "DOOR_R"))  return UP;
		else if (StringTools.startsWith( s ,"DOOR_L")) return LEFT;
		else if (StringTools.startsWith( s, "DOOR_BL")) return DOWN;
		else if (StringTools.startsWith( s, "DOOR_BR")) return RIGHT;
	
		return null;
	}
	
	public inline function get(x : Int, y: Int)
	{
		return store.get( getKey( x,y ));
	}
	
	public static inline function getKey(x,y) : Int
	{
		return (x << 16) | y;
	}
	
	public inline function tiles() : Iterable<Tile>
	{
		return store;
	}
	
	public function allEntities() : Iterable<Entity>
	{
		return entities.flatten();
	}
	
	public function getDeps(x:Int, y:Int) : Array<DepInfos>
	{
		return dependancies.filter(function(d)
		{
			return d.data.test( function(v) return v.x == x && v.y == y );
		});
	}
	
	public function testChair( x, y)
	{
		return dependancies.test(function(d)
		{
			return d.data.test( function(v) return v.x == x && v.y == y &&
			switch(d.gameData)
			{
				default:false;
				case Chair:true;
			});
		});
	}
	
	public function getChair( x, y) : DepInfos
	{
		for( d in dependancies)
		{
			switch(d.gameData)
			{
				default:
				case Chair:
					if ( d.data.test( function(v) return v.x == x && v.y == y))
						return d;
			}
		}
		
		return null;
	}
	
	public function getDepPad(x:Int, y:Int): DepInfos
	{
		return dependancies.find(function(d)
		{
			return d.pad.test( function(v) return v.isEq2( x,y ) );
		});
	}
	
	public function tile(x:Int, y:Int) : Tile
	{
		var k = getKey( x, y);
		var tl = store.get(k);
		if( tl == null )
		{
			tl = new Tile(this).setPos(x, y);
			tl.root().el.visible = true;
			addChild( tl.root().el );
			store.set(k, tl);
			Debug.ASSERT( store.get( k ) == tl);
		}
		return tl;
	}
	
	public function isWalkable(x:Int,y:Int)
	{
		var t = get( x, y);
		if( t == null) return false;
		if( t.get( Wall ) != null) return false;
		if( t.get( Ground ) == null) return false;
		
		for( d in dependancies)
		{
			if( x >= d.rectCache[0].x
			&&	x <= d.rectCache[1].x
			&&	y >= d.rectCache[0].y
			&&	y <= d.rectCache[1].y
			)
			{
				if ( d.gameData != Decal && d.gameData != Chair)
				{
					if ( d.ent != null  )
					{
						if( d.ent.el.visible )
							return false;
						else
							return true;
					}
					else
						return false;
				}
			}
		}
		return true;
	}
	
	public function isPathable(x:Int,y:Int)
	{
		var t = get( x, y);
		if( t == null) return false;
		if( t.get( Wall ) != null) return false;
		if( t.get( Ground ) == null) return false;
		
		for( d in dependancies)
		{
			if( x >= d.rectCache[0].x
			&&	x <= d.rectCache[1].x
			&&	y >= d.rectCache[0].y
			&&	y <= d.rectCache[1].y
			)
			{
				if ( d.gameData != Decal && d.gameData != Chair)
				{
					if ( d.ent != null  )
					{
						if( d.ent.el.visible )
							return false;
						else
							return true;
					}
					else
						return false;
				}
			}
		}
		
		return getNpc(x, y) == null;
	}
	
	public function isSpawnable(x:Int,y:Int)
	{
		if(! isPathable(x, y) ) return false;
		
		for( d in dependancies)
			if(d.pad!=null)
				if( d.pad.test( function(v) return v.isEq2(x, y)) )
					return false;
		
		return true;
	}
	
	
	public static inline function sortFunc(a : Z,b: Z)
	{
		var az = a.getZ();
		var bz = b.getZ();
		
		var apr = a.getPrio();
		var bpr = b.getPrio();
		//eq
		if( Math.abs(az - bz) <= 0.01 )
		{
			if( bpr > apr ) return 1;
			else if( bpr == apr )
			{
				return Std.int( a.getDo().x - b.getDo().x);
			}
			return -1;
		}
		else
		{
			if( az > bz ) return 1;
			else return -1;
		}
	}
	
	public static inline function sortFunc2(e0 : {  rect: Array<V2I>, ent : Entity },e1 : {  rect: Array<V2I>, ent : Entity })
	{
		return Std.int( - e1.rect[0].y + e0.rect[0].y ) ;
	}
	
	public function dirtSort() dirty = true;
	
	public inline function myRemoveChildren()
	{
		#if !flash11
			while( numChildren != 0 ) removeChildAt( 0 );
		#else
			removeChildren();
		#end
	}
	
	public var tileArrCache :Array<Z>;
	public var tileCache : Sprite;
	
	public function sort()
	{
		var flatEnt :Array<Entity> = [];
		//flatten
		if( !entities.empty() )
			for(c in entities)
				for(e in c)
					flatEnt.push( e );
		
		var disp = flatEnt.dispatchByEnum( Engine, function(v) return v.engine );
		var sweepSortArr : Array<{ rect : Array<V2I>, ent : Entity }> = [];
		
		for ( e in disp.get(UseEntity) ) 
			sweepSortArr.push( { rect:e.getRect(), ent:e } );
		
		//first
		if(disp.get(UsePreWall)!=null)
		for(t in disp.get(UsePreWall))
			addChild(t.getDo());
			
		if (tileArrCache != null)
			addChild(tileCache);
		else
		{
			var tileArr : Array<Z> = cast store.array();
			
			//tile structure
			if(disp.get(UseTile)!=null)
			for( v in disp.get(UseTile)) tileArr.push( v );
			tileArr.sort( sortFunc );
			for(t in tileArr)
				tileCache.addChild(t.getDo());
			tileArrCache = tileArr;
			addChild(tileCache);
		}
			
				
		//just after
		for ( x in postWall) addChild( x );
		
		if(disp.get(UsePostWall)!=null)
		for( v in disp.get(UsePostWall)) addChild( v.getDo() );
			
		//go entities go !
		var sweepRes : Iterable<SweepEntry> = algo.SweepRenderer.doSweep( sweepSortArr );
			
		for(t in sweepRes)		addChild( t.ent.getDo());
		for( x in postFx)		addChild( x );
		if(disp.get(UsePostFx)!=null)
			for ( v in disp.get(UsePostFx)) 
				addChild( v.getDo() );
				
		
		dirty = false;
		
		//trace(Profiler.get().dump());
		//Profiler.get().clean();
		
		//crawl( this );
	}
	
	public static function crawl(o:DisplayObjectContainer)
	{
		for(x in 0...o.numChildren)
		{
			var child =  o.getChildAt( x );
			var chCont : DisplayObjectContainer = cast child;
			var chElem : mt.pix.Element = cast child;
			/*
			if(chElem != null )
				if(chElem.mouseEnabled)
					Debug.MSG( "me: " +chElem.dbgName + " " + chElem.toString() );
			*/
			if(chCont!=null)
				crawl( chCont );
		}
	}
	
	public override function toString()
		return 'Grid : Room = $rid ';
	
	public function getDep( x, y) : Null<DepInfos>
	{
		return dependancies.find( function(d) return d.data.exists( function(v:V2I) return v.x == x && v.y == y ) );
	}
	
	public function findDoorTo( need : RoomId ) : DepInfos
	{
		for( d in dependancies )
		{
			if( !isDoor( d.gameData ) ) continue;
			switch(d.gameData)
			{
				case Door( here, there):
					if (	( there == need )
					|| 		( here == need )	)
					{
						//Debug.MSG(" ok : " +here+"," + there +" "+need );
						return d;
					}
				default://skip
			}
		}
		return null;
	}
	
	
	public function onClick( tile : Tile )
	{
		if( entities.get(PLAYER) == null ) return;
		
		var pl = entities.get(PLAYER).first();
		
		if ( pl != null && Main.ship.player != null && tile.isPathable())
		{
			if(Main.ship.player.laid)
				ServerProcess.touch();
			Main.ship.player.jumpTile( tile);//to
		}
	}
	
	
	var fires : Array<fx.CellFire>;
	
	public function  setFire()
	{
		if (onFire) return;
		onFire = true;
		Debug.MSG("setting fire");
		var tiles = tiles().filter( function (t) return t.get( Ground ) != null );
		
		//Debug.MSG("tiles = "+tiles.length);
		
		var lim = 30;
		var nb = 0;
		
		var max_nb = MathEx.maxi( 8 ,  Std.int(0.5 + tiles.length * 20 / 100 ));
		
		for(x in 0...max_nb)
		{
			var t = tiles.random();
			tiles.remove( t );
			var grPos = t.getGridPos();
			var f = new fx.CellFire( this,grPos.x,grPos.y);
			fires.push(f);
			nb++;
			if (nb > lim) break;
		}
	}
	
	public function unsetFire()
	{
		if( onFire){
			for( f in fires ) f.kill();
			fires = [];
			onFire = false;
		}
	}

	public function resetGfx()
	{
		x = 0; y = 0; alpha = 1; blendMode = flash.display.BlendMode.NORMAL;
	}
	
	public function update()
	{
		input.update();
		
		var t = Protocol.roomDb( getRid() ).type;
		switch(t)
		{
			default: 
			case PATROL_SHIP:
			{
				x += Math.sin( mt.Timer.oldTime * 2);
				y += Math.sin( mt.Timer.oldTime * 10) + Math.cos( mt.Timer.oldTime * 7.5 );
			}
		}
		
		fires.iter( function(f) f.update() );
		
		for(x in entities.list())
			for ( e in x .list())
				e.update();
				
		if( dirty )
			sort();
		
	}
	
	public function getDepByItem( it : ItemId )
		return dependancies.filter( function(d) return d.iid == it );
		
	public function getDepByUid( uid: Int )
		return dependancies.filter( function(d) return d.itemUid == uid);
		
	public function getDepByTarget( str:String )
		return dependancies.filter( function(d) return d.target == str );
	
	public function getDepByKey( str:String )
		return dependancies.filter( function(d) return d.key == str );
		
	public function viewToGrid( x:Float, y:Float )
	{
		//in world
		var wx = x + Main.view.x;
		var wy = y + Main.view.y;
		
		return V2DIso.pix2Grid( wx, wy );
	}
	
	public function gridToView( x:Float, y:Float )
	{
		var g = V2DIso.grid2px( x, y);
		
		//in world
		//g.x -= Main.view.x;
		//g.y -= Main.view.y;
		
		return g;
	}
}




