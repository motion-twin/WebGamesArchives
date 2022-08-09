class game.Patate extends Game{//}
	
	// CONSTANTES
	var elementMax:int;
	var typeMax:int;
	var upMargin:int;
	
	// VARIABLES
	
	var desc:Array<int>
	var decalList:Array<int>
	var elementList:Array<{t:int,mc:Sprite}>
	var drag:{e:int,t:int,mc:Sprite}
	
	// MOVIECLIPS
	var skin:Sprite;
	var model:Sprite;
	

	function new(){
		super();
	}

	function init(){
		gameTime = 320-dif*2;
		super.init();
		upMargin = 108;
		elementMax = 3;
		typeMax = 4;
		
		elementList = new Array();
		decalList = [-12,-31,26]
		desc = new Array();
		
		for( var i=0; i<elementMax; i++ ){
			desc.push(Std.random(typeMax))
		}
		
		attachElements();

	};
	
	function attachElements(){
		
		// SKIN
		skin = newSprite("mcPatateSkin")
		skin.x = Cs.mcw*0.25
		skin.y = upMargin*0.5
		skin.init();
		
		// MODEL
		model = newSprite("mcPatateSkin")
		model.x = Cs.mcw*0.75
		model.y = upMargin*0.5
		model.init();		
		for( var x=0; x<elementMax; x++ ){
			var mc = downcast(newSprite("mcPatateElement"))
			mc.x = model.x;
			mc.tx = model.x;
			mc.y = model.y;
			mc.ty = model.y;
			
			mc.init();
			mc.skin.gotoAndStop(string(x+1))
			Std.cast(mc.skin).e.gotoAndStop(string(desc[x]+1))			
		}
		
		
		// ELEMENTS
		var list = new Array();
		var mx = 50
		var my = 18
		var ex = (Cs.mcw-2*mx)/(elementMax-1) 
		var ey = (Cs.mch-(upMargin+2*my))/(typeMax-1) 
		for( var x=0; x<elementMax; x++ ){
			for( var y=0; y<typeMax; y++ ){
				var mc = downcast(newSprite("mcPatateElement"))
				mc.x = mx + ex*x
				mc.tx = mc.x
				mc.y = my + upMargin + ey*y
				mc.ty = mc.y
				mc.init();
				//initElement(mc,x,y)
				list.push(mc)
				
				

			}		
		}
		
		for( var x=0; x<elementMax; x++ ){
			for( var y=0; y<typeMax; y++ ){
				var index = Std.random(list.length)
				var mc = list[index]
				list.splice( index, 1 )
				mc.ty +=decalList[x]
				mc.y = mc.ty
				initElement(mc,x,y)
			}
		}	
		
		
		
	}
	
	function initElement(mc:Sprite,e:int,t:int){
		
		mc.skin.gotoAndStop(string(e+1))
		Std.cast(mc.skin).e.gotoAndStop(string(t+1))

		
		var me = this
		var x = mc.x
		var y = mc.y
		mc.skin.onPress = fun(){
			me.sDrag(mc,e,t);
			
		}
		mc.skin.onRelease = fun(){
			me.drop(x,y);
			
		}
		mc.skin.onReleaseOutside = mc.skin.onRelease
	}	
	
	function sDrag(mc,e,t){
		drag = {e:e,t:t,mc:mc}
		dm.over(mc.skin)
	}
	
	function drop(x,y){
		var dist = skin.getDist( drag.mc ) 
		var mc = downcast(drag.mc)
		if( dist < 60 ){
			if( elementList[drag.e] != null ) elementList[drag.e].mc.skin.onPress();
			
			mc.tx = skin.x
			mc.ty = skin.y
			mc.skin.onPress = null
			mc.skin.onRelease = null
			mc.skin.onReleaseOutside = null
			elementList[drag.e] = { t:drag.t, mc:Std.cast(mc)}
			
			var d = drag
			var me = this
			//var dy = decalList[d.e]
			mc.skin.onPress = fun(){
				mc.tx = x
				mc.ty = y //+ dy
				me.initElement(mc,d.e,d.t)
			}
			
						
			checkWin();
			
		}else{
			mc.tx = x
			mc.ty = y
		}
		drag = null
	}
	
	function update(){
		
		switch(step){
			case 1: 

				
				var list = glSprite()
				for( var i=0; i<list.length; i++ ){
					var mc = downcast(list[i]);
					if(mc.tx !=null){
						var dx = mc.tx - mc.x;
						var dy = mc.ty - mc.y;
						mc.x += dx*0.5*Timer.tmod;
						mc.y += dy*0.5*Timer.tmod;
					}
				}

				/*
				var dx = this._xmouse - drag.mc.x
				var dy = this._ymouse - (drag.mc.y-decalList[drag.e])
				drag.mc.x += dx*0.5*Timer.tmod
				drag.mc.y += dy*0.5*Timer.tmod
				*/
				var mc = downcast(drag.mc)
				mc.tx = this._xmouse
				mc.ty = this._ymouse+decalList[drag.e]
				
			
				break;
		}
		//
		super.update();
	}

	function checkWin(){
		for( var i=0; i<elementMax; i++ ){
			var info = elementList[i]
			if( info == null || info.t != desc[i] )return;
			
		}
		setWin( true )
	}
	
	
	
	
	

//{	
}









