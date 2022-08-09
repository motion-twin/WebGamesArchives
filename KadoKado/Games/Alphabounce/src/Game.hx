import KKApi;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Lib;
import mt.bumdum.Plasma;
import mt.bumdum.Bmp;

typedef Plan = {>flash.MovieClip, c:Float }
typedef Title = {>flash.MovieClip, mcField:{>flash.MovieClip,field:flash.TextField}, bl:Float, t:Float }
enum Step {
	Scroll;
	Intro;
	Play;
	GameOver;
}


class Game {//}

	public static var FL_DEBUG = false;
	public static var PLAY_AUTO = false;

	public static var DP_BG = 		0;
	public static var DP_PLASMA = 		2;
	public static var DP_UNDERPARTS = 	3;
	public static var DP_BLOCK = 		4;
	public static var DP_PAD = 		5;
	public static var DP_OPTION = 		6;
	public static var DP_BALL = 		7;
	public static var DP_PARTS = 		8;
	public static var DP_INTER = 		10;


	var flDoor:Bool;
	public var flPress:Bool;
	public var flClick:Bool;
	public var flSafe:Bool;

	var step:Step;
	public var lvl: 	mt.flash.Volatile<Int>;
	public var block:	mt.flash.Volatile<Int>;
	var blockTotal:		mt.flash.Volatile<Int>;
	var accTimer:		mt.flash.Volatile<Float>;
	var scroll:		Float;
	var timeCoef:		mt.flash.Volatile<Float>;
	public var levelTimer:mt.flash.Volatile<Float>;
	public var autoLaunchTimer:Float;

	public var grid:Array<Array<Block>>;
	public var blocks:Array<Block>;
	public var model:Array<Array<Int>>;
	public var balls:mt.flash.PArray<Ball>;
	public var sides:Array<flash.MovieClip>;
	public var options:Array<Option>;
	public var events:Array<Event>;
	public var titles:Array<Title>;

	public var pad:Pad;

	public static var me:Game;
	public var dm:mt.DepthManager;
	public var bdm:mt.DepthManager;
	public var root:flash.MovieClip;
	public var bg:flash.MovieClip;
	public var mcScreenshot:{>flash.MovieClip,bmp:flash.display.BitmapData};
	public var mcPlasma:{>flash.MovieClip,bmp:flash.display.BitmapData};
	public var mcTitle:{>flash.MovieClip,field:flash.TextField,timer:Float};


	public var bmpPaint:flash.display.BitmapData;


	public function new( mc : flash.MovieClip ){
		haxe.Log.setColor(0xFFFFFF);
		Cs.init();
		root = mc;
		me = this;
		dm = new mt.DepthManager(root);
		var base = dm.empty(DP_BLOCK);
		Filt.glow(base,4,2,0xFFFFFF);

		bdm = new mt.DepthManager(base);
		sides = [];
		for( i in 0...2 ){
			var mc = dm.attach("mcSide",DP_BLOCK);
			mc._x = i*Cs.mcw;
			mc._xscale = -(i*2-1)*100;
			sides.push(mc);
		}

		// SCREENSHOT
		mcScreenshot = cast dm.empty(DP_BG);
		mcScreenshot.bmp = new flash.display.BitmapData(Cs.mcw,Cs.mch,false,0);
		mcScreenshot.attachBitmap(mcScreenshot.bmp,0);
		mcScreenshot._x = -Cs.mcw;

		//
		bg = dm.attach("mcBg",0);
		bg.stop();
		balls = new mt.flash.PArray();
		options = [];
		events = [];
		titles = [];
		lvl = 0;
		pad = new Pad(dm.attach("mcPad",DP_PAD));

		//
		initPlasma();
		initMouseListener();

		initScroll(1);



		//
		initKeyListener();


		/*
		var a = new mt.flash.PArray();
		a.push(1);
		a.remove(1);
		trace(a.cheat);
		*/

	}

