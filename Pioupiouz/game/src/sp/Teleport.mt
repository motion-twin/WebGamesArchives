class sp.Teleport extends LevelElement{//}

	var pair:sp.Teleport;

	var flActive:bool;
	var bloup:int;
	
	var timer:float;
	
	
	function new(mc){
		mc = Cs.game.dm.attach("mcTeleport",Game.DP_ELEMENT)
		flActive = false;
		super(mc)
	}
	
	function update(){
		super.update();


		
		if(step==1){
			if(downcast(this).fl==null){
				//Log.trace("firstUpdate("+x+","+y+")")
				downcast(this).fl = true
			}
			if(flActive){
				var mx = int(x)
				var my = int(y)
				
				for( var i=0; i<Cs.game.pList.length; i++ ){
					var p = Cs.game.pList[i]
					if( p.step == Piou.WALK && p.px == mx && p.py == my ){
						
						var mc = Cs.game.dm.attach("mcPiouFader",Game.DP_PART)
						mc._x = p.px;
						mc._y = p.py;
						
						Std.attachMC(p.root,"mcPiouFader",10)
						
						p.px = int(pair.x)+p.sens
						p.py = int(pair.y)
						
						bloup = 5
						pair.bloup = 5
					}
				}
			}else{
				if(timer!=null && timer--<0)timer=null;
				if( pair!=null && pair.step==1 && timer==null && pair.timer == null){
					pair.activate();
					activate();
				}
			}
			
			
			if(bloup>0)bloup--;
			for( var i=0; i<bloup; i++ ){
				var p = Cs.game.newPart("partLightFlip")
				p.x = x+(Math.random()*2-1)*8
				p.y = y - (2+Math.random()*Piou.RAY*1.8)
				p.weight = - Math.random()*0.1
				p.setScale(50+Math.random()*70)
				p.timer = 10+Math.random()*10
			}
		}
		
		
	}
	
	function activate(){
		//Log.trace("acticate!")
		flActive = true;
		downcast(root).onde._visible = true;	
	}
	
	function onLand(){
		if(root._currentframe==1)root.play();
		
		vr=0
		root._rotation = 0;
		if( !Level.isFree(x,y) || Level.isFree(x,y+1) ){
			Log.trace("Teleport Position Error !!!")
		}
		//Log.trace("onLand("+x+","+y+") ("+vx+","+vy+","+weight+")")
		timer = 16
	}
	
	function onBlast(x,y){
		Log.trace("blaast!")
		super.onBlast(x,y)
	}
	

	
	
	
//{	
}