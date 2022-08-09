class Special extends Ball{//}
	
	var sid:int
	
	function new(){
		super();
		//setSkin(root)
	}

	function setSkin(mc){
		super.setSkin(mc);
		mc.b.gotoAndStop(string(30+sid))
	}	
//{	
}