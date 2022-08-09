class Gem extends Ball{//}
	
	

	
	function new(){
		type = 0
		super();
		
		var max = 3;
		var p = Cs.game.play;
		if(p>20)max++;
		if(p>60)max++;
		col = Std.random(max)
		/*
		if(Std.random( int(Math.min(5,50-Cs.game.play*0.05)) )==0){
			flIce = true;
		}
		*/
		setSkin(root)
	}
	
	
	function setSkin(mc){
		super.setSkin(mc);
		mc.gotoAndStop("1")
		var frame = col+1
		if(flIce)frame+=10
		mc.b.gotoAndStop(string(frame));
	}
	
	function explode(){
		for( var i=0; i<3; i++){
			var p = new Part( Cs.game.dm.attach("partIce",Game.DP_PART));
			var a = Math.random()*6.28
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var sp = 0.5+Math.random()*3
			var ray = 5
			p.x = root._x+ca*ray
			p.y = root._y+sa*ray	
			p.vx = ca*sp
			p.vy = sa*sp
			p.vr = (Math.random()*2-1)*16
			p.weight = 0.1+Math.random()*0.2
			p.root._rotation = a/0.0157 + 90 //Math.random()*360
			p.root.gotoAndPlay(string(Std.random(20)+1));
			p.timer = 10+Math.random()*50
			p.scale = 50+Math.random()*100
			p.fadeType = 1
			p.root._xscale = p.scale;
			p.root._yscale = p.scale;
			
			
		}
		super.explode();
	}
	
	
	
//{	
}