class Inter{//}
	
	
	
	static var DP_SLOT = 0;
	static var DP_SELECTION = 1;
	
	static var flWin:bool;
	static var flButWait:bool;
	
	static var outIndex:int;
	static var piouIndex:int;
	static var timeFreeze:int;
	static var endAuto:int;
	static var showArrow:{>MovieClip,id:int};
	
	static var root:{>MovieClip, fieldGoal:TextField, fieldTime:TextField, fieldPiou:TextField, panGoal:MovieClip, panOut:MovieClip };
	static var dm:DepthManager;
	
	static var actionList:Array< { id:int, num:int, mc:MovieClip } >
	static var cid:int
	static var mcSelection:MovieClip;
	static var horloge:{>MovieClip,timer:int,aig:MovieClip,field:TextField};
	
	static var butList:Array<{>MovieClip, glow:MovieClip, id:int, dec:float, ba:float, flRover:bool}>
	
	static function init(){
		root = downcast(Cs.game.mdm.attach("mcInterface",Game.DP_INTER))
		root._x = Cs.mcw-Cs.INTERFACE_MARGIN
		root._y = 10
		dm = new DepthManager(root);
		actionList = new Array();
		
		mcSelection = dm.attach("mcSelection",DP_SELECTION)
		mcSelection._visible = false
		
		flButWait = false;
		cid = null;
		//
		outIndex = 0;
		piouIndex = 0;
		//
		endAuto = null
		//
		initBut();
		updateScorePanel()
		
	}
	
	//
	static function update(){
		
		// BUTTONS
		for( var i=0; i<butList.length; i++ ){
			var mc = butList[i]
			var flGlow = (mc.id==0 && flWin)
			
			if(mc.flRover){
				mc.ba = Math.min(mc.ba+20,100)
			}else{
				mc.ba = Math.max(0, mc.ba-20)
				if(mc.ba==0){
					if(!flGlow )butList.splice(i--,1)
				}				
			}
			if(flGlow)mc.dec = (mc.dec+53)%628;
			var base = 40-Math.cos(mc.dec/100)*40
			//if(Cs.game.piouOut == 0  ) base = 0;
			mc.glow._alpha = base + mc.ba
		}
		
		//
		if(timeFreeze!=null){
			timeFreeze--
			if(root.fieldTime.textColor == 0xB49859){
				root.fieldTime.textColor = 0x856825
			}else{
				root.fieldTime.textColor = 0xB49859
			}
			
			if(timeFreeze==0){
				root.fieldTime.textColor = 0x856825
				timeFreeze = null;
			}
		}else{
			updateTimer();
		}	
		//Log.print(endAuto)
		// CHECK AUTO END
		if( Cs.game.piouOut==0 ){
			if(endAuto!=null){
				if(endAuto--==0){
					Cs.game.initEndPanel();
					Cs.game.mcEndPanel.cross._visible = false;
				}
				
			}else{
				endAuto = 60;
			}
		}
	
		
		
		
		// HORLOGE
		if(horloge!=null){
			horloge.aig._rotation += Manager.speed
			if(horloge.timer--<10*Manager.speed){
				horloge._alpha = (horloge.timer*10)/Manager.speed
				if(horloge.timer==0){
					horloge.removeMovieClip();
					horloge = null
				}
			}
		}
		
		
	}
	
	static function freezeTimer(){
		timeFreeze = 100
		updateTimer();
	}
	
	static function updateTimer(){
		root.fieldTime.text = getTime(Cs.game.btimer*32 )
	}
	
	// BUT
	static function initBut(){
		
		// ACTION
		butList = new Array();
		var bmc = downcast(root)
		var a = [bmc.butExit,bmc.butHelp,bmc.butPause]
		for( var i=0; i<a.length; i++ ){
			var mc = a[i]
			mc.id = i
			mc.onRollOver = callback(Inter,butRollOver,mc)
			mc.onRollOut = callback(Inter,butRollOut,mc)
			mc.onDragOut = callback(Inter,butRollOut,mc)
			mc.onPress = callback(Inter,butPress,mc)
			mc.flRover = false
			mc.ba = 0
			mc.dec = 0
			
			
		}
		
		// PAN
		root.panGoal.onPress = callback(Inter,viewOut)
		root.panOut.onPress = callback(Inter,viewPiou)
		Cs.game.makeHint(root.panOut,Lang.hintGoal[3])
		
		// TIMER
		bmc.butTime.onPress = callback(Cs.game,incMultime,null)
		Cs.game.makeHint( bmc.butTime, Lang.gameButDesc[3] )
		
	}
	
	static function butRollOver(mc){
		
		if(!mc.flRover)pushBut(mc);
		mc.flRover = true;
		Cs.game.addHint(Lang.gameButDesc[mc.id])
	}
	
	static function butRollOut(mc){
		mc.flRover = false;
		Cs.game.removeHint()
	}
	
	static function butPress(mc){
		if(flButWait)return;
		switch(mc.id){
			case 0: // EXIT
				//Cs.game.fastExit();
				Cs.game.initEndPanel();
				break;
			
			case 1: // HELP
				Cs.game.toggleHelp();
				break;
			
			case 2: // PAUSE
				Cs.game.togglePause();
				break;
		}
	}
	
	static function pushBut(mc){
		for( var i=0; i<butList.length; i++ ){
			if( mc == butList[i] ) return;
		}
		butList.push(mc);
			
	}
	
	static function viewOut(){
		var mc = Cs.game.outList[outIndex];
		Cs.game.scrollMapTo( mc._x, mc._y );
		outIndex = (outIndex+1)%Cs.game.outList.length;
	}
	
