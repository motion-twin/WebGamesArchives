import Common;
import mt.bumdum.Lib;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Part;
import mt.bumdum.Plasma;
import flash.Key;

typedef Line = 		{>flash.MovieClip, bmp:flash.display.BitmapData, sleep:Float, speed:Float, ty:Int, explodeTimer:Float, special:Array<Array<Int>>}
typedef OptionSlot = 	{>flash.MovieClip, id:Int, field:flash.TextField, bg:flash.MovieClip }
typedef Contrat = 	{>flash.MovieClip, field:flash.TextField, bg:flash.MovieClip, id:Int }

class Game {//}



	public static var FL_DEBUG = false;

	public static var DP_BG = 	0;
	public static var DP_PLASMA = 	1;
	public static var DP_LINES = 	3;
	public static var DP_PIECE = 	4;
	public static var DP_BOARD = 	5;
	public static var DP_QUEUE = 	7;
	public static var DP_PARTS = 	8;
	public static var DP_FG = 	10;
	public static var DP_INTER = 	12;


	public var flPress:Bool;
	public var flInverse:Bool;
	public var rainbowCoef:Float;
	public var speed:mt.flash.Volatile<Float>;
	public var playTimerMax:mt.flash.Volatile<Float>;
	public var levelTimer:mt.flash.Volatile<Float>;

	public var board:flash.display.BitmapData;
	public var plasma:Plasma;
	public var grid:Array<Array<Int>>;
	var lines:Array<Line>;
	public var pieceList:Array<Array<Array<Int>>>;
	public var contrats:Array<Contrat>;
	public var options:Array<Option>;
	public var currentOption:Option;

	var brushSquare:flash.MovieClip;


	public var step:Step;
	public var piece:Piece;

	public static var me:Game;
	public var dm:mt.DepthManager;
	public var root:flash.MovieClip;
	public var bg:{>flash.MovieClip, cadre:flash.MovieClip, cdm:mt.DepthManager, odm:mt.DepthManager, nextList:Array<Piece>, optList:Array<OptionSlot>, mcOptions:flash.MovieClip };
	public var stats:{_o:Array<Int>,_l:Array<Int>,_g:Array<Int>};

	public function new( mc : flash.MovieClip ){

		me = this;
		root = mc;
		Cs.MX = (Cs.mcw-Cs.XMAX*Cs.SIZE)*0.5;
		Cs.MY = Cs.mch-Cs.YMAX*Cs.SIZE;
		dm = new mt.DepthManager(root);

		speed = 0.05;
		playTimerMax = 30;
		levelTimer = 0;
		options = [];
		contrats = [];
		stats = {_o:[],_l:[],_g:[0,0,0]};

		initBg();
		initGrid();
		initPlay();
		initPlasma();

		rainbowCoef = 0;
		

	}
	function initBg(){
		var mc =  dm.attach("mcBg",DP_BG);
		bg = cast dm.attach("mcFg",DP_FG);
		bg.cdm = new mt.DepthManager(bg.cadre.smc);
		bg.odm = new mt.DepthManager(bg.mcOptions.smc);
		bg.nextList = [];
		bg.optList = [];

		//addOpt(13);
		/*
		addOpt(2);
		addOpt(6);
		addOpt(7);
		addOpt(8);
		addOpt(9);
		addOpt(10);
		//*/

		/*
		addOpt(6);
		addOpt(7);
		addOpt(5);
		addOpt(4);
		addOpt(4);
		addOpt(2);
		addOpt(3);
		addContrat(3);
		//*/



		//for( i in 0...Cs.CONTRAT_MAX )if(Std.random(20)==0)addContrat(i);

	}

	// UPDATE
	public function update(){

		//haxe.Log.clear();
		//trace(mt.Timer.tmod);
		
		//for( i in 0...500000 )50.2514*465.9;

		

		rainbowCoef+= 0.01*mt.Timer.tmod;
		levelTimer += mt.Timer.tmod;
		if(levelTimer>500){
			speed = speed+0.05;
			levelTimer = 0;
			if(speed>0.5){
				playTimerMax *= 0.92;
			}


		}



		updatePlasma();

		switch(step){
			case Play: updatePlay();
			case Fall: updateFall();
			default:
		}




		updateNextPieces();
		updateOptionSlots();
		updateOptions();
		updateSprites();


	}
	function updateSprites(){
		var list =  Sprite.spriteList.copy();
		for(sp in list)sp.update();
	}
	function updateOptions(){
		var list = options.copy();
		for(opt in list)opt.update();
	}

