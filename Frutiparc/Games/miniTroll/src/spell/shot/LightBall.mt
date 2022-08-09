class spell.shot.LightBall extends spell.Shot{//}

	function new(){
		super();
		cost = 1
		freq = 5//50
		cdMax = 20
	}
	
	
	function shoot(){
		
		var s = newShot();
		s.link = "shotLightBall"
		s.damage = 15
		s.ray = 4
		s.init();
		s.initDirect(4)
		
	}
	
	
	

	
	
	//
	function getName(){
		return "Balles de lumieres "
	}

	function getDesc(){
		return "Elles permettent aux fées de se défendre contre les démons."
	}
	
//{
}
	