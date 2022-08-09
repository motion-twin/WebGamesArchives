// 70%


import mt.bumdum.Lib;
class Ball {//}

	public static var FL_ROLL = true;
	public static var ANIM_COEF = 0.5;

	public var flInsert:Bool;
	public var flDeath:Bool;
	public var from:Float;

	public var x:Float;
	public var y:Float;
	public var vx:Float;
	public var vy:Float;

	var px:Int;
	var py:Int;

	public var root:flash.MovieClip;
	public var bmp:flash.display.BitmapData;



	public var pos:Float;
	public var flh:Float;

	public var col:mt.flash.Volatile<Int>;
	public var chain:Chain;

	public function new(?flGen){
		Game.me.balls.push(this);
		root = Game.me.bdm.attach("mcBall2",Game.DP_BALL);

		var mc = new mt.DepthManager(root.smc).empty(0);
		bmp = new flash.display.BitmapData(Cs.bray*2,Cs.bray*2,true,0);
		mc.attachBitmap(bmp,0);
		mc._x = -Cs.bray;
		mc._y = -Cs.bray;

		
		col = Std.random(Game.me.colorMax);
		#if !prod
		col = Std.random(2);
		#end
		
		if( flGen && Std.random(Game.me.black)==0 ){
			col = 4;
		}
		root.gotoAndStop(col+1);

		setTexture(0);

		//root.smc.smc.gotoAndStop(col+1);
		//Col.setColor(root,0,20);

	}

	public function setPos(c:Float,?flDirect:Bool){
		if(flDeath)trace("setDeadPos!");
		pos = c;
		var p = Cs.getPos(pos);
		if( flInsert){
			var c = Game.me.animCoef;
			var dx = p.x-x;
			var dy = p.y-y;
			x += dx*c;
			y += dy*c;
			flInsert = Math.abs(dx)+Math.abs(dy)>2;
		}else{

			x = p.x;
			y = p.y;
		}


		root.smc._rotation = (p.a+1.57)/0.0174;

		//root.smc.smc._x = (c*1500)%48 - 60;


		setTexture( Std.int((c*1350)%48) );


		updatePos();
		upgradeGridPos();
	}
	function setTexture(fr){
		bmp.copyPixels(Game.me.gfxTable[col][fr], bmp.rectangle, new flash.geom.Point(0,0));
	}

	public function updatePos(){
		root._x = x;
		root._y = y;
	}

	// FLYING
	public function update(){
		//trace(Std.random(8));



		x += vx*mt.Timer.tmod;
		y += vy*mt.Timer.tmod;
		upgradeGridPos();
		var a = Game.me.bgrid[px][py];
		var ball = null;
		var dist = 99.0;
		for( b in a ){
			if(b.chain!=null){
				if(b.flDeath){

				}else{
					var dx = b.x - x;
					var dy = b.y - y;
					var d = Math.sqrt(dx*dx+dy*dy);
					if( d < Cs.bray*2 ){
						if( d<dist || ball == null ){
							ball = b;
							dist = d;
						}
					}
				}
			}
		}
		if( ball != null ){
			if(from==null || Math.abs(from-ball.pos)>0.1 ){
				ball.chain.insert(this,ball);



				fxInsert( (x+ball.x)*0.5,  (y+ball.y)*0.5 );
			}
		}
		updatePos();

		//PARTS
		fxDust();




		//
		if( Cs.isOut(x,y,-Cs.bray) ){
			if( col == 4 ){
				KKApi.addScore(Cs.SCORE_BLACK);
				fxSideBurst();
			}
			kill();
		}


	}
	public function getLauncherAngle(){
		var dx = Cs.SPX - x;
		var dy = Cs.SPY - y;
		return Math.atan2(dy,dx);


	}

	// MAJ
	public function maj(){

		if( flh!=null ){

			var c = flh;
			flh*=0.9;
			if(flh<0.01){
				flh = null;
				c = 0;
			}
			Col.setColor(root,0,Std.int(c*255));

			root.filters = [];
			if(c>0){
				Filt.glow(root,12*c,1+2*c,0xFFFFFF);
			}


			/*
			if(Math.random()<c){
				var p = new mt.bumdum.Phys( Game.me.dm.attach("fxSpark",Game.DP_FX) );
				p.x = x+(Math.random()*2-1)*Cs.bray;
				p.y = y+(Math.random()*2-1)*Cs.bray;
				p.timer = 10+Math.random()*30;
				p.setScale(40+Math.random()*60);
				p.updatePos();
			}
			*/

		}



	}



	// GRID
	function upgradeGridPos(){
		var npx = Cs.getPX(x);
		var npy = Cs.getPY(y);
		if( npx!=px || npy!=py ){
			removeFromGrid();
			px = npx;
			py = npy;
			insertInGrid();
		}
	}
	function insertInGrid(){
		for( x in 0...3 ){
			for( y in 0...3 ){
				var gx = px+x-1;
				var gy = py+y-1;
				Game.me.bgrid[gx][gy].push(this);
			}
		}
	}
	function removeFromGrid(){
		for( x in 0...3 ){
			for( y in 0...3 ){
				var gx = px+x-1;
				var gy = py+y-1;
				Game.me.bgrid[gx][gy].remove(this);
			}
		}
	}

