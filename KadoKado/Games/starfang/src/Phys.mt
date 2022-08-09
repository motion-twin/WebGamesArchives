class Phys extends Sprite{//}

	var ray:float;
	
	var weight:float;
	var frict:float;
	var vx:float;
	var vy:float;
	var vr:float;
	
	var flash:float;


	function new(mc){
		super(mc)
		//frict = 1
		vx = 0;
		vy = 0;
	}
	
	function update(){
		super.update();
		
		if( weight!=null ){
			vy += weight*Timer.tmod;
		}
		
		if( frict!=null ){
			var f = Math.pow(frict,Timer.tmod)
			vx *= f;
			vy *= f;
		}
		if(vr!=null){
			if( frict!=null )vr*=frict;
			root._rotation += vr*Timer.tmod
		}
	
		x += vx*Timer.tmod;
		y += vy*Timer.tmod;
		

		
		
	}
	
	function updateFlash(){
		if(flash!=null){
			var prc = Math.min(flash,100)
			flash *= 0.6
			if( flash < 2 ){
				flash = null
				prc = 0
			}
			Cs.setPercentColor(root,prc,0xFFFFFF)
		}	
	}
	
	function speedToward(o,c,lim){
		var a = getAng(o)
		var dx = o.x - x;
		var dy = o.y - y;
		vx += Cs.mm(-lim,dx*c,lim)
		vy += Cs.mm(-lim,dy*c,lim)
	}
	
	function collide(sp){
		var d = getDist(sp)
		return d<ray+sp.ray
	}
	
	function checkWarp(){
		if(x<-ray){
			x=Cs.mcw+ray
		}
		if(x>Cs.mcw+ray){
			x=-ray
		}
		if(y<-ray){
			y=Cs.mch+ray
		}		
		if(y>Cs.mch+ray){
			y=-ray
		}		
	}	

	//
	function fxOnde(sc){
		var p = Cs.game.dm.attach("mcOnde",Game.DP_UNDERPARTS)
		p._x = x;
		p._y = y;
		p._xscale = sc;
		p._yscale = sc;
	}
	
	function fxExplode(sc){
		var p = Cs.game.dm.attach("mcMiniExplo",Game.DP_UNDERPARTS)
		p._x = x;
		p._y = y;
		p._xscale = sc;
		p._yscale = sc;
	}
	
	function throwDebris(gid:int,coef:float){
		if(coef==null)coef=1;
		var fr = 0
		while(true){
			fr++
			var p = new Part(Cs.game.dm.attach("partDebris",Game.DP_PARTS))
			p.root.gotoAndStop(string(gid))
			var mc = downcast(p.root).sub
			mc.gotoAndStop(string(fr))
			
			var flBreak = (fr+1) > mc._totalframes*coef
			var a = Math.random()*6.28
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			var c = 0.5+Math.random()*0.5
			var sp = 3
			
			p.x = x + ca*c*ray;
			p.y = y + sa*c*ray;
			p.vx = vx + ca*c*sp;
			p.vy = vy + sa*c*sp;
			p.vr = (Math.random()*2-1)*15
			p.timer = 10+Math.random()*10
			p.fadeType = 0
			p.root._rotation = Math.random()*360
			if(flBreak)break;

		}
	}
	
	function getRandomPart(gid:int):Part{
		var p = new Part(Cs.game.dm.attach("partDebris",Game.DP_PARTS))
		p.root.gotoAndStop(string(gid))
		var mc = downcast(p.root).sub
		mc.gotoAndStop( string(Std.random(mc._totalframes)+1) )
		
		
		return p;
	}
				
//{
}