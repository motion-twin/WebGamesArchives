import mt.bumdum9.Lib;

typedef SScanStar = {>flash.display.MovieClip,c:Float};


class SpaceScan extends Game{//}

	static var MCW = 1600;
	static var MCH = 1600;

	var mmax:Int;
	var min:Int;
	var msize:Int;

	var px:Float;
	var py:Float;
	var vx:Float;
	var vy:Float;
	var a:Float;

	var rnb:Null<Float>;
	var color:Int;

	var parts:List<Phys>;
	var stars:List<SScanStar>;
	var objects:List<Sprite>;
	var minerals:List<Sprite>;
	var ship:flash.display.MovieClip;
	var score:{>flash.display.MovieClip,_score:Int};
	var scan:{>flash.display.MovieClip,bmp:flash.display.BitmapData};

	var sco:Int;

	override function init(dif:Float){
		gameTime =  600-100*dif;
		super.init(dif);
		objects = new List();
		parts = new List();
		mmax = 1+Std.int(dif*7);
		min = 0;
		msize = Math.ceil(100/mmax);
		attachElements();
		
	}

	function attachElements(){

		dm.attach("spaceScan_bg",0);

		// SHIP
		ship = dm.attach("spaceScan_ship",1);
		ship.x = Cs.mcw*0.5;
		ship.y = Cs.mch*0.5;
		px = MCW*0.5;
		py = MCH*0.5;
		vx = 0;
		vy = 0;
		a = 0;

		// STARS
		stars = new List();
		var max = 200;
		for( i in 0...max ){
			var c = Math.pow(i/max,2)*0.5;
			var mc:SScanStar = cast dm.attach("spaceScan_star",0);
			mc.x = Math.random()*Cs.mcw;
			mc.y = Math.random()*Cs.mch;
			mc.scaleX = mc.scaleY = 0.5+c;
			mc.c = c;
			stars.push(mc);
		}

		// MINERALS

		minerals = new List();
		for( i in 0...mmax ){
			var sp = newSprite("spaceScan_mineral");
			sp.x = Math.random()*MCW;
			sp.y = Math.random()*MCH;
			sp.setScale(0.8+msize*0.01);
			objects.push(sp);
			minerals.push(sp);

		}

		// SCAN
		scan = cast dm.attach("spaceScan_scan",3);
		scan.x = Cs.mcw-104;
		scan.y = Cs.mch-104;
		scan.bmp = new flash.display.BitmapData(50, 50, true, 0);
		var mc = new flash.display.Bitmap();
		mc.bitmapData = scan.bmp;
		scan.addChild(mc);
		//scan.attachBitmap(scan.bmp,0);
		scan.scaleX = scan.scaleY = 2;
		
		
		
		//scan.blendMode = flash.display.blendMode.ADD;

		// SCORE
		score = cast dm.attach("spaceScan_digital",3);
		score.x = Cs.mcw*0.5;
		score.y = Cs.mch*0.5-30;
		field = cast(getMc(score, "field")).field;
		field.text = "0";
		sco = 0;
	


	}
	var	field:flash.text.TextField;

	override function update(){

		if( rnb == null )rnb = 0.0;
		rnb = Num.sMod(rnb+0.05,1);
		//var c = Col.getRainbow(rnb);
		//color = Col.objToCol32({r:c.r,g:c.g,b:c.b,a:255});
		var n = Std.int(255*rnb);
		color = Col.objToCol32({r:n,g:255,b:n,a:255});

		move();
		scroll();
		updateMinerals();
		super.update();
		updatePos();
		updateScan();
	}

	function move() {
		var mp = getMousePos();
		var dx = mp.x - Cs.mcw*0.5;
		var dy = mp.y - Cs.mch*0.5;
		var da = Num.hMod( Math.atan2(dy,dx)-a, 3.14);
		var lim = 1;
		a += Num.mm(-lim,da*0.5,lim);

		ship.rotation = a/0.0174;

		getSmc(ship).visible = click;

		if( click ){
			var acc = 0.8;
			vx += Math.cos(a)*acc;
			vy += Math.sin(a)*acc;
		}


	}
	function scroll(){

		var fr = 0.99;
		vx*=fr;
		vy*=fr;
		px += vx;
		py += vy;


		// STARS
		var ma = 10;
		var lim = Cs.mcw+2*ma;
		for( mc in stars ){
			mc.x-=vx*mc.c;
			mc.y-=vy*mc.c;
			if( mc.x < -ma ) 	mc.x += lim;
			if( mc.x > Cs.mcw+ma ) mc.x -= lim;
			if( mc.y < -ma ) 	mc.y += lim;
			if( mc.y > Cs.mcw+ma ) mc.y -= lim;
		}

	}
	function updatePos(){
		for(sp in objects){
			var dx = Num.hMod(sp.x - px,MCW*0.5);
			var dy = Num.hMod(sp.y - py,MCH*0.5);
			sp.root.x = Cs.mcw*0.5+dx;
			sp.root.y = Cs.mch*0.5+dy;
			if(sp.root.visible!=true)objects.remove(sp);
		}



	}

