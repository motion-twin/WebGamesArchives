class Star extends Phys {//}

	var damage:float;
	
	function new(mc) {
		super(mc)
		Cs.game.nsList.push(this)
		damage=5
	}
	
	function update() {
		super.update();
		//list = Cs.game.grid[x][y].list
		for( var i=0; i<Cs.game.mList.length; i++ ){
			var m = Cs.game.mList[i];
			if( Math.abs(m.x-x)+Math.abs(m.y-y) < 20 ){
				m.hit(this);
				kill();
				break;
			}
		}
		// CHECK
		checkMouse();
		checkMedusa();
		// OUT
		if(isOut(40))kill();
	
	}
	
	function checkMouse(){
		if(!Cs.game.flMouseDead){
			var xm = Cs.game.map._xmouse+8
			var ym = Cs.game.map._ymouse+8
			if(Math.abs(x-xm)+Math.abs(y-ym)<15){
				Mouse.hide();
				Cs.game.flMouseDead = true;
				Cs.game.mouseDeadTimer = 50;
			
				var p = Cs.game.newPart("mcMouse");
				p.x = xm+8;
				p.y = ym+8;
				p.vy = -4;
				p.vx = vx*0.5;
				p.vr = 8+Math.random()*10;
				p.timer = 30+Math.random()*10;
				p.fadeType = 0;
				p.weight = 0.6;
				p.flPlatCol = true;
				p.ray = 8
				
				kill();
				return;
			
				/*
				var max = 6
					for( var i=0; i<max; i++ ){
					var p = Cs.game.newPart("partLight");
					var a = (i/max)*6.28 + (Math.random()*2-1)*0.3
					var ca = Math.cos(a);
					var sa = Math.sin(a);
					var sp = 2+Math.random()*4
					p.x = xm+ca*3;
					p.y = ym+sa*3;
					p.vx = ca*sp;
					p.vy = sa*sp;
					p.frict = 0.98
					p.fadeType = 0;
					p.timer = 10+Math.random()*10;
					p.setScale(100+Math.random()*100)
				}
				*/
				
				
			}
		}	
	}
	function checkMedusa(){
		if(vx<0){
			if(Cs.game.medusa.root.hitTest(x+Cs.game.map._x,y+Cs.game.map._y,true))klong();
		}
	}
	function klong(){
		var a = Math.atan2(-vy,-vx)+(Math.random()*2-1)*0.4
		var speed = Math.sqrt(vx*vx+vy*vy)*0.5
		
		var p = Cs.game.newPart("mcKlongShuriken");
		p.x = x
		p.y = y
		p.vx = Math.cos(a)*speed;
		p.vy = Math.sin(a)*speed;
		p.vr = 8+Math.random()*10;
		p.timer = 30+Math.random()*10;
		p.fadeType = 0;
		p.weight = 0.6;
		kill();
	}
	
	function kill(){
		super.kill();
		Cs.game.nsList.remove(this)
	}

	
//{
}








