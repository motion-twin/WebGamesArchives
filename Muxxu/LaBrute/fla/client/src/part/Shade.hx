package part;

import mt.bumdum.Lib;

class Shade extends Part{//}



	var f:Fighter;
	var col:Int;
	var col2:Int;
	var length:Int;

	var width:Int;
	var height:Int;

	var bmp:flash.display.BitmapData;

	public function new(f,col,col2,?length){



		var mc = Game.me.dm.empty(Game.DP_FIGHTERS);
		super(mc);

		if(length==null)length = 7;

		this.f = f;
		this.col = col;
		this.col2 = col2;
		this.length = length;




		// BMP
		width = Std.int(f.root._width);
		height = Std.int(f.root._height);
		bmp = new flash.display.BitmapData( width, height, true, 0x00FF0000 );
		var b = f.root.getBounds(f.root);
		var m = new flash.geom.Matrix();
		m.translate(-b.xMin,-b.yMin);
		bmp.draw(f.root,m);
		var mc = new mt.DepthManager(root).empty(0);
		mc.attachBitmap(bmp,0);
		mc._x = b.xMin;
		mc._y = b.yMin;


		// COLOR
		//var ct = new flash.geom.ColorTransform(1,1,1,1,-100,-100,150,0);
		//bmp.colorTransform(bmp.rectangle,ct);


		// POS
		x = f.x;
		y = f.y-0.5;
		z = f.z;
		updatePos();

		timer = length;
		//fadeLimit = 10;
		//fadeType = 4;


	}

	override function update(){
		super.update();


		var c = timer/length;
		var color = Col.mergeCol(col,col2,c);


		Col.setPercentColor(root,50,color);

		//root._visible = true;

	}

	override function kill(){
		bmp.dispose();
		super.kill();
	}



//{
}