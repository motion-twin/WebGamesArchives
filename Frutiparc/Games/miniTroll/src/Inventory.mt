class Inventory extends Slot{//}
	
	
	
	static var DP_FRONT = 	12;
	
	static var DP_CURSOR = 	11;
	static var DP_HAND = 	15;
	static var DP_MSG = 	9;
	static var DP_BG = 	7;
	static var DP_SLOT2 = 	6;
	static var DP_SLOT = 	4;
	

	static var MARGIN_UP = 20
	static var SLOT_SIZE = 32
	static var INV_WIDTH = 154
	static var INV_HEIGHT = 140
	static var INV_SHAPE = [0,2,3,4,3]
	//			0,4,6,8,9

	static var SECTION = ["voir les caractéristiques","voir les sortilèges","voir l'équipement","voir la santé"]
	
	// CONSTANTES
	var smx:float;
	var smy:float;
	var hand:inv.Item;
	
	// VARIABLES
	var flNoExtraDisplay:bool;
	var faerieIntMode:int;
	
	var extraList:Array<int>;
	var extraArrowList:Array<MovieClip>;
	var extraSlot:Array<inv.Slot>;
	var extraIndex:int;
	var extraMax:int;
	
	//MC
	var faeriePanel:{>MovieClip,dm:DepthManager};
	var facePanel:{>MovieClip,pic:MovieClip,swap:MovieClip,quit:MovieClip,level:{>MovieClip,field:TextField}}
	var msgPanel:{>MovieClip, field:TextField, fieldTitle:TextField, symbol:MovieClip };
	
	var mcStar:{>MovieClip,sub:MovieClip,field:TextField}
	
	function new(){
		dpCursorFront = 6
		dpCursorBack = 4
		super();
	}
	
	function init(){
		super.init();
		initSlot();
		initDecor();
		updateCurrent();
		
		initTrashcan();
		
		//setExtraList([30,305,307,322,323])
	}
	
	function postInit(){
		super.postInit();
		if(!flNoExtraDisplay)initExtraDisplay();
	}
	
	function maskInit(){
		super.maskInit();
		initButQuit();
	}
		
	function updateCurrent(){

		if(cursor!=null){
			removeCursor();
			removeFaeriePanel();
		}
		
		var fi = Cm.getCurrentFaerie();
		
		if( fi != null ){
			//Log.trace("initCursor!")
			initCursor(fi,dm.empty( DP_CURSOR ));
			cursor.x = _xmouse;
			cursor.y = _ymouse;
			initFaeriePanel();
		}
	}

	function updateFace(){
		var fi = Cm.getCurrentFaerie();
		cursor.setInfo(fi)
		
		// REMPLACE LE SKIN DU CURSOR
		cursor.skin.removeMovieClip();
		cursor.birth(dm.empty( DP_CURSOR ))
		cursor.showStatus();
		
		// REDRAW FACE
		setFaerieFace(fi)
	}
		
	function initSlot(){
		
		var list = Cm.card.$inv
		var bag = Cm.card.$bag
		//var bag = 1
		//var list = [0,null,null,null]
		
		var max = Cs.bagLimit[bag]
		
		var xMax = INV_SHAPE[bag]//Math.ceil( Math.sqrt(list.length) )
		var yMax = Math.ceil(max/xMax)//Math.floor( Math.sqrt(list.length) )
		
		var x = 0
		var y = 0
		
		smx = (INV_WIDTH-xMax*SLOT_SIZE)*0.5
		smy = MARGIN_UP + (INV_HEIGHT-yMax*SLOT_SIZE)*0.5
		
		for( var i=0; i<max; i++ ){
			
			// SLOT
			var slot = newSlot(getSlotX(x),getSlotY(y));
			slot.index = i;
			//
			var n = list[i]		
			if( n!=null  ){
				slot.addItem( n, null )
			}
			//
			x++
			if(x==xMax){
				y++;
				x = 0
			}			
		}
	}
	
	function newSlot( x, y ):inv.Slot{
		var slot = downcast(dm.attach("invSlot",DP_SLOT))
		slot.inv = this;
		slot._x = x
		slot._y = y
		slot._xscale = SLOT_SIZE
		slot._yscale = SLOT_SIZE
		return slot
	}
	
	function initDecor(){
		// FRONT
		dm.attach("invFront",DP_FRONT);
		
		// MSG PANEL
		msgPanel = downcast(dm.attach("msgPanel",DP_MSG));
		msgPanel._y = Cs.mch -60
		msgPanel.stop();
		
		// MSG PANEL
		dm.attach("invBg",DP_BG);
		
 	}
	
	function initTrashcan(){
		
		var mc = dm.attach("mcTrashcan",DP_FRONT)
		
		mc.onPress  = callback(this,trash)
		mc.onRollOver = fun(){
			mc.gotoAndStop("2")
		}
		mc.onRollOut = fun(){
			mc.gotoAndStop("1")
		}
		mc.onDragOut = mc.onRollOut;
		
		mc._y = Cs.mch
		mc.stop()
		//Manager.log(mc)
	}
	
	function update(){
		super.update();
		moveHand();
		moveCursor()
		movePart();

		if(extraList!=null && butQuit !=null){
			var flDone = true;
			for( var i=0; i<extraList.length; i++ ){
				if(extraList[i] != null ){
					flDone = false
					break;
				}
			}

			if(flDone){
				if( butQuit.onPress == null ){
					butQuit.removeMovieClip();
					initButQuit();
				}
			}else{
				butQuit.onPress = null
				butQuit.onRollOver = null
				butQuit.onRollOut = null
				butQuit.onDragOut = null
				Mc.makeHint( butQuit, "Rangez vos nouveaux objets avant de partir!", 120 )
			}
		}
		
		
	}
	
	
	// EXTRA LIST
	function setExtraList(list){
		
		extraList = list;
		extraMax = int( Math.min( list.length, 4 ) )
		extraIndex = 0
		extraSlot = new Array();
		for( var i=0; i<extraMax; i++ ){
			var c = i/(extraMax-1)
			var x = INV_WIDTH*0.5 + (i-(extraMax-1)*0.5) * SLOT_SIZE
			var y = 158;
			var slot = newSlot(x,y)
			slot.flExtra = true;
			slot.addItem( list[extraIndex+i], null )
			slot.index = i
			extraSlot.push(slot)
		}
		extraArrowList = new Array();
		for( var i=0; i<2; i++ ){
			var sens = i*2-1
			var mc = initExtraArrowBut(sens)
			extraArrowList.push(mc)
		}		
		updateExtraList()
		
		butQuit.onPress = null;
		
		
	}
	
	function initExtraArrowBut(sens){
		var mc = dm.attach("butExtraArrow",DP_FRONT);
		mc._x = INV_WIDTH*0.5 + (5+(extraMax*0.5)*SLOT_SIZE)*sens;
		mc._y = 158;
		mc._xscale = 100*sens;
		var me = this;
		mc.onPress = fun(){
			if( me.hand == null ){
				me.incExtraIndex(sens);
			}
		}
		return mc;
	}
	
	function updateExtraList(){
		for( var i=0; i<extraMax; i++ ){
			var slot = extraSlot[i]
			slot.removeItem();
			var id = extraList[extraIndex+i]
			if(id!=null)slot.addItem( id, null );
			
		}
		extraArrowList[0]._visible = extraIndex > 0
		extraArrowList[1]._visible = extraIndex < extraList.length-extraMax
	}
	
	function incExtraIndex(inc){
		extraIndex = int(Cs.mm(0,extraIndex+inc,extraList.length-extraMax))
		//Manager.log(">"+extraIndex+"("+inc+")")
		updateExtraList();
	}
	
	// EXTRA DISPLAY
	function initExtraDisplay(){
		
		var mc = null;
		
		for( var i=0; i<5; i++ ){
			mc =  downcast(dm.attach("invSmallSlot",DP_SLOT))
			mc._x = 85+i*15//20
			mc._y = 168
			mc.gotoAndStop("3")
			if(Cm.card.$diam > i ){
				mc.sub.gotoAndStop( string(1+i) )
			}else{
				mc.sub.stop();
				mc.sub._visible = false;
			}
		}
		
		// KEY
		mc = downcast(dm.attach("invSmallSlot",DP_SLOT))
		mc._x = 19
		mc._y = 168
		mc.gotoAndStop("1")
		if( Cm.card.$key > 0 ){
			mc.field.text = Cm.card.$key
		}else{
			mc.sub._visible = false;
		}
		
		// STAR
		mcStar = downcast(dm.attach("invSmallSlot",DP_SLOT))
		mcStar._x = 54
		mcStar._y = 168
		mcStar.gotoAndStop("2")
		updateStar();
	}
	
	function updateStar(){
		if( Cm.card.$star > 0 ){
			mcStar.sub._visible = true;
			mcStar.field.text = string(Cm.card.$star)
		}else{
			mcStar.sub._visible = false;
		}
	}
	
	// HAND
	
	function moveHand(){
		if( hand!=null ){
			var dx =  _xmouse - hand._x
			var dy =  _ymouse - hand._y
			var c = 0.3
			hand._x += dx*c*Timer.tmod
			hand._y += dy*c*Timer.tmod
		}	
	}
	
	function setHand(it:inv.Item){		
		hand = downcast( dm.attach( "invHand", DP_HAND ) );
		hand.inv = this;
		hand._x = it._x;
		hand._y = it._y;
		hand._xscale = SLOT_SIZE;
		hand._yscale = SLOT_SIZE;

		hand.index = it.index;	
		hand.flExtra = it.flExtra;
		hand.faerie = it.faerie;
		hand.addItem(it.item.type,null)
		//Manager.log( hand.item )
	}
	
	function clearHand(){
		hand.removeMovieClip();
		hand = null;
	}
	
	function trash(){
		if( hand.item.type == 30 && hand.item.fi!=null )return;
		hand.removeItem();
		hand.addItem(null,hand)	
		clearHand();

	}
	
	
	// FAERIE PANEL
	
	function initFaeriePanel(){
		
		// FACE
		facePanel = downcast(dm.attach("invFace",DP_SLOT2))
		facePanel._x = 200;
		facePanel._y = 41;
		facePanel.pic.onPress = callback(this,giveItem)//func
		
		
		
		var fi = Cm.getCurrentFaerie();
		setFaerieFace(fi)
		Mc.makeHint(facePanel.pic,"Pour nourrir une fée, amenez des aliments ici",100)
		
		
		// LEVEL
		facePanel.level.field.text = string(fi.fs.$level+1)
		var prc = Math.round((fi.fs.$exp/fi.getNextExpLimit())*1000)/10
		Mc.makeHint(facePanel.level,"niveau "+string(fi.fs.$level+1)+" ("+Math.min(prc,99.9)+"%)",null)
	
		// BUTTON
		var me = this;
		facePanel.quit.gotoAndStop("6")
		facePanel.quit.onPress = fun(){
			me.tryToWithdraw();
		}
		Mc.makeHint(facePanel.quit,"libérer la fée",null)
		
		//
		initFaerieIntMode(0)
		facePanel.swap.onRollOut();
		Mc.makeHint(facePanel.swap,"panneau suivant",null)
		//
		
	};
	
	function setFaerieFace(fi){
		Mc.setPic(facePanel.pic,fi.skin)
		var msg = new Msg(fi.getMsgTaste());//new Msg("Elle aime les biscotte et le thon")
		
		msg.type = 1 
		msg.title = fi.fs.$name
		trgMsg(facePanel.pic,msg)	
	}
	
	function removeFaeriePanel(){
		facePanel.removeMovieClip();
		faeriePanel.removeMovieClip();
	}
	
	function initBut(mc:MovieClip){
		var f0 = mc.onRollOver;
		mc.onRollOver = fun(){
			mc.gotoAndStop( string(mc._currentframe+10) )
			f0();
		}
		var f1 = mc.onRollOut;
		mc.onRollOut = fun(){
			mc.gotoAndStop( string(mc._currentframe-10) )
			f1();
		}
		mc.onDragOut = mc.onRollOut
	}	
	
	function initFaerieIntMode(n:int){
		//Manager.log( ">"+n )
		faerieIntMode = n
		
		// SWAP BUTTON
		var me = this;
		var next = (n+1)%4
		facePanel.swap.gotoAndStop(string(next+1))
		facePanel.swap.onPress = fun(){
			if( me.hand == null ){
				me.initFaerieIntMode(next);
			}
		}

		trgMsg(facePanel.swap,new Msg(SECTION[next]))
		initBut(facePanel.swap)
		facePanel.swap.onRollOver()
		removeHint(facePanel.swap)
		// FAERIE PANEL
		if(faeriePanel!=null)faeriePanel.removeMovieClip();
		faeriePanel = downcast(dm.empty(DP_SLOT))
		faeriePanel.dm = new DepthManager(faeriePanel)

		var fi = Cm.getCurrentFaerie()
		switch(faerieIntMode){
			case 0: // CARACS
				var cl = fi.carac;
				for( var i=0; i<6; i++ ){
					var bar = faeriePanel.dm.attach("invFaerieBar",1)
					bar._x = 173;
					bar._y = 97+i*14;
					bar.gotoAndStop(string(i+1))
					var list = new Array();
					for(var p=0; p<Cs.caracMax; p++){
						var mc =Std.attachMC(bar,"invFaerieBarPoint",100-p)
						
						mc._x = 9+p*6
						if(p<cl[i]){
							mc.gotoAndStop("2");
						}else{
							mc.stop();
						}
						list.push(mc)
					}
					trgMsg(bar,new Msg(Lang.caracResume[i]))
					Mc.makeHint(bar,Lang.caracName[i],null)
					downcast(bar).list = list;
				}
				break;
			case 1: // MAGIE
				var list = fi.spell
				var i = 0
				for( var y=0; y<5; y++ ){
					for( var x=0; x<4; x++ ){
						var ball= faeriePanel.dm.attach( "spellBall", 1 )
						ball._x = 175+x*17
						ball._y = 98+y*17
						//
						var t = list[i]
						if( t != null ){
							ball.stop();
							downcast(ball).symbol.gotoAndStop(string(t+1));
							
							// MSG
							var spell = Spell.newSpell(t)
							/*
							var msg = new Msg(spell.getDesc())
							msg.type = 1
							msg.title = spell.getName()+":"
							*/
							trgMsg(ball,spell.getMsg())
							
							
							
							
						}else{
							ball.gotoAndStop("2")
						}
						//
						i++
					}
					
				}

				
				
				break;
			case 2: // INVENTAIRE
				var list = fi.fs.$inv
				var x = 0
				var y = 0
				var by = 130-Math.floor( fi.fs.$bagMax/2 )*16

				for( var i=0; i<fi.fs.$bagMax; i++ ){
					
					// SLOT
					var slot:inv.Slot = downcast(faeriePanel.dm.attach( "invSlot", 1 ))
					slot.inv = this;
					slot._x = 184+x*32
					slot._y = by+y*32
					slot._xscale = SLOT_SIZE;
					slot._yscale = SLOT_SIZE;
					slot.faerie = fi;
					slot.index = i;
					//
					var t = list[i]		
					if( t!=null  ){
						slot.addItem(t,null)
					}
					x++
					if(x==2){
						y++;
						x = 0;
					}
				}
				break;
			case 3: // STATE
				
				
				// HEALTH
				var max = fi.carac[Cs.LIFE]
				for( var i=0; i<max; i++ ){
					var mc =  downcast(faeriePanel.dm.attach( "mcHeart", 1 ))
					mc.bg.stop();
					mc._x = 196 + (i-(max-1)*0.5)*9;
					mc._y = 92;
					mc._xscale = mc._yscale = 60;
					if( i < fi.fs.$life ){
						mc.gotoAndStop("2")
					}else{
						mc.gotoAndStop("1")
					}
				}
				
				// SANTE
				var mc = downcast(faeriePanel.dm.attach( "mcManPower", 1 ))
				mc._x = 200
				mc._y = 137
				mc.h0.h._rotation = 180 + (fi.fs.$hunger/20)*180
				mc.h1.h._rotation = 180 + (fi.fs.$moral/20)*180
				
				Mc.makeHint( mc.h0, " faim ", null )
				Mc.makeHint( mc.h1, " moral ", null )
				
				
				break;					
		}
	}
	
	function giveItem(){
		if( hand.item.flUse ){
			var tp  = hand.item.type
			hand.item.use( Cm.getCurrentFaerie() );
			
			//Manager.log("hand.item.type("+hand.item.type+")")
			
			if( tp >= 300 ){
				var food:it.Food = downcast(hand.item)
				for( var i=0; i<14; i++ ){
					var p = newPart("partFood",DP_FRONT)//(dm.attach("partFood",DP_FRONT))
					var a = Math.random()*6.28
					var ca = Math.cos(a)
					var sa = Math.sin(a)
					var sp = 1+Math.random()*4
					p.x = _xmouse + ca*sp;
					p.y = _ymouse + sa*sp;
					p.vitx = ca*sp
					p.vity = sa*sp
					p.flGrav = true;
					p.weight = 0.2+Math.random()*0.2
					p.timer = 8+Math.random()*14
					p.skin.gotoAndStop(string(food.id+1))
					var mc = downcast(p.skin).p
					mc.gotoAndStop(string(Std.random(mc._totalframes)+1))
					p.init();
				}
			}
			
			
			
			var type = hand.item.type
			hand.removeItem();
			hand.addItem(type,hand)	
			if(hand.item==null)clearHand();
			
			initFaerieIntMode(3)
			facePanel.swap.onRollOut()			
			//eat(hand.item.type)

			

			
		}	
	}
	
	
	// GET
	function getSlotX(x){
		return  smx + (x+0.5)*SLOT_SIZE
	}
	
	function getSlotY(y){
		return  smy + (y+0.5)*SLOT_SIZE
	}	
	
	//
	function tryToWithdraw(){
		var fi = Cm.getCurrentFaerie();
		attachChoice("Voulez vous rendre sa liberte a "+fi.fs.$name+" ?")
		choice.yes.onPress = callback(this,withdraw)
	}

	function withdraw(){
		Cm.withdraw(Cm.card.$current);
		updateCurrent();
		removeChoice();
		updateStar();
	}
	
	//
	function trgMsg(mc,msg){
		if(msg==null){
			mc.onRollOver = null;
			mc.onRollOut = null;
			mc.onDragOut = null;
			return;
		}
		
		var me = this
		mc.onRollOver = fun(){
			//Manager.log("over!")
			me.setMsg(msg)
		}
		
		mc.onRollOut = fun(){
			me.setMsg(null)
			
		}
		mc.onDragOut = mc.onRollOut
		
	}
	
	function setMsg(msg){
		if( msg == null ){
			msgPanel.gotoAndStop("1")
		}else{
			msgPanel.gotoAndStop(string(2+msg.type))
			switch(msg.type){
				case 0:
					msgPanel.field.text = msg.text
					msgPanel.field._y = 30-msgPanel.field.textHeight*0.5
					break;
				case 1:
					msgPanel.fieldTitle.text = msg.title
					msgPanel.field.text = msg.text
					msgPanel.field._y = 36-msgPanel.field.textHeight*0.5				
					break;
				case 2:
					msgPanel.fieldTitle.text = msg.title
					msgPanel.field.text = msg.text
					msgPanel.symbol.gotoAndStop(string(msg.picFrame))	
					break;
			}			
		}		
	}
	
	
//{
}





	