class game.Orbital extends Game{//}
	
	// CONSTANTES
	var tRay:int;
	var pRay:int;
	
	// VARIABLES
	var decal:float;
	var speed:float;
	var speedDecal:float;
	var launcher:Array<{mc:MovieClip,t:float,a:float}>
	var missile:Array<sp.Phys>
	
	var oTrg:{x:float,y:float}
	
	// MOVIECLIPS
	var planete:Sprite;
	var trg:Sprite;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 400;
		super.init();

		speed = 4+dif*0.1
		speedDecal = 0
		decal = Std.random(328)
		pRay = 50
		tRay = 108
		missile = new Array();
		attachElements();
	};
	
	function attachElements(){
		
		// PLANETE
		planete = newSprite("mcPlanete"); 
		planete.x = Cs.mcw*0.5
		planete.y = Cs.mch*0.5
		planete.skin._xscale = pRay*2
		planete.skin._yscale = planete.skin._xscale
		planete.init();
		
		// TARGET
		trg = newSprite("mcOrbitalTarget")
		trg.init();
		
		// LAUNCHER
		launcher = new Array();
		var max = 6-(dif*0.05)
		for( var i=0; i<max; i++ ){
			var mc = newSprite("mcMissileLauncher")
			mc.x = planete.x
			mc.y = planete.y
			
			var a = 0;
			while(true){
				a = Std.random(628)/100
				var flag = true
				for( var n=0; n<launcher.length; n++ ){
					if( Math.abs(launcher[n].a - a) < 0.2 ){
						flag = false;
					}
				}
				if(flag)break;
			}
			
			mc.skin._rotation = a/0.0174
			mc.skin.stop();
			mc.init();
			
			var info = {mc:mc.skin,a:a,t:i*4}
			
			
			//Log.trace(mc)
			launcher.push(info)
		}

	}

	function initLauncher(info){
		var me = this;
		info.mc.onPress = fun(){
			me.fire(info)
		}
		info.t = null
		info.mc.gotoAndPlay("2")		
	}
	
	
	function update(){
		super.update();
		switch(step){
			case 1:
				// ORBITE
				speedDecal = (speedDecal+10)%628
				var sp = speed+Math.cos(speedDecal/100)*speed*0.5
				decal = (decal+sp)%628
				trg.x = planete.x + Math.cos(decal/100)*tRay
				trg.y = planete.y + Math.sin(decal/100)*tRay
				trg.skin._rotation += 50/sp
			
				// COOLDOWN
				for( var i=0; i< launcher.length; i++ ){
					var info = launcher[i]
					if( info.t != null ){
						info.t -= Timer.tmod
						if( info.t < 0 ){
							initLauncher(info)
						}
					}
					
				}
				
				// CHECK COL
				for( var i=0; i<missile.length; i++ ){
					var s = missile[i];
					var dist = s.getDist(trg)
					if( dist < 10 ){
						explosion(trg.x,trg.y)
						setWin(true)
						s.kill();
						trg.kill();
						missile.splice(i,1)
						i--;
					}
				}
				
				// OLD TRG POS
				oTrg={x:trg.x,y:trg.y}
				
				break;
		}
		//
	
	}
	
	function fire(info){
		info.t = 80
		info.mc.gotoAndStop("1")
		info.mc.onPress = null
		var mc = newPhys("mcOrbitalMissile")
		var ca = Math.cos(info.a)
		var sa = Math.sin(info.a)
		var d = pRay+10
		var sp = 6
		mc.x = info.mc._x + ca*d
		mc.y = info.mc._y + sa*d
		mc.vitx = ca*6
		mc.vity = sa*6
		mc.flPhys = false;
		mc.skin._rotation = info.a/0.01714
		mc.init();
		missile.push(mc)
		
	}
	
	function explosion(x,y){
	
		var dist = trg.getDist(oTrg)
		var ta = trg.getAng(oTrg)
		
		for( var i=0; i<12; i++ ){
			var mc = newPart("mcPartFeather")
			var a = Std.random(628)/100
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			var p = 0.5+Std.random(30)*0.1
			var scale = 50+Std.random(100)
			mc.x = x + ca*p*1.5
			mc.y = y + sa*p*1.5
			mc.vitx = ca*p - Math.cos(ta)*dist*0.15
			mc.vity = sa*p - Math.sin(ta)*dist*0.15
			mc.vitr = Math.random()*20
			mc.flPhys = false;
			mc.init();
			mc.skin.gotoAndStop(string(Std.random(mc.skin._totalframes)+1))
			mc.skin._xscale = scale;
			mc.skin._xscale = scale;
		}
		
	}
	
	
	
	
//{	
}
















