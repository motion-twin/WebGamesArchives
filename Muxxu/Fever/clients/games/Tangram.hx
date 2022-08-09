import mt.bumdum9.Lib;

class Tangram extends Game{//}
	
	static var TRACKS = [
		[8,9,10,11],
		[0,1,12,13,14,15],
		[2,3,8,9,14,15],
		[0,1,2,3,8,9],
		[4,5,6,7,12,13,14,15],
		[0, 1, 6, 7],
		
		[2, 3, 4, 5, 12, 13, 14, 15],
		[10, 11, 12, 13],
		[9,10,16,17,22,23],
		[18, 19, 20, 21],
		[10, 14, 20, 21],
		[9, 10, 13, 14],
		
		[8,9,10,11,21,22],
		[12,13,14,15],
		[2, 3, 8, 9],
		[0, 1, 2, 3, 17, 18],
		[0, 1, 4, 5, 6, 7],
		[0, 1, 6, 7, 12, 13, 14],
		
		[2,3,4,5,18,19,20,21],
		[6, 7, 12, 13, 14, 9, 10, 11],
		[9,10,13,22,23],
		[21,23,23,16],
		[10,11,14,15,20,21],
		[9,10,18,22],
		
	];

	static var ECART = 90;
	static var PAL_MAX = 12;
	
	var rot:Int;
	var elMax:Int;
	var soluce:Array<Int>;
	var pal:Array<McTangramPal>;
	var model:flash.display.MovieClip;
	var playground:Array<McTangramPal>;
	var mbg:McColorsBg;
	var picA:flash.display.Sprite;
	var picB:flash.display.Sprite;

	override function init(dif:Float){
		gameTime =  600-250*dif;
		super.init(dif);
		elMax = 2 + Math.round(dif * 2);
		rot = Std.random(4)*90;
		attachElements();
		
		/*
		var b = [];
		for( i in 0...26 ) b.push(0);
		for( a in TRACKS ) for( n in a ) b[n]++;
		var str = "";
		var id = 0;
		for( n in b ) {
			str += "[" + id + "] = " + n+"\n";
			id++;
		}
		trace(str);
		*/
		
	}

	function attachElements(){
		mbg = new McColorsBg();
		addChild(mbg);
		
		
		
		// Pallette
		var margin = 10;
		var ec = 64;
		var a = [];
		for( i in 0...PAL_MAX ) {
			var n = i;
			if( Std.random( Std.int(12-dif*10) ) == 0 ) n += 12;
			a.push(n);
		}
		Arr.shuffle(a);
		var me = this;
		pal = [];
		for( i in 0...PAL_MAX ) {
			var mc = new McTangramPal();//dm.attach("mcColorsPalette", 0);
			addChild(mc);
			mc.x = 38+(i % 6) * ec;
			mc.y = Cs.mch - (40 + Std.int(i / 6) * (ec));
			mc.scaleX = mc.scaleY = 0.85;
			var id = a[i];
			mc.gotoAndStop(id+ 1);
			mc.addEventListener(flash.events.MouseEvent.CLICK, function(e) { me.select(id); } );
			mc.tabIndex = 0;
			mc.rotation = rot;
			pal.push(mc);

		}
		
		// PICTURES
		picA = new flash.display.Sprite();
		picB = new flash.display.Sprite();
		addChild(picA);
		addChild(picB);
		picA.x = Cs.mcw*0.5-ECART;
		picA.y = 100;
		picB.x = Cs.mcw*0.5+ECART;
		picB.y = 100;
		picA.rotation = rot;
		picB.rotation = rot;
		
		// MODEL
		soluce = [];
		for( i in 0...24 ) soluce.push(0);
		Arr.shuffle(a);
		for( i in 0...elMax ) {
			var model = new McTangramPal();
			picA.addChild(model);
			model.gotoAndStop(a[i]+1);
			model.scaleX = model.scaleY = 2.2;
			var b = TRACKS[a[i]];
			for( n in b ) soluce[n] = 1;
		}
		
		// RESULT
		
		playground = [];

		//
		majCounter();
		
	}
	
	//
	var coef:Float;
	override function update(){

		// CONTROL
		switch(step){
			case 1:

			case 2:
				coef = Math.min(coef + 0.1, 1);
				var c = Math.pow(coef,2);
				picA.x = Cs.mcw*0.5 - ECART * (1 - c);
				picB.x = Cs.mcw*0.5 + ECART * (1 - c);
				/*
				var ax = 40;
				var bx = 230;
				var tx = 135;
				picA.x = ax * (1 - c) + tx * c;
				picB.x = bx * (1 - c) + tx * c;
				*/
				if( coef == 1 ) {
					new mt.fx.Flash(this);
					step = 3;
					coef = 0;
				}
			case 3:
				coef = Math.min(coef + 0.06, 1);
				var c = 1 - coef;
				picB.filters = [ new flash.filters.GlowFilter(0xFFFFFF, 1, c * 16, c * 16, c * 8) ];
				if( coef == 1) step++;
				Col.setColor(picB,0,Std.int(c*100));
				

		}

		super.update();
	}
	//
	function select(id:Int) {
		var pal = getPal(id);
		if( pal.tabIndex == 0 ) {
		
			if( playground.length == elMax ) {
				new mt.fx.Flash(mbg, 0.15,0xFF0000);
				return;
			}
			pal.tabIndex = 1;
			pal.alpha = 0.2;
			var mc = new McTangramPal();
			mc.scaleX = mc.scaleY = 2.2;
			mc.gotoAndStop(id + 1);
			playground.push(mc);
			picB.addChild(mc);
			
		}else {
			pal.tabIndex = 0;
			pal.alpha = 1;
			var mc = getFrame(id);
			picB.removeChild(mc);
			playground.remove(mc);
			
		}
		majCounter();
		checkWin();
		
	}
	function majCounter() {
		
		mbg.t1.text = Std.string(playground.length);
		mbg.t2.text = Std.string(elMax);
	}
	function checkWin() {
		
		var mask = [];
		for( i in 0...24 ) mask.push(0);
		for( mc in playground ) {
			var b = TRACKS[mc.currentFrame-1];
			for( n in b ) mask[n] = 1;
		}
		
		for( i in 0...24 ) if( mask[i] != soluce[i] ) return;
		
		setWin(true, 30);
		for( mc in pal ) mc.mouseEnabled = false;
		step = 2;
		coef = 0 ;
	}
	
	
	function getPal(id) {
		for( mc in pal ) if(mc.currentFrame-1 == id ) return mc;
		return null;
	}
	function getFrame(id) {
		for( mc in playground ) if(mc.currentFrame-1 == id ) return mc;
		return null;
	}



//{
}

