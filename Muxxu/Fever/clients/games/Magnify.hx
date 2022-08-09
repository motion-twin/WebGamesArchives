import mt.bumdum9.Lib;

typedef MagCell = {>flash.display.MovieClip,px:Float,py:Float};

class Magnify extends Game{//}

	var mcw:Float;
	var mch:Float;

	var px:Float;
	var py:Float;

	var zoom:Float;
	var cellMax:Int;

	var size:Int;
	var ec:Int;

	var cell:flash.display.MovieClip;
	var mcLvl:flash.display.MovieClip;
	var ldm:mt.DepthManager;
	var cells:List<MagCell>;
	var text:flash.display.BitmapData;

	var scan:{>flash.display.MovieClip, bmp:flash.display.BitmapData, cadre:flash.display.MovieClip};

	override function init(dif:Float){
		gameTime =  400-50*dif;
		super.init(dif);
		zoom = 3+dif*3;
		if( zoom>8 )zoom =8;
		ec = 200;
		size = 100;
		mcw = Cs.mcw*zoom;
		mch = Cs.mch*zoom;

		cellMax = Std.int( Math.pow(mcw*0.003,2));

		attachElements();
	}

	function attachElements(){
		bg = dm.attach("magnify_bg",0);
		//
		// LEVEL
		mcLvl = dm.empty(0);
		ldm = new mt.DepthManager(mcLvl);
		mcLvl.scaleX = mcLvl.scaleY = 1/zoom;

		// TEXTURE
		text = new flash.display.BitmapData(ec,ec,false,0x00FF00);
		var brush = dm.attach("magnify_text",0);
		var m = new flash.geom.Matrix();
		m.scale(ec*0.01,ec*0.01);
		text.draw(brush,m);
		brush.parent.removeChild(brush);

		var xmax = Math.ceil( mcw/ec );
		var ymax = Math.ceil( mcw/ec );
		for( x in 0...xmax ){
			for( y in 0...xmax ){
				var mc = ldm.empty(0);
				mc.addChild(new flash.display.Bitmap(text));
				mc.x = x*ec;
				mc.y = y*ec;

			}
		}

		// SCAN
		scan = cast dm.empty(1);
		var sdm = new mt.DepthManager(scan);
		var mask = sdm.attach("magnify_round",0);
		var mc = sdm.empty(0);
		mask.x = size*0.5;
		mask.y = size*0.5;
		mask.scaleX = mask.scaleY = size*0.01;
		mc.mask = mask;
		scan.mouseChildren = false;
		scan.mouseEnabled = false;

		scan.bmp = new flash.display.BitmapData(size, size, false, 0x00FF00);
		mc.addChild(new flash.display.Bitmap(scan.bmp));
		//mc.attachBitmap(scan.bmp,0);
		scan.x = (Cs.mcw-size)*0.5;
		scan.y = (Cs.mch-size)*0.5;
		Filt.glow(scan,4,4,0xFFFFFF);
		Filt.glow(scan, 2, 4, 0);

		var mc = sdm.attach("magnify_loupe",0);
		mc.x = size*0.5;
		mc.y = size*0.5;

		// CELL
		cells = new List();
		var dsi = Std.random(cellMax);
		for( i in 0...cellMax ){

			var mc:MagCell = cast ldm.attach("magnify_stain",0);
			mc.px = Std.random(xmax-1);
			mc.py = Std.random(ymax-1);
			mc.gotoAndStop(Std.random(mc.totalFrames)+1);
			mc.x = mc.px*ec;
			mc.y = mc.py*ec;
			mc.blendMode = flash.display.BlendMode.OVERLAY;
			mc.alpha = 0.5;
			mc.scaleX = mc.scaleY = ec;
			cells.push(mc);
			if(dsi==i){
				cell = ldm.attach("magnify_cell",0);
				cell.x = mc.x;
				cell.y = mc.y;
				cell.scaleX = cell.scaleY = ec*0.01;
				//cell.onPress = splash;
				cell.addEventListener(flash.events.MouseEvent.CLICK, splash);
				cell.gotoAndStop(mc.currentFrame);
				cell.visible = false;
			}
		}
		
		//
		px = Cs.mcw * 0.5;
		py = Cs.mch * 0.5;
		updateScan();


		//

		//text.dispose();
		//var txt = new flash.display.BitmapData();


	}

