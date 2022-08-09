class Star extends Shoot {//}

	var damage:float;
	
	function new(mc) {
		super(mc)
		Cs.game.nsList.push(this)
		damage=5
	}
	
	function update() {
		super.update();
		//list = Cs.game.grid[x][y].list
	
	}
	
	function checkCol(){
		super.checkCol();
		var list = Cs.game.grid[x][y].list
		
		if(list.length>0){
			var m = list[0]
			m.hit(this)
			kill();
		}
		
		/*
		var list = Cs.game.mList
		for( var i=0; i<list.length; i++ ){
			var m = list[i]
			var d = Math.abs()
		}
		*/
		
	}
	
	function kill(){
		super.kill();
		Cs.game.nsList.remove(this)
	}

	
//{
}








