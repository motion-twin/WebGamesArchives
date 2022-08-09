import Common;
import Protocol;
import ExploreProtocol;
import Mode;

@:bitmap("gfx/texture.png") class TilesBmp extends flash.display.BitmapData {}

class Main {
	
	static var SOFTWARE = false;
	static var START = Debug.getStartInfos();
	static var PLANET : PlanetInfos = {
		id : null,
		biome : START.biome,
		size : START.size,
		seed : START.seed,
		waterLevel : 0,
		waterFlood : 0,
		waterTotal : 0,
	};
	
	static var mode : Mode;
	static var engine : h3d.Engine;

	static function gameInfos() : GameInfos {
		var maxSlots = 10;
		var inv : InventoryInfos = {
			maxWeight : 64,
			t : [],
			charges : [],
		};
		//for( b in [BShipDoor, BShipHull, BShipGlass, BShipWire, BShipComputer, BShipEntry, BShipGlass2, BShipEngine, BShipPlate, BCrafter, BCrafterComputer] )
		//for( b in [BWood, BLamp, BBlueCrystalLight, BMoonLight] )
		//0xD2C8E6,0x877da2,0x4D4561
		for( b in [BLamp, BFreezer, BMinIron, BMinAluminium, BIron, BHealPlant, BCascadeSource, BBonusMedium, BChest] )
			inv.t.push( { k : Type.enumIndex(b), n : 50 } );
		for( c in [CYellow,CBlue,CPink,CBonus] )
			inv.charges.push( { c : Type.enumIndex(c), n : 30 } );
		while( inv.t.length < maxSlots )
			inv.t.push(null);
		return {
			planet : PLANET,
			inventory : inv,
			lastPos : null,
			debug : true,
			userId : null,
			userName : "Anonymous",
			offline : false,
			ship : { x : 14, y : 12, z : 34, data : Const.DEFAULT_SHIP },
			crafts : null,
		};
	}
	
	static function randPlanet() : PlanetInfos {
		return {
			id : null,
			biome : START.biome,
			size : 2,//1 + Std.random(4),
			seed : Std.random(0x1000000) ^ Std.random(0x1000000) ^ Std.random(0x1000000),
			waterLevel : 0,
			waterFlood : 0,
			waterTotal : 0,
		};
	}
	
	static function getParam( v : String ) : String {
		return Reflect.field(flash.Lib.current.stage.loaderInfo.parameters, v);
	}
	
	static function main() {
		mt.Timer.maxDeltaTime = 10;
		mt.Timer.tmod_factor = 0.98;
		haxe.Log.setColor(0xFF0000);
		
		if( !flash.system.Capabilities.isDebugger )
			flash.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(flash.events.UncaughtErrorEvent.UNCAUGHT_ERROR, function(e:flash.events.UncaughtErrorEvent) {
				tools.Codec.displayError(e.error);
				e.preventDefault();
			});
		
		var data = new flash.utils.ByteArray();
		data.length = 1024;
		try flash.Memory.select(data) catch( e : Dynamic ) {
			haxe.Log.trace("Flash Player 11.2 Beta can't run this game : please use 11.1");
			return;
		}
		
		var k : Dynamic = try tools.Codec.getData("data") catch( e : Dynamic ) { tools.Codec.displayError(e); return; };
		if( k != 654 ) {
			START.mode = k;
			Data.TEXTURE = new TilesBmp(0, 0);
		} else
			Mode.LOCAL = true;

		var domain = flash.Lib.current.loaderInfo.url.split("/")[2];
		if( domain.substr(0,5) == "data." )
			flash.system.Security.allowDomain(domain.substr(5));
		
		if( Data.TEXTURE == null ) {
			var l = new flash.display.Loader();
			l.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, function(_) init(l.content));
			l.load(new flash.net.URLRequest("gfx/texture.png"),new flash.system.LoaderContext(true,new flash.system.ApplicationDomain()));
		}
		
		engine = new h3d.Engine(0, 0, !SOFTWARE);
		engine.backgroundColor = 0x130200;
		engine.onReady = callback(init, null);
		engine.init();
	}
	
	static function init(content:Dynamic) {

		if( content != null ) {
			var bmp = flash.Lib.as(content, flash.display.Bitmap);
			Data.TEXTURE = bmp.bitmapData;
		}
		
		if( Data.TEXTURE == null || !engine.isReady() )
			return;
			
		var stage = flash.Lib.current.stage;
		var root = new flash.display.MovieClip();
		flash.Lib.current.addChild(root);
	
		switch( START.mode ) {
		case MGame(inf):
			if( inf == null ) inf = gameInfos();
			var api = if( inf.offline )
				new net.Offline(inf.planet)
			else if( inf.planet.id == null )
				new net.Local(inf.planet)
			else {
				var url = getParam("url");
				var sid = getParam("sid");
				var sender : net.Sender;
				if( sid != null && sid != "" ) {
					var visible = !(inf.lastPos != null && inf.lastPos.flags.has(CameraMode));
					sender = new net.ToraSender(url, inf.planet.id, visible);
				} else
					sender = new net.HttpSender(url);
				new net.Server(sender,inf.planet);
			}
			mode = new Game(root, engine, api, inf);
		case MEditShip(inf):
			if( inf == null )
				inf = {
					inventory : gameInfos().inventory,
					debug : true,
					size : { x : 17, y : 17, z : 12 },
					ship : Const.DEFAULT_SHIP,
				};
			var api = new net.EditShip(new net.HttpSender(getParam("url")),inf);
			mode = new EditShip(root, engine, api, inf);
		case MExplore(inf):
			var explore = new exp.Manager(root, inf, false);
		}
		mt.flash.Key.init();
		mt.flash.Key.enableJSKeys("client");
		tools.Codec.addObfuFields(ClientAction);
		tools.Codec.addObfuFields(ExploreAction);
	}
	
}