	override function update(){

		var mp = getMousePos();
		px = mp.x;
		py = mp.y;
		updateScan();

		var dx = px*zoom - (cell.x+getSmc(cell).x*ec*0.01);
		var dy = py*zoom - (cell.y+getSmc(cell).y*ec*0.01);
		cell.visible = Math.sqrt(dx*dx+dy*dy)<130;
		//cell.visible = true;

		super.update();
	}

	override function kill(){
		scan.bmp.dispose();
		text.dispose();
		super.kill();
	}

	function updateScan(){

		// MOVE
		var ma = size*0.5;
		//scan.x = Num.mm(0,px-ma,Cs.mcw-size);
		//scan.y = Num.mm(0,py-ma,Cs.mch-size);
		scan.x = px-ma;
		scan.y = py-ma;

		// SCAN
		var x = px*zoom;
		var y = py*zoom;

		var cz = 4;
		var sz = size*cz;
		//var cx = Num.mm( 0 ,x-sz*0.5, mcw-size );
		//var cy = Num.mm( 0 ,y-sz*0.5, mch-size );
		var cx = x-sz*0.5;
		var cy = y-sz*0.5;

		// SOURCE

		var source = new flash.display.BitmapData(sz,sz,false,0xFE7F7F);
		var m = new flash.geom.Matrix();
		m.translate( -Std.int(cx), -Std.int(cy) );
		source.draw(mcLvl,m);

		// DISPLACEMENT MAP
		var mc = dm.attach("magnify_displacementMap",0);
		mc.gotoAndStop(1);
		var dmap = new flash.display.BitmapData(size,size,false,0x0000FF);
		var m = new flash.geom.Matrix();
		m.scale(size*0.01,size*0.01);
		dmap.draw(mc,m);

		var fl = new flash.filters.DisplacementMapFilter(dmap);

		var mpx = Std.int((sz-size)*0.5);
		var mpy = Std.int((sz-size)*0.5);
		fl.mapPoint = new flash.geom.Point(mpx*1.0,mpy*1.0);
		//fl.mapPoint = new flash.geom.Point(10.0,10.0);
		var sc = 260;
		fl.componentX = 1;
		fl.componentY = 2;
		fl.scaleX = -sc;
		fl.scaleY = -sc;
		fl.mode = flash.filters.DisplacementMapFilterMode.COLOR;// "color";

		scan.bmp.applyFilter(source,source.rect,new flash.geom.Point(-mpx,-mpy),fl);

		dmap.dispose();
		source.dispose();
		mc.parent.removeChild(mc);

	}

	function splash(e){

		setWin(true,50);
		fxShake(8);
		var max = 30;
		var cr = 3;
		for( i in 0...max ){
			var a = Math.random()*6.28;
			var sp = Math.random()*12;
			var p = new Phys(ldm.attach("magnify_splash",1));
			p.vx = Math.cos(a)*sp;
			p.vy = Math.sin(a)*sp;
			p.x = cell.x+getSmc(cell).x*ec*0.01 + p.vx*cr;
			p.y = cell.y+getSmc(cell).y*ec*0.01 + p.vy*cr;
			p.root.gotoAndStop(Std.random(p.root.totalFrames)+1);
			getSmc(p.root).gotoAndPlay(Std.random(10)+1);
			p.setScale(0.5+Math.random()*2);
			p.vr = (Math.random()*2-1)*16;
			p.root.rotation = Math.random()*360;
			p.fr = 0.95;
			p.updatePos();
			Col.setPercentColor(p.root,0.5-(i/max)*0.5,0x440044);
			if( Math.abs(i/max-0.3)<0.2 )Col.setPercentColor(p.root,1,0xFF0000);

		}
		cell.parent.removeChild(cell);

	}

//{
}
















