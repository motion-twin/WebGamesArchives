class spell.imp.Night extends spell.Imp{//}

	var pieceTimer:int;
	var step:int;
	var timer:float;
	var blackRing:MovieClip;
	
	var x:float;
	var y:float;
	
	var prc:float;
	var scale:float;
	
	function new(){
		super();
	}
	
	function cast(){
		super.cast();
		if(Manager.mask!=null){
			//Manager.log("other>")
			endActive();
			super.dispel()
			return;
		}
		
		pieceTimer = imp.level;
		initStep(0)
	}
	
	function initStep(n){
		step = n 
		switch(step){
			case 0:
				centerCaster();
				break;
			case 1:
				prc=0;
				//timer = 20;
				break;
			case 2:
				setNight();
				break;
			
				
		}
	}
	
	function activeUpdate(){
		switch(step){
			case 0:
				
				caster.toward( caster.trg, 0.1 );
				
				if( isCasterReady(10) ){
					initStep(1);
				};
				break;
			case 1:
				prc = Math.min(prc+Timer.tmod*1.5,100);
				
				
				
				if( prc == 100 ){
					prc = 0;
					initStep(2)
				}
				
				Mc.setPercentColor( Manager.slot, prc, 0x000000 )
				
				//timer -= Timer.tmod;
				//if( timer < 0 )setNight();
				break;
			case 2:
				scale *= Math.pow(0.92,Timer.tmod)
				if(scale < 1 )scale = 0
				Manager.mask._xscale = 100-scale
				Manager.mask._yscale = 100-scale
				blackRing._xscale = 100-scale
				blackRing._yscale = 100-scale
				
				if(scale ==0 )endActive();
				
				
				break;
		}
	}
	
	function update(){
		
		var tx = caster.x
		var ty = caster.y
		
		var p = Cs.game.piece
		if( p.base._visible ){
			tx = p.base._x;
			ty = p.base._y;
		
		}
		
		var dx = tx-x
		var dy = ty-y
		
		var c = 0.2;
		x += dx*c*Timer.tmod;
		y += dy*c*Timer.tmod;
		
		
		Manager.mask._x = x
		Manager.mask._y = y
		blackRing._x = x;
		blackRing._y = y;
		
		
		
		
	}
	
	function onUpkeep(){
		pieceTimer--
		if(pieceTimer==0){
			dispel();
		}
	}
	
	function dispel(){
		//Manager.log("d>")
		blackRing.removeMovieClip();
		Manager.removeNightMask();
		
		super.dispel()
		
	}
	
	
	function setNight(){
		
		x = caster.x;
		y = caster.y;
		scale = 100
		
		Manager.setNightMask("mcNightMask")
		blackRing = Cs.game.dm.attach("mcBlackRing",Game.DP_PART)
		
		blackRing._x = -1000
		Manager.mask._x = -1000
		
		//endActive();
	}
	
	
	function getName(){
		return "Nuit Noire "
	}
	
	
//{	
}












