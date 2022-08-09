class spell.Ascension extends spell.Base{//}

	var e:sp.Element;
	var vy:float;
	var step:int;
	var tube:sp.Part

	var best:{e:sp.Element,score:float}
	
	function new(){
		super();
		cost = 1;
	}
	
	function cast(){
		super.cast();
		initStep(0);
	}
	
	function initStep(n){
		step = n 
		switch(step){
			case 0:
				e = best.e//getBestResult().e
				e.isolate();
				Cs.game.removeFromGrid(e)
				
				tube = Cs.game.newPart( "partLightTube", Game.DP_PART2 )
				tube.x = e.x + Cs.game.ts*0.5
				tube.y = e.y + Cs.game.ts
				tube.init();
				tube.skin._yscale = e.y + Cs.game.ts
				tube.skin._xscale = 0
				
			
				break;
			case 1:
				vy = -0.5
				break;

		}
	}

	function activeUpdate(){

		switch(step){
			case 0:
				tube.skin._xscale  = Math.min( tube.skin._xscale+10*Timer.tmod, 100 )
				if(tube.skin._xscale==100)initStep(1);
				break;
			case 1:
				vy *= Math.pow(1.1,Timer.tmod)
				e.y += vy
				e.update();
				if(e.y < -20 ){
					e.kill();
					initStep(2)
				}
				
				var p = Cs.game.newPart("partVertiLight",Game.DP_PART2);
				p.x = tube.x + (Math.random()*2-1)*(Cs.game.ts*0.5-4); 
				p.y = tube.y - Math.random()*tube.skin._yscale;
				p.vity = -(2+Math.random()*10)
				p.timer = 10+Math.random()*20
				p.init();
				
				break;
				
			case 2:
				tube.skin._xscale  = Math.max( tube.skin._xscale-10*Timer.tmod, 0 )
				if(tube.skin._xscale==0){
					tube.kill();
					finishAll();
				}
				break;
		}	
	
	}
	
	function getBestResult(){
		var result = new Array();
		
		for( var x=0; x<Cs.game.xMax; x++ ){
			for( var y=0; y<Cs.game.yMax; y++ ){
				var e = Cs.game.grid[x][y]
				if(e!=null){
					var score = getRemoveValue(e)
					score += 1-(y/Cs.game.yMax)
					result.push({e:e,score:score})
					break;
				}
			}
		}
		
		sortByScore(result)
		
		var index = int(Math.random()*(result.length/fi.carac[Cs.INTEL]))
		return result[index];
		
	}


	function getRelevance(){		// *1.0 sinon int
		best = getBestResult()
		return best.score;

	}
	
	function getName(){
		return "Ascension "
	}

	function getDesc(){
		return "Elimine une bille haute en la projetant dans les cieux."
	}
	
//{
}
	
	
	