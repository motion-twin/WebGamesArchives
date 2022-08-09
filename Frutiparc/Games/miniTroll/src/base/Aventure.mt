class base.Aventure extends Base{//}

	
	var level:int;
	
	
	var timer:float;
	var mf:sp.pe.Faerie;
	
	var intFace:inter.Face;
	var intLife:inter.Life;
	var intMana:inter.Mana;
	
	
	var bouquet:{mc:MovieClip,trg:int,vit:float,list:Array<{sc:float,x:float,y:float,mc:MovieClip}>};
	var panel:{mc:MovieClip,trg:int,vit:float};
	var expPanel:{>MovieClip, dm:DepthManager, list:Array<{>MovieClip,e:MovieClip}>,fieldName:TextField };
	
	function new(){
		super();
		Cs.aventure = this;
		fi = Cm.getCurrentFaerie();
		fi.fs.$mana  = fi.carac[Cs.MANA]*2
	}
	
	function init(){
		//
		//Log.setColor(0xFFFFFF) 
		//
		super.init();
		level = 0;


		
	}

	function launch(){
		initSkin();
		updatePos();
		initStep(0);
	}

	function initGame(){
		super.initGame();
		

		
	}
	
	function initFaerie(){
		mf = null;
		//if( fi != null && fi.fs.$life > 0 && fi.fs.$moral > 0){}
		if( fi.isReadyForBattle() ){
			linkToInterface();
			mf = new sp.pe.Faerie();
			mf.setInfo(fi)
			mf.init();
			
		}	
	}
	
	/*
	function grab(type){
		super.grab(type);
	}
	*/

	function initSkin(){

	}

	function updatePos(){
		
		super.updatePos();
		game._x = 0
		game._y = 0
		
		// INTERFACE
		var m = 4
		var x = 132+m
		var y = m
		
		for( var i=0; i<interList.length; i++ ){
			
			var inter = interList[i];
			inter.skin._x = x+inter.mx
			inter.skin._y = y+inter.my
			y += inter.height+inter.margin+m*0.75;
		}	
	}
	
	//
	function initStep(n){
		super.initStep(n)
		switch(step){
			case 0:	// OPENING 1 - BOUQUET
				initGame();
				game.init();	
				initBouquet();
				timer = 40;
				break;
				
			case 1:  // OPENING 2 - FAERIE
				if( mf !=null ){
					mf.birth( game.dm.empty( Game.DP_PEOPLE ) );
					mf.x = game.width*0.5;
					mf.y = game.height*0.5;
					mf.update();

					
				}
				game.lvl = getLevel()
				game.launch()
				
					
				for( var i=0; i<Manager.impList.length; i++ ){
					var imp = game.addImp(game.width*0.5,game.height*0.5,Manager.impList[i])
					//imp.setStatus(0,true)
					//imp.statusTimer[0] = 100+Math.random()*100
				}				
				
				break;
				
			case 2:	// ENDING 1 - FAERIE
				mf.trg = { x:game.width*0.5, y:-30 }
				mf.flForceWay = true;
				mf.fi.react(Lang.endCheerList)
				timer = 20;
				break;
				
			case 3: // ENDING 2 - LEVEL-UP
				
				initExpPanel();
				setPanel(upcast(expPanel))
				panel.trg = 80
				break;				
		}
	}
	
	//
	function update(){
		super.update();
		switch(step){
			case 0: // OPENING 1 - BOUQUET
				moveBouquet();
				break;
			case 1: // OPENING 2 - GAME

				break;
			case 2: // ENDING 1 - NEXT
				timer -= Timer.tmod;
				if( timer<0 && ( mf == null || mf.y < -10 || mf.flDeath ) ){
					endGame();
				}
				break;
			case 3:	// ENDING 2 - LEVEL-UP
				movePanel();
				if( panel == null ){
					tryToCloseGame();
				}
				break;
		}	
	}
	//
	
	
	// ENDING

	function endGame(){
		tryToCloseGame();
	}
	
	function tryToCloseGame(){
		game.kill();
		if( mf.fi.fs.$level < Cs.FAERIE_LEVEL_MAX && mf !=null && mf.fi.getNextExpLimit() <= mf.fi.fs.$exp ){
			initStep(3)
			return;
		}
		initStep(0)		
		
	}
	

	// EXP
	
	function initExpPanel(){
		expPanel = downcast(dm.attach("mcExpPanel",Base.DP_PANEL))
		expPanel._x = Cs.mcw*0.5
		expPanel._y = Cs.mch*0.5


		expPanel.dm = new DepthManager(expPanel);
		expPanel.list = new Array();//[expPanel.s0,expPanel.s1]
		

		for( var i=0; i<2; i++ ){
			var mc = downcast(expPanel.dm.attach("evolutionSlot",1))//expPanel.list[i]
			initExpSlot(mc,i,mf.fi);
			expPanel.list.push(mc);
		}

	}
	
	function initExpSlot(mc,i,fi){
		mc._x = (i*2-1) * 46
		mc._y = 15
		
		var n =  fi.fs.$next[i]
		var frame = 60
		if( n != null ){
			frame = n+1+i*10;
			var me = this;
			mc.onPress = fun(){
				fi.levelUp(i);
				me.panel.trg = 0;
				me.expPanel.onPress = fun(){}
				me.expPanel.useHandCursor = false;
			}
			var name = " pas de définition "
			switch(i){
				case 0:
					name = "+1 en "+it.Carac.carNameList[n]
					break;
				case 1:
					var spell = Spell.newSpell(n)
					name = spell.getName();
					break;
			}
			
			//var field = Std.cast(mc)._parent.fieldName

			mc.onRollOver = fun(){
				me.expPanel.fieldName.text = name;
			}
			mc.onRollOut = fun(){
				me.expPanel.fieldName.text = "Faites votre choix !"
			}
			mc.onDragOut = mc.onRollOut

			//*
			if(i==0){
				Mc.makeHint(Std.cast(mc),Lang.caracResume[n],120)
			}else{
				Mc.makeHint(Std.cast(mc),Spell.newSpell(n).getDesc(),120)
			}
			//*/

		}
		mc.e.gotoAndStop(string(frame));
		
	}
	
	// PANEL
	
	function setPanel(mc){
		mc._xscale = 0;
		mc._yscale = 0;
		panel = { mc:mc, vit:0, trg:100 }	
	}
	
	function movePanel(){
		var ds = panel.trg-panel.mc._xscale
		var lim = 10
		panel.vit += Math.min(Math.max(-lim,ds*0.1,),lim)*Timer.tmod
		panel.vit *= Math.pow(0.75,Timer.tmod)
		panel.mc._xscale += panel.vit*Timer.tmod;
		panel.mc._yscale = panel.mc._xscale
		
		/*
		for( var i=0; i<panel.list.length; i++ ){
			var info = panel.list[i]
			var mc = info.mc
			var c = Math.pow((panel.mc._xscale/100),2)
			mc._xscale = mc._yscale = c*info.sc
			var coef = (info.sc/100)
			mc._x = info.x*(1-coef) + info.x*c*coef
			mc._y = info.y*(1-coef) + info.x*c*coef
		}
		*/

		if( panel.mc._xscale < 0 ){
			panel.mc.removeMovieClip();
			panel = null
			//initStep(1)
		}
		
	}
	
	// INTERFACE
	
	function initFaerieInterface(){
		//super.initInterface();
		intFace = new inter.Face(this)
		intFace.init();
		intMana = new inter.Mana(this)
		intMana.init();		
		intLife = new inter.Life(this)
		intLife.init();
		//intDialog = new inter.Dialog(this)
	}
		
	function linkToInterface(){
		intFace.setFaerie(fi);
		intLife.setFaerie(fi);
		intMana.setFaerie(fi);
	}
	/*	
	function speak(txt){
		newDialog(txt)
	}
	*/
	function attachDialog(d){
		d.x = 122
		d.y = 64
		super.attachDialog(d);
		var w = d.skin.pan._width
		d.skin._x = Math.min(190-w*0.5,Cs.mcw-w)
		d.skin.pointe._x = 190-d.skin._x
	}
	
	
	// BOUQUET
	function initBouquet(){
		var mc = game.dm.attach("bouquet",Game.DP_PART)
		mc._x = (game.marginLeft+game.width)*0.5;
		mc._y = game.height*0.5;
		mc._xscale = mc._yscale = 1
		downcast(mc).panel.field.text = level+1
		var i = 0
		var p = downcast(mc).panel
		
		var list = [{sc:p._xscale,x:p._x,y:p._y,mc:p}];
		do{
			var f = Std.getVar( mc, "$f"+i )
			if( f != null ){
				i++;
				list.push({sc:f._xscale,x:f._x,y:f._y,mc:f});
			}else{
				break;
			}
		}while(true)
		bouquet = { mc:mc, vit:0, list:list, trg:100 }	
	}
	
	function moveBouquet(){
		var ds = bouquet.trg-bouquet.mc._xscale
		var lim = 10
		bouquet.vit += Math.min(Math.max(-lim,ds*0.1,),lim)*Timer.tmod
		bouquet.vit *= Math.pow(0.75,Timer.tmod)
		bouquet.mc._xscale += bouquet.vit*Timer.tmod;
		bouquet.mc._yscale = bouquet.mc._xscale
		
		for( var i=0; i<bouquet.list.length; i++ ){
			var info = bouquet.list[i]
			var mc = info.mc
			var c = Math.pow((bouquet.mc._xscale/100),2)
			mc._xscale = mc._yscale = c*info.sc
			var coef = (info.sc/100)
			mc._x = info.x*(1-coef) + info.x*c*coef
			mc._y = info.y*(1-coef) + info.x*c*coef
		}
		if(bouquet.trg==100){
			timer -= Timer.tmod;
			if(timer<0){
				bouquet.trg = 0
			}
		}else{
			if( bouquet.mc._xscale < 0 ){
				bouquet.mc.removeMovieClip();
				initStep(1)
			}
		}	
	}
		
	// ON
	function onNextRemove(){
		//fi.intFace.removeNext();
		intFace.removeNext();
	}
	
	// LEVEL
	function getLevel(){
		return null;
	}
	
	// GET
	function getManaReplenishCoef(){
		
		return game.flColorKill?0:3//Math.round( Math.max( 0, game.colorList.length - Math.min( level*0.05, 5 ) ) )*2	
	}	
	

	
	
//{	
} 






















