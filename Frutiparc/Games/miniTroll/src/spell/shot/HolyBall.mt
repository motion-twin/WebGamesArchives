class spell.shot.HolyBall extends spell.Shot{//}


	function new(){
		super();
		cost = 8
		freq = 1
		cdMax = 80
		minShotZone = 60
	}
	
	function shoot(){
	
		var s = newShot();
		s.link = "shotHolyBall"
		s.damage = 80
		s.ray = 10
		s.recul = 8; 
		s.initDirect(4);
		s.friction = 1.01
		s.typeList.push(1)
		s.init();

	}
	

	//
	function getName(){
		return "Damaides "
	}

	function getDesc(){
		return "Ce sont de puissantes vagues d'energie qui détruisent tout sur leur passage."
	}
	
//{
}
	
