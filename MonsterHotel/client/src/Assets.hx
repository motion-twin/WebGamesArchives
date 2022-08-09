
import mt.deepnight.Color;
import mt.deepnight.slb.BLib;
import mt.deepnight.slb.*;
import mt.deepnight.slb.assets.TexturePacker;
import mt.flash.Sfx;
import com.Protocol;
import com.GameData;

import h2d.Tile;
import h2d.Font;
import hxd.res.FontBuilder;
import mt.MLib;

class Assets {
	public static var READY = false;

	public static var charset		: String;
	public static var bg			: BLib;
	static var directTextures		: Map<String, h2d.Tile> = new Map();
	public static var tiles			: BLib;
	public static var tiles1		: BLib;
	public static var rooms			: BLib;
	public static var monsters0		: BLib;
	public static var monsters1		: BLib;
	public static var monsters2		: BLib;
	public static var custo0		: BLib;
	public static var preloader		: BLib;
	public static var intro			: BLib;
	public static var fontTiny		: h2d.Font;
	public static var fontNormal	: h2d.Font;
	public static var fontHuge		: h2d.Font;
	public static var fontRoof		: h2d.Font;

	#if cpp
	public static var SBANK			= mt.flash.Sfx.importFromAssets("assets/sfx_ogg");
	#else
	public static var SBANK			= mt.flash.Sfx.importFromAssets("assets/sfx_low");
	#end

	public static var SCALE			= 1;

	public static function minimalInit() {
		charset =
			hxd.Charset.DEFAULT_CHARS +
			"€¢£¥₩₪฿₫₴₹";

		var f = openfl.Assets.getFont("small");
		if ( f == null ) throw "unknown font!";

		hxd.Profiler.begin("Assets.font.tiny");
		fontTiny = hxd.res.FontBuilder.getFont(f.fontName, 26, { antiAliasing:false, chars:charset } );
		hxd.Profiler.end("Assets.font.tiny");

		hxd.Profiler.begin("Assets.preloader");
		preloader = TexturePacker.importXmlMt("assets/preloader.xml");
		hxd.Profiler.end("Assets.preloader");

		#if (mBase && (android || ios))
		var mem = mtnative.device.Device.systemMemory();
		if( mem != null && mem < 512 )
			mt.Assets.USE_HALF_SIZE = true;
		if( mem != null && mem < 1536 && mt.Metrics.h() <= 800 )
			mt.Assets.USE_HALF_SIZE = true;
		#end

		if( mt.Assets.USE_HALF_SIZE )
			SCALE = 2;
	}

	public static function init() {
		if( READY )
			return;

		hxd.Profiler.begin("Assets.font.normal");
		var f = openfl.Assets.getFont("large");
		if( f==null ) throw "unknown font!";
		fontNormal = hxd.res.FontBuilder.getFont(f.fontName, 36, { antiAliasing:false, chars:charset } );
		hxd.Profiler.end("Assets.font.normal");
	}


	static var initStep = 0;
	static var doneStep = 0;

	static var workers : Array<mt.Worker>;

	static var wi = 0;
	static function getWorker(){
		return workers[ (wi++)%workers.length ];
	}

