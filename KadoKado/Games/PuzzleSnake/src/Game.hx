import KKApi;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Lib;
import Cell;

enum DestroyType {
	SnakeEat;
	SnakeEatSuite;
	EndLevel;
}


class Const {
	public static var WIDTH_1 = KKApi.const( 4 );
	public static var WIDTH_2 = KKApi.const( 6 );
	public static var WIDTH_3 = KKApi.const( 8 );
	public static var WIDTH_4 = KKApi.const( 10 );

	public static var HEIGHT_1 = KKApi.const( 2 );
	public static var HEIGHT_2 = KKApi.const( 4 );
	public static var HEIGHT_3 = KKApi.const( 6 );
	public static var HEIGHT_4 = KKApi.const( 8 );

	public static var LENGTH_1 = KKApi.const( 5 );
	public static var LENGTH_2 = KKApi.const( 6 );
	public static var LENGTH_3 = KKApi.const( 7 );
	public static var LENGTH_4 = KKApi.const( 8 );

	public static var TIME = KKApi.const( 2000 );
	public static var TIME_COEF = 0.9;

	public static var BASIC_SYMBOLS = KKApi.const( 5 );
	public static var POINTS = KKApi.aconst( [75,100,150,200,300,2000,5000,15000] );
	public static var RPOINTS = KKApi.aconst( [-75,-100,-150,-200,-300,-2000,-5000,-15000] );

	public static var BONUS_PROBA = KKApi.aconst( [100,20,5,1] );



	public static var ANIM_BLINK = {start: 10, end: 25};
	public static var ANIM_APPEAR = {start: 30, end: 40};

	public static var FRAME_HORI = 60;
	public static var FRAME_VERT = 61;
	public static var FRAME_BOTTOM_RIGHT = 62;
	public static var FRAME_BOTTOM_LEFT = 63;
	public static var FRAME_TOP_RIGHT = 64;
	public static var FRAME_TOP_LEFT = 65;

	public static var ANIM_SNAKE_STEP = 5;

	public static var DESTROY_ANIM_LENGTH = 30;


}

class Game {//}

	public static var DP_BG = 0;
	public static var DP_GRID = 2;
	public static var DP_CELL = 4;
	public static var DP_SNAKE = 6;
	public static var DP_PART = 8;

	static var level : mt.flash.Volatile<Int>;
	static var levelStarted : Bool;
	static var globalLock : Bool;
	public static var levelEnded : Bool;
	public static var grid : Array<Array<Cell>>;
	public static var suite : Suite;

	public static var width : KKConst;
	public static var height : KKConst;
	public static var length : KKConst;

	public static var time : mt.flash.Volatile<Float>;
	public static var cTime : mt.flash.Volatile<Float>;

	public static var inst(default,null) : Game;

	static var anim : Array<Anim>;
	static var animToAdd : List<Anim>;

	var mcBg : {> flash.MovieClip, bar: flash.MovieClip };
	var mcGrid : flash.MovieClip;
	var mcTitle : {>flash.MovieClip, field:flash.TextField};

	var barPlay : Bool;
	var levelClean : Bool;

	public static var dm:mt.DepthManager;

	public static var cleanId:Int;

	public function new( mc : flash.MovieClip ){
		/*
		Cell.dmanager = new mt.DepthManager( mc.createEmptyMovieClip("a",5) );
		Suite.dmanager = new mt.DepthManager( mc.createEmptyMovieClip("b",10) );
		var dmanager = new mt.DepthManager( mc.createEmptyMovieClip("c",15) );
		mcBg = cast dmanager.attach("bg",1);
		mcBg.bar.stop();
		*/
		dm = new mt.DepthManager(mc);
		mcBg = cast dm.attach("bg",DP_BG);
		mcBg.onRelease = onRelease;

		level = 0;
		globalLock = false;

		inst = this;
		anim = new Array();
		animToAdd = new List();

		levelUp();

		//Col.setPercentColor( mcBg, 30, 0xFF0000 );
		/*
		var co = new flash.Color(mc);
		var ct = {
			ra:100,
			ga:100,
			ba:100,
			aa:100,
			rb:100,
			gb:0,
			bb:0,
			ab:0
		};
		co.setTransform( ct );
		//co.setRGB(0xFF0000);
		*/
	}

