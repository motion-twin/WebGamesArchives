class Bonus extends Phys{//}

	static var SPEED = 1.5;
	static var MX = 11;
	static var MY = 15;

	static var STATS = [
		200	// FIREBALL
		200	// PINK BEAM
		200	// PLASMA
		  0
		  0
		  0
		  0
		  0
		  0
		  0
		100	// BOMB
		100	// TENTACULE
		100	// HOMING
		  0
		  0
		  0
		  0
		  0
		  0
		  0
		400	// BONUS VERT
		200	// BONUS BLEU
		 20	// BONUS ROUGE
		  0
		  0
		  0
		  0
		  0
		  0
		  0
		100	// BUILD
		300	// SPEED UP
		 50	// SHIELD
	]

	static var FRAME = [ 1,2,3,11,12,13,21,22,23 ]

	var id:int;

	function new(mc){
		super(mc)
		id = getRandomId();
		var h = Cs.game.hero;
		if( id==30 && h.flBuild ) id=21;
		if( id==31 && h.flSpeedUp ) id=21;
		if( id==32 && h.flShield ) id=21;
		if( id>=20 && id<23 )root.stop();

		var fr = id+1
		downcast(root).c.gotoAndStop(string(fr))
		downcast(root).frame = fr

		vx  = -SPEED
		vy  = (Std.random(2)*2-1)*SPEED*1.5

		frict = 1

	}

	function update(){

		super.update();
		//
		if( y<MY || y>Cs.GL-MY){
			vy*=-1
			y=Cs.mm(MY,y,Cs.GL-MY)
		}
		if( x<MX ){
			vx*=-1
			x=MX
		}
		if(y>Cs.mcw+MX ){
			kill();
		}
		//
		var help = 10
		if( Math.abs(Cs.game.hero.x-x)<MX+help && Math.abs( Cs.game.hero.y-y)<MY+help ){
			take();
		}


	}

	function take(){
		var h = Cs.game.hero
		Cs.game.stats.$b.push(id)
		var score = null
		switch(id){
			case 0:
			case 1:
			case 2:
				if( h.shotType == id ){
					h.shotPower = int(Math.min(h.shotPower+1,2))
				}else{
					h.shotType = id;
				}
				break;
			case 10:
			case 11:
			case 12:
				h.takeSide(id-10)
				break;
			case 20:
				score = Cs.C1000;
				break;
			case 21:
				score = Cs.C3000;
				break
			case 22:
				score = Cs.C10000;
				break;
			case 30:
				h.flBuild = true;
				break
			case 31:
				h.initSpeedUp();

				break
			case 32:
				h.initShield();
				break
		}
		if(score!=null){
			Cs.game.spawnScore( x, y, KKApi.val(score) )
			KKApi.addScore(score)
		}

		Cs.game.hero.updateCards();
		kill()
	}

	function getRandomId(){
		var sum = 0
		for( var i=0; i<STATS.length; i++ )sum += STATS[i];
		var rand = Std.random(sum)
		sum = 0
		for( var i=0; i<STATS.length; i++ ){
			sum += STATS[i];
			if(sum>rand)return i;
		}
		return null;
	}

	function kill(){

		super.kill();
	}



//{
}
