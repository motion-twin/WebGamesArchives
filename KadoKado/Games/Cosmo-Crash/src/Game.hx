import KKApi;
import mt.bumdum.Lib;

typedef Star = {>flash.MovieClip,c:Float,x:Float,y:Float};

class Game {//}


	public static var DP_FX = 	14;

	public static var DP_FOLK = 	13;
	public static var DP_GROUND = 	12;
	public static var DP_SHUTTLE = 	10;

	public static var DP_VEHICULE = 8;
	public static var DP_HERO = 	6;
	public static var DP_PLAT = 	4;

	public static var DP_UNDER_FX =	2;

	public static var DP_BG = 	0;

	public var focus:Element;

	public var dif:mt.flash.Volatile<Float>;
	var scrx:Float;
	var scry:Float;

	public var flRescue:Bool;

	public var fuel:mt.flash.Volatile<Float>;
	public var glow:Float;
	public var endTimer:Int;
	public var learnTimer:Int;
	public var step:Int;
	public var opt:Int;
	public var lag:Int;
	public var seed:mt.Rand;

	public var hero:Hero;
	public var top:Array<Int>;
	public var elements:Array<Element>;
	public var plats:Array<Plat>;
	public var starField:Array<Star>;
	public var groundField:Array<Star>;
	public var sgrid:Array<Array<Array<Shot>>>;

	public var vehicules:mt.flash.PArray<Vehicule>;
	public var folks:mt.flash.PArray<Folk>;


	public static var me:Game;
	public var mdm:mt.DepthManager;
	public var dm:mt.DepthManager;
	public var root:flash.MovieClip;
	public var bg:flash.MovieClip;
	public var gyro:{>flash.MovieClip, stab:flash.MovieClip, vector:flash.MovieClip, inf:flash.MovieClip };

	var bmpLevel:flash.display.BitmapData;
	var bmpScreen:flash.display.BitmapData;
	public var map:flash.MovieClip;
	public var mcHor:flash.MovieClip;

	// DEBUG
	public var bmpGrid:flash.display.BitmapData;
	public var marks:Array<flash.MovieClip>;



	public function new( mc : flash.MovieClip ){

		haxe.Log.setColor(0xFFFFFF);
		Cs.init();
		root = mc;
		me = this;
		mdm = new mt.DepthManager(root);


		var bg = mdm.empty(0);
		var bmp = new flash.display.BitmapData(10,10,false,0);
		var mc = mdm.attach("mcBg",0);
		bmp.draw(mc);
		mc.removeMovieClip();
		bg._xscale = bg._yscale = 3000;
		bg.attachBitmap(bmp,0);

		flRescue = true;

		opt=0;
		lag=0;


		initScreen();
		initMap();

		elements = [];
		vehicules = new mt.flash.PArray();
		folks = new mt.flash.PArray();

		initStarField();
		initGrid();
		initInter();


		hero = new Hero();

		learnTimer = 600;
		step  =0;

		fuel = 100;
		dif = 0;

		for( i in 0...12 ) new Folk();
		//for( i in 0...10 ) new Jeep();

		initHor();



		/*
		for( i in 0...800 ){
			var mc = dm.attach("mcTest",0);
			mc._x = Std.random(Cs.lw);
			mc._y = Std.random(Cs.mch);
			mc._xscale = mc._yscale = 10+Std.random(10);
		}

		//*/
	}

	function initMap(){



		map = mdm.empty(0);
		dm = new mt.DepthManager(map);

		genLevel();


		//
		map._visible = false;




	}
	function initGrid(){
		sgrid = [];
		for( x in  0...Cs.XMAX ){
			sgrid[x] = [];
			for( y in  0...Cs.YMAX ){
				sgrid[x][y] = [];
			}
		}
	}

