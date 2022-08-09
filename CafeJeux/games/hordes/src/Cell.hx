import Common;
import Anim;

typedef T_CellMc = {>flash.MovieClip, hex:flash.MovieClip, switchAnim:flash.MovieClip};

class Cell {

	public var x(default,null) : Int;
	public var y(default,null) : Int;
	public var mc : T_CellMc;
	public var mcShield : flash.MovieClip;
	public var mcTrap : flash.MovieClip;
	public var game : Game;
	public var points : Int;
	public var locked : Bool;
	public var team1 : Bool;
	public var shield : Bool;
	public var megaShield : Bool;
	public var zombie : Bool;
	public var trap : Bool;
	public var door : Bool;
	public var void : Bool;
	public var armageddon : Bool;

	public function new( game : Game, x : Int, y : Int, isLocked = false ) {
		this.game = game;
		this.x = x;
		this.y = y;
		points = 0;
		locked = isLocked;
		shield = false;
		megaShield = false;
		zombie = false;
		trap = false;
		door = false;
		void = false;
		armageddon = false;

		/*
		mc = game.dm.attach("mcHex",Const.DP_HEX);
		mc._x = getXCoord();
		mc._y = getYCoord();
		mc.onRelease = onRelease;
		mc.onReleaseOutside = onRollOut;
		mc.onRollOver = onRollOver;
		mc.onRollOut = onRollOut;
		mc.stop();
		*/

		if( isLocked ) {
			mc.useHandCursor = false;
		}

	}

	public function onRollOver() {
		if( game.lock ) return;

		/*
		if( zombie ) {
			game.displayHelp( 106 );
		}
		else {
			if( points == 0 ) {
				game.displayHelp( 104 );
			} else {
				if( team1 != game.team )
					game.displayHelp( 105 );
			}
		}*/

		if( shield ) return;
		if( locked ) return;
		if( !MMApi.isMyTurn() ) return;

		game.mcSelector._xscale = mc._xscale;
		game.mcSelector._yscale = mc._yscale;
		game.mcSelector._x = mc._x;
		game.mcSelector._y = mc._y;
		game.mcSelector._visible = true;
	}

	public function onRollOut() {
		if( game.lock ) return;
		if( locked ) return;
		game.mcSelector._visible = false;
	}

	public function onRelease() {
//		if( locked ) trace( toString() );
		if( game.lock ) return;
		if( shield ) return;
		if( locked ) return;
		if( !MMApi.isMyTurn() ) return;
		if ( !MMApi.hasControl() ) return;
		game.onActionDone(this.x, this.y);
	}

	// C'est ici qu'on vire tous les mc
	public function cleanUp() {
		if( mcShield != null ) {
			mcShield.removeMovieClip();
			mcShield = null;
		}
		if( mcTrap != null ) {
			mcTrap.removeMovieClip();
			mcTrap= null;
		}
		mc.removeMovieClip();
		mc = null;
	}

	public function toString(){
		return "Cell ("+x+","+y+") [points:"+points+",zombie:"+zombie+",arma:"+armageddon+",void:"+void+",shield:"+shield+",megaShield:"+megaShield+",trap:"+trap+"]";
	}

	public function reset() {
		//trace("reset "  + id());
		if( mcShield != null ) {
			mcShield.removeMovieClip();
			mcShield = null;
		}
		if( mcTrap != null ) {
			mcTrap.removeMovieClip();
			mcTrap= null;
		}
		zombie = false;
		points = 0;
		mc.gotoAndStop( 1 );
		mc.smc.gotoAndStop( 1 );
		locked = false;
	}


	public function getSide() {
		if ( zombie ) return 3;
		return if ( team1 ) 1 else 2;
	}

	public function switchTeam() {
		team1 = !team1;
	}

	public function zombify() {
		zombie = true;
	}

	public function unzombify() {
		zombie = false;
	}

	function id() {
		return "x"+x+"_y"+y;
	}

