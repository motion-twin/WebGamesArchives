class spell.Dig extends spell.Base{//}


	var step:int;
	var x:int;
	var timer:float;
	var decal:float;
	var destroyList:Array<{y:int,e:sp.Element}>

	var best:{x:int,score:float,list:Array<{y:int,e:sp.Element}>}
	
	function new(){
		cost = 1;
		super();
	}
	
	function cast(){
		super.cast();
		initStep(0)
	}

	function initStep(n){
		step = n 
		switch(step){
			case 0:
				//var best = getBestResults()
				//TYPE(best)
				this.x = best.x
				destroyList = best.list;
				/*
				for( var y=0; y<Cs.game.yMax; y++ ){
					if( Cs.game.grid[x][y] != null ){
						destroyList.push({y:y,e:Cs.game.grid[x][y]})
						//if( destroyList.length == fi.carac[Cs.POWER]*2 )
					}
				}
				*/
				caster.trg = {
					x:Cs.game.getX(x+0.5) ,
					y:Cs.game.getY(destroyList[0].y)
				}
				caster.flForceWay = true;
				
				break;
			
			case 1:
				caster.vity += 16
				caster.trg = {
					x:Cs.game.getX(x+0.5) ,
					y:Cs.game.getY(Cs.game.yMax)
				}
				break;
			case 2:
				caster.vity -= 6
				timer = 8
				break;
			
		}
	}

	function update(){
		super.update();
	}
	
	function activeUpdate(){
		switch(step){
			case 0:		// PART EN HAUT DE LA COLONNE
				caster.starFall(1.5)
				caster.toward(caster.trg,0.1)
			
				var dx = Math.abs(caster.trg.x-caster.x)
				var dy = Math.abs(caster.trg.y-caster.y)
			
				if( dx < 2 && dy < 20){
					initStep(2)
				}
				break;
			case 1:		// DASH ET DETRUIT LA COLONNE
				caster.vitx *= Math.pow(0.75,Timer.tmod)
			 	caster.starFall(3)
				caster.toward(caster.trg,0.15)
				
				while( (destroyList[0].y-1.5)*Cs.game.ts < caster.y ){
					var e = destroyList.shift().e;
					e.explode();
					Cs.game.removeFromGrid(e)
					e.kill();
				}
				
				if( destroyList.length == 0 ){
					caster.vity *= -0.8
					finishAll();
				}
				break;
			case 2:		// PREND DE L ELAN POUR LE DASH
				timer -= Timer.tmod
				var dx = Math.abs(caster.trg.x-caster.x)
				//caster.x += dx*0.4*Timer.tmod
				if( timer < 0 ) initStep(1)
				break;
				
		}
	}
	//
	function getBestResults(){
		var game = Cs.base.game
		var gm = game.getGridModel();
		var ref = Cs.game.getGroupModelScore( Cs.game.evalGridModel(gm).gList )
		var result = new Array();		// DEMANDER A WARP :Array<{x:int,score:float,list:Array<{y:int,e:sp.Element}>}>
		
		
		
		for( var x=0; x<game.xMax; x++ ){
			var gMod = game.getGridModel();
			var list = new Array();
			for( var y=0; y<game.yMax; y++ ){
				if( gMod[x][y] != null ){
					list.push({y:y,e:Cs.game.grid[x][y]})
					gMod[x][y] = null;
					var next = Cs.game.grid[x][y+1].et
					if( next == Cs.E_STONE || next == Cs.E_CELL || next == Cs.E_BOMB || list.length >= fi.carac[Cs.POWER]*2  )break;
				}
				
			}
			var o = game.evalGridModel(gMod)
			var score = game.getGroupModelScore(o.gList) - ref
			for( var i=0; i<list.length; i++ ){
				score += getRemoveValue(list[i].e)
			}
			result.push({x:x,score:score,list:list})
			
		}
		
		sortByScore(result)
		
		var index = int(Math.random()*(result.length/fi.carac[Cs.INTEL]))
		
		//var o = result[index];
		//TYPE(o)
		return result[index];
		
		
		//Manager.log(x)	//result[index]
	}
	//
	
	function getRelevance(){
		best = getBestResults()
		//Manager.log( "dig : "+(best.score/100) )
		return best.score/100;
	}
	
	//
	function getName(){
		return "Perce Puits "
	}
	
	function getDesc(){
		return "Détruit le sommet d'une colonne de bille."
	}	
	
	
	
	
	
//{	
}















