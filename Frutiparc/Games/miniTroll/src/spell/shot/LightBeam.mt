class spell.shot.LightBeam extends spell.Shot{//}

	function new(){
		super();
		cost = 2
		freq = 20//50
		cdMax = 8
	}
	
	
	function shoot(){
		var s = newShot();
		s.link = "shotLightBeam"
		s.damage = 15
		s.ray = 2
		s.init();
		s.initDirect(6)
		s.orient();
	}
	
	
	//
	function getName(){
		return "theo laser "
	}

	function getDesc(){
		return "Ce tir rapide permet de toucher les demons les plus nerveux."
	}
	
//{
}
	