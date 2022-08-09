class spell.Shot extends spell.Base{//}


	var cd:float;
	var cdMax:float;
	var freq:float;
	var minShotZone:float;

	function new(){
		super();
		flShoot = true;
		
		freq = 100
		cd = 0
		cdMax = 20
		minShotZone = 40
	}
	
	
	function update(){
		//Manager.log("update!")
		if( cd<0 ){
			if( Std.random(int(freq/Timer.tmod)) == 0 ){
				shoot();
				cd = cdMax;
			}			
		}else{
			cd -= Timer.tmod;
		}
		
	}
	
	function shoot(){
		
	}
		
	function newShot(){
		var s = new sp.part.Shot();
		s.x = caster.x 
		s.y = caster.y
		s.caster = caster;
		s.spell = this;
		s.type = 0
		s.addToList(Cs.game.shotList)
		var list = Cs.game.impList;
		// AJOUTE LES CIBLES
		for( var i=0; i<list.length; i++ ){
			list[i].addToList(s.trgList)
		}
		
		return s;
	}
	
	function getName(){
		return "noShotName "
	}


	function hitTrg(trg,shot){
	
	}
	
	function trigger(shot){
	
	};
	
//{
}
	