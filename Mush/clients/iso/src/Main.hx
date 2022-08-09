package ;

import flash.display.StageScaleMode;
import flash.Lib;
import fx.Moisify;
import fx.RedSeq;
import haxe.Log;
import haxe.PosInfos;
import haxe.Timer;
import mt.fx.Blink;
import mt.fx.Shake;
import mt.fx.Vanish;
import Spr3D;
import mt.bumdum9.Lib;
import IsoConst;
import Keyboard;
import CrossConsts;

import IsoProtocol;
import Data;
import Protocol;
import Protocol.ShipStatsId;

import haxe.remoting.ExternalConnection;
import haxe.remoting.Proxy;

import flash.display.MovieClip;
import flash.display.Sprite;
import fx.Starfield;

import Data;
import Types;
using Ex;
using As3Tools;

import data.Map;
import data.Level;

import Grid;

import IntHash;
import Hash;

class BmpGfxBg extends flash.display.BitmapData
{
	
}

/**
 * ...
 * @author de
 */

typedef Save =
{
	viewX : Int,
	viewY : Int,
	
	scale2 : Bool,
	curRoom : Int,

	?red_grid : Bool,
}

enum _ClientState
{
	_Idle;
	_Decoding;
	_Looping;
	_DecodingUpgradeDone;
	_DecodingPeopleDone;
	_DecodingMinimapDone;
	_DecodingStart;
	_DecodingPlayerDone;
	_DecodingMoving;
	_DecodingItemDone;
	_DecodingBattleDone;
	_DecodingUpdateChar;
	_DecodingNpcDone;
	_DependancyCheck;
	_DependancyChecked;
	_FireChecked;
	_MarkingNpcDone;
}

@:keep
class Main
{
	public static var eventQueue : List<NT_ISO_EVENT>;
	public static var data : Data;
	public static var view : View = new View();
	public static var ship : Ship = new Ship();
	
	public static var fxm = new mt.fx.Manager();
	public static var tweenie = new mt.deepnight.Tweenie();
	
	public static var mouse	 : Mouse = null;
	public static var keyb : Keyboard = null;
	public static var time : Float = 0;
	
	public static var previousServerData : _RoomsClientData = null;
	public static var incServerData : _RoomsClientData = null;
	public static var actServerData : _RoomsClientData = null;
	public static var actServerDataExt :
	{
		projects:FlagsArray<ProjectId>,
		researches:FlagsArray<ResearchId>,
		uiFlags: Flags<CrossConsts.UI_FLAGS>,
		
	} = null;
	
	public static var loadingScreen : MovieClip = new MovieClip();
	public static var bg0Screen : flash.display.Sprite = new Sprite();
	public static var gui : Gui = new Gui();
	
	
	public static var allHumanNPC : Array<HumanNPC> = [];
	
	//non human npc
	public static var allNPC : IntHash<NPC> = new IntHash();
	
	public static var state : _ClientState = _Idle;
	public static var infos : { ?item : _ItemDesc, ?room:RoomId,?fire:Bool, ?endItemUpdate:Bool} =  { };
	
	
	static var swf2JsProxi : Swf2JsProxi;
	
	static var ctx = new haxe.remoting.Context();
	static var cnx : ExternalConnection;
	
	
	static function goToFirebug()
	{
		mt.deepnight.Lib.redirectTracesToConsole();
	}
	
	public static function getProxy()
	{
		return swf2JsProxi;
	}
	
	public static function evalEvent(e:NT_ISO_EVENT) {
		Debug.MSG("evaluating prx event "+e);
		switch(e) {
			case IE_DO_THE_THING(_, _, _):
			case IE_MASSGGEDON:
				if ( ship.current() == null || ship.current().data == null )
					return;
					
				new Moisify(view);
				var d = grid().getRoomNpcs();
				for ( n in d ) {
					new RedSeq( n.el );
				}
				
				
			case IE_SHAKE:
				{
					if( ship.current() != null && ship.current().data!=null && !shaking)
					{
						shaking = true;
						var s = new Shake(ship.current().data, 0, 75, 0.85,1);
						s.onFinish = function() shaking = false;
					}
				}
				
			case IE_HURT(hid): {
				var h = allHumanNPC.find( function(h) return h.hid == hid );
				if ( h != null ) h.onHurt();
				//trace(e);
			}
		}
	}
	
	static var shaking = false;
	
	public static function onEvent(e:NT_ISO_EVENT) {
		if (eventQueue == null) eventQueue = new List();
		Debug.MSG("received prx event "+e);
		eventQueue.push( e );
	}
	
	static function tryConnect()
	{
		try
		{
			cnx = haxe.remoting.ExternalConnection.jsConnect( CrossConsts.REMOTING_COM_CHANNEL, ctx);
			if( cnx != null)
			{
				try
				{
					swf2JsProxi = new Swf2JsProxi(cnx.swf2Js);
					if( swf2JsProxi !=null )
						swf2JsProxi._echo();
				}
				catch(d:Dynamic)
				{
					swf2JsProxi = null;
					cnx = null;
				}
			}
		}
		catch(d:Dynamic)
		{
			cnx = null;
		}
	}
	
	static function domains()
	{
		var domain = flash.Lib.current.loaderInfo.url.split("/")[2];
		if( domain.substr(0,5) == "data." ) flash.system.Security.allowDomain(domain.substr(5));
	}
	
	public static function resetServerData( data : _RoomsClientData ) : Void
	{
		state = _Decoding;
		//only to let the exception stack
		if ( IsoConst.EDITOR )
		{
			setServerData( data );
			return;
		}
		
		setServerData( data );
		state = _Idle;
	}
	
	public static function getInfos(){
		var s = "";
		if ( infos.room != null)
			s += " rid:" + infos.room;
			
		if ( infos.item != null)
			s += " item:" + Protocol.itemIdList[infos.item.id.index()]
			+" ser:" + Std.string( infos.item );
			
		s += " others:" + Std.string( infos );
		return s;
	}
	
	public static function getKey( id : _ItemDesc ) {
		return id.customInfos.locate( function(ci) return switch(ci) { default:null; case _Key(k):k; } );
	}
	
	public static inline function isAdmin() {
		if ( actServerData != null)
			return Utils.Bit_is(actServerData.flags, 1 << CrossFlags.IsA.index());
		
		if ( incServerData != null)
			return Utils.Bit_is(incServerData.flags, 1 << CrossFlags.IsA.index());
			
		return false;
	}
	