	public function update(){
		//haxe.Log.clear();
		//trace(vehicules.length);
		//trace(dif);
		//mx = (mx+10)%Cs.lw;


		if(learnTimer>0)learnTimer--;
		switch( step ){
			case 0:
				if(!flRescue)updateDif();
			case 1:
				updateSpawn();
		}


		if(endTimer!=null && endTimer--==0){
			KKApi.gameOver({});
		}


		optimize();
		updateSprites();
		updateInter();
		updateHor();
		display();

		//viewGrid(cast sgrid);
	}
	function updateSprites(){
		var a = elements.copy();//mt.bumdum.Sprite.spriteList.copy();
		for( sp in a )sp.update();
	}

	// DIF
	public function updateDif(){
		if(hero==null)return;
		dif++;
		var vmax = dif*0.0018 - 2;
		//haxe.Log.clear();
		//trace( dif );
		//trace( Std.int(vmax) );
		if( vehicules.length < vmax ){
			new Vehicule();
		}
		if( Std.random(200)==0 ){
			var sum = 0;
			for( f in folks )if(f.step==1)sum++;
			for( i in sum...Std.int(12+vmax*2) ){
				var f = new Folk();
				f.x = getFarAwayX();
			}


		}




	}

	// LEVEL
	function genLevel(){

		seed = new mt.Rand(0);

		bmpLevel = new flash.display.BitmapData(Cs.lw,Cs.lh,true,0);
		var bg = dm.empty(DP_GROUND);
		bg.attachBitmap(bmpLevel,0);


		//
		genTop();


		// PLATS
		var ec  =8;
		plats = [];
		var to = 0;
		var m = 150;
		for( i in 0...3 ){
			while( true ){
				var x = m+seed.random(Cs.lw-2*m);
				var flAdd  = true;
				for( pl in plats )if( Math.abs(pl.x-x) < 300 )flAdd = false;
				if( flAdd ){
					var px = Std.int(x/Cs.PW);
					var ly = Math.max( top[px] , top[(px+1)%Cs.PMAX] );
					var y = Cs.lh - Std.int(ly*ec + 50 + seed.rand()*50 );
					var p = new Plat(x,y,25+i*25);
					p.skin.rampe.shuttle.gotoAndStop("bat");
					break;
				}
				if(to++>100){
					trace("ERROR = GEN PLATS");
					break;
				}
			}
		}


		// ROCHER
		var brush = dm.attach("mcRocher",0);
		for( i in 0...Cs.PMAX ){
			var rmax = seed.random(3);
			for( ni in 0...rmax ){
				var x = seed.random(Cs.PW)+i*Cs.PW;
				var gr = this.getGround(x);
				var y = gr.y;
				var m = new flash.geom.Matrix();
				m.rotate(seed.random(8)*45);
				m.translate(Std.int(x),Std.int(y));
				brush.gotoAndStop(seed.random(brush._totalframes)+1);
				bmpLevel.draw(brush,m);
			}

		}
		brush.removeMovieClip();

		// DRAW
		var ec = 8;
		var brush = dm.attach("mcDirt",0);
		for( i in 0...Cs.PMAX ){
			var ly = top[i];
			var next = top[(i+1)%Cs.PMAX];

			var my = ly;
			if(next<my)my = next;
			bmpLevel.fillRect( new flash.geom.Rectangle(i*Cs.PW, Cs.lh-my*ec, Cs.PW, my*ec), 0xFF000000 );

			//
			var dif = next-ly;
			brush.gotoAndStop( dif+6 );
			var m = new flash.geom.Matrix();
			m.translate(i*Cs.PW,Cs.lh-ly*ec);
			bmpLevel.draw(brush,m);

		}
		brush.removeMovieClip();


		// ROCHER
		var brush = dm.attach("mcRocher",0);
		for( i in 0...Cs.PMAX ){
			var rmax = seed.random(4);
			for( ni in 0...rmax ){
				var x = seed.random(Cs.PW)+i*Cs.PW;
				var gr = this.getGround(x);
				var y = gr.y + 3 + seed.random(2);
				var m = new flash.geom.Matrix();
				m.rotate(seed.random(8)*45);
				m.translate(x,y);
				brush.gotoAndStop(seed.random(brush._totalframes)+1);

				var b = brush.getBounds(brush);
				// x+b.xMin, y+b.yMin, b.xMax-b.xMin, (b.yMax-b.yMin)-10
				var rect = new flash.geom.Rectangle( Std.int(x+b.xMin), Std.int(y+b.yMin), Math.ceil(b.xMax-b.xMin), Math.ceil(-b.yMin)+1 );

				bmpLevel.draw( brush, m, null, null, rect );
			}
		}
		brush.removeMovieClip();




	}
	function genTop(){


		// TOPOGRAPHIE
		//var ec = 8;
		//var max = Std.int(Cs.lw/Cs.PW);
		var st = 3;
		top = [];
		for( i in 0...Cs.PMAX )top.push(st);

		// PIC
		var ray = 2;
		for( i in 0...Cs.PMAX ){
			var index = seed.random(Cs.PMAX);
			for( dx in 0...ray*2+1 ){
				var ind = Std.int(Num.sMod(index+dx-ray,Cs.PMAX));
				top[ind] += 1+ray-Std.int(Math.abs(dx-ray));
			}
		}

		// APPLANIE
		var hmax = 25;
		var lim = 5;
		var prev = top[Cs.PMAX-1];
		for( i in 0...Cs.PMAX ){
			if( top[i] > hmax )top[i] = hmax;

			var dif = top[i] - prev;
			if( dif > lim )		top[i] += lim-dif;
			if( dif < -lim )	top[i] += -lim-dif;
			prev = top[i];
		}
		//for( i in 0...Cs.PMAX ) if(top[i]<st) trace("!");


	}

