class game.CrossLazer extends Game{//}
	
	// CONSTANTES
	static var ALPHA = 70;
	
	
	// VARIABLES
	var flTest:bool;
	
	var decal:float;
	var timer:float;
	var mdy:float;
	var blackPrc:float;

	var lineList:Array<{>MovieClip,vitr:float}>
	
	var lazerList:Array<{>MovieClip,t:float}>;
	var bpList:Array<{>sp.phys.Part,cs:float,z:float}>;
	
	// MOVIECLIPS
	var hori:{>MovieClip,field:TextField}
	var verti:{>MovieClip,field:TextField}
	var mire:MovieClip
	var bad:MovieClip
	
	var bg:MovieClip;
	
	function new(){
		
		super();
	}

	function init(){
		gameTime = 200
		super.init();
		
		flTest = false;
		mdy = 0
		decal = 0
		attachElements();
		
	};
	
	function attachElements(){
		var m = 50
		bad = dm.attach("mcCrossBad",Game.DP_SPRITE2)
		bad._x = m + Math.random()*(Cs.mcw-2*m)
		bad._y = m + Math.random()*(Cs.mch-2*m)
		bad._xscale = 80-dif*0.5
		bad._yscale = bad._xscale
		
		hori = downcast(dm.attach("mcCrossHoriLine",Game.DP_SPRITE))
		hori._alpha = ALPHA
		
		
	}
	
	function update(){
		moveMonster();
		switch(step){
			case 1: 
				updateDecal();
				
				hori._y = (Math.cos(decal/100)+1)*Cs.mch*0.5
				hori.field.text = "y:"+getStringNum(hori._y)

				break;
			case 2:
				updateDecal();
				verti._x = (Math.cos(decal/100)+1)*Cs.mcw*0.5
				verti.field.text = "x:"+getStringNum(verti._x)
				
				mire._x = verti._x
				mire._y = hori._y

				
				break;
			case 3:
				
				for( var i=0; i<lazerList.length; i++ ){
					
					var mc = lazerList[i]
					mc.t-=Timer.tmod
					if(mc.t<0){
						
						mc._xscale *= 0.8
						mc._yscale = mc._xscale
						if( mc._xscale < 2 && !flTest ){
							hit();
						}
					}
				}
				
				if(timer!=null){
					timer -= Timer.tmod
					if( timer < 0 ){
						setWin(true)
						timer = null
					}
				}
				
				
				for( var i=0; i<bpList.length; i++ ){
					var p = bpList[i]
					p.z *= p.cs
					p.skin._xscale = p.scale*p.z;
					p.skin._yscale = p.scale*p.z;
					var prc = Cs.mm( 0, 100-Math.pow(p.z,1)*100, 100 )
					
					Mc.setPercentColor(p.skin,prc,0x333399)
					
				}
				
				// LINE
				for( var i=0; i<lineList.length; i++ ){
					var mc = lineList[i]
					mc._rotation += mc.vitr*Timer.tmod;
					mc._yscale *= 0.75
					if( mc._yscale < 5 ){
						mc.removeMovieClip();
						lineList.splice(i--,1)
					}
				}
				
				// BLACK
				if(blackPrc!=null){
					Mc.setPercentColor(bg,blackPrc,0x000000)
					blackPrc *= 0.5
				}
				
				
		}
		//
		super.update();
	}
	
	function moveMonster(){
		mdy = (mdy+20)%628
		bad._y += Math.cos(mdy/100)*(bad._xscale/100)
		
		bad._xscale *= 1.003
		bad._yscale = bad._xscale
	}
	
	function blastMonster(){
		
		// LINE
		lineList = new Array();

		for( var i=0; i<10; i++ ){
			var mc = downcast( dm.attach("mcCrossRay",Game.DP_SPRITE2) )
			mc._x = bad._x
			mc._y = bad._y
			mc._rotation = Math.random()*360
			mc._yscale = 80+Math.random()*300
			mc.vitr = (Math.random()*2-1)*1.5
			lineList.push(mc)
		}

		// PART
		bpList = new Array();
		var max = 28
		for( var i=0; i<max; i++ ){
			var p = downcast( newPart("mcCrossBadPart") )
			p.x = bad._x
			p.y = bad._y
			p.z = 1
			p.scale = bad._xscale * ( 1 + (Math.random()*2-1)*0.2 )
			
			
			var a = Math.random()*6.28
			var sp  = 1+Math.random()*4

			p.vitx = Math.cos(a)*sp
			p.vity = Math.sin(a)*sp
			//p.vitr = (Math.random()*2-1)*8
					
			p.cs = 1 + ((i/max)*2-1)*0.05
			p.weight = 0
			
			p.init();
			p.skin._rotation = Math.random()*500
			downcast(p.skin).p.gotoAndPlay(string(Std.random(2)+1))
			
			bpList.push(p)
		}
		
		// ONDE
		var onde = dm.attach("mcCrossOnde",Game.DP_SPRITE2)
		onde._x = bad._x
		onde._y = bad._y
		

		
		// DESTROY
		bad.gotoAndPlay("death")
		blackPrc = 100
		
		//
		hori.removeMovieClip();
		verti.removeMovieClip();
		mire.removeMovieClip();
		
		
		
	}
	
	function updateDecal(){
		var sp = 8+dif*0.16
		decal = (decal+sp)%628
	}
	
	function click(){
		switch(step){
			case 1: 
				step = 2
				verti = downcast(dm.attach("mcCrossVertiLine",Game.DP_SPRITE))
				mire = dm.attach("mcCrossMire",Game.DP_SPRITE)
				verti._alpha = ALPHA
				mire._alpha = ALPHA
				break;
			case 2:
				step = 3
				lazerList = new Array();
				for( var i=0; i<12; i++){
					var x = verti._x+(Math.random()*2-1)*3
					var y = hori._y+(Math.random()*2-1)*3
					var rot = Math.random()*360
					for( var n=0; n<3; n++ ){
						var mc = downcast(dm.attach("mcCrossLazer",Game.DP_SPRITE2))
						mc._x = x
						mc._y = y
						mc._rotation = rot
						mc.t = n*6
						lazerList.push(mc)
					}
					//mc._xscale = mc._yscale = 100+Math.random()*200
					
				}
				flTimeProof = true;
				
				
				break;
			
			
		}
	}
	
	function hit(){
		flTest = true;
		if( Mc.shapeHitTest( bad, verti._x, hori._y ) ){
			blastMonster();	
			timer = 20
		}else{
			setWin(false)
		}
	}
	
	
	function getStringNum(n){
		
		var base = string(int(n))
		while(base.length<3)base = "0"+base
		return base+"."+Std.random(10)
		
	}
	
	
	
	
	

//{	
}










