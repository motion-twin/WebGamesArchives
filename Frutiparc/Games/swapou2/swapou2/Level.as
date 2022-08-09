import swapou2.Data ;

class swapou2.Level {

	static var static_id_gen = 0;
	public var min_combo;

	var fruits;
	var width,height;
	var gen_fruit_flags;
	var gen_fruit_color;
	var animator : swapou2.AnimatorChallenge;
	var anim_infos;

	function Level( infos, animt ) {
		width = infos.width;
		height = infos.height;
		min_combo = infos.min;
		gen_fruit_flags = infos.gen_fruit_flags;
		gen_fruit_color = infos.gen_fruit_color;
		animator = animt;

		this.anim_infos = animator.getInfos();

		fruits = new Array();
		var x,y;
		for(x=0;x<width;x++) {
			fruits[x] = new Array();
			for(y=0;y<height;y++)
				fruits[x][y] = null;
		}
	}

	function getWidth() {
		return width;
	}

	function getHeight() {
		return height;
	}

	function getFruits() {
		return fruits;
	}

	function dbg() {
		var x,y;
		for(x=0;x<width;x++)
			for(y=0;y<height;y++) {
				var f = fruits[x][y];
				f.dbg = (f.combo == null)?0:f.combo.v;
			}
	}

	function genLine() {
		var x,y;
		for(x=0;x<width;x++)
			if( fruits[x][0] != null )
				return false;

		for(x=0;x<width;x++)
			for(y=1;y<height;y++) {
				var f = fruits[x][y];
				fruits[x][y-1] = f;
				fruits[x][y] = null;
				animator.moveUp(f);
			}

			y = height - 1;
			for(x=0;x<width;x++) {
				var color;

				do {
					color = gen_fruit_color();
				} while( color == fruits[x][y-1].t || color == fruits[x-1][y].t );

				var flags = gen_fruit_flags();
				if( (flags & Data.FLAG_SET_COLOR) != 0 ) {
					color = flags >> 8;
					flags = 0;
				}
				var f : swapou2.Fruit = animator.attachFruit(x,y+1,color,flags);
				fruits[x][y] = f;
				animator.moveUp(f);
			}
			return true;
	}



	function getPair(x,y) {
		var fx = int((x - anim_infos.px) / anim_infos.sx);
		var fy = int((y - anim_infos.py) / anim_infos.sy);
		if( fruits[fx][fy] == null )
			return null;
		x -= fx * anim_infos.sx + anim_infos.px;
		y -= fy * anim_infos.sy + anim_infos.py;
		x /= anim_infos.sx;
		y /= anim_infos.sy;
		var dx = 0, dy = 0;
		if( x > 1-y ) {
			if( x > y )
				dx = 1;
			else
				dy = 1;
		} else {
			if( x > y )
				dy = -1;
			else
				dx = -1;
		}
		return {
			x : fx,
			y : fy,
			dx : dx,
			dy : dy,
			f1 : fruits[fx][fy],
			f2 : fruits[fx+dx][fy+dy]
		};
	}

	function getFruit(x,y) {
		return fruits[x][y];
	}

	function swapPair(p) {
		if( p == null )
			return false;
		var y2 = p.y+p.dy;
		var f1 = fruits[p.x][p.y];
		var f2 = fruits[p.x+p.dx][y2];
		if( f1 == null || f2 == null || !f1.canSwap() || !f2.canSwap()  )
			return false;
		fruits[p.x][p.y] = f2;
		fruits[p.x+p.dx][y2] = f1;
		return true;
	}

	function calc_rec(t,x,y,c) {
		c.v++;
		fruits[x][y].combo = c;
		var f;
		f = fruits[x-1][y];
		if( f.t == t && f.combo == null )
			calc_rec(t,x-1,y,c);
		f = fruits[x+1][y];
		if( f.t == t && f.combo == null )
			calc_rec(t,x+1,y,c);
		f = fruits[x][y-1];
		if( f.t == t && f.combo == null )
			calc_rec(t,x,y-1,c);
		f = fruits[x][y+1];
		if( f.t == t && f.combo == null )
			calc_rec(t,x,y+1,c);
	}

	function calcMinCombos(n) {
		var old_min = min_combo;
		min_combo = n;
		var combos = calc();
		min_combo = old_min;
		return combos;
	}

	function calc() {
		var x,y;
		var combos = new Array();
		for(x=0;x<width;x++) {
			var a = fruits[x];
			for(y=0;y<height;y++)
				a[y].combo = null;
		}
		for(x=0;x<width;x++)
			for(y=0;y<height;y++) {
				var f = fruits[x][y];
				if( f != null && f.combo == null ) {
					var c = { v : 0, x : x, y : y };
					if( !f.has_armure ) {
						calc_rec(f.t,x,y,c);
						if( c.v >= min_combo )
							combos.push(c);
					} else {
						c.v++;
						f.combo = c;
					}
				}
			}
		if( combos.length == 0 )
			return null;
		return combos;
	}