	//static var start : Float;
	public static function progressiveInit() {
		if( READY )
			return 1.0;

		hxd.Profiler.begin("Assets.progressiveInit");

		if( workers != null )
			for( w in workers )
				w.checkDone();

		var next = true;
		switch( initStep ) {
			case 0 :
				//start = haxe.Timer.stamp();
				workers = [];
				for( i in 0...2 )
					workers.push( new mt.Worker() );

				initDirectTexture("paris", "assets/directTextures/paris.png");

			case 1 :
				initDirectTexture("city", "assets/directTextures/introCity.png");

			case 2 :
				getWorker().enqueue(new mt.Worker.WorkerTask(function(){
					for(k in Reflect.fields(SBANK))
						Reflect.field(SBANK,k)();
					new SoundMan();
					doneStep++;
				}));

			case 3 :
				if( SCALE==1 )
					TexturePacker.importXmlMtDeferred("assets/bgAssets.hd.xml",getWorker(),function(t){ bg = t; doneStep++; });
				else
					TexturePacker.importXmlMtDeferred("assets/bgAssets.low.xml",getWorker(),function(t){ bg = t; doneStep++; });

			case 4 :
				if( SCALE==1 )
					TexturePacker.importXmlMtDeferred("assets/monsters0.hd.xml",getWorker(),function(t){ monsters0 = t; doneStep++; });
				else
					TexturePacker.importXmlMtDeferred("assets/monsters0.low.xml",getWorker(),function(t){ monsters0 = t; doneStep++; });

			case 5 :
				if( SCALE==1 )
					TexturePacker.importXmlMtDeferred("assets/monsters1.hd.xml",getWorker(),function(t){ monsters1 = t; doneStep++; });
				else
					TexturePacker.importXmlMtDeferred("assets/monsters1.low.xml",getWorker(),function(t){ monsters1 = t; doneStep++; });

			case 6 :
				if( SCALE==1 )
					TexturePacker.importXmlMtDeferred("assets/monsters2.hd.xml",getWorker(),function(t){ monsters2 = t; doneStep++; });
				else
					TexturePacker.importXmlMtDeferred("assets/monsters2.low.xml",getWorker(),function(t){ monsters2 = t; doneStep++; });

			case 7:
				var f = openfl.Assets.getFont("large");
				if( f==null ) throw "unknown font!";
				fontHuge = hxd.res.FontBuilder.getFont(f.fontName, 72, { antiAliasing:false, chars:charset, noRetain: true } );
				doneStep++;

			case 8 : TexturePacker.importXmlMtDeferred("assets/tilesheet0.xml",getWorker(),function(t){ tiles = t; doneStep++; });
			case 9 : TexturePacker.importXmlMtDeferred("assets/tilesheet1.xml",getWorker(),function(t){ tiles1 = t; doneStep++; });

			case 10:
				TexturePacker.importXmlMtDeferred("assets/rooms0.xml",getWorker(),function(t){ rooms =  t; doneStep++; });

			case 11:
				if( SCALE==1 )
					TexturePacker.importXmlMtDeferred("assets/custo0.hd.xml",getWorker(),function(t){ custo0 =  t; doneStep++; });
				else
					TexturePacker.importXmlMtDeferred("assets/custo0.low.xml",getWorker(),function(t){ custo0 =  t; doneStep++; });

			case 12:
				TexturePacker.importXmlMtDeferred("assets/intro.xml",getWorker(),function(t){ intro =  t; doneStep++; });

			case 13:
				var f = openfl.Assets.getFont("roof");
				if( f==null ) throw "unknown font!";
				fontRoof = hxd.res.FontBuilder.getFont(f.fontName, 72, { antiAliasing:false, chars:charset, noRetain: true } );
				doneStep++;


			default :
				next = false;
				if( doneStep == initStep ){
					if( workers != null )
						for( w in workers )
							w.stop();
					workers = null;
					//#if !flash
					//trace("Total init: "+(haxe.Timer.stamp() - start));
					//#end
					#if cpp
					cpp.vm.Gc.run( true );
					#end

					READY = true;
				}
		}
		hxd.Profiler.end("Assets.progressiveInit");
		if( next )
			initStep++;
		return mt.MLib.fmin(1, 0.1 + 0.9*doneStep/( 1 + /****/ 13 /* <------ steps count here */ ));
	}


	public static function createText(size:Int, ?col:UInt=0xFFFFFF, ?txt:String, ?p:h2d.Sprite, ?sh:h2d.Drawable.DrawableShader) : h2d.Text {
		var f = size<=26 ? fontTiny : (size<=36 ? fontNormal : fontHuge);
		var t = new h2d.Text(f,p, sh!=null?cast sh.clone():null);
		t.filter = true;
		t.emit = true;

		if( f==fontTiny )
			t.scale(size/26);
		else if( f==fontNormal )
			t.scale(size/36);
		else if( f==fontHuge )
			t.scale(size/72);

		t.textColor = col;

		if( txt!=null )
			t.text = Lang.addNbsps(txt);

		return t;
	}

