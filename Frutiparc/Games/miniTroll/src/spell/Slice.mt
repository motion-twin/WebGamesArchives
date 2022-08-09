class spell.Slice extends spell.Base{//}

	var step:int;
	
	var cutHeight:int;
	var cy:float;
	var cutList:Array<{e:sp.Element, vx:float, vy:float, timer:float }>;

	var slash:sp.Part;
	
	function new(){
		super();
		cost = 2;
	}
	
	function cast(){
		super.cast();
		initStep(0);
	}
	
	function initStep(n){
		step = n 
		switch(step){
			case 0:
				casterGoTo( Cs.game.ts*0.8, cy )
				break;
			case 1:
				casterGoTo( Cs.game.width-Cs.game.ts*0.8, cy )
				break;
			case 2:
				slash = Cs.game.newPart("partSlash",Game.DP_PART2)
				slash.x = 0
				slash.y = cy
				slash.fadeTypeList=[1]
				slash.timer = 10;
				slash.init();
				slash.skin._xscale = Cs.game.width
				
				//
				//caster.trg = null
				caster.flForceWay = false;
				for( var i=0; i<cutList.length; i++ ){
					var o = cutList[i]
					o.vx = 0.5
					o.vy = 0.5
					o.timer = 18
					Cs.game.removeFromGrid(o.e)
					Cs.game.dm.over(o.e.skin)
				}
				break;
		}
	}

	function activeUpdate(){

		switch(step){
			case 0:
				caster.toward( caster.trg, 0.1 )
				if( caster.getDist( caster.trg ) < 8 )initStep(1);
				break;
			case 1:
				caster.toward( caster.trg, 0.3 )
				if( caster.getDist( caster.trg ) < 5 )initStep(2);			
				break;
			case 2:
				for( var i=0; i<cutList.length; i++ ){
					var o = cutList[i]
					o.e.x += o.vx*Timer.tmod;
					o.e.y += o.vy*Timer.tmod;
					//o.e.skin._x = o.e.x
					//o.e.skin._y = o.e.y
					o.e.update();
					o.timer -= Timer.tmod
					
					if( o.timer < 0 ){
						o.e.kill();
						cutList.splice(i--,1)
					}else if( o.timer < 10 ){
						o.e.skin._alpha = o.timer*10
					}
				}
				if( cutList.length == 0 ){
					finishAll();
				}
				break;
		}	
	
	}
	
	function getRelevance(){		// *1.0 sinon int
		
		
		var ym = Cs.game.getHeightMax();

		if(ym > Cs.game.yMax-2) return 0;
		cutHeight = int(Math.min( Cs.game.yMax-2, ym+Math.floor( fi.carac[Cs.WISDOM]*0.43 ) )) 
		cy = Cs.game.getY(cutHeight+1)
		cutList = new Array();
		
		var score=0
		for( var x=0; x<Cs.game.xMax; x++ ){
			for( var y=0; y<=cutHeight; y++ ){
				var e = Cs.game.grid[x][y]
				if( e != null ){
					cutList.push({e:e,vx:0,vy:0,timer:10})
					score += getRemoveValue(e)
				}
			}
		}		
		
		
		return score
	}
	
	function getName(){
		
		return "Tranche Cimes "
	}

	function getDesc(){
		return "Coupe et supprime les plus hautes billes du niveau."
	}
	
//{
}
	
	
	