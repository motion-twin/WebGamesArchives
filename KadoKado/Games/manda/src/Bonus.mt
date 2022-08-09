class Bonus extends Item {

	static var CISEAUX_COUNT = 1;
	static var POTION_BLEUES = 0;

	function new(id,mc) {
		super(id,mc,7+(Std.random(300)/100));
	}

	function activate( g : Game ) {
		var x = mc._x;
		var y = mc._y;
		mc.removeMovieClip();

		var i;
		switch( id ) {
		case 0: // CISEAUX
			for(i=0;i<CISEAUX_COUNT,g.snake.len > 0;i++)
				g.snake.explode(g.snake.getColor());
			CISEAUX_COUNT++;
			break;
		case 1: // COFFRE
			var nfruits = 5 + Std.random(5);
			for(i=0;i<nfruits;i++) {
				var f = g.level.generateFruit();
				f.setPos(x,y);
				f.add_queue = false;
				f.jumpNear(Std.random(20)+20,Std.random(10)+15,0.05,Const.LEVEL_BOUNDS);
			}
			break;
		case 2: // POTION BLEUE
			var time = 15;
			POTION_BLEUES++;
			g.snake.blue = true;		
			g.snake.blue_flag = true;
			var fupdate;
			fupdate = fun() {
				time -= Timer.deltaT;
				if( time < 2 && POTION_BLEUES == 1 && (g.fcounter & 2) == 0 )
					g.snake.blue_flag = false;
				else
					g.snake.blue_flag = true;
				if( time < 0 ) {					
					if( (--POTION_BLEUES) == 0 )
						g.snake.blue = false;
					Manager.updates.remove(fupdate);
				}
			};
			Manager.updates.push(fupdate);
			break;
		case 3: // CANNE
			var f = g.level.generateFruit();
			var pts = KKApi.cmult(f.points(),Const.C10);			
			f.setPos(Const.WIDTH/2,Const.HEIGHT/2);
			f.mc.gotoAndStop("standard");
			f.z = 100;
			f.scale *= 2;
			f.fall(0.08);			
			f.points = fun() { return pts };
			break;
		case 4: // MOLECULE
			var _ = new PopScore(x,y,3000,g.dmanager.empty(Const.PLAN_POPSCORE));
			KKApi.addScore(Const.C3000);
			g.fbarre += 10;
			if( g.fbarre > Const.FBARRE_MAX )
				g.fbarre = Const.FBARRE_MAX;
			break;
		case 5: // PLUME
			g.snake.speed -= 1.0;
			if( g.snake.speed < Const.SNAKE_MIN_SPEED )
				g.snake.speed = Const.SNAKE_MIN_SPEED;
			break;
		case 6: // CLOCHE
			if( g.fcloche != null )
				return;
			var n = g.snake.len;
			g.fcloche = fun() {
				if( g.snake.len <= 0 || n <= 0 ) {
					g.fcloche = null;
					return;
				}
				var p = g.snake.endQueuePos(0);	
				if( g.snake.len % 2 == 0 )  {
					var f = g.level.generateFruit();
					f.id = 75;
					f.mc._x = p.x;
					f.mc._y = p.y;
					downcast(f.mc).f.gotoAndStop(76);
				}
				g.snake.explode(g.snake.getColor());
				g.snake.draw();
				n--;
			};			
			break;
		case 7: // JACKPOT:
			g.jackpot.start();
			break;
		}
	}

}