package anim;
import Lib;
import mt.deepnight.SpriteLib;

@:bitmap("../gfx/anim/girl.png") class GirlTilesData extends BitmapData {}
@:bitmap("../gfx/anim/dog.png") class DogTilesData extends BitmapData {}
@:bitmap("../gfx/anim/boy.png") class BoyTilesData extends BitmapData {}

class TilesManager
{

	public var girlTiles : SpriteLib;
	public var dogTiles : SpriteLib;
	public var boyTiles : SpriteLib;
	
	public function new()
	{
		initGirlTiles();
		initDogTiles();
		initBoyTiles();
	}
	
	function removeBackground( b : BitmapData)
	{
		//b.threshold( b, b.rect, Lib.P_ZERO, "==", 0xd3f6f4, 0xFF000000, 0xFFFFFFFF, false);
	}
	
	function initGirlTiles()
	{
		var w = 50;
		var h = 50;
		var b = new GirlTilesData(0, 0);
		removeBackground(b);
		var tiles = new SpriteLib( b ) ;
		tiles.setDefaultCenter(0.32, 0.80);
		tiles.setUnit(w, h) ;
		//TODO tester sliceUnitCustom  avec 32x32?
		tiles.sliceUnit("down", 0, 0, 7) ;
		tiles.sliceUnit("left", 0, 1, 7) ;
		tiles.sliceUnit("up", 0, 2, 7) ;
		tiles.sliceUnit("win", 0, 3);
		tiles.sliceUnit("oups", 0, 4, 8);
		//ANIMS
		tiles.setAnim("walk", [0, 1, 2, 3, 4, 5, 6], [4]) ;
		tiles.setAnim("missed", [0, 1, 2, 3, 4, 5, 6, 7], [4]) ;
		girlTiles = tiles;
	}
	
	function initDogTiles()
	{
		var w = 50;
		var h = 50;
		var b = new DogTilesData(0, 0);
		removeBackground(b);
		var tiles = new SpriteLib( b ) ;
		tiles.setUnit(w, h) ;
		tiles.setDefaultCenter(0.43, 0.75);
		//
		tiles.sliceUnit("down", 0, 1, 5) ;
		tiles.sliceUnit("up", 0, 2, 5) ;
		tiles.sliceUnit("left", 0, 0, 5) ;
		
		tiles.sliceUnit("fall_left", 0, 3, 3) ;
		tiles.sliceUnit("fall_down", 0, 4, 3) ;
		tiles.sliceUnit("fall_up", 0, 5, 3) ;
		
		//ANIMS
		tiles.setAnim("walk", [0, 1, 2, 3, 4], [4]) ;
		tiles.setAnim("fall", [0, 1, 2], [2] );
		
		dogTiles = tiles;
	}
	
	function initBoyTiles()
	{
		var w = 50;
		var h = 50;
		var b = new BoyTilesData(0, 0);
		removeBackground(b);
		var tiles = new SpriteLib( b ) ;
		tiles.setUnit(w, h) ;
		tiles.setDefaultCenter(.45, .85);
		
		tiles.sliceUnit("cry", 0, 0, 8) ;
	
		tiles.sliceUnit("down", 0, 1, 7) ;
		tiles.sliceUnit("left", 0, 3, 7) ;
		tiles.sliceUnit("up", 0, 2, 7) ;
		//ANIMS
		tiles.setAnim("walk", [0, 1, 2, 3, 4, 5, 6], [4]) ;
		tiles.setAnim("cry_anim", [0, 1, 2, 3, 4, 5, 6, 7], [5]) ;
		boyTiles = tiles;
	}
}

