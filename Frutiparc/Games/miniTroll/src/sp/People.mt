class sp.People extends Sprite{//}

	static var DP_STATUS = 6
	static var DP_SKIN = 5
	static var DP_GLOW = 2
	
	
	// CONSTANTES
	var mcw:float;
	var mch:float;
	
	
	// SEMI-CONSTANTE
	var ray:float;
	var speed:float;
	var cTurn:float;
	var frict:float;
	var freqShoot:int;
	var freqDash:int;
	var shootPower:float;

	
	// VARIABLES
	var flFear:bool;
	var flDeath:bool;
	var flForceWay:bool
	var flBound:bool
	
	var px:int;
	var py:int;
	
	var fightStep:int;
	
	var flyMode:int;
	var life:int;
	var dashTimer:float;
	var health:float;
	var mana:int;
	var xInc:float;
	var yInc:float;
	var vitx:float;
	var vity:float;
	var angle:float;
	var wingDecal:float;
	var ta:float;
	var noTrgTimer:float;
	var stun:float;
	var spinSpeed:float;
	var spinFrame:float;
	var minShotZone:float;
	var status:Array<bool>
	var statusTimer:Array<float>

	var dm:DepthManager;
	var peTrg:sp.People
	var trg: { x:float, y:float }
	var colorBlink:{t:float,d:float,c:int,sp:float}
	
	var game:Game;
	var currentSpell:spell.Base;
	
	var dashAura:MovieClip;
	var mcStatus:MovieClip
	
	var body:{
		>MovieClip,
		w0:{ >MovieClip, w:{ >MovieClip, w:MovieClip } },
		w1:{ >MovieClip, w:{ >MovieClip, w:MovieClip } },
		body:{ >MovieClip, tete:{>MovieClip, kami:MovieClip}, corps:{>MovieClip, m:MovieClip}, epaule:{>MovieClip, m:MovieClip} }
	}
	var glow:MovieClip;
	
	
	function new(){
		super();
		flForceWay = false;
		flBound = true;
		angle = 1.57 ;
		
		speed = 0//0.2
		cTurn = 0.1
		frict = 0.95
		freqShoot = 300
		
		noTrgTimer = 0;
		
		vitx = 0
		vity = 0
		ta = Math.random()*6.28
		
		flDeath = false;
		
		wingDecal = 0
		flyMode = 0
		
		health = 100;
		spinFrame = 0
		
		status = new Array();
		statusTimer = new Array();
		
		
	}
	
	function init(){
		super.init();
		
	}
	
	function setSkin(mc){
		super.setSkin(mc)
		dm = new DepthManager(skin);
		mcw = (game.xMax*game.ts)+game.marginLeft
		mch = (game.yMax*game.ts)+game.marginUp	
		yInc = 0
		xInc = 0
		glow = downcast( dm.attach( "mcGlow", sp.People.DP_GLOW ) )
		
	}
				
	function update(){
		// FIGHT
		if( peTrg != null ){
			if( !peTrg.flDeath ){
				if(game.step == 2){
					fight();
				}
			}else{
				flyMode = 0;
				peTrg = null
				if( dashAura != null ){
					dashAura.removeMovieClip();
					dashAura = null;
				}				
			}
		}
		// MOVE
		move();
	
		//FX
		var cb = colorBlink
		if( cb != null ){
			cb.t -= Timer.tmod;
			var prc = 0
			if( cb.t > 0 ){
				cb.d = (cb.d+cb.sp*Timer.tmod)%628
				prc = 50+Math.cos(cb.d/100)*50 
			}
			Mc.setPercentColor(body,prc,cb.c)
		}
		
		// STATUS
		for( var i=0; i<statusTimer.length; i++ ){
			if( statusTimer[i] != null ){
				statusTimer[i] -= Timer.tmod
				if( statusTimer[i] <= 0 ){
					statusTimer[i] = null
					setStatus(i,false)
				}
			}
		}
		
		
		
		super.update();
	}
	
	function move(){
		
		
		// FRICT
		var f = frict
		
		// BOOST
		ta = chooseWay()
		
		var da = ta-angle
		if(da>3.14)da-=6.28;
		if(da<-3.14)da+=6.28;
		angle += da*cTurn*Timer.tmod;//(Math.random()*2-1)*0.1*Timer.tmod
		
		if( stun == null ){
			vitx += Math.cos(angle)*speed*Timer.tmod;
			vity += Math.sin(angle)*speed*Timer.tmod;
			f *= Math.pow( f, Math.abs(da) )
		}
		
		f = Math.pow(f,Timer.tmod)
		vitx *= f
		vity *= f
		
		// MOVE
		x += vitx*Timer.tmod
		y += vity*Timer.tmod
		
		if(flBound)checkBounds();
		if(spinSpeed!=null){
			spin();
		}else{
			moveWings();
		}
	}
	
	function chooseWay(){
		
		if( flFear ){
			//Log.print("fear !!!")
			return peTrg.getAng(this)
		}
		
		
		if( noTrgTimer > 0 ){
			noTrgTimer -= Timer.tmod
		}else{
			if( !flForceWay && Std.random(int(30/Timer.tmod)) == 0  ){
				trg = getRandomTrg()
			}
		}
		var ta = this.ta
		if( trg != null ) ta = this.getAng(trg);

		return ta
	}
	
	function getRandomTrg(){
		 return { x:Std.random(int(mcw)), y:Std.random(int(mch))}
	}
		
	function checkBounds(){
		var m = 6
		if( x < m+Cs.game.marginLeft || x > mcw-m ){
			angle = getEvadeAngle(angle,30)			
			vitx *= -0.3;
			x = Math.min( Math.max( m+Cs.game.marginLeft, x ), mcw-m )
		}
		if( y < m+Cs.game.marginUp || y > mch-m ){
			angle = getEvadeAngle(angle,30)	
			vity *= -0.3;
			y = Math.min( Math.max( m+Cs.game.marginUp, y ), mch-m )
		}		
	}
		
	function moveWings(){
		
		// 
		var dy = Math.min( Math.max( 0, 0.5+vity*0.15 ), 1 ) - yInc
		yInc += dy*0.2*Timer.tmod 
		var mc = body
		
		//Manager.log(mc);
		
		var xi = xInc
		var yi = yInc
		
		switch(flyMode){
			case 1:
				var a = getAng(peTrg)			
				yi = (1+Math.sin(a))*0.5
				xi = Math.cos(a)*2
				break;
		}
		
		// BODY
		mc.body.gotoAndStop(string(1+Math.floor(yi*40)))

		// AILE HAUTEUR
		mc.w0.w.w._yscale = 100-80*yi
		mc.w1.w.w._yscale = 100-80*yi
		

		// BATTEMENT
			wingDecal = (wingDecal+(80-vity*16))%628	
			
			// SCALE
			var sup = Math.cos(wingDecal/100)*45*(1-yi) + 75*yi
			mc.w0.w.w._xscale = mc.w1.w._xscale = 50+sup
		
			// ROTATION
			mc.w0.w._rotation = (Math.cos(wingDecal/100)*70)*yi
			mc.w1.w._rotation = (Math.cos(wingDecal/100)*70)*yi

		
		
		// DECALAGE
		var dx  = vitx-xi
		xi += dx*0.2*Timer.tmod 

		var mod1 = xi*12//*20;
		var mod2 = -xi*50;

		if( vitx > 0 ){
			mc.w0._xscale =   100 + mod1
			mc.w1._xscale =   100 + mod2
		}else{
			mc.w0._xscale =   100 - mod2
			mc.w1._xscale =   100 - mod1		
		}

		// PENCHE
		mc._rotation = xi*12
		mc.body._rotation = xi*5
		
	}
	
	function spin(){
		spinFrame = (spinFrame+spinSpeed)%38;
		body.gotoAndStop(string(10+Math.floor(spinFrame)))
	}
	
	function stopSpin(){
		spinSpeed = null;
		body.gotoAndStop("1")
	}
	
	function setLife(n){
		life = n
	}
	
	function setMana(n){
		mana = n
	}
	
	function incMana(inc){
		setMana(mana+inc)
	}
	
	
	function checkSpell(){
	
	}
	
	function setPeopleTarget(pe){
		peTrg = pe;
		flyMode = 1
		initFightStep(0)
	}
	
	function birth(mc){
		game = Cs.game;
		setSkin( mc );
		addToList(game.pList);	
	}
	
	// SET STATUS
	function setStatus(id,flag){
		status[id] = flag
		updateStatus();
	}
		
	function updateStatus(){
	
		var frame = null
		for( var i=0; i<status.length; i++ ){
			if(status[i])frame = i+1;
		}

		
		if( frame == null && mcStatus != null ){
			mcStatus.removeMovieClip();
		}
		if( frame != null  ){
			//Manager.log("updateStatus!")
			if( mcStatus == null ){
				mcStatus = downcast( dm.attach( "mcPeopleStatus", DP_STATUS ) );
				//Manager.log(mcStatus)
			}
			mcStatus.gotoAndStop(string(frame));
		}
	}
	
	
	// FIGHT
	
	function initFightStep(n){
		fightStep = n
		switch(fightStep){
			case 0:
				break;
			
			case 1:	// DASH
				dashTimer = 18//12+speed*1.5;
				dashAura = Std.attachMC(skin,"mcDashAura",10)
				dashAura._alpha = 0
				break;
		}
		
		
	}
	
	function fight(){

		var dist = getDist(peTrg);
		var a = getAng(peTrg);
		
		switch(fightStep){
			case 0:	// NORMAL
				if( dashAura != null ){
					dashAura.removeMovieClip();
					dashAura = null;
				}
				if( dist > getMinShotZone() ){	
					checkShoot();
				}
				
				if( dist < 100 && dist > 40  ){
					checkDash();
				}
				break;
			case 1:	// DASH
				//Log.print("dash!")
				var dashSpeed = getSpeed()
				
				dashTimer -= Timer.tmod
				if( dashTimer < 0 ){
					initFightStep(0)
				}
				
				// DASH
				towardSpeed( peTrg, 1, 1.5 )
				
				// PART
				dashAura._rotation = a/0.0174
				dashAura._alpha = dashSpeed*10;
				
				// COL
				//*
				var r = ray+peTrg.ray
				if( dist < r ){
					//Manager.log("touch! "+dist)
					if( dashSpeed > 5 ){
						
						// RECAL
						var d = (r-dist)*0.5;
						var ca = Math.cos(a);
						var sa = Math.sin(a);
						x -= ca*d;
						y -= sa*d;
						peTrg.x += ca*d;
						peTrg.y += sa*d;
						
						// HARM
						var p0 = peTrg.dashImpact()
						var p1 = dashImpact()
						
						harm(p0)
						peTrg.harm(p1)
						
						var mod = 1
						vitx -= ca*p0*mod
						vity -= sa*p0*mod
						peTrg.vitx += ca*p1*mod
						peTrg.vity += sa*p1*mod
						
						// FX
						Cs.base.flash();
						var part = Cs.game.newPart("partOnde", Game.DP_PART2)
						part.x = (x+peTrg.x)*0.5;
						part.y = (y+peTrg.y)*0.5;
						
						
					}else{
						initFightStep(0)
					}

				}
				//*/
				break;
		}		

		// SHOOT

	}
	
	function checkShoot(){

		for( var i=0; i<freqShoot; i++ ){
			if( Std.random(int(Cs.shootBase/Timer.tmod)) == 0 ){
				shoot()
				break;
			}
		}	
	}
	
	function checkDash(){
		for( var i=0; i<freqDash; i++ ){
			if( Std.random(int(Cs.dashBase/Timer.tmod)) == 0 ){
				initFightStep(1);
			}
		}	
	}	
	
	function shoot(){
		//Manager.log("goefefe!")
	}	
	
	function newShot(){
		var s = new sp.part.Shot();
		s.x = x
		s.y = y
		//s.setSkin(link)
		//s.init();
		s.addToList(Cs.game.shotList)
		return s;
	}

	function harm(damage){
		health -= damage
		colorBlink = {t:damage,d:0,c:0xFF0000,sp:50}
	}

	function dashImpact(){
		var c = 1
		if(fightStep == 1){
			c*=3;
			initFightStep(0)
		}
		return c;
	}	

	function seekTarget(a){
		var list:Array<sp.People> = Std.cast(a)
		if( peTrg == null && list.length > 0 ){
			setPeopleTarget(list[Std.random(list.length)])
		}
	}
	
	function getMinShotZone():float{
		return 50;
	}
	
	// TOOLS
	function towardSpeed(t,c,lim){
		var dx = t.x - x
		var dy = t.y - y
		vitx += Math.min( Math.max( -lim, dx*c*Timer.tmod ), lim )
		vity += Math.min( Math.max( -lim, dy*c*Timer.tmod ), lim )
	}	

	function getSpeed(){
		return Math.sqrt( vitx*vitx + vity*vity )
	}
	
	function getEvadeAngle(a,dist){
		var sens = 1
		var dif = 0
		
		var ta = a
		var tx = 0;
		var ty = 0;
		
		do{
			ta += dif*2*sens	
			tx = x+Math.cos(ta)*dist
			ty = y+Math.sin(ta)*dist
			
			dif += 0.05
			sens *= -1
			if( dif > 3 ){
				Manager.log("coucou ")
				break;
			}
		}while( !Cs.game.isIn(tx,ty,12) )
		
		return ta;
	}
	
	// FX
	function starFall(coef){
	
	}
	
	
	//
	function kill(){
		flDeath = true;
		if( currentSpell != null ){
			currentSpell.emergencyStop()
		}
		super.kill();
	}
	

	

	
	
	//{	
}


















