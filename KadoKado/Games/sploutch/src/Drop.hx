import mt.bumdum.Phys ;
import mt.bumdum.Lib ;
import Game.Pos ;


class Drop extends Phys {

	static public var SPEED = /*2.7*/2.3 ;
	
	public var d : Int ;
	public var from : Pos ;
	public var done : Bool ;
	public var f : Int ;
	
	
	public function new(pos : Pos, dir : Int) {
		super(Game.me.dm.attach("drop", Game.DP_DROP)) ;
		d = dir ;
		from = pos ;
		done = false ;
		
		root._alpha = Cs.ALPHA_SLIME ;
		root._rotation = dir * 90 ;
		//root._visible = false ;
		
		var coords = Cs.getPos(from, true) ;
		x = coords.x ;
		y = coords.y ;
		
		var v = Cs.dir[d] ;
		vx = v[0] * SPEED ;
		vy = v[1] * SPEED ;
		frict = 1.03 ;
		f = 0 ;
		
		Game.me.drops.push(this) ;
	}
	
	
	override public function update() {
		if (done)
			return ;
		
		super.update() ;
		
		var s = onSlime() ;
		if (s != null) {
			onTouch(s) ;
			return ;
		}
		
		if (outOfBounds())
			onTouch(null) ;
	}
	
	
	public function onTouch(s : Slime) {
		done = true ;
		if (s != null)
			s.growing() ;
		else 
			absorbed() ;
		kill() ;
	}
	
	
	function absorbed() {//animation for slime absorb / burp
		var mc = Game.me.dm.attach("splash", Game.DP_ANIM) ;
		mc._x = root._x ;
		mc._y = root._y ;
		mc._rotation = d * 90 ;
		
		//### TODO animation
		
	}
	
	
	public function onSlime() : Slime { //return a slime or null
		for (s in Game.me.slimes) {
			if (!onWay(s.pos))
				continue ;
			
			if (root.hitTest(s.mc) && (s.grow > 0 || s.bonus))
				return s ;
		}
		return null ;
	}
	
	
	function onWay(p  : Pos) {
		switch(d) {
			case Cs.EAST : 
				return p.y == from.y && p.x > from.x ;
			case Cs.SOUTH : 
				return p.x == from.x && p.y > from.y ;
			case Cs.WEST : 
				return p.y == from.y && p.x < from.x ;
			case Cs.NORTH : 
				return p.x == from.x && p.y < from.y ;
			default : return false ;
		}
	}
	
	
	public function outOfBounds() : Bool {
		if (root._x < Cs.BOARD_X_LIMIT)
			return true ;
		else if (root._x > Cs.BOARD_X_LIMIT + Cs.BOARD_WIDTH * Cs.ZONE_SIZE)
			return true ;
		else if (root._y < Cs.BOARD_Y_LIMIT)
			return true ;
		else if (root._y > Cs.BOARD_Y_LIMIT + Cs.BOARD_HEIGHT * Cs.ZONE_SIZE)
			return true ;
		return false ;
	}
	
	
	override public function kill() {
		super.kill() ;
		Game.me.drops.remove(this) ;
	}
	
	
	
	static public function launch(pos : Pos) {
		for (i in 0...4) {
			var d = new Drop(pos, i) ;
		}
	}
	
	
}