	static function setServerData(data)
	{
		//Profiler.get().begin("setServerData");
		var dbg = true;
		if (data == null)
		{
			//Debug.MSG("no data to do");
			//Profiler.get().end("setServerData");
			return;
		}
		//trace("flsh:update started" );
		Debug.MSG("received data ...");
		if(dbg) Debug.MSG("received server data " + Std.string(data) );
		
		//diff datas
		incServerData = data;
		
		var first = actServerData == null;
		
		var old : _RoomsClientData = actServerData;
		var nu : _RoomsClientData = incServerData;
		
		state = _DecodingStart;
		
		 Debug.MSG("scanning items");
		//trace(incServerData);
		//trace(incServerData.showPatrol);
		
		if( nu.me.items != null)
		{
			//Profiler.get().begin('doMini');
			var doMinimap = nu.me.items.test( function(i)
			{
				//mt.gx.Debug.assert( i != null);
				//mt.gx.Debug.assert( i.id != null);
				return (i.id == TRACKER || i.id == SUPER_TALKY) && !Flags.test( i.status, BROKEN  );
			});
			
			
			#if debug
				gui.setMinimap(true);
			#else
				gui.setMinimap( doMinimap );
			#end
			
			//Profiler.get().end('doMini');
		}
		else
		{
			if(dbg) Debug.MSG("no minimap possible");
		}
		
		state = _DecodingMinimapDone;
		
		haxe.Timer.delay(function() {
			
		if ( Protocol.roomDb( nu.me.room ).type == PATROL_SHIP )
			Main.sf.type = SF_PATROL;
		else
			Main.sf.type = nu.daedalus.traveling ? SF_DAEDALUS_TRAVELING : SF_DAEDALUS_STOPPED;
		
		for(  h in ship.people )
			h.mark = false;
		
		if(dbg) Debug.MSG("updating people");
		for (p in nu.people)
		{
			if ( p.id == nu.me.id ) continue;
			if(dbg) Debug.MSG("updating " + Protocol.heroesIdList[p.id.index()].id+" main:"+nu.me.id);
			
			ship.setPeopleRoom( p,true );
		}
		
		if (dbg) Debug.MSG("done updating people");
		
		state = _DecodingPeopleDone;
		
		haxe.Timer.delay(function()
		{
		if ( first)
			ship.setPlayer( nu.me );
		else
		{
			var myGrid = ship.getRoom( nu.me.room ).data;
			
			if ( ship.player.getGrid().getRid() != nu.me.room)
			{
				ship.player.changeRoom( ship.player.getGrid(), myGrid );
				ship.player.refresh( nu.me );
			}
			else {
				if ( gui.minimap != null) gui.minimap.setPeopleRoom( nu.me.id, nu.me.room,true   );
				ship.player.data = nu.me;
			}
		}
		
		state = _DecodingPlayerDone;
		
		haxe.Timer.delay(function()
		{
		if(!ServerProcess.waitingServer)
		{
			if (dbg) Debug.MSG("updating view");
			
			if(	grid() == null
			|| 	grid().getRid() != nu.me.room)
			{
				ship.setCurRoom( nu.me.room );
				if (dbg) Debug.MSG("current room set" + nu.me.room );
			}
		}
		else
		{
			if ( grid().getRid() != nu.me.room)
				ServerProcess.confirmLeave(grid().getRid(),nu.me.room);
		}
		
		state = _DecodingMoving;
		
		haxe.Timer.delay(function()
		{
		//todo handle rooms statuses
		 Debug.MSG("updating map");
		for(r in nu.shipMap )
		{
			var st :Flags<RoomStatusId> = Flags.ofInt( r.status );
			var grid : Grid = Main.ship.getRoom( r.id ).data;
			
			infos.room = r.id;
			infos.fire = true;
			
			if(st.get( FIRE ))		grid.setFire();
			else					grid.unsetFire();
		
			infos.fire = false;
			
			if(dbg) Debug.MSG("updating items");
			grid.startItemUpdate();
			
			var obj = { iid: null, key: null,inf:null};
			for ( d in grid.dependancies) {
				if ( d.te.el.visible == false ) continue;
				
				//fill in iid and dep
				if( d.gameData !=null)
				switch(d.gameData)
				{
					default:
						continue;
						
					case Equipment(iid):
						obj.iid = iid;
						obj.inf = Protocol.itemList[iid.index()];
						obj.key = d.key;
				}
				
				if ( obj.inf.disassemble.length <= 0 )
					continue;
				
				var found = false;
				for (i in 0...r.inventory.length ){
					var ri = r.inventory[i];
					if ( ri.id == obj.iid ) {
						//found matching, it is ok, this item still exists
						var k = getKey( ri );
						if( k == null )
						{	found = true; break; }
						else if (k == obj.key )
						{	found = true; break;  }
					}
				}
				
				if ( !found ) {
					var dur = 30;
					new Vanish(d.te.el,dur);
				}
				
				obj.iid = null; 
				obj.key = null; 
				obj.inf = null;
			}
			
			
			var il = r.inventory.length;
			for (i in 0...r.inventory.length )
			{
				var ri = r.inventory[i];
				grid.updateItem( ri );
				infos.item = ri;
			}
			infos.item = null;
			grid.endItemUpdate();
			infos.endItemUpdate = null;
			
			infos.room = null;
		}
		
		state = _DecodingItemDone;
		haxe.Timer.delay(function()
		{
		for ( n in allNPC) n.mark = false;
		state = _MarkingNpcDone;
		
		if( incServerData != null)
			for ( i in incServerData.npc)
			{
				if ( !allNPC.exists( i.uid ))
				{
					var n = new NPC( getGrid( i.room), i );
					n.mark = true;
				}
				else
				{
					var n = allNPC.get( i.uid );
					n.refresh( i );
				}
			}
			
		for ( n in allNPC.list() )
			if ( !n.mark )
				{ 	allNPC.remove( n.data.uid ); 	n.kill(); }
		
		for(  h in ship.people )
			if ( !h.mark )
				{	ship.people.remove( h.hid );		h.kill(); }
		
		state = _DecodingNpcDone;
		
		var hadData = actServerData != null;
		
		haxe.Timer.delay(function()
		{
			Debug.MSG("diffing");

			{
				previousServerData = actServerData;
				actServerData = nu;
				
				var oldDataEx = actServerDataExt;
				
				actServerDataExt =
				{
					projects: 	new FlagsArray(ProjectId).rawFill( nu.projects ),
					researches: new FlagsArray(ResearchId).rawFill( nu.researches),
					uiFlags: 	new Flags(nu.uiFlags),
				};
				
				
				if ( actServerDataExt.uiFlags.has( UF_FORCE_CLOSET_OPENED ) )
				{
					Debug.MSG("forcing closet");
					for ( s in ship.selectables )
						if ( s.isCloset && s.grid == ship.player.getGrid() )
							{
								s.select();
								ServerProcess.showCloset(true);
							}
				}
				//dirtMinimap();
				haxe.Timer.delay( function()
				{
					makePlanet();
					runners.add();
					runners.refresh();
				},1);
				incServerData = null;
			}
			
			sf.type = sf.type;
			state = _DecodingUpdateChar;
			haxe.Timer.delay(function()
			{
				Debug.MSG("checking battle");
				checkBattle();
				state = _DecodingBattleDone;
				haxe.Timer.delay(function()
				{
					{
						Debug.MSG("checking upgrades");
						ship.checkUpgrades();
						if(dbg) Debug.MSG("done checking upgrades");
						state = _DecodingUpgradeDone;
					}
					
					haxe.Timer.delay(
					function()
					{
						if ( old != null )
						{
							if( !ServerProcess.waitingServer)
								Main.doVp();
							if(dbg) Debug.MSG("doign insta vp");
						}
						else
						{
							Debug.MSG("delaying scene show");
							haxe.Timer.delay( showScene, 20);
						}
							
						ServerProcess.end();
						
						processLaid();
						dirtMinimap();
						
						/*if (dbg)*/ Debug.MSG("evaluating events");
						
						haxe.Timer.delay( function() {
							if(eventQueue!=null)
								eventQueue.iter(evalEvent);
							eventQueue = new List();
							if (dbg) Debug.MSG("eventQueue ok");
						},100);
						
						if (dbg) Debug.MSG("finishing");
					 },1);
				 },1);
			 },1);
		},1);
		},1);
		},1);
		},1);
		},1);
		},1);
			
		
		//Profiler.get().end("setServerData");
		//if ( isAdmin() )
		//	trace( Profiler.get().dump() );
		
		//Profiler.get().clean();
	}
	
