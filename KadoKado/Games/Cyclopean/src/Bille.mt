class Bille extends Phys{//}
	
	static var TURN = 0.4

	
	static var RAY = 5
	static var WEIGHT = 0.5
	
	
	var step:int;
	var angle:float;
	var timer:float;
	var bTimer:float;
	var sp:float;


	function new(mc){
		mc = Cs.game.dm.attach( "mcBille" ,Game.DP_PIOU)
		super(mc)
		
		frict = 0.98
		//weight = 0.5
		//
		Cs.game.bList.push(this)
		//
		//bouncer = new Bouncer(this)
	
		bouncer = new RoundBouncer(this)
		bouncer.frict = 0.5
		downcast(bouncer).setRoundShape(RAY,4)
		bouncer.onBounce = callback(this,onBounce)

		
		//
		angle = 0
		step = 1
		//
		newSpeedRot(5,30);
		
		
		setColor(Std.random(root._totalframes)+1)
	}
	

	function initGeneratorMode(){
		step = 2
		frict = 0.95
		sp = 0.4+Math.random()*0.5
		bTimer = 200
		timer = 0
		newSpeedRot(15,15)
		
	}
	
	function update(){
		
		
		
		
		switch(step){
			case 1:
				sp = 0.6
				towardAngle(Cs.game.ball)
				if( getDist({x:Cs.LEVEL_SIDE*0.5,y:Cs.LEVEL_SIDE*0.5}) < 100 ){
					initGeneratorMode();
					Cs.game.generator.push(root._currentframe);
					if(!Cs.game.flCenterActive)kill();
				}
				break;
			case 2:

				var center = {x:Cs.LEVEL_SIDE*0.5,y:Cs.LEVEL_SIDE*0.5}
				towardAngle(center)
				
				if(Math.random()<0.2 && Timer.tmod<1.4 ){
					var p = Cs.game.newPart("mcLightFlip");
					var c = Math.random()*0.5
					p.x = x;
					p.y = y;
					p.vx = vx*c
					p.vy = vy*c
					p.setScale(100+Math.random()*100)
					p.timer = 10+Math.random()*10
					p.fadeType = 0
				}
				

				
				if(bTimer!=null){
					bTimer -= Timer.tmod
					if(bTimer<0){
						bTimer = null;
						bouncer = null;
					}
				}

				
				break;
		}
		super.update();

	}

	function towardAngle(trg){
		var da = Cs.hMod( getAng(trg) - angle, 3.14 )
		angle += Cs.mm( -TURN, da*0.2*Timer.tmod, TURN )
		vx += Math.cos(angle)*sp*Timer.tmod;
		vy += Math.sin(angle)*sp*Timer.tmod;
		
	}
	
	function onBounce(x,y){
		if(Math.abs(vx)+Math.abs(vy)>7){
			
			newSpeedRot(5,10+Math.abs(vx)+Math.abs(vy)*3);
		}
	}
	
	function kill(){
		Cs.game.bList.remove(this)
		super.kill()
	}
	
	function newSpeedRot(base,inc){
		vr = (base+Math.random()*inc)*(Std.random(2)*2-1)
	}
	
	function setColor(fr){
		root.gotoAndStop(string(fr))
	}
	
//{
}