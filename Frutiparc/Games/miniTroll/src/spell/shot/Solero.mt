class spell.shot.Solero extends spell.Shot{//}

	function new(){
		super();
		cost = 3
		freq = 1
		cdMax = 30
	}
	
	
	function shoot(){
		var s = newShot();
		s.link = "shotSolero"
		s.damage = 35
		s.ray = 5
		s.init();
		s.initDirect(4.5);
		s.orient();
	}
	
	
	//
	function getName(){
		return "Solero shot "
	}

	function getDesc(){
		return "Tir efficace bien que vert."
	}
	
//{
}
	


