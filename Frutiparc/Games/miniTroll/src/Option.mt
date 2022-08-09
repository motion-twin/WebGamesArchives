class Option extends Slot{//}

	
	
	var wc:float
	var waitingKit:int
	
	var round:float;
	var round2:float;
	
	var kList:Array<{>MovieClip,but:Button,bn:Button,fieldName:TextField,fieldInput:TextField}>
	
	var pan:{ >MovieClip, mouse:MovieClip };
	var pil:{ >MovieClip, dm:DepthManager };
	var bg:{ >MovieClip, pale:MovieClip, outside:MovieClip, dm:DepthManager }
	var rList:Array< { >MovieClip, decal:float } >;	
	var pList:Array< { >MovieClip, decal:float, f:bool } >;
		
	var kl:struct.KeyListener;
	

	
	
	function new(){
		dpCursorFront = 6
		dpCursorBack = 4
		super();
	}
	
	function init(){
		super.init();
		initDecor();
		initKits();
		initMouse();
		updateAll();
		
		
		wc = Cm.card.$wind


		//wc = 1
		round = 0;
		round2 = 0;
		
		
		setNight();
		
	}

	function maskInit(){
		super.maskInit()
		initButQuit();
	}
	
	function initKits(){
		
		var name = [ "Gauche ", "Droite ", "Tourner ", "Chute ", "Sort " ]
		kList = new Array();
		for( var i=0; i<5; i++ ){
			var mc = downcast(dm.attach("keyKit",12));
			mc._x = pan._x;
			mc._y = pan._y+i*25;
			mc.fieldName.text = name[i];
			mc.but.onPress = callback(this,pushKit,i)
			
			Mc.makeHint(Std.cast(mc.bn),Lang.commandResume[i],100)
			mc.bn.useHandCursor = false;
			kList.push(mc)
						
		}
		
		
	}
	
	function initMouse(){
		pan.mouse.stop();
		pan.mouse.onPress = callback(this,toggleMouse);
		Mc.makeHint(Std.cast(pan.mouse),Lang.commandResume[5],110)
		
	}
	
	function initDecor(){
		// BG
		bg.dm = new DepthManager(bg)
		

		// PAN
		pan = downcast( dm.attach( "optionPanel", 10 ) )
		pan._x = 20;
		pan._y = 93;
		
		// PIL
		pil = downcast( bg.dm.attach( "mcPillier", 5 ) )
		pil._x = 170;
		
		// RAIGNURE
		rList = new Array();
		pil.dm = new DepthManager(pil);
		
		// POUTRE
		pList = new Array();
		for( var i=0; i<6; i++ ){
			var mc = downcast( bg.dm.attach("mcPoutre",5) );
			//mc._xscale = -100
			mc._y = 10;
			mc.f  = ((i+0.5)/6)%1 > 0.5;		
			pList.push(mc);
		}	
		

		
		
	};
	
	function setNight(){
		var nc = Cm.getNightCoef();

		var coef = Math.abs(nc*2-1)
		//bg.outside.gotoAndStop(string(int(coef*100)+1))
		bg.outside.gotoAndStop(string(int(nc*100)+1))
		
		Mc.setPercentColor( bg, coef*50, 0x000066)
		Mc.setPercentColor( pan, coef*40, 0x000066)
		
	}
	
	function update(){
		super.update();
		
		// RAIGNURE SPAWN
		if( Std.random(int(10/wc)) == 0 ){
			var mc = downcast( pil.dm.attach("mcMillLine",1) );
			mc.decal = 0;
			mc.gotoAndStop(string(Std.random(mc._totalframes)+1));
			mc._x = 0;
			mc._y = 0;
			mc._xscale = 0;

			rList.push(mc);
		}
		
		// RAIGNURE
		for( var i=0; i<rList.length; i++ ){
			var mc = rList[i];
			mc.decal = mc.decal+10*wc*Timer.tmod;
			mc._x = Math.cos(mc.decal/100)*50;
			var prc = Math.abs(Math.cos(mc.decal/100)*100)
			mc._xscale = 120 - prc
			Mc.setPercentColor(mc,mc._xscale,0x000000)
			if( mc.decal > 314 ){
				mc.removeMovieClip();
				rList.splice( i--, 1 );
			}
		}
		
		// POUTRE
		round = (round+6*wc*Timer.tmod)%628
		for( var i=0; i<pList.length; i++ ){
			var a = (round/100)+(i/pList.length)*6.28
			if(a>6.28)a-=6.28;
			
			var mc = pList[i];
			//var frame = Math.abs( 100-Math.round( (a/6.14)*200 ) );
			var frame = (200-Math.round( (a/6.28)*200 )+100)%200
			mc.gotoAndStop(string(frame+1))
			
			Mc.setPercentColor( mc, 30+Math.cos(3.14+a*2)*30, 0x000000 )
			mc._x = pil._x + Math.cos(a)*50;
			
			if( a<3.14 && !mc.f ){
				mc.f = true;
				bg.dm.over(mc)
			}
			if( a>3.14 && mc.f ){
				mc.f = false;
				bg.dm.under(mc)
			}			
		}
		
		// PALE
		round2 = (round2+3*wc*Timer.tmod)%628
		
		var rot = ((round2/100) / 0.0174)%90


		var shadeMax = 30
		var prc = 0
		
		if( rot > 60 && rot < 80 ){
			prc = shadeMax-Math.abs(((rot-60)/20)*2-1)*shadeMax
		}
		
		if( rot > 50 && rot < 80 ){
			if(!bg.pale._visible)bg.pale._visible=true;
			bg.pale._rotation = rot-80
		}else{
			if(bg.pale._visible)bg.pale._visible=false;
		}
		
		Mc.setPercentColor(this, prc, 0x000000 )
		
	}
	
	function updateAll(){
		for( var i=0; i<kList.length; i++ ){
			var mc = kList[i]
			if( i<4 && Cm.pref.$mouse){
				mc.fieldInput.text = "souris "
			}else{
				mc.fieldInput.text = KeyName.LIST[Cm.pref.$key[i]]//KeyManager.getKeyName(Cm.pref.$key[i])
			}
		}
		pan.mouse.gotoAndStop(Cm.pref.$mouse?"2":"1")
		
	}

	function pushKit(i){
		if( waitingKit == null ){
			waitingKit = i;
			var mc = kList[i]
			mc.fieldInput.text = "??? "
			
			kl = new struct.KeyListener();
			kl.onKeyDown = callback(this,keyPress)
			kl.onKeyUp = null
			Key.addListener(kl);

		}
		

		
	}
	
	function keyPress(){
		if( waitingKit != null ){
			Key.removeListener(kl);
			Cm.pref.$key[waitingKit] = Key.getCode();
			//kList[waitingKit].fieldInput.text = string(Cm.pref.$key[waitingKit]);
			waitingKit = null;
			updateAll()
		}
	}
		
	function toggleMouse(){
		Cm.pref.$mouse = !Cm.pref.$mouse
		
		updateAll()
	 }
	
	function kill(){
		Manager.client.saveSlot(1,null);
		super.kill();
	}
	 
//{
}


