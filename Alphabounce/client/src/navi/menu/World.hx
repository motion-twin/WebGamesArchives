package navi.menu;
import mt.bumdum.Lib;

class World extends navi.Menu{//}

	var sq:Float;

	var xmax:Int;
	var ymax:Int;
	var ddx:Int;
	var ddy:Int;

	var pts:Array<Array<flash.MovieClip>>;
	var bg:flash.MovieClip;
	var bmpZone:flash.display.BitmapData;

	override function init(){
		super.init();
		initMap(1.2);

	}

	function initMap(sc){

		sq = sc;

		xmax = Std.int(Cs.mcw/sq);
		ymax = Std.int(Cs.mch/sq);
		ddx = Std.int(xmax*0.5);
		ddy = Std.int(ymax*0.5);

		initBg();
		initIcons();
		initInter();
	}
	function initBg(){


		// BG
		bg = dm.empty(0);
		var bmp = new flash.display.BitmapData(Cs.mcw,Cs.mch,false,0x001144 );
		bg.attachBitmap(bmp,0);

		bg.onPress = clickMap;


		// LINES
		var col = 0x002266;
		for( x in 0...xmax ) bmp.fillRect( new flash.geom.Rectangle( Std.int(x*sq), 0, 1, Cs.mch ), col );
		for( y in 0...ymax ) bmp.fillRect( new flash.geom.Rectangle( 0, Std.int(y*sq), Cs.mcw, 1 ), col );


	}
	function initIcons(){


		// TROU NOIRS
		var path = dm.empty(1);
		path.lineStyle(10,0xFF00FF,20);
		for( a in ZoneInfo.holes ){
			for( i in 0...a.length ){
				var p = a[i];
				var mc = dm.attach("mcWorldMapIcon",1);
				mc._x = getX(p[0]);
				mc._y = getY(p[1]);
				mc.gotoAndStop(4);
				if(i==0)path.moveTo(mc._x,mc._y);
				if(i==1)path.lineTo(mc._x,mc._y);

			}
		}

		// ZONES
		var zid = 0;
		var brush =  Manager.mcPlanet;
		bmpZone.dispose();
		bmpZone = new flash.display.BitmapData(Cs.mcw,Cs.mch,true,0);
		for( zi in ZoneInfo.list ){

			brush.smc.gotoAndStop(zid+1);
			var scx = zi.pos[2]*2*sq;
			var scy = zi.pos[2]*2*sq;
			var m = new flash.geom.Matrix();
			m.scale(scx*0.01,scy*0.01);
			m.translate( getX(zi.pos[0]+0.5), getY(zi.pos[1]+0.5) );
			bmpZone.draw(brush,m);


			/*
			var mc = dm.attach("mcZone",1);
			mc._x = getX(zi.pos[0]+0.5);
			mc._y = getY(zi.pos[1]+0.5);
			mc._xscale = (zi.pos[2]*2)*sq;
			mc._yscale = mc._xscale;
			mc.gotoAndStop(zid+1);
			*/

			zid++;
			//Filt.glow(mc,2,4,0xFFFFFF);
			//Filt.glow(mc,5,1,0xFFFFFF);

		}
		var mc = dm.empty(1);
		mc.attachBitmap(bmpZone,0);


		// POINTS
		pts = [];
		for( item in MissionInfo.ITEMS ){
			if(item.x!=null){
				var mc = dm.attach("mcWorldMapIcon",1);
				mc._x = getX(item.x);
				mc._y = getY(item.y);
				//mc._xscale = mc._yscale = sq*10;
				mc.gotoAndStop(item.fam+1);
				//Col.setColor(mc,[0xFFFFFF,0x00FF00,0xFFFF00][item.fam]);
			}
		}

		// ASTEROID

		var mc = dm.attach("worldAsteroMap",2);
		mc._x = getX( ZoneInfo.ASTEROBELT_CX );
		mc._y = getY( ZoneInfo.ASTEROBELT_CY );
		mc._xscale = ZoneInfo.ASTEROBELT_RAY*2*sq;
		mc._yscale = ZoneInfo.ASTEROBELT_RAY*2*sq;








	}
	function initInter(){

		// BUTTONS
		var a = [quit,zoomIn,zoomOut];
		var x = Cs.mcw - 0.0;
		var id = 0;
		for( f in a ){
			var mc = dm.attach("mcWorldBut",1);
			mc.gotoAndStop(id+1);
			x -= mc._width+4;
			mc._x = x;
			mc._y = Cs.mch - 22;
			mc.onRollOver = function(){ mc.blendMode = "add"; };
			mc.onRollOut = function(){ mc.blendMode = "normal"; };
			mc.onDragOut = mc.onRollOut;
			mc.onPress = f;
			id++;
		}


	}

	// UPDATE
	override public function update(){
		super.update();
		haxe.Log.clear();
		var x = Std.int(root._xmouse/sq)-ddx;
		var y = Std.int(root._ymouse/sq)-ddy;
		//trace( x+","+y );

	}

	// TOOLS
	function getX(px:Float){
		return (px+ddx)*sq;
	}
	function getY(py:Float){
		return (py+ddy)*sq;
	}

	// ACTION
	function zoomIn(){
		dm.destroy();
		initMap(sq*2);
	}
	function zoomOut(){
		dm.destroy();
		initMap(sq*0.5);
	}

	function clickMap(){

		var px = Std.int( (bg._xmouse/sq)-ddx );
		var py = Std.int( (bg._ymouse/sq)-ddy );
		navi.Map.me.callPlay(px,py);

		quit();

		/*
		var px = Std.int( (bg._xmouse/sq)-ddx );
		var py = Std.int( (bg._ymouse/sq)-ddy );
		Cs.pi.x = px;
		Cs.pi.y = py;
		Cs.pi.saveCache();
		*/

	}

//{
}