	public static var imgCache :Hash<flash.display.BitmapData>=  new Hash();
	public static function makePlanet() {
		
		if ( actServerData.add.planet == null)
		{
			if( ship.planet != null)
				ship.planet.clean();
			ship.planet = null;
		}
		else
		{
			if (ship.planet != null)
			{
				if ( ship.planet.seed == actServerData.add.planet.seed )
					return;
				else
				{
					ship.planet.clean();
					ship.planet = null;
				}
			}
			
			var n = actServerData.add.planet.imgName;
			function mk(_, bmp)
			{
				imgCache.set( actServerData.add.planet.imgName, bmp );
				ship.planet = new ui.Planet( bmp, actServerData.add.planet.seed );
				Debug.MSG("creating planet " + actServerData.add.planet);
				As3Tools.putBefore( ship.planet,Main.sf.root );
			}
			
			if( !imgCache.exists( n ) )
				As3Tools.loadBitmap( n, mk );
			else
				mk( null, imgCache.get( n ));
		}
	}
	
	
	public static function processLaid() {
		
		haxe.Timer.delay( function()
		{
			var embodied = [];
			var touched = 0;
			var r = ship.player.getRid();
			
			for ( i in actServerData.shipMap.get( r.index() ).inventory )
			{
				var b = null;
				i.customInfos.iter( function(c) switch(c) { case BodyOf(h, _): b = h; default: } );
				if ( b != null)
				{
					embodied.push( { item:i, body:b } );
					touched |= 1 << b.index();
					//trace("bodied "+i);
				}
			}
			
			for ( p in ship.people)
			{
				if ( p == ship.player) continue;
				if ( p.laid)
					if ( (touched & (1 << p.hid.index()) ) == 0)
						p.circa( p.getTile());
				
				if ( p.getRid() == r && (touched & (1 << p.hid.index())!=0 ))
				{
					for ( h in embodied )
						if ( h.body == p.hid )
							p.layDown( h.item );
				}
			}
				
			mt.gx.Debug.assert( ship.player != null);
			
			for ( h in embodied )
				if (ship.player.hid == h.body)
					ship.player.layDown( h.item );
				 
			
			if ( ship.player.laid && (touched & (1 << ship.player.hid.index()) ) == 0)
				ship.player.circa( ship.player.getTile());
			
				
			
		},1);
	}
	
	public static function checkBattle() {
		
		if ( ship.player == null)
		{
			//trace("checkBattle error : no player ");
			return;
		}
		
		var hadData = false;
		var data = Protocol.roomDb( ship.player.location() );
		
		if(	data.type  == LASER_TURRET
		||	data.type == PATROL_SHIP )
		{
			Main.view.onEndScroll(
			function()
			{
				if(Main.actServerData!=null)
				{
					if ( ship.battle != null)
						ship.battle.updateData();
					else
					{
						ship.battle = new ui.SpaceBattle(true,true);
						Main.guiStage().addChild(  ship.battle );
						
						if (gui.minimap != null)
						{
							ship.battle.sendBefore( gui.minimap.mc);
							ship.battle.sendBefore( gui.minimap.preMc);
						}
						gui.tip.spr.toFront();
					}
				}
			}
			);
		}
		else
		{
			if ( ship.battle != null)
			{
				ship.battle.detach();
				ship.battle = null;
			}
		}
	}
	
	public static function doVp(insta=false){
		//Debug.MSG("doing vp " + insta+ ""+haxe.Stack.callStack().join(""));
		
		if ( insta)
			Main.view.stopScroll();

		if ( ship.player != null)
		{
			var type = Protocol.roomList[ ship.curRoom.index() ].type;
			
			if( Player.DYN_VP.has( type ) )
				Main.focusPlayer( insta );
			else
				Main.centerVp();
		}
		else
			centerVp();
	}
	
	public static function dirtMinimap(){
		if( gui.minimap !=null )
			gui.minimap.dirty = true;
	}
	
