class ac.Damages extends Action{//}

	var data:DataDamages;

	function new(d){
		super(d)
		data = downcast(d)
	}
	
	function init(){
		super.init();
		
		var vic = null;
		//Log.trace(data.$type)
		if(data.$typeTarget==0){
			vic = Cs.game.getPlayer(data.$target).getName();
		}else{
			vic = Card.getCard(data.$target).getName();
		}
		
		Cs.log( Card.getCard(data.$from).getName()+" inflige "+data.$value+" degat(s) à "+vic+" !", 3 )
		
		kill();
	}
	
	function update(){
		super.update();
	}



//{
}