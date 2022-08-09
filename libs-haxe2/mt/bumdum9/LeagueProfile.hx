package mt.bumdum9;


typedef LeagueSlot = { users:Int, up:Int, down:Int };

class LeagueProfile {//}
	
	public var rankMax:Int;		// nombre de rangs maximum de la league
	public var size:Int;		// taille maximum de chaque groupe
	public var climb:Int;		// objectifs de passage au niveau superieur ( niveau inderieur = climb*ratio )
	public var ratio:Float;		// determine l'ecrasement des leagues
	
	public function new() {
		rankMax = 9;
		size = 50;
		climb = 3;
		ratio = 2;
	}

	public function build(users:Array<Int>) {
		
		var leagues = [];
		for( i in 0...rankMax ) leagues.push([]);
		
		// SHRINK IF USER LENGTH > RANK MAX
		while( users.length > rankMax ) {
			var n = users.pop();
			users[users.length-1] += n;
		}
		
		
		// BUILD LEAGUES
		for( i in 0...users.length ) {
			
			var tot = users[i];
			var max = Math.ceil(tot / size);
			
			if( i > 0 ) {
				var obj = getObj(i);
				if( max > obj ) max = obj;
			}
			
			var rep = Std.int(tot / max);
			for( k in 0...max )	leagues[i].push( { users:rep, up:climb, down:0 } );

			// ADD EXTRA
			var extra = tot - (rep * max);
			var id = 0;
			while( extra-- > 0 ) {
				leagues[i][id % leagues[i].length].users++;
				id++;
			}

		}
		
		// ADJUST UP/DOWN
		for( i in 0...rankMax ) {
			var id = rankMax - i - 1;
			if( id == 0 ) continue;
			
			var row = leagues[id];
			if( row.length == 0 ) continue;

			// CHECK NEXT TOTAL
			var tot = 0;
			for( o in row ) tot += o.users;
			tot += leagues[id - 1].length * climb;
			if( id < rankMax-1) tot -= row.length * climb;
			var above = leagues[id + 1];
			if( above != null ) {
				var down = 0;
				for( o in above ) down += o.down;
				tot += down;
			}
			
			// ADJUST DOWN
			var obj = getObj(id);
			var n = tot - obj * size;
			if( n > 0 ) {
				var rep = Std.int(n / row.length);
				for( o in row ) o.down = rep;

				var extra = n - (row.length * rep);
				var id = 0;
				while( extra-- > 0 ) {
					row[id % row.length].down++;
					id++;
				}
					
				for( o in row ) if( o.down > o.users - o.up ) o.down = o.users - o.up;
			}
			
			// ADJUST UP
			if( id == rankMax-1 ) for( o in row ) o.up = 0;
			
			if( n < 0 ) {
				var up = (row.length * climb < size)?0:climb;
				for( o in row ) o.up = up;
				
			}
			
			
		}
		
		
			/*
			var under =  leagues[id - 1];
			var count = under.length * LEAGUE_CLIMB_BOOST;
			while( n++ < 0 && count-- > 0 ) under[count % under.length].up++;
			*/
		
		return leagues;
		
	}
	
	
	function getObj(rank) {
		return Std.int(Math.pow(ratio, (rankMax-rank-1)));
	}
	

		
//{
}


















