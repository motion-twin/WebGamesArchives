class ac.DinozState extends Action{//}

	var data:DataDinozState;
	var card:Card;
	
	var remInjList:Array<MovieClip>
	
	function new(d){
		super(d)
		data = downcast(primedata)
		waitTimer = 2
		//
	}
	
	function init(){
		super.init();

		card = Card.getCard(data.$inst);
		
		card.strength = data.$strength;
		card.endurance = data.$endurance;
		card.capacities = data.$capacities
		card.updateFace();
		
		//Log.trace(card.data.$name+":"+data.$capacities.length)
		
		// INJURIES
		card.setToken( Token.DAMAGE, data.$injuries )
		if(!card.flFace){
			if(data.$eclosion!=null){
				card.setToken( Token.ECLOSION, data.$eclosion )
				card.setEclosionHint(data.$eclosion);
			}else{
				card.birth();
				waitTimer = 12
				Cs.game.removeHint(card.area)
			}
		}else{
			if(data.$eclosion!=null){
				card.unbirth()
				card.setToken( Token.ECLOSION, data.$eclosion )
				waitTimer = 12
			}
		}

		//
		
		
	}
	
	function update(){
		super.update();
		
	}



//{
}