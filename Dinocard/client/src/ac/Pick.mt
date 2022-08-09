class ac.Pick extends Action{//}

	var data:DataPick;
	var card:Card;
	
	
	function new(d){
		super(d)
		data = downcast(primedata)
		
	}
	
	function init(){
		super.init();
		
		//Log.trace("!pick! ")
		var pl = Cs.game.getPlayer(data.$pid)


		
		
		var flDraw = true;
		var flPlay = false;
		var flGrave = false;
		var card = null;
		
		// RESURECTION DEPUIS LE GRAVEYARD
		if(data.$graveyard==null){
			card = pl.pack.getTopCard();
			card.x = pl.pack.x
			card.y = pl.pack.y + pl.pack.card.y	
			//Log.trace("draw! ("+card.id+")")
		}else{
			card = pl.graveyard.getCard(data.$graveyard);
			card.x = pl.graveyard.x
			card.y = pl.graveyard.y + pl.graveyard.card.y
			flGrave = true;
			
			//Log.trace("graveyard LalalatsooOOOooOOOoouin ! ("+card.id+")")
			
			
			var name = card.getName()
			Cs.log( pl.data.$name+" prend la carte "+name+" dans son cimetierre", 3 )
			
			
		}
		card.owner = pl
		card.setScale(70)
		
		

		
		var name = card.getName()
		
		switch(data.$result){
			case 0:
				if(!pl.flHero && !flGrave )name = "un dinoz";
				Cs.log( pl.data.$name+" invoque "+name, 3 )
				flPlay = true;
				break;
			case 1:
				Cs.log( pl.data.$name+" défausse "+name+" car il n'y a plus de d'espace libre!", 3 )
				var a = []
				for( var i=0; i<pl.dinoz.length; i++ )a.push(pl.dinoz[i].root)
				Cs.game.setFlashMessage("PAS ASSEZ DE PLACE !",pl.side,a)
				break;
			case 2:
				Cs.log( pl.data.$name+" lance le sort "+name, 3 )
				flPlay = true;
				break;
			case 3:
				Cs.log( pl.data.$name+" n'a pas assez d'energie pour lancer le sort "+name, 3 )
				var a = []
				for( var i=0; i<pl.energies.length; i++ )a.push(pl.energies[i].root)				
				a.push(downcast(card.root).face.mcLevel)
				Cs.game.setFlashMessage("PAS ASSEZ D'ENERGIE !",pl.side,a )
				break;
			case 4:
				Cs.log( pl.data.$name+" ne peut lancer le sort "+name+" car aucune cible n'est disponible", 3 );
				Cs.game.setFlashMessage("AUCUNE CIBLE DISPONIBLE !",pl.side,[])
				break;
			case 5:
				Cs.log( pl.data.$name+" ajoute "+name+" à sa reserve d'energie", 3 );	
				break;	
			case 6:
				Cs.log( name+" est contré !", 3 );
				break;
			case 7:
				Cs.log( pl.getOpponent().data.$name+" prend le controle de "+name, 3 );	
				break;
			case 8:
				Cs.log( pl.data.$name+" defausse la carte "+name, 3 );	
				flDraw = false;
				break;
			case 9:
				var el = Card.getEnergyName(card.data.$element)
				Cs.log( pl.data.$name+" n'a pas d'energie "+el+" pour lancer le sort "+name, 3 )
				var a = []
				for( var i=0; i<pl.energies.length; i++ )a.push(pl.energies[i].root)				
				a.push(downcast(card.root).face.mcLevel)
				Cs.game.setFlashMessage("PAS D'ENERGIE "+el.toUpperCase()+" !",pl.side,a )
				break;					
		}
		
		if( (card.data.$type==0 || !flPlay ) && !pl.flHero ){
			flDraw = false;
		}
		//if(data.$graveyard!=null)flDraw = true;
		
		
		if(flDraw || flGrave ){
			card.goto(Player.MARGIN*0.5 +5 , Cs.mch*0.5 + pl.side*40  ,200)
			card.flipIn()
			if(flGrave)card.instantFlipIn();
			Cs.game.togglePause();
			card.initInfo();
		}else{
			card.goto(card.x,card.y-5,70)
		}
		

		
		
	}
	
	function update(){
		super.update();
		if(card.trg==null){
			kill();
		}
		
	}



//{
}