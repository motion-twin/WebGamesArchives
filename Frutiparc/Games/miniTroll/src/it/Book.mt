class it.Book extends It{//}

	var id:int;

	
	function new(){
		super();
		link = "itemSpellBook"
	}
	
	function setType(t){
		super.setType(t)
		id = t-200
	}
	
	function groupEffect(fi){
		fi.spell.push(id)
		return true;
	}	
	
	function getPic(dm,dp){
		var pic = super.getPic(dm,dp);
		pic.gotoAndStop(string(id+1))
		return pic;
	}
	
	function getName(){
		return "Livre de sort "//Spell.newSpell(id).getName();
	}
	
	function getDesc(){
		return "Ce grimoire permet à toutes les fées d'utiliser le sort "+Spell.newSpell(id).getName()+"."
	}	
		
	
//{	
}