	// SCREEN
	function initScreen(){
		bmpScreen = new flash.display.BitmapData(Cs.mcw,Cs.mch,true,0);
		var screen = Game.me.mdm.empty(1);
		screen.attachBitmap(bmpScreen,0);
	}
	function display(){

		var mult = 1;

		bmpScreen.fillRect(bmpScreen.rectangle,0);

		var vision = 1;


		var fx = focus.x + focus.vx*vision;
		var fy = focus.y + focus.vy*vision + 30;
		var x = Num.sMod( fx - Cs.mcw*0.5, Cs.lw ) ;
		var y = Num.mm(0, fy - Cs.mch*0.5, Cs.lh-Cs.mch) ;
		x = Std.int(x/mult)*mult;
		y = Std.int(y/mult)*mult;



		//
		// HORIZON

		var hh = Cs.lh-Cs.mch;
		var c = scry/hh;
		var h = 120-c*54;
		mcHor._y = Cs.mch-80;
		mcHor.smc._yscale = h;

		// STARFIELD
		if(scrx!=null){
			var vx = Num.hMod(x - scrx,Cs.lw*0.5);
			var vy = Num.hMod(y - scry,Cs.lw*0.5);
			for( mc in starField ){
				mc.x = Num.sMod(mc.x-vx*mc.c,Cs.mcw);
				mc.y = Num.sMod(mc.y-vy*mc.c,Cs.mch);
				mc._x = mc.x;
				mc._y = mc.y;
			}

			for( mc in groundField ){
				mc.x -= vx*mc.c;
				if( mc.x-mc._width*0.5 > Cs.mcw )	mc.x -= mc._width+Cs.mcw;
				if( mc.x+mc._width*0.5 < 0 )		mc.x += mc._width+Cs.mcw;
				//trace(mc.x);
				mc.y = mcHor._y + mc.c*h;
				mc._x = mc.x;
				mc._y = mc.y;
				//trace(mc.y);
			}



		}
		scrx = x;
		scry = y;

		//
		var width = Std.int(Cs.lw-x);
		var w = width;
		if( width > Cs.mcw ) w = Cs.mcw;


		var rect = new flash.geom.Rectangle(0,0,Cs.mcw,Cs.mch);
		var m = new flash.geom.Matrix();
		m.translate(-x,-y);
		bmpScreen.draw(map,m,null,null,rect);

		if( width > Cs.mcw )return;

		//var rect = new flash.geom.Rectangle(w,0,width,Cs.mcw-w);
		var m = new flash.geom.Matrix();
		m.translate(w,-y);
		bmpScreen.draw(map,m);


		// ABOVE
		/*
		return;
		var rect = new flash.geom.Rectangle(w,0,Cs.mcw-w,Cs.mch);
		var m = new flash.geom.Matrix();
		m.translate(-x,-y);
		bmpScreen.draw(map,m,null,null,rect);
		*/





	}

