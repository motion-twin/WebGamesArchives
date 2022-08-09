package horde ;


/* *****************************************	
	### - plus de multitraitement d'une zone si elle dépasse n zombies (n définit en random au début) : une zone qui a reçu des zombies par celle d'à côté est virée des zones à traiter et des cases d'adjacences possibles
	### cap des n zombies pour éviter qu'un nettoyage des joueurs garantisse un couloir avec 2 zombies max le jour suivant
	### en bonus, ça accélère le traitement
		
	- compteur de nouveaux zombies : plus on a déjà ajouté, plus les random pour en faire pop/depop sont durs à faire passer
	- pondération de ce compteur par un shuffle de l'ordre des zones traités => éviter que ça pop toujours plus au même endroit de la map
	- quelques randoms par ci par là pour caser le systématisme du comportement :
		- 50% de pop sur une case adjacente est un déplacement de zombie (pondéré)
		- 75% de pop un nouveau zombie sur une zone de plus de 4 (déjà présent mais pondéré)
		- 30% de cases avec 4 zombies peuvent quand mm recevoir des zombies adjacents
	
	
	résultats : 
	- globalement similaire mais les "gros blocs" ont un comportement moins statique (plus d'écoulements, moins d'auto-entretien)
	- le remplissage de toute la map est ralenti : écart-type plus élevé, moins de zombies qu'en mode 1 (cf stats)
	- le développement reste sensiblement le même à chaque fois (nombre de zombies, moyenne... = randoms ont peu d'influence sur l'issue de la partie)
	
	*******************************************/


class ModDone {
	
		
	
	static public function process(map : Map) {
		var doneLimit = Std.random(3) + 3 ;
		
		var zones = new Array() ;
		var tzones = new Array() ;
		var baseZones = new Array() ;
		for(x in 0...Map.SIZE) {
			for(y in 0...Map.SIZE) {
				var z = map.grid[x][y] ;
				z.done = false ;
				baseZones.push(z) ;
				if (z.isTown() || z.zombies == 0)
					continue ;
				tzones.push(z) ;
			}
		}
		
		
		while (tzones.length > 0) {
			var e = tzones[Std.random(tzones.length)] ;
			tzones.remove(e) ;
			zones.push(e) ;
		}
		
		
		var cZombie = 0 ;
		var cZombieRatio = 75 ;
		
		while(zones.length > 0) {
			var z = zones.pop() ;
			if (z == null || z.done)
				continue ;
			
			z.done = true ;
			
			var x = z.x ;
			var y = z.y ;
			
			
			if (z.zombies >= Cs.ZombieGrowThreshold) {
				var adjacentZones = Lambda.array( Lambda.filter( baseZones, function( az: Zone ) {
					if( az.isTown() || az.done || (az.zombies >= Cs.ZombieGrowThreshold && Std.random(100) <= 30))
						return false;
					if( x==az.x && y==az.y )
						return false;
					if( Zone.getZoneLevel(  { x:x, y:y }, {x:az.x,y:az.y} ) == 1 )
						return true;
					return false;
				} ) );
				
				

				if( adjacentZones.length <= 0 ) {
					cZombie++ ;
					z.addZombie(1) ;
					continue;
				}
				
				var zombieS = Cs.ZombieSpreaded ;
				while( zombieS > 0 ) {
					var spreadZone = adjacentZones[ Std.random( adjacentZones.length) ];
					var spreadedZombies = Std.random( zombieS ) +1;
					spreadZone.addZombie(spreadedZombies) ;
					zombieS -= spreadedZombies;
					
					cZombie += spreadedZombies ;
					
					if (spreadZone.zombies >= doneLimit)
						spreadZone.done = true ;
					
					
					if (Std.random(100) - (cZombie / 75) < 50)
						z.killZombie(zombieS) ;
				}
				
				if (Std.random(100) + (cZombie / 75) < 75) {
					cZombie++ ;
					z.addZombie(1) ;
				}
				continue ;
			}
			
			if( Std.random(2) == 0 || z.building)
				z.addZombie(1) ;
		}
	}
	
	
	
	
}