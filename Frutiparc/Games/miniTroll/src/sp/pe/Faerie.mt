class sp.pe.Faerie extends sp.People{//}


	var fi:FaerieInfo
	
	var manaMax:int;
	var manaTimer:float;
	
	var starTimer:float;
	var blinkDecal:float;
	/*
	var intFace:inter.Face
	var intLife:inter.Life;
	var intMana:inter.Mana;
	var intDialog:inter.Dialog;	
	*/
	
	var currentShot:spell.Shot;
	
	var dbgAngle:MovieClip;
	var dbgRound:MovieClip;
	
	function new(){
		super();
	}
	
	function init(){
		super.init();
		manaTimer = 50;
		starTimer = 0;
		blinkDecal = 0;
	}
	
	function update(){
		super.update();
		replenish();
		updateState();
		seekTarget(Cs.game.impList);
		if(!flForceWay)dodge();
		
		/*
		if(dbgAngle==null){
			var dm = new DepthManager(skin)
			dbgAngle = dm.attach("mcAngle",10)
		}
		dbgAngle._rotation = angle/0.0174
		if(trg==null)
			dbgAngle.gotoAndStop("2")
		else
			dbgAngle.gotoAndStop("1")
		*/
		
	}
		
	function dodge(){
		var zoneRay = 30+fi.carac[Cs.SPEED]*15
		var list = Cs.game.shotList
		
		var ea = null
		var distMax = zoneRay
		var fear = null
		for( var i=0; i<list.length; i++ ){
			var shot = list[i]
			for( var n=0; n<shot.trgList.length; n++ ){
				if( shot.trgList[n] == this ){
					var dist = getDist(shot)
					if( dist < distMax){
						fear  = shot;
						var c = 1 - dist/zoneRay
						var a = getAng(shot)-3.14
						ea = getEvadeAngle(a,50)
						distMax = dist
					}
				}
			}
		}
		if( ea != null ){
			//Log.print("esquive! ")
			angle = ea;
			trg = null;
			noTrgTimer = 6;	
			/*
			if( dbgRound._visible != true ) dbgRound = game.dm.attach("dbgRound",Game.DP_PART);
			dbgRound._x = fear.x
			dbgRound._y = fear.y
			dbgRound._xscale = dbgRound._yscale = zoneRay*2
			*/
			
		}else{
			dbgRound.removeMovieClip();
		}
	}
	
	function updateState(){
		if( Cs.game.flHelp ){
			starFall(0.7)
		}
	}
	
	function incManaTimer(inc){
	
		if( fi.sPow[Cs.POW_REGENERATE_MANA] ) inc*=1.5;
		manaTimer+=inc
		if( mana < manaMax ){
			if( manaTimer < 0 ){
				manaTimer += 80
				setMana(mana+1)
			}
		}
	}
	
	function replenish(){

		if( health < 100 && fi.sPow[Cs.POW_REGENERATE_LIFE] ){
			//Log.print("regenerate!")
			health = Math.min( health+Timer.tmod, 100 )
			fi.intLife.setHealth(health*0.4);
		}
	}
	
	function checkSpell(){
		if(game.flHelp){
			Log.setColor(0xFFFFFF)
			var list = getSpellList();
			
			
			if( list.length > 0 ){
				var index = Math.floor( Math.random()*list.length / fi.carac[Cs.INTEL] );
				var spell = list[index].spell
				//spell.caster = this
				spell.store();
			}
		}
	}
	
	function getSpellList():Array<{rel:float,spell:spell.Base}>{	// Recursive

		var list = new Array();
		//var spList = Std.cast(Tools.shuffle)(fi.spell);

		//Manager.log("Relevance test:")
		
		for( var i=0; i<fi.spellList.length; i++ ){
			var spell = fi.spellList[i];
			var rel = spell.getRelevance();
			
			if( rel > 0  && spell.isAvailable() && rel!=null && !Std.isNaN(rel) ){
				var multi = fi.fs.$spellCoef[spell.sid]
				if( multi == null ) multi = 10;
				var fr = (rel*multi)/spell.cost
				list.push( {rel:fr,spell:spell} );
				//Manager.log(spell.getName()+" : "+fr)
			}
		};
		var f = fun(a,b){
			if( a.rel > b.rel ) return -1;
			if( a.rel < b.rel ) return 1;
			return 0;
		}
		list.sort(f);
		return list;
	}
	
	function setLife(n){
		super.setLife(n)
		//Manager.log(n)
		fi.fs.$life = int(Math.max(0,n));
		fi.intLife.updateGFX();	
	}
	
	function setMana(n){
		super.setMana(n)
		fi.fs.$mana = n
		currentShot = fi.getBestShotAvailable();
		fi.intMana.updateGFX();	
	}	
	
	function setSkin(mc){
		super.setSkin(mc)
		
		body = downcast( dm.attach( "faerie", sp.People.DP_SKIN ) )	
		setColor()
		if( fi.sPow[Cs.POW_INVISIBILITY] ){
			body._alpha = 40
		}
		
	}
	
	function setColor(){
		Mc.setColor( body.body.tete.kami, fi.skin.col1 ) 
		Mc.setColor( body.body.corps.m, fi.skin.col2 )		
		Mc.setColor( body.body.epaule.m, fi.skin.col2 )		
		Mc.setColor( body.w0.w, fi.skin.col3 ) 
		Mc.setColor( body.w1.w, fi.skin.col3 ) 	
	}
	
	function setInfo(info){
		fi = info
		setLife(fi.fs.$life);
		setMana(fi.fs.$mana);
		manaMax = fi.carac[Cs.MANA]*2
		
		// MANIABILITE
		speed = 0.1 + fi.carac[Cs.SPEED]*0.13
		frict = 0.95
		cTurn = 0.03 + fi.carac[Cs.SPEED]*0.04
		
		freqDash = 7;
		freqDash += fi.carac[Cs.POWER]*2;
		if( fi.sPow[Cs.POW_BERSERK] )freqDash*=2;
		ray = 8
		
		// SPELL		
		var list = fi.spellList;
		for( var i=0; i<list.length; i++ ){
			list[i].caster = this;
		}
		var list2 = fi.shotList;
		for( var i=0; i<list2.length; i++ ){
			list2[i].caster = this;
		}
		
		// FIGHT
		currentShot = fi.getBestShotAvailable();
		
		//dashCoef = 1
		
		
		// SPECIAL POWER
		
		
		
	}
	
	//
	function callHelp(){

		if( mana > 0 ){
			Cs.game.flHelp = true;
			colorBlink = {t:1000,d:0,c:0xFFFFFF,sp:20}
			fi.react(Lang.helpOk)
		}else{
			fi.react(Lang.helpNoMana)
		}
	}
	
	//
	function birth(mc){
		super.birth(mc)
		addToList(game.faerieList);
	}
		
	function spin(){
		super.spin()
		Mc.setColor( Std.cast(body).tete.kami, fi.skin.col1 ) 
		Mc.setColor(  Std.cast(body).body.col, fi.skin.col2 )		
		Mc.setColor( body.w0.w, fi.skin.col3 ) 
		Mc.setColor( body.w1.w, fi.skin.col3 ) 	
	}
	
	function stopSpin(){
		super.stopSpin();
		setColor();
	}	
	
	
	//
	function showStatus(){
		//Manager.log("show Status : life("+fi.fs.$life+")")
		if( fi.fs.$life==0 ){
			setStatus( Cs.NEED_HEAL, true )
		}
		if( fi.fs.$moral==0 ){
			setStatus( Cs.NEED_MORAL, true )
		}
		if( fi.fs.$mood[Cs.M_NUMB]==1 ){
			setStatus( Cs.NUMB, true )
		}
		if( fi.fs.$mood[Cs.M_DISEASE]==1 ){
			setStatus( Cs.DISEASE, true )
		}
	}
	
	
	
	//FIGHT
	
	function fight(){
		super.fight();	//Log.print("fight ")
	}
	
	function checkShoot(){
		if( currentShot == null )return;
		currentShot.update();
	}
	
	function harm(damage){
		damage = damage/1+(fi.fs.$level)*0.1
		super.harm(damage)
		while( health <= 0 ){
			setLife(life-1)
			if( life > 0 ){
				fi.react(Lang.SENT_HEART_DAMAGE)
				health += 100
			}else{
				fi.intFace.fadeToDeath();
				deathExplosion()
				kill();
				break;
			}
		}
		if(damage>40)fi.react(Lang.SENT_DAMAGE)
		fi.intLife.setHealth(health);
		
	}
		

	function dashImpact(){
		var c = super.dashImpact();
		var p = (1+fi.carac[Cs.POWER]*2)*c;
		if( fi.sPow[Cs.POW_BERSERK] )p=Math.round(p*1.5);
		return  p
	}
	
	// GET
	function getPower(){
		
	}

	function getMinShotZone(){
		return currentShot.minShotZone;
	}	
	
	//TOOLS
	
	function newPart(link,flFront){
		var d = Game.DP_PART2;
		if(flFront) d = Game.DP_PART3;
		return Cs.game.newPart(link,d);
	}
	
	//FX
	function starFall(coef){
		starTimer -= Timer.tmod*coef;
		while( starTimer < 0 ){
			starTimer ++;
			var sp = newPart("partStar",true)
			var a = Math.random()*6.28
			var d = Math.random()*14
			sp.x = x+Math.cos(a)*d
			sp.y = y+Math.sin(a)*d
			sp.scale= 20+Math.random()*90
			sp.weight = 0.1
			sp.flGrav = true
			sp.timer = 5+Math.random()*15
			sp.init();
			Mc.setColor(sp.skin, fi.skin.col1 )
			Mc.modColor(sp.skin, 1, 180 )
		}	
	}
		

	function deathExplosion(){
		// PART
		var iMax = 4
		var nMax = 6
		for( var i=0; i<iMax; i++ ){
			//var a0 = (i/iMax)*1.57;
			var a0 = (i%2)*1.57
			for( var n=0; n<nMax; n++ ){
				var a =  a0 + (n/nMax)*6.28;
				var p = Cs.game.newPart("partLightBallFlip",null)
				p.x = x;
				p.y = y;
				var speed = 1.5+i*1.5
				p.vitx += Math.cos(a)*speed
				p.vity += Math.sin(a)*speed
				p.timer = 30-i*5
				p.init();
			}				
		}
		
	}
	
//{	
}




















