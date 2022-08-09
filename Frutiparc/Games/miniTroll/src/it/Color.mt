class it.Color extends It{//}

	static var COLOR = [
		0xFF6600
		0xFF9900
		0xFFCC00
		0xFFFF00
		0x99FF00
		0x22DD00
		0x00BBFF
		0x5566FF
		0x7700EE
		0xFF22EE
	]
	var id:int;
	
	
	
	function new(){
		super();
		flEquip = true;
		link = "itemColor"
	}
	
	function setType(t){
		super.setType(t);
		id = type-60
	}	
	
	function faerieEffect(){
		fi.skin.col1 = COLOR[id]
		return true;
	}	
	
	function getPic(dm,dp){
		var pic = super.getPic(dm,dp);
		pic.gotoAndStop(string(id+1))
		Mc.setColor( downcast(pic).col, COLOR[id] )
		return pic;
	}

	function getName(){
		return "coloration pour cheveux";
	}
	
	function getDesc(){
		
		return  "Modifie la couleur des cheveux d'une fée une fois équipé."
	}
	
	

	
	
//{	
}






















