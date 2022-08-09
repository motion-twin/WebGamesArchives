class Words {

	var tbl : Array<String>;
	var nwords : int;

	function new(lens : Array<int>) {
		Dico.init();

		tbl = new Array();
		var i;
		for(i=0;i<lens.length;i++) {
			var n = lens[i];
			while( n > 0 ) {
				var w = generate(i+2);
				if( w != null )
					tbl.push(w);
				n--;
			}
		}
		nwords = tbl.length;
	}

	function generate(l : int) : String {
		var max = Dico.LENGTHS[l].length;
		var n = Std.random(max);
		var w = Dico.LENGTHS[l][n];
		return w.substring(1);
	}

	function get() {		
		var n = Std.random(tbl.length);		
		var w = tbl[n];
		tbl.splice(n,1);
		return w;
	}

}