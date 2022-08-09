import mt.bumdum9.Lib;


typedef IWheel = { > flash.display.MovieClip, a:Float, va:Float, ray:Float, neon:flash.display.MovieClip, cd:Null<Int> };

class Interwheel extends Game{//}

	static var DIST_MIN = 30;
	static var DIST_MAX = 150;
	static var JUMP = 10;

	var speed:Float;
	var wmax:Int;
	var light:mt.flash.Volatile<Int>;
	var wheels:List<IWheel>;
	var blob:{>Phys,wh:IWheel,a:Float,blop:Float};

	override function init(dif:Float){
		gameTime =  500-100*dif;
		super.init(dif);
		speed = 0.04+dif*0.1;
		wmax = 3+Std.int(dif*5);
		light = 0;

		attachElements();

	}

	function attachElements(){


		bg = dm.attach("interwheel_bg",0);

		// BG
		var bmp = new flash.display.BitmapData(Cs.mcw,Cs.mch);
		bg.addChild(new flash.display.Bitmap(bmp));//attachBitmap(bmp,0);
		var mc = dm.attach("interwheel_tile",0);
		for( x in 0...10 ){
			for( y in 0...10 ){
				var m = new flash.geom.Matrix();
				m.translate(x*40,y*40);
				mc.gotoAndStop(Std.random(mc.totalFrames)+1);
				bmp.draw(mc,m);
			}
		}

		// WHEELS
		var whb = 35-dif*10;
		var to = 0;
		wheels = new List();
		while( wheels.length<wmax ){

			var bs = Math.max(15,whb-(to*0.1));
			var ray = bs+Math.random()*bs;
			var ma = ray+8;
			var x = ma+Math.random()*(Cs.mcw-ma*2);
			var y = ma+Math.random()*(Cs.mch-ma*2);

			var flOk = wheels.length==0;

			for( wh in wheels ){
				var dx = x-wh.x;
				var dy = y-wh.y;
				var dist = Math.sqrt(dx*dx+dy*dy)-(ray+wh.ray);
				if( dist< DIST_MIN ){
					flOk = false;
					break;
				}
				if( dist < DIST_MAX )flOk = true;

			}

			var fl = new flash.filters.DropShadowFilter();
			fl.blurX = 2;
			fl.blurY = 2;
			fl.color = 0;
			fl.strength = 0.2;
			fl.distance = 5;

			if( flOk ){
				var mc:IWheel = cast dm.attach("interwheel_wheel",2);
				mc.x = x;
				mc.y = y;
				mc.ray = ray;
				mc.scaleX = mc.scaleY = ray*0.02;
				mc.va = speed + Math.random()*speed;
				mc.a = Math.random()*6.28;
				mc.gotoAndStop(Std.random(4)+1);
				wheels.push(mc);
				mc.filters = [fl];

				mc.neon = dm.attach("interwheel_neon",1);
				var mcl = dm.attach("interwheel_wheel_light",2);
				var mcd = dm.attach("interwheel_dust",1);
				mcl.gotoAndStop(mc.currentFrame);
				mc.neon.gotoAndPlay(Std.random(mc.totalFrames)+1);
				mc.neon.visible = false;
				Col.setColor(mc.neon,Col.getRainbow(wheels.length/wmax));

				var a = [mc.neon, mcl, mcd ];
				for( mmc in a ){
					mmc.x = x;
					mmc.y = y;
					mmc.scaleX = mmc.scaleY = mc.scaleX;
				}




			}
			if( to++ > 300 ){
				trace("echec");
				break;
			}

		}

		// BLOB
		blob = cast new Phys(dm.attach("interwheel_blob",1));
		grabWheel(wheels.last());
		updateBlob();


	}

	override function update(){
		updateWheels();
		updateBlob();
		super.update();
	}

	function updateWheels(){
		for( wh in wheels ) {
			if( wh.cd != null && wh.cd-- <= 0 ) wh.cd = null;
			wh.a = Num.hMod(wh.a+wh.va,3.14);
			wh.rotation = wh.a / 0.0174;
		}

	}

	function updateBlob(){

		if( blob.wh != null ){
			var wh = blob.wh;
			var a = Num.hMod(blob.a + wh.a, 3.14);
			blob.x = wh.x + Math.cos(a)*wh.ray;
			blob.y = wh.y + Math.sin(a)*wh.ray;
			blob.root.rotation = a/0.0174;
			blob.updatePos();
		}else{
			// BLOP
			blob.blop = Math.max(0.07,blob.blop*0.94);
			if(Math.random()<blob.blop){
				var p = newPart();
				var fr = 0.4+Math.random()*0.4;
				p.x += (Math.random()*2-1)*3;
				p.y += (Math.random()*2-1)*3;
				p.vx = blob.vx*fr;
				p.vy = blob.vy*fr;
				p.setScale( 0.5+Math.random()*0.5 + blob.blop*0.5 );
				p.weight = 0.2+Math.random()*0.2;
			}

			// ORIENT
			var a = Math.atan2(blob.vy,blob.vx)+3.14;
			var c = Num.sMod(a,6.28)/6.28;
			blob.root.gotoAndStop(60+Std.int(c*40));

			// SEEK WHEEL
			for( wh in wheels ){
				var dx = wh.x - blob.x;
				var dy = wh.y - blob.y;
				if( Math.sqrt(dx*dx+dy*dy) < wh.ray+5 ){
					grabWheel(wh);
					break;
				}
			}

			// BOUNDS
			var ma = -20;
			if( blob.x<ma || blob.x>Cs.mcw-ma*2 || blob.y>Cs.mch-ma*2 ) setWin(false);

		}
	}

	override function onClick(){
		if( blob.wh == null || win )return;

		blob.wh.cd = 5;
		var a = Num.hMod(blob.a + blob.wh.a, 3.14);

		// PARTS
		var max = 4;
		for( i in 0...max ){
			var dec = Math.random()*2-1;
			var na = blob.a + dec*0.8;
			var sp = 8-Math.abs(dec)*6;
			var c = i/max;
			var p = newPart();
			p.vx = Math.cos(na)*sp;
			p.vy = Math.sin(na)*sp;
			p.setScale(0.5+c);
			p.timer = 10 + Std.random(30);
			p.weight = 0.2+c*0.2;

		}

		// A
		blob.wh = null;
		blob.weight = 0.35;
		blob.vx = Math.cos(a)*JUMP;
		blob.vy = Math.sin(a)*JUMP;
		blob.root.rotation = 0;

		blob.blop = 1;


	}

	function newPart(){
		var p = new Phys( dm.attach("interwheel_oil",2 ));
		p.x = blob.x;
		p.y = blob.y;
		p.timer = 10 + Std.random(10);
		p.fadeType = 0;
		return p;
	}

	function grabWheel(wh:IWheel) {
		if( wh.cd != null ) return;
		var dx = wh.x - blob.x;
		var dy = wh.y - blob.y;

		var pa = Math.atan2(dy,dx)+3.14;
		blob.wh = wh;
		blob.a = Num.hMod(pa-wh.a,3.14);
		blob.weight = 0;
		blob.vx = 0;
		blob.vy = 0;
		blob.root.gotoAndPlay("grab");

		if(wh.neon.visible)return;
		wh.filters = [];
		wh.neon.visible = true;
		light++;
		if(light==wmax)setWin(true,20);
		//fxFlash(wh);

	}

//{
}








