package ui;

import flash.events.MouseEvent;
/**
 * ...
 * @author de
 */
import flash.display.MovieClip;
import flash.events.MouseEvent;

using Ex;
import Protocol;

typedef MinimapPpl = { ppl:HeroId, rid:RoomId, mc:flash.display.Shape, ?hint:{x:Int,y:Int} };

@:publicFields
class SelfishSprite extends flash.display.Sprite
{
	var over_proc : Dynamic->Void;
	var out_proc : Dynamic->Void;
	
	public function new()
	{
		super();
	}
}

class Minimap
{
	public var preMc : MovieClip;
	public var mc : MovieClip;
	public var bg : MovieClip;
	
	public static var SQ = 1;
	
	public static var SAFE_COLOR = 0x112e42;
	public static var WALL_COLOR = 0x257d9f;
	public static var FIRE_COLOR = 0xc40000;
	public static var EQ_BROKEN_COLOR = 0xff9c00;
	
	public static var peoples : EnumHash< HeroId,MinimapPpl> =  new EnumHash(HeroId);
	
	public var maxH : Float;
	public var dirty : Bool;
	
	public var roomSprite : EnumHash<RoomId,SelfishSprite>;
	public var t : Float;
	
	public var roomLabel : flash.text.TextField;
	var preMcT : Float;
	
	
	
	public function new()
	{
		mc = new MovieClip();
		mc.mouseEnabled = false;
		
		mc.x = 10;
		mc.y = Window.H() - 10 - maxH - 50;

		maxH = 0;
		dirty = true;
		
		roomSprite = new EnumHash( RoomId );
		t = 0;
		
		roomLabel = As3Tools.tfield(0xFFFFFF,10,"square" );
		roomLabel.antiAliasType = flash.text.AntiAliasType.ADVANCED;
		roomLabel.gridFitType = flash.text.GridFitType.SUBPIXEL;
		roomLabel.text = "";
		roomLabel.multiline = true; 
		roomLabel.width = 400;
		roomLabel.height = 100;
		
		mc.transform.matrix = baseTrans(0);
		
		preMc = new MovieClip();
		var gfx = preMc.graphics;
		
		var isHiFi = Main.isHiFi();
		gfx.beginFill(0x070724, Main.isHiFi() ? 1 : 0.92);
		
		var t = 12;
		
		gfx.lineTo( 9*t, 0);
		gfx.lineTo( 10*t, t);
		gfx.lineTo( 10* t, 20 * t);
		gfx.lineTo( 0, 20*t);
		gfx.endFill();
		
		preMcT = 1;
		cornerInteract();
	}
	
	function mover(e)
	{
		preMc.filters = [ new flash.filters.GlowFilter( 0xFFFFFF) ];
	}
			
	function mout(e)
	{
		preMc.filters = [  ];
	}
		
	function mdown(e)
	{
		new fx.Tween(0.3, 1.0, 2.0, function(v) preMc.scaleX = v ).interp( MathEx.lerp );
		new fx.Tween(0.3, 1.0, 2.0, function(v) preMcT = v ).interp( MathEx.lerp );
		new fx.Tween(0.3, 0.2, 1, function(v) t = v).interp( MathEx.lerp )
		.end( function(_)
		{
			preMc.filters = [  ];
			mc.mouseEnabled = false;
			preMc.mouseEnabled = false;
			mainInteract();
		});
		
		Main.setInput( false);
	}
			
