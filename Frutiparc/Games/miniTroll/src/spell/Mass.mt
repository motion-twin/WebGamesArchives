class spell.Mass extends spell.Base{//}

	var flUsed:bool;
	var step:int;
	var timer:float;
	var burnTimer:float;
	var m:sp.Part;
	var msList:Array<sp.Part>
	
	
	function new(){
		super();
		cost = 6;
	}
	
	function cast(){
		super.cast();
		flUsed = false;
		initStep(0);
	}

	function update(){
		super.update();
		if( Cs.game.step == 2 ){
			flUsed = true;
			var p = Cs.game.piece
			
				for( var i=0; i<p.list.length; i++ ){
					var o = p.list[i]
					var px = o.x+p.x;
					var py = o.y+p.y;
					
					for( var n=0; n<2; n++ ){
						var part = Cs.game.newPart("partFlameBall",null)
						var a = Math.random()*6.28
						part.x = Cs.game.getX(px+p.cx+0.5+Math.cos(a)*0.5)
						part.y = Cs.game.getY(py+p.cy+0.5+Math.sin(a)*0.5) 
						part.scale = 80+Math.random()*50
						part.weight = -0.1+(Math.random()*0.2)
						part.flGrav = true;
						part.timer = 10+Math.random()*10
						part.init();
						
					}
					if( p.flGround && !Cs.game.isFree(px,py+1) ){
						var e = Cs.game.grid[px][py+1]
						Cs.game.removeFromGrid(e)
						//e.fxCrystal();
						e.explode();
						e.kill();
					}
				}				

		}else{
			if( flUsed ){
				dispel();
			}
		}
	
		
		
	}
	
	function initStep(n){
		step = n 
		switch(step){
			case 0:
				m = Cs.game.newPart("partMeteore",null)
				m.x = caster.x
				m.y = caster.y
				m.scale = 0;
				m.init();
			
				burnTimer = 100;
				msList = new Array();
			
				break;
			case 1:
				for(var i=0; i<msList.length; i++ ){
					var p = msList[i]
					p.timer = 10
					p.weight = 0.1+Math.random()*0.3
					p.flGrav = true
				}
			
				caster.vity += 5
				timer = 6
				break;
			case 2:
				caster.trg = {
					x:m.x,
					y:-10
				}
				caster.flForceWay = true;				
				
				break;
		}
	}

	function activeUpdate(){
		
		burnMeteore();
		
		switch(step){
			case 0:
				slowCaster(0.5);
				//m.scale += Timer.tmod
				m.skin._xscale  = m.scale
				m.skin._yscale  = m.scale
				m.skin._rotation += 2*Timer.tmod;
				m.towardSpeed(caster,0.001,1)
			
				var ms = Cs.game.newPart("partMeteoreStone",null)
				var a = Math.random()*6.28
				var d = 36
				ms.x = m.x + Math.cos(a)*36
				ms.y = m.y + Math.sin(a)*36
				ms.init();
				msList.push(ms)
				
				//Cs.game.dm.over(m.skin)
			
				for( var i=0; i<msList.length; i++ ){
					var p = msList[i]
					var dist = p.getDist(m)
					if( dist < 5 ){
						p.kill();
						msList.splice(i--,1)
						m.scale += 1.5
					}else{
						var c = 1-(dist/36)
						//var coef = Math.min( Math.max( 0.001, c ), 0.4 )
						p.toward(m,0.1)
						p.scale = Math.min( Math.max( 0, c ), 1 )*100
						p.skin._xscale = p.scale
						p.skin._yscale = p.scale
					}
				}		
			
			
			
				if( m.scale > 100 )initStep(1);
			
				break;
			case 1:
				timer -= Timer.tmod;
				if( timer < 0 ){
					initStep(2)
				}
				m.towardSpeed(caster,0.1,1)
				break;
			case 2 :
				m.vity -= 2*Timer.tmod;
				caster.towardSpeed(caster.trg,0.2,2)
				if( m.y < -100 ){
					caster.flForceWay = false;
					m.kill();
					endActive();
				}
				
				break;
		}	

		
	}
	
	function burnMeteore(){
		
		burnTimer -= Timer.tmod*m.scale

		while( burnTimer < 0 ){
			var part = Cs.game.newPart("partFlameBall",null)
			var a = Math.random()*6.28
			var d = Math.random()*(m.scale/100)*18
			
			part.x = m.x + Math.cos(a)*d
			part.y = m.y + Math.sin(a)*d
			part.scale = 80+Math.random()*50
			part.weight = -0.1+(Math.random()*0.2)
			part.flGrav = true;
			part.timer = 10+Math.random()*10
			part.init();
			
			burnTimer += 80
		}

	}

	//
	function getRelevance(){
		var best0 = -1
		var best1 = -1
		for( var x=0; x<Cs.game.xMax; x++ ){
			var n = 0;
			var r0 = 0
			var r1 = 0			
			for( var dx=0; dx<3; dx++ ){
				var px = x+dx

				for( var y=0; y<Cs.game.yMax; y++ ){
					var e = Cs.game.grid[px][y]
					if( e != null )n += getRemoveValue(e)
				}
				if(dx==1)r0 = n
				if(dx==2)r1 = n
			}
			best0 = Math.max( r0, best0 ) 
			best1 = Math.max( r1, best1 ) 
			if( Std.isNaN(best0+best1) ) Manager.log("Error! ghrzgrjzgkrgjb");
		}
		
		
		//Manager.log("Meteore score :"+((best0+best1)*0.5) )
		
		return (best0+best1)*0.5
	}
	
	function getName(){
		return "Meteore "
	}

	function getDesc(){
		return "Transforme la prochaine pièce en un météore ardent destructeur."
	}	
	
//{
}
	
	
	
	
	
	