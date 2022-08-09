class spell.imp.Wall extends spell.Imp{//}

	var step:int;
	var ym:int;
	var x:int;
	var timer:float;
	var pList:Array<{>sp.Part, trg:{x:float,y:float}, t:{x:int,y:int} }>

	//var pList:Array<{ p:sp.Part, color:int, tx:float }>
	
	
	function new(){
		super();
	}
	
	function cast(){
		super.cast();
		initStep(0)
	}
	
	function initStep(n){
		step = n 
		switch(step){
			case 0:
				centerCaster();
				break;
			case 1:
				pList = new Array();
				ym = int( Math.min( imp.level+1, Cs.game.getHeightMax()-1 ) );
				x = 0;
				timer = 0;
				break;
			case 2:

				
				break;
		}
	}
	
	function activeUpdate(){
		switch(step){
			case 0:
				
				caster.toward( caster.trg, 0.1 );
				
				if( isCasterReady(20) ){
					initStep(1);
				};
				break;
			case 1 :
				
				
				for( var i=0; i<pList.length; i++ ){
					var p = pList[i]
					p.towardSpeed( p.trg, 0.2, 0.4 )
					var dist = p.getDist(p.trg)
					p.toward( p.trg, Cs.mm( 0, 3/dist, 0.5) )
					if( dist < 5 ){
						Cs.game.genElement( Cs.E_STONE, p.t.x, p.t.y, 2 )
						p.kill();
						pList.splice(i--,1)
					}
				}
				if( x < Cs.game.xMax ){
					timer -= Timer.tmod
					if( timer <= 0){
						timer = 8
						
						for( var y=2; y<ym; y++ ){
							
							//var e = Cs.game.genElement( Cs.E_STONE, x, y, 2 )
							var p = downcast( Cs.game.newPart("partDust",null) )
							p.x = caster.x;
							p.y = caster.y;
							var a = Math.random()*6.28;
							var po = 1+Math.random()*8;
							p.vitx = Math.cos(a)*po;
							p.vity = Math.sin(a)*po;
							p.init();
							p.trg = {
								x:Cs.game.getX(x),
								y:Cs.game.getY(y)
							}
							p.t = {x:x,y:y}
							p.scale = 250
							p.init()
							pList.push(p);

						}
						x++
					}
				}else{
					if(pList.length==0)finishAll();
				}
				break;
				
			case 2:
							
				break;
			
		}
	}
		
	function getName(){
		return "Quintal "
	}
	
	
//{	
}