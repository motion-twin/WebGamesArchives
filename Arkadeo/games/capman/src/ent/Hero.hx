package ent;

import mt.kiroukou.math.MLib;
import mt.bumdum9.Lib;
import Protocol;

class Hero extends Ent {
	
	var bonusLife : Int;
	public var bonus : BonusKind;
	
	public var dead:Bool;
	public var skin:EL;
	var multi:Int;
	var inputX:Int;
	var inputY:Int;
	var jumpReady:Bool;
	
	public function new() {
		super();
		skin = new EL();
		skin.goto("hero");
		root.addChild(skin);
		multi = 1;
		dead = false;
		jumpReady = false;
		dropShadow();
	}
	
	public function canJump() {
		return bonusLife > 0 && bonus == BonusKind.BK_Jump;
	}
	
	public function isInvincible() {
		return bonusLife > 0 && bonus == BonusKind.BK_Star;
	}
	
	function applyBonus(kind:BonusKind) {
		bonus = kind;
		bonusLife = Cs.BONUS_LIFE;
		updateSkin();
	}
	
	function cleanBonus() {
		bonus = null;
		bonusLife = -1;
		updateSkin(false);
	}
	
	function updateSkin(useBonus = true) {
		var frame = (skin.anim != null) ? Std.int(skin.anim.cursor) : 0;
		if( useBonus && canJump() )
			skin.play("hero_walk_shoe_" + dir, true, frame );
		else if( useBonus && isInvincible() )
			skin.play("hero_walk_cap_" + dir, true, frame );
		else
			skin.play("hero_walk_" + dir, true, frame );
	}
	
	override function update() {
		if( bonus != null ) {
			bonusLife --;
			if( bonusLife <= 50 ) {
				updateSkin( MLib.isEven(Std.int(bonusLife/3)) );
			}
			if( bonusLife <= 0 ) {//remove effect, update hero skin
				cleanBonus();
			}
		}
		//
		inputX = -1;
		inputY = -1;
		if( api.AKApi.isDown( flash.ui.Keyboard.RIGHT ) )	inputX = 0;
		if( api.AKApi.isDown( flash.ui.Keyboard.DOWN  ) )	inputY = 1;
		if( api.AKApi.isDown( flash.ui.Keyboard.LEFT  ) )	inputX = 2;
		if( api.AKApi.isDown( flash.ui.Keyboard.UP    ) )	inputY = 3;
		if( api.AKApi.isToggled( flash.ui.Keyboard.SPACE ) )	{
			var b = Game.me.inter.bonusKind;
			if( b != null ) {
				applyBonus(b);
				Game.me.inter.removeBonus();
			}
		}
		//
		super.update();
		//
		switch(step) {
			case VOID :
				checkMove();
			case MOVE :
				// AUTO RETURN
				var input = -1;
				if( inputX >= 0 && (inputX + 2) % 4 == dir ) input = inputX;
				if( inputY >= 0 && (inputY + 2) % 4 == dir ) input = inputY;
				if( input >= 0 ) {
					var d = Cs.DIR[dir];
					setSquare(square.x + d[0], square.y + d[1]);
					setDir(input);
					moveCoef = 1 - moveCoef;
					updateSquarePos();
				}
			default :
		}
	}
	
	function checkMove() {
		var jump = false;
		if( square.getWall(inputX) == 1 ) {
			jump = !square.dnei[inputX].isBlock() && canJump();
			if( jump && !jumpReady ) {
				jump = false;
				jumpReady = true;
			}
			if( !jump ) inputX = -1;
		}
		
		if( square.getWall(inputY) == 1 ) {
			jump = !square.dnei[inputY].isBlock() && canJump();
			if( jump && !jumpReady ) {
				jump = false;
				jumpReady = true;
			}
			if( !jump ) inputY = -1;
		}
		
		if( inputX == -1 && inputY == -1 ) {
			step = VOID;
			if( skin.anim != null ) skin.anim.stop();
			moveCoef = 0;
			updateSquarePos();
			return;
		}
		
		var input = inputY;
		if( input == -1 ) input = inputX;
		if( square.getWall(input) == 2 ) square.door.flip(input == square.doorDir);
		
		setDir(input);
		step = MOVE;
		
		if( jump ) {
			step = JUMPING;
			jumpReady = false;
		}
		updateSquarePos();
	}
	
	override function setDir(di) {
		super.setDir(di);
		//
		updateSkin();
	}
	
	override function onEnterSquare() {
		checkMove();
		// HERODIST
		majHeroDist();
		square.htrack = 5;
	}
	
	override function onReach() {
		var next = square.dnei[dir];
		// COINS
		if( next.coin != null ) {
			next.removeCoin(true);
			//
			var base = Cs.SCORE_BALL.get();
			var inc = Cs.SCORE_BALL_INC.get();
			var max = Cs.SCORE_BALL_MAX.get();
			var score = base + inc * multi;
			if( score > max ) score = max;
			Game.me.addScore( score, root.x, root.y);
			multi++;
		} else {
			multi = 1;
		}
	}
	
	override function updatePos() {
		super.updatePos();
		root.y -= 3;
	}
	
	public function majHeroDist() {
		Game.me.buildDistFrom(square);
	}
	
	/*
	public function majHeroDist() {
		for( sq in Game.me.squares ) sq.hdist = 999;
		square.hdist = 0;
		var work = [square];
		while(work.length> 0 ) work = expand(work);
	}
	function expand(work:Array<Square>) {
		var a = [];
		for( sq in work ) {
			var hdist = sq.hdist + 1;
			for( di in 0...4 ) {
				var nsq = sq.dnei[di];
				if( nsq == null || nsq.hdist <= hdist || sq.getWall(di) > 0 ) continue;
				nsq.hdist = hdist;
				a.push(nsq);
			}
		}
		return a;
		
	}
	*/
}

