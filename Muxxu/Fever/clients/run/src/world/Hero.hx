package world;
import world.Island;
import Protocole;
import mt.bumdum9.Lib;

enum HeroStep {
	HS_WAIT;
	HS_MOVE;
}

class Hero {//}
	
	public static var DX = 8;
	public static var DY = 12;

	public static var WALK_SPEED = 0.12;
	public static var MOVE_RAY = 16;

	public var island:Island;
	public var sq:Square;
	public var tsq:Square;
	public var root:flash.display.Sprite;
	public var sprite:pix.Sprite;
	public var dir:Int;

	var step:HeroStep;
	
	var vx:Float;
	var vy:Float;
	var coef:Float;
	

	public function new(isl, sq:Square) {
	
		
		island = isl;
		island.respawn = sq;
			
		root = new pix.Sprite();
		island.dm.add(root, Island.DP_ELEMENTS);
		//root.graphics.beginFill(0xFF0000, 1);
		//root.graphics.drawCircle(0, -8, 8);
		
		sprite = new pix.Sprite();
		sprite.y = -5;
		root.addChild(sprite);
		face();
		
		
		
		setSquare(sq);
		wait();
		
		
	}

	public function setDir(di:Int,force=false) {
		if( dir == di && !force ) return;
		dir = di;
		var a = ["hero_right", "hero_front", "hero_left", "hero_back"];
		sprite.setAnim( Gfx.hero.getAnim(a[di]));
		sprite.anim.goto(2);
	}
	
	public function face() {
		setDir(1, true);
		sprite.anim.goto(0);
		sprite.anim.play(0);

	}
	
	public function update() {
		
		switch(step) {
			case HS_WAIT :
		
			
			case HS_MOVE :
				var coefSpeed = Loader.me.have(Shoes)?1:0.5;
				coef = Math.min(coef + WALK_SPEED*coefSpeed , 1);
				sprite.anim.play(coefSpeed);
				
				var dx = trg.x - sq.x;
				var dy = trg.y - sq.y;

				var x = sq.x + dx * coef;
				var y = sq.y + dy * coef;
				
				setPos( x, y );
				//island.sortElements();
				
				if( coef == 1 ) {
					sq = trg;
					coef = 0;
					if(trg.score == 0) {
						
						wait();
						World.me.setControl(true);
						//trg.heroIn();
					}else {
						chooseNextTarget();
					}
				}

				
				
		}
		
		//mouseHider();
		
	}
	
	public function setSquare(sq:Square) {
		this.sq = sq;
		island.mapDistanceFrom(sq);
		setPos(sq.x,sq.y);
	}
	
	function mouseHider() {
		var dist = Math.abs(root.mouseX) + Math.abs(root.mouseY);
		if( dist < 32 ) flash.ui.Mouse.hide();
		else			flash.ui.Mouse.show();
	}
		
	public function setPos(x:Float,y:Float) {
		root.x = Std.int(x* 16 + DX);
		root.y = Std.int(y * 16 + DY);
	
	}
	
	// WAIT
	function wait() {
		step = HS_WAIT;
		island.mapDistanceFrom(sq);
		sprite.anim.goto(0);
		sprite.anim.play(0);
	}
	
	// WALK
	var trg:Square;
	var onEndMove:Void->Void;
	public function goto(trg:Square) {
	
		removeArrow();
		island.mapDistanceFrom(trg);
		step = HS_MOVE;
		coef = 0;
		chooseNextTarget();
		//
		if( step == HS_MOVE ) {
			world.Inter.me.hideHint();
			World.me.setControl(false);
		}
		//
		
		
	}
	
	function chooseNextTarget() {
		trg = sq.rnei[0];
		var lim = 999;
		for( nsq in sq.rnei ) {
			if( nsq.score > -1 && nsq.score < lim ) {
				trg = nsq;
				lim = nsq.score;
			}
		}
	
			
		var di = 0;
		for( nsq in sq.dnei ) {
			if( nsq == trg ) break;
			di++;
		}
		setDir(di);
		sprite.anim.play(1);
		
		
	
		
		// TRIG
		if( trg.trigSide() ) {
			wait();
		}
		
		
		
	}

	// IS
	public function isWaiting() {
		return step == HS_WAIT;
	}
	
	// JUMP
	var arrow:flash.display.Sprite;
	var arrows:Array<pix.Sprite>;
	public var arrowDir:Null<Int>;
	public function initJumpArrow(di:Int) {
		//if( arrow != null ) trace("error");
		arrowDir = di;
		arrow = new flash.display.Sprite();
		root.addChild(arrow);
		
		var d = Cs.DIR[di];
		arrow.x = d[0] * 16;
		arrow.y = d[1] * 16 - 8;
		Filt.glow(arrow, 2, 40, 0xFFFFFF);
		arrows = [];
		for( i in 0 ...3 ) {
			var sp = new pix.Sprite();
			arrow.addChild(sp);
			//
			if( island.isSafe() ) 		sp.drawFrame(Gfx.inter.get("classic_arrow"));
			else						sp.setAnim(Gfx.inter.getAnim("rainbow_arrow"));
			
			
			if( i != 2 ) {
				Col.setColor( sp, 0, -100);
				sp.y += 2-i;
			}
			sp.rotation = di * 90;
			arrows.push(sp);
		}
	}
	public function removeArrow() {
		if( arrow == null ) return;
		for( sp in arrows ) sp.kill();
		root.removeChild(arrow);
		arrow = null;
		arrowDir = null;
		
	}
	public function getMouseDir() {
		var a = Math.atan2(root.mouseY, root.mouseX)+0.77;
		a = Num.sMod(a, Math.PI*2) / (Math.PI*2);
		return Std.int(a * 4);
		
	}
	
	//
	public function swapToIsland(isl) {
		island = isl;
		island.dm.add(root, world.Island.DP_ELEMENTS);
	}
	
	//TOOLS
	public function getNearestMonster(dist=999.9) {

		var d = Cs.DIR[dir];
		if( dir == -1 ) d = Cs.DIR[0];
		var faceFactor = 0.1;
		
		var mon = null;
		
		for( m in island.monsters ) {

			var dx = sq.x+d[0]*faceFactor - m.sq.x;
			var dy = sq.y+d[1]*faceFactor - m.sq.y;
			var d = Math.sqrt(dx * dx + dy * dy);
			if( d < dist ) {
				dist = d;
				mon = m;
			}
		}
		return mon;
	}
	
	

	
	
//{
}














