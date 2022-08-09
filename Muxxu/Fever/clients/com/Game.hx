import mt.bumdum9.Lib;
import world.Loader;

typedef PhxCol = {p:Phx,f:Phx->Void};

class Game extends flash.display.Sprite {//}
	
	static public var DP_BG = 0;
	static public var DP_SPRITE2 = 1;
	static public var DP_SPRITE = 2;
	static public var DP_PART = 3;
	
	static public var WIDTH = 400;
	static public var HEIGHT = 400;
	static public var MAX = 100;
	
	var timeProof:mt.flash.Volatile<Bool>;
	public var click:Bool;
	public var active:Bool;
	
	
	public var id:Int;
	public var win:Null<Bool>;
	var endTimer:Null<Int>;
	public var end:Void->Void;
	public var onSetWin:Bool->Void;
	
	var box:flash.display.Sprite;
	var dm:mt.DepthManager;
	var bg:flash.display.MovieClip;
	
	public var gameTime:mt.flash.Volatile<Float>;
	public var gameTimeMax:mt.flash.Volatile<Float>;
	var step:Int;
	var dif:mt.flash.Volatile<Float>;

	public static var me:Game;
	
	public function new() {
		me = this;
		super();
		active = false;
		click = false;
		dif = 0;
		step = 0;
		gameTime = 20000;
		gameTimeMax = 200;
		timeProof = false;
		
		box = new flash.display.Sprite();
		dm = new mt.DepthManager(box);
		addChild(box);
		
		initDecor();
	}
	function initDecor() {
		
	}
	