	public static function createBatchText(sb:h2d.SpriteBatch, font:h2d.Font, ?size:Float, ?col:UInt=0xFFFFFF, ?txt:String) : h2d.TextBatchElement {
		var t = new h2d.TextBatchElement(font,sb);
		t.textColor = col;

		var baseSize = if( font==fontTiny ) 26;
			else if( font==fontNormal ) 36;
			else 72;
		if( size==null )
			size = baseSize;
		t.setScale( size/baseSize );

		if( txt!=null )
			t.text = Lang.addNbsps(txt);

		return t;
	}

	public static inline function getDirectTexture(id:String) {
		return directTextures.get(id);
	}

	static function initDirectTexture(id:String, url:String) {
		mt.Assets.getTileDeferred(url,getWorker(),function(t){ directTextures.set(id,t); doneStep++; });
	}

	public static function getItemHSprite(i:Item, size:Float, ?xr=0., ?yr=0.) : Null<HSprite> {
		var e = switch( i ) {
			case I_Bath(f)	: custo0.h_get("bath", f);
			case I_Bed(f)	: custo0.h_get("bed", f);
			case I_Ceil(f)	: custo0.h_get("ceil", f);
			case I_Furn(f)	: custo0.h_get("furn", f);
			case I_Wall(f)	: custo0.h_get("wall", f);

			case I_Cold, I_Heat, I_Odor, I_Noise, I_Light :
				tiles.h_get( getItemIcon(i) );

			case I_Gem : tiles.h_get("moneyGem");

			default : return null;
		}
		e.filter = true;
		e.setCenterRatio(xr,yr);
		e.constraintSize(size);
		return e;
	}

	public static function getItemIcon(i:Item) : String {
		return switch( i ) {
			case I_Heat : "iconHeat";
			case I_Cold : "iconCold";
			case I_Odor : "iconOdor";
			case I_Noise : "iconNoise";
			case I_Gem : "moneyGem";
			case I_Money(n) : "moneyGold";
			case I_Light : "iconMoonlight";

			case I_Color(_) : "iconPaint";
			case I_Texture(_) : "iconPaint";

			case I_Bath(_) : "iconPaint";
			case I_Bed(_) : "iconPaint";
			case I_Ceil(_) : "iconPaint";
			case I_Furn(_) : "iconPaint";
			case I_Wall(_) : "iconPaint";

			case I_LunchBoxAll, I_LunchBoxCusto : "gift";
			case I_EventGift(_) : "chest";
		}
	}

	public static function getAffectIcon(a:Affect) {
		return switch( a ) {
			case Heat : "iconHeat";
			case Cold : "iconCold";
			case Odor : "iconOdor";
			case Noise : "iconNoise";
			case SunLight : "iconLight";
		}
	}


	public static function getGoldIcon(n:Int) {
		var i = tiles.getH2dBitmap("moneyGold", 0.5, 0.5);

		var str = Std.string(n);
		var t = new h2d.Text(fontNormal, i);
		t.text = str;
		t.scale( str.length>2 ? 0.55 : 0.8 );
		t.textColor = 0x8E3002;
		t.dropShadow = { color:0xFFFF80, alpha:1, dx:0, dy:2 }
		//t.dropShadow = { color:0x8E3002, alpha:1, dx:1, dy:0 }
		t.x = Std.int( -t.width*t.scaleX*0.5 - 2 );
		t.y = Std.int( -t.height*t.scaleY*0.5 );
		t.filter = true;

		return i;
	}

	public static function getGemIcon(n:Int) {
		var i = tiles.getH2dBitmap("moneyGem", 0.5, 0.5);

		var str = Std.string(n);
		var t = new h2d.Text(fontNormal, i);
		t.text = str;
		t.scale( str.length>2 ? 0.55 : 0.8 );
		t.textColor = 0x001D3C;
		t.dropShadow = { color:0xBBDBFF, alpha:0.8, dx:0, dy:2 }
		t.x = Std.int( -t.width*t.scaleX*0.5 );
		t.y = Std.int( -t.height*t.scaleY*0.5 );
		t.filter = true;

		return i;
	}


