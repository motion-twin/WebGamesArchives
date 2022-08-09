class Piece{//}

	var dx:float;
	var dy:float;
	
	var dm : DepthManager;
	var list:Array<Cub>
	
	var root:MovieClip;
	var game:Game;
	
	function new(mc,lst){
		root = mc;
		dm = new DepthManager(root);
		list =lst;
	}
	
	function build(flExt){
		var mg = new Array()
		

		
		for( var x=0; x<Cs.SHAPE_VOLUME; x++ ){
			mg[x] = new Array();
			for( var y=0; y<Cs.SHAPE_VOLUME; y++ ){
				mg[x][y]=false
			}
			
		}
		var xmax = 0
		var ymax = 0		
		for( var i=0; i<list.length; i++){
			var o = list[i]
			mg[o.x][o.y] = true;
			xmax = Math.max(xmax,o.x)
			ymax = Math.max(ymax,o.y)
		}
		
		dx = (xmax*0.5)
		dy = (ymax*0.5)
		
		for( var i=0; i<list.length; i++){
			var o = list[i]
			var mc = dm.attach("cube",1)
			mc._x = (o.x-dx)*Game.SIZE;
			mc._y = (o.y-dy)*Game.SIZE;
			mc.gotoAndStop(string(o.n+1))
			o.mc = mc;
			var frame = 1
			for( var n=0; n<4; n++ ){
				var d = Game.DIR[n]
				var nx = o.x + d.x
				var ny = o.y + d.y
				if( mg[nx][ny] )frame+=Math.pow(2,n)
				
			}
			o.s = int(frame)
			downcast(mc).sub.gotoAndStop(frame)
			
			if(flExt){
				var be = Std.attachMC(mc,"butExt",1)
				be._alpha = 0
			}
			
		}
		
	};
	
	function destroy(){
		for( var i=0; i<list.length; i++ ){
			var cub = list[i]
			cub.s = null;
			cub.mc.removeMovieClip();
			if(cub.mc!=null){
				
				
			}
		}
		
	}
	
	function sortList(){
		/*
		var s = fun(a,b){
			if((a.x+a.y)<(b.x+b.y)){
				return -1
			}else{
				return 1
			}
			
		}
		*/
		while(true){
			var swap = false;
			for( var i=0; i<list.length-1; i++ ){
				var a = list[i]
				var b = list[i+1]
				if((a.x+a.y)>(b.x+b.y)){
					list[i+1] = a
					list[i] = b
					swap = true;
				}
				
			}
			if(!swap)break;
		}
		
		
		//list.sort(s)
		
	}
	
	function kill(){
		root.removeMovieClip();
	}

	function burst(){
		for( var i=0; i<list.length; i++ ){
			
			var o = list[i]
			for( var n=0; n<10; n++ ){
				var p = game.newPart("partLight")
				p._x = (root._x +(o.x-0.5)*Game.SIZE) - dx
				p._y = (root._y +(o.y-0.5)*Game.SIZE) - dy
				var a = Math.random()*6.28
				var sp = 0.1+Math.random()*1
				p.vx = Math.cos(a)*sp
				p.vy = Math.sin(a)*sp
				p.t = 10+Math.random()*10
				p.scale = 50+Math.random()*100
				p._xscale = p.scale;
				p._yscale = p.scale;
				//p.gotoAndStop(string(list[0].n+1))
				p.ft = 0;
			}
		}
	}
	
//{	
}