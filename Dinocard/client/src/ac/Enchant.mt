class ac.Enchant extends Action{//}

	var data:DataEnchant
	var card:Card;
	//var trg:Card;

	function new(d){
		super(d)
		data = downcast(d);
	}
	
	function init(){
		//Log.trace("!enchant! "+data.$inst)

		super.init();
		
		card = Card.getCard(data.$inst);
		card.initInfo();
		
		
		var trg = Card.getCard(data.$dinozId);
		//Log.trace(card._root._visible)
		//Log.trace(trg._root._visible)
		
		for( var i=0; i<trg.enchants.length; i++ ){
			if( trg.enchants[i] == card ){
				kill();
				return;
			};
		}
		
		//trg.root._rotation = 20
		var pos = trg.getEnchantPos(trg.enchants.length);
		card.goto(pos.x,pos.y,Player.dSize*100);
		trg.enchants.push(card);
		card.enchantTarget = trg
		
		// ORDER DEPTHS
		for(var i=trg.enchants.length-1; i>=0; i-- ){
			trg.enchants[i].front();
		}
		trg.front();
	}
	
	function update(){
		super.update();
		//Log.trace("update:"+card.x)
		if(card.trg==null)kill();
	}



//{
}