	// UPDATE
	public function update(){


		if(pad.flStop){
			if(timeCoef==null)timeCoef = 1;
			timeCoef = Math.max(timeCoef-0.1,0.1);
		}else{
			if(timeCoef!=null){
				timeCoef = Math.min(timeCoef+0.1,1);
				if(timeCoef==1)timeCoef=null;
			}
		}

		if(timeCoef!=null)mt.Timer.tmod = timeCoef;

		switch(step){
			case Scroll:	updateScroll();
			case Intro:	updateIntro();
			case Play:	updatePlay();
			case GameOver:	updateGameOver();
		}

		updatePlasma();
		updateTitle();

		flClick = false;

		if(balls.cheat){
			KKApi.flagCheater();
		}

	}
	function updateSprites(){
		var list =  Sprite.spriteList.copy();
		for(sp in list)sp.update();
	}

	// SCROLL
	function initScroll(n){

		step = Scroll;
		scroll = n;
		pad.init();
		bg.gotoAndStop(lvl+1);

		// LEVEL
		initGrid();
		fillGrid();
		accTimer = 0;
		flDoor = false;


		//
		updateScroll();

	}
	function updateScroll(){
		scroll = Math.min(scroll+0.05*mt.Timer.tmod, 1);
		root._x = (1-scroll)*Cs.mcw;

		pad.x += 3;
		pad.updatePos();

		if(scroll==1)initIntro();
	}

	// INIT
	function initIntro(){
		step = Intro;

		mcTitle = cast Game.me.dm.attach("mcTitleLevel",DP_INTER);
		mcTitle.field.text = "NIVEAU "+(lvl+1);
		mcTitle._y = -60;
		mcTitle.timer = 30;

	}
	function updateIntro(){

		//var dy = 10-mcTitle._y;
		//mcTitle._y += dy*0.5;
		mcTitle._y = Math.min(mcTitle._y+10, 10);

		sides[0].prevFrame();
		if(sides[0]._currentframe==1 && mcTitle._y == 10 ){
			initPlay();
			var cx = Cs.mcw*0.5;
			var cy = mcTitle._y + 25;
			for( i in 0...64 ){
				var p = new Phys(dm.attach("partLight",DP_INTER));
				p.x = Math.random()*Cs.mcw;
				p.y = mcTitle._y+Math.random()*50;
				var dx = p.x - cx;
				var dy = p.y - cy;
				var a = Math.atan2(dy,dx);
				var dist = Math.sqrt(dx*dx+dy*dy);
				var sp = dist*0.1;
				p.vx = Math.cos(a)*sp;
				p.vy = Math.sin(a)*sp;
				p.timer = 10+Math.random()*10;
				p.frict = 0.9;
				//p.setScale(100+Math.random()*150);
			}
		}
	}

	// PLAY
	function initPlay(){
		step = Play;
		var b = newBall();
		var rnd = (Math.random()*2-1);
		b.gluePoint = rnd*20;
		b.moveTo(pad.x,pad.y);
		b.vx=0;
		b.vy=1;
		b.update();
		b.colPad(rnd);

		levelTimer = 0;
		autoLaunchTimer = 0;
		flSafe = lvl == 0;
	}
	function updatePlay(){
		levelTimer+= mt.Timer.tmod;
		autoLaunchTimer += mt.Timer.tmod;
		if(autoLaunchTimer>200){
			autoLaunchTimer = 0;
			for( b in balls )b.gluePoint = null;
		}


		// BALL ACCELERATION
		var mult = 1.0;
		if( lvl>=5 ) mult=(lvl-3)*0.5;
		accTimer += mult*mt.Timer.tmod;
		if(accTimer>Cs.TEMPO){
			for( b in balls )b.setSpeed(b.speed+0.5);
			accTimer = 0;
		}

		//
		if(flDoor)checkEnd();
		if(mcTitle!=null){
			mcTitle.timer -= mt.Timer.tmod;
			if(mcTitle.timer<0){
				mcTitle._y -= (11-mcTitle._y);
				if(mcTitle._y<-60){
					mcTitle.removeMovieClip();
					mcTitle = null;
				}
			}
		}
		//
		updateSprites();

		for(e in events)e.update();

	}