	public function init(dif) {
		this.dif = dif;
		step = 1;
		flash.Lib.current.stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, mouseDown);
		flash.Lib.current.stage.addEventListener(flash.events.MouseEvent.MOUSE_UP, mouseUp);
		gameTimeMax = gameTime;
	}
	
	public function update() {

		var a = Sprite.LIST.copy();
		for( sp in a ) sp.update();
		specialMaj();
		if( gameTime-- < 0 && win == null ) outOfTime();
		
		if( endTimer != null ) {
			endTimer--;
			if( endTimer <= 0 ) {
				if(end != null) end();
			}
		}
	
		updateFxShake();

	}
	function specialMaj() {
		
	}
	
	
	function setWin(fl,t=7) {
		if( win != null ) return;
		if( !fl ) new mt.fx.Flash( this, 0.15, 0xFF0000);
		win = fl;
		endTimer = t;
		if( onSetWin != null )onSetWin(fl);
	}
	
	function outOfTime() {
		if( !timeProof )setWin(false,8);
	}
	
	// MOUSE
	function mouseUp(e) {
		click = false;
	}
	function mouseDown(e) {
		if( !click && active ) onClick();
		click = true;
		
	}
	function onClick() {
		
	}

	// FX
	var shk:Null<Float>;
	var shkFrict:Float;
	function fxShake(sh,shf=0.5){
		shk = sh;
		shkFrict = shf;
		updateFxShake();
	}
	function updateFxShake(){
		if( shk == null ) return;
		box.y = shk;
		shk *= -shkFrict;
		if(Math.abs(shk)<0.2){
			box.y = 0;
			shk = null;
		}
	}


	// TOOLS
	function getMousePos() {
		//var mc = flash.Lib.current;
		var mc = box;
		var x = Num.mm(0,mc.mouseX,Cs.mcw);
		var y = Num.mm(0,mc.mouseY,Cs.mch);
		//return new Point(x, y);
		return { x:x, y:y };
	}
	
	
	// COMPATIBILITE MINI-FEVER
	public inline function newSprite(link) {
		
		var sp = new Sprite(dm.attach(link,DP_SPRITE));
		return sp;

	}
	public inline function newPhys(link){
		var sp = new Phys(dm.attach(link,DP_SPRITE));
		sp.frict=  0.99;
		return sp;

	}
	function zoomOld(){
		box.scaleX = Cs.mcw/Cs.omcw ;
		box.scaleY = Cs.mch/Cs.omch;
	}
	inline function getSmc(mc:flash.display.Sprite) {
		var smc:flash.display.MovieClip = cast(mc).smc;
		return smc;
	}
	inline function getMc(mc:flash.display.Sprite, inst:String) {
		var mc:flash.display.MovieClip = Reflect.field(mc, untyped __unprotect__(inst));
		return mc;
	}

	var screen:{>flash.display.MovieClip,bmp:flash.display.BitmapData, q:Float};
	function initScreen(q=0.6){
		screen = cast dm.empty(1);
		screen.q = q;
		screen.bmp = new flash.display.BitmapData(Math.ceil(Cs.mcw*q),Math.ceil(Cs.mch*q),false,0x00FF00);
		screen.scaleX = 1/q;
		screen.scaleY = 1 / q;
		
		var bmp = new flash.display.Bitmap();
		bmp.bitmapData = screen.bmp;
		screen.addChild(bmp);
		//screen.attachBitmap(screen.bmp,0);
	}
	function screenDraw(mc:flash.display.MovieClip,sc=1.0){
		//screen.bmp.fillRect(screen.bmp.rectangle,0x0000FF);
		var m = new flash.geom.Matrix();
		m.scale(sc,sc);
		screen.bmp.draw(mc,m);
	}
	
	// PHYSAXE
	var phxCols:List<PhxCol>;
	public var phxLib:Hash<Phx>;
	public var world:phx.World;
	function initWorld(){
		phxCols = new List();
		phxLib = new Hash();
	}
	function updatePhxCols(){
		for( o in phxCols ){

			for( arb in o.p.body.arbiters ){
				var shapes = [arb.s1,arb.s2];
				for( sh in shapes){
					var ph = getPhx(sh.id);
					if( ph != o.p ){
						o.f(ph);
					}
				}
			}
		}
	}
	public function addPhxCheck(p,col){
		phxCols.push({p:p,f:col});

	}
	function getPhx(id){
		return phxLib.get(Std.string(id));
	}

	// GOD
	public function isGod(n:Int) {
		if( Loader.me == null ) return true;
		return Loader.me.data._god == n;
	}
	
	//
	// KILL
	public function kill() {
		
		flash.Lib.current.stage.removeEventListener(flash.events.MouseEvent.MOUSE_DOWN, mouseDown);
		flash.Lib.current.stage.removeEventListener(flash.events.MouseEvent.MOUSE_UP, mouseUp);
		if( parent != null ) parent.removeChild(this);
	}
	
	// STATIC TOOLS
	public static function getData(id:Int) {
		
	}
	public static function getInstance(id:Int) {
		var game:Game = null;
		switch(id) {
			//*
			case 0 :		game = new Parachute();
			case 1 :		game = new Egg();
			case 2 :		game = new Mirror();
			case 3 :		game = new Cliff();
			case 4 :		game = new Dart();
			case 5 :		game = new Ray();
			case 6 :		game = new Pair();
			case 7 :		game = new Source();
			case 8 :		game = new Puzzle();
			case 9 :		game = new Colline();
			case 10 :		game = new Tapette();
			case 11 :		game = new Brochette();
			case 12 :		game = new Pierce();
			case 13 :		game = new Bibli();
			case 14 :		game = new BossRound();
			case 15 :		game = new Rope();
			case 16 :		game = new Chess();
			case 17 :		game = new Pixiz();
			case 18 :		game = new Asteroid();
			case 19 :		game = new Tree();
			
			case 20 :		game = new ShakeTree();
			case 21 :		game = new Gobelet();
			case 22 :		game = new Sheep();
			case 23 :		game = new Glass();
			case 24 :		game = new PlatJump();
			case 25 :		game = new Clou();
			case 26 :		game = new Zibal();
			case 27 :		game = new PopBalloon();
			case 28 :		game = new JumpFish();
			case 29 :		game = new Trampoline();
			case 30 :		game = new Ghost();
			case 31 :		game = new Hammer();
			case 32 :		game = new Geyser();
			case 33 :		game = new Hamburger();
			case 34 :		game = new Bomb();
			case 35 :		game = new Olive();
			case 36 :		game = new Orbital();
			case 37 :		game = new Plate();
			case 38 :		game = new CrossLazer();
			case 39 :		game = new Rempart();
			
			case 40 :		game = new Pilul();
			case 41 :		game = new Slider();
			case 42 :		game = new RollBlock();
			case 43 :		game = new Toupie();
			case 44 :		game = new JumpCar();
			case 45 :		game = new FallApple();
			case 46 :		game = new Scud();
			case 47 :		game = new SplashPiou();
			case 48 :		game = new FlyEater();
			case 49 :		game = new BalloonKid();
			case 50 :		game = new FlyingDeer();
			case 51 :		game = new Acrobate();
			case 52 :		game = new RainbowCircle();
			case 53 :		game = new Wheel();
			case 54 :		game = new ColorBall();
			case 55 :		game = new Flower();
			case 56 :		game = new Gather();
			case 57 :		game = new SuperKnight();
			case 58 :		game = new Chain();
			case 59 :		game = new Tubulo();
			
			case 60 :		game = new Frog();
			case 61 :		game = new SpaceDodge();
			case 62 :		game = new Taquin();
			case 63 :		game = new GemTurn();
			case 64 :		game = new Umbrella();
			case 65 :		game = new KiwiCut();
			case 66 :		game = new SpaceScan();
			case 67 :		game = new Magnify();
			case 68 :		game = new Interwheel();
			case 69 :		game = new Kaskade();
			case 70 :		game = new Karate();
			case 71 :		game = new SpaceHunter();
			case 72 :		game = new Spot();
			case 73 :		game = new Stacker();
			case 74 :		game = new Pachinko();
			case 75 :		game = new PullRope();
			case 76 :		game = new EscapeBug();
			case 77 :		game = new Tunnel();
			case 78 :		game = new Eclipse();
			case 79 :		game = new Train();
			
			case 80 :		game = new FamilyMusic();
			case 81 :		game = new Firewall();
			case 82 :		game = new XRay();
			case 83 :		game = new Blocks();
			case 84 :		game = new LabyBall();
			case 85 :		game = new Noe();
			case 86 :		game = new Linea();
			case 87 :		game = new LabySlide();
			case 88 :		game = new Window();
			case 89 :		game = new Boxes();
			case 90 :		game = new Tangram();
			case 91 :		game = new Puissance4();
			case 92 :		game = new Hedgehog();
			case 93 :		game = new FlowerBounce();
			case 94 :		game = new Racer();
			case 95 :		game = new RopeJump();
			case 96 :		game = new RobinHood();
			case 97 :		game = new SquareNum();
			case 98 :		game = new Intruder();
			case 99 :		game = new CarCrash();
			
			//*/
						
			
			default : 		game = new Blank(id);
		}
		game.id = id;
		return game;
	}
	

	
//{
}














