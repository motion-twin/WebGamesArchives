class it.Carac extends It{//}

	var inc:int;
	var car:int;
	
	

	
	
	function new(){
		super();
		flEquip = true;
		link = "itemCarac"
	}
	
	function setType(t){
		super.setType(t);
		car = Math.floor(type/5);
		inc = (type%5)+1;
	}	
	
	function faerieEffect(){
		fi.carac[car] += inc;
		return true;
	}	
	
	function getPic(dm,dp){
		var pic = super.getPic(dm,dp);
		pic.gotoAndStop(string(type+1))
		return pic;
	}

	function getName(){
		return nameList[type];
	}
	
	function getDesc(){
		
		var str = "Augmente de "+inc+" point"
		if(inc>1)str+="s "
		str += "la caractéristique "+carNameList[car]+"de la fée";
		
		return  str
	}
	
	static var carNameList = [
		"force "
		"rapidité "
		"vie "
		"intelligence "
		"concentration "
		"mana "
	]
	
	static var nameList = [

		"Gant de cuir "
		"Gantelet en fer "
		"Brassard du dragon "
		"f4  "
		"f5 "
	
		"Chaussures grossieres "
		"Souliers cursifs "
		"Ballerines du sirocco "
		"r4 "
		"r5 "	
	
		"Racine primordiale "
		"Cocarde tenace "
		"Couronne gauloise "
		"v4 "
		"v5 "

		"Perles de discernement "
		"Bracelet Siméen "
		"Jade de clairvoyance "
		"i4 "
		"i5 "
		
		"Tanagra d'argile "
		"Tanagra d'emeraude "
		"Tanagra de granite "
		"c4 "
		"c5 "
		
		"Amethyste "
		"Aigue marine "
		"Rubis du dragon "
		"m4 "
		"m5 "			
	]


	
	
//{	
}






















