class spell.StarEater extends spell.Base{//}

	var sList:Array<sp.el.Token>;
	var pList:Array<sp.Part>;
	var step:int;
	
	var bs:sp.Part;
	
	function new(){
		super();
		cost = 2;
	}
	
	function cast(){
		super.cast();
		initStep(0);
	}

	function update(){
		super.update();
	
		
	}
	
	function initStep(n){
		step = n 
		switch(step){
			case 0:
				/*
				caster.trg = {
					x:Cs.game.width*0.5 ,
					y:Cs.game.height*0.5
				}
				caster.flForceWay = true;
				*/
				centerCaster();
				break;
			case 1:
				bs = Cs.game.newPart( "partMiniStar", Game.DP_PART2 );
				bs.x = caster.x
				bs.y = caster.y
				bs.scale = 1000
				bs.alpha = 0
				bs.init();
				
				break;
			case 2:
				pList = new Array();
				sList = getStarList()
				for( var i=0; i<sList.length; i++){
					var e = sList[i]
					e.setSpecial(0)
					var p = Cs.game.newPart( "partMiniStar", Game.DP_PART2 );
					p.x = Cs.game.getX(e.px+0.5);
					p.y = Cs.game.getY(e.py+0.5)
					p.addToList(pList)
					var a = caster.getAng(p)
					var dist = caster.getAng(p)
					var speed = (1+(dist/6))
					p.vitx = Math.cos(a)*speed
					p.vity = Math.sin(a)*speed
					p.timer = 20+Math.random()*10
					p.init()
				}			
				
				break;
		}
	}

	function activeUpdate(){

		switch(step){
			case 0:
				//slowCaster(0.5);
				caster.starFall(1.5)
				caster.toward(caster.trg,0.1)
				if( caster.getDist(caster.trg) < 10 ){
					initStep(1);
				}			
				break;
			case 1:
				bs.scale = bs.scale*Math.pow(0.7,Timer.tmod)
				bs.alpha = Math.min(bs.alpha+10*Timer.tmod,100)
				bs.skin._xscale = bs.scale
				bs.skin._yscale = bs.scale
				bs.skin._alpha = bs.alpha
				if( bs.scale < 5 ){
					bs.kill()
					initStep(2)
				}
		
				break;
			case 2 :
				if( pList.length == 0 ){
					finishAll();
				}
				break;
		}	

		
	}
	
	function getStarList(){
	
		var list = new Array();
		for( var i=0; i<Cs.game.eList.length; i++ ){
			var e = Cs.game.eList[i]
			if( e.et == 0 ){
				var te:sp.el.Token = downcast(e)
				if( te.special == 1 ){
					list.push(te);
				}
			}
		}
		
		return list;
		
	}	

	//
	function getRelevance(){					// *1.0 sinon int
		var n  = getStarList().length
		return Math.pow(n,1.3) * 0.25
	}
	
	function getName(){
		return "Gobeur de perles "
	}

	function getDesc(){
		return "Détruit toutes les perles présentes dans les billes colorées."
	}
	
//{
}
	
	
	
	
	