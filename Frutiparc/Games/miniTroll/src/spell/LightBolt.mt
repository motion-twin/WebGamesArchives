class spell.LightBolt extends spell.Base{//}


	var step:int;
	var timer:float;
	
	var bList:Array<{>sp.Part,trg:{x:float,y:float},trgType:int}>

	
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
				bList = new Array();
				var max = 1+fi.carac[Cs.WISDOM]
				var iList = Cs.game.impList.duplicate();
				var eList = Cs.game.eList.duplicate();
				for( var i=0; i<max; i++ ){
					var p = downcast(Cs.game.newPart("partFlipGlow",null));
					p.x = caster.x
					p.y = caster.y
					p.scale = 30
					p.trg = null
					p.trgType = null;
					if(iList.length>0){
						p.trg = upcast(iList.pop());
						p.trgType = 0;
					}else{
						if( eList.length == 0 )break;
						var index = Std.random(eList.length)
						p.trg = upcast(eList[index])
						p.trgType = 1;
					}
					
					var a = p.getAng(p.trg)
					var sp = 3+Math.random()*4
					p.vitx = -Math.cos(a)*sp
					p.vity = -Math.sin(a)*sp
					
					p.init();				
					bList.push(p)
				}
			
			
				break;
			case 1:
			
				
				
				
				
				break;

		}
	}
	
	function activeUpdate(){

		switch(step){
			case 0:
				for( var i=0; i<bList.length; i++ ){
					
					var p = bList[i]

					var trg = {x:p.trg.x,y:p.trg.y}
					if( p.trgType == 1 ){
						trg.x += Cs.game.ts*0.5
						trg.y += Cs.game.ts*0.5
					}
					
					
					p.towardSpeed( trg, 0.15, 0.6 )
					var m = 10
					
					if( p.x < m || p.x > Cs.game.width-m ){
						p.vitx *= -0.8
						p.x = Cs.mm( m, p.x, Cs.game.width-m)
					}
					if( p.y < m || p.y > Cs.game.height-m ){
						p.vity *= -0.8
						p.y = Cs.mm( m, p.y, Cs.game.height-m)
					}
					
					if( p.getDist(trg) < 10 ){
						
						if( p.trgType == 0 ){
							var imp:sp.pe.Imp = downcast(p.trg)
							imp.vitx += p.vitx*0.5
							imp.vity += p.vity*0.5
							imp.harm(80);
						}else{
							var e:sp.Element = downcast(p.trg)
							e.isolate();
							e.explode();
							e.kill()
		
						}
						
						p.vits  = 20
						p.timer = 8
						p.fadeTypeList = [1]
						
						
						bList.splice(i--,1)
					}
				
					if(bList.length==0)finishAll();
					
				}
			
			
				break;
			case 1:
				break;
		}	
	
	}
	
	function getRelevance(){
		var score = (fi.carac[Cs.WISDOM] + Cs.game.impList.length)*0.4
		return score
	}
	
	function getName(){
		return "Billes de lumiere"
	}

	function getDesc(){
		return "Elles anéantiront vos ennemis ou les billes du niveau."
	}	
	
//{
}
	


