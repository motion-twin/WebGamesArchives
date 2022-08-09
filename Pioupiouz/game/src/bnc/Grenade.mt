class bnc.Grenade extends Phys{//}

	static var TURN = 15
	static var EJECT = 12
	
	var timer:float;
	var ray:float;
	var rot:float;
	
	function new(mc){
		super(mc)
		ray = 50;
		timer = 100;
		weight = 0.15
		frict = 0.98
		bouncer = new RoundBouncer(this);
		bouncer.frict = 0.5
		bouncer.onBounce = callback(this,plonk);
		rot = (Math.random()*2-1)*TURN
	}
	
	function update(){
		super.update();
		timer-=Timer.tmod;
		
		root._rotation += rot;
		
		if( timer<0 ){
			
			// PARTICULE TERRE
			var max = 50
			for( var i=0; i<max; i++ ){
				var a = (i/max)*6.28
				var ca = Math.cos(a)
				var sa = Math.sin(a)
				var dist = Math.random()*ray
				var speed = 3-(dist/ray)*2.5
				var ppx = int(x+ca*dist)
				var ppy = int(y+sa*dist)				
				var p = Cs.game.newDebris(ppx,ppy);
				p.vx = ca*speed;
				p.vy = sa*speed;
				p.timer = 10+Math.random()*10
				p.setScale(100+Math.random()*100)
				if(Std.random(3)==0){
					p.bouncer = new Bouncer(p)
					p.timer += 60
				}
			}
			
			
			// EXPLOSION
			var mc = Cs.game.dm.attach("mcExplosion",Game.DP_PART)
			mc._x = x;
			mc._y = y;
			mc._xscale = ray*1.5
			mc._yscale = ray*1.5
			mc._rotation = Math.random()*360
			
			// HOLE
			//Level.genHole(x,y,ray)
			var sc  = (ray*2)/100
			Level.holeSecure("mcHole",x,y,sc,sc,0,1)
			
			// PIOU
			
			for( var i=0; i<Cs.game.pList.length; i++ ){
				var piou = Cs.game.pList[i]
				var pos = {x:piou.x,y:piou.y-5}
				var c = 1-getDist(pos)/ray
				if(c>0){
					var a = getAng(pos)
					piou.currentAction.interrupt();
					piou.initStep(Piou.FLY)
					piou.vx += Math.cos(a)*c*EJECT;
					piou.vy += Math.sin(a)*c*EJECT;
				}
			}
			
			//
			kill();
		}
		
		// RECAL
		if( !Level.isFree(bouncer.px,bouncer.py ) ){
			var p = Level.scanRecal(bouncer.px,bouncer.py)
			bouncer.setPos(p[0],p[1])
		}
		
	}
	
	function plonk(){
		rot =  (Math.random()*2-1)*TURN
	}
	

	
//{	
}