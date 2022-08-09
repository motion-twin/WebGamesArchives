class Corn extends Phys{//}

	static var FRAME_MAX = 100;
	
	static var RAY = 5
	
	var timer:float;
	var frame:float;
	
	var step:int;
	
	
	function new(mc){
		mc = Cs.game.dm.attach("mcCorn",Game.DP_CORN)
		Cs.game.cList.push(this)
		super(mc)
		

		
		weight = 0.14+Math.random()*(0.1+Cs.game.boss.escPop)
		frict = 0.95
		
		
		step = 0
		
	}
	

	
	function update(){
		super.update();
		
		switch(step){
			case 0:
				if(y>Cs.game.ly){
					bouncer = new RoundBouncer(this);
					downcast(bouncer).onBounceAngle = callback(this,col)
					step = 1;
				}
				var m = RAY*2
				if( x < m || x> Cs.mcw-m ){
					x = Cs.mm(m,x,Cs.mcw-m)
					vx*=-1
				}
				
			
				break;
			case 1:
				
				if(timer!=null){
					timer -= Timer.tmod;
				}
				
				if( bouncer == null ){
					//
					frame = Math.min(frame+15*Timer.tmod,FRAME_MAX);
					root.gotoAndStop(string(int(frame)+1))
					
					//
					var m = new flash.geom.Matrix();
					m.rotate(root._rotation*0.0174);
					m.translate(int(root._x),int(root._y))
					Cs.game.lvl.draw(root,m,null,null,null,null)
					if( root._currentframe == root._totalframes ){
						kill();
					}
				}else{
					while( downcast(bouncer).isRoundFree(bouncer.px,bouncer.py) ){
						bouncer.px = int( Cs.mm( (RAY+3), bouncer.px, Cs.mcw-(RAY+3) ) )
						bouncer.py--
					}
				
				}			
				break;
		}
		

		if(y>Cs.HEIGHT)kill();
		
		
		
		
		
	}
	
	function col(a,n){
		if(timer==null){
			timer = 30;
		}else{
			
			if( timer < 0 && Math.abs(Cs.hMod(1.57-n,3.14)) < 1.57 ){
				if(Cs.game.hero.trg==this){
					Cs.game.hero.releaseJump();
				}
				
				Cs.game.ly = Math.min( Cs.game.ly, y-30)
				vx = 0
				vy = 0
				weight = 0
				removeBouncer();
				frame = 0
				//Log.clear();
				//Log.trace(Cs.HEIGHT-Game.LIMIT+">"+int(Cs.game.ly))
				/*
				if( (Cs.HEIGHT-Game.LIMIT) > Cs.game.ly ){
					Cs.game.focus = {y:y};
					Cs.game.initStep(9);
				}
				*/
				root._rotation = Math.random()*360
				
			}
		}
	}
	
	function explode(bx,by){
		
		for( var i=0; i<12; i++ ){
			var p = Cs.game.newPart("mcCornDebris")
			var a = Math.random()*6.28
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			var sp = 0.5+Math.random()*2
			
			p.x = x + ca*RAY*Math.random();
			p.y = y + sa*RAY*Math.random();
			p.vx = ca*sp + bx*0.5
			p.vy = sa*sp + by*0.5
			p.setScale(50+Math.random()*50)
			p.timer = 10+Math.random()*10
			p.weight = 0.05+Math.random()*0.1
			p.fadeType = 0
			p.root.gotoAndStop(string(Std.random(root._totalframes)+1))
			/*
			if(Std.random(4)==0){
				p.bouncer = new Bouncer(this)
				p.bouncer.setPos(x,y)
				p.timer += 20
			}
			*/
			
		}
		
		var impact = downcast(Cs.game.dm.attach("mcImpact",Game.DP_PART))
		impact._x = x;
		impact._y = y;
		impact.frame = 0
		impact.fs = 9
		Cs.game.animator.push(impact)
		
		kill();
	}
	
	function kill(){
		Cs.game.cList.remove(this)
		super.kill()
	}
		
	
	

	
	
//{
}