	function updateMinerals(){
		for(sp in minerals ){
			// GLOW
			var c = 0.5+Math.cos(rnb*6.28)+0.5;
			sp.root.filters = [];
			Filt.glow(sp.root,2,4,0xFFFFFF);
			Filt.glow(sp.root,4+c*10,0.5+c*0.5,0xFFFFFF);

			// COL
			var dx = Num.hMod(sp.x-px,MCW*0.5);
			var dy = Num.hMod(sp.y-py,MCH*0.5);
			if( Math.sqrt(dx*dx+dy*dy)<50 ){
				var cr = 3;
				for( i in 0...msize ){
					var speed = 3+Math.random()*12+(msize*0.2);
					var a = i/msize*6.28;
					var p = newPhys("spaceScan_part");
					p.vx = Math.cos(a)*speed;
					p.vy = Math.sin(a)*speed;
					p.x = sp.x+p.vx*cr;
					p.y = sp.y+p.vy*cr;
					p.frict = 0.98;
					p.vr = (Math.random()*2-1)*8;
					p.root.gotoAndStop(Std.random(p.root.totalFrames)+1);
					cast(p).cheat = 0;
					objects.push(p);
					parts.push(p);
				}

				sp.kill();
				objects.remove(sp);
				minerals.remove(sp);
			}
		}

		var acc = 2;
		for( sp in parts ){
			var dx = Num.hMod( px-sp.x, MCW*0.5);
			var dy = Num.hMod( py-sp.y, MCH*0.5);
			var a = Math.atan2(dy,dx);
			sp.vx += Math.cos(a)*acc;
			sp.vy += Math.sin(a)*acc;

			if( Math.sqrt(dx*dx+dy*dy)<26 ){
				if( sco < 100 ) sco++;
				score.gotoAndPlay(2);
				if(sco >= 100 ) setWin(true,20);
				field.text = Std.string(sco);
				new mt.fx.Flash(ship,0.2);
				sp.kill();
				objects.remove(sp);
				parts.remove(sp);
			}

			var ch = cast(sp).cheat;
			cast(sp).cheat =  Math.min(ch+0.002,1);
			sp.x += dx*ch;
			sp.y += dy*ch;


			var ec = 5;
			if( Std.random(3)==0 && Sprite.LIST.length<200 ){
				var p = newPhys("pixiz_twinkle");
				p.root.gotoAndPlay(Std.random(p.root.totalFrames)+1);
				p.x = sp.x+(Math.random()*2-1)*ec;
				p.y = sp.y+(Math.random()*2-1)*ec;
				p.vx = sp.vx*0.5;
				p.vy = sp.vy*0.5;
				p.timer = 20;
				objects.push(p);
			}


		}

	}
	function updateScan(){
		//scan.bmp.fillRect(scan.bmp.rectangle,0);

		var co = new flash.geom.ColorTransform(1,1,1,1,-50,-10,-50,-20);
		scan.bmp.colorTransform(scan.bmp.rect,co);


		//scan.bmp.applyFilter(scan.bmp,scan.bmp.rectangle,new flash.geom.Point(0,0),fl);


		var cn = 25;
		var scx = 50/MCW;
		var scy = 50/MCH;



		var bmp = new flash.display.BitmapData(50,50,true,0);
		bmp.setPixel32(cn,cn,0xFFFF0000);
		for( sp in minerals ){
			var x = Std.int(cn+Num.hMod((sp.x-px),MCW*0.5)*scx);
			var y = Std.int(cn+Num.hMod((sp.y-py),MCH*0.5)*scy);
			//bmp.setPixel32(x,y,0xFFBBFFBB);
			bmp.setPixel32(x,y,color);

		}
		for( sp in parts ){
			var x = Std.int(cn+Num.hMod((sp.x-px),MCW*0.5)*scx);
			var y = Std.int(cn+Num.hMod((sp.y-py),MCH*0.5)*scy);
			bmp.setPixel32(x,y,0x5000FF00);
		}


		scan.bmp.draw(bmp);
		bmp.dispose();


	}

//{
}

