	// FX
	public function fxLink(b:Ball){
		if( b.pos==null || pos ==null )return;



		var mc = Game.me.mcMagnet;
		mc.lineStyle(1,0xFFFFFF,100);


		var run = pos;
		var ec = 0.01;
		var size = 6;


		var to = 0;
		var a = [];

		var lineMax = 2;


		while(true){
			run = Math.min(run+ec,b.pos);

			var p = Cs.getPos(run);
			if(run<b.pos){
				var lst = [];
				for( i in 0...lineMax ){
					lst.push({
						x : p.x + (Math.random()*2-1)*size,
						y : p.y + (Math.random()*2-1)*size,

					});
				}
				a.push(lst);
				//p.x += (Math.random()*2-1)*size;
				//p.y += (Math.random()*2-1)*size;

			}


			//mc.lineTo(p.x,p.y);

			if(to++>500){

				trace("INFINITE LOOP");
				trace(flDeath+";"+b.flDeath);
				trace(pos+";"+b.pos);
				trace(run);
				break;
			}


			if(run==b.pos)break;
		}

		for( i in 0...2 ){
			mc.lineStyle(0.2+i*1.3,0xFFFFFF,100);
			mc.moveTo(x,y);
			for( lst in a ){
				var p = lst[i];
				mc.lineTo(p.x,p.y);
			}
		}




		//mc.moveTo(x,y);
		//mc.lineTo(b.x,b.y);







	}
	function fxInsert(px,py){
		var max = 12;
		for( i in 0...max ){
			var a =  i/max * 6.28;
			var sp = Math.random()*3;
			var cr = 5;
			var ca = Math.cos(a)*sp;
			var sa = Math.sin(a)*sp;
			var p = fxPart();
			p.x = px + ca*cr;
			p.y = py + sa*cr;
			p.vx = ca;
			p.vy = sa;

		}
	}
	function fxDust(){
		var p = fxPart();
		p.x = x + (Math.random()*2-1)*10;
		p.y = y + (Math.random()*2-1)*10;
		p.vx = vx*Math.random()*0.5;
		p.vy = vy*Math.random()*0.5;
	}
	function fxSideBurst(){

		var dx = Cs.mcw*0.5 - x;
		var dy = Cs.mch*0.5 - y;
		var a = Math.atan2(dy,dx);

		//
		var mc = Game.me.dm.attach("mcSideBurst",Game.DP_FX);
		mc._x = x;
		mc._y = y;
		mc._rotation = a/0.0174 + 90;



		// PARTS
		var dec = 12;
		for( i in 0...36 ){
			var sp = 1.5+Math.random()*4;
			var p = fxPart();
			p.x = x + (Math.random()*2-1)*dec;
			p.y = y + (Math.random()*2-1)*dec;
			p.vx = Math.cos(a)*sp;
			p.vy = Math.sin(a)*sp;


		}
	}
	function fxPart(){
		var p = new mt.bumdum.Phys(Game.me.dm.attach("fxSpark",Game.DP_FX));
		p.timer = 10+Math.random()*10;
		p.fadeType = 0;
		p.root.gotoAndPlay(Std.random(p.root._totalframes)+1);
		p.root.blendMode = "overlay";
		Filt.glow(p.root,10,2,0xFFFFFF);
		return p;
	}



	public function incFlash(inc:Float){

		if(flh==null)flh = 0;
		flh = Math.min(flh+inc,1);
		Col.setColor(root,0,Std.int(flh*255));
		if(flh>0.5)flInsert = false;
	}

	//
	public function getIndex(){
		var id = 0;
		for( ball in chain.list ){
			if( ball == this )return id;
			id++;
		}
		return null;
	}

	//
	public function explode(){

		// ONDE
		var mc = Game.me.dm.attach("mcOnde",Game.DP_FX);
		mc._x = x;
		mc._y = y;

		// EXPLODE
		var mc = Game.me.dm.attach("fxExplode",Game.DP_FX);
		mc._x = x;
		mc._y = y;
		mc._rotation = Std.random(360);
		mc.blendMode ="add";
		Filt.glow(mc,4,1,0xFFFFFF);
		mc._xscale= mc._yscale = 120;
		mc._rotation = Math.random()*360;
		//mc.blendMode = "overlay";




		var max = 8;
		var cr = 3;
		for( i in 0...max ){
			var speed = Math.random()*2;
			var a = i/max * 6.28;
			var ca = Math.cos(a)*speed;
			var sa = Math.sin(a)*speed;
			var p = new mt.bumdum.Phys(Game.me.dm.attach("partEclat",Game.DP_FX));
			p.x = x+ca*cr*speed;
			p.y = y+sa*cr*speed;
			p.vx = ca*speed;
			p.vy = sa*speed;
			p.timer = 10+Math.random()*14;
			p.setScale(50+Math.random()*50);
			p.root._rotation = Math.random()*360;
			p.root.smc._xscale = 50+Math.random()*100;
			p.root.smc._yscale = 50+Math.random()*100;
			p.root.gotoAndPlay(Std.random(p.root._totalframes)+1);
			p.vr = (Math.random()*2-1)*25;
			p.frict = 0.95;
			p.fadeType = 0;
			var colors = Cs.COLORS;
			if( i/max < 0.5 ) colors =  Cs.COLORS_DARK;
			Col.setColor( p.root.smc, colors[col] );
			p.updatePos();

			//trace(p.root._visible);
		}


		kill();
	}
	public function collapse(){
		explode();
	}

	//
	public function unchain(){
		chain.list.remove(this);
		removeFromGrid();
		chain = null;
		pos = null;
	}
	public function kill(){
		flDeath = true;
		root.removeMovieClip();
		Game.me.shots.remove(this);
		Game.me.balls.remove(this);
		unchain();




	}






//{
}











