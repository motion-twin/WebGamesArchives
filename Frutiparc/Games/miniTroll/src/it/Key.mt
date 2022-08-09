class it.Key extends It{//}

	var id:int;

	
	function new(){
		super();
		flGeneral = true;
		link = "itemKey"
	}
	
	function grab(){
		super.grab();
		Cm.incKey(1)
		
	}
	
	function getName(){
		return "clé du donjon"
	}	
		
	
	
//{	
}