	// PLAY
	public function initPlay(){
		if(piece==null){
			piece = getNextPiece();
			piece.setPos(5,2);
			Filt.glow(piece.root,6,2,0xFFFFFF);
			if( !piece.isFree(piece.px,piece.py) ){
				piece.kill();
				initGameOver();
			}

		}
		step = Play;
	}
	function updatePlay(){



	}

	// FALL
	public function checkLines(){

		var sl = [];
		lines = [];
		var fall = 0;
		var scn = 0;
		for( py in 0...Cs.YMAX ){
			var y = (Cs.YMAX-(py+1));
			var flFull = true;
			var flOk = false;
			for( x in 0...Cs.XMAX ){
				if(grid[y][x]==null){
					flFull = false;
				}else{
					flOk = true;
				}
			}
			// BREAK LINE
			if(flFull){
				var line = getLine(y);
				line.sleep = fall;
				line.explodeTimer = 0;
				fall++;
				scn++;
				sl.push(y);
				if( contrats[py]!=null )validateContrat(py);
				line.special = [];
				for( x in 0...grid[y].length ){
					var n = grid[y][x];
					if( n>0 )line.special.push([n,x]);
				}

			}else if( flOk && fall>0 ){
				var line = getLine(y);
				//line.sleep = fall*2 + 5 + py*2;
				line.speed = 5;
				line.ty = y+fall;
			}else if( !flOk ){
				fall++;
				sl.push(y);
			}
		}


		if(scn>0){
			for( o in options )o.onLine();
			stats._l.push(scn);
			KKApi.addScore(Cs.getLineScore(scn));
		}

		for( y in sl )grid.splice(y,1);
		for( y in sl )grid.unshift([]);

		if(lines.length>0)initFall(); else initPlay();

	}

	public function initFall(){
		step = Fall;
	}
	function updateFall(){
		var flFall = true;
		var i = 0;
		while( i < lines.length ) {
			var mc = lines[i];
			if(mc.explodeTimer!=null){
				if(mc.sleep>0){
					mc.sleep-=mt.Timer.tmod;
				}else{
					mc.explodeTimer += mt.Timer.tmod;
					var c = mc.explodeTimer/6;
					var max = 3;
					if(c<1){
						Col.setPercentColor(mc,c*120,0xFFFFFF);
					}else{
						var max = 24;
						for( a in mc.special ){
							var x = Cs.MX + (a[1]+0.5)*Cs.SIZE;
							var y = mc._y + Cs.SIZE*0.5;
							switch(a[0]){
								case 1: launchOpt(x,y);
								case 2: getBonus(0,x,y);
								case 3: getBonus(1,x,y);
								case 4: getBonus(2,x,y);
							}
						}
						// CLEAN
						mc.bmp.dispose();
						mc.removeMovieClip();
						lines.splice(i--,1);


					}

					for( i in 0...max ){
						var p = new Part( dm.attach("partPix",DP_PARTS));
						p.x = Cs.MX + Math.random()*(Cs.XMAX*Cs.SIZE);
						p.y = mc._y ;//+ Cs.SIZE*0.5;
						p.weight = -(0.5+Math.random());
						p.timer = 10+Math.random();
						p.bhl = [BhVertiLine];
						p.coef = 1;

					}


				}
				flFall = false;
			}else if(flFall){
				var lim = Cs.MY + mc.ty*Cs.SIZE;
				mc._y = Math.min(mc._y+mc.speed*mt.Timer.tmod, lim);
				if( mc._y == lim ){
					board.copyPixels(mc.bmp,mc.bmp.rectangle, new flash.geom.Point(0,mc.ty*Cs.SIZE));
					mc.bmp.dispose();
					mc.removeMovieClip();
					lines.splice(i--,1);
				}
			}
			drawRainbowShade(mc);
			i++;

		}
		if(lines.length==0)initPlay();

	}
	function getBonus(id,x,y){
		var score = Cs.SCORE_BONUS[id];
		KKApi.addScore(score);
		stats._g[id]++;

		// FX
		var p = new Phys(Game.me.dm.attach("mcScore",DP_INTER));
		p.x = x;
		p.y = y;
		p.vy = -3;
		p.frict = 0.9;
		p.timer = 30;
		var field:flash.TextField = (cast p.root).field;
		field.text = Std.string(KKApi.val(score));
		Filt.glow( cast field, 2, 4, [0x25A73F,0x0089C4,0xF9179F][id]);

	}


