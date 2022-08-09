class sp.pe.Imp extends sp.People{//}
	
	
	
	// VARIABLES
	var action:int;
	var level:int;
	var spellCoolDown:float;
	
	
	function new(){
		super();
		action = 8+Std.random(4)//8
	}
	
	function init(){
		super.init();
		//setLevel(Std.random(5))

		spellCoolDown = Cs.impSpellRate*0.5
		
	}
	
	function update(){
		super.update();

		if(Cs.game.step == 2 ){
			if( spellCoolDown > 0 ){
				var c = 1
				if( Cs.game.faerieList.length>0 )c=0.3;
				spellCoolDown -= c*Timer.tmod;
			}
			
			if( action == 0 ){
				flForceWay = true;
				trg = {x:Cs.game.width*0.5, y:-30}
				if( y < -20 ){
					kill();
				}
				
			}
			
		}
		
		seekTarget(Cs.game.faerieList);
		
	}
		
	function setSkin(mc){
		super.setSkin(mc)
		
		dm = new DepthManager(skin);
		body = downcast( dm.attach( "imp", sp.People.DP_SKIN ) )
		
		var free = Std.cast(body)
		
		var col0 = Cs.impColorList[level][0]
		var col1 = Cs.impColorList[level][1]
		
		Mc.setColor( free.body.tete.col, col0 )
		Mc.setColor( free.body.corps.col, col0 )	
		Mc.setColor( free.body.epaule.col, col0 )
		Mc.setColor( free.w0.w, col1 )
		Mc.setColor( free.w1.w, col1 )
	}
	
	function shoot(){
		super.shoot();

		var s = newShot()
		peTrg.addToList(s.trgList)
		
		s.caster = upcast(this);
		s.typeList = [ 20+level ]
		s.link = "shotImp"
		s.ray = 4+level
		s.damage = 15 + level*15		// 30 40 50 60 70	15 30 45 60 75
		s.initDirect(4+level*0.4)
		
		if( downcast(peTrg).fi.sPow[Cs.POW_INVISIBILITY] ){
			s.angle += (Math.random()*2-1)*1.3
			s.updateVit();
		}
		
		s.init(); 
		s.skin.gotoAndStop(string(1+level))
	}
	
	function setLevel(n){
		level = n;
		freqShoot = 1+n*2;
		health = 50+50*n
		freqDash = 2+int(level*0.5);
		ray = 8
		
		speed = 0.2
		cTurn = 0.11		
		
	}
	
	function dashImpact(){
		var c = super.dashImpact();
		var p = (level+1)*c;
		return  p
	}
	
	function harm(damage){
		super.harm(damage)
		if( health <= 0 ){
			
			var mf = Cs.aventure.mf
			if( !mf.flDeath ){
				mf.fi.incExp( int(Math.pow(level+2,2)) )
			}
			var pa = Cs.game.newPart("partDeadImp",null)
			pa.x = x;
			pa.y = y;
			pa.scale = 100+level*20
			pa.timer = 15;
			pa.init();
			
			for(var i=0; i<10+level*2; i++){
				var p = Cs.game.newPart("partJet",null)
				p.x = x;
				p.y = y;
				
				p.skin._rotation = Math.random()*360
				p.skin.gotoAndPlay(string(Std.random(12)+1))
				p.init();
				p.skin._xscale = 50+Math.random()*50			
			} 
			
			Cm.card.$stat.$kill[level]++
			kill();
		}
	}
	
	function birth(mc){
		super.birth(mc);
		addToList(game.impList)	
	}

	function seekTarget(a){
		super.seekTarget(a)
		if( downcast(peTrg).fi.sPow[Cs.POW_FEAR] ){
			//Log.print("fear")
			flFear = true;
		}
	}
	

	// SPELL
	function checkSpell(){
		if( status[Cs.SILENCE] || action == 0 )return;
		if( spellCoolDown <= 0 ){
			var spell = getSpell();
			if(spell != null ){
				spellCoolDown = Cs.impSpellRate
				spell.store();
				action--;
			}
		}
	}	
	
	function getSpell():spell.Imp{
		
		var rnd = Math.random();
		var s:spell.Imp = null
		//*
		switch(level){
			
			case 0:
				if( rnd < 0.1 ){
					s = upcast( new spell.imp.TokenFall() );
				}else if( rnd < 0.15 ){
					s = upcast( new spell.imp.Bind() );					
				}
				
				break;
				
			case 1:
				if( rnd < 0.1 ){
					s = upcast( new spell.imp.TokenFall() );
				}else if( rnd < 0.14 ){
					s = upcast( new spell.imp.Conglomerat() );
				}else if( rnd < 0.20 ){
					s = upcast( new spell.imp.Smoke() );
				}else if( rnd < 0.23 ){
					s = upcast( new spell.imp.ShapeBig() );
				}else if( rnd < 0.25 ){
					s = upcast( new spell.imp.Bind() );
				}else if( rnd < 0.26 ){
					s = upcast( new spell.imp.Night() );						
				}	
				break;
				
			case 2:
				if( rnd < 0.1 ){
					s = upcast( new spell.imp.TokenFall() );
				}else if( rnd < 0.15 ){
					s = upcast( new spell.imp.Conglomerat() );
				}else if( rnd < 0.20 ){	
					s = upcast( new spell.imp.Armor() )
				}else if( rnd < 0.25 ){
					s = upcast( new spell.imp.ShapeBig() );					
				}else if( rnd < 0.26 ){
					s = upcast( new spell.imp.Bind() );
				}else if( rnd < 0.28 ){
					s = upcast( new spell.imp.Night() );					
				}
				break;
				
			case 3:
				if( rnd < 0.1 ){
					s = upcast( new spell.imp.TokenFall() );
				}else if( rnd < 0.15 ){	
					s = upcast( new spell.imp.Armor() )
				}else if( rnd < 0.18 ){
					s = upcast( new spell.imp.Conglomerat() );
				}else if( rnd < 0.21 ){
					s = upcast( new spell.imp.ShapeBig() );					
				}else if( rnd < 0.25 ){
					s = upcast( new spell.imp.Wall() );
				}else if( rnd < 0.28 ){
					s = upcast( new spell.imp.Night() );
					
				}
				break;
				
			case 4:
				if( rnd < 0.1 ){
					s = upcast( new spell.imp.TokenFall() );
				}else if( rnd < 0.15 ){	
					s = upcast( new spell.imp.Armor() )
				}else if( rnd < 0.16 ){
					s = upcast( new spell.imp.Conglomerat() );
				}else if( rnd < 0.18 ){
					s = upcast( new spell.imp.ShapeBig() );					
				}else if( rnd < 0.24 ){
					s = upcast( new spell.imp.Wall() );
				}else if( rnd < 0.26 ){
					s = upcast( new spell.imp.Night() );
				}else if( rnd < 0.29 ){
					s = upcast( new spell.imp.Origin() );					
				}
				break;				
		}
		//*/
		
		
		s.imp = this;
		s.caster = this;
		return s;
		
	}
	
//{	
}








