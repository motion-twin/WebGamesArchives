class it.Potion extends It{//}

	static var NAME = [
		"Petite potion"
		"Potion standard"
		"Super potion"
	]
	static var DESC = [
		"En la buvant votre fée récupère 1 coeur."
		"En la buvant votre fée récupère 3 coeurs."
		"En la buvant votre fée récupère tous ses coeurs."
	]	
	var id:int;

	

	function new(){
		super();
		flUse = true;
		link = "itemPotion"
	}

	function setType(t){
		super.setType(t);
		id = type-70
	}	
	
	function use(fi){
		super.use(fi)
		switch(id){
			case 0:
				fi.incLife(1)
				break;
			case 1:
				fi.incLife(3)
				break;
			case 2:
				fi.incLife(99)
				break;				
		}
		type = null
	
	}	
	
	function getPic(dm,dp){
		var pic = super.getPic(dm,dp);
		pic.gotoAndStop(string(id+1))
		return pic;
	}

	function getName(){
		return NAME[id]
	}	

	function getDesc(){
		return DESC[id]
	}

//{	
}