	// GAMEOVER
	function initGameOver(){
		step = GameOver;
		KKApi.gameOver(stats);
		piece.explode();
	}
	function updateGameOver(){

	}

	// INTERFACE
	function getNextPiece(){
		if(pieceList==null)pieceList=[];
		while(pieceList.length<10){
			var index = Std.random(Cs.PIECES.length);
			var a = Cs.PIECES[index];
			var matrix  = a[0].copy();
			var color:Int = Col.objToCol(Col.getRainbow(index/Cs.PIECES.length));


			var infos = [ matrix, a[1].copy(), [color] ];

			for( x in 0...4 ){
				for( y in 0...4 ){
					var type = matrix[x*4+y];
					if( type == 1 ){
						if( Std.random(Cs.PROBA_OPTION) == 1 )	type = 2;
						if( Std.random(Cs.PROBA_GREEN) == 0 )	type = 3;
						if( Std.random(Cs.PROBA_BLUE) == 0 )	type = 4;
						if( Std.random(Cs.PROBA_PINK) == 0 )	type = 5;
						matrix[x*4+y] = type;
					}
				}
			}

			pieceList.push(  infos  );
		}

		// DISPLAY NEXT
		for( next in bg.nextList )next.ty = -60;

		var next = new Piece(bg.cdm.empty(0), pieceList[1], true);
		next.ty = 0;
		next.y = 120;
		next.setScale(70);
		bg.nextList.push(next);



		return new Piece( dm.empty( Game.DP_PIECE ), pieceList.shift() );
	}
	function updateNextPieces(){
		var i = 0;
		while( i < bg.nextList.length ){
			var next = bg.nextList[i];
			var dy = next.ty-next.y;
			next.y += dy*0.5*mt.Timer.tmod;
			var fl = new flash.filters.BlurFilter();
			fl.blurX = 0;
			fl.blurY = Math.abs(dy);
			next.root.filters = [fl];

			if(Math.abs(dy)<10 && next.ty!=0 ){
				next.root.removeMovieClip();
				bg.nextList.splice(i--,1);
			}
			i++;
		}
	}

	public function launchOpt(x,y){
		var sp = new Particule(dm.attach("mcPuce",DP_INTER));
		sp.speed =  9+Math.random()*4;
		sp.a = 1.57+(Math.random()*2-1)*0.2;
		sp.ca = 0.12+Math.random()*0.05;
		sp.lim = 0.25;
		sp.x = x;
		sp.y = y;

		sp.bhl = [4,5];

	}
	public function addOpt(?id){
		if(id==null)id = Cs.getRandomOptionId();
		var n = bg.optList.length;
		var mc:OptionSlot = cast bg.odm.attach("mcOptSlot",0);
		mc.field.text = Cs.OPTION_INFOS[id].name;
		//mc.bg._visible = false;
		mc.id = id;
		Filt.glow(cast mc.field,2,10,0x375073);
		bg.optList.push(mc);

		while(bg.optList.length>7)bg.optList.shift().removeMovieClip();

		updateOptPos();



	}
	public function	updateOptPos(){
		var y = 6;
		for( mc in bg.optList){
			mc._y = y;
			y+=13;
		}
	}
	public function useOpt(){
		if(bg.optList.length==0)return;
		var mc = bg.optList.shift();
		var opt = Cs.getOption(mc.id);
		stats._o.push(mc.id);
		mc.removeMovieClip();
		updateOptPos();

	}
	function updateOptionSlots(){
		var mc = bg.optList[0];
		mc.field.textColor = Col.objToCol(Col.getRainbow(rainbowCoef));
	}

