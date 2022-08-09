class spell.Nova extends spell.Base{//}


	var eList:Array<sp.Element>
	var dList:Array<float>
	
	var step:int;
	var timer:float;
	
	var ray:float;
	var size:float;
	var sizeSpeed:float;
	var center:{x:float,y:float}
	
	var ball:sp.Part;
	
	function new(){
		super();
		cost = 5;
	}
	
	function cast(){
		super.cast();
		initStep(0);
	}

	function initStep(n){
		step = n 
		switch(step){
			case 0:
				casterGoTo(center.x,center.y)
				break;
			case 1:
				ball = Cs.game.newPart("partSuperNova",Game.DP_UNDER)
				ball.x = center.x;
				ball.y = center.y;
				ball.scale = 0;
				ball.init();
			
				//timer = 100
				size = 0
				sizeSpeed = 1
				break;
			case 2:
				ball.timer = 6
				ball.fadeLimit = 6
				//ball.vits = 3
				//ball.fadeTypeList = [1]
				/*
				for( var i=0; i<eList.length; i++ ){
					var e = eList[i]
					var p = e.morphToPart();
					p.vitx = (Math.random()*2-1)*3
					p.vity = (Math.random()*2-1)*3
					p.timer = 10+Math.random()
					p.init();
					//e.kill();
				}
				*/
				timer = 10
				break;
		}
	}

	function activeUpdate(){

		switch(step){
			case 0:
				caster.starFall(1.5)
				caster.toward(caster.trg,0.1)
				if( isCasterReady(20) )	initStep(1);
				break;
			case 1:
				//var c = 1-(timer/100)
				//ball.skin._xscale = ball.skin._yscale = c*100
				slowCaster(0.1)
			
				// BALL
				sizeSpeed += 0.2*Timer.tmod
				size += sizeSpeed*Timer.tmod
				ball.scale = (size/100)*ray*2
				if(size > 100 ) size = 100;
				ball.skin._xscale = ball.skin._yscale = ball.scale

			
				var m  = Cs.game.ts*0.5
				var c = { x:center.x-m,y:center.y-m}

				
				for( var i=0; i<eList.length; i++ ){
					var e = eList[i]
					var dist = dList[i]
					if( dist < ball.scale*0.5 ){
						var el = eList[i]
						var p = el.morphToPart();
						var a = p.getAng(c)
						var sp = dist*0.05
						p.vitx = Math.cos(a)*sp
						p.vity = Math.sin(a)*sp
						p.timer = 7+Math.random()*10
						p.init();
						eList.splice(i,1)
						dList.splice(i,1)
						i--
					}
				}
			
			
				
				// BLACK JUICE
				for( var i=0; i < Math.floor( sizeSpeed/8 ); i++ ){
					var p = Cs.game.newPart("partBlackJuice",Game.DP_PART2)
					var a = Math.random()*6.28
					p.x = center.x + Math.cos(a)*ray
					p.y = center.y + Math.sin(a)*ray
					p.init();
					p.skin._rotation = a/0.0174
					p.skin._xscale = 60 + (Math.random()*2-1)*15
					p.skin._yscale = 60 + (Math.random()*2-1)*8
					
				}
				
				// CASTER RAY
				for( var i=0; i<2; i++ ){
					var p = Cs.game.newPart("partConcentrationRay",Game.DP_PART2);
					p.x = caster.x
					p.y = caster.y
					p.vitx = caster.vitx
					p.vity = caster.vity
					p.vitr = (Math.random()*2-1)*10
					p.init();
					p.skin._xscale = 10+Math.random()*30
					p.skin._rotation = Math.random()*360
				}
				
				if(sizeSpeed > 16 )initStep(2);
			
				break;
			case 2 :
				timer-=Timer.tmod
				if(timer<=0)finishAll();
				break;
		}	

		
	}

	function getRelevance(){					// *1.0 sinon int
	
		//ray = 30+fi.carac[Cs.WISDOM]*5
		ray = 30+7*5
		center = {x:Cs.game.width*0.5,y:Cs.mch-ray}
		
		eList = Cs.game.eList.duplicate();
		dList = new Array();
		
		var m  = Cs.game.ts*0.5
		var c = { x:center.x-m,y:center.y-m}
		var score = 0
		for( var i=0; i<eList.length; i++ ){
			var e = eList[i]
			var dist = e.getDist(c)
			if( dist < ray ){
				score += getRemoveValue(e)
				dList[i] = dist;
			}else{
				eList.splice(i--,1)
			}
		}
		
		return score
	}
	
	function getName(){
		return "Super Nova "
	}
	
	function getDesc(){
		return "Créé un trou noir aspirant les billes les plus proches."
	}		
	
//{
}
	
	
	
	
	