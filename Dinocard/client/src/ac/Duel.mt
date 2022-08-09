class ac.Duel extends Action{//}

	static var SHAKE = 8
	
	var data:DataDuel;
	
	var att:Card;
	var def:{x:float,y:float};
	
	var bp:Array<Array<float>>
	
	var coef:float;
	var step:int;
	var attDist:float;

	function new(d){
		super(d)
		data = downcast(d)
		
	}
	
	function init(){
		//Log.trace("attack!")
		super.init();
		
		
		att = Card.getCard(data.$aggro)
		
		
		att.front();
		//kill();
		

	
		attDist = 40
		if(data.$def==null){
			attDist = 120;
			def = upcast(att.owner.getOpponent().avatar);
		}else{
			def = Card.getCard(data.$def)
		}
		
		bp = [ [att.x,att.y], [def.x,def.y] ]
		coef =0;
		step = 0
		
		
	}
	
	function update(){
		super.update();
		//Log.trace("Duel("+step+")")
		switch(step){
			case 0:
				coef = Math.min(coef+Cs.game.speed*4,1);
				var ty = bp[0][1] - att.owner.side*attDist*coef
				att.moveTo(att.x,ty)	
				if(coef==1){
					setPlayList(data.$actions)
					step++;
				}
				break;
			case 1:
				coef = Math.max(coef-Cs.game.speed*2,0);
				var ty = bp[0][1] - att.owner.side*attDist*coef
				att.moveTo(att.x,ty)

				var dx = bp[1][0] + (Math.random()*2-1)*SHAKE*coef
				var dy = bp[1][1] + (Math.random()*2-1)*SHAKE*coef
				downcast(def).moveTo(dx,dy)
			
				if(coef==0 && playList.length==0){
					Cs.game.togglePause();
					kill();
				}
				break
			case 2:
				
				break;
		}
		
	}



//{
}