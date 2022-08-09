class Spark extends Part{//}

	
	var z:float
	var vz:float
	var gz:float
	var fbz:float
	
	var glow:float;
	var size:float;
	var length:int;
	var color:Array<int>
	var op:Array<{x:float,y:float,z:float}>

	var timerMax:float
	
	function new(mc){
		mc = Cs.game.dm.empty(Game.DP_PART)//Cs.game.dm.attach("partTest",Game.DP_PART)
		super(mc)
		op = []
		length = 1
		size = 1
		color = [0xFFFFFF]
		frict =  0.9
		fadeType = 99
		z = 0
		vz = 0
		gz = 0
		fbz = -0.8
	}
	

	function update(){
		
		updateDraw();
		
		while(op.length>10)op.pop();

		vz += gz*Timer.tmod
		vz *= Math.pow(0.95,Timer.tmod)
		z += vz*Timer.tmod
		if(z>0){
			vz*=fbz;
			z=0
		}

		
		super.update();
		op.unshift({x:x, y:y, z:z})

		
	}
	
	function updateDraw(){
		if(op.length<length)return;
		if( timer!=null && timerMax==null )timerMax=timer;
		
		var s = size
		if(timer<fadeLimit){
			s *= timer/fadeLimit
		}
		var col = color[0]
		if(color.length>1){
			col = Cs.mergeColor(color[0],color[1],timer/timerMax)
		}
		
		
		root.clear();
		

		var dx = op[length].x - x
		var dy = op[length].y - y
		var dz = op[length].z - z
		root.lineStyle(s,0,30)
		root.moveTo(0,0);
		root.lineTo(dx,dy);
		if(glow!=null){
			root.lineStyle(s+glow,col,20)
			root.moveTo(0,z);
			root.lineTo(dx,dy+op[length].z);
			col = Cs.mergeColor(col,0xFFFFFF,0.5)
		}
		root.lineStyle(s,col,100)
		root.moveTo(0,z);
		root.lineTo(dx,dy+op[length].z);
	}
	
	function initOp(){
		for( var i=0; i<length; i++ )op.push({x:x,y:y,z:z})
	}
	

	
	function kill(){
		super.kill();
	}
//{
}