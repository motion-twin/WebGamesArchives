class Bonus extends Phys {//}

	static var STATS = [10,3,1,6,6,6,1]
	
	var ray:float;
	var bType:int;


	function new(mc){
		super(Cs.game.dm.attach("mcBonus",2));
		ray = 4 ;
		vy = 2;
		
		bType = getRandomId();
		root.gotoAndStop(string(bType+1))
		
		Cs.game.bonusList.push(this)
		
	}

	function update () {
		super.update()
		checkdeadLine();
		isTaken();
	}

	function isTaken(){
		var h = Cs.game.hero
		var adx = Math.abs(h.x-x);
		var ady = Math.abs(h.y-y);
		if( adx<h.hWidth+ray && ady<h.hHeight+ray )applyBonus();
	}
	function applyBonus(){
		switch (bType)    {
			case 0:
			case 1:
			case 2:
				var score = Cs.SCORE_BONUS[bType]
				KKApi.addScore( score  )
				Cs.game.dispScore(score,x,y)
				break;
			case 3:
				Cs.game.hero.speed = 8
				break;
			case 4:
				Cs.game.hero.type = 2;
				break;
			case 5:
				Cs.game.hero.fireRate = 10;
				break;
			case 6:
				Cs.game.hero.initBubble();
				
				break;				
		}	
		Cs.game.hero.flasher();
		kill();
		
	}
	function checkdeadLine() {
		if (  y > 310  ) kill();
	}
	function getRandomId(){
		var max = 0
		for( var i=0; i< STATS.length; i++ )max += STATS[i];
		var rand = Std.random(max)
		var sum = 0
		for( var i=0; i<STATS.length; i++ ){
			sum += STATS[i]
			if(sum>rand)return i;
		}
		return null;
	
	};
	
	function kill(){
		Cs.game.bonusList.remove(this)
		super.kill();
	}

//{
}