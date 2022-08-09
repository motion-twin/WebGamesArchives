package part;
import Protocole;
import mt.bumdum9.Lib;



class Ball extends mt.fx.Arrow<GameIcons> {//}
	
	//var behaviourMode:Int;
	
	
	public static var WAIT = 0;

	var glowColor:Int;
	var trg: { x:Float, y:Float };
	var color:Int;
	var fuse:Float;
	//var spiral:fx.Spiral<SP>;
	var type:BallType;
	var anLim:Float;
	var anCoef:Float;
	var onImpact:Void->Void;

	public function new(type:BallType ) {
		this.type = type;
		
		var el = new GameIcons();
		Game.paint(el, type);
		Game.me.dm.add(el, Game.DP_FX);
		
		super(el);
		
		//
		asp = 0;
		aspFrict = 0.95;
		
		glowColor = 0;
		fuse = Math.random();
		
		anLim = 0.2;
		anCoef = 0.1;

		WAIT++;
	}

	// INIT POS
	public function initBoardPos(hero:Hero,x:Int,y:Int) {
		var pos = hero.board.getGlobalBallPos(x, y);
		setPos( pos.x, pos.y );
	}
	public function initFolkPos(folk:Folk) {
		var pos = folk.getGlobalPos();
		setPos( pos.x, pos.y );
	}
	
	// UPDATE
	override function update() {
		super.update();
		if ( trg != null ) seek();
		
	}
	function seek() {

		var dx = trg.x - x;
		var dy = trg.y - y;
		var da = Num.hMod(Math.atan2(dy, dx) - an, 3.14);
		an += Num.mm( -anLim, da * anCoef, anLim);
		aspAcc = (1 - Math.min(Math.abs(da), 0.75));
		
		if ( Math.sqrt(dx * dx + dy * dy) < 16 ) impact();
		
		
		
		aspFrict -= 0.0005;

	}

	// SEEK SYSTEM
	public function gotoBoard(board:Board, x, y) {
		trg = board.getGlobalBallPos(x, y);
		var me = this;
		onImpact = function() {
			board.addBall(me.type, x, y);
		}
	}
	public function gotoFolk(f:Folk,?onImpact:Void->Void) {
		trg = f.getCenter();
		var me = this;
		if (onImpact == null ) onImpact = function() { me.kill(); };
		this.onImpact = onImpact;
	}
	
	//
	function impact() {
		if ( onImpact != null ) onImpact();
		kill();
	}
	
	override function kill() {
		super.kill();
		WAIT--;
	}
	
	
	
//{
}