

typedef ZoneInfos = {
	var zombies : Int ;
	var zombieKills : Int ;
	var deads : Int ;
}


class Day {
	
	public var day : Int ;
	public var infos : Array<Array<ZoneInfos>> ;

	public function new(d : Int) {
		day = d ;
		stockInfos() ;
	}
	
	function stockInfos() {
		infos = new Array() ;
		
		for (x in 0...Map.SIZE) {
			infos[x] = new Array() ;
			for (y in 0...Map.SIZE) {
				infos[x][y] = Map.me.grid[x][y].getInfos() ;
			}
		}
		
	}
	
}