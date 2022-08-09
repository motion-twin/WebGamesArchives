class spell.Ban extends spell.Base{//}


	var step:int;
	var timer:float;
	
	var ray:float;

	
	function new(){
		super();
		cost = 4;
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
				break;
			case 1:
				var p = Cs.game.newPart( "partLightCircle", null )
				p.x = caster.x;
				p.y = caster.y;
				p.scale = 20
				p.timer = 10
				p.fadeTypeList = [1]
				p.vits = 40
				p.init();
				
				p = Cs.game.newPart( "partFaerieWhiteShade", Game.DP_PART2 )
				p.x = caster.x;
				p.y = caster.y;
				p.fadeTypeList = [1];
				p.fadeLimit = 7;
				p.timer = 8;
				p.init();
			
				ray = 0
				
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
				ray += 8*Timer.tmod
				var list = Cs.game.impList
				for( var i=0; i<list.length; i++ ){
					var imp = list[i]
					if( caster.getDist(imp) < ray ){
						var a = caster.getAng(imp)
						var ca = Math.cos(a)
						var sa = Math.sin(a)
						for( var n=0; n<8; n++ ){
							var da = Math.random()*6.28;
							var d = Math.random()*24;
							var p = Cs.game.newPart("partHoriLight",null);
							p.x = imp.x+Math.cos(da)*d*0.5;
							p.y = imp.y+Math.sin(da)*d;
							var sp = 0.5+Math.random()*3;
							p.vitx = ca*sp;
							p.vity = sa*sp;
							p.timer = 10+Math.random()*10;
							p.init();
							p.skin._xscale = 300-d*10 ;
							p.skin._rotation = a/0.0174;
						}						
						imp.kill();
					}					
				}
				
				
				if( ray > 200 ){
					finishAll();
				}
				
				
				
				
				break;
		}	
	
	}
	
	function getRelevance(){		// *1.0 sinon int
		var list = Cs.game.impList
		var score = 0
		for( var i=0; i<list.length; i++ ){
			score += Math.pow(list[i].level+2,2)
		}
		return score;
	}
	
	function getName(){
		return "Bannissement "
	}

	function getDesc(){
		return "Bannit définitivement tous les démons en liberté du niveau."
	}

	
//{
}
	


















