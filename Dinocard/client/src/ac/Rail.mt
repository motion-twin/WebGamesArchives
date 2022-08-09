class ac.Rail extends Action{//}

	var data:DataRail;
	var waitList:Array<Card>;
	
	function new(d){
		super(d)
		data = downcast(primedata)
	}
	
	function init(){
		super.init();
		var pl = Cs.game.getPlayer(data.$pid);
		waitList = new Array();
		
		//Log.trace("Rail type :"+data.$action);
		//Log.trace("Rail data.$value :"+data.$value);
		
		switch(data.$action){
			case 0:	// SIZE
				break;
			case 1: // DINOZ
				var card = null
				//Log.trace("from :"+data.$from);
				//Log.trace("value:"+data.$value);
				if(data.$from!=int(data.$value)){
					card = new Card(null);
					card.setId(int(data.$value));			
					card.toggleShadow();
					card.copyCard(Card.getCard(data.$from))
					card.instantFlipIn();
				}else{
					card = Card.getCard(int(data.$value));
				}
				//Log.trace("Rail Card :"+card.data.$id);
				
				// VIRE DU RAIL SI DEJA POSE
				for( var i=0; i<Cs.game.playerList.length; i++){
					Cs.game.playerList[i].removeDinoz(card);
				}
				
				// PROPRIETAIRE
				card.owner = Cs.game.getPlayer(data.$pid)
				
				// HACK
				if(data.$isEgg){
					card.setEclosionHint(0)
					card.flipOut();	
				}
				
				
				
				card.initInfo();
				pl.addDinoz(card,data.$place);
				waitList.push(card);
				break;
			case 2:	// ORDER
				//Log.trace("order!")
				pl.dinoz = new Array();	
				var a = data.$value.split(",")
				//Log.trace("order! "+a)
				for( var i=0; i<a.length; i++ ){
					if(a[i]!=""){
						var card =  Card.getCard(int(a[i]))
						pl.dinoz.push(card);
						waitList.push(card)
					}else{
						pl.dinoz.push(null)
					}
				}
				pl.orderDinoz(3);
				break;
		}
		
	}
	
	function update(){
		super.update();
		for( var i=0; i<waitList.length; i++ ){
			if( waitList[i].trg == null ){
				waitList.splice(i--,1)
			}	
		}
		if(waitList.length==0)kill();			
	}



//{
}