	function onRelease(){
		if( !locked() && suite.started() ) suite.reinit();
	}

	public function cleanLevel(){
		cleanId = Std.random(Std.int(Math.min(5,level*0.5)));
		if( suite != null ) suite.kill();
		if( grid != null ) for( a in grid ) for( c in a ) c.kill();
		levelClean = true;
	}

	public function levelUp(){
		level++;
		levelStarted = false;
		levelEnded = false;
		levelClean = false;

		mcBg.bar.gotoAndStop( 1 );
		barPlay = false;


		initConst();
		initGrid();
		initSuite();
	}

	public static function locked(){
		return globalLock || anim.length > 0 || animToAdd.length > 0;
	}

	public function onEndAnim(){
		if( !levelStarted ) levelStarted = true;
		if( levelEnded ){
			if( levelClean )
				levelUp();
			else
				cleanLevel();
		}
		suite.tryNext();
	}

	function initConst(){
		if( level < 3 ){
			width = Const.WIDTH_1;
			height = Const.HEIGHT_1;
			length = Const.LENGTH_1;
		}else if( level < 8 ){
			width = Const.WIDTH_2;
			height = Const.HEIGHT_2;
			length = Const.LENGTH_2;
		}else if( level < 30 ){
			width = Const.WIDTH_3;
			height = Const.HEIGHT_3;
			length = Const.LENGTH_3;
		}else{
			width = Const.WIDTH_4;
			height = Const.HEIGHT_4;
			length = Const.LENGTH_4;
		}

		if( time == null )
			time = KKApi.val( Const.TIME );
		else
			time *= Const.TIME_COEF;

		cTime = time;
	}

	function initGrid(){
		grid = new Array();

		for( i in 0...KKApi.val(height) ){
			grid[i] = new Array();
			for( j in 0...KKApi.val(width) ){
				var v = Std.random( KKApi.val(Const.BASIC_SYMBOLS) );
				grid[i][j] = new Cell(j,i,v);

			}
		}

		if(mcGrid==null){
			mcGrid = dm.attach("back",DP_GRID);
			mcTitle = cast dm.attach("title",DP_GRID);
			var fl = new flash.filters.GlowFilter();
			fl.blurX = 3;
			fl.blurY = 3;
			fl.color = 0x995DCA;
			fl.strength = 5;
			var a = mcTitle.filters;
			a.push(fl);
			mcTitle.filters = a;
		}
		var m =8;
		mcGrid._x = Cell.getX(0)-m;
		mcGrid._y = Cell.getX(0)-m;
		mcGrid._xscale = (Cell.getX(KKApi.val(width)) - mcGrid._x)+m;
		mcGrid._yscale = (Cell.getX(KKApi.val(height)) - mcGrid._y)+m;

		mcGrid._x += -15;
		mcGrid._y += 43;

		mcTitle._x = mcGrid._x;
		mcTitle._y = mcGrid._y;

		//vat tf : flash.TextField = Reflect.field(mcTitle,"field");
		mcTitle.field.text = "NIVEAU "+level;

	}


	function initSuite(){
		suite = new Suite();

		// get first
		var cur = grid[Std.random(KKApi.val(height))][Std.random(KKApi.val(width))];
		cur.chained = true;
		suite.add( cur );

		for( i in 1...KKApi.val(length) ){
			cur = cur.randomNeighbour();
			if( cur == null ) break;
			cur.chained = true;
			suite.add( cur );
		}
		suite.clean();

		var type = null;
		do {
			var t = 0;
			for( a in Const.BONUS_PROBA )
				t += KKApi.val( a );
			var r = Std.random( t );

			var tType = 0;
			for( a in Const.BONUS_PROBA ){
				r -= KKApi.val( a );
				if( r < 0 ){
					type = tType;
					break;
				}
				tType++;
			}
			if( type == null ){
				type = 0;
			}

			if( type > 0 ){
				// on a un fruit de la suite qui doit être upgradé en bonus
				var c = suite.list[Std.random(suite.list.length)];
				if( c.symbol >= KKApi.val(Const.BASIC_SYMBOLS) ){
					type = 0;
				}else{
					c.symbol = KKApi.val(Const.BASIC_SYMBOLS) + type - 1;
				}
			}

		}while( type > 0 );

		for( a in grid ) for( c in a ) c.display();

		suite.display();
	}

