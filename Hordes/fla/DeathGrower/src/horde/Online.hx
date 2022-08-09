package horde ;


class Online {
	
	
	
	static public function process(map : Map) {
		var zones = new Array() ;
		var baseZones = new Array() ;
		for(x in 0...Map.SIZE) {
			for(y in 0...Map.SIZE) {
				var z = map.grid[x][y] ;
				baseZones.push(z) ;
				if (z.isTown() || z.zombies == 0)
					continue ;
				zones.push(z) ;
			}
		}
		
		
		while(zones.length > 0) {
			var z = zones.pop() ;
			if (z == null)
				continue ;
			
			var x = z.x ;
			var y = z.y ;
			
			
			if (z.zombies >= Cs.ZombieGrowThreshold) {
				var adjacentZones = Lambda.array( Lambda.filter( baseZones, function( az: Zone ) {
					if( az.isTown() || az.zombies >= Cs.ZombieGrowThreshold )
						return false;
					if( x==az.x && y==az.y )
						return false;
					if( Zone.getZoneLevel(  { x:x, y:y }, {x:az.x,y:az.y} ) == 1 )
						return true;
					return false;
				} ) );
				
				

				if( adjacentZones.length <= 0 ) {
					z.addZombie(1) ;
					continue;
				}
				
				var zombieS = Cs.ZombieSpreaded ;
				while( zombieS > 0 ) {
					var spreadZone = adjacentZones[ Std.random( adjacentZones.length) ];
					var spreadedZombies = Std.random( zombieS ) +1;
					spreadZone.addZombie(spreadedZombies) ;
					zombieS -= spreadedZombies;
				}
				
				if (Std.random(100) < Cs.OverThresholdGrowChance)
					z.addZombie(1) ;
				continue ;
			}
			
			
			if( Std.random(2) == 0 || z.building)
				z.addZombie(1) ;
		}
	}
	
	
	
	
}