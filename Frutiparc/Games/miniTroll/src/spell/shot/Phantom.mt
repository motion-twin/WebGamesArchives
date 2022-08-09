class spell.shot.Phantom extends spell.Shot{//}


	function new(){
		super();
		cost = 10
		freq = 50
		cdMax = 10
	}
	
	function shoot(){
	
		var s = newShot();
		s.link = "shotPhantom"
		s.damage = 40
		s.ray = 8
		s.initHoming( 3, 0.4, 0.25 , 0 )
		s.initQueue("partQueuePhantom")
		s.typeList.push(7)
		s.init();

	}
	

	//
	function getName(){
		return "Ame en peine "
	}

	function getDesc(){
		return "Elle poursuit sa victime jusqu'a ce que celle-ci soit vidée de sa substance vitale."
	}
	
	
//{
}
	
