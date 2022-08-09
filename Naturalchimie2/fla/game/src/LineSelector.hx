import mt.bumdum.Lib ;
import mt.bumdum.Sprite ;
import Game.GameStep ;
import GameData._ArtefactId ;

/*
StageObject avec surcharge de keylistener + mc pour la sélection d'une ligne horizontale
*/

class LineSelector {
	
	public var mc : {> flash.MovieClip, _up : flash.MovieClip, _down : flash.MovieClip} ;
	public var sMax : Int ;
	public var sLine : Int ;
	public var k : Dynamic ;
	public var side : Int ; // 1 for line, 0 for column
	public var blocked : Int ;
	var notLast : Bool ;
	
	

	public function new(s : Int, ?notLast = false) {
		side = s ;
		this.notLast = notLast ;
		initMc() ;
	}
	
	
	public function init(?firstOnly : Bool) : Bool {
		if (side == 0) { //column ==> no ckeck needed
			sMax = Stage.WIDTH ;
			return true ;
		}
		
		sMax = -1 ;
		var xMax = Stage.WIDTH ;
		if (firstOnly)
			xMax = 1 ;
		for (xx in 0...xMax) {
			for (yy in 0...Stage.HEIGHT) {
				if (Game.me.stage.grid[xx][yy] == null) {
					if (yy > sMax)
						sMax = yy ;
					break ;
				}
			}
		}
		
		if (sMax > 0 && notLast)
			sMax-- ;
		if (firstOnly && sMax <= 0)
			sMax = 1 ;
		return if (firstOnly) true else sMax > 0 ;
	}
	
	
	function initMc(?i : Int = 0) {
		mc = cast Game.me.mdm.attach(if (side == 1) "lineSelector" else "columnSelector", Const.DP_PART) ;
		if (side == 0) {
			mc._x = Stage.X + sLine * Const.ELEMENT_SIZE ;
			mc._y = Const.HEIGHT - (Stage.BY + (Stage.LIMIT) * Const.ELEMENT_SIZE) ;
		} else {
			mc._x = Stage.X ;
			mc._y = Const.HEIGHT - (Stage.BY + (sLine + 1) * Const.ELEMENT_SIZE) ;
		}
		
		mc._alpha = 0 ;
	}
	
	
	public function showMc(b : Bool) {
		if (mc == null)
			return ;
		mc._alpha = if (b) 100 else 0 ;
	}
	
	
	public function showButtons(b : Bool) {
		if (mc == null)
			return ;
		mc._up._alpha = 0 ;
		mc._down._alpha = 0 ;
	}
	
	
	public function moveTo(s : Int) {
		if (s < 0 || s >= sMax || mc == null)
			return ;
		
		if (s != blocked) {
			sLine = s ;
		} else {
			if (sLine < s) {
				if ( s + 1 < sMax) {
					sLine = s + 1 ;
				} else 
					return ;
			} else {
				if ( s - 1 >= 0) {
					sLine = s - 1 ;
				} else 
					return ;
			}
		}
		
		if (side == 0)
			mc._x = Stage.X + (sLine) * Const.ELEMENT_SIZE ; //to check
		else
			mc._y = Const.HEIGHT - (Stage.BY + (sLine + 1) * Const.ELEMENT_SIZE) ;
	}
	
	
	public function move(s : Int) {
		moveTo(sLine + s) ;
	}
	
	
	public function setKeyListener(f : Void -> Void) {
		k = {
			onKeyDown:callback(f),
			onKeyUp:callback(Game.me.onKeyRelease)
		}	
	}
		
	
	public function selectLine() {
		Game.me.restoreKeyListener() ; 
		
		showButtons(false) ;
	}
	
	
	public function kill() {
		if (mc != null)
			mc.removeMovieClip() ;
	}
	
	
	

	
	
}