	public static function addAnim( a : Anim ){
		animToAdd.add( a );
	}

	public function update(){


		if( animToAdd.length > 0 ){
			for( a in animToAdd ) anim.push( a );
			animToAdd = new List();
		}

		suite.update();
		if( anim.length > 0 ){
			var animToRemove = new List();
			for( a in anim ){
				if( a.play() ) animToRemove.add( a );
			}

			for( a in animToRemove ) anim.remove( a );

			if( anim.length == 0 && animToAdd.length == 0 ) onEndAnim();
		}

		if( anim.length == 0 && animToAdd.length == 0 ) suite.tryNext();

		if( levelStarted && !levelEnded ){
			cTime -= mt.Timer.deltaT * 24;
			if( cTime <= 0 ){
				KKApi.gameOver(null);
				globalLock = true;
			}
		}

		mcBg.bar._xscale = Math.max(0,cTime * 100 / time);
		if( cTime < 200 && !barPlay ){
			barPlay = true;
			mcBg.bar.play();
		}

		for( p in Sprite.spriteList )p.update();

	}

	public function destroyAnim( mc : McCell, type : DestroyType ){

		switch(type){
			case EndLevel:
				var max = Std.int(Math.min(3,120/Sprite.spriteList.length));
				for( i in 0...max ){
					var p = new Phys(dm.attach("partDifuse",DP_PART));
					p.x = mc._x;
					p.y = mc._y;
					var a = Math.random()*6.28;
					var ca = Math.cos(a);
					var sa = Math.sin(a);
					var speed = 0.5+Math.random()*4;
					p.vx = ca*speed;
					p.vy = sa*speed;
					p.timer = 5+Math.random()*10;
					p.fadeLimit = 5;
					p.fadeType = 0;
					p.root.blendMode = "add";
					Col.setPercentColor( p.root, 100, Col.objToCol({r:Std.random(255),g:Std.random(255),b:Std.random(255)}) );
					p.setScale(100+Std.random(50));

					p.vr = (Math.random()*2-1)*12;
					//Col.setColor( p.root, 100, 0xFF0000 );
				}
			case SnakeEat:
				for( i in 0...6 ){
					var p = new Phys(dm.attach("partFruit",DP_PART));

					var a = Math.random()*6.28;
					var ca = Math.cos(a);
					var sa = Math.sin(a);
					var speed = 0.5+Math.random()*3;
					if(mc.symbol._currentframe>5){
						p.root.blendMode = "add";
						p.setScale(150+Std.random(150));
						speed += 1.5;
					}
					p.x = mc._x+ca*12;
					p.y = mc._y+sa*12;
					p.vx = ca*speed;
					p.vy = sa*speed;
					p.timer = 10+Math.random()*10;
					p.fadeType = 0;
					p.root.gotoAndStop(mc.symbol._currentframe);
					p.vr = (Math.random()*2-1)*20;
					Filt.glow(p.root,3,1,0);


				}
				var onde = dm.attach("partOnde",DP_PART);
				onde.blendMode = "add";
				onde._x = mc._x;
				onde._y = mc._y;
			case SnakeEatSuite:

		}


		//
		mc._visible = false;

	}
//{
}


//DONE - Detruire le fruit quand il commence a etre mangé appeler "destroyAnim" dans cell dans le tableau ET dans la suite
//DONE - faire clignoter la barre quand il n'y a plus beaucoup de temps
//DONE - le clique de retour doit marcher n'importe ou
// - si c'est possible, jouer l'anim de retour du serpent ( rapide > 1 frame = 1 case )
//DONE - anim de fin de tableau : couper le temps, jouer "destroyAnim" sur tous les fruits en décalé
//DONE - quand le serpent bouge : - l'empecher de suivre la souris, assigner la bonne direction a la variable "rot"
//DONE - quand le serpent est a l'arret : l'empecher de tourner sa tete a +- de 90° par rapport a sa direction d'origine si ca pose problème laisse moi juste l'angle de sa derniere direction prise dans une variable et je m'en occupe.



