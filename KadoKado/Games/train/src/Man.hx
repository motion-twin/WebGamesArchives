import Common;

typedef M = {>flash.MovieClip, rotation:Float}

class Man {

	static var lDIR : Dir;
	static var DIR : Dir;
	static var man : M;
	static var shadow : flash.MovieClip;
	static var game : Game;
	static var initDone = false;
	static var MIN_POS = 4;
	static var FEET_CYCLE = 1;
	static var feetCycle : Float = FEET_CYCLE;
	static var leftFoot : Bool;
	static var leftArm : Int;
	static var ARMS_CYCLE = 5;
	static var armCycles : Float = ARMS_CYCLE;
	static var moveCounter : Int = 0;
	static var lockCycles = 0.0;

	static var lastX : Float = 0.0;
	static var lastY : Float = 0.0;

	static var swap : Bool = false;
	public static var lock = false;

	public static var outside = false;

	
	public static function init(g : Game) {
		leftArm = 1;
		lockCycles = 20;
		game = g;

		if( !initDone ) {
			shadow = game.dm.attach( "ombre_pilote", Const.DP_OBJECTS );
			shadow.blendMode = "multiply";
			man = cast game.dm.attach( "mcPilote", Const.DP_OBJECTS );
			initDone = true;
		}

		man.gotoAndStop( 1 );
		man.rotation = 0;

		outside = false;

		shadow._x = man._x = Const.CENTER_X;
		shadow._y = man._y = Const.LOCO_STARTPOS - 60;
		man._visible = false;
		shadow._visible = false;
	}

	public static function initLeft() : Bool {
		if( lockCycles > 0 ) return false;
		if( lock ) return false;

		shadow._y = man._y = Loco.mc._y - 60;
		shadow._x = man._x = Const.CENTER_X;
		shadow._x = man._x -= Const.MAN_OUT;
		if( hit() ) {
			shadow._x = man._x += Const.MAN_OUT;
			return false;
		}

		game.stopScroll();
		man.gotoAndStop( 3 );
		outside = true;
		return true;
	}

	public static function fly() {
		if( !man._visible ) return;
		man._yscale = man._xscale += 1;
		shadow._y = man._y += 20;		
		if( man._y > Const.HEIGHT ) {
			man.removeMovieClip();
			shadow.removeMovieClip();
		}
	}

	public static function left() : Bool {
		if(!outside) {
			if( !initLeft() ) return false;
			return true;
		}

		man.rotation -= Const.MAN_SPEED * mt.Timer.tmod;
		return true;
	}

	public static function show() {
		shadow._visible = true;
		man._visible = true;
	}

	public static function initRight() : Bool{
		if( lockCycles > 0 ) return false;
		if( lock ) return false;

		shadow._y = man._y = Loco.mc._y - 60;
		shadow._x = man._x = Const.CENTER_X;
		shadow._x = man._x += Const.MAN_OUT;
		if( hit() ) {
			shadow._x = man._x -= Const.MAN_OUT;
			return false;
		}

		game.stopScroll();
		man.gotoAndStop( 4 );
		outside = true;
		return true;
	}

	public static function right() : Bool {
		if(!outside) {
			if( !initRight() ) return false;
			return true;
		}
		man.rotation += Const.MAN_SPEED * mt.Timer.tmod;
		return true;
	}

	public static function go() {
		if(!outside) return;

		if( flash.Key.isDown( flash.Key.UP ) ) {
			if( flash.Key.isDown( flash.Key.LEFT ) )
				DIR = UpLeft;
			else if( flash.Key.isDown( flash.Key.RIGHT ) )
				DIR = UpRight;
			else
				DIR = Up;
		}else if( flash.Key.isDown( flash.Key.DOWN ) ) {
			if( flash.Key.isDown( flash.Key.LEFT ) )
				DIR = DownLeft;
			else if( flash.Key.isDown( flash.Key.RIGHT ) )
				DIR = DownRight;
			else
				DIR = Down;
		}else if( flash.Key.isDown( flash.Key.LEFT ) ) {
			DIR = Left;
		}else if( flash.Key.isDown( flash.Key.RIGHT ) ) {
			DIR = Right;
		}

		if( man._x <= 0 + MIN_POS ) {
			switch( DIR ) {
				case Left:
					DIR = Up;
				case UpLeft :
					DIR = Up;
				case DownLeft :
					DIR = Down;
				default :
			}
			move();
			return;
		}

		if( man._x >= Const.HEIGHT - MIN_POS ) {
			switch( DIR ) {
				case Right:
					DIR = Up;
				case UpRight :
					DIR = Up;
				case DownRight :
					DIR = Down;
				default :
			}
			move();			
			return;
		}

		if( man._y <= 0 + MIN_POS) {
			switch( DIR ) {
				case UpLeft:
					DIR = Left;
				case UpRight :
					DIR = Right;
				case Up :
					DIR = Left;				
				default :
			}
			move();			
			return;
		}

		if( man._y >= Const.HEIGHT - MIN_POS ) {
			switch( DIR ) {
				case DownLeft:
					DIR = Left;
				case DownRight :
					DIR = Right;
				case Down :
					DIR = Left;				
				default :
			}
			move();			
			return;
		}

		move();
	}