	public static function getClientIcon(t:ClientType, ?p) : h2d.Bitmap {
		return switch( t ) {
			case C_Bomb : monsters0.getH2dBitmap("monsterBombIdle", true, p);
			case C_MobSpawner : monsters1.getH2dBitmap("monsterSlimeIdle", true, p);
			case C_Spawnling : monsters1.getH2dBitmap("monsterSlimeIdle", true, p);
			case C_Custom : monsters1.getH2dBitmap("monsterSlimeIdle", true, p);
			case C_HappyLine : monsters0.getH2dBitmap("ghostMaskIdle", true, p);
			case C_HappyColumn : monsters1.getH2dBitmap("monsterEmpathyIdle", true, p);
			case C_Liker : monsters0.getH2dBitmap("monsterPoringIdle", true, p);
			case C_Neighbour : monsters0.getH2dBitmap("monsterEyeIdle", true, p);
			case C_Disliker : monsters0.getH2dBitmap("monsterPearIdle", true, p);
			case C_Plant : monsters0.getH2dBitmap("monsterPlantIdle", true, p);
			case C_Repairer : monsters0.getH2dBitmap("monsterCarefullIdle", true, p);
			case C_Vampire : monsters1.getH2dBitmap("spectralSwordIdle", true, p);
			case C_Inspector : monsters1.getH2dBitmap("monsterInspectorIdle", true, p);
			case C_Gifter : monsters0.getH2dBitmap("monsterMaruIdle", true, p);
			case C_Gem : monsters2.getH2dBitmap("monsterRoosterIdle", true, p);
			case C_Rich : monsters1.getH2dBitmap("monsterRichIdle", true, p);
			case C_JoyBomb : monsters1.getH2dBitmap("monsterJoyBombIdle", true, p);
			case C_Dragon : monsters0.getH2dBitmap("monsterPyroIdle", true, p);
			case C_Emitter : monsters0.getH2dBitmap("monsterFormolIdle", true, p);
			case C_MoneyGiver : monsters1.getH2dBitmap("monsterWeekEnderIdle", true, p);
			case C_Halloween : monsters2.getH2dBitmap("monsterBulb", true, p);
			case C_Christmas : monsters2.getH2dBitmap("monsterBulb", true, p); // TODO
		}
	}


	public static function getStockIconId(t:RoomType, ?crate=false) : Null<String> {
		return switch( t ) {
			case R_StockBeer : crate?"box_beer":"itemBeer";
			case R_StockPaper : crate?"box_pq":"iconPq";
			case R_StockSoap : crate?"box_soap":"iconSoap";
			case R_StockBoost : crate?"battery":"iconBattery";
			case R_CustoRecycler : null;
			default : "iconTodoRed";
		}
	}

	public static function getRoomIconId(t:RoomType) : String {
		return switch( t ) {
			case R_Bar : "roomBar";
			case R_Bedroom : "roomBedroom";
			case R_ClientRecycler : "roomRecycle";
			case R_Laundry : "roomLaundry";
			case R_Trash: "roomTrash";

			case R_StockBeer: "roomStockBeer";
			case R_StockPaper: "roomStockPq";
			case R_StockSoap: "roomStockSoap";
			case R_StockBoost: "roomStockBattery";

			case R_Library : "iconQuest";
			case R_FillerStructs : "iconPoutre";
			case R_LevelUp : "roomUnknown"; // TODO
			case R_CustoRecycler : "iconSaw";
			case R_Bank : "iconSafe";
			case R_VipCall : "roomUnknown"; // TODO

			case R_Lobby : "iconQueue";
		}
	}


	public static function destroy() {
		hxd.res.FontBuilder.deleteFont(fontTiny);
		fontTiny = null;

		hxd.res.FontBuilder.deleteFont(fontHuge);
		fontHuge = null;

		hxd.res.FontBuilder.deleteFont(fontRoof);
		fontRoof = null;

		hxd.res.FontBuilder.deleteFont(fontNormal);
		fontNormal = null;

		bg.destroy();
		bg = null;

		for( e in directTextures )
			e.dispose();
		directTextures = null;

		monsters0.destroy();
		monsters0 = null;

		monsters1.destroy();
		monsters1 = null;

		monsters2.destroy();
		monsters2 = null;

		tiles.destroy();
		tiles = null;

		tiles1.destroy();
		tiles1 = null;
	}
}
