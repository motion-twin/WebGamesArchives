class spell.Silence extends spell.Base{//}


	var step:int;
	var timer:float;
	
	function new(){
		super();
		cost = 1;
	}
	
	function cast(){
		super.cast();
		//Manager.log("----")
		//Manager.log(caster.trg)
		initStep(0)
		//Manager.log(caster.trg)
		//Manager.log("----")
	}

	function initStep(n){
		step = n 
		switch(step){
			case 0:
				centerCaster();
				break;
			
			case 1:
				var list = Cs.game.impList
				for( var i=0; i<list.length; i++ ){
					var imp = list[i]
					var a = caster.getAng(imp)
					var p  = Cs.mm( 0, 300/caster.getDist(imp), 30 )
					imp.vitx = Math.cos(a)*p
					imp.vity = Math.sin(a)*p
					
					imp.setStatus(Cs.SILENCE,true)
					imp.statusTimer[Cs.SILENCE] = (fi.carac[Cs.WISDOM]*300)/(1+imp.level*0.5) + Math.random()*100
				}
			
				// PART
				newOnde();

				
				timer = 20
			
				break;
			
		}
	}


	function activeUpdate(){
		switch(step){
			case 0:
				caster.toward(caster.trg,0.1)
				if( isCasterReady(20) )initStep(1);
				break;
			
			case 1:
				slowCaster(0.3)
				timer-=Timer.tmod;
				if(timer<=0)finishAll();
				break;
			
		}
	}
	//
	function getRelevance(){
		var list = Cs.game.impList.duplicate();
		for( var i=0; i<list.length; i++ ){
			if(list[i].status[Cs.SILENCE])list.splice(i--,1);
		}
		
		return list.length*2
	}
	
	//
	function getName(){
		return "Silence "
	}
	
	function getDesc(){
		return "Empêche les démons de lancer leur sortilèges."
	}
	
//{	
}