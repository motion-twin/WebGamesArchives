class Level {//}

	var game : Game;
	var legumes : Array<Array<Legume>>;
	var width : int;
	var height : int;

	function new( g ) {
		width = Const.WIDTH;
		height = Const.HEIGHT;
		game = g;
		legumes = new Array();
		var i;
		for(i=0;i<width;i++)
			legumes[i] = new Array();
	}

	function genLine() {
		var i;
		for(i=0;i<width;i++)
			genPushLegume(i,null);
	}

	function genPushLegume(x,l : Legume) {
		var y;		
		if( legumes[x][0] != null )
			return false;
		for(y=1;y<height;y++) {
			var ltmp = legumes[x][y];
			legumes[x][y-1] = ltmp;
			game.animator.moveUp(ltmp);
		}
		if( l == null ) {
			l = new Legume(game,game.randId(),x,height);
			game.animator.moveUp(l);
		}
		legumes[x][height-1] = l;
		return true;
	}

	function popLegume(x,id) {
		var y;
		for(y=0;y<height;y++) {
			var l = legumes[x][y];
			if( l != null ) {				
				if( (l.id == id || id == null) && id != Const.PIERRE && l.id != Const.BULLE ) {
					legumes[x][y] = null;
					return l;
				}
				return null;
			}
		}
		return null;
	}

	function freeHeight(x) {
		var y;
		for(y=0;y<height;y++)
			if( legumes[x][y] != null )
				break;
		return y;
	}

	function maxHeight() {
		var x;
		var y;
		var max = 0;
		for(x=0;x<width;x++) {
			for(y=0;y<height;y++) {
				if( legumes[x][y] != null )
					break;
			}
			if( height - y > max )
				max = height - y;
		}
		return max;
	}

	function pushLegume(x,l) {
		var y;
		for(y=0;y<height;y++)
			if( legumes[x][y] != null )
				break;		
		y--;
		if( y >= 0 )
			legumes[x][y] = l;
		return y;
	}

	function explode_rec(c : Array<Legume>, b : Array<{ x : int, y : int, l : Legume }>, x : int,y : int,id : int) {
		var f = legumes[x][y];
		legumes[x][y] = null;
		f.moved = false;
		c.push(f);
		
		f = legumes[x][y-1];
		if( f.id == id )
			explode_rec(c,b,x,y-1,id);
		else {
			f.blast = false;
			b.push({ x : x, y : y-1, l : f});
		}

		f = legumes[x][y+1];
		if( f.id == id )
			explode_rec(c,b,x,y+1,id);
		else {
			f.blast = false;
			b.push({ x : x, y : y+1, l : f});
		}

		f = legumes[x-1][y];
		if( f.id == id )
			explode_rec(c,b,x-1,y,id);
		else {
			f.blast = false;
			b.push({ x : x-1, y : y, l : f});
		}

		f = legumes[x+1][y];
		if( f.id == id )
			explode_rec(c,b,x+1,y,id);
		else {
			f.blast = false;
			b.push({ x : x+1, y : y, l : f});
		}
	}

	function explode_scan(x,y,id) {
		var count = 1;
		var tmp_x = x;
		var tmp_y;		
		tmp_y = y + 1;
		while( legumes[x][tmp_y].id == id ) {
			tmp_y++;
			count++;
		}
		if( count < 3 ) {
			tmp_y = y - 1;
			while( legumes[x][tmp_y].id == id ) {
				tmp_y--;
				count++;
			}
		}
		if( count >= 3 ) {
			var c = new Array();
			var blasted = new Array();
			explode_rec(c,blasted,x,y,id);
			return { x : c, b : blasted };
		}
		return null;
	}

	function blast(a,x,y) {
		var l = legumes[x][y];
		if( l == null )
			return;
		a.push({ x : x, y : y, l : l });
	}

	function explodes() {
		var x,y;
		var count;
		var exlist = new Array();
		var blist = new Array();
		var i,j;
		var golds = new Array();

		for(x=0;x<width;x++) {
			var legs = legumes[x];
			for(y=0;y<height;y++) {
				var l = legs[y];
				if( l.moved ) {
					l.moved = false;
					if( l.id == Const.PIERRE )
						continue;
					var c = explode_scan(x,y,l.id);
					if( c != null ) {
						for(i=0;i<c.x.length;i++)
							if( c.x[i].gold ) {
								golds.push(l.id);
								break;
							}
						exlist.push(c.x);
						blist.push(c.b);
					}
				}
			}
		}
		if( exlist.length == 0 )
			return null;

		var gblasts = new Array();
		for(i=0;i<golds.length;i++) {
			var e = new Array();
			game.stats.$g[golds[i]]++;
			for(x=0;x<width;x++)
				for(y=0;y<height;y++) {
					var l = legumes[x][y];
					if( l.id == golds[i] ) {
						legumes[x][y] = null;
						e.push(l);
						blast(gblasts,x,y-1);
						blast(gblasts,x,y+1);
						blast(gblasts,x-1,y);
						blast(gblasts,x+1,y);
					}
				}
			if( e.length != 0 )
				exlist.push(e);
		}
		blist.push(gblasts);

		for(i=0;i<blist.length;i++) {
			var b = blist[i];
			for(j=0;j<b.length;j++) {
				var m = b[j];
				if( m.l.blast )
					continue;
				m.l.blast = true;
				switch( m.l.id ) {
				case Const.PIERRE:
					if( !m.l.stoneParts() )
						legumes[m.x][m.y] = null;
					break;
				case Const.BONUS1:
				case Const.BONUS2:
					game.animator.destroyLegume(m.l);
					legumes[m.x][m.y] = null;
					break;
				}
			}
		}
		return { combos : exlist };
	}

	function gravity() {
		var x,y;
		var glist = new Array();
		for(x=0;x<width;x++) {
			var legs = legumes[x];
			for(y=height-1;y>0;y--)
				if( legs[y] == null )
					break;
			y--;
			while( y >= 0 ) {
				var l = legs[y];
				if( l != null ) {
					l.moved = true;
					legs[y+1] = l;
					legs[y] = null;
					glist.push(l);
				}
				y--;
			}
		}
		if( glist.length == 0 )
			return null;
		return glist;
	}

	function explodeBulles() {
		var x,y;
		var bulles = new Array();
		for(x=0;x<width;x++) {
			var legs = legumes[x];
			var moved = false;
			for(y=0;y<height;y++)
				if( moved && legs[y].id == Const.BULLE ) {
					bulles.push(legs[y]);
					legs[y] = null;
				} else if( legs[y].moved )
					moved = true;				
		}
		if( bulles.length == 0 )
			return null;
		return bulles;
	}
//{
}