	static function move() {		
		
		switch( DIR ) {
			case Up :  
				shadow._y = man._y -= Const.MAN_SPEED;
			case Down : 
				shadow._y = man._y += Const.MAN_SPEED; 
			case Left : 
				shadow._x = man._x -= Const.MAN_SPEED;
			case Right : 
				shadow._x = man._x += Const.MAN_SPEED;
			case UpRight : 
				shadow._x = man._x += Const.MAN_SPEED;
				shadow._y = man._y -= Const.MAN_SPEED;
			case UpLeft : 
				shadow._x = man._x -= Const.MAN_SPEED;
				shadow._y = man._y -= Const.MAN_SPEED;
			case DownRight : 
				shadow._x = man._x += Const.MAN_SPEED;
				shadow._y = man._y += Const.MAN_SPEED; 			
			case DownLeft : 
				shadow._x = man._x -= Const.MAN_SPEED;
				shadow._y = man._y += Const.MAN_SPEED; 			
		}
		
		printShoe();
		moveArms();
		moveCounter = 10;

		if( hit() ) {
			return;
		}		
		
	}

	static function hit() {
	
		Scroller.hitGem( man, Gem.bonus );

		if( Station.hit( man ) ) {
			return true;
		}

		if( Scroller.hitRoot( man ) ) {
			Scroller.changeDepth( man );
			Scroller.changeDepth( shadow );
		}

		if( Scroller.hit( man.smc ) ) {

			switch(DIR ) {
				case Up: shadow._y = man._y = lastY;
				case Down: shadow._y = man._y = lastY;
				case Left: shadow._x = man._x = lastX;
				case Right: shadow._x = man._x = lastX;
				case UpRight : shadow._x = man._x = lastX; shadow._y = man._y = lastY;
				case UpLeft : shadow._x = man._x = lastX; shadow._y = man._y = lastY;
				case DownRight : shadow._x = man._x = lastX; shadow._y = man._y = lastY;
				case DownLeft : shadow._x = man._x = lastX; shadow._y = man._y = lastY;
			}

			lastX = man._x;
			lastY = man._y;

			return true;
		}

		lastX = man._x;
		lastY = man._y;

		return false;
	}

	public static function update() {
		lockCycles -= mt.Timer.tmod;

		if( moveCounter-- <= 0 ){
			switch( DIR ) {
				case Up :  man.gotoAndStop( 8 );
				case Down : man.gotoAndStop( 2 ); 
				case Left : man.gotoAndStop( 11 );
				case UpLeft : man.gotoAndStop( 11 );
				case DownLeft : man.gotoAndStop( 11 );
				case Right : man.gotoAndStop( 5 );
				case UpRight : man.gotoAndStop( 5 );
				case DownRight : man.gotoAndStop( 5 );
			}
			
		}
	}

	static function moveArms() {
		if( armCycles-- <= 0 ) {
			switch( DIR ) {
				case Up : 
					man.gotoAndStop( 7 + leftArm );
				case Right : 
					man.gotoAndStop( 4 + leftArm );
				case UpRight : 
					man.gotoAndStop( 4 + leftArm );
				case DownRight : 
					man.gotoAndStop( 4 + leftArm );
				case Left : 
					man.gotoAndStop( 10 + leftArm );
				case UpLeft : 
					man.gotoAndStop( 10 + leftArm );
				case DownLeft : 
					man.gotoAndStop( 10 + leftArm );
				case Down : 
					man.gotoAndStop( 1 + leftArm );
			}
			if( ++leftArm > 2 ){
				leftArm = 0;
			}
			armCycles = ARMS_CYCLE;
		}
	}

	static function printShoe() {
		feetCycle -= mt.Timer.tmod;

		if( feetCycle <= 0 ) {
			var s = game.dm.attach( "mcFoot", Const.DP_OBJECTS );
			s._rotation = man.rotation;
			if( leftFoot ) {
				s._x = man._x - 3;
			}
			else {
				s._x = man._x + 3;
			}

			leftFoot = !leftFoot;
			s._y = man._y;
			SceneManager.drawOnScene( s );
			s.removeMovieClip();
			s = null;
			feetCycle = FEET_CYCLE;
		}
	}


	public static function inLoco() {
		return man.hitTest( Loco.mc ) && outside;
	}
}
