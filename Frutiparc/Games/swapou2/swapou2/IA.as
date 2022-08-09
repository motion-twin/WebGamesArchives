import swapou2.Data;

class swapou2.IA {

	var level;
	var combos,cur_pair;
	var width,height;
	var cur_swap,swaps,swap_pos;

	function IA( level : swapou2.Level ) {
		this.level = level;
		combos = null;
		width = level.getWidth();
		height = level.getHeight();
		cur_swap = null;
		swaps = null;
	}

	function processStart( hlock ) {
		combos = new Array();
		swaps = new Array();
		var x,y;
		for(x=0;x<width;x++)
			for(y=0;y<height;y++) {
				if( !hlock && x < width - 1 ) {
					var f1 = level.getFruit(x,y);
					var f2 = level.getFruit(x+1,y);
					if( f1.canSwap() && f2.canSwap() )
						swaps.push( { x : x, y : y, dx : 1, dy : 0, f1 : f1, f2 : f2 } );
				}
				if( y < height - 1 ) {
					var f1 = level.getFruit(x,y);
					var f2 = level.getFruit(x,y+1);
					if( f1.canSwap() && f2.canSwap() )
						swaps.push( { x : x, y : y, dx : 0, dy : 1, f1 : f1, f2 : f2 } );
				}
			}
		swaps.shuffle();
		swap_pos = swaps.length - 1;
	}

	private static function sort_by_score(c1,c2) {
		return c1.score - c2.score;
	}

	private function makeCombo(p,c) {
		var n = 0;
		var i,j;
		for(i=0;i<c.length;i++) {
			var ci = c[i];
			for(j=0;j<ci.length;j++)
				n += ci[j].v;
		}
		var h = level.calcAvgHigh();
		var score =  - h + n / 5;
		return { p : p , c : c, h : h, n : n, score : score, combos : c };
	}

	function process(n) {

		if( cur_swap != null ) {
			var c = level.calcNext(cur_swap.data);
			if( c != null ) {
				var p = cur_swap.p;
				cur_swap = null;
				combos.push( makeCombo(p,c) );
				level.swapPair(p);
			}
			return null;
		}

		if( swap_pos < 0 )
			return chooseCombo();

		var p = swaps[swap_pos--];
		if( level.swapPair(p) ) {
			var data = level.calcStart();
			if( data != null )
				cur_swap = { data : data, p : p };
			else
				level.swapPair(p);
		} else if( n == 0 )
			return null;
		else
			return process(n-1);

		return null;
	}

	function chooseCombo() {
		if( combos.length == 0 ) { // rien trouvé !
			var i = 0;
			while( !level.swapPair(swaps[i]) )
				i++;
			level.swapPair(swaps[i]);
			return swaps[i];
		}
		combos.sort(sort_by_score);
		var c = combos[combos.length - 1];
		return c.p;
	}


	function processEnd() {
		if( cur_swap != null ) {
			level.calcEnd(cur_swap.data);
			level.swapPair(cur_swap.p);
			cur_swap = null;
		}
		return chooseCombo();
	}

}