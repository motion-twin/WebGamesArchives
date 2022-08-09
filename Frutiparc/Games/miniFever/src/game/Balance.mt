class game.Balance extends Game{//}
	
	// CONSTANTES
	var plateWidth:int;
	var barRay:int;
	
	// VARIABLES
	var left:int;
	var right:int;
	var rot:float;
	var vitr:float;
	var pList:Array<Array<MovieClip>>
	var pInfoList:Array<int>
	
	
	// MOVIECLIPS
	var bar:MovieClip;
	var p1:MovieClip;
	var p2:MovieClip;

	
	function new(){
		super();
	}

	function init(){
		gameTime = 500-dif*3;
		super.init();
		pInfoList = [2,5,20]
		
		Std.cast(p2).d = 0
		plateWidth = 60
		barRay = 80
		
		left = 12+Std.random(60)
		rot = -20
		vitr = 0;
		
		
		attachElements();

	};
	
	function attachElements(){

		// POIDS
		pList = new Array();
		var max = pInfoList.length
		var ec = Cs.mcw/(max+1)
		for( var i=0; i<max; i++){
			pList[i] = new Array();
			var mc = newSprite("mcPoid")
			mc.x = ec*(i+1)
			mc.y = Cs.mch - 10
			mc.skin._xscale = Math.sqrt(pInfoList[i])*20;
			mc.skin._yscale = mc.skin._xscale;
			mc.init()
			initButPoid(mc,i)
		}
		
		// RABBIT
		var mc = Std.attachMC(Std.cast(p1).empty,"mcBalanceRabbit",1)
		var scale = 30+left;
		mc._y = 93;
		mc._xscale = scale;
		mc._yscale = scale;
		
		
	}
	
	function initButPoid(mc,n){
		var me = this;
		mc.skin.onPress = fun(){
			me.addPoid(n)
		}
	}
	
	function initPlatePoid(mc,n){
		var me = this;
		mc.onPress = fun(){
			me.removePoid(n)
		}
	}	
	
	function addPoid(n){
		if( pList[n].length >  4 || flWin )return;
		var mc = Std.cast(p2)
		mc.d++
		var p = Std.attachMC( mc.plate, "mcPoid", Math.floor(mc.d+Math.pow(10,pList.length-n)) )
		p._xscale = Math.sqrt(pInfoList[n])*12
		p._yscale = p._xscale
		initPlatePoid(p,n)
		pList[n].push(p)
		updatePlate();
	}
	
	function removePoid(n){
		pList[n].pop().removeMovieClip();
		updatePlate();
		
	}
	
	function updatePlate(){
		right = 0
		for( var n=0; n<pList.length; n++ ){
			var a = pList[n]
			var w = a[0]._width//pInfoList[n]
			var wt = (a.length-1) * w
			var e = (plateWidth-(wt+w))/(a.length-1);

			for( var i=0; i<a.length; i++){
				var mc  = a[i]
				mc._x =   w*0.5 + (w+e)*i - plateWidth*0.5 // w*0.5 + (w+e)*i -plateWidth*0.5
			}
			right += a.length * pInfoList[n]
		}

		var lim = 20
		rot = Math.min(Math.max(-lim,(right-left)*6),lim)

		
	}

	function update(){
		switch(step){
			case 1: 
				var dr = rot - bar._rotation
				var lim = 0.5
				vitr += Math.min(Math.max(-lim,dr*0.1),lim)
				vitr *= Math.pow(0.92,Timer.tmod)
				bar._rotation += vitr*Timer.tmod
			
				var a = bar._rotation*0.0174
				var ca= Math.cos(a)
				var sa= Math.sin(a)

				p1._x = bar._x - ca*barRay;
				p1._y = bar._y - sa*barRay;
			
				p2._x = bar._x + ca*barRay;
				p2._y = bar._y + sa*barRay;
						
				if(right == left && Math.abs(vitr)<0.6 && Math.abs(bar._rotation)<0.6){
					setWin(true);
				}
				break;
		}
		//
		super.update();
	}
	

//{	
}


/* TODO

- ajouter une bestiole dans le plateau de gauche
- contour aux poids plus epais.



*/

