	// INTER
	function initInter(){
		gyro = cast mdm.attach("mcGyro",2);
		var m = 16;
		gyro._x = Cs.mcw - m;
		gyro._y = m;
	}
	function updateInter(){
		gyro.stab._rotation = hero.root._rotation;
		var rot = Math.abs( hero.root._rotation );
		var speed = Math.sqrt(hero.vy*hero.vy+hero.vx*hero.vx);
		//gyro.vector.gotoAndStop(Std.int(40*speed/(Cs.LAND_SPEED_LIMIT*2))+1);
		gyro.vector.stop();
		var c = speed/(Cs.LAND_SPEED_LIMIT*2);
		gyro.stab.smc._yscale = c*100;

		var col = [0x00FF00,0xFFFF00,0xFF0000][hero.danger];



		gyro.filters = [];
		var st = 1.2;
		if( fuel < 20 ){
			if( glow == null )glow = 0;
			glow = (glow+77)%628;
			var c = (Math.sin(glow*0.01)+1)*0.5;
			st = 1.2 + c*2;
			col = 0xFF0000;
			gyro._visible = !gyro._visible;
			Col.setPercentColor(hero.root,c*100,0xFF0000);

		}else{
			if( glow!= null ){
				glow = null;
				gyro._visible = true;
				Col.setPercentColor(hero.root,0,0xFF0000);
			}
		}


		Col.setColor(gyro,col);
		Filt.glow(gyro,8,st,0xFFFFFF);

		gyro.blendMode = "add";






	}
	public function incFuel(n){
		fuel += n;
		//trace(fuel);

		if(fuel<0)fuel = 0;
		if(fuel>100) fuel = 100;

		gyro.vector.gotoAndStop(Std.int(40*fuel/100)+1);
	}
	public function stopRescue(){
		if(!flRescue)return;
		flRescue = false;
		gyro.inf.play();
	}

	// TOOLS
	public function getGY(x:Float){
		if(x==null)return 0;
		var x = Num.sMod(x,Cs.lw);

		var px = Std.int(x/Cs.PW);
		var c = x/Cs.PW - px;
		var sy = top[px];
		var ey = top[(px+1)%Cs.PMAX];
		return Cs.lh - Std.int ( ( sy*(1-c) + ey*c )*Cs.EC ) ;
	}
	public function getGround(x:Float){
		var px = Std.int(x/Cs.PW);
		var c = x/Cs.PW - px;

		var sy = top[px];
		var ey = top[(px+1)%Cs.PMAX];

		var y = Cs.lh - Std.int ( ( sy*(1-c) + ey*c )*Cs.EC );
		var a = Math.atan2( (ey-sy)*Cs.EC, Cs.PW );

		return {y:y,a:a};
	}
	public function getFarAwayX(){
		var hx =hero.x;
		if(hx==null)hx = Std.random(Cs.lw);
		return Std.int( Num.sMod(hx+Cs.lw*0.5+(Math.random()*2-1)*200,Cs.lw) );
	}
	public function getHeroDX(ex:Float):Float{
		if(hero==null) return 100;
		return Num.hMod( hero.x - ex, Cs.lw*0.5 );
	}

	// HORIZON
	public function initHor(){
		mcHor = mdm.attach("mcHor",0);
		updateHor();
		groundField = [];
		var max = 40;
		for( i in 0...max ){
			var mc:Star = cast mdm.attach("mcDecor",0);

			mc.c = 0.05 + (i/max)*0.95;
			groundField.push(mc);
			mc.gotoAndStop(i+1);
			mc.smc.gotoAndStop(i+1);
			mc.x = Math.random()*Cs.mcw+mc._width - mc._width*0.5;

		}

	}
	public function updateHor(){


	}

