class spell.shot.Wisp extends spell.Shot{//}

	function new(){
		super();
		cost = 4
		freq = 60
		cdMax = 4
	}
	
	
	function shoot(){
		
		for( var i=0; i<3; i++ ){
			var s = newShot();
			s.link = "shotWisp"
			s.damage = 8
			s.ray = 3
			s.init();
			s.initHoming( 4, 0.4, 0.08 , 0 )
			s.initQueue("partQueueStandard")
			s.angle += (i-1)*0.6
			s.updateVit()
		}
	}
	
	
	//
	function getName(){
		return "Meches fantomes "
	}

	function getDesc(){
		return "Les mèches poursuivent votre ennemi, mais elles ne sont pas très puissantes."
	}
	
//{
}
	


