class Puce extends Phys{//}

	var a:float;
	
	function new(mc){
		super(mc)
		Cs.game.puceList.push(this)
	}
	
	function update(){
		super.update();
	}
	
	function kill(){
		Cs.game.puceList.remove(this)
		root.removeMovieClip();
		Cs.game.sList.remove(this)
	}

//{
}