import KKApi;
import mt.bumdum.Lib;


typedef Ball = {>Sprite,ph:sbh.Phys, gr:sbh.Grid};

class Game {//}

	public static var DP_SHOTS = 	3;
	public static var DP_HERO = 	2;
	public static var DP_BG = 	0;

	public var dm:mt.DepthManager;
	public var root:flash.MovieClip;
	public var bg:flash.MovieClip;
	static public var me:Game;

	public var zone:flash.geom.Rectangle<Float>;
	var hero:Hero;
	var gr:sbh.Grid;


	public function new( mc : flash.MovieClip ){

		//
		haxe.Log.setColor(0xFFFFFF);

		root = mc;
		me = this;
		dm = new mt.DepthManager(root);
		bg = dm.attach("mcBg",0);

		zone = new flash.geom.Rectangle(0.0,0,Cs.mcw,Cs.mch);

		hero = new Hero();


	}

	public function update(){


		viewGrid(0);
		updateSprites();


	}
	function updateSprites(){
		var list =  Sprite.LIST.copy();
		for(sp in list)sp.update();
	}

	// DEBUG
	var bmpGrid:flash.display.BitmapData;
	function viewGrid(id){
		if( !flash.Key.isDown(71) ){
			bmpGrid.dispose();
			bmpGrid = null;
			return;
		}


		if(bmpGrid==null){
			bmpGrid = new flash.display.BitmapData( sbh.Grid.XMAX,sbh.Grid.YMAX, false, 0 );
			var mc = dm.empty(1);
			mc.attachBitmap(bmpGrid,0);
			mc.blendMode = "add";
			mc._xscale = (Cs.mcw/sbh.Grid.XMAX)*100;
			mc._yscale = (Cs.mch/sbh.Grid.YMAX)*100;


		}

		for( x in 0...sbh.Grid.XMAX ){
			for( y in 0...sbh.Grid.YMAX ){
				var n = sbh.Grid.grid[id][x][y].length * 10;
				if( n >255 ) n = 255;
				var col = Col.objToCol({r:n,g:n,b:n});
				bmpGrid.setPixel(x,y,col);
			}
		}


	}

//{
}