	public function refresh() {
		//trace( "refresh" + id() );
		if( armageddon ) {
			mc.gotoAndStop(7);
			mc.hex.gotoAndStop( getSide() );
			mc.switchAnim._visible = false;
			return;
		}

		if ( points<=0 ) {
			reset();
			return;
		}

		if( mcTrap != null && !trap && mcTrap._visible ) {
			mcTrap._visible = false;
		}

		if( zombie ) {
			mc.gotoAndStop(4);
			mc.hex.gotoAndStop( getSide() );
			mc.switchAnim._visible = false;
			mc.smc.gotoAndStop( points + 1 );
			return;
		}

		if( team1 ) {
			mc.gotoAndStop(3);
			mc.hex.gotoAndStop( getSide() );
			mc.switchAnim._visible = false;
			mc.smc.gotoAndStop( points + 1 );
			return;
		}

		mc.gotoAndStop(2);
		mc.hex.gotoAndStop( getSide() );
		mc.switchAnim._visible = false;
		mc.smc.gotoAndStop( points + 1 );
	}

	public function getPoints( ) {
		return points;
	}

	public function display() {
		if( mc == null ) {
			mc = cast game.dm.attach("mcHex",Const.DP_HEX);
			mc._x = getXCoord();
			mc._y = getYCoord();
			mc.onRelease = onRelease;
			mc.onReleaseOutside = onRollOut;
			mc.onRollOver = onRollOver;
			mc.onRollOut = onRollOut;
			mc.switchAnim._visible = false;
			mc.stop();
		}

		if( void ) {
			mc.gotoAndStop(6);
			mc.smc.gotoAndStop( Std.random(mc.smc._totalframes)+1 );
		} else if( door ) {
			mc.gotoAndStop(8);
		} else if( armageddon ) {
			mc.gotoAndStop(7);
		}
		else {
			mc.gotoAndStop( 1 );
		}
		mc.hex.gotoAndStop( getSide() );
	}

	// On change les points en cours de partie
	public function changePoints( points ) {
		this.points = points;
		lock();
	}

	public function setTrap() {
		trap = true;
	}

	public function untrap() {
		trap = false;
	}

	public function unProtect() {
		shield = false;
		mcShield.gotoAndStop(1);
		mcShield._visible = false;
	}

	public function protect( high = false ) {

		if( mcShield == null ) {
			mcShield = game.dm.attach("mcShield",Const.DP_HEX);
			mcShield._x = mc._x + 26;
			mcShield._y = mc._y + 26;
			mcShield.gotoAndStop(1);
			mcShield._visible = false;
		}

		if( high ) {
			mcShield.gotoAndStop(2);
			mcShield._visible = true;
			megaShield = true;
		}
		else {
			mcShield.gotoAndStop(1);
			mcShield._visible = true;
			shield = true;
		}
	}

	// On met les points au premier coup joué
	public function setPoints( points ) {
		this.points = points;
		lock();
	}

	public function isLocked() {
		return locked;
	}

	public function lock() {
		locked = true;
		mc.useHandCursor = false;
	}

	public function unLock() {
		locked = false;
		mc.useHandCursor = true;
	}

	public function setTeam( team1 : Bool ) {
		this.team1 = team1;
	}

	public function getXCoord() : Float{
		if( this.y % 2  == 0 ) {
			return ( this.x * ( Const.HEXA_ANGLE_WIDTH * 2 ) ) + Const.CENTER_X;
		}

		return ( this.x * ( Const.HEXA_ANGLE_WIDTH * 2 )  + Const.HEXA_ANGLE_WIDTH ) + Const.CENTER_X;
	}

	public function getYCoord() : Float {
		return ( this.y * ( Const.HEXA_ANGLE_HEIGHT + Const.HEXA_BORDER - 4 ) ) + Const.CENTER_Y ;
	}

	/* -------------------- ANIM --------------------- */

	public function conquered( f, ?fl_fadeUp:Bool) {
		//trace ("conquered"  + id());
		var cm = mc;
		var anim = new CellAnim( game, cm, fl_fadeUp );
		anim.onEnd = f;
		game.conquered.add( anim );
	}

	public function switched(prevSide:Int, f) {
		//trace ("switched"  + id() + "from:" + prevSide + " to:" + getSide() );
		var anim = new CellSwitch( game, this, prevSide,getSide() );
		anim.onEnd = f;
		game.conquered.add( anim );
	}
}

