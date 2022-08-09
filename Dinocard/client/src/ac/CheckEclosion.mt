class ac.CheckEclosion extends Action{//}

	
	var side:int;
	
	function new(d){
		super(d)
		
	}
	
	function init(){
		super.init();
		
		
		var pl = Cs.game.playerList[side];
		for( var i=0; i<pl.railDinoz.length; i++ ){
			var card = pl.railDinoz[i];
			if( card.tokens[Token.ECLOSION].length >= card.level ){
				card.birth();
			};
			
		}
		
		kill();
		
	}
	
	function update(){
		super.update();
	}



//{
}