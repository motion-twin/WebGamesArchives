class game.Maximum extends Game{//}
	
	// CONSTANTES

	
	// VARIABLES
	var g0:int;
	var g1:int;
	var timer:float;
	var colDecal:float;
	var rotDecal:float;
	var mList:Array<{>sp.Phys,decal:float,wp:{x:float,y:float,r:float},vitd:float}>
	
	
	// MOVIECLIPS
	var panel:Sprite;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 300-dif*2;
		super.init();
		
		
		timer = 30;
		
		attachElements();
		
	};
	
	function attachElements(){

		var total = 7+ Math.floor((dif*0.06))*2
		
		if(Std.random(2)==0){
			g0 = Math.floor(total*0.5)
			g1 = Math.ceil(total*0.5)
		}else{
			g1 = Math.floor(total*0.5)
			g0 = Math.ceil(total*0.5)
		}
		
		
		/*
		if(dif>50){
			var inc = Std.random(2)*2-1
			g0 += inc
			g1 -= inc
		}
		*/
		var list = [g0,g1]

		

		mList = new Array();
		for( var n=0; n<list.length; n++){
			for( var i=0; i<list[n]; i++){
				var sp = downcast(newPhys("mcMaxMonster"))
				sp.skin.gotoAndStop(string(n+1))
				downcast(sp.skin).m.stop();
				var pos = getRandomPos();
				sp.x = pos.x
				sp.y = pos.y 
				sp.vitd = (Math.random()*2-1)*30
				sp.wp = getRandomPos();
				sp.decal = 0;
				sp.flPhys = false;
				sp.skin._xscale = 75
				sp.skin._yscale = 75
				sp.init();
				mList.push(sp) // BUG MTYPE
			}
		}
		

		
		
	}
	
	function update(){
		super.update();
		moveMonsters();
		switch(step){
			case 1: 
				timer -= Timer.tmod;
				if(timer<0){
					step = 2;
					panel = newSprite("mcMaxPanel");
					panel.x = Cs.mcw*0.5
					panel.y = Cs.mch+80
					panel.init();
					panel.skin._xscale = 60
					panel.skin._yscale = 60
					
					var free = downcast(panel.skin)
					free.stop();
					free.m0.gotoAndStop("1"); 
					free.m1.gotoAndStop("2");
					
					var me = this;
					free.m0.onPress = fun(){
						me.select(0)
					}
					free.m1.onPress = fun(){
						me.select(1)
					}					
					
					colDecal = Math.random()*628
					rotDecal = Math.random()*628
				}
				break;
			case 2 :
				panel.toward({x:panel.x,y:Cs.mch-30},0.2,null)
				
				var free = downcast(panel.skin)
				var gros = free.m0;
				var petit = free.m1;
				var rot = 0;
				if(_xmouse>Cs.mcw*0.5){
					gros = free.m1;
					petit = free.m0;
					rot = 180;
				}
				var dif = 60 - gros._xscale
				gros._xscale += dif*0.3*Timer.tmod;
				gros._yscale = gros._xscale
				
				dif = 40 - petit._xscale
				petit._xscale += dif*0.3*Timer.tmod;
				petit._yscale = petit._xscale				
				
				dif = rot - free.sup._rotation
				while(dif>180)dif-=360;
				while(dif<-180)dif+=360;
				free.sup._rotation += dif*0.3*Timer.tmod;
				
				colDecal = (colDecal+30*Timer.tmod)%628
				rotDecal = (colDecal+10*Timer.tmod)%628
				
				gros._rotation = Math.cos(rotDecal/100)*10
				Mc.setPColor( gros, 0xFFFFFF, 30+Math.cos(colDecal/100)*30)
				
				petit._rotation *= 0.9
				Mc.setPColor( petit, 0xFFFFFF, 100)
				
				break;
			case 3:
				panel.toward({x:panel.x,y:Cs.mch+30},0.2,null)
				break;
					
		}
	}
	
	function moveMonsters(){
		for( var i=0; i<mList.length; i++ ){
			var sp = mList[i]
			if( Std.random(int(100/Timer.tmod)) == 0 ){
				sp.wp = getRandomPos();
			}
			sp.decal = (sp.decal+sp.vitd*Timer.tmod)
			var x = sp.wp.x + Math.cos(sp.decal/100)*sp.wp.r
			var y = sp.wp.y + Math.sin(sp.decal/100)*sp.wp.r
			
			sp.towardSpeed( {x:x,y:y}, 0.1, 0.3)
			sp.checkBounds( 0.5, 15, null )
			
			// RECAL
			for( var n=i+1; n<mList.length; n++ ){
				var sp2 = mList[n]
				var dist = sp.getDist(sp2)
				var ray = 10//20
				if( dist < ray*2 ){
					
					var d = ray-dist*0.5
					
					var a = sp.getAng(sp2)
					var ca = Math.cos(a)
					var sa = Math.sin(a)
					
					sp.x -= ca*d
					sp.y -= sa*d
					sp2.x += ca*d
					sp2.y += sa*d							
					
				}
			}
		}	
	}
	
	function getRandomPos(){
		var m = 50;
		var x = m+Math.random()*(Cs.mcw-2*m);
		var y = m+Math.random()*(Cs.mch*0.75-2*m);
		var r = 10+Math.random()*20
		return {x:x,y:y,r:r}
	}
	
	function select(n){
		setWin( (n==0) == (g0>g1) )
		var st = 0
		var end = g0
		if(n==1){
			st = g0
			end = mList.length;
		}
		for(var i=st; i<end; i++){
			var sp = mList[i]
			downcast(sp.skin).m.gotoAndPlay(flWin?"content":"triste");
		}
		step  = 3;					
		
	}
	
	
//{	
}

