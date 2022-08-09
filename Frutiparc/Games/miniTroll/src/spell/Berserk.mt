class spell.Berserk extends spell.Base{//}

	static var MULTI = 20
	
	var step:int;
	var timer:float;

	
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
				caster.body.body.tete.kami.gotoAndPlay("2")
				caster.body.body.epaule.gotoAndStop("2")
				endActive();
				timer = 400
			
				fi.carac[Cs.POWER] += 5
				caster.freqDash *= MULTI
			
				break;
			case 1:
				break;

		}
	}

	function update(){
		super.update()
		timer -= Timer.tmod;
		if(timer<0){
			dispel();
		}
		
		
	}
	
	function dispel(){
		super.dispel()
		fi.carac[Cs.POWER] -= 5
		caster.freqDash = int(caster.freqDash/MULTI)
		caster.body.body.tete.kami.gotoAndStop("1")
		caster.body.body.epaule.gotoAndStop("1")	

	}
	
	function activeUpdate(){

		switch(step){
			case 0:
				break;
			case 1:
				break;
		}	
	
	}
	
	function getRelevance(){		// *1.0 sinon int
		var list = Cs.game.impList
		var score = 0
		for( var i=0; i<list.length; i++ ){
			score += Math.pow(list[i].level+1,2)
		}
		return score;
	}
	
	function getName(){
		return "Exaltation "
	}
	
	function getDesc(){
		return "Transforme votre fée en une impitoyable machine à tuer."
	}

	
//{
}
	
	
	