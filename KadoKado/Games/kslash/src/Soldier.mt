class Soldier extends Runner{//}

	var stMaxShot:int

	function new(mc) {
		super(mc);
		stShootWait = 36
		stDrop.push({w:1,id:10})
	}
	
	function setLevel(n){
		stLevel = n;
		switch(stLevel){
			case 1:
				hp =  10
				score = Cs.C30;
				stClimbWait = 32
				stTossClimb = 12
				stTossSmart = 4	
				stTossShoot = null
				speed=2
				noSpikes();
				stDrop.push({w:70,id:4})
				//stDrop.push({w:500,id:10})
				break;
			case 2:
				hp = 40
				score = Cs.C100
				stTossClimb = 12
				stTossSmart = 3
				stTossShoot = 10
				stMaxShot = 3
				speed=3
				noSpikes();
				stDrop.push({w:50,id:4})
				stDrop.push({w:30,id:5})
				stDrop.push({w:20,id:8})
				stDrop.push({w:1,id:9})
				break;
			case 3:
				hp = 60
				score = Cs.C200
				stTossClimb = 6
				stTossSmart = 1
				stTossShoot = 4
				stMaxShot = 1
				stShootWait = 12
				speed=5
				flSpike = true;
				stDrop.push({w:40,id:5})
				stDrop.push({w:20,id:6})
				stDrop.push({w:20,id:7})
				stDrop.push({w:1,id:9})
				break;			
		}
		downcast(root).b1.gotoAndStop(string(stLevel))
	}
	
	function update() {
		super.update();
		switch(step){
			case Cs.ST_SHOOT:
				if((Cs.game.hero.x-x)*sens<0)setSens(-sens);
				
				break
		}
		
	}
	//
	function crossSquare(){
		super.crossSquare();

		
		
		
		//if( (isSmart() && Cs.game.hero.y>y+3) || Std.random(3)==0 )return;
		
		
		if(step==Cs.ST_NORMAL){
			if( Cs.game.checkFree(x+sens,y+1) ){
				if(isSmart()){
					if(Cs.game.hero.y>y+3){
						
					}else{
		
						var dif = Cs.game.hero.x-x;
						if( int(dif/Math.abs(dif))==sens ){
							tryJumpFront()
						}else{
							setSens(-sens)
						}
	
					}
					
				}else{
					var rnd = Std.random(7)
					switch(rnd){
						case 0:
							break;
						case 1:
						case 2:
							tryJumpFront();
							break;
						default:
							setSens(-sens)
							break;
						
					}
					
				}
				
			}else{
				if( stTossShoot!=null && Std.random(stTossShoot)==0 ){
					var d = getDist(Cs.game.hero)
					if( d< 180 ){
						initStep(Cs.ST_SHOOT)
					}
				}
			}
			
			
			
		}
	}

	function shoot(){
		
		var d = getDist(Cs.game.hero)
		var a = getAng(Cs.game.hero)
		var speed = 3
		var max = stMaxShot
		for( var i=0; i<max; i++ ){
			var da = (i/(max-1)-0.5)*0.4
			if(max==1)da=0;
			var s = new Kunai(Cs.game.mdm.attach("mcKunai",Game.DP_SHOOT))
			s.root._x = root._x;
			s.root._y = root._y;
			s.root._rotation = (a+da)/0.0174;
			s.vx = Math.cos(a+da)*speed
			s.vy = Math.sin(a+da)*speed
			s.x = x;
			s.y = y;
			s.dx = dx;
			s.dy = dy;
		}		
		super.shoot();
	}
	
	function noSpikes(){
		var mc = downcast(root)
		/*
		mc.b3._visible = false;
		mc.b4._visible = false;
		mc.b5._visible = false;
		/*/
		mc.b3.gotoAndStop("2")
		mc.b4.gotoAndStop("2")
		mc.b5.gotoAndStop("2")
		//*/
	}
	
//{
}






