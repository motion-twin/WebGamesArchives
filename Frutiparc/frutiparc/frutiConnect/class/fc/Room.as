class fc.Room extends MovieClip{//}

	// CONSTANTES
	var marginUp:Number = 10;
	var marginBottom:Number = 10;
	var marginInside:Number = 2;
	var marginOutside:Number = 10;

	// VARIABLES	
	var slotNum:Number;
	var slotList:Array;
	var gameWidth:Number;
	
	var slGame:fc.slot.Game;
	var slChat:fc.slot.Chat;
	var slList:fc.slot.List;
		
	var root:FrutiConnect;
	
	
	function Room(){
		this.init()
	}
	
	function setUserList(list,index,max){
		//_root.test+="[Room] setUserList("+list+","+index+","+max+",)"
		this.slList.content.setList(list,index,max)
	}
	
	function init(){
		//_root.test+="Room init\n"
		//
		if(this.gameWidth==undefined)this.gameWidth = 300;
		this.slotNum = 0;
		this.slotList = new Array();
		//this.widthList = new Array();
		this.initSlot();
		//
	
	}
	
	function initSlot(){
		//
		this.slGame = this.addSlot("fcSlGame",{flOpen:false, width:this.gameWidth})
		this.slChat = this.addSlot("fcSlChat",{flOpen:true})
		this.slList = this.addSlot("fcSlList",{flOpen:true})
		//
		for(var i=0; i<this.slotList.length; i++){
			var mc = this.slotList[i];
			mc.pos.x = i*(10+this.marginInside) + this.marginOutside
			mc.pos.y = this.marginUp
			mc.pos.w = 10;
			mc.pos.h = this.root.mch - (this.marginUp+this.marginBottom);
			mc.update();
		}
		this.updateSlotTarget();

	}
	
	function addSlot(link,initObj){
		//
		if(initObj==undefined)initObj = new Object();
		initObj.root = this.root
		initObj.room = this
		//
		var d = this.slotNum++
		this.attachMovie(link,"slot"+d,d,initObj)
		var mc = this["slot"+d]
		this.slotList.push(mc)
		return mc;
	}
	
	function updateSlotTarget(){
		var toFill = this.root.mcw - (this.marginOutside*2 + this.marginInside*(this.slotList.length-1) )
		//_root.test+="toFill"+toFill+"\n"
		var bigTotal = 0;
		for(var i=0; i<this.slotList.length; i++){
			var mc = slotList[i]
			mc.content._visible = false;
			if(mc.flOpen){
				var w = Math.min(mc.width,toFill);
				if(mc.big)bigTotal+=mc.big;
			}else{
				var w = 10;
			}
			mc.trg.w = w
			toFill -= w
		}
		var x = this.marginOutside
		for(var i=0; i<this.slotList.length; i++){
			var mc = slotList[i]
			if(mc.big and mc.flOpen){
				mc.trg.w += toFill * mc.big/bigTotal
			}
			mc.trg.x = x
			x += mc.trg.w + this.marginInside
			mc.trg.y = mc.pos.y
			mc.trg.h = mc.pos.h
			mc.initMove();
		}
		
	}
		
	// ENVOIS
	/*
	function createGame(card){
		_root.test+="[Room] createGame("+card+")\n"
		this.root.manager.createGame( card );
	};
	*/
	
	// RECEPTIONS
	function receiveMessage(txt){
		_root.test+="main.room.receiveMessage("+txt+")\n"
		this.slChat.content.receiveMessage(txt);
		
		// XXX temporaire pour créer une partie
		/*
		if( txt == "fi" ) 
			this.createGame();
		else if( txt.substr( 0, 2) == "fj" )
		{
			_root.test += "txt.length=" + txt.length + "\n";
			_root.test += "txt.substr( 3, txt.length-2)=" + txt.substr( 2, txt.length-2) + "\n"; 
			this.joinfGame( txt.substr( 2, txt.length-2) );
		}
		else if( txt == "start" )
		{
			this.root.manager.startGame();
		}
		else if( txt == "list" )
		{
			this.root.manager.listGames();
		}
		else if( txt == "players" )
		{
			this.root.manager.listPlayers();
		}
		*/
	};
		
	function receiveGameInfo(docXML){
		
	}	

	function clearGame(){
		if(this.slGame.flOpen){
			this.slGame.killContent();
			//this.slGame.updateContent()
			this.slGame.flOpen = false;
			this.updateSlotTarget();
			
		}
	}


	function joinGame(flOwn,userList){
		//_root.test+="[Room] joinGame("+userList+","+flOwn+")\n"
		if(this.slGame.type != "panWaitGame"){
			if(!this.slGame.flOpen){
				this.slGame.flOpen = true
				this.updateSlotTarget();
			}
			var initObj = {
				flOwn:flOwn,
				slotMax:userList.length
			}
			
			this.slGame.genContent("fcPanWaitGame",initObj)
			//this.slGame.content._visible = false				// :-/
			this.slGame.updateContent();
		}
		this.slGame.content.setUserList(userList)
	}
		
	function displayWaitList(user){
		//_parent._parent._parent._x+=1;
		_root.test+="displayWaitList()\n"
		if(this.slGame.type != "panKOHWaitList" || user!=this.slGame.content.user ){
			if(!this.slGame.flOpen){
				this.slGame.flOpen = true;
				this.updateSlotTarget();
			}
			var initObj = {
				user:user
			}
			
			this.slGame.genContent("fcPanKOHWaitList",initObj)
		}
		this.slGame.updateContent();
	}
	
	function displayCreateGame(){
		if(this.slGame.type != "panCreateGame" ){
			if(!this.slGame.flOpen){
				this.slGame.flOpen = true;
				this.updateSlotTarget();
			}
			
			this.slGame.genContent("fcPanCreateGame")
		}
		this.slGame.updateContent();	
	}
	
	
	
	
	function displayDoc(doc){
		_root.test+="[Room] displayDoc("+doc+")\n"
		this.slGame.content.setDoc(doc)
	}
	
	
//{	
}


























