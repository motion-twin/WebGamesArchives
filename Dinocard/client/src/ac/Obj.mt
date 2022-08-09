class ac.Obj extends Action{//}

	var data:DataObject;
	var card:Card;

	function new(d){
		super(d);
		data = downcast(d);
	}
	
	function init(){
		super.init();
		card = Card.getCard(data.$inst);
		card.initInfo();
		var pl = Cs.game.getPlayer(data.$pid);
		pl.addObject(card);
		card.front();
	}
	
	function update(){
		super.update();
		if(card.trg==null)kill();
		
	}



//{
}