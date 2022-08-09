class it.Bag extends It{//}

	var id:int;

	
	function new(){
		super();
		flGeneral = true;
		link = "itemBag"
	}
	
	function grab(){
		super.grab();
		Cm.getNewBag(id+1)
	}
	
	function setType(t){
		super.setType(t)
		id = t-80
	}
	
	function getPic(dm,dp){
		var pic = super.getPic(dm,dp);
		pic.gotoAndStop(string(id+1))
		return pic;
	}
	
	
	
//{	
}