	// PLASMA
	function initPlasma(){
		//(mc:flash.MovieClip,?w:Int,?h:Int,?q:Float)
		var ww = Std.int(Cs.SIZE*Cs.XMAX);
		var hh = Std.int(Cs.SIZE*Cs.YMAX);
		var mc = dm.empty(DP_PLASMA);
		var pq = 0.5;
		plasma = new Plasma(mc,ww,hh,pq);
		plasma.setPos(Cs.MX,Cs.MY);
		plasma.ct = new flash.geom.ColorTransform(1,1,1,1,0,0,0,-12);

		var fl = new flash.filters.BlurFilter();
		fl.blurX = Std.int(4*pq);
		fl.blurY = Std.int(4*pq);
		plasma.filters = [ cast fl];

		plasma.root.blendMode = "overlay";
		plasma.root._alpha = 120;

	}
	function updatePlasma(){
		plasma.update();
	}
	public function drawRainbowShade(mc,?r){
		if(r==null)r = Col.getRainbow(rainbowCoef);
		var ct = new flash.geom.ColorTransform(0,0,0,1,r.r,r.g,r.b,0);
		var pq = plasma.pq;
		plasma.drawMc(mc,-Cs.MX*pq,-Cs.MY*pq,ct);
	}

	// BOARD
	public function initGrid(){
		var ww = Std.int(Cs.XMAX*Cs.SIZE);
		var hh = Std.int(Cs.YMAX*Cs.SIZE);



		// BMP
		board = new flash.display.BitmapData(ww,hh,true,0x00000000);
		var mc = dm.empty(DP_BOARD);
		mc._x = Cs.MX;
		mc._y = Cs.MY;
		mc.attachBitmap(board,0);

		// BRUSH
		brushSquare = dm.attach("mcSquare",0);
		brushSquare._visible = false;

		// LOGIC
		grid = [];
		for( y in 0...Cs.YMAX ){
			grid[y] = [];
			if(  y>18 ){	//18
				var hole = Std.random(Cs.XMAX);
				for( x in 0...Cs.XMAX ){
					if(x!=hole)addSquare(x,y);
				}
			}
		}


	}
	public function isFree(x,y){
		return grid[y][x]==null && x>=0 && x<Cs.XMAX && y>=0 && y<Cs.YMAX;
	}
	public function addSquare(?sq:Square,x:Int,y:Int,?type:Int,?color:Int){
		if(type==null)type = 0;
		if(color==null)color = Std.random(0xFFFFFF);
		var flDestroy = false;
		if(sq==null){
			sq = new Square(Game.me.dm.attach("mcSquare",0),type,color);
			flDestroy = true;
		}
		sq.initSkin(brushSquare);
		Col.setPercentColor(brushSquare.smc,20,0x98ABD4);
		//Col.setPercentColor(brushSquare.smc,20,sq.color);

		var m = new flash.geom.Matrix();
		m.translate(getX(x),getY(y));
		board.draw(brushSquare,m);
		grid[y][x] = sq.type;

		//if( y<5 && step!=GameOver )initGameOver();
		if(flDestroy)sq.kill();

	}
	public function destroySquare(x:Int,y:Int){



		var mc = dm.attach("partScore",DP_PARTS);
		mc._x = Cs.MX + (x+0.5)*Cs.SIZE;
		mc._y = Cs.MY + (y+0.5)*Cs.SIZE;
		mc._rotation = Math.random()*360;

		for( n in 0...4 ){
			var p = getPartSquare();
			var dx  = (Math.random()*2-1)*Cs.SIZE*0.5;
			var dy  = (Math.random()*2-1)*Cs.SIZE*0.5;
			var a = Math.atan2(dy,dx);
			var sp = Math.random()*3;
			p.x = Cs.MX + x*Cs.SIZE + dx;
			p.y = Cs.MY + y*Cs.SIZE + dy;
			p.vx = Math.cos(a)*sp;
			p.vy = Math.sin(a)*sp;
			p.updatePos();

		}

		removeSquare(x,y);
	}
	public function removeSquare(x:Int,y:Int){
		grid[y][x] = null;
		board.fillRect(new flash.geom.Rectangle(x*Cs.SIZE,y*Cs.SIZE,Cs.SIZE,Cs.SIZE), 0 );
	}
	public function getLine(y){
		var bmp = new flash.display.BitmapData(Std.int(Cs.XMAX*Cs.SIZE),Cs.SIZE,true,0x00000000);
		var rect = new flash.geom.Rectangle(0,y*Cs.SIZE,Cs.XMAX*Cs.SIZE,Cs.SIZE);
		bmp.copyPixels(board,rect, new flash.geom.Point(0,0));
		board.fillRect(rect,0);

		//
		var mc:Line = cast dm.empty(DP_LINES);
		mc.attachBitmap(bmp,0);
		mc._x = Cs.MX;
		mc._y = Cs.MY+y*Cs.SIZE;
		mc.bmp = bmp;
		lines.push(mc);

		drawRainbowShade(mc);

		return mc;

	}

