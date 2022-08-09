class Wave {//}
	

	
	var flLinear:bool;
	
	var bList:Array<Bads>
	
	var speed:float;
	var ecart:float;
	
	var score:KKConst;
	
	var path:Array<Array<int>>
	var pl:Array<float>
	
	
	function new(id,sp,fl){
		flLinear = fl;
		//var c = ( 0.3 + 0.7*Cs.game.dif/10000 );
		//if(id==null)id = Std.random( int(Stykades.PATH.length*c) );
		// INIT PATH
		var mp = Stykades.PATH[id]
		path = new Array();
		for( var i=0; i<mp.length; i++ ){
			path[i] = mp[i].duplicate();
		}
		
		//if(Std.random(2)==0)flipPath();
		
		pl = [0];
		var dist = 0;
		var x = path[0][0];
		var y = path[0][1];
		for( var i=1; i<path.length; i++ ){
			
		
				var p = path[i];
				var dx = p[0] - x;
				var dy = p[1] - y;
				dist += Math.sqrt(dx*dx+dy*dy)
				pl.push(dist)
				x = p[0];
				y = p[1];
	
		}
		
		
		//
		bList = new Array();
		speed = sp;
		ecart = 30;
		//
		score = Cs.C500;
	}
	
	function flipPath(n){
		for( var i=0; i<path.length; i++ ){
			var a = path[i]
			var w = Cs.mcw*0.5
			a[n] = w-(a[n]-w)
		} 
	}
	

	
	function addBad(b){
		b.way = -bList.length*ecart;
		b.waveIndex = bList.length; 
		b.pathIndex = 0; 
		bList.push(b);
		b.wave = this;
		b.bList.push(0);
		b.frict = 1
		b.x = path[0][0]
		b.y = path[0][1]
		b.vx = 0;
		b.vy = 0;
	}

	
	function addBads(f,max){
		for( var i=0; i<max; i++ ){
			var b = f();
			addBad(b)
		}
	}
	
//{	
}