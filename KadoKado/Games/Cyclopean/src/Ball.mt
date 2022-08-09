class Ball extends Phys{//}
	
	static var RAY = 8
	static var WEIGHT = 0.5
	static var DASH_BOOST = 60

	var flPrepareDash:bool;
	var dashTimer:float;
	var vrot:float;
	
	var trc:flash.display.BitmapData;

	var sq:{ dec:float, sp:float, am:float }
	
	
	function new(mc){
		mc = Cs.game.dm.attach( "mcPiou" ,Game.DP_PIOU)
		super(mc)
		
		frict = 0.98
		weight = 0.5

		flPrepareDash = false;
		
		//
		vrot = (Math.random()*2-1)*20
		root._rotation = Math.random()*360
		root._xscale = 135
		root._yscale = root._xscale
		//
		bouncer = new RoundBouncer(this)
		bouncer.frict = 0.5
		downcast(bouncer).setRoundShape(RAY,16)
		downcast(bouncer).onSwapPixel = callback(this,traceQueue)
		downcast(bouncer).hitPoint = callback(this,impact)
		//
		initTrace();

	}
	
	function initTrace(){
		var mc = Cs.game.dm.attach("mcTrace",Game.DP_BASE);
		trc = new flash.display.BitmapData(RAY*2,RAY*2,true,0x00000000)
		Cs.drawMC(trc,mc)
		mc.removeMovieClip();
	}
	
	function update(){
		
	
		for( var i=0; i<Cs.game.eList.length; i++){
			var e = Cs.game.eList[i];
			var dx = x-e.x;
			var dy = y-e.y;
			var screen_limit = 280
			if( Math.abs(dx)<screen_limit && Math.abs(dy)<screen_limit ){
				if(!e.flActive)e.attach();
				if( getDist(e) < RAY+Element.RAY ){
					e.collide(this);
				}
			}else{
				if(e.flActive)e.detach();
			}
		}
		
		
		//root._rotation = -Cs.game.scroller._rotation
		//vrot *= 0.98
		root._rotation += vrot//vrot*Timer.tmod
		
		//

		/*
		var flk = Key.isDown(Key.SPACE)
		if(flPrepareDash){
			if(flk){
				dashTimer = Math.min(dashTimer+Timer.tmod,100);
				var f  =Math.pow(0.7,Timer.tmod)
				vx*=f;
				vy*=f;
				Cs.setPercentColor(root,int(dashTimer),0xFFFFFF)
			}else{
				Cs.setPercentColor(root,0,0xFFFFFF)
				var c  = dashTimer/100
				vx = -Cs.game.gcos*DASH_BOOST
				vy = -Cs.game.gsin*DASH_BOOST
				flPrepareDash = false;
				weight = 0.5
				downcast(bouncer).onBounceAngle = callback(this,impact)
			}
		}else{
			if(flk){
				flPrepareDash  =true;
				dashTimer = 0
				weight = 0
			}
		}
		*/
		
		
		
		
		
		super.update();

	}
	
	function traceQueue(){
		var rect = new flash.geom.Rectangle(0,0,RAY*2,RAY*2)
		var px = bouncer.px + bouncer.ox - RAY;
		var py = bouncer.py + bouncer.oy - RAY;
		var p = new flash.geom.Point(px,py)
		Cs.game.prc.copyPixels(trc,rect,p,trc,null,true)	
	}
	

	function impact(cp){
		var pw = Cs.mm( 0, Math.sqrt(vx*vx+vy*vy)*0.5-3, 8)
		
		for( var i=0; i<pw; i++ ){
			var p = Cs.game.newPart("partImpact");
			var a = Math.random()*6.28
			var sp = 0.5+Math.random()*pw*2
			p.x = cp.x;
			p.y = cp.y;
			p.vx = Math.cos(a)*sp;
			p.vy = Math.sin(a)*sp;
			p.vr = (Math.random()*2-1)*20
			p.timer = 10+Math.random()*10;
			p.fadeType = 0;
			p.setScale(50+Math.random()*80)
			p.root._rotation = Math.random()*360
			p.bouncer = new Bouncer(p)
		}
		vrot = (Math.random()*2-1)*(10+pw*2)
		
	}
	
	function blast(coef){
		var mc = Cs.game.dm.attach("mcImpact",Game.DP_BASE)
		mc.blendMode = BlendMode.ERASE
		mc._x = x;
		mc._y = y;
		mc._xscale = coef*100
		mc._yscale = coef*100

		// PART
		for( var i=0; i<10+coef; i++ ){
			var ray = Math.random()*(RAY*coef)
			var ma = Math.random()*6.28
			var x = x+Math.cos(ma)*ray
			var y = y+Math.sin(ma)*ray
			var p = Cs.game.newDebris(x,y)
			p.bouncer = new Bouncer(p)
			p.timer += Math.random()*50
		}
		
		// DRAW
		Cs.drawMC(Cs.game.lvl,mc)
			
	}
	

	
	
//{
}