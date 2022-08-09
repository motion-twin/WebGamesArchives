class Kunai extends Shoot {//}


	function new(mc) {
		super(mc)
		Cs.game.sList.push(this)
	}
	
	
	function checkCol(){
		super.checkCol();
		if(!Cs.game.hero.flInvicible && Cs.game.hero.sTimer==null){
			
			
			var dx = root._x - Cs.game.hero.root._x;
			var dy = root._y - Cs.game.hero.root._y;
			
			if(Math.sqrt(dx*dx+dy*dy)<14){
				Cs.game.hero.hit(this);
				kill();
			}
			
			
		}

		/*
		var list = Cs.game.mList
		for( var i=0; i<list.length; i++ ){
			var m = list[i]
			var d = Math.abs()
		}
		*/
		
	}
	
	function update(){
		super.update()
	}
	
	
	function kill(){
		super.kill();
		Cs.game.sList.remove(this)
	}

	
//{
}








