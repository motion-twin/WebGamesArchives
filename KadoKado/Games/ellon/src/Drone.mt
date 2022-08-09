class Drone extends Bads{//}

	var flLeader:bool;
	var flOndulator:bool;


	
	
	function new(mc){
		level = 1.5
		super(mc)
		ray = 10
		hp = 1
		root.stop();
		frict = 1
		score = Cs.SCORE_DRONE
		shootRate = 400
		gid = 1
		cooldown = 100
	}
	
	function update(){
		super.update();
		
	}
	
	function shoot(){

		if(flOndulator){
			var s = newAimedShot(4,0.2);
			s.setSkin(8)
			cooldown = 20
		}else{
			var s = newAimedShot(2.5,0.5);
			s.setSkin(2)
			cooldown = 30
		}
		
		
	}
	
	function setLeader(){
		flLeader = true;
		root.gotoAndStop("2");
		hp = 4
		shootRate = 30
		gid = 21
	}
	
	function setOndulator(){
		root.gotoAndPlay("1");
		shootRate = 50
		flOndulator = true;
		hp = 2
		gid = 22
	}
	
	
	function explode(){

		super.explode();
		
		//
		if(flLeader){
			for( var i=0; i<wave.bList.length; i++ ){
				var b = wave.bList[i]
				if(b!=null){
					b.a = Math.atan2(b.vy,b.vx)
					b.va = 0
					b.bList.push(1)
					b.bList.remove(0)
				}
			}
		}
		
		
		
	}
	
	

//{
}