	public function removeBlock(){
		block--;
		var c = block/blockTotal;
		//trace(Std.int(c*100));
		if( !flDoor && c<Cs.DOOR_COEF )	openDoor();
	}
	function openDoor(){
		var mc = sides[1];
		flDoor = true;
		mc.play();
	}
	function checkEnd(){
		if( pad.x >= Cs.mcw-(pad.ray+Cs.SIDE-1)  ){
			while(balls.length>0)balls.pop().kill();
			while(options.length>0)options.pop().kill();
			while(events.length>0)events[0].kill();
			pad.flGo = true;
		}
	}
	public function leaveLevel(){

		lvl++;
		//
		mcScreenshot.bmp.draw(root,new flash.geom.Matrix());
		sides[0].gotoAndStop(sides[0]._totalframes);
		sides[1].gotoAndStop(1);
		pad.x = pad.ray;
		pad.updatePos();

		//
		initScroll(0);
	}

	// GAME OVER
	public function initGameOver(){

		KKApi.gameOver({});
		step = GameOver;
	}
	public function updateGameOver(){

	}

	// OPTIONS
	public function newOption(?t,?x,?y){
		if(x==null)x = pad.x;
		if(y==null)y = pad.y-60;
		var opt = new Option(dm.attach("mcOption",DP_OPTION));
		opt.x = x;
		opt.y = y;
		opt.setType(t);
	}
	public function getOption(id){
		switch(id){
			case 0:	// A IMANT
				pad.setType(Cs.PAD_AIMANT);

			case 1:	// B LINDAGE
				for( bl in blocks )if(bl.type<5)bl.setLife(bl.life+2);

			case 2:	// C OLLE
				pad.setType(Cs.PAD_GLUE);

			case 3:	// D IMINUTION
				pad.setRay(Math.max(pad.ray-15,Pad.SIDE+1));
				pad.powerUp();

			case 4:	// E XTENSION
				pad.setRay(Math.min(pad.ray+15,80));
				pad.powerUp();

			case 5:	// F LAMME
				for( b in balls )b.setType(Cs.BALL_FIRE);

			case 6:	// G LACE
				for( b in balls )b.setType(Cs.BALL_ICE);

			case 7:	// HALO
				for( b in balls )b.setType(Cs.BALL_HALO);

			case 8:	// I NVERSION
				pad.moveFactor *= -1;

			case 9:	// J AVELOT
				new ev.Javelot();

			case 10: // K AMIKAZE
				for( b in balls )b.setType(Cs.BALL_KAMIKAZE);

			case 11: // L ASER
				pad.setType(Cs.PAD_LASER);

			case 12: // M ULTI-BALL
				var list = balls.copy();
				for( b in list ){
					if(balls.length>=Cs.MAX_BALL)break;
					if(b.type!=Cs.BALL_SHADE){
						var ball = b.clone();
						var a = Math.atan2(b.vy,b.vx);
						var ma = 0.15;
						ball.vx = Math.cos(a+ma)*ball.speed;
						ball.vy = Math.sin(a+ma)*ball.speed;
						b.vx = Math.cos(a-ma)*b.speed;
						b.vy = Math.sin(a-ma)*b.speed;
					}
				};

			case 13: // N ERVEUX
				pad.setType(Cs.PAD_SHAKE);

			case 14: // O UVRE
				if(!flDoor)openDoor();

			case 15: // P ROTECTION
				pad.setType(Cs.PAD_PROTECTION);

			case 16: // Q UASAR
				new ev.Quasar();

			case 17: // R LENTISSEMENT
				for( b in balls )b.setSpeed(Math.max(b.speed-5,3));

			case 18: // S AUVETAGE ACTIF
				levelTimer = 0;
				flSafe = true;
			case 19: // T EMPORALITE
				pad.setType(Cs.PAD_TIME);

			case 20: // U NIFICATION
				new ev.Unification();

			case 21: // V AGUE
				new ev.Wave();

			case 22: // W HISKY
				for( b in balls )b.setType(Cs.BALL_DRUNK);

			case 23: // X ENOPHOBIE
				for( b in balls )b.setType(Cs.BALL_STANDARD);

			case 24: // Y OYO
				for( b in balls )b.setType(Cs.BALL_YOYO);

			case 25: // Z ELE
				for( b in balls )b.setSpeed(b.speed+5);
		}

		// TITLE
		newTitle(Option.NAMES[id],Option.getCol(id));

	}

