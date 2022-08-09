class ac.Shuffle extends Action{//}

	var data:DataShuffle;

	var player:Player;
	
	function new(d){
		super(d)
		data = downcast(d);
		
	}
	
	function init(){
		super.init();
		player = Cs.game.getPlayer(data.$pid);
		
	}
	
	function update(){
		var deck = player.graveyard

		if(deck.list.length==0){
			player.pack.setList(data.$cards);
			kill();
		}else{
			var card = deck.getTopCard();
			player.pack.putCard(card)
			card.kill();
		}
		
		super.update();
	}



//{
}