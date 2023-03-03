import snake3.Const;
import snake3.Manager;

class snake3.bonus.FlecheBleue {

	var game;
	var ang;
	var x,y,id;

	function FlecheBleue( game : snake3.Game, ang, x, y ) {
		this.x = x;
		this.y = y;
		this.id = game.gen_fruit_id();
		this.ang = ang * Math.PI / 180;
		this.game = game;
		game.updates.push(this,update);
	}

	function close() {
		game.updates.remove(this,update);
	}

	function update() {
		x += Math.cos(ang) * Const.FLECHE_BLEUE_GENSPEED;
		y += Math.sin(ang) * Const.FLECHE_BLEUE_GENSPEED;

		var b = game.level.bounds();
		if( x - 50 <= b.left || y - 50 <= b.top || x + 50 >= b.right || y + 50 >= b.bottom )
			close();
		
		var f : snake3.Fruit = game.gen_fruit();
		if( id == Const.FRUIT_MAX )
			id--;
		f.on_eat = undefined;
		f.set_id(id++);
		f.set_pos(x,y);
	}

}