	// GRID
	function initGrid(){

		grid = [];
		for( x in 0...Cs.XMAX ){
			grid[x] = [];
			for( y in 0...Cs.YMAX ){
				grid[x][y] = null;
			}
		}

	}
	function fillGrid(){

		bdm.clear(0);
		genPalette();

		var to = 0;
		while(true){
			genModel();
			var bl = 0;
			for( x in 0...Cs.XMAX ){
				for( y in 0...Cs.YMAX ){
					if( model[x][y] !=null )bl++;
				}
			}
			if(to++>10 || bl>20+lvl*25 )break;
		}


		block = 0;
		blocks = [];
		// BLOCKS
		//var str = "";
		for( y in 0...Cs.YMAX ){
			for( x in 0...Cs.XMAX){
				var type = model[x][y];
				if( type != null ){
					//str+=type+";";
					var bl = new Block(x,y,type);
				}else{
					//str+="-;";
				}
			}
			//str+="\n";
		}
		//trace(str);
		blockTotal = block;
	}
	public function hit(px,py,ball){
		grid[px][py].damage(ball);
	}

	// LEVEL
	function genPalette(){
		// PAINT
		var skin = Cs.SKIN[0];
		bmpPaint = new flash.display.BitmapData(Cs.XMAX,Cs.YMAX,false,skin.back);
		var brush = dm.attach("mcBrush",0);
		var sc = 0.1;
		var ma = -2;
		for( i in 0...16 ){
			var m = new flash.geom.Matrix();
			m.scale(sc,sc);
			m.translate(ma+Std.random(Cs.XMAX-2*ma),ma+Std.random(Cs.YMAX-2*ma));
			var r = skin.br+Std.random(skin.rr);
			var g = skin.bg+Std.random(skin.rg);
			var b = skin.bb+Std.random(skin.rb);

			var ct = new flash.geom.ColorTransform(0,0,0,0,r,g,b,40);
			//trace(ct.redOffset+";"+ct.greenOffset+";"+ct.blueOffset);
			bmpPaint.draw(brush,m,ct,"add");

		}
		brush.removeMovieClip();

		// 256 colors !
		/*
		var bs = 16;
		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){
				var o = Col.colToObj(bmpPaint.getPixel(x,y));
				var col = {
					r:Std.int(o.r/bs)*bs,
					g:Std.int(o.g/bs)*bs,
					b:Std.int(o.b/bs)*bs
				}
				bmpPaint.setPixel(x,y,Col.objToCol(col));
			}
		}
		//*/


	}
	function genModel(){

		//if(FL_DEBUG)lvl = 7;


		// PARAMS
		var flMirror = Std.random(2)==0;
		var flMirrorPalette = Std.random(2)==0 && flMirror;
		var density = 1 + 3/(lvl+1);

		// MASSE
		var bmp = new flash.display.BitmapData(Cs.XMAX,Cs.YMAX,false,0);
		var brush = dm.attach("mcShape",0);
		var sc = 0.05;
		var ma = -2;
		var max = Std.int(3+Math.pow(lvl,2));
		for( i in 0...max ){
			var m = new flash.geom.Matrix();
			m.rotate(Math.random()*6.28);
			var scc = (sc*(1+Math.random()*0.5));
			m.scale(scc,scc);
			m.translate(ma+Std.random(Cs.XMAX-2*ma),ma+Std.random(Cs.YMAX-2*ma));

			//var ct = new flash.geom.ColorTransform(0,0,0,0,r,g,b,40);
			bmp.draw(brush,m);

		}
		brush.removeMovieClip();


		// FILL
		model = [];
		var ymax = Std.int(Math.min(11+lvl,Cs.YMAX-5) );
		for( x in 0...Cs.XMAX ){
			model[x] = [];
			for( y in 0...ymax){
				if( bmp.getPixel(x,y) == 0xFF0000 ){
					model[x][y] = 0;
				}
				/*
				if(Math.random()*density<1 ){
					model[x][y] = 0;
				}
				*/
			}


		}

		// LINE
		for( i in 0...lvl ){
			var lim = 4;
			var y = lim+Std.random(ymax-lim);
			for( x in 0...Cs.XMAX ){
				if( model[x][y] <5 ){
					model[x][y]++;
				}
			}
		}

		// DIG
		while(lvl>=0 && Std.random(2)==0 ){
			var m = 3;
			var di = Std.random(4);
			var sx = m+Std.random(Cs.XMAX-(2*m));
			var sy = m+Std.random(Cs.YMAX-(2*m));
			while(true){
				var bl = model[sx][sy];
				if(bl!=null ){
					model[sx][sy] = null;
					var d = Cs.DIR[di];
					sx += d[0];
					sy += d[1];
					if(Std.random(4)==0){
						di=Std.int(Num.sMod( di+(Std.random(2)*2-1), 4 ));
					}
				}else{
					break;
				}

			}

		}

		// BORDER
		if( lvl > 0 ){
			/*
			var dir = [];
			var bdir = Cs.DIR.copy();
			for( i in 0...lvl ){

				var index = Std.random(bdir.length);
				dir.push(bdir[index]);
				bdir.splice(index,1);

			}
			*/
			for( x in 0...Cs.XMAX ){
				for( y in 0...ymax ){
					if( model[x][y] < 5 ){
						for( d in Cs.DIR ){
							var nx = x+d[0];
							var ny = y+d[1];
							if( nx>=0 && nx<Cs.XMAX && ny>=0 && ny<ymax+1 && model[nx][ny]==null ){
								model[x][y]++;
								break;
							}
						}
					}
				}
			}
		}

		// END MALUS
		if( lvl>5 ){
			for( i in 0...(lvl-5) ){
				for( x in 0...Cs.XMAX ){
					for( y in 0...ymax){
						if(model[x][y]<5)model[x][y]++;
					}
				}
			}
		}

		// BLOCK BALL
		while( lvl>=1 && Std.random(3)==0 ){
			var x = Std.random(Cs.XMAX);
			var y = Std.random(5);
			model[x][y] = 13;

		}


		// BONUS
		var n = 1;
		while( Std.random(n++) == 0  )genBonusBlock(ymax);



		// MIRROR
		if(flMirror){
			var mx = Std.int(Cs.XMAX*0.5);
			for( x in 0...mx){
				var nx = Cs.XMAX-(x+1);
				//bmp.copyPixels(bmp,new flash.geom.Rectangle(x,0,1,Cs.YMAX), new flash.geom.Point(nx,0)  );
				model[nx] = model[x].copy();
				if(flMirrorPalette){
					bmpPaint.copyPixels(bmpPaint,new flash.geom.Rectangle(x,0,1,Cs.YMAX), new flash.geom.Point(nx,0)  );
				}
			}
		}

		return true;
	}
	function genBonusBlock(ymax){
		var max = Std.int( Math.min(2+lvl,4) );

		var mx = 1+Std.random( max );
		var my = 1+Std.random( max );
		var sx = Std.random(Cs.XMAX-mx);
		var sy = Std.random(ymax-my);
		var po = 0;
		if( Std.random( Std.int(Math.pow(mx+my+1,2)) ) == 0 )po = 1;
		if( Std.random( Std.int(Math.pow(mx+my+1,3)) ) == 0 )po = 2;

		for( x in 0...mx){
			for( y in 0...my){
				model[sx+x][sy+y] = 10+po;

			}
		}


	}

