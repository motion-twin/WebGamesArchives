class spell.Shield extends spell.Base{//}

	static var RAY = 36
	
	var pList:Array<sp.Part>
	var step:int;
	var timer:float;
	var speed:float;
	var decal:float;
	
	var bubble:sp.Part;
	
	function new(){
		super();
		cost = 1;
	}
	
	
	
	
	function cast(){
		super.cast();
		initStep(0)
	}

	function initStep(n){
		step = n 
		switch(step){
			case 0:
				centerCaster();
				pList = new Array();
				break;
			case 1:
				decal = 0
				speed = 6
				
				break;
			case 2:
				for( var i=0; i<pList.length; i++ ){
					var p = pList[i]
					var a = caster.getAng(p)
					var sp = 8+Math.random()*12
					p.vitx = Math.cos(a)*sp
					p.vity = Math.sin(a)*sp
					p.timer = 10+Math.random()*10
				}
				
				bubble = Cs.game.newPart("partForceBubble",null)
				bubble.x = caster.x
				bubble.y = caster.y
				bubble.init();
				
				timer = 20
				break;
			
		}
	}

	function update(){
		super.update();
		bubble.x = caster.x;
		bubble.y = caster.y;
		
		var list = Cs.game.shotList
		for( var i=0; i<list.length; i++ ){
			var shot = list[i]
			if( shot.trgList[0] == caster ){
				bubblePush(upcast(shot))
			}
		}
		

		for( var i=0; i<Cs.game.impList.length; i++ ){
			var imp = Cs.game.impList[i]
			bubblePush(upcast(imp))

		}

		if( Cs.game.step == 2 ){
			timer -= Timer.tmod
			if(timer<=0){
				dispel();
			}else if(timer<40){
				bubble.skin._alpha = timer*2.5
			}
		}
	}

	function activeUpdate(){
		switch(step){
			case 0:
				
				if( Std.random(4)==0 ){
					var p = Cs.game.newPart("partShieldBall",Game.DP_PART2)
					var d = 50+Math.random()*30
					var a = Math.random()*6.28
					p.x = caster.x + Math.cos(a)*d
					p.y = caster.y + Math.sin(a)*d
					p.init();
					pList.push(p)
					
				}
				
				for( var i=0; i<pList.length; i++ ){
					var p = pList[i]
					p.towardSpeed( caster, 0.3, 0.5 )
				}
						
			
				if(pList.length>32)initStep(1);
			
				break;
			
			case 1:
				decal = (decal+20*Timer.tmod)%628
				speed += 0.7*Timer.tmod
				
				slowCaster(0.5)
				
				var ray = 40
				for( var i=0; i<pList.length; i++ ){
					var p = pList[i]
					var a = (i/pList.length)*6.28 + decal/100
					var trg = {
						x:caster.x + Math.cos(a)*ray
						y:caster.y + Math.sin(a)*ray
					}
					//p.toward( trg, Math.min(speed*0.05,1) )
					p.towardSpeed( trg, 0.3, 1.25 )
				}
				
				if( speed > 50 )initStep(2);
				break;
				
			case 2:
				slowCaster(0.3)
				timer -= Timer.tmod;
				if(timer<=0){
					timer = 200+fi.carac[Cs.WISDOM]*100
					endActive();
				}//finishAll();
				break;
			
		}
	}
	//
	
	function dispel(){
		bubble.kill();
		super.dispel();
	}
	
	function bubblePush(trg){
		var a = caster.getAng(trg);
		var dist = caster.getDist(trg)+trg.ray;
		if( dist < RAY ){
			var d = RAY-dist
			trg.x += Math.cos(a)*d
			trg.y += Math.sin(a)*d
		}	
	}
	
	function getRelevance(){
		var list = Cs.game.impList
		var score = 0
		for( var i=0; i<list.length; i++ ){
			score += Math.pow(list[i].level+1,2)
		}
		return list.length*0.5/fi.fs.$life
	}
	
	//
	function getName(){
		return "Cloche d'immunite"
	}
	
	function getDesc(){
		return "Créé un bouclier d'energie qui protège votre fée des tir et des charges."
	}		
	

	
//{	
}