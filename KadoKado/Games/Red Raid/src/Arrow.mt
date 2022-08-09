class Arrow extends Phys{//}

	
	
	var angle:float;
	var va:float;
	var ca:float;
	
	var wp:{x:float,y:float,ray:float}
	
	var flWalk:bool;
	var flDeath:bool;
	
	var speed:float;
	var accel:float
	var speedMax:float;
	var tol:float;
	var frame:float;
	var hp:float;
	var hpMax:float;
	var armor:float;
	
	var lifePanelTimer:float;
	
	var type:int;
	var skin:MovieClip;
	var shadow:MovieClip;	
	var lifePanel:{>MovieClip, bar:MovieClip};
	
	function new(mc){
		super(mc)
		flWalk = true;
		flDeath = false;
		//
		va = 1
		ca = 0.1
		angle = 0
		//
		speed = 0
		tol = 10
		//
		armor = 0
		hp = 0;
		hpMax = 1;
		//
		initSkin();		
		
		
	}

	function initSkin(){
		root.gotoAndStop(string(type+1))
		skin = downcast(root).sub
		skin.stop();

	}
	
	function update(){
		super.update();
		if(downcast(wp).flDeath)wp=null;
		if(frame!=null)run();
		
		shadow._x = x;
		shadow._y = y;

		if(lifePanelTimer!=null){
			lifePanelTimer -= Timer.tmod;
			var limit = 5
			
			if(lifePanelTimer<limit){
				lifePanel._alpha = lifePanelTimer/limit * 100
				if( lifePanelTimer < 0 )hideLife();
			}
		}
		if( lifePanel != null ){
			lifePanel._x = x;
			lifePanel._y = y-ray;
		}		

	}
	
	function setVit(speed){
		vx = Math.cos(angle)*speed;
		vy = Math.sin(angle)*speed;
	}
	
	function towardVit(c,speed){
		var dvx = Math.cos(angle)*speed - vx;
		var dvy = Math.sin(angle)*speed - vy;
		vx += dvx*c;
		vy += dvy*c;
	}
	
	function towardAngle(ta){
		var da = Cs.hMod( ta-angle, 3.14)
		angle += Cs.mm(-Math.abs(da), Cs.mm(-va,da*ca,va)*Timer.tmod,Math.abs(da));
		//angle += Cs.mm(-va,da*ca,va)*Timer.tmod
		updateRotation();
	}
	
	function updateRotation(){
		root._rotation = angle/0.0174
	}
	
	function follow(){
		var dist = getDist(wp)
		var dSpeed =   Cs.mm( 0, (dist-tol)*0.1, 1 )*speedMax - speed
		speed += dSpeed*accel*Timer.tmod
		towardAngle(getAng(wp))
		setVit(speed);
		if(dSpeed<0.1 && dist < tol ){
			reachWp()
		}
		
	}
	
	function reachWp(){
		wp = null;
		vx = 0;
		vy = 0;
	}
		
	function hit( damage, a ){

		damage = Math.max(0,damage-armor)
		hp -= damage
		//
		showLife();
		lifePanelTimer = 30
		//		
		//
		if(hp<=0){
			die(a);
		}

	}
	
	function die(a){
		kill();
	}
	
	function kill(){
		flDeath = true;
		shadow.removeMovieClip();
		if(lifePanel!=null)lifePanel.removeMovieClip();
		
		super.kill();
	}
	
	function run(){
		var dist = Math.sqrt(vx*vx+vy*vy)
		frame = (frame+dist*2*Timer.tmod)%40
		skin.gotoAndStop(string(1+int(frame)))	
	}

	function showLife(){
		if( lifePanel == null ){
			lifePanel = downcast(Cs.game.dm.attach("mcHpBar",Game.DP_DRAW))
			lifePanel._x = x;
			lifePanel._y = y-ray;
		}
		lifePanel.bar._xscale = hp/hpMax * 100
		lifePanel._alpha = 100
	}
	
	function hideLife(){
		lifePanel.removeMovieClip();
		lifePanel = null;
		lifePanelTimer = null
	}
	
	function setWaypoint(pos){
		wp = pos
		if(flWalk && frame == null )frame = 0;
	}
	
//{
}