class spell.shot.Glue extends spell.Shot{//}

	function new(){
		super();
		cost = 5
		freq = 50
		cdMax = 12
	}
	
	
	function shoot(){
		
		var s = newShot();
		s.link = "shotGlue"
		s.damage = 32
		s.ray = 10
		s.recul = 3;
		s.scale = 0;
		s.init();
		s.initDirect(2)
		s.typeList.push(5)
		s.initBlob(  20, 36, -0.6 )
		s.blobInfo.dec = 314
		s.orient();
		downcast(s.skin).light._rotation = - s.skin._rotation

		//s.skin._xscale = s.scale // X-FILES
		//s.skin._yscale = s.scale // X-FILES
		
	}
	
	function hitTrg(trg,shot){
		trg.speed *= 0.6
		trg.freqShoot = Math.ceil(Math.max(trg.freqShoot*0.5, 1))
		Mc.setPercentColor(trg.skin,50,0xDDDD00)
		
		var cx = (trg.x+shot.x)*0.5
		var cy = (trg.y+shot.y)*0.5
		
		for( var i=0; i<12; i++){
			var p = Cs.game.newPart("partGlue",null)
			var a = Math.random()*6.28
			var sp = 1+Math.random()*3
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			p.x = cx+ca*sp*2;
			p.y = cy+sa*sp*2;
			p.vitx = ca*sp
			p.vity = sa*sp
			p.timer = 2+Math.random()*10
			p.scale = 100+(Math.random()*2-1)*50
			p.init();
			p.orient();
		}
		
	}
		
	//
	function getName(){
		return "Glumelle "
	}

	function getDesc(){
		return "La glumelle ralentie les demons touchés."
	}
	
//{
}
	


