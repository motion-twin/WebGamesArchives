import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import mt.bumdum9.Lib;


class GfxWorld extends BitmapData { }
class GfxMonsters extends BitmapData { }
class GfxInter extends BitmapData { }
class GfxHero extends BitmapData { }
class GfxFx extends BitmapData { }
class GfxModule extends BitmapData { }
class GfxGames extends BitmapData { }
class GfxIllus extends BitmapData { }

class Gfx {//}
	// COLORS
	public static var BLACK = 			4278190080;
	public static var WHITE = 			4294967295;
	public static var BLUE = 			4283267837;
	public static var DARK_BLUE = 		4284492967;
	
	static public var monsters :	pix.Store;
	static public var world :		pix.Store;
	static public var inter :		pix.Store;
	static public var hero :		pix.Store;
	static public var fx :			pix.Store;
	static public var mod :			pix.Store;
	static public var games :		pix.Store;
	static public var illus :		pix.Store;
	
	static public function init() {

		
		
		initWorld();
		initMonsters();
		initFx();
		initInter();
		initModule();
		initHero();

		
		/// ILLUS
		var bmp = new GfxIllus(10, 10);
		illus = new pix.Store(bmp);
		illus.addIndex("medusa");
		illus.slice(0, 0, 50, 55, 4);
		illus.addAnim("medusa", [0, 1, 2, 3], [4,4,3,2]);
		illus.addIndex("voodoo_mask");
		illus.slice(200, 0, 50, 50);
		
		// GAMES
		var bmp = new GfxGames(0, 0);
		makeTransp(bmp, WHITE );
		games = new pix.Store(bmp);
		
		// INTRUDER
		games.addIndex("horde_toys");
		games.slice(0, 0, 16, 16, 15, 3);
		games.addIndex("horde_bg");
		games.slice(0, 48, 200, 100);
		games.addIndex("horde_card");
		games.slice(200, 48, 32, 32);
		
		// SUPER KNIGHT
		games.addIndex("super_knight");
		games.slice( 200, 104, 16, 16, 1, 4 );
		games.setOffset( 5, 0);
		games.slice( 216, 152, 24, 16 );
		games.setOffset( 0, 5);
		games.slice( 216, 104, 16, 24 );
		games.setOffset( -5, 0);
		games.slice( 216, 168, 24, 16 );
		games.setOffset( 0, -5);
		games.slice( 216, 128, 16, 24 );
		games.setOffset();
		
		games.addIndex("orc");
		games.slice( 0, 152, 16, 16, 6, 4 );
		var anims = ["orc_front", "orc_back", "orc_side", "orc_carry"];
		for( i in 0...4  ) {
			var a = [];
			for( k in 0...6 ) a.push(k+i*6);
			games.addAnim(anims[i], a, [2]);
		}
		games.addIndex("orc_die");
		games.slice( 96, 152, 16, 16 );
		
		games.addIndex("knight_naked");
		games.slice( 96, 168, 16, 16 );
		
		games.addIndex("knight_tile");
		games.slice( 96, 200, 16, 16 );
		games.addIndex("knight_holes");
		games.slice( 112, 200, 8, 8, 2, 2 );
		games.slice( 120, 208, 4, 4, 2, 2);
		
		games.addIndex("knight_armor");
		games.slice( 96, 184, 8, 8, 3, 2);
		games.slice( 120, 184, 8, 16);
		
		// LABYSLIDE
		games.addIndex("laby_slide_tiles");
		games.slice(0, 216, 16, 16, 4, 4);
		games.addIndex("laby_slide_ball");
		games.slice(0, 148, 4, 4);
		
		// LABYBALL
		games.addIndex("laby_ball");
		games.slice(217, 81, 8, 8);
		games.addIndex("laby_ball_wall");
		games.slice(200, 80, 16, 16);
	}
	
