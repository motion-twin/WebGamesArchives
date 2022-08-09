class it.SpecialPower extends It{//}

	var id:int;

	
	
	function new(){
		super();
		flEquip = true;
		link = "itemSpecialPower"
	}
	
	function setType(t){
		super.setType(t);
		id = type-40
	}	
	
	function faerieEffect(){
		
		fi.sPow[id] = true;
		
		return true;
	}	
		
	function getPic(dm,dp){
		var pic = super.getPic(dm,dp);
		pic.gotoAndStop(string(id+1))
		return pic;
	}

	function getName(){
		return nameList[id];
	}
	
	function getDesc(){
		return  descList[id];
	}
		
	static var nameList = [

		"Poudre d'invisibilite "
		"Masque tribal "
		"Ankh sylvaine "
		"Azur D'Avalon "
		"Calice Hatalan"
		"Serre-tete a corne "
		"Totoche "
		"f7 "
		"f8 "
		"f9 "
	]

	static var descList = [
		"Votre fée devient semi-transparente, elle sera donc plus difficile à toucher."
		"Votre fée effraie les démons."
		"Votre fée reconstitue l'énergie d'un coeur blessé, au cours du jeu."
		"Votre fée reconstitue plus vite ses réserves de mana. "
		"Votre fée apprend plus vite de ses expériences. "
		"Votre fée charge plus souvent, et augmente ses dégats. "
		"Votre fée ne peut plus parler. "
		"f7 "
		"f8 "
		"f9 "
	]
	
	
//{	
}