	// CONTRAT
	public function addContrat(id){
		var col = Col.getRainbow(1-(id/Cs.CONTRAT_MAX)*0.6);
		var mc:Contrat = cast dm.attach("mcContrat",DP_INTER);
		var y = Cs.YMAX-(id+1);
		mc._x = Cs.MX+Cs.XMAX*Cs.SIZE;
		mc._y = Cs.MY+y*Cs.SIZE;
		mc.id = id;
		mc.field.text = Std.string(KKApi.val(Cs.getContratScore(id)));
		Col.setPercentColor(mc.bg,100,Col.objToCol(col));


		// BANDE
		var o = cast col;
		o.a = 255;
		var n = Std.int(plasma.pq*Cs.SIZE);
		var inc = 0.5;
		plasma.fillRect( new flash.geom.Rectangle(0,Std.int((y-inc)*n),Cs.XMAX*n,Std.int(1+inc*2)*n), Col.objToCol32(o) );

		// CONTOUR LETTRE
		var inc = -70;
		col.r = Std.int(Math.max(col.r+inc,0));
		col.g = Std.int(Math.max(col.g+inc,0));
		col.b = Std.int(Math.max(col.b+inc,0));
		Filt.glow(cast mc.field, 2, 10, Col.objToCol(col));

		//
		contrats[id] = mc;
	}
	public function removeContrat(id){
		var mc = contrats[id];
		mc.removeMovieClip();
		contrats[id] = null;
	}
	public function validateContrat(id){
		var mc = contrats[id];
		mc.bg.play();
		mc.field.text = "";
		KKApi.addScore(Cs.getContratScore(id));
		contrats[id] = null;

		for( i in 0...32 ){
			var sp = new Part(dm.attach("partPix",DP_INTER));
			sp.x = mc._x + Math.random()*70;
			sp.y = mc._y + Math.random()*Cs.SIZE;
			sp.vx = (Math.random()*2-1)*10;
			sp.timer = 10+Math.random()*10;
			sp.frict = 0.8;
			sp.bhl = [BhHoriLine];
		}


	}

	// FX
	public function getPartSquare(){
		var p = new Particule(Game.me.dm.attach("partSquare",Game.DP_PARTS));
		p.frict = 0.95;
		p.timer = 10+Math.random()*30;
		p.weight = 0.05+Math.random()*0.05;
		p.setScale(100+Math.random()*50);
		p.fadeType = 0;
		p.bhl = [1];
		return p ;
	}


	// TOOLS
	public function getX(x:Float){
		return x*Cs.SIZE;
	}
	public function getY(y:Float){
		return y*Cs.SIZE;
	}


	// LISTENERS
	function initMouseListener(){
		var ml = Reflect.empty();
		Reflect.setField(ml,"onMouseDown",mouseDown);
		Reflect.setField(ml,"onMouseUp",mouseUp);
		flash.Mouse.addListener(cast ml);
	}
	function mouseDown(){
		flPress = true;
	}
	function mouseUp(){
		flPress = false;
	}

	function initKeyListener(){
		var kl = Reflect.empty();
		Reflect.setField(kl,"onKeyDown",pressKey);
		Reflect.setField(kl,"onKeyUp",releaseKey);
		flash.Key.addListener(cast kl);
	}
	function pressKey(){
		var n = flash.Key.getCode();


	}
	function releaseKey(){
		var n = flash.Key.getCode();
		//if( flPress )mouseUp();
	}


//{
}


// JACKPOT


// COL
// REVOIR LES LUCIOLES






