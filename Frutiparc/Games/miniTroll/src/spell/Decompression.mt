class spell.Decompression extends spell.Base{//}

	var aList:Array<sp.el.Token>;
	var pList:Array<sp.Part>;
	var cList:Array<sp.Part>;
	var step:int;
	
	var timer:float;

	
	function new(){
		super();
		cost = 4;
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
				centerCaster();
				break;
			case 1:
				aList = getArmorList()
				cList = new Array();
				for( var i=0; i<aList.length; i++){
					var p = Cs.game.newPart( "partMiniCircle", Game.DP_PART2 );
					var a = Math.random()*6.28
					var dist = 10+Math.random()*10
					p.x = caster.x + Math.cos(a)*dist
					p.y = caster.y + Math.sin(a)*dist
					p.alpha = 0
					p.init()
					p.addToList(cList)
				}
				timer = 30;
				
				break;
			case 2:
				for( var i=0; i<cList.length; i++){
					var p = cList[i]
					p.friction = 0.8
					p.timer = 50
				}
				break;
			case 3:
				pList = new Array();
				
				for( var i=0; i<aList.length; i++){
					
					var e = aList[i]
					e.setSpecial(0)
					
					var p = Cs.game.newPart( "partMiniCircle", Game.DP_PART2 );
					p.x = Cs.game.getX(e.px+0.5);
					p.y = Cs.game.getY(e.py+0.5)
					p.addToList(pList)
					p.timer = 8+Math.random()*3
					p.scale = 100
					p.fadeTypeList = [1]
					//p.alpha = 0;
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
				//Log.print(cList.length)
				for( var i=0; i<cList.length; i++){
					var p = cList[i]
					
					p.alpha = Math.min(p.alpha+20*Timer.tmod,50)
					p.skin._alpha = p.alpha;
					p.towardSpeed( caster, 0.1, 0.5 )
					
				}
				timer -= Timer.tmod
				if( timer < 0 ){
					initStep(2)
				}
		
				break;
			case 2 :
				for( var i=0; i<cList.length; i++){
					var p = cList[i]
					var e = aList[i]
					var trg = {
						x:Cs.game.getX(e.px+0.5)
						y:Cs.game.getY(e.py+0.5)
					}
					p.towardSpeed( trg, 0.1, 2 )
				}
				if( cList.length == 0 ){
					initStep(3)
				}				
				break;
			case 3 :
				for( var i=0; i<pList.length; i++){
					var p = pList[i];
					p.scale *= 1.05;
					p.skin._xscale =  p.scale
					p.skin._yscale =  p.scale
				}
				if( pList.length == 0 ){
					finishAll();
				}
				break;
		}	

		
	}
	
	function getArmorList(){
	
		var list = new Array();
		for( var i=0; i<Cs.game.eList.length; i++ ){
			var e = Cs.game.eList[i]
			if( e.et == 0 ){
				var te:sp.el.Token = downcast(e)
				if( te.special == 2 ){
					list.push(te);
				}
			}
		}
		
		return list;
		
	}	

	//
	function getRelevance(){				// *1.0 sinon int
		var n = getArmorList().length
		return Math.pow(n,1.3) * 0.4

	}
	
	function getName(){
		return "Depressurisation "
	}

	function getDesc(){
		return "Retire l'armure de toutes les billes colorées du niveau."
	}
	
//{
}
	
	
	
	
	