	// TITLES
	public function newTitle(str,col,?flBlink){

		var mc:Title = cast dm.attach("mcTitle",DP_INTER);
		mc.mcField.field.text = str;
		mc.bl = 100;
		mc.t = 30;
		if(flBlink==null)mc.mcField.stop();
		Filt.glow(cast mc.mcField,4,2,col);

		titles.unshift(mc);
	}
	function updateTitle(){

		var i = 0;

		while( i<titles.length ){
			var mc = titles[i];
			mc.t -= mt.Timer.tmod;
			if(i==0 && mc.t>0){
				mc.bl*=0.5;
				if(mc.bl<0.5)mc.bl=0;
			}else{
				mc.bl +=20;
				if(mc.bl>100){
					mc.removeMovieClip();
					titles.splice(i--,1);
				}
			}
			if(mc.bl>0){
				mc.filters = [];
				Filt.blur( mc, mc.bl, 0 );
			}
			i++;
		}

	}

	// LISTENERS
	function initMouseListener(){
		//var ml = Reflect.empty();
		var ml : Dynamic = {};
		Reflect.setField(ml,"onMouseDown",mouseDown);
		Reflect.setField(ml,"onMouseUp",mouseUp);
		Reflect.setField(ml,"onMouseMove",mouseMove);
		flash.Mouse.addListener(cast ml);
	}
	function mouseDown(){
		autoLaunchTimer = 0;
		mcTitle.timer = 0;
		pad.action();
		flPress = true;
		flClick = true;
	}
	function mouseUp(){
		pad.release();
		flPress = false;
	}
	function mouseMove(){
		pad.flMouse = true;
	}

