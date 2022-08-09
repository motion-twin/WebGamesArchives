class Dragon extends Bads{//}

	static var MARGIN = 30;
	static var ECART = 9;
	
	var flLeader:bool;
	var qList:Array<Dragon>
	var op:Array<Array<float>>
	var leader:Dragon;
	
	
	function new(mc){
		level = 4
		super(mc)
		ray = 18
		hp = 2
		root.stop();
		frict = 0.98
		score = Cs.SCORE_DRAGON
		gid = 2
		//500
	}
	
	function update(){
		super.update();
		if(flLeader){
			//Log.print(int(x)+","+int(y))
			//Log.print(trg.x+"-"+trg.y)
			var last = this;
			for( var i=0; i<qList.length; i++ ){
				var b = qList[i];
				var pos = op[(i+1)*ECART]
				b.x = pos[0]
				b.y = pos[1]
				b.root._rotation = b.getAng(last)/0.0174
				last = b;
			}
			op.unshift([x,y])
			while(op.length>300)op.pop();
			
			var fa = a
			while(fa<0)fa+=6.28;
			downcast(root).sub.gotoAndStop(string(int(1+80*(fa/6.28))))
			
			
		}
		//bounceFamily();

	}
	
	function shoot(){
		cooldown = 50
		var max = 3
		var ec = 0.3
		//var a = //getAng(Cs.game.hero)
		var sp = 5
		for( var i=0; i<max; i++ ){
			var c = ((i/(max-1))*2-1)
			var s = newShot();
			s.vx = Math.cos(a+c*ec)*sp
			s.vy = Math.sin(a+c*ec)*sp
			s.x += s.vx*4
			s.y += s.vy*4
			s.orient();
			s.setSkin(4)
		}
		
		
	}
	
	function setLeader(){
		flLeader = true;
		root.gotoAndStop("2");
		hp = 5
		shootRate = 80
		
		
		op = new Array();
		qList = new Array();
		for( var i=0; i<300; i++ )op.push([x,y]);

		
		// BEHAVIOUR
		bList.push(3)
		a = -1.57
		turnCoef = 0.1
		va = 0.05
		speed = 2.5
		
		// FIRST TRG
		trg = {
			x:Cs.mcw*0.5
			y:MARGIN+Math.random()*(Cs.GL-2*MARGIN)
		}
		
		//
		Cs.game.mdm.over(root)
		root._rotation = 0
	}
	
	function explode(){
		if(flLeader){
			for( var i=0; i<qList.length; i++ ){
				var b = qList[i]
				b.explode();
			}
		}else{
			if(leader.hp>0)leader.explodePart(this);	
		}
		super.explode();
	}
	
	function explodePart(eb){
		
		for( var i=0; i<qList.length; i++ ){
			
			if(eb==qList[i] && i<qList.length-1){
				//var newLeader = null
				i++
				var newLeader = qList[i]
				qList.splice(i,1)
				newLeader.setLeader();
				//*
				newLeader.op = new Array();
				for( var n=(i+1)*ECART; n<op.length; n++ ){
					var p = op[n]
					newLeader.op.push([p[0],p[1]])
				}
				//*/
				while(i<qList.length){
					var b = qList[i]
					qList.splice(i,1)
					newLeader.qList.push(b)
					b.leader = newLeader;
				}
			}
		}
	}
	
	function onTargetReach(){
		super.onTargetReach()
		trg = {
			x:MARGIN+Math.random()*(Cs.mcw-2*MARGIN)
			y:MARGIN+Math.random()*(Cs.GL-2*MARGIN)
		}
	}

	
	

//{
}