	static function initHero() {
		var bmp = new GfxHero(0, 0);
		makeTransp(bmp, WHITE );
		
		var color = Col.brighten(Main.worldColor, -120);
		var o = Col.colToObj(color);
		color = Col.objToCol32( { r:o.r, g:o.g, b:o.b, a:255 } );
		replaceCol(bmp, BLACK, color);
		
		hero = new pix.Store(bmp);
		
		hero.addIndex("hero_front");
		hero.slice(0, 0, 16, 16, 12);
		hero.addAnim("hero_front", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], [2]);
		hero.addAnim("hero_stand", [0], [2]);
		
		hero.addIndex("hero_right");
		hero.slice(0, 16, 16, 16, 12);
		hero.addAnim("hero_right", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], [2]);
		
		hero.addIndex("hero_left");
		hero.slice(0, 16, 16, 16, 12, 1, true );
		hero.addAnim("hero_left", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], [2]);
		
		hero.addIndex("hero_back");
		hero.slice(0, 32, 16, 16, 12);
		hero.addAnim("hero_back", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], [2]);
		
		hero.addIndex("hero_hurt");
		hero.slice(160, 64, 16, 16, 2 );
		hero.addAnim("hero_hurt", [0], [24]);
			
		hero.addIndex("hero_sorcery");
		hero.slice(0,80, 16, 16, 5 );
		hero.addAnim("hero_sorcery", [0, 1, 2, 3, 4], [2]);
		hero.addAnim("hero_sorcery_loop", [3, 2, 3, 4], [2, 4, 2, 4]);
		
		hero.addIndex("hero_slash");
		hero.slice(96, 80, 16, 16, 5 );
		hero.addAnim("hero_slash", [0, 1, 2, 3, 4], [2]);


		hero.setOffset(0, -8);
		hero.addIndex("hero_explode");
		hero.slice(0, 176, 32, 32, 6, 4 );
		hero.addAnim("hero_explode", [0, 1, 2, 3, 4, 5, 6, 8, 9, 10 ,11, 12, 13, 14, 15, 16, 17, 18, 19], [4,4,4,5,6,7,8,2]);
		
		hero.setOffset(0, -1);
		hero.addIndex("hero_cheese");
		hero.slice(0, 96, 16, 16, 12);
		hero.slice(0, 112, 16, 16, 4);
		hero.addAnim("hero_cheese", [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], [2,6,5,4,3,2]);
		
		hero.setOffset(0, -8);
		hero.addIndex("hero_happy_jump");
		hero.slice(0, 48, 16, 32, 10);
		hero.addAnim("hero_happy_jump", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], [2]);
		
		hero.setOffset(0, -4);
		hero.addIndex("hero_fork");
		hero.slice(72, 152, 16, 24, 5 );
		hero.addAnim("hero_fork", [0, 1, 2, 3, 4], [2,6,2,2,16]);
		
		hero.setOffset(-1, -6);
		hero.addIndex("hero_knife");
		hero.slice(0, 128, 24, 24,8);
		hero.slice(0, 152, 24, 24,3);
		hero.addAnim("hero_knife", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], [2, 2, 2, 3, 4, 5, 2, 2, 3]);
		
		
				
	}
	static function initModule() {
		var bmp = new GfxModule(0, 0);
		makeTransp(bmp, WHITE );
		mod = new pix.Store(bmp);
		
		mod.addIndex("radar");
		mod.slice(0, 0, 128, 128 );
		
		mod.addIndex("dice");
		mod.slice(128, 0, 32, 32, 2, 3 );
		
		mod.addIndex("table");
		mod.slice(0, 128, 96, 36 );
		
		mod.addIndex("fever_x");
		mod.slice(0, 168, 120, 168 );
		// 40 288 --> 40 120 -> -20, 44
		
		mod.addIndex("fever_x_back");
		mod.slice(0, 164, 120, 4 );
		
		mod.addIndex("arrow");
		mod.slice(128, 96, 8, 8 );
		
		mod.addIndex("gradient_blocks");
		mod.slice(128, 176, 4, 4, 3, 2 );
		
		mod.addIndex("timer_brick");
		mod.slice(136, 96, 7, 5, 3 );
		
		mod.addIndex("cart");
		mod.slice(128, 104, 64, 72 );
		
		mod.addIndex("fever_x_click");
		mod.slice(128, 184, 40, 40 );
		
				
	}
	static function initInter() {
		var bmp = new GfxInter(0, 0);
		makeTransp(bmp, WHITE );
		inter = new pix.Store(bmp);
		
		inter.addIndex("bar");
		inter.slice(0, 0, 200, 9, 1, 2);
		
		inter.addIndex("heart");
		inter.slice(0, 18, 8, 7, 2);
		inter.slice(23, 18, 8, 7);
		
		inter.addIndex("timebar");
		inter.slice(16, 18, 1, 7, 2);
		
		inter.addIndex("icon_temp");
		inter.slice(18, 18, 5, 5);
		
		inter.addIndex("heart_explode");
		inter.slice(0, 32, 16, 16, 8);
		inter.addAnim("heart_explode", [0, 1, 2, 3, 4, 5, 6, 7], [2]);
		
		inter.addIndex("loading_bar");
		inter.slice(140, 18, 60, 5, 1, 5);
		inter.addAnim("loading_bar", [0, 1, 2, 3, 4], [2]);
		
		inter.addIndex("icecube");
		inter.slice(0, 48, 10, 12, 2 );
		inter.addIndex("rainbow");
		inter.slice(20, 48, 15, 10 );

		inter.addIndex("bonus_game");
		inter.slice(0, 64, 16, 16, 3 );
		inter.addIndex("bonus_island");
		inter.slice(48, 64, 16, 16, 3 );
		inter.addIndex("bonus_ground");
		inter.slice(0, 80, 16, 16, 12 );
		
		inter.addIndex("items");
		inter.slice(0, 96, 16, 16, 12, 3 );
		
		inter.addIndex("bag");
		inter.slice(48, 48, 16, 16, 4 );
		inter.addAnim("bag", [0, 1, 2, 3], [2]);
		
		inter.addIndex("inv");
		inter.slice(0, 144, 200, 88 );
		
		inter.addIndex("inv_slash");
		inter.slice(112, 48, 16, 16 );
		
		inter.addIndex("big_heart");
		inter.slice(0, 240, 32, 32, 4 );
		
		inter.addIndex("bg_timebar");
		inter.slice(31, 18, 1, 18 );
		
		inter.addIndex("adv_icons");
		inter.slice(32, 18, 10, 9, 4 );
		
		inter.addIndex("rainbow_arrow");
		inter.slice(96, 64, 16, 16, 5 );
		inter.addAnim("rainbow_arrow", [0, 1, 2, 3, 4], [4]);
		inter.addIndex("classic_arrow");
		inter.slice(96, 80, 16, 16);
		
		inter.addIndex("runes");
		inter.slice(128, 224, 16, 16, 3, 2 );
		
		inter.addIndex("no_entry");
		inter.slice(112, 48, 16, 16);
		
		inter.addIndex("bonus_daily");
		inter.slice(112, 80, 16, 16, 2 );

			
	}
	static function initMonsters() {
		// MONSTERS
		var bmp = new GfxMonsters(0, 0);
		makeTransp(bmp, WHITE );
		monsters = new pix.Store(bmp);
		
		// BLOBS
		var names = ["blob_yellow", "blob_green", "blob_rose"];
		for ( i in 0...3 ) {
			var name = names[i];
			monsters.addIndex(name);
			monsters.slice( 0, i*16, 16, 16, 4, 1 );
			monsters.slice( 0, i*16, 16, 16, 4, 1, true );
			monsters.addAnim(name, [0, 1, 2, 3, 1, 4, 5, 6, 7, 5], [2, 3, 4, 5, 3, 2, 3, 4, 5, 3]);
			
			monsters.addIndex(name+"_explode");
			monsters.slice( 64, i * 16, 16, 16, 8 );
			monsters.addAnim(name + "_explode", [0, 1, 2, 3, 4, 5, 6, 7], [2, 4, 8, 2]);
			monsters.addAnim(name+"_hurt", [0, 1, 2, 1, 0], [1,2,4,3,2]);
		}
		
		// PIAF
		monsters.addIndex("piaf");
		monsters.slice( 0, 48, 16, 24, 16 );
		monsters.addAnim("piaf", [0, 1, 2, 3, 4, 5], [8]);
		monsters.addAnim("piaf_hurt", [5], [16]);
		monsters.addAnim("piaf_explode", [8, 9, 10, 9, 10, 9, 10, 9, 10, 11, 12, 12, 13, 13, 14, 14 , 15, 15], [2]);
		
		// SCARAB
		monsters.addIndex("scarab");
		monsters.slice( 0, 72, 16, 24, 10, 2);
		monsters.addAnim("scarab",[0, 1, 2, 0, 1, 2, 0, 1, 2, 3, 4, 5, 6, 7, 8], [4]);
		monsters.addAnim("scarab_hurt", [9], [16]);
		monsters.addAnim("scarab_explode", [5, 6, 10, 11, 12, 13, 12, 13, 12, 13, 14, 15, 16, 17, 18, 19], [ 2, 2, 2, 3, 4, 4, 2, 2, 2, 2, 2, 2, 2, 3, 4, 5]);
		
		// OCTOPUS
		monsters.addIndex("poulpe");
		monsters.slice( 0, 120 , 16, 16, 16 );
		monsters.addAnim("poulpe", [0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3, 0, 1, 2, 3], [4]);
		monsters.addAnim("poulpe_hurt", [15], [16]);
		monsters.addAnim("poulpe_explode", [0, 8, 9, 8, 9, 8, 9, 8, 9, 10, 11, 12,12, 13,13, 14,14], [2]);
		
		// RED
		monsters.addIndex("red");
		monsters.slice( 0, 136 , 16, 24, 16 );
		monsters.addAnim("red", [0, 1, 2, 3, 4, 5], [4]);
		monsters.addAnim("red_hurt", [6,7,6], [4,8,4]);
		monsters.addAnim("red_explode", [6, 7, 8, 9, 10, 11, 12, 13, 14, 15], [2, 2, 2, 2, 2, 2, 2, 3, 4]);
		
		// STINKY
		monsters.addIndex("stinky");
		monsters.slice( 0, 160, 16, 24, 16 );
		monsters.addAnim("stinky", [0, 1, 2, 3, 4, 5, 6, 7], [2, 4, 6, 2, 2, 4, 6, 2]);
		monsters.addAnim("stinky_hurt", [8, 9, 8], [4, 8, 4]);
		monsters.addAnim("stinky_explode", [0, 8, 9, 10, 11, 12, 13, 14, 15], [2, 4, 8, 2, 2, 3, 4]);
		
		// GHOST
		monsters.addIndex("ghost");
		monsters.slice( 0, 184, 16, 24, 16 );
		monsters.addAnim("ghost", [0, 1, 2, 3, 4, 5], [6, 4, 4, 6, 4, 4]);
		monsters.addAnim("ghost_hurt", [6, 7, 6, 7, 6, 7],[4]);
		monsters.addAnim("ghost_explode", [8, 9, 10, 11, 12, 13, 14], [4] );

		// NARAM
		monsters.addIndex("naram");
		monsters.slice( 0, 208, 16, 24, 16 );
		monsters.addAnim("naram", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], [4]);
		monsters.addAnim("naram_hurt", [15],[16]);
		monsters.addAnim("naram_explode", [15,7,15,7,15,7,15,11, 12, 13, 14, 14, 14], [4,3,4,2,4,1,4] );
		
		// SARGON
		monsters.addIndex("sargon");
		monsters.slice( 0, 232, 16, 24, 16 );
		monsters.addAnim("sargon", [0, 1, 2, 3, 4, 5, 6], [4]);
		monsters.addAnim("sargon_hurt", [10],[16]);
		monsters.addAnim("sargon_explode", [7, 8, 9, 10, 11, 12, 13, 14, 15, 14, 15, 14, 15, 14, 15], [2] );
		monsters.addIndex("sargon_repel");
		monsters.slice( 176, 256, 16, 24, 5 );
		monsters.addAnim("sargon_repel", [0,1,2,3,4],[4]);
		
		// BRAINO
		monsters.addIndex("braino");
		monsters.slice( 0, 256, 16, 24, 5, 4 );
		monsters.addAnim("braino", [0, 1, 2, 2, 1, 0, 3, 4, 4, 3 ], [2]);
		monsters.addAnim("braino_hurt", [6],[16]);
		monsters.addAnim("braino_explode", [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19], [2, 2, 3, 4, 2] );
				
		// MEDUSA
		monsters.addIndex("medusa");
		monsters.slice( 80, 256, 16, 24, 6, 5 );
		monsters.addAnim("medusa", [0, 1, 2, 3, 4, 5 ], [4]);
		
		monsters.addAnim("medusa_explode", [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16], [3] );
		monsters.addAnim("medusa_stone", [0, 18, 0, 18, 0, 18, 0, 18, 0, 18, 0, 18, 0, 18, 0, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], [3] );
		monsters.addAnim("medusa_hurt", [6], [16]);
		
		// KOUROU
		monsters.addIndex("kourou");
		monsters.slice( 176, 280, 16, 16, 5, 2 );
		monsters.addAnim("kourou", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], [4] );
		
		monsters.addIndex("kourou_explode");
		monsters.setOffset(0, -4);
		monsters.slice( 0, 376, 24, 24, 10, 2 );
		monsters.addAnim("kourou_explode", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], [2, 4, 6, 8, 10, 2] );
		monsters.addAnim("kourou_hurt", [1],[16]);
		
		
		
		
		//monsters.addAnim("piaf_look", [1, 6, 7, 6], [9, 2, 9, 2]);
		
		
	}
	static function initWorld() {
		var bmp = new GfxWorld(0, 0);
		makeTransp(bmp, WHITE );
		world = new pix.Store(bmp);
		world.slice(0, 0, 16, 16, 10);
		world.addIndex("dirt");
		world.slice(0, 16, 16, 16, 16);
		
		world.addIndex("grass");
		world.slice(0, 96, 16, 16, 16);
		
		world.addIndex("cliff");
		world.slice(0, 32, 16, 16, 16);
		
		/*
		world.addIndex("waves");
		world.slice(0, 64, 16, 16, 6);
		world.addAnim("waves", [0, 1, 2, 3, 4, 5], [8]);
		world.addIndex("waves_2");
		world.slice(0, 80, 16, 21, 6);
		world.addAnim("waves_2", [0, 1, 2, 3, 4, 5], [8]);
		*/
		
		world.addIndex("waves_3");
		world.slice(96, 64, 16, 24,2);
		world.slice(96, 64, 16, 8);
		
		world.addIndex("clouds");
		world.slice(0, 168, 24, 24,4);
		
		world.addIndex("elements_dirt_small");
		world.slice(0, 48, 8, 8, 4, 2);
		world.addIndex("elements_dirt_medium");
		world.slice(32, 48, 16, 16, 5);
		
		world.setOffset(0, -1);
		world.addIndex("elements_grass_medium");
		world.slice(0, 128, 16, 15, 8);
		world.setOffset(0, 0);
		
		world.addIndex("ladder");
		world.slice( 64, 0, 16, 16 );
		
		world.addIndex("jump_stone");
		world.slice( 80, 0, 16, 16, 2 );
		
		world.addIndex("selector");
		world.slice( 144, 0, 16, 16, 3 );
		world.addAnim("selector", [0, 1, 2], [4]);
		
		world.addIndex("portal");
		world.slice( 0, 144, 22, 18 );
		
		world.addIndex("portal_light");
		world.slice( 22, 144, 12, 12, 4, 2 );
		world.addAnim("portal_light", [0, 1, 2, 3, 4 , 5, 6, 7], [2]);
		
		world.addIndex("portal_stone");
		world.slice( 0, 162, 2, 2, 4 );
		world.addAnim("portal_stone", [0, 2, 1, 2, 3], [16, 2, 4, 2]);

		world.addIndex("chest");
		world.slice( 80, 144, 16, 16, 6 );

		world.addIndex("statue");
		world.slice( 112, 32, 16, 32 );
		
		world.addIndex("fever_head");
		world.slice( 128, 48, 32, 48, 4 );
		
		world.setOffset(0, 16);
		world.addIndex("fever_head");
		world.slice( 128, 48, 32, 48, 4 );
	}
	
	// FX
	static function initFx() {
		var bmp = new GfxFx(0, 0);
		makeTransp(bmp, WHITE );
		fx = new pix.Store(bmp);
		
		fx.addIndex("bonus_vanish");
		fx.slice(0, 0, 16, 16, 9);
		fx.addAnim("bonus_vanish", [0, 1, 2, 3, 4, 5, 6, 7, 8], [2]);
		
		fx.addIndex("spark_twinkle");
		fx.slice(0, 16, 8, 8, 4);
		fx.addAnim("spark_twinkle", [0, 1, 2, 3], [40, 2] );
		
		fx.addIndex("spark_grow");
		fx.slice(32, 16, 3, 3, 3);
		fx.slice(32, 19, 5, 5, 2);
		fx.addAnim("spark_grow", [0, 1, 2, 3], [4] );
		fx.addAnim("spark_grow_loop", [4, 3], [2] );
		fx.addAnim("spark", [0, 1, 2], [2] );
		
		fx.addIndex("twinkle_gray");
		fx.slice(0, 24, 8, 8, 4);
		fx.addAnim("twinkle_gray", [0, 1, 2, 3], [16, 2] );
		
		fx.addIndex("rainbow");
		fx.slice(144, 0, 16, 16);
		
		fx.addIndex("scan_hero");
		fx.slice(144, 16, 8, 8 );
		
		fx.addIndex("knife");
		fx.slice(144, 24, 16, 4, 1, 2 );
		
		fx.addIndex("dirt_stones");
		fx.slice(128, 32, 8, 8, 3  );
		fx.slice(152, 32, 4, 4, 2, 2  );
		
		fx.addIndex("grey_stones");
		fx.slice(128, 40, 8, 8, 3  );
		fx.slice(152, 40, 4, 4, 2, 2  );
		
		fx.addIndex("butterfly");
		fx.slice(0, 88, 8, 8, 6);
		fx.addAnim("butterfly", [0, 1, 2, 3, 4, 5], [2] );
		
		// OFFSET
		fx.setOffset(0, -6);
		fx.addIndex("tornado");
		fx.slice(48, 16, 16, 16, 6);
		fx.addAnim("tornado", [0, 1, 2, 3, 4, 5], [4] );
		
		fx.setOffset(0, -4);
		fx.addIndex("square_explosion");
		fx.slice(0, 64, 16, 24, 10);
		fx.addAnim("square_explosion", [0, 1, 2, 3, 4, 5, 6, 7, 7, 8, 8, 9, 9], [2] );
		
		fx.setOffset(-8, -8);
		fx.addIndex("fireball");
		fx.slice(0, 32, 32, 33, 4);
		fx.addAnim("fireball", [0, 1, 2, 3], [4] );
		
		
		
		
		
	}
	
	//
	static function makeTransp( bmp:BitmapData, color:Float ) {
		for ( x in 0...bmp.width ) {
			for ( y in 0...bmp.height ) {
				if ( bmp.getPixel32(x, y) == color ) {
					bmp.setPixel32(x, y, 0 );
				}
			}
		}
	}
	public static function replaceCol( bmp:BitmapData, a:Float, b:Float ) {
		for ( x in 0...bmp.width ) {
			for ( y in 0...bmp.height ) {
				if ( bmp.getPixel32(x, y) == a ) {
						bmp.setPixel32(x, y, cast b );
				}
			}
		}
		return bmp;
	}
	
	// TOOLS

//{
}



