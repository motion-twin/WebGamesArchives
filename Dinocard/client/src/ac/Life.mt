class ac.Life extends Action{//}

	var data:DataLife;

	function new(d){
		super(d)
		data = downcast(d);
		
	}
	
	function init(){
		super.init();
		var pl = Cs.game.getPlayer(data.$pid);
		pl.setLife(data.$life)
		kill();
		
	}
	
	function update(){
		super.update();
	}



//{
}