	function explode_rec(l,l2,c,x,y) {
		var f = fruits[x][y];
		f.combo = null;
		l.push(f);
		fruits[x][y] = null;

		f = fruits[x-1][y];
		if( f.combo == c )
			explode_rec(l,l2,c,x-1,y);
		else if( f.has_armure ) {
			f.has_armure = false;
			l2.push(f);
		}

		f = fruits[x+1][y];
		if( f.combo == c )
			explode_rec(l,l2,c,x+1,y);
		else if( f.has_armure ) {
			f.has_armure = false;
			l2.push(f);
		}

		f = fruits[x][y-1];
		if( f.combo == c )
			explode_rec(l,l2,c,x,y-1);
		else if( f.has_armure ) {
			f.has_armure = false;
			l2.push(f);
		}

		f = fruits[x][y+1];
		if( f.combo == c )
			explode_rec(l,l2,c,x,y+1);
		else if( f.has_armure ) {
			f.has_armure = false;
			l2.push(f);
		}
	}

	function explode(combos) {
		var l = new Array();
		var l2 = new Array();
		var i;
		for(i=0;i<combos.length;i++) {
			var c = combos[i];
			explode_rec(l,l2,c,c.x,c.y);
		}
		if( l.length == 0 )
			return null;
		return { mcs : l, combos : combos, pete_armures : l2 };
	}

	function addFruit(x,color,flags) {
		var y;
		for(y=0;y<height;y++)
			if( fruits[x][y] != null )
				break;
		if( y == 0 )
			return null;
		y--;
		var f = animator.attachFruit(x,y,color,flags);
		fruits[x][y] = f;
		return f;
	}

	function calcStart() {
		var x,y;
		var tmp = calc();

		if( tmp == null )
			return null;

		var combos = new Array();
		var save = new Array();
		var f;
		for(x=0;x<width;x++) {
			var a = fruits[x];
			var save_x = new Array();
			save[x] = save_x;
			for(y=0;y<height;y++) {
				f = a[y];
				save_x[y] = f;
			}
		}
		return { tmp : tmp, save : save, combos : combos };
	}

	function calcEnd(data) {
		fruits = data.save;
		var x,y;
		var f;
		for(x=0;x<width;x++) {
			var a = fruits[x];
			for(y=0;y<height;y++) {
				f = a[y];
				f.has_armure = ((f.flags & Data.FLAG_ARMURE) != 0);
				if( f.has_armure )
					f.t = -1;
			}
		}
		return data.combos;
	}

	function calcNext(data) {
		var c;
		if( data.tmp != null ) {
			c = explode(data.tmp);
			data.combos.push(c.combos);
			gravity();
			data.tmp = calc();
			if( data.tmp != null )
				return null;
		}
		return calcEnd(data);
	}

	function calcAvgHigh() {
		var y,x;
		var highs = new Array();
		var moy = 0;
		for(x=0;x<width;x++) {
			var h = 0;
			for(y=height-1;y>=0;y--) {
				var f = fruits[x][y];
				if( f == null )
					break;
				if( f.combo.v < min_combo )
					h++;
			}
			highs[x] = h;
			moy += h;
		}
		moy /= width;
		var ecart = 0;
		for(x=0;x<width;x++) {
			var d = highs[x] - moy;
			ecart += d*d;
		}
		return Math.sqrt(ecart+moy);
	}

	function gravity() {

		var l = new Array();
		var i,x,y;
		var f,delta_y;
		for(x=0;x<width;x++) {
			var fx = fruits[x];
			y = height - 1;
			delta_y = 0;
			while(true) {
				while( y >= 0 && fx[y] == null ) {
					y--;
					delta_y++;
				}
				if( y < 0 )
					break;
				if( delta_y > 0 )
					while( (f = fx[y]) != null ) {
						fx[y+delta_y] = f;
						fx[y] = null;
						l.push( { f : f, delta : delta_y } );
						y--;
					}
				else
					while( fx[y] != null )
						y--;
			}
		}
		if( l.length == 0 )
			return null;
		return l;
	}

	function popBottomFruit(x) {
		var f = fruits[x][height-1];
		var y = height - 2;
		while( fruits[x][y] != null ) {
			fruits[x][y+1] = fruits[x][y];
			y--;
		}
		fruits[x][y+1] = null;
		return f;
	}

	function pushBottomFruit(x,f) {
		var y;
		fruits[x][0].destroy();
		for(y=1;y<height;y++)
			fruits[x][y-1] = fruits[x][y];
		if( f == null ) {
			var color = gen_fruit_color();
			var flags = gen_fruit_flags();
			if( (flags & Data.FLAG_SET_COLOR) != 0 ) {
				color = flags >> 8;
				flags = 0;
			}
			f = animator.attachFruit(x,height-1,color,flags);
		}
		fruits[x][height-1] = f;
		return f;
	}

	function destroy() {
		var x,y;
		for(x=0;x<width;x++)
			for(y=0;y<height;y++)
				fruits[x][y].destroy();
	}

}