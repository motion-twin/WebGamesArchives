class Game {

	var bg : MovieClip;
	var interf : DepthManager;
	var dmanager : DepthManager;
	var snake : Snake;
	var level : Level;
	var game_over_flag : bool;
	volatile var fcounter : int;
	volatile var fbarre : float;
	var jackpot : Jackpot;
	volatile var nfruits : int;
	var fcloche : void -> void;

	function new(mc) {
		bg = Std.attachMC(mc,"bg",0);
		dmanager = new DepthManager(Std.createEmptyMC(mc,1));
		interf = new DepthManager(Std.createEmptyMC(mc,2));
		var mask = Std.attachMC(mc,"bgMask",3);
		mask._x = 5;
		mask._y = 5;
		dmanager.getMC().setMask(mask);
		level = new Level(this);
		jackpot = new Jackpot(this);
		snake = new Snake(dmanager, { x : 0, y : 0 });
		snake.ang = Math.PI / 4;
		fcounter = 0;
		fbarre = 0;
		nfruits = 0;
	}

	function pad(s : String,n) {
		while( s.length < n )
			s = "0"+s;
		return s;
	}

	function main() {
		fcounter++;
		if( game_over_flag ) {
			gameOverMain();
			return;
		}
		gameMain();

		// CHECK CHEAT
		if( level.fl != level.fruits.length )KKApi.flagCheater();
	}

	function eatFruit(f : Fruit) {
		if( f.isMoving() )
			return false;

		var pts = f.points();
		// 80+Std.random(20)-10,282+Std.random(6)-3
		var _ = new PopScore(f.mc._x,f.mc._y,KKApi.val(pts),dmanager.empty(Const.PLAN_POPSCORE));
		jackpot.addFruit(f.id);
		if( f.add_queue )
			snake.addQueue();
		f.destroy();
		nfruits++;
		KKApi.addScore(pts);
		fbarre += Const.FBARRE_FRUIT_EAT;
		if( fbarre > Const.FBARRE_MAX )
			fbarre = Const.FBARRE_MAX;
		return true;
	}

	function gameMain() {
		var tmod = Timer.tmod;
		if( Key.isDown(Key.LEFT) )
			snake.ang -= snake.delta_ang * Math.pow(snake.speed / Const.SNAKE_DEFAULT_SPEED,0.5) * tmod;
		if( Key.isDown(Key.RIGHT) )
			snake.ang += snake.delta_ang * Math.pow(snake.speed / Const.SNAKE_DEFAULT_SPEED,0.5) * tmod;

		snake.base_speed *= Math.pow(Const.FRICTION,tmod);
		if( Key.isDown(Key.UP) )
			snake.base_speed = Const.SNAKE_FAST_SPEED_COEF;
		if( snake.base_speed < 1 )
			snake.base_speed = 1;

		fcloche();
		var hit = snake.move(Const.LEVEL_BOUNDS);
		if( hit )
			game_over_flag = true;

		snake.speed += Const.SNAKE_SPEED_INCREMENT * tmod;
		level.main();
		jackpot.main();
		snake.draw();
	}

	function gameOverMain() {
		if( snake.len >= 0 ) {
			var timer = 4;
			if( snake.len > 10 )
				timer = 3;
			if( snake.len > 50 )
				timer = 2;
			if( snake.len > 100 )
				timer = 1;
			if( fcounter % Math.max(1,int(timer/Timer.tmod)) == 0 )
				snake.explode(snake.getColor());
			snake.draw();
		} else {
			snake.tete._visible = false;
			KKApi.saveScore({ $f : nfruits, $j2 : jackpot.count2, $j3 : jackpot.count3 });
		}
		level.main();
	}

	function destroy() {
		dmanager.destroy();
	}

}