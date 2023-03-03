import snake3.Const;

class snake3.bonus.Croix {

	var game;
	var dist;
	var sx,sy,id;

	function Croix( game : snake3.Game, x, y ) {
		this.sx = x;
		this.sy = y;
		this.dist = 10;
		this.id = game.gen_fruit_id();
		this.game = game;
		game.updates.push(this,update);
	}

	function close() {
		game.updates.remove(this,update);
	}

	function gen_fruit(ang) {
		var x = sx + Math.cos(ang)*dist;
		var y = sy + Math.sin(ang)*dist;
		var b = game.level.bounds();

		if( x - 10 <= b.left || y - 10 <= b.top || x + 10 >= b.right || y + 10 >= b.bottom )
			return false;
		
		var f : snake3.Fruit = game.gen_fruit();
		f.set_id(id);
		f.set_pos(x,y);
		f.on_eat = undefined;
		return true;
	}

	function update() {
		dist += Const.CROIX_GENSPEED;

		var flag = false;
		if( gen_fruit(Math.PI/4) )
			flag = true;
		if( gen_fruit(Math.PI*3/4) )
			flag = true;
		if( gen_fruit(-Math.PI*3/4) )
			flag = true;
		if( gen_fruit(-Math.PI/4) )
			flag = true;

		if( !flag )
			close();

		if( id == Const.FRUIT_MAX )
			id--;
		id++;
	}

}