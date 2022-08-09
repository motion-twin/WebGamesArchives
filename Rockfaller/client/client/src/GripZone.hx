package ;

import h2d.Sprite;

import data.Settings;
import process.Game;

import Common;

/**
 * ...
 * @author Tipyx
 */
class GripZone extends Sprite
{
	static var ALL		: Array<GripZone>		= [];
	
	var game			: Game;
	
	public var cX		: Int;
	public var cY		: Int;
	
	var hs				: mt.deepnight.slb.HSprite;

	public function new(?cX:Int= - 1, ?cY:Int= - 1) {
		super();
		
		game = Game.ME;
		
		hs = Settings.SLB_FX2.h_getAndPlay("gripZone");
		hs.a.setGeneralSpeed(0.5);
		hs.setCenterRatio(0.5, 0.5);
		this.addChild(hs);
		
		ALL.push(this);
		
		if (cX > -1 && cY > -1) {
			this.cX = cX;
			this.cY = cY;
			
			resize();
		}
		else
			spawn();
	}
	
	public function pick(r:Rock) {
		//switch (r.type) {
			//case TypeRock.TRLoot(id) :
				//game.grip.pick(r);
				////r.destroy();
				//game.arLoots.push( { id:id, num:1 } );
			//case TypeRock.TRCog(v) :
				//game.grip.pick(r);
				////r.destroy();
				//FX.ADD_MOVES(v, cX, cY);
				//switch (v) {
					//case 0 :
						//game.movesLeft += 3;
						//FX.POINT_ROCK(cX, Settings.GRID_HEIGHT - 1, "+" + 3 + "Moves !");
					//case 1 : 
						//game.movesLeft += 4;
						//FX.POINT_ROCK(cX, Settings.GRID_HEIGHT - 1, "+" + 4 + "Moves !");
					//case 2 :
						//game.movesLeft += 5;
						//FX.POINT_ROCK(cX, Settings.GRID_HEIGHT - 1, "+" + 5 + "Moves !");
				//}
			//default :
				//throw r.type + " is not handled by be pickable";
		//}
		//
		//spawn();
	}
	
	public function spawn() {
		var newCX = Std.random(Settings.GRID_WIDTH);
		var newCY = Std.random(Settings.GRID_HEIGHT);
		var b = true;
		
		while (b) {
			newCX = Std.random(Settings.GRID_WIDTH);
			newCY = Std.random(Settings.GRID_HEIGHT);
			b = false;
			
			if (EXIST(newCX, newCY) != null)
				b = true;
			
			var r = Rock.GET_AT(newCX, newCY);
			if (r == null || !r.isRotable || r.isPickable)
				b = true;
		}
		
		this.cX = newCX;
		this.cY = newCY;
		
		resize();
	}
	
// RDU
	public function resize() {
		hs.scaleX = hs.scaleY = Settings.STAGE_SCALE;
		
		this.x = Rock.GET_POS(cX);
		this.y = Rock.GET_POS(cY);
	}
	
	public function destroy() {
		hs.destroy();
		hs = null;
		
		ALL.remove(this);		
	}
	
	public function update() {
		
	}
	
// STATIC
	public static function EXIST(cX:Int, cY:Int):GripZone {
		for (g in ALL)
			if (g.cX == cX && g.cY == cY)
				return g;
				
		return null;
	}
	
	public static function RESPAWN(cX:Int, cY:Int) {
		var g = EXIST(cX, cY);
		if (g != null)
			g.spawn();
	}
	
	public static function PICK():Bool {
		for (r in Rock.ALL) {
			var gz = EXIST(r.cX, r.cY);
			if (r.isPickable && gz != null) {
				gz.pick(r);
				return true;
			}
		}
		
		return false;
	}

	public static function RESIZE() {
		for (gz in ALL)
			gz.resize();
	}
	
	public static function DESTROY() {
		for (gz in ALL.copy())
			gz.destroy();
			
		ALL = [];
	}
	
	public static function UPDATE() {
		for (gz in ALL)
			gz.update();
	}
}