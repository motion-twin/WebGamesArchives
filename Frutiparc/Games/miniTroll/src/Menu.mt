class Menu extends Slot{//}
	
	
	
	static var DP_SKY = 	3
	static var DP_HORIZON = 4
	static var DP_HILL = 	5
	
	static var DP_FOREST3 = 6
	static var DP_FOREST2 = 7
	static var DP_FOREST = 	8
	static var DP_MID = 	9
	
	static var DP_TREE = 	10
	static var DP_HERB = 	12
	static var DP_PANEL = 	14
	static var DP_FIRST = 	15
	static var DP_TITLE = 	16
	static var DP_ICON = 	17
	
	
	var panList:Array<{>MovieClip,fade:float}>
	var plan:Array<{>MovieClip,c:float}>
	var cloudList:Array<{>MovieClip,c:float,w:float,x:float,y:float}>
	var titleFadeList:Array<MovieClip>
	var title:MovieClip
	var decor:MovieClip;
	
	var xm:float;
	var oxm:float;
	var nc:float	// night coef
	var wc:float	// wind coef
	
	var bag:MovieClip;
	var dungeon:MovieClip;
	var forest:MovieClip;
	var frog:MovieClip;
	var fountain:MovieClip;
	var windMill:MovieClip;
	var rainbow:MovieClip;
	var tree:MovieClip;
	var house:MovieClip;
	
	var sky:MovieClip;
	
	var msgIcon:{>MovieClip,decal:float}
	var panLog:{>MovieClip,field:TextField,up:Button,down:Button,inside:MovieClip,out:Button}
	
	var di:{>MovieClip, day:MovieClip, game:MovieClip, dm:DepthManager}
	
	var fdm:DepthManager;
	var herb:MovieClip;
	
	function new(){
		dpCursorBack = 9
		dpCursorFront = 11
		super()
		panList = new Array();
	}
		
	function init(){
		super.init();
		oxm = _xmouse;

		nc = Cm.getNightCoef()
		wc = Cm.card.$wind
		
		titleFadeList = new Array();
		
		initDecor();
		
		if( Manager.CHEAT > 0 )initDebugInterface();
		setNight()
		
		
		var fi = Cm.getCurrentFaerie();
		if(fi != null){
			initCursor(fi,dm.empty( DP_TREE ));
		}
		initElements()
		
		//
		Cm.save()
		//
		

		//
		Manager.flNewDay = false;
		Manager.flFirst = false;
	}
	
	function maskInit(){
		super.maskInit();
		initEvents();
		if( Manager.msg.list.length > 0 )initMsgIcon();
		
		// FAERIE AMBIENT
		if( cursor.fi!= null ){
			if( Manager.flNewDay ){
				cursor.fi.react(Lang.SENT_NEW_DAY)
			}else if( Manager.flFirst){
				cursor.fi.react(Lang.SENT_ENTER_MENU_FIRST)
			}else{
				cursor.fi.react(Lang.SENT_ENTER_MENU)
			}
		}
				
		
	};
	
	function initDecor(){
		
		plan = new Array();
		
		// HORIZON
		sky = downcast(dm.attach("decorPlanSky",DP_SKY))
		
		// HORIZON
		var mc = downcast(dm.attach("decorPlanHorizon",DP_HORIZON))
		mc.c = 0.25
		rainbow = downcast(mc).rainbow
		plan.push(mc)
		
		// HILL
		mc = downcast(dm.attach("decorPlanHill",DP_HILL))
		mc.c = 0.35
		dungeon = downcast(mc).dungeon
		windMill = downcast(mc).windMill
		plan.push(mc)
		
		
		// FOREST 3
		mc = downcast(dm.attach("decorPlanForest3",DP_FOREST3))
		mc.c = 0.45
		plan.push(mc)
		
		// FOREST 2
		mc = downcast(dm.attach("decorPlanForest2",DP_FOREST2))
		mc.c = 0.52
		plan.push(mc)
		
		// FOREST
		mc = downcast(dm.attach("decorPlanForest",DP_FOREST))
		mc.c = 0.9
		plan.push(mc)
		forest = downcast(mc).forest
		fountain = downcast(mc).fountain
		house = downcast(mc).house
		
		// MID
		mc = downcast(dm.attach("decorPlanMid",DP_MID))
		mc.c = 1.1
		tree = downcast(mc).tree
		plan.push(mc)

		
		// TREE
		mc = downcast(dm.attach("decorPlanTree",DP_TREE))
		mc.c = 1.5
		bag = downcast(mc).bag
		plan.push(mc)
		
		// HERBE
		mc = downcast(dm.attach("decorPlanHerb",DP_HERB))
		mc.c = 1.8
		plan.push(mc)
		fdm = new DepthManager(mc)
		herb = Std.cast(mc)
		
		// FIRST
		mc = downcast(dm.attach("decorPlanFirst",DP_FIRST))
		mc.c = 3.2
		plan.push(mc)
		frog = downcast(mc).frog

		
		// NUAGE
		var max = 8
		cloudList = new Array();
		for( var i=0; i<max; i++ ){
			var c = i/max
			
			for( var n=0; n<(max-i); n++ ){
				var cl = downcast(dm.attach("cloud",DP_SKY))
				cl.w = 50+c*100
				cl.c = c*0.2
				
				cl.x = Math.random()*(Cs.mcw+cl.w)-cl.w
				cl.y = (170 - c*40)+(Math.random()*2-1)*c*20
				
				cl._x = cl.x
				cl._y = cl.y
				cl._xscale = cl.w
				cl._yscale = cl.w
				
				cl.gotoAndStop(string(1+Std.random(cl._totalframes)))
				
				Mc.setPercentColor(cl,80*(1-c),0x8EB3D7)
				Mc.modColor(cl,1,-Math.abs(nc-0.5)*130)
				
				cloudList.push(cl)
				
			}			
		}
		
		
	}
	
	function initElements(){
		var me = this;
		
		// BAG
		if(Cm.card.$bag>0){
			bag.gotoAndStop(string(Cm.card.$bag))
		}else{
			bag.stop();
			bag._visible = false;
		}
		
		
		//DONJONS
		if( Cm.card.$dungeon.$f ){
			dungeon.gotoAndStop(string(Cm.card.$dungeon.$lvl+1))
		}else{
			dungeon._visible = false;
			dungeon.stop();
		}


		// FOUNTAIN
		fountain.gotoAndStop("1")

		// FROG
		if( !Cm.card.$frog ){
			frog.stop();
			frog._visible = false;
		}
		
		// RAINBOW
		if( !Cm.card.$rainbow.$f ){
			rainbow._visible = false;
		}	

		// TREE
		var frame = 1
		for( var i=0; i<Cs.treeLimit.length; i++ ){
			if( Cm.card.$stat.$treeMax > Cs.treeLimit[i] )frame++;
		}
		tree.gotoAndStop(string(frame))
		
		// HOUSE
			
		
	}
	
	function initEvents(){
		var me = this;
		
		// BAG
		initTitleBut(bag,"Inventaire ")
		initElementBut(bag,"inventory")
		
		
		//DONJONS
		initTitleBut(dungeon,"Donjon ")
		if( Cm.card.$key > 0 ){
			initElementBut(dungeon,"baseDungeon")
		}else{
			initElementButError(dungeon,0)
		}
			
		// FOREST
		initTitleBut(forest,"Foret enchantee")
		initElementBut(forest,"baseForest")
		
		// WINDMILL
		initTitleBut(windMill,"Moulin ")
		initElementBut(windMill,"option")

		// FOUNTAIN
		initTitleBut(fountain,"Bassin aux fees ")
		if( Cm.card.$pond.$fs != null ){
			if( Cm.card.$current == null ){
				initElementBut(fountain,"baseFountain")	
				fountain.gotoAndStop("2")
			}else{
				initElementButError(fountain,1)
			}
		}else{
			fountain.useHandCursor = false;
		}
		
		// FROG
		initTitleBut(frog,"Ornegon ")
		if( Cm.card.$current != null ){
			initElementBut(frog,"frog")	
		}else{
			initElementButError(frog,2)
		}		

		// RAINBOW
		initTitleBut(rainbow,"Arc en ciel ")
		initElementBut(rainbow,"baseRainbow")
		
		// TREE
		initTitleBut(tree,"Arbre creux")
		initElementBut(tree,"baseTree")
		
		// HOUSE
		initTitleBut(house,"Cabane de Gromelin")
		initElementBut(house,"mission")		
		
	}
		
	function removeEvents(){
		bag.onPress = null;
		dungeon.onPress = null;
		forest.onPress = null;
		fountain.onPress = null;
		frog.onPress = null;
		windMill.onPress = null;
		rainbow.onPress = null;
		tree.onPress = null;
		
		bag.useHandCursor = false;
		dungeon.useHandCursor = false;
		forest.useHandCursor = false;
		fountain.useHandCursor = false;
		frog.useHandCursor = false;
		windMill.useHandCursor = false;
		rainbow.useHandCursor = false;
		tree.useHandCursor = false;
		
	}

	function initTitleBut(mc,name){
		mc.onRollOver = callback(this,setTitle,name)
		mc.onRollOut = callback(this,removeTitle,name)
		mc.onDragOut = callback(this,removeTitle,name)

		//Mc.makeHint(mc,name,null)
	}
	
	function initElementBut(mc,link){
		var me = this;
		mc.onPress = fun(){
			var x = mc._x + mc._parent._x
			var y = mc._y + mc._parent._y
			Manager.fadeSlot(link,x,y)
			Manager.slot.postInit();
			me.removeEvents();
		}	
	}
	
	function initElementButError(mc,id){
		var me = this;
		//mc.gotoAndStop(string(id+1))
		mc.onPress = fun(){
			me.setError(id)
		}	
	}
	
	function setTitle(name){
		title = dm.attach("mcMenuTitle",DP_TITLE)
		downcast(title).field.text = name
	}
	
	function removeTitle(name){
		titleFadeList.push(title)
		title = null
	}	
	
	function setNight(){
		var c = Math.abs(nc-0.5)*2
		for( var i=0; i<plan.length; i++ ){
			var mc = plan[i]
			var prc = Math.max(80-mc.c*30,30)*c
			Mc.setPercentColor(mc,prc,0x274C76)
			//Mc.setPercentColor(mc,prc,0x162D43)
		}
		
		//
		sky.gotoAndStop(string(int(nc*100)+1))

	}
	
	function initMsgIcon(){
		msgIcon = downcast(dm.attach("mcMailIcone",DP_ICON))
		msgIcon.decal = 0
		msgIcon._x = Cs.mcw
		
		msgIcon.onPress = callback(this,displayLog)
		
	}
	//
	function update(){
		super.update();
		var ma =0.3
		xm = Math.min(Math.max(0,_xmouse*(1+2*ma)-Cs.mcw*ma),Cs.mcw)
		moveDecor()
		moveCursor()
		movePart();
		oxm = xm;
		
		// MSG BLINK
		if(!Manager.msg.flView){
			msgIcon.decal = (msgIcon.decal+40)%628;
			Mc.setPercentColor( msgIcon, 50+Math.cos(msgIcon.decal/100)*50, 0xFFFFFF );
		}
		
		// PAN
		for( var i=0; i<panList.length; i++ ){
			var mc = panList[i]
			if( mc.fade == null ){
				var dx = Math.abs(herb._xmouse - mc._x)
				var dy = Math.abs(herb._ymouse - mc._y)
				if( dx > 70 || dy >70 ){
					mc.onPress = null
					mc.fade = 10
				}
			}else{
				mc.fade -= Timer.tmod;
				mc._alpha = mc.fade*10;
				if(mc.fade<0){
					mc.removeMovieClip();
					panList.splice(i--,1)
				}
			}
		}
		
		// TITLEFADE
		for( var i=0; i<titleFadeList.length; i++ ){
			var t = titleFadeList[i]
			t._alpha *= 0.5
			if( t._alpha < 2 ){
				t.removeMovieClip();
				titleFadeList.splice(i--,1)
			}
		}
		
		// AMBIENT DIALOG
		if( Std.random(int((Cs.ambientRate*2)/Timer.tmod))==0 ){
			cursor.fi.react(Lang.SENT_MENU_AMBIENT)
		}
		
		
	}
	//
	function moveDecor(){
		
		
		for( var i=0; i<plan.length; i++ ){
			var mc = plan[i]
			mc._x = -xm*mc.c
			
		}
		for( var i=0; i<cloudList.length; i++ ){
			var mc = cloudList[i]
			mc.x += mc.c*wc*3*Timer.tmod
			var m  = 100
			if( mc.x > Cs.mcw+m ){
				mc.x = -(mc.w+m)
			}
			mc._x = (0-xm)*mc.c +mc.x
		}
		
		// WINDMILL
		downcast(windMill).w.w._rotation += wc*2
		
	}
	
	function moveCursor(){
		
		
		var dx = xm-oxm
		cursor.x -=  dx*1.3
		super.moveCursor();
	}
	
	function movePart(){
		
		var dx = xm-oxm
		for( var i=0; i<partList.length; i++ ){
			var p = partList[i]
			p.x -=  dx*1.3	
		}
		super.movePart();		
	}
	
	function displayLog(){
		Manager.msg.flView = true;
		Mc.setPercentColor( msgIcon, 0, 0xFFFFFF );
		
		panLog = downcast(dm.attach("mcMail",DP_ICON))
		panLog._x = Cs.mcw*0.5
		panLog._y = Cs.mch*0.5
		
		var str = ""
		var day = null
		for(var i=0; i<Manager.msg.list.length; i++ ){
			var o = Manager.msg.list[i]
			var s = ""
			if(o.d != day ){
				s += "<b>Jour "+o.d+"</b> :\n";
				day = o.d
			}
			s += o.txt+"\n"
			str += s
		}
		panLog.field.htmlText = str
		panLog.out.onPress = callback(this,removeLog)
		panLog.inside.onPress = fun(){}
		panLog.inside.useHandCursor = false;
		msgIcon._visible = false;
		
		if( panLog.field.maxscroll > 1 ){
			var f = panLog.field
			panLog.up.onPress = fun(){ f.scroll -= 1 }
			panLog.down.onPress = fun(){ f.scroll += 1 }
		}else{
			panLog.up._visible = false
			panLog.down._visible = false
		}
	}

	function removeLog(){
		panLog.removeMovieClip();
		msgIcon._visible = true;
		
	}
	
	// DIALOG
	function attachDialog(d){
		d.x = 5 + 44
		d.y = 5 
		super.attachDialog(d);
		d.skin.pointe._visible = false
		d.setPic(cursor.fi)
	}
	
	//
	function setError(id){
		var pan = downcast(fdm.attach("mcEnterError",DP_PANEL))
		var m = 55
		pan._x = Cs.mm(m,_xmouse,Cs.mcw-m)-herb._x
		pan._y = Cs.mm(m,_ymouse,Cs.mch-m)
		pan.gotoAndStop(string(id+1))
		/*
		pan.onRollOut(){
			//pan.removeMovieClip();
		}
		pan.onDragOut = pan.onRollOut
		*/
		var me = this;
		pan.onPress = fun(){
			me.panList.remove(pan)
			pan.removeMovieClip();
		}
		
		
		panList.push(pan)
	}
	
	// DEBUG    
	function initDebugInterface(){
		di = downcast( dm.empty(DP_ICON) )
		di.dm = new DepthManager(di);
		//di._x = 4;
		di._y = 4;
		
		var list = [0,5]
		if( Manager.CHEAT > 1 ){
		
			list = [0,1,2,3,4,5]
		
			if( Cm.card.$current==null ){
				list.push(10);
				list.push(11);
				if( Cm.card.$pond.$fs != null ){
					list.push(12)
				}			
			}
			if( Cm.card.$frog == false )list.push(13);
			if( Cm.card.$rainbow.$f == false )list.push(14);
		}
		
		for( var i=0; i<list.length; i++ ){
			var mc = di.dm.attach("debugButton",1)
			mc.onPress = callback(this,debugAction,list[i])
			mc.gotoAndStop(string(list[i]+1))
			mc._x = 4+i*18
		}
	}	
	
	function debugAction(id){
	
		var flReset = false;
		var c = Cs.getKeyCoef()

		switch(id){
			case 0:
				Cm.card.$time.$s += Cs.sDay*c;
				flReset = true
				break;
			case 1:
				var list = Cm.card.$stat.$game
				for( var i=0; i<list.length; i++ ){
					list[i]+=1*c
				}
				for( var i=0; i<50; i++ ){
					Cm.card.$stat.$run+= int(Math.pow(i,2))
				}
				break;
		
			case 2:
				Cm.incKey(c);
				break;
			case 3:
				initItemSelector();
				break;
			case 4:
				if(Manager.impList==null)Manager.impList = new Array();
				Manager.impList.push(int(Cs.mm(0,c-1,4)))
				break;
			case 5:	// RESET
				if(Client.STANDALONE){
					Cm.card = null
					downcast(Cm.so.data).fruticard[0] = null
				}else{
					Manager.client.slots[0] = null
				}
				flReset  = true;
				break;					
			case 10:
				var fs = Cm.genFaerieSeed()
				Cm.card.$current = Cm.card.$faerie.length;
				Cm.card.$faerie.push(fs);
				flReset = true;
				
				break;
			case 11:
				var fs = Cm.getBarbarellaSeed();

				Cm.card.$current = Cm.card.$faerie.length;
				Cm.card.$faerie.push(fs);

				flReset = true;
				
				break;
			case 12:
				Cm.freeFaerie();
				flReset = true;
				break;
			case 13:
				Cm.freeOrnegon();
				flReset = true;
				break;
			case 14:
				//Cm.card.$rainbow.$f = true;
				Cm.addRainbow()
				flReset = true;
				break;					
		}
		if(flReset){
			Cm.save()
			Manager.reStart();
		}
		
	}
	
	function initItemSelector(){
		var mc = downcast(dm.attach("mcItemSelector",DP_PANEL))	
		mc.dm = new DepthManager(mc);
		
		var max = 13
		var m = 28
		var s = (Cs.mcw-2*m)/(max-1)
		var x = 0
		var y = 0;
				
		
		for( var i=0; i<400; i++ ){
			var it = Item.newIt(i)
			if( it != null ){
				var pic = it.getPic(mc.dm,1)
				if( pic._width>0 ){
					pic._x = m+x*s
					pic._y = m+y*s
					pic._xscale = s
					pic._yscale = s
					
					x++
					if(x==max){
						x = 0
						y++
					}
					
					pic.onPress = callback(this,getItem,i,mc)
				}
			}
		}		
	}
	
	function getItem(type,panel){
		Cm.getItem(type)
		var it = Item.newIt(type)
		if( it.flGeneral ){
			it.grab();
		}else{
			
			var list = Cm.card.$inv
			var index = null
			for( var i=0; i<Cs.bagLimit[Cm.card.$bag]; i++ ){
				if(list[i]==null){
					index = i
					break;
				}
			}
			if( index != null ){
				Manager.log("Ajout de "+it.getName()+" !")
				list[index] = type;
			}		
		}
		if(!Key.isDown(Key.CONTROL))panel.removeMovieClip();
	}
	
	
	
	
//{
}	















