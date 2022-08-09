class sp.el.Item extends sp.Element{//}

	

	var type:int;
	var vity:float;
	
	var it:It;
	var item:MovieClip
	
	var dm:DepthManager;
	
	function new(){
		et = 1;
		link = "elItem";
		flFront = true;
		super();
	}

	function init(){

		vity = 0
		super.init();
		dm = new DepthManager(skin)
	}

	function setType(n){
		type = n;
		
		
		
		it = Item.newIt(n)
		item = it.getPic(dm,1)//downcast(Std.attachMC(skin,"item",1))

		//item.setType(type)
		item._x = 50
		item._y = 50
		
		//skin.gotoAndStop(string(type+1))
	}

	function update(){
		super.update();
		

	}
	
	function initActiveStep(){
		if( Cs.game.isFree(px,py-1) ){
			Cs.aventure.mf.fi.reactItem(type)
			addToList(Cs.game.activeElementList)
		}	
	}
	
	function activeUpdate(){
		
		// 
		vity -= 0.1*Timer.tmod;;
		y += vity*Timer.tmod;
		update();
		
		// FX
		var depth = Game.DP_PART3
		if( Math.random() > 0.7 ){
			depth = Game.DP_PART2;
		}

		var sp = Cs.game.newPart("partStar",depth);
		var a = Math.random()*6.28
		var d = Math.random()*12
		var dc = Cs.game.ts*0.5
		sp.x = x+dc+Math.cos(a)*d
		sp.y = y+dc+Math.sin(a)*d
		sp.scale= 20+Math.random()*90
		sp.weight = 0.1
		sp.flGrav = true
		sp.timer = 5+Math.random()*15
		sp.init();
		Mc.setColor(sp.skin, Std.random(0xFFFFFF) )
		Mc.modColor(sp.skin, 1, 180 )

		// DEATH
		if( y <- 20 ){
			Cs.base.grab(type);
			kill();
		}
	}
	


	
//{	
}