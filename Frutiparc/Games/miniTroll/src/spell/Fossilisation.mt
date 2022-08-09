class spell.Fossilisation extends spell.Base{//}

	var step:int;
	var timer:float;
	
	var dList:Array<{ >sp.Part, dx:float, dy:float, dsx:float, dsy:float, }>
	var tList:Array<sp.el.Token>
	
	var best:{score:float, list:Array<sp.el.Token>}
	
	function new(){
		super();
		cost = 3;
	}
	
	function cast(){
		super.cast();
		initStep(0);
	}
	
	function initStep(n){
		step = n 
		switch(step){
			case 0:
				centerCaster();
				caster.spinSpeed = 0.6
				timer = 6
				dList = new Array();
				tList = best.list;
				break;
			case 1:
				timer = 10
				break;
			case 2:
				for( var i=0; i<dList.length; i++ ){
					var p = dList[i];
					var dist = p.getDist(caster)
					var a = caster.getDist(p)
					p.vitx = Math.cos(a)*dist*0.5
					p.vity = Math.sin(a)*dist*0.5
					if(i>=tList.length){
						p.timer = 10+Math.random()*10
					}
				}
				break;
			case 3:
							
				break;
		}
	}

	function activeUpdate(){

		
		
		switch(step){
			case 0:
				caster.spinSpeed  = Math.min( caster.spinSpeed+0.02*Timer.tmod, 4 )
				timer -= caster.spinSpeed;
				
				if( timer < 0){

					if( dList.length == tList.length*2 ){
						if(caster.spinSpeed>3)initStep(1);
					}else{
						timer = 6
						var d = newDust();
						if(dList.length <= tList.length){
							d.scale = 150
							d.skin._xscale = d.skin._yscale = d.scale;
						}
						
					}
				}
				slowCaster(0.5);
				moveDust();
				break;
			case 1:
				caster.spinSpeed *= Math.pow(1.1,Timer.tmod)
				timer -=Timer.tmod
				if(timer<0)initStep(2)
				
				break;
			case 2 :
				for( var i=0; i<tList.length; i++ ){
					var e = tList[i]
					var p = dList[i]
					var trg = {
						x:Cs.game.getX(e.px+0.5)
						y:Cs.game.getY(e.py+0.5)
					}
					
					p.towardSpeed(trg,0.05,2)
					
					if( p.getDist(trg) < 8 ){
						var x = e.px
						var y = e.py
						e.kill();
						p.kill();
						tList.splice(i--,1)
						Cs.game.genElement(Cs.E_STONE,x,y,2)
						
						var c = Cs.game.newPart("partStoneCrack",Game.DP_PART2)
						c.x = Cs.game.getX(x+0.5)
						c.y = Cs.game.getY(y+0.5)
						c.timer = 10
						c.fadeTypeList = [1]
						//c.fadeTypeList = [1,2]
						//c.fadeColor = Std.random(0xFF0000)
						c.skin._rotation = Math.random()*360
						c.scale = Cs.game.ts
						c.init();
						
						
					}
					
				}
				if( caster.spinSpeed != null){
					if( caster.spinSpeed < 0.7){
						if( Math.abs(caster.spinFrame-10)<5 )caster.stopSpin();
						
					}else{
						caster.spinSpeed *= 0.95
					}
				}else{
					if( tList.length == 0 && caster.spinSpeed==null ){
						finishAll();
	
					}
				}
				
				break;
			case 3 :

				break;
		}	

		
	}
	
	function getBestResult(){
		var result = new Array();
		for( var i=0; i<Cs.game.eList.length; i++ ){
			var e = Cs.game.eList[i]
			if(e.et==Cs.E_TOKEN){
				var token:sp.el.Token = downcast(e)
				if( result[token.type] == null ){
					result[token.type] = { score:0, list:[] }
				}
				var o = result[token.type]
				switch(token.special){
					case 0:
						o.score += -0.5
						break
					case 1:
						o.score += 0
						break
					case 2:
						o.score += 0.5
						break
				}
				o.list.push(token)
			}
		}
		
		for( var i=0; i<result.length; i++ ){
			if(result[i] == null )result.splice(i--,1);
		}
		
		sortByScore(result)
		var index = int(Math.random()*(result.length/fi.carac[Cs.INTEL]))
		
		return result[index];
		
	}
	
	function moveDust(){
	
		for( var i=0; i<dList.length; i++ ){
			var p = dList[i]
			p.dx = (p.dx+p.dsx*caster.spinSpeed*Timer.tmod)%628
			p.dy = (p.dy+p.dsy*Timer.tmod)%628
			
			var ca = Math.cos(p.dx/100)
			var sa = (p.dy/628)*2-1//Math.cos(p.dy/100)

			var trg = {
				x:caster.x + ca*(60-Math.abs(sa)*60)
				y:caster.y + sa*20
			}
			
			p.towardSpeed( trg, 0.1, 2 )
			
		}
		
	}
	
	function newDust(){
	
		var p = downcast(Cs.game.newPart("partDust",null))
		p.x = Math.random()*Cs.game.width
		p.y = Math.random()*Cs.game.height
		p.dx = Math.random()*628
		p.dy = Math.random()*628
		p.dsx = 20
		p.dsy = 8
		p.friction = 0.9
		p.init();
		p.addToList(dList)
		
		return p;
		
	}
	

	function getRelevance(){		// *1.0 sinon int
		best = getBestResult()
		return Math.pow(Cs.game.colorList.length-1,2) + best.score

	}
	
	function getName(){
		return "Valse Fossile "
	}

	function getDesc(){
		return "Elimine une couleur présente a l'ecran en la remplaçant par des pierres."
	}	
	
//{
}
	
	
	
	