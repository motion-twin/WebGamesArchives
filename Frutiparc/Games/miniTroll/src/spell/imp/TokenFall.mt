class spell.imp.TokenFall extends spell.Imp{//}

	var step:int;
	
	var max:int;
	var timer:float;
	var pList:Array<{>sp.Part, tx:float }>
	var cList:Array<int>
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
			
				break;
			case 1:
				max = Math.round( Math.min( Cs.game.xMax, (imp.level+1)*(1+Math.random()) ) )
				downcast(caster.body.body.epaule).col.gotoAndStop("2");
				timer = 20
				break;
			case 2:
				downcast(caster.body.body.epaule).col.gotoAndStop("1");
				
				//*
				cList = new Array();
				for( var i=0; i<max; i++ ){
					cList[i] = Cs.game.getColor();
				}
			
				pList = new Array();
				for( var i=0; i<max; i++ ){
					var p = downcast( Cs.game.newPart("partBallColor",null) )
					p.tx = Math.random()*Cs.game.width
					p.x = caster.x ;
					p.y = caster.y - 10 ;
					p.vitx = 4*(Math.random()*2-1);
					p.vity = -(1+Math.random()*2)
					var mc = downcast(p.skin).col
					Mc.setColor( mc, Cs.colorList[cList[i]] );
					Mc.modColor( mc, 1, 220 )
					pList.push(p)
					p.init();
				}
				//*/
				caster.vity += 4
				
				break;
		}
	}
	
	function activeUpdate(){
		switch(step){
			case 0:
				centerCaster();
				caster.toward( caster.trg, 0.1 );
				
				if( isCasterReady(20) ){
					initStep(1);
				};
			
				
				break;
			case 1 :
				
				for( var i=0; i<max; i++ ){
					var p = Cs.game.newPart("partLightBallFlip",null)
					var a = Math.random()*6.28
					var r = Math.random()*8
					p.x = caster.x + Math.cos(a)*r
					p.y = caster.y-10 + Math.sin(a)*r
					p.timer = 6+Math.random()*10
					p.fadeTypeList = [2]
					p.scale = 50+Math.random()*20
					p.fadeColor = Std.random( 0xFFFFFF ) //Cs.getHexaColot( 150+Math.random() )
					p.init();
					
					
				}
				
				
				timer -= Timer.tmod;
				if( timer < 0 )initStep(2);
				
				break;
				
			case 2:
				for( var i=0; i<pList.length; i++ ){
					var p = pList[i]
					var trg = { x:p.tx, y:-30}
					p.towardSpeed( trg, 0.1, 0.4 )
					
					if( p.x < 0 || p.x > Cs.game.width ){
						p.x = Cs.mm(0,p.x,Cs.game.width)
						p.vitx *= -0.8
					}					
					if(p.y<-20){
						pList.splice(i--,1);
						p.kill();
					}
					

					
				}
				
				if(pList.length==0){
					var xList = new Array();
					for( var i=0; i<Cs.game.xMax; i++ )xList.push(i);
					xList = Std.cast(Tools.shuffle)( xList );
					for( var i=0; i<cList.length; i++ ){
						/*
						var p = pList[i]
						
						var trg = { x:p.tx, y:-30};
						p.towardSpeed( trg, 0.1, 0.4 );
						if(p.y<-20){
							pList.splice(i--,1);
							p.kill();
						}
						*/
						
						var x = xList.pop()
						var y = 0
						while( !Cs.game.isFree(x,y) && y<20){
							y++
						}
						if( y < 3 ){
							var t:sp.el.Token = downcast( Cs.game.genElement( 0, x, y, 1 ) )
							t.setType(cList[i])
						}
						
					}
					
					finishAll();
				}
				
				break;
			
		}
	}
	

	
	function getName(){
		return "éboulement "
	}
	
	
//{	
}