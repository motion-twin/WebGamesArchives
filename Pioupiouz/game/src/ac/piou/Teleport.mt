class ac.piou.Teleport extends ac.Piou{//}

	
	var tel0:sp.Teleport
	var tel1:sp.Teleport
	
	function new(x,y){
		super(x,y)
	}
	
	function init(){
		super.init();
		piou.root.gotoAndStop("launchTeleport")
		flExclu = true;
	}
	

	function update(){
		super.update();
		

	}	

	function launchTel(){
		
		var px = piou.x
		var py = piou.y - Piou.RAY
		if( !Level.isFree(px,py) ){
				go();
				kill();
				return;
		}
		
		tel0 = new sp.Teleport(null);
		tel0.bouncer.setPos(px,py)
		tel0.vy = -8
		tel0.vx = 8*piou.sens
		tel0.vr = 9
		tel0.root._rotation = 30
	}
	
	function dropTel(){
		piou.initStep(Piou.FLY)
		piou.vy = -3
		piou.y -= 2
		tel1 = new sp.Teleport(null);
		tel1.bouncer.setPos(piou.x,piou.y - Piou.RAY)
		tel0.pair = tel1
		tel1.pair = tel0
		kill();
	}	
	
	
//{
}