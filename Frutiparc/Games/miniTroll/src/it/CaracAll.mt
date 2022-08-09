class it.CaracAll extends It{//}

	var id:int;

	
	
	function new(){
		super();
		link = "itemCaracAll"
	}
	
	function setType(t){
		super.setType(t);
		id = type-50
	}	
	
	function groupEffect(fi){
		fi.carac[id] += 1;
		return true;
	}	
	
	function getPic(dm,dp){
		var pic = super.getPic(dm,dp);
		pic.gotoAndStop(string(id+1))
		return pic;
	}

	function getName(){
		return NAME[id];
	}
	
	function getDesc(){
		return  "Augmente de 1 point la caracteristique "+it.Carac.carNameList[id]+"de toutes les fées";
	}
		
	static var NAME = [

		"globe de Churele"
		"globe de Remesh"
		"globe de Mederet"
		"globe de Henata"
		"globe de Hastophies"
		"globe de Suez"
	]


	
	
//{	
}




