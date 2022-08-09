class RandomManager
{
	var bulks		: Array<Array<int>>;
	var expanded	: Array<Array<int>>;

	var sums		: Array<int>;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		bulks		= new Array();
		expanded	= new Array();
		sums 		= new Array();
	}


	/*------------------------------------------------------------------------
	AJOUTE UN TABLEAU
	------------------------------------------------------------------------*/
	function register(id, bulk) {
		bulks[id] = bulk;
		computeSum(id);
//		expand(id);
	}


	/*------------------------------------------------------------------------
	COMPUTE SUM OF ALL ELEMENTS IN A BULK ARRAY
	------------------------------------------------------------------------*/
	function computeSum(id) {
		sums[id]=0;
		for (var i=0;i<bulks[id].length;i++) {
			if ( bulks[id][i]==null ) {
				bulks[id][i]=0;
			}
			sums[id] += bulks[id][i];
		}
	}


	/*------------------------------------------------------------------------
	CRÉATION DU CACHE
	------------------------------------------------------------------------*/
	function expand(id) {
		expanded[id] = new Array();
		for (var i=0;i<bulks[id].length;i++) {
			for (var j=0;j<bulks[id][i];j++) {
				expanded[id].push(i);
			}
		}
	}


	/*------------------------------------------------------------------------
	TIRAGE
	------------------------------------------------------------------------*/
	function draw(id) {
		// light system
		var tab		= bulks[id];
		var i		= 0;
		var target	= Std.random(sums[id]);
		var sum		= 0;
		var result	= null;
		while (i<tab.length && result==null) {
			sum+=tab[i];
			if ( target<sum ) {
				result = i;
			}
			i++;
		}

		if ( result==null ) {
			GameManager.warning("null draw in array "+id);
		}

		return result;

		// deprecated expanded system
//		return expanded[id][ Std.random(expanded[id].length) ];
	}


	/*------------------------------------------------------------------------
	RENVOIE LES CHANCES DE TIRER LA VALEUR DONNÉE (ratio / 1)
	------------------------------------------------------------------------*/
	function evaluateChances(id:int,value:int) {
//		var chance	= 1;
//		var tab		= bulks[id];
//		var i		= 0;
//		var sum		= 0;
//		var total	= sums[id];
		Log.trace("item="+value);
		Log.trace(bulks[id][value]);
		Log.trace(sums[id]);
		return bulks[id][value] / sums[id];
	}


	function remove(rid:int, id:int) {
		bulks[rid][id] = 0;
		computeSum(rid);
	}



	function drawSpecial() {
		//
	}
}
