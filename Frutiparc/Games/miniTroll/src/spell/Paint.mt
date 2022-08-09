class spell.Paint extends spell.Base{//}


	var step:int;
	var cid:int
	var timer:float;
	//var tList:Array<{x:float,y:float}>

	
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

				cid = Cs.game.colorList[Std.random(Cs.game.colorList.length)]
				centerCaster();
				break;
			case 1:
				timer = 100
				break;

		}
	}
	
	function activeUpdate(){

		switch(step){
			case 0:
				caster.toward(caster.trg,0.1)
				if( isCasterReady(10) ){
					initStep(1)
				}
				break;
			case 1:
				
				var list = Cs.game.eList
				var tList = new Array();
				for( var i=0; i<list.length; i++ ){
					var e = list[i]
					if(e.et==Cs.E_TOKEN){
						var token = downcast(e)
						var trg = {x:token.x+Cs.game.ts*0.5,y:token.y+Cs.game.ts*0.5}
						if( caster.getDist(trg) < 20 ){
							if( token.type != cid ){
								token.setType(cid)
								Cs.game.clearGroup();
								Cs.game.checkGroup();
								var gList = Cs.game.gList;
								for( var n=0; n<gList.length; n++ ){
									var group = gList[n]
									group.draw()
								}
								
								for( var n=0; n<4; n++ ){
									var p = Cs.game.newPart("partPaint",null)
									var mc = downcast(p.skin).col
									var a = p.getAng(trg)
									Mc.setColor( mc, Cs.colorList[cid] ) 
									Mc.modColor( mc, 1, 150 )
									p.x = trg.x;
									p.y = trg.y;
									var sp = Math.random()*4
									p.vitx  = -Math.cos(a)*sp; 
									p.vity  = -Math.sin(a)*sp;
									p.scale = 40+Math.random()*60
									p.timer = 10+Math.random()*10
									p.flGrav  = true;
									p.weight = 0.35
									//Manager.log(p.x)
									p.init();
								}
								
								
							}
						}
						
						if( token.type != cid )tList.push(trg);
						
					}
				}
				
				timer -= Timer.tmod
				
				if( tList.length == 0 || timer<0 ){
					finishAll();
				}else{
					if( isCasterReady(16) ){			//Std.random(int(40/Timer.tmod)) == 0
						caster.flForceWay = true;
						caster.trg = tList[Std.random(tList.length)]
					}
				}
				
				break;
		}	
	
	}
	
	function getRelevance(){		// *1.0 sinon int
		var score = 0
		for( var i=0; i<Cs.game.eList.length; i++ ){
			var e  = Cs.game.eList[i]
			if( e.et == Cs.E_TOKEN ) score += 0.05;
		}
		score *= Math.pow(fi.carac[Cs.SPEED],0.5);
		return score;
	}
	
	function getName(){
		return "Pigmentation "
	}

	function getDesc(){
		return "Votre fée peint d'une couleur unique les billes du niveau en les touchant."
	}		
	
//{
}
	

