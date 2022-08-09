class Jeep extends Ally{//}


	
	function new(mc){
		type = 3
		super(mc)
		
		va = 0.13
		ca = 0.15
		ray = 20
		tol = 36

		accel = 0.1
		speedMax = 6

		
		mass = 0.1
		hpMax = 70
		armor = 1
		range = 80;
		damage = 12;	//8
		rate = 14;	//8	
		
		swivel = 3.14
		
		//
		flWalk = false;
	
	}
	
	
	function faceTrg(trg){
		var tur = downcast(skin).tur.t
		var pos = getTurretPos();
		var a = 3.14+downcast(trg).getAng(pos)
		var tr = Cs.hMod(a-angle,3.14)/0.0174
		
		var dr = Cs.hMod(tr - tur._rotation, 180)
		tur._rotation += Cs.mm( -Math.abs(dr), dr*0.3*Timer.tmod, Math.abs(dr) );
		//towarngle(getAng(trg))
	}
		
	function update(){
		super.update();
	}
	
	function attack(trg){
		super.attack(trg);

		var pos = getTurretPos();
		var a =( downcast(skin).tur.t._rotation + root._rotation)*0.0174//   3.14+downcast(trg).getAng(pos)
		downcast(skin).tur.t.play();
		
		for( var i=0; i<2; i++ ){
			var mc = Cs.game.dm.attach("partExploGun",Game.DP_PART)
			mc._x = pos.x 
			mc._y = pos.y
			mc._rotation = a/0.0174
		}
		
		
	}
	
	function getTurretPos(){
		return {
			x:x-Math.cos(angle)*14
			y:y-Math.sin(angle)*14
		}
	}
	
	function setWaypoint(pos){
		skin.gotoAndPlay("run")
		super.setWaypoint(pos)
	}
	
	function reachWp(){
		skin.gotoAndPlay("stop")
		super.reachWp();
		
	}
	
	function die(ba){
		super.die(ba)
		
		
		//
		var r = 25
		var mc = Cs.game.dm.attach("partOnde",Game.DP_PART)
		mc._x = x;
		mc._y = y;
		mc._xscale = r*2
		mc._yscale = mc._xscale
		
		mc = Cs.game.dm.attach("partExplosion",Game.DP_PART)
		mc._x = x;
		mc._y = y;
		mc._xscale = r*1.7
		mc._yscale = mc._xscale			
		
		//
		var cc = 0.75
		var frame = 1
		while(true){
			var a =Math.random()*6.28
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			var dist = Math.random()*ray
			var speed = (dist/ray)*8
			var sp = new Gibs(Cs.game.dm.attach("partJeep",Game.DP_PART));
			sp.x = x+ca*dist
			sp.y = y+sa*dist
			sp.z = 8-(dist/ray)*6
			sp.vx = ca*speed
			sp.vy = sa*speed
			sp.vz = sp.z*0.8
			sp.timer = 40+Math.random()*30
			sp.wz = 0.2+Math.random()*0.4
			sp.vr = (Math.random()*2-1)*16
			sp.frict = 0.94
			sp.root._rotation = Math.random()*360

			sp.root.gotoAndStop(string(frame));
	
			
			
			frame++
			if(frame>sp.root._totalframes)break;
			
		}	
	}
//{
}