	// SPAWN
	public function spawn(){
		step = 1;
		learnTimer = 30;
		KKApi.setScore(KKApi.const(0));

	}
	public function updateSpawn(){
		if(learnTimer==0){
			step = 0;
			hero = new Hero();
			fuel = 100;
		}
	}

	// FX
	public function initStarField(){
		starField = [];
		var max = 25;
		for( i in 0...max ){
			var c = 0.25+(i/max)*0.75;
			var mc:Star = cast mdm.attach("mcStar",0);
			mc.x = Math.random()*Cs.mcw;
			mc.y = Math.random()*Cs.mch;
			mc.c = c;
			starField.push(mc);
		}
	}
	public function fxScore(x,y,n){
		var p = new Part(dm.attach("fxScore",DP_FX));
		p.x = x;
		p.y = y;
		p.weight = -0.03;
		p.frict = 0.95;
		p.timer = 30;
		Reflect.setField(p.root,"_sc",n);
		Filt.glow(p.root,2,4,0x000044);

	}
	public function getDust(?x){
		var p  = new Part(dm.attach("partDust",DP_FX));
		if(x!=null){
			p.x = x;
			p.y = getGY(x);
			p.updatePos();
		}
		p.frict = 0.92;
		p.weight = 0.01+Math.random()*0.04;
		p.timer = 10+Math.random()*30;
		p.root._xscale = p.root._yscale = 100+Std.random(100);
		return p;

	}

	// OPTIMISATION
	public function optimize(){
		if( mt.Timer.tmod>1.5 )opt++;
		else if(opt>0)opt--;
		//opt+=2;
		if( opt > 10 ){
			opt = 0;
			if( groundField.length>6 )	groundField.pop().removeMovieClip();
			if( starField.length>6 )	starField.pop().removeMovieClip();
			lag++;
		}
	}

	// DEBUG
	public function mark(x,y){
		if(marks==null)marks = [];
		var mc = Game.me.dm.attach("mcMark",20);
		mc._x = x;
		mc._y = y;
		marks.push(mc);
		while(marks.length>10)marks.shift().removeMovieClip();
	}
	function viewGrid(grid){
		if( !flash.Key.isDown(71) ){
			bmpGrid.dispose();
			bmpGrid = null;
			return;
		}

		if(bmpGrid==null){

			bmpGrid = new flash.display.BitmapData( Cs.XMAX, Cs.YMAX, false, 0 );
			var mc = dm.empty(12);
			mc.attachBitmap(bmpGrid,0);
			mc.blendMode = "add";
			mc._xscale = (Cs.lw/Cs.XMAX)*100;
			mc._yscale = (Cs.lh/Cs.YMAX)*100;
		}

		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){

				var n = grid[x][y].length * 20;
				if( n >255 ) n = 255;
				var col = Col.objToCol({r:n,g:n,b:n});

				bmpGrid.setPixel(x,y,col);
			}
		}


	}

	//
	/*

	*/


	// EVASION
	// EVACUATION
	// EVACTICA
	// EVADE
	// ESCAPE FROM
	// CARGO
	// GOLD RUN


	// IDEES
	// K : KICK COSMO
	// DECOR SEMAINE -> couleur change

	/*
		Les pièces, les pierres-précieuses, shurikens, nourriture, armes et armures sont ajoutés mais n'occupent pas de place dans votre inventaire.
	* /

	/*
La colonie de Sophios est l'endroit le plus impopulaire de la galaxie.
Il n'y ni cinéma ni skatepark pas de boite de nuit... rien.
Aidez les habitants a quitter Sophios pour de meilleur horizon avant que l'armée ne vous en empeche.
	*/

	/*
	L'armée des Storgz vient de débarquer sur le sol de notre colonie. Nous n'avons plus qu'un seul choix : la fuite. Aidez les colons isolés a rejoindre les plateformes de lancement.
	Attention : les tanks Storgz lour
	*/


//{
}







