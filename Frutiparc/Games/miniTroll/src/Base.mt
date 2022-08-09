class Base extends Slot{//}
	
	
	var fi:FaerieInfo;
	
	// CONSTANTE
	static var DP_PANEL =		8;
	static var DP_SKIN_UP =		5;
	static var DP_INTER = 		4;
	static var DP_SKIN_MIDDLE =	3;
	static var DP_GAME = 		2;
	static var DP_SKIN_DOWN =	1;
	
	// VARIABLES
	var step:int;
	
	var timer:float;
	var interList:Array<Inter>;
	var itemList:Array<int>;
	var game:Game;
	
	var flashInfo:{prc:float, frict:float, color:int}
	var elementColor:{prc:float,col:int}
	var intScore:inter.Score

	var intUp:MovieClip;
	var intMiddle:MovieClip;
	var intDown:MovieClip;
	
	var panGameOver:MovieClip;
	
	
	function new(){
		super();
		Cs.base = this;
		interList = new Array();
	}
	
	function init(){
		super.init();
		
		itemList = new Array();

	}
	
	function initGame(){
		game = downcast( dm.attach( "game", Base.DP_GAME) );
		game.base = this;
	}
	
	function initInterface(){
		
		
	}
	
	// ITEM
	function grab(type){
		//Manager.log("grab Item")
		// TRAITER LE CAS DES ITEMS PARTICULIERS ( PAS DANS L'INVENTAIRE )
		
		
		
		Cm.getItem(type)
		
		var it = Item.newIt(type)
		if( it.flGeneral ){
			it.grab();
			return;
		}
		
		var list = Cm.card.$inv
		var index = null
		for( var i=0; i<Cs.bagLimit[Cm.card.$bag]; i++ ){
			if(list[i]==null){
				index = i
				break;
			}
		}
		if( index != null ){
			//Manager.log("addItem at"+index)
			list[index] = type;
		}else{
			//Manager.log("pushItem!")
			itemList.push(type)
		}		
	}
	

	//
	function initStep(n){
		step = n;
		//Manager.log("initStep("+n+")")
		switch(step){
			case 10:
				
				break;
			case 11:
				//Manager.log("init 11")
				flashInfo = { prc:100, frict:0.96, color:0x000000 }
				panGameOver = dm.attach("panGameOver",DP_PANEL)
				timer = 100
				break;
			case 20:
				break;
		}
	}	
	//
	function update(){
		super.update();
		game.update();
		for(var i=0; i<interList.length; i++ ){
			interList[i].update();
		}

		switch(step){
			case 10:	// GAME OVER - 1 - FADE OUT
				if( flashInfo.prc == 100){
					game.kill();
					initStep(11)
					//Manager.log("---init 11")
				}				
				break;
			case 11:	// GAME OVER - 2 - PANEL
				timer -= Timer.tmod
				if(timer<=10){
					tryToClose();
				}
				break;
			case 20:
				break;
		}
		
		
		updateFlash();
		
		
	}
	
	function updateFlash(){
		if( flashInfo != null ){
			var p = flashInfo.prc
			if( p < 1 ){
				flashInfo = null
				p=0
			}
			Mc.setPercentColor(this,p,flashInfo.color)
			var f = Math.pow(flashInfo.frict,Timer.tmod)
			flashInfo.prc = Cs.mm( 0, flashInfo.prc*f, 100 )
		}	
	}
	
	function updatePos(){
		
	}
	
	//
	function newPieceList( shape:Array<{x:int,y:int}> ):Array<ElementInfo>{ // ICI
		var list = new Array();
		for( var i=0; i<shape.length; i++ ){
			var ei = newPieceListElement()
			list.push( ei )
		};
		for( var i=0; i<list.length; i++ ){
			var ei = list[i];
			ei.x = shape[i].x;
			ei.y = shape[i].y;
		}	
		return list;
	}
	//
	function newPieceListElement():ElementInfo{
		var et = 0;
		var ei	= new ElementInfo();
		switch(et){
			case 0:
				var e = new sp.el.Token();
				e.type = game.getColor();
				if( game.starWait>80 ){
					e.special = 3
					game.starWait = 0
				}
				ei.e = upcast(e);
				break;
		}
		return ei
	}
	
	
	// ON
	function onNextRemove(){
		
	}
	
	function onLevelClear(){

	}
	
	function onNewTurn(){
	
	}
	
	function onFireBall(fb){
		
	}
	
	function onDestroyElement(list:Array<sp.Element>){
		
	}		
	
	function setWin(flag:bool){
		//Manager.log("fin du tableau ("+flag+")")
	}

	//
	function onFallStats(fs){
	
	}	
	
	// GET
	function getManaReplenishCoef():float{
		return 1
	}
	
	
	//
	function flash(){
		flashInfo = {prc:100, frict:0.6, color:0xFFFFFF}
		
	}
	
	//
	function gameOver(){
		flashInfo = {prc:1, frict:1.1, color:0x000000}
		initStep(10)
	}
	
	function tryToClose(){
		if(itemList.length>0){
			Manager.fadeSlot("inventory",120,120);
			downcast(Manager.slot).setExtraList(itemList);
			downcast(Manager.slot).flNoExtraDisplay = true;
			Manager.slot.postInit();
			return;
		}
		Manager.fadeSlot("menu",120,120);		
	}
	
	
//{
}