	// PLASMA
	function initPlasma(){
		mcPlasma = cast dm.empty(DP_PLASMA);
		mcPlasma.bmp = new flash.display.BitmapData(Std.int(Cs.mcw*Cs.PQ),Std.int(Cs.mch*Cs.PQ),true,0x00000000);
		mcPlasma._xscale = mcPlasma._yscale = 100/Cs.PQ;
		mcPlasma.attachBitmap(mcPlasma.bmp,0);
		mcPlasma.blendMode = "add";
	}
	function updatePlasma(){
		// BLUR
		var fl = new flash.filters.BlurFilter();
		var bl = Math.max(2,mt.Timer.tmod*4*Cs.PQ);
		fl.blurX = bl;
		fl.blurY = bl;
		mcPlasma.bmp.applyFilter(mcPlasma.bmp,mcPlasma.bmp.rectangle,new flash.geom.Point(0,0),fl);

		// COLOR TRANSFORM
		var ct = new flash.geom.ColorTransform(1,1,1,1,0,0,0,-2);
		mcPlasma.bmp.colorTransform(mcPlasma.bmp.rectangle,ct);


	}
	public function plasmaDraw(mc:flash.MovieClip){
		var m = new flash.geom.Matrix();
		m.rotate(mc._rotation*0.0174);
		m.scale( (mc._xscale/100)*Cs.PQ, (mc._yscale/100)*Cs.PQ );
		m.translate(mc._x*Cs.PQ,mc._y*Cs.PQ);
		var ct = new flash.geom.ColorTransform(1,1,1,mc._alpha/100,0,0,0,0) ;
		mcPlasma.bmp.draw(mc,m,ct,mc.blendMode);
	}

	//
	public function displayScore(x,y,sc,?col,?size:Float){
		if(col==null)col=0x222288;
		if(size==null)size=1;

		var psc = new Phys( Game.me.dm.attach("mcScore",Game.DP_PARTS) );
		psc.x = x;
		psc.y = y;
		psc.vy = -0.5;
		psc.timer =  30;
		var field:flash.TextField = (cast psc.root).field;
		field.text = Std.string(sc);
		psc.fadeLimit = 5;
		psc.fadeType = 0;
		psc.setScale(100*size);
		Filt.glow(cast field, 4, 2, col);
	}

	// TOOLS
	public function newBall(){
		var ball = new Ball(dm.attach("mcBall",DP_BALL));
		return ball;
	}
	public function isFree(px,py){
		return grid[px][py] == null && px>=0 && px<Cs.XMAX && py>=0;
	}
	public function getLowestBall(){
		var ball:Ball = null;
		for( b in balls ){
			if( ball==null || ( b.flUp && b.y>ball.y ) ){
				ball = b;
			}
		}
		return ball;

	}

	// DEBUG
	function initKeyListener(){
		var kl = {};
		Reflect.setField(kl,"onKeyDown",pressKey);
		Reflect.setField(kl,"onKeyUp",releaseKey);
		flash.Key.addListener(cast kl);
	}
	function pressKey(){
		var n = flash.Key.getCode();
		if( n==flash.Key.SPACE )mouseDown();

		if(FL_DEBUG){
			var al = 65;
			if( n >= al  && n<al+26 )newOption(n-al);
			if( n == flash.Key.ENTER ){
				for( i in 0...26 ){
					var x = 50+(i%6)*40;
					var y = 20+Std.int(i/6)*20;
					var opt = newOption(i,x,y);
				}
			}
		}

	}
	function releaseKey(){
		var n = flash.Key.getCode();
		if( n==flash.Key.SPACE )mouseUp();
	}

	// CLIQUER POUR COMMENCER
	// NOM DU LEVEL

	// QUASAR PROG
	// FX BULLET TIME
	// FX BLOCK EXPLOSE




//{
}


	// JS

	// Jet, joint, judo, jumeau, jugement
	// Unification Ultime


	// sauvetage,