	static function viewPiou(){
		var piou = Cs.game.pList[piouIndex];
		Cs.game.scrollMapTo( piou.x, piou.y );
		piouIndex = (piouIndex+1)%Cs.game.pList.length;
	}
	
	// ACTIONS
	static function addAction(id,num){
		var o = getActionSlot(id)
		if(o==null){
			o = {
				id:id,
				num:0,
				mc:dm.attach("mcActionSlot",DP_SLOT)
			}
			o.mc.gotoAndStop(string(o.id+1))
			if(!Cs.game.flReplay)o.mc.onPress = callback(Inter,clickAction,o);
			Cs.game.makeHint(o.mc,Lang.actionDesc[id])
			
			actionList.push(o)
			updatePanel();
			
			o.mc._xscale = (Cs.INTERFACE_MARGIN/30)*100
			o.mc._yscale = o.mc._xscale
			
		}
		o.num+=num
		updateActionSlot(o)
		if(mcSelection==null){
			selectAction(o)
		}
	}

	static function getActionSlot(id){
		for( var i=0; i<actionList.length; i++ ){
			var o = actionList[i]
			if(o.id==id)return o;
		}
		return null
	}

	static function updateActionSlot(o){
		if(o.num==0){
			o.mc.removeMovieClip();
			actionList.remove(o)
			updatePanel();
			if(actionList.length==0){
				cid = null
				mcSelection = null//._visible = false;
			}else{
				selectAction(actionList[0])
			}
			
		}else{
			downcast(o.mc).txt = o.num
		}
	}
	
	static function updatePanel(){
		for( var i=0; i<actionList.length; i++ ){
			var o = actionList[i]
			o.mc._y = 51 + i*Cs.INTERFACE_MARGIN// + (Cs.mch-10*Cs.INTERFACE_MARGIN)
			downcast(o.mc).txt = o.num
		}
	}
	
	static function clickAction(o){
		if(!Cs.game.flReplay)Cs.game.history.push([Cs.game.btimer,-1,o.id]);
		selectAction(o)
	}
	
	static function selectAction(o){
		
		//var o = getActionSlot(id);
		//mcSelection._visible = true;
		//mcSelection._y = o.mc._y;

		
		
		if(mcSelection!=null){
			mcSelection.filters = []
		}
		mcSelection = o.mc
		
		
		var m = [
			1,	0,	0,	0,	0,
			0,	1,	0,	0,	0,
			0,	0,	1,	0,	0,
			0,	0,	0,	1,	0 
		]
		Cs.setColorMatrix(mcSelection, m, 50)
		//
		cid = o.id
		
		// CHECK ARROW
		for( var i=0; i<actionList.length; i++ ){
			
			if( o == actionList[i] && i==showArrow.id ){
				showPiou();
				showArrow.removeMovieClip();
				showArrow = null;
			}
		}
		

		
	} 
	
	static function selectActionId(id){
		for( var i=0; i<actionList.length; i++ ){
			var o = actionList[i]
			if(o.id == id){
				
				selectAction(o);
				return true;
			}
		}
		return false;
	}
	
	static function selectNext(){
	
	}
	
	static function launchAction(){
	
	}
	
	static function showAction(id){
		if(showArrow!=null)showArrow.removeMovieClip();
		showArrow = downcast(Cs.game.mdm.attach("mcHelpArrow",Game.DP_INTER))
		showArrow._x = Cs.mcw - (Cs.INTERFACE_MARGIN-2)
		showArrow._y = 60 + (id+0.5)*Cs.INTERFACE_MARGIN
		showArrow.id = id;
		
	}
	
	// HORLOGE
	static function trigHorloge(){
		if(horloge==null)horloge = downcast(dm.attach("mcMultime",DP_SELECTION));
		horloge.field.text = " x"+Manager.speed
		horloge.timer = 40*Manager.speed
		horloge._alpha = 100
		horloge._x = -24
		horloge._y = Cs.mch-24
		
		Lib.cellShadeMc(horloge,2,5)
		/*
		var fl = new flash.filters.GlowFilter();
		fl.blurX = 2
		fl.blurY = 2
		fl.color = 0x000000
		fl.
		horloge.filters = [fl]
		*/
		
	}
	
	// SCORES
	static function updateScorePanel(){
		root.fieldPiou.text = getNum(Cs.game.piouOut)
		
		
		
		var n = Cs.game.piouGoal-Cs.game.piouIn
		var str = getNum(n)
		if( n<0 ){
			str = str.substring(1);
			while(str.length<2)str="0"+str
		}
		var color = 0x6D3D3D;
		Cs.game.makeHint(root.panGoal,Lang.hintGoal[0])
		if(n<=0){
			color = 0x307A30;
			if(n==0)Cs.game.makeHint(root.panGoal,Lang.hintGoal[1])
			if(n<0)Cs.game.makeHint(root.panGoal,Lang.hintGoal[2])
			
		}
		
		root.fieldGoal.textColor = color
		root.fieldGoal.text = str
		
		if(!flWin){
			if(Cs.game.piouGoal<= Cs.game.piouIn){
				flWin = true;
				pushBut(downcast(root).butExit)
			}
		}
		
	}
	
	static function getNum(n){
		var str = string(n);
		while(str.length<2)str="0"+str;
		return str;
	}
	
	static function getTime(t){
		
		var m = int(t/60000);
		var sec = string(int(t/1000)-m*60);
		var min = string(m)
		
		
		
		while(min.length<2)min = "0"+min;
		while(min.length>2)min = min.substring(1);		
		while(sec.length<2)sec = "0"+sec;
		
		
		
		return min+":"+sec
		
	}
	
	// SHOW PIOU
	static function showPiou(){
		for( var i=0; i<Cs.game.pList.length; i++){
			Cs.game.pList[i].point();
		}
	}
	
	
	
//{
}




