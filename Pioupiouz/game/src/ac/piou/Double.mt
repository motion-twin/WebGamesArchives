class ac.piou.Double extends ac.Piou{//}


	var list:Array<Piou>;
	
	function new(x,y){
		super(x,y)
	}
	
	function init(){
		super.init();
		
		var piou2 = new Piou(null)
		piou2.bouncer.setPos(piou.x,piou.y)
		if(piou.sens==1)piou2.reverse();
		
		list= [piou,piou2]
		
		for( var i=0; i<list.length; i++ ){
			var p = list[i]
			p.initStep(Piou.FALL)
			p.vx = 1.5*p.sens
			p.vy = -2
			p.root.gotoAndStop("jump")
		}
		
		piou.gerb(-1.57,1.57,8,2)
	}
	
	function update(){
		super.update();
		for( var i=0; i<list.length; i++ ){
			var p  = list[i]
			p.root._rotation = p.vy*10*p.sens
			if( p.step != Piou.FALL )list.splice(i--,1);
		}
		if(list.length==0)kill();
	}

	
//{
}