class spell.shot.Flame extends spell.Shot{//}

	var trg:sp.pe.Imp
	
	function new(){
		super();
		cost = 6
		freq = 1
		cdMax = 0
		minShotZone = 0
	}
	
	
	function update(){
		
		super.update();
			
		var r = 70
		var list = Cs.game.impList
		trg = null;
		for( var i=0; i<list.length; i++ ){
			var imp = list[i]
			var dist = caster.getDist(imp)
			if(  dist < r  ){
				r = dist
				trg = imp
			}
		}
		
		
		if( list.length > 0 && trg !=null){
			caster.trg = upcast(trg)			
		}
		
	}
	
	function shoot(){
		if(trg!=null){
			var s = newShot();
			s.link = "partFlameBall"
			s.damage = 2.2
			s.ray = 5
			s.recul = 0; 
			s.initSpellTrigger(12);
			s.initDirect(4);
			s.friction = 1.05
			s.init();
			s.angle = s.getAng(trg)
			s.updateVit();
		}
		
	}
	
	function trigger(shot){
		shot.weight = -(0.6+Math.random()*1.5)
		shot.trgList = new Array();
		var c = 0.6
		shot.vitx *= c
		shot.vity *= c
		shot.flGrav = true;
		shot.fadeTypeList = [3,1]
		shot.timer = 4+Math.random()*10
	}
	
	//
	function getName(){
		return "Clametorche "
	}

	function getDesc(){
		return "C'est une arme redoutable malgré sa courte portée."
	}
	
//{
}
	
