class it.Scroll extends It{//}

	var id:int;

	
	function new(){
		super();
		flEquip = true;
		link = "itemScroll"
	}
	
	function setType(t){
		super.setType(t)
		id = t-100
	}
	
	function faerieEffect(){
		fi.spell.push(id)
		return true;
	}	
	
	function getPic(dm,dp){
		var pic = super.getPic(dm,dp);
		pic.gotoAndStop(string(id+1))
		return pic;
	}
	
	function getName(){
		return "Parchemin "//Spell.newSpell(id).getName();
	}
	
	function getDesc(){
		return "Ce parchemin permet à la fée qui le porte d'utiliser le sort "+Spell.newSpell(id).getName()+"."
	}	
	
//{	
}