	static function doLoader() {
		
		loadingScreen.graphics.beginFill( 0x09092d,1 );
		loadingScreen.graphics.drawRect( 0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		loadingScreen.graphics.endFill();
		loadingScreen.mouseEnabled = false;
		loadingScreen.visible = true;
		Lib.current.addChild( loadingScreen );
		loadingScreen.toFront();
	}
	
	
	static function startup() {
		
		domains();
		load();
		
		if(!IsoConst.EDITOR)
			goToFirebug();
		
		//Lib.current.stage.quality = flash.display.StageQuality.LOW;
		data = new Data();
		
		//Debug.MSG("generating world");
		data.init();
		ship.check();
		
		ship.parseUnlocks();
		
		//Debug.MSG("...done");
		haxe.Log.setColor( 0xCDCDCD );
		
		if( !IsoConst.EDITOR)
		{
			Debug.MSG( "welcome to the server part");
		}
		else
		{
			gui.setMinimap( true );
		}
		
		Lib.current.addChild( view );
		loadingScreen.toFront();
		
		mouse = new Mouse();
		keyb = new Keyboard().init(Lib.current.stage);
		keyb.enabled = enableInput;
		
		mkHandlers();
		gui.init();
		{
			var spr = new flash.display.Sprite();
			var bmp = new BmpGfxBg(0, 0);
			
			var w = bmp.width;
			var h = bmp.height;
			
			spr.graphics.beginBitmapFill(bmp);
			spr.graphics.moveTo( -w * .5, -h * .5 );
			spr.graphics.drawRect(0,0,w,h);
			spr.graphics.endFill();
			spr.mouseEnabled = false;
			
			Lib.current.addChild(spr);
			Lib.current.setChildIndex( spr, 0);
			
			bg0Screen = spr;
		}
		
		view.init();
		view.scrollPix(mem.viewX, mem.viewY);
			
		if ( sf != null) sf.kill();
		
		sf = new fx.Starfield( SF_DAEDALUS_STOPPED,  Main.bg0Screen );
		sf.root.toFront();
		
		runners = new ui.SpaceRunners();
		runners.add();
		
		var mid = V2DIso.grid2px( 16 , 16);
		sf.root.x = mid.x;
		sf.root.y = mid.y;
		
		//load engine
		{
			ship.init();
			
			#if !master
			view.addChild( IsoUtils.getGizmo() );
			#end
			
			flash.Lib.current.stage.addEventListener( flash.events.Event.ENTER_FRAME, update );
			flash.Lib.current.stage.addEventListener( flash.events.Event.RESIZE, resize );
			
			updateScale();
		}
		Debug.MSG("engine started");

		//startup
		{
			var r = Type.createEnumIndex( RoomId, mem.curRoom );
			//CURRENT ROOM HERE
			
			if( IsoConst.EDITOR )
			{
				var rr = data.getDebugStart();
				if( rr != null )
				{
					Debug.MSG("overriding start location");
					r = rr;
				}
			}
			
			ship.setCurRoom( r );
			
			var grid = ship.current().data;
			startLogic();
		}
		Debug.MSG("logic started");
		
		update(null);
		Debug.MSG("silent update done");
		
		if( !IsoConst.EDITOR)
			ctx.addObject("js2Swf_ISO_MODULE", new Js2Swf_ISO_MODULE());
			
		if ( IsoConst.EDITOR)
			showScene();
	}
	
	
	static function resize(d)
	{
		gui.update();
	}
	
	public static var sf : fx.Starfield;
	public static var runners : ui.SpaceRunners;
	
	static function showScene()
	{
		if ( false )
		{
			var vx = new TweenEx.VanishEx(loadingScreen, 16,16,true);
			vx.fadeAlpha = true;
			vx.onKill = function(mc)
			{
				if( mc.parent != null)
					mc.parent.removeChild( mc );
			}
		}
		else
		{
			loadingScreen.detach();
		}
		trace("showing scene");
		Main.doVp(true);
	
	}
	
	static function main()
	{
		inputSkip = false;
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		doLoader();
		haxe.Timer.delay(startup,1);
	}
	
	static function updateScale()
	{
		if( mem.scale2)
		{
			view.scaleX = 2;
			view.scaleY = 2;
		}
		else
		{
			view.scaleX = 1;
			view.scaleY = 1;
	 	}
	}
	
	static var hideAllEntities = false;
	
	static function mkHandlers()
	{
		#if master
		return;
		#end
		
		keyb.addReleasedHandler( flash.ui.Keyboard.A, function(_)
			{
				for ( d in grid().dependancies)
				{
					if ( d.gameData != Chair) continue;
					
					var nn = new HumanNPC(grid(), { 
							id:STEPHEN_SEAGULL, 	room:LABORATORY, mutant:false, items:new List(), serial:"zorglub", life:1.01, vanities:new List(),
							skin:1,					diseases:new List()} );
					nn.init( grid(), null);
					nn.setChar( HeroId.random() );
					nn.setPos( d.pad[0].x, d.pad[0].y);
				}
			},
			"Press A to put chars on all chairs");
			/*
		keyb.addReleasedHandler( flash.ui.Keyboard.B, function(_)
			{
				ServerProcess.sendError( "gya" );
			},
			"Press B to sim errors");
			*/
		keyb.addReleasedHandler( flash.ui.Keyboard.R, function(_)
		{
			var current = grid().getRid();
			var next : RoomId = current.next( RoomId );
			mem.curRoom = next.index();
			ship.setCurRoom( next );
		},
		"Press R to cycle Rooms");
		
		
		keyb.addReleasedHandler( flash.ui.Keyboard.C, function(_)
		{
			if( ship.battle!=null)
				ship.battle.visible = !ship.battle.visible;
		},
		"Press C to toggle battle vis");
		
		
		keyb.addReleasedHandler( flash.ui.Keyboard.D, function(_)
		{
			var p = ship.player;
			var ctr = CITROUILLITE.index();
			if ( p.data.diseases.has(ctr) )
			{ 	p.data.diseases.remove(ctr); trace('removed '+p.data);  }
			else
			{ p.data.diseases.add(ctr);trace('added');}
		},
		"Press D to debug smthg");
		
		
		keyb.addReleasedHandler( flash.ui.Keyboard.E, function(_)
		{
			ship.checkUpgrades();
		},
		"Press E to mute");
		
		keyb.addReleasedHandler( flash.ui.Keyboard.H, function(_)
		{
			var d = grid().dependancies.filter( function(d)
				return d.iid == ItemId.RESEARCH_LAB ).first();
			
			var l = new List();
			
			if ( d != null)
				l.push(CatOccupation( d.itemUid ));
			
			new NPC( grid(),
			{
				id:Cat,
				uid:0,
				room:grid().getRid(),
				state:l,
				life:3.002,
			});
		},
		"Press F to spawn cat, if lab it will try to sit");
		
		
		keyb.addReleasedHandler( flash.ui.Keyboard.SPACE, function(_)
			Debug.MSG( ship.current().data),
			"Press SPACE to dump grid state");
			
		
		keyb.addReleasedHandler( flash.ui.Keyboard.I, function(_)
			{
				var ai = Main.grid().getAi();
				ai.updateWeights();
				
				var fr0 = Main.grid().randomFree();
				var fr1 = Main.grid().randomFree();
				
				ai.mkPathFrom( AIView.mkNid(fr0.pos.x,fr0.pos.y) );
				//ai.pathTo( fr1 );
			},
			"Press I  to sim ai");
			
		keyb.addReleasedHandler( flash.ui.Keyboard.BACKSPACE, function(_)
			{
				Debug.MSG( Profiler.get().dump() );
				Profiler.get().clean();
			},
			"Press BACKSPACE to dump profiler");
		
		keyb.addReleasedHandler( flash.ui.Keyboard.K, function(_)
			{
				resetMem();
				save();
				ship.setCurRoom( RoomId.COMMAND_CENTER );
				var gr = grid().tiles().filter( function(t) return t.isSpawnable() ).random();
				ship.player.setPos( gr.getGridPos().x,gr.getGridPos().y);
			},
			"Press K to reset all");
			
			
		keyb.addReleasedHandler( flash.ui.Keyboard.M, function(_)
			{
				grid().dirtSort();
				Debug.MSG("dirt sort forced");
			},
			"Press M to dirt sort");
		
		keyb.addReleasedHandler( flash.ui.Keyboard.K ,function(_)
		{
			Main.grid().setFire();
		},"Press K to set fire");
		
		keyb.addReleasedHandler( flash.ui.Keyboard.F, function(_)
			{
				focusPlayer();
			},
			"Press F to focus player");
		
		keyb.addReleasedHandler( flash.ui.Keyboard.NUMPAD_ADD ,function(_)
		{
			ship.player.doKill();
		},"Press + to trigger a debug func");
		
		keyb.addReleasedHandler( flash.ui.Keyboard.O, function(_)
			{
				hideAllEntities = !hideAllEntities;
				for(x in grid().allEntities() )
				{
					if( x.type == Entities.PLAYER )
					{
						x.getDo().visible = !hideAllEntities;
					}
				}
			},
			"Press O to toggle player vis");
			
		keyb.addReleasedHandler( flash.ui.Keyboard.P, function(_)
			{
				Main.bg0Screen.visible = ! Main.bg0Screen.visible;
			},
			"Press O to toggle BG vis");
		
			
		keyb.addReleasedHandler( flash.ui.Keyboard.J, function(_)
			{
				Main.grid().unsetFire();
			},
			"Press J to unset fire");
			
		keyb.addReleasedHandler( flash.ui.Keyboard.L, function(_)
			{
				Main.grid().unsetFire();
			},
			"Press J to unset fire");
			
		keyb.addReleasedHandler( flash.ui.Keyboard.Z, function(_)
			{
				ship.player.set = CharSet.random();
			},
			"Press L to go ot next set");
			
		keyb.addReleasedHandler( flash.ui.Keyboard.T, function(_)
			{
				ship.player.turn(true);
			},
			"Press T to turn player");
			
		keyb.addReleasedHandler( flash.ui.Keyboard.Y, function(_)
			{
				new fx.Tween( 0.175, 0.0, 1.0, function(v) gui.minimap.t = v ).interp( MathEx.lerp );
			},
			"Press Y to scale minimap");
			
			
		keyb.addReleasedHandler( flash.ui.Keyboard.F1, function(_)
			{
				for(h in 0...guiStage().numChildren )
				{
					var c = guiStage().getChildAt( h );
					if ( Std.is( c , flash.text.TextField ))
						c.visible = !c.visible;
				}
			},
			"Press F1 to toggle help");
			
		keyb.addReleasedHandler( flash.ui.Keyboard.NUMBER_0, function(_)
			{
				var next = RoomId.COMMAND_CENTER;
				ship.setCurRoom(next);
				ship.player.changeRoom(null, ship.getGrid(next));
			},
			"Press 0 to go to COMMAND_CENTER");
			
		keyb.addReleasedHandler( flash.ui.Keyboard.NUMBER_1, function(_)
			{
				var next = RoomId.REFECTORY;
				ship.setCurRoom(next);
				ship.player.changeRoom(null, ship.getGrid(next));
			},
			"Press 1 to go to REFECTORY");
			
		keyb.addReleasedHandler( flash.ui.Keyboard.NUMBER_2, function(_)
			{
				var next = RoomId.NEXUS_ROOM;
				ship.setCurRoom(next);
				ship.player.changeRoom(null, ship.getGrid(next));
			},
			"Press 2 to go to NEXUS_ROOM");
			
		keyb.addReleasedHandler( flash.ui.Keyboard.NUMBER_3, function(_)
			{
				var next = RoomId.CORRIDOR_A;
				ship.setCurRoom(next);
				ship.player.changeRoom(null, ship.getGrid(next));
			},
			"Press 3 to go to CORRIDOR_A");
			
		keyb.addReleasedHandler( flash.ui.Keyboard.NUMBER_4, function(_)
		{
			var next = RoomId.CORRIDOR_B;
			ship.setCurRoom(next);
			ship.player.changeRoom(null, ship.getGrid(next));
		},
		"Press 4 to go to CORRIDOR_B");
		
		
		keyb.addReleasedHandler( flash.ui.Keyboard.NUMBER_5, function(_)
		{
			var next = RoomId.CORRIDOR_C;
			ship.setCurRoom(next);
			ship.player.changeRoom(null, ship.getGrid(next));
		},
		"Press 5 to go to CORRIDOR_C");
		
		keyb.addReleasedHandler( flash.ui.Keyboard.NUMBER_6, function(_)
		{
			var next = RoomId.MOTOR_ROOM;
			ship.setCurRoom(next);
			ship.player.changeRoom(null, ship.getGrid(next));
		},
		"Press 6 to go to MOTOR_ROOM");
		
		keyb.addReleasedHandler( flash.ui.Keyboard.NUMBER_7, function(_)
		{
			var next = RoomId.ICARUS;
			ship.setCurRoom(next);
			ship.player.changeRoom(null, ship.getGrid(next));
		},
		"Press 7 to go to MOTOR_ROOM");
			
		keyb.addReleasedHandler( flash.ui.Keyboard.NUMBER_8, function(_)
		{
			var next = RoomId.LABORATORY;
			ship.setCurRoom(next);
			ship.player.changeRoom(null, ship.getGrid(next));
		},
		"Press 8 to go to LAB");
		
		keyb.addReleasedHandler( flash.ui.Keyboard.NUMBER_9, function(_)
		{
			var next = RoomId.SPACESHIP_BAY_B;
			ship.setCurRoom(next);
			ship.player.changeRoom(null, ship.getGrid(next));
		},
		"Press 9 to go to SPACESHIP_BAY_B");
		
		
		keyb.addReleasedHandler( flash.ui.Keyboard.U, function(_)
		{
			//if( pixelisation == null) startPixelisation( 1 );
			//else endPixelisation();
			//if( fx.Mosaic.me == null ) new fx.Mosaic( Main.view, true );
			gui.minimap.doGfx();
		},
		"Press U to cycle Rooms");
	
		keyb.addReleasedHandler( flash.ui.Keyboard.G, function(_)
		{
			if ( mem.red_grid == null)
				mem.red_grid = true;
				
			mem.red_grid = ! mem.red_grid;
			
			for (x in dbgHighlights) x.getDo().visible = mem.red_grid;
			
			save();
		},
		"Press G to show adjust grid");
	
		keyb.addReleasedHandler( flash.ui.Keyboard.X, function(_)
		{
			for ( npc in allHumanNPC )
				npc.changeChar();
		},"Press X to change player face");
	
		keyb.addReleasedHandler( flash.ui.Keyboard.U, function(_)
		{
			Main.ship.player.getUp();
		},"Press U to get up");
	}
	
	static var pixelisation : flash.display.BitmapData = null;
	static var pixObj : flash.display.Bitmap = null;
	
	static var me : HeroId = null;
	
	static var succCall = 0;
	static function simServerData()
	{
		Debug.MSG("simulating data");
		ServerProcess.waitingServer = true;
		succCall++;
		var charsArr = Protocol.heroesList.map(function(h) return h.id).array();
		charsArr.scramble();
		charsArr.remove(ADMIN);
		
		if ( me == null) me = charsArr.pop();
		
		var rooms : Array<RoomId> = [ RoomId.COMMAND_CENTER];
		var myRoom : RoomId = rooms.random();
		
		var rdMap = new haxe.ds.IntMap<_RoomInfos>();
		
		for( r in Level.map.rooms )
		{
			var rinv : Array<ItemId> = Protocol.roomDb( r.id ).objects;
			var st : Flags<RoomStatusId>= Flags.ofInt(0);
			
			//st.set(FIRE);
			rdMap.set( r.id.index(),
				{
					id:r.id, status: st.toInt(),
					inventory: rinv.map( function(id) return Utils.itemDesc( id )  ).array()
				});
		}
		
		var labInv = rdMap.get( RoomId.LABORATORY.index() ).inventory;
		for ( it in labInv)
			it.status |= 1 << BROKEN.index();
		
		labInv.push( Utils.itemDesc( HELP_DRONE ) );
		labInv.push( Utils.itemDesc( CAMERA ) );
			
		var i = 0;
		var peo 
		= charsArr.map(function(h : HeroId ) : ClientChar return
		{ id:h, room:rooms.random(), items:null, serial:Std.string(i++), mutant:false, life:13.1, vanities:new List(), skin:0,diseases:new List() } ).array();
		
		var fl  = new Flags<CrossFlags>();
		var rd : _RoomsClientData =
		{
			me : {id:me,room: RoomId.NEXUS_ROOM, items:null,serial:"125",mutant:false, life:13.1,vanities:new List(),skin:0,diseases:new List()},
			debug:false,
			hunters:
				(succCall <= 3) ?
				[{
					{ id : 0,  state : Move, hp:10 - succCall, type: ShipStatsId.random().index(),charges:Std.random(3) }
				}]
				: []
				,
			patrolShips:[],
			turrets:[],
			npc:[],
			shipMap:rdMap,
			people : peo,
			al : [],
			daedalus: { traveling:false },
			projects: [1<<ICARUS_LARGER_BAY.index()],
			researches: [1 << DRUG_DISPENSER.index(),/*1 << ResearchId.SUPER_CALC.index()*/],
			uiFlags:0,
			flags:fl.toInt(),
			isoHiFi:true,
			add :
				{
					plasmaShield:0,
				},
			showPatrol: [],
		}
		resetServerData( rd );
	}
	
	
	static function update(e)
	{
		//var t0 = haxe.Timer.stamp();
		state = _Looping;
		if( cnx == null)
			tryConnect();
		
		mt.Timer.update();
		time += mt.Timer.deltaT;
		
		#if !master
		view.fpsMeter.text = "FPS " + Std.int((1.0 /  mt.Timer.deltaT)+0.5);
		#end
		
		if( enableInput() )
			input();
			
		logic();
		
		engineUpdate();
		
		fxm.update();
		fx.FXManager.self.update();
		tweenie.update(1);
		
		gui.update();
		view.update();
		
		state = _Idle;
		//var t1 = haxe.Timer.stamp();
		
		//if ( isAdmin() )
		//	trace( Profiler.get().dump() );
		
		//Profiler.get().clean();
	}
	
	static function engineUpdate()
		mt.pix.Element.updateAnims();
	
	static var fire = null;
	
	
	static function startLogic()
	{
		//spr3d = new Spr3D(grid(),FX);
		//spr3d.init(  grid(),Data.mkSetup("FX_PIXEL"));
		////spr3d.setPos(0, 0);
		//spr3d.setPos3( 0.0, 0.5, 0.2 );
		
		//fire = new fx.CellFire(  grid(),new V2DIso( 4, 5 ) );
		if( IsoConst.EDITOR )
		{
			//ship.setPlayer( { id:IAN_SOULTON, room:grid().getRid(), serial:"255", mutant:true, items:new List(), life:13.1, 
			
			ship.setPlayer( { room:RoomId.REFECTORY, serial:"255", mutant:false, items:new List(), life:13, 
			
			//DE : GYHYOM change skin
			//id:DEREK_HOGAN, 
			id:FINOLA_KEEGAN, 
			skin:1,
				
			//TUNE VANITIES HERE
			//vanities : [Gears].list(),
			//vanities : [XmasBall].list(),
			vanities:[].list(),
			//diseases:[DiseaseId.CITROUILLITE.index()].list(),
			diseases:[].list(),
			
			} );
			Main.doVp();
		}
		
		ship.checkUpgrades();
	}
	
	
	static function logic()
	{
		ship.update();
		runners.update();
	}
	
	public static function getGrid(rid)
		return ship.getGrid( rid );
	
	
	static function input()
	{
		mouse.update();
		
		mouseInput();
		keyInput();
		
		keyb.flush();
	}
	
	static function scroll(x:Int, y:Int)
	{
		var vx : Int = view.getScrollPix().x;
		var vy : Int = view.getScrollPix().y;
		
		vx += x;
		vy += y;
		view.scrollPix( vx, vy);
		mem.viewX = vx;
		mem.viewY = vy;
		
		//Debug.MSG("vx = " +vx );
		//Debug.MSG("vy = " + vy);
		
	}
	
	public static inline var scrOfs = 32;
	public static var showTiles = true;
	
	public static var localEnableInput = true;
	public static function enableInput()
	{
		return localEnableInput && (ServerProcess.waitingServer == false) && fx.Mosaic.me == null;
	}
	

	static var dbgHighlights :Array<Entity>= [];
	
	static function keyInput()	{
		
		#if master
			return;
		#end
		
		if( !keyb.isDown( flash.ui.Keyboard.SHIFT ) ){
			if( keyb.isDown( flash.ui.Keyboard.LEFT ) ) 	scroll( 1*scrOfs, 0);
			if( keyb.isDown( flash.ui.Keyboard.RIGHT ) )	scroll( -1*scrOfs, 0);
			if( keyb.isDown( flash.ui.Keyboard.UP ) ) 		scroll( 0, 1*scrOfs);
			if( keyb.isDown( flash.ui.Keyboard.DOWN ) )		scroll( 0, -1 * scrOfs);
		}
		
		if( keyb.isDown( flash.ui.Keyboard.SHIFT ) ){
			//var modSetup = 542dfb;
			var modSetup = Data.debug.tileOfs;
			if(modSetup != null)
			{
				var setup : PixSetup = Data.col2Slice.get( modSetup);
				var slice : PixSlice = Data.slices.get( setup.index );
				
				if( keyb.isDown( flash.ui.Keyboard.LEFT ) ) slice.ofsX--;
				if( keyb.isDown( flash.ui.Keyboard.RIGHT ) ) slice.ofsX++;
				if( keyb.isDown( flash.ui.Keyboard.UP ) )  slice.ofsY--;
				if( keyb.isDown( flash.ui.Keyboard.DOWN ) ) slice.ofsY++;
				
				Debug.MSG("new Offset for " + setup.index +" " + StringTools.hex( modSetup) + " " + slice.ofsX + "," + slice.ofsY );
				#if debug
					if( Main.view.message != null )
						Main.view.message.text = "Ofs:("+slice.ofsX + "," + slice.ofsY + ")";
				#end
				if( dbgHighlights.length == 0 ){
					dbgHighlights = [];
					var deps :List<DepInfos>= grid().dependancies.filter( function(dep:DepInfos) return dep.te.setup.index == setup.index  ).list();
					for(x in deps)
						for(poses in x.data){
							var elem = new Entity( grid(), FX );
							dbgHighlights.push( elem );
							elem.init( grid() , Data.mkSetup( "FX_TILE_HIGHLIGHT_RED" ) );
							elem.setPos( poses.x, poses.y );
							elem.getDo().visible = mem.red_grid;
							elem.engine = UsePostFx;
						}
				}
				else{
					var i = 0;
					var deps :List<DepInfos>= grid().dependancies.filter( function(dep:DepInfos) return dep.te.setup.index == setup.index  ).list();
					for(x in deps)
						for(poses in x.data)
						{
							dbgHighlights[i].setPos( poses.x, poses.y );
							i++;
						}
				}
				grid().reset();
				
				
			}
		}
		
		if( keyb.isDown( flash.ui.Keyboard.CONTROL )
		&&	keyb.wasDown( flash.ui.Keyboard.CONTROL )
		&&	keyb.isReleased( flash.ui.Keyboard.S ))
		{
			save();
		}
		else
		if( keyb.isReleased( flash.ui.Keyboard.S ) && !keyb.wasDown(  flash.ui.Keyboard.CONTROL ))
		{
			mem.scale2 = !mem.scale2;
			updateScale();
		}
		
		
		
		if( keyb.isReleased( flash.ui.Keyboard.L ) )
		{
			doVp();
		}
		
		if( keyb.isReleased( flash.ui.Keyboard.L ) )
		{
			simServerData();
		}
		
		if( keyb.isReleased( flash.ui.Keyboard.N ) )
		{
			var current = grid().getRid();
			var next : RoomId = current.previous( RoomId );
			mem.curRoom = next.index();
			ship.setCurRoom(next);
			ship.player.changeRoom(null, ship.getGrid(next));
		}
		
		if( keyb.isReleased( flash.ui.Keyboard.B ) )
		{
			var current = grid().getRid();
			var next : RoomId = current.next( RoomId );
			ship.setCurRoom(next);
			ship.player.changeRoom(null,  ship.getGrid(next));
		}
	}
	
	public static function setInput( onOff )
	{
		localEnableInput = onOff;
		
		if( onOff )
			for ( g in ship.getRooms())
				g.data.input.enable();
		else
		{
			for ( g in ship.getRooms())
				g.data.input.disable();
			Main.gui.hideTip();
		}
	}
	
	
	public static function changeActiveRoom(r : RoomId, onEnd)
	{
		//Main.stopVp();
		localEnableInput = false;
			
		//mem.curRoom = r.index();
		
		//var m = new fx.Mosaic( Main.view, true );
		var m = new fx.RoomTransition( grid(), ship.getRoom( r ).data, true);
		
		m.onFinish = function()
		{
			ship.setCurRoom( r );
			if ( onEnd != null ) onEnd();
			//Main.doVp(true);
			localEnableInput = true;
		};
		
	}
	
	static var current : Tile = null;
	static var inputSkip :Bool;
	
	public static function setInputSkip(v)
	{
		if(ship.player!=null)
		{
			var pl = ship.player;
			if( pl.pathFx !=null)
				pl.pathFx.getDo().visible = !v;
		}
		
		if (null!=grid())
			grid().input.skip = true;
		
		inputSkip = v;
	}
	
	static function mouseInput()
	{
		if ( inputSkip )
		{
			return;
		}
		
		if( ship.player != null)
			ship.player.pathFx.setPos( -1000, -1000);
		
		var cr = ship.current();
		if( cr != null)
		{
			var grid :Grid = cr.data;
			var cell = V2DIso.pix2GridI( grid.mouseX, grid.mouseY );
			var tile = grid.get( cell.x, cell.y );
			
			if( tile != null )
			{
				if( current != null )
					if( current != tile )
					{
						current.onOut();
						current = null;
					}
				
				if(mouse.onClick)
				{
					grid.onClick( tile );
					tile.onClick();
				}
				else
				{
					if ( ship.player != null)
					{
						ship.player.pathFx.setPos( cell.x, cell.y );
					}
					tile.onOver();
				}
				
				current = tile;
			}
			else
				if( current != null )
				{
					current.onOut();
					current = null;
				}
		}
		
	}
	
	// save block
	public static var mem : Save = null;
	static inline var mem_name = "mush_iso_black";
	static inline var FORCE_RESET = false;
	
	public static function save()
	{
		if( !IsoConst.EDITOR )
			return;
		
		var so = flash.net.SharedObject.getLocal("mem_name");
		so.data.mem = mem;
		so.flush();
		
		Debug.MSG("Saved.");
	}
	
	static function load()
	{
		if( !IsoConst.EDITOR )
		{
			resetMem();
			return;
		}
		
		var so = flash.net.SharedObject.getLocal("mem_name");
		
		if(so.data.mem == null || FORCE_RESET )
		{
			resetMem();
			save();
		}
		else
			mem = so.data.mem;
		
		if ( mem != null)
			if ( mem.red_grid == null) mem.red_grid = true;
	}
	
	
	static function resetMem()
	{
		var sv : Save = { viewX:0, viewY:0, scale2:false, curRoom : COMMAND_CENTER.index(), red_grid:true};
		mem = sv;
	}
	
	public static function guiStage()
	{
		return flash.Lib.current;
	}
	
	public static function grid() : Grid
	{
		return ship.current().data;
	}
	
	public static function focusPlayer( insta = false)
	{
		var vX = Lib.current.stage.stageWidth;
		var vY = Lib.current.stage.stageHeight;
		
		var tx = vX * 0.5 - ship.player.getDo().x;
		var ty = vY * 0.5 - ship.player.getDo().y;
		if(!insta) view.tweenPix( tx, ty );
		else view.scrollPix( tx, ty);
	}
	
	public static function focusPosition( x:Float,y:Float,insta = false)
	{
		var vX = Lib.current.stage.stageWidth;
		var vY = Lib.current.stage.stageHeight;
		
		var tx = vX * 0.5 - x;
		var ty = vY * 0.5 - y;
		if(!insta) view.tweenPix( tx, ty );
		else view.scrollPix( tx, ty);
	}
	
	public static function getVpCenter( gr = null) : V2D
	{
		var r = (gr==null) ? grid() : gr;
		var m = r.getCenter();
		
		var vX = Lib.current.stage.stageWidth;
		var vY = Lib.current.stage.stageHeight;
		
		var midX : Float = ((m.max.x + m.min.x ) * 0.5);
		var midY : Float = ((m.max.y + m.min.y ) * 0.5);
		
		return new V2D( -midX + vX*0.5,
						-midY + vY*0.5);
	}
	
	//pos is in world space in pixels
	public static function getVpCentersPos( gr : Grid = null , pos : V2D )
	{
		var vX = Lib.current.stage.stageWidth;
		var vY = Lib.current.stage.stageHeight;
		
		return new V2D( - pos.x + vX*0.5,
						- pos.y + vY*0.5);
	}
	
	public static function stopVp()
	{
		view.stopScroll();
	}
	
	public static function centerVp(insta = false)
	{
		var t = getVpCenter();
		
		if( insta )
			view.scrollPix( t.x, t.y);
		else
			view.tweenPix( t.x, t.y);
	}
	
	public static function serverDataGetRoom( rid : RoomId) : _RoomInfos
	{
		if( actServerData == null ) return null;
		return actServerData.shipMap.get(rid.index());
	}
	
	public static function serverDataGetItemByDep(  rid : RoomId, dep:DepInfos ) : _ItemDesc
	{
		return serverDataGetItem( rid, dep.iid, dep.key);
	}
	
	public static function serverDataGetItem(  rid : RoomId, iid: ItemId, ?key : String ) : _ItemDesc
	{
		if ( actServerData == null ) return null;
		
		var rinf  = actServerData.shipMap.get(rid.index());
		
		for ( i  in rinf.inventory)
			if ( i.id == iid )
			{
				if ( key != null && i.customInfos.locate( function(ci) return switch(ci) { default:null; case _Key(k):k; }) != key )
					continue;
					
				return i;
			}
			
		return null;
	}
	
	public static function serverDataIsBroken( rid : RoomId, iid: ItemId, ?key : String ) : Bool
	{
		if ( actServerData == null ) return false;
		
		var rinf  = actServerData.shipMap.get(rid.index());
		
		for ( i  in rinf.inventory)
			if ( i.id == iid )
			{
				if ( key != null && i.customInfos.locate( function(ci) return switch(ci) { default:null; case _Key(k):k; }) != key )
					continue;
					
				return Flags.test( i.status, BROKEN);
			}
		
		return false;
	}
	
	public static function serverDataGetActions() : Array<FlashMoveData>
	{
		if( actServerData == null ) return null;
		return actServerData.al;
	}
	
	public static function serverHeroData( hid :HeroId )
	{
		if ( actServerData == null )
		{
			if ( incServerData != null)
			{
				for( x in incServerData.people )
					if ( x.id == hid )
						return x;
			}
			else
				return null;
		}
		else
		{
			for( x in actServerData.people )
				if ( x.id == hid )
					return x;
		}
		
		return null;
	}
	
	public static function serverDataGetDoorTo( rid : RoomId, to : RoomId ) : _ItemDesc
	{
		//Debug.MSG( rid + " to " + to );
		if( actServerData == null )
		{
			//Debug.MSG("no server data ");
			return null;
		}
		
		var rm = serverDataGetRoom(rid);
		if( rm == null)
		{
			Debug.MSG("no such room");
			return null;
		}
		Debug.ASSERT( rm.id == rid);
		
		#if debug
		//if(  rm.inventory.length == 0) Debug.MSG("inventory is empty...");
		#end

		for( i in rm.inventory )
		{
			if(i.id != DOOR ) continue;
			Debug.ASSERT( i.customInfos != null );
			
			if( i.customInfos != null )
				for( info in i.customInfos)
				{
					switch(info)
					{
						case Door( index ):
							{
								var door : DoorShipData = Level.map.doors[index];
								
								var v = ( 	to == door.link[0].id
									|| 		to == door.link[1].id);
								if( v ) return i;
							}
						default:
					}
				}
		}
		
		return null;
	}
	
	public static function isHiFi()
	{
		if ( actServerData == null ) 
			return true;
		else 
			return actServerData.isoHiFi;
	}
}