	public function cornerInteract()
	{
		preMc.mouseEnabled = true;
		preMc.useHandCursor = true;
		preMc.buttonMode = true;
		
		mc.mouseEnabled = false;
		mc.useHandCursor = false;
		mc.buttonMode = false;
		mc.mouseChildren = false;
			
		preMc.addEventListener( flash.events.MouseEvent.MOUSE_OVER, mover);
		preMc.addEventListener( flash.events.MouseEvent.MOUSE_OUT, mout);
		preMc.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, mdown);
		mc.removeEventListener( flash.events.MouseEvent.MOUSE_DOWN, mapdown);
		
		
	}
	
	function mapdown(e)
	{
		new fx.Tween(0.3, 2.0, 1.0, function(v) preMc.scaleX = v ).interp( MathEx.lerp );
		new fx.Tween(0.3, 2.0, 1.0, function(v) preMcT = v ).interp( MathEx.lerp );
		
		new fx.Tween(0.3, 1.0, 0.0, function(v) t = v).interp( MathEx.lerp )
		.end( function(_)
		{
			mc.mouseEnabled = false;
			preMc.mouseEnabled = false;
			cornerInteract();
			Main.setInput( true);
		});
	}
	
	var isolateScreen:MovieClip;
	
	public function mainInteract()
	{
		preMc.useHandCursor = false;
		preMc.buttonMode = false;
		preMc.mouseEnabled = false;
		
		mc.mouseEnabled = true;
		mc.useHandCursor = true;
		mc.buttonMode = true;
		mc.mouseChildren = true;
		
		preMc.removeEventListener( flash.events.MouseEvent.MOUSE_OVER, mover);
		preMc.removeEventListener( flash.events.MouseEvent.MOUSE_OUT, mout);
		preMc.removeEventListener( flash.events.MouseEvent.MOUSE_DOWN, mdown);
		
		mc.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, mapdown);
		
		isolateScreen = new flash.display.MovieClip();
		isolateScreen.graphics.beginFill(0x000000);
		isolateScreen.graphics.drawRect( 0, 0, Window.W(), Window.H());
		isolateScreen.graphics.endFill();
		isolateScreen.alpha = 0;
		
		var ev = flash.events.MouseEvent.MOUSE_DOWN;
		var l = null;
		l = function( e )
		{
			if( isolateScreen!=null){
				if( isolateScreen.parent!=null)
					isolateScreen.parent.removeChild(isolateScreen);
				isolateScreen.removeEventListener( ev, l );
				mapdown(null);
			}
			isolateScreen = null;
		}
		//Main.guiStage().useHandCursor = true;
		isolateScreen.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, l);
		
		var i = Main.guiStage().getChildIndex( preMc );
		Main.guiStage().addChildAt(isolateScreen,i-1);
		isolateScreen.useHandCursor = true;
		isolateScreen.mouseChildren = true;
	}
	
	public function baseTrans( t : Float)
	{
		var matrix = new flash.geom.Matrix();
		
		matrix.identity();
		
		var cx = mc.width *0.5;
		var cy = mc.height *0.5;
		
		matrix.translate(-cx, -cy);
		matrix.scale(1.0+t, 1.0+t);
		matrix.translate(cx,cy);
		matrix.rotate( Math.PI / 6 );
		
		matrix.translate(	MathEx.lerp( 8, 55,t ),
							MathEx.lerp( 	Window.H() - 10 - maxH - 60,
											Window.H() - 10 - maxH - 95,
											t));
		
		return matrix;
	}
	
	public function doGfx()
	{
		//Profiler.get().begin("minimap doGfx");
		if (bg == null)
		{
			bg = new MovieClip();
			bg.cacheAsBitmap = true;
			mc.addChild(bg);
		}
		
		bg.graphics.clear();
		
		for ( s in roomSprite )
		{
			s.removeEventListener( flash.events.MouseEvent.MOUSE_OVER, s.over_proc );
			s.removeEventListener( flash.events.MouseEvent.MOUSE_OUT, s.out_proc );
			s.parent.removeChild( s );
		}
		
		var map : SpaceShipData  = data.Level.map;
		for(x in map.rooms )
		{
			if( [OUTER_SPACE,PATROL_SHIP,PLANET,LIMBO].has( Protocol.roomDb( x.id ).type )) continue;
			
			var cl = SAFE_COLOR;
			var data = Main.serverDataGetRoom( x.id );
			if ( data != null && Flags.test(data.status, FIRE ) )
				cl = FIRE_COLOR;
			
			var tl = [1000, 1000];
			
			var spr = new SelfishSprite();
			
			roomSprite.set(  x.id,spr );
			
			spr.graphics.lineStyle();
			spr.graphics.beginFill( cl,0.75 );
			for( p in x.pos)
			{
				if( p.x == 0 && p.y == 0 ) continue;
				
				var px = p.x * SQ;
				var py = p.y * SQ;
				if ( py + SQ > maxH) maxH = py + SQ;
				
				//calc bb for equipment replacement
				tl[0] = MathEx.mini(p.x, tl[0]);
				tl[1] = MathEx.mini(p.y, tl[1]);
				
				spr.graphics.drawRect(px, py, SQ, SQ );
				
				spr.over_proc =  function(d)
				{
					roomLabel.text = Protocol.roomDb(x.id).assert("windy room").name;
					
					var n = 0;
					if ( Main.actServerData != null )
						if ( Main.actServerDataExt.projects.has( WHOS_WHO) )
							for ( p in peoples )
								if ( p.rid == x.id )
								{
									roomLabel.text += " " + Protocol.heroesIdList[p.ppl.index()].initials;
									n++;
									if ( n == 6 ) roomLabel.text += "\n";
								}
					
					var g =  new flash.geom.ColorTransform();
					g.blueOffset= 50;
					g.redOffset= 50;
					g.greenOffset = 50;
					g.blueMultiplier = 2.0;
					g.greenMultiplier = 2.0;
					spr.transform.colorTransform = g;
				};
				
				spr.out_proc =  function(d)
				{
					roomLabel.text = "";
					spr.transform.colorTransform = new flash.geom.ColorTransform();
				};
				
				spr.addEventListener(MouseEvent.MOUSE_OVER, spr.over_proc);
				spr.addEventListener(MouseEvent.MOUSE_OUT, spr.out_proc);
				
			}
			spr.graphics.endFill();
			bg.addChild( spr );
			
		FilterEx.outline( mc , WALL_COLOR,2,0.75,50);
		
		for(d in map.doors)
		{
			var SAFE_DOOR_COLOR = 0x12d7e1;
			var col = SAFE_DOOR_COLOR;
			var data = Main.serverDataGetDoorTo( d.link[0].id, d.link[1].id );
			
			if (data != null &&  Flags.test(data.status, BROKEN ))
				col = 0xf8de05;
			
			bg.graphics.lineStyle();
			bg.graphics.beginFill( col );
			
			for( p in d.poses )
				bg.graphics.drawRect(p.x, p.y, 1, 1 );
				
			bg.graphics.endFill();
		}
		
			var s = 0;
			for(x in map.rooms ){
				for ( d in Main.ship.getGrid(x.id).dependancies ){
					switch(d.gameData){
						case Equipment( iid ):{
							if ( Main.serverDataIsBroken( x.id, iid, d.key ) )
							{
								bg.graphics.lineStyle(1.0, EQ_BROKEN_COLOR);
								bg.graphics.beginFill( EQ_BROKEN_COLOR );
								
								var e = [0., 0.];
								for ( p in d.data) {
									s++;
									e[0] = p.x;
									e[1] = p.y;
									if ((s & 1) == 0)
										continue;
									
									var f = extractAndRematchPc( x.id, Math.round(e[0]), Math.round(e[1]));
									bg.graphics.drawRect(f.x-1,f.y-1, 3, 3 );
								}
								bg.graphics.endFill();
								
								//trace("iid " + iid + " is broken");
							}
							else {
								//trace("iid " + iid + " is not broken");
							}
						}
						default:
					}
				}
			}
		}
		
		if (Main.ship.testCond( CC_ProjectUnlocked( PLASMA_SHIELD) ))
		{
			var v = ( Main.actServerData == null)
			//? 0.8
			? 0
			: Main.actServerData.add.plasmaShield;
			
			var col = 0x00d5ff;
			if ( v <= 0.01)
			{
				col = 0xff1800;
				v = 0.12;
			}
			else
				v = MathEx.lerp( 0.12, 1.0, v);
				
			var g = new flash.filters.GlowFilter( col, 1.0, 20*v, 20*v );
			g.strength = 0.8;			
			mc.filters = mc.filters.concat( [g] );
		}
		
		//
		for ( p in peoples)
			if ( Main.ship.player != null && p.ppl != Main.ship.player.hid )
				mkPeopleSprite( p.ppl, p.rid, p.hint, false);
		
		//fetchPeoples();
		//trace("a");
		//Profiler.get().end("minimap doGfx");
		dirty = false;
	}
	
	
	inline function random( rid )
	{
		var rm = data.Level.map.rooms.find( function(r) return r.id == rid );
		return ( rm.pos != null && rm.pos.length > 0 )
		? 	rm.pos.random().clone()
		:	null;
	}
	
	inline function roomPoses(rid:RoomId)
	{
		return data.Level.map.roomsById.get( rid.index() ).pos;
	}
	
	//take a point in iso client space and render it in minimapSpace
	function extractAndRematchPc( rid , x, y) : V2I
	{
		//Profiler.get().begin("EARPC");
		
		//Profiler.get().begin("EARPC grpos");
		var grid = Main.ship.getGrid( rid );
		var rmP = (grid.allPoses == null) ? (grid.allPoses=grid.tiles().map( function(t) return t.getGridPos() ).array()) : grid.allPoses;
		//Profiler.get().end("EARPC grpos");

		if( grid.tgtBb==null){
			grid.bb = V2I.calcBBox( rmP );
			
			//Profiler.get().begin("EARPC roomPoses");
			grid.poses = roomPoses(rid);
			//Profiler.get().end("EARPC roomPoses");
			grid.tgtBb = V2I.calcBBox( grid.poses );
		}
		var tgtBb = grid.tgtBb;
		var bb = grid.bb;
		var poses = grid.poses;
		
		var pc : V2D = new V2D( (x - bb[0].x) / (bb[1].x  - bb[0].x),
								(y - bb[0].y) / (bb[1].y  - bb[0].y));
		var estimX : Int = Math.round( pc.x * (tgtBb[1].x -  tgtBb[0].x) + tgtBb[0].x);
		var estimY : Int = Math.round( pc.y * (tgtBb[1].y -  tgtBb[0].y) + tgtBb[0].y);
		
		var paskEstim = new V2I( estimX, estimY );
		
		//Profiler.get().begin("EARPC fold");
		
		var tryOne = { pos:poses[0], len:V2I.dist2( poses[0], paskEstim ) };
		
		for(elem in poses){
			var l = Math.round(V2I.dist2( elem, paskEstim ));
			if ( l < tryOne.len ){
				tryOne.pos = elem;
				tryOne.len = l;
			}
		}
		
		//Profiler.get().end("EARPC fold");
		
		//Profiler.get().end("EARPC");
		return tryOne.pos;
	}
	
	public function cleanPeople( hid )
	{
		var entry = peoples.get( hid );
		mc.removeChild(entry.mc );
		peoples.remove( hid );
	}
	
	public function mkPeopleSprite( hid,rid, ?hint:{ x:Int,y:Int },isMain = false )
	{
		var entry = peoples.get( hid );
		
		var old = entry.mc;
		var pl = Main.ship.player;
		var im = isMain || (pl != null && pl.getChar() == hid );
		var col = im ?  0xFFFF00 : 0xff8888;
		
		if ( Main.ship.testCond( CC_ProjectUnlocked( WHOS_WHO)))
			col = Protocol.heroesIdList[hid.index()].col;
			
		var sz = im?3:2;
		if ( old != null)
		{
			var spr = old;
			spr.graphics.clear();
			spr.graphics.beginFill( col );
			spr.graphics.drawRect( 0, 0, sz, sz );
			spr.graphics.endFill();
		}
		else
		{
			var spr = new flash.display.Shape();
			
			spr.graphics.beginFill( col );
			spr.graphics.drawRect( 0, 0, sz, sz );
			spr.graphics.endFill();
			
			mc.addChild( spr );
			entry.mc = spr;
		}
		
		if ( isMain ){
			entry.mc.filters = [];
		}
		
		entry.mc.toFront();
	}
	
	public function setPeopleRoom(hid,rid, ?hint:{ x:Int,y:Int }, isMain = false)
	{
		//Profiler.get().begin("minimap setPeopleRoom");
		var entry = peoples.get( hid );
		if( entry == null )
		{
			peoples.set( hid, entry = { ppl:hid, rid:null, mc:null, hint:Reflect.copy(hint) } );
			mkPeopleSprite( hid,rid,hint,isMain);
			mc.visible = Protocol.roomDb( rid ).type != PATROL_SHIP;
		}
		else
			entry.mc.toFront();
		
		if( hint != null)	entry.hint = Reflect.copy( hint );
		else				entry.hint = null;
		
		if( entry.rid != rid )
		{
			entry.rid = rid;
			
			var rdPos = random( rid );
			if ( rdPos == null) return;
			
			if ( hint != null)
			{
				//pixel is in pixel map space;
				var pc = extractAndRematchPc(rid, hint.x, hint.y);
				
				rdPos.x = pc.x;
				rdPos.y = pc.y;
			}
			
			entry.mc.x = rdPos.x * SQ + Dice.roll( 0 , SQ-1 );
			entry.mc.y = rdPos.y * SQ + Dice.roll( 0 , SQ-1 );
			
			entry.mc.visible = ![PATROL_SHIP, OUTER_SPACE,PLANET].has( Protocol.roomDb( rid ).type );
		}
		else
		{
			
			if ( hint != null)
			{
				//pixel is in pixel map space;
				var pc = extractAndRematchPc(rid, hint.x, hint.y);
				
				//let s rematch it with actual geometry
				entry.mc.x = pc.x * SQ + Dice.roll( 0 , SQ-1 );
				entry.mc.y = pc.y * SQ + Dice.roll( 0 , SQ-1 );
			}
		}
		//Profiler.get().end("minimap setPeopleRoom");
		
	}

	public function update()
	{
		if (dirty )
			doGfx();
			
		mc.transform.matrix = baseTrans(t);
		
		if ( roomLabel.parent == null )
			Main.guiStage().addChild( roomLabel );
		
		roomLabel.x = 10;
		roomLabel.y = Window.H() - 24;
		roomLabel.visible = mc.visible;
		
		/*
		if ( 	Main.guiStage().mouseY > Window.H() - 180
		&&		Main.guiStage().mouseX < Window.W() * 0.5
		&&		!Select.hasSelection()
		)
		{
			t += 0.1;
		}
		else
			t -= 0.2;
			*/
			
		t = MathEx.clamp( t, 0, 1 );
		
		preMc.y  = Window.H() - 100 * preMcT;
		
		if ( Main.ship.player != null){
			var p = peoples.get( Main.ship.player.hid );
			if(p!=null&&p.mc!=null)
				p.mc.alpha = 0.5 + 0.5 * Std.int( Math.sin( haxe.Timer.stamp() * 6  ) + 0.5);
		}
	}
	
	
}