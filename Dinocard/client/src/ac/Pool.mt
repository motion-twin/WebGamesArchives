class ac.Pool extends Action{//}

	
	
	var data:DataPool;
	var list:Array<Card>;
	
	function new(d){
		super(d)
		data = downcast(primedata)
	}
	
	function init(){
		super.init();
		var pl = Cs.game.getPlayer(data.$pid)
		var from = Card.getCard(data.$from)
		pl.energies = new Array()
		
		for(var i=0; i<data.$list.length; i++ ){
			var id = data.$list[i]
			var c = Card.getCard(id)
			
			if(c==from){
				c.flipOut();
				c.disenchant();
				c.owner.removeDinoz(c)
			}
			if(c==null){
				c = new Card(null);
				c.setId(id);			
				c.flipOut();
				c.toggleShadow();
				c.copyCard(from)
			}
			
			//c.setEnergie();
			
			Cs.game.makeHint(c.area,"energie "+Card.getEnergyName(c.data.$element),0,-1)
			
			/*
			if( data.$effect){
				c = new Card(null);
				c.setId(id);			
				c.flipOut();
				c.toggleShadow();
				c.copyCard(from)
			}else{
				c = Card.getCard(id)
				c.flipOut();
			}			
			*/
			/*
			var pos = pl.getEnergyPos(i,int(m));
			c.goto(pos.x,pos.y,70);
			*/
			pl.energies.push(c)
		}

		pl.orderEnergies();
		
		
	}
	
	
	
	
	function update(){
		super.update();
		var flKill = true;
		for( var i=0; i<list.length; i++ ){
			if(list[i].trg!=null){
				flKill = false;
				break;
			}
		}
		if(flKill)kill();
	}



//{
}