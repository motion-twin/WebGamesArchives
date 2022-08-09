class Wave {//}
	
	static var PATH = [
		[[330,270],[205,270],[205,193],[281,192],[280,114],[-20,115]],	
		[[330,27],[35,25],[19,32],[11,46],[23,60],[268,131],[288,145],[287,161],[276,172],[-24,172]],
		[[330,17],[291,134],[249,205],[204,251],[135,275],[64,249],[23,187],[22,109],[68,43],[142,26],[206,49],[248,95],[289,172],[326,292]],
		[[333,149],[197,148],[95,70],[96,41],[116,21],[141,22],[157,41],[156,330]],
		[[306,9],[229,73],[171,91],[132,84],[107,51],[118,22],[151,7],[191,20],[202,55],[202,102],[187,140],[149,173],[79,181],[42,157],[36,122],[60,95],[95,95],[121,118],[120,154],[117,202],[120,245],[145,277],[178,291],[221,277],[277,202],[322,163]],
		[[351,188],[215,187],[142,171],[113,134],[114,90],[142,71],[175,79],[196,112],[227,133],[260,119],[268,84],[258,52],[227,33],[172,26],[114,39],[72,74],[54,132],[64,183],[94,231],[143,261],[208,273],[355,274]],
		[[-23,17],[21,17],[62,25],[97,50],[119,88],[152,109],[194,109],[243,108],[277,121],[284,143],[275,168],[243,184],[-16,185]]
	]
	
	var bList:Array<Bads>
	
	volatile var speed:float;
	volatile var ecart:float;
	
	var score:KKConst;
	
	var path:Array<Array<int>>
	var pl:Array<float>
	
	
	function new(id){
		var c = ( 0.3 + 0.7*Cs.game.dif/10000 );
		if(id==null)id = Std.random( int(PATH.length*c) );
		// INIT PATH
		var mp = PATH[id]
		path = new Array();
		for( var i=0; i<mp.length; i++ ){
			path[i] = mp[i].duplicate();
			//Log.trace(path[i])
		}
		//path = PATH[Std.random(PATH.length)].duplicate()
		if(Std.random(2)==0)flipPath();
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
		speed = 2;
		ecart = 30;
		//
		score = Cs.C500;
	}
	
	function flipPath(){
		for( var i=0; i<path.length; i++ ){
			var a = path[i]
			var h = (Cs.mch+Cs.MY)*0.5
			a[1] = h-(a[1]-h)
		} 
	}
	
	function addBads(b){
		b.way = -bList.length*ecart;
		b.waveIndex = bList.length; 
		b.pathIndex = 0; 
		bList.push(b);
		b.wave = this;
		b.bList.push(0);
		b.frict = 1
		b.x = path[0][0]
		b.y = path[0][1]
	}

	
//{	
}