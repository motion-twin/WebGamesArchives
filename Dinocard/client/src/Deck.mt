class Deck extends Sprite{//}

	var flFace:bool;
	var card:Card;
	var list:Array<int>;
	var name:String;
	
	function new(mc){
		mc = Cs.game.dm.attach("mcDeck",Game.DP_DECK)
		super(mc);
		flFace = true;		
	}
	
	function setFace(f){
		flFace = f
		if(card.flFace!=flFace)card.flip();
	}
	
	function setList(a){
		
		list = a;
		updateTop();
		
	}
		
	function getTopCard(){
		var card = new Card(null);
		card.setId( list.shift() )
		updateTop();
		card.toggleShadow();
		return card;
	}
	
	function getCard(id){
		for( var i=0; i<list.length; i++ ){
			if(list[i]==id){
				list.splice(i,1);
				break;
			}
		}
		var card = new Card(null);
		card.setId(id);
		updateTop();
		card.toggleShadow();
		return card;
	}
	
	
	/*
	function seekCard(id){
		var card = new Card(null);
		card.setId( id )
		updateTop();
		card.toggleShadow();
		
		//
		
		//
		
		return card;
	}
	*/
	
	function putCard(c){
		list.unshift(c.id)
		c.kill();
		updateTop();
		
	}
	
	function updateTop(){

		if( card == null ){
			card = new Card(Std.attachMC(root,"mcCard",10))
			//card.getDesc = callback(this,getMax)
			card.setScale(70);
			card.updatePos();
			Cs.game.cardList.remove(card)
			if(flFace){
				card.instantFlipIn();
				card.initInfo();
			}
			
			
		}
		

		root._visible = list.length>0
		
		if(root._visible){
			card.setId(list[0])
			//if(card.flFace!=flFace)card.flip();
			card.y = -list.length*0.5
		}
		
		
		//
		Cs.game.removeHint(card.area)
		Cs.game.makeHint(card.area,Cs.getBold(name)+"\n"+list.length+" carte(s)",0,-1)
		
	}
	
	function getMax(){
		return string(list.length)
	}
	
	
	
	
	
	
	/*
	function incPile(inc){
		if(pile+inc<0){
			Log.trace("incCard Error (<0)!!")
			return;
		}
		setPile(pile+inc)
	}
	
	function setCard(id){
		if( card == null ){
			card = new Card(Std.attachMC(root,"mcCard",1))
			setFace(true)
		}
		card.setId(id)
	}
	*/
	

	
//{
}