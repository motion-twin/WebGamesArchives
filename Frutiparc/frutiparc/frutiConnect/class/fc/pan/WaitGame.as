class fc.pan.WaitGame extends fc.Panel{//}

	// CONSTANTES
	var slotHeight:Number = 20;
	//
	var dp_slotList:Number = 400
	
	
	
	// VARIABLES
	var slotMax:Number;
	var flOwn:Boolean;
	var userList:Array;
	var slotList:Array;
	
	// MOVIECLIP
	var doc:cp.Document;
	
	
	function WaitGame(){
		this.init();
	}
	
	function init(){
		this.title = "Partie en attente..."
		this.slotList = new Array();
		super.init();
	}
	
	function display(){
		super.display();
		this.initDoc();
		//
		for(var i=0; i<this.slotMax; i++){
			var n = this.slotList.length
			// SLOT
			// CLOSE
			var initObj = {
				panel:this,
				flEndLine:true
			};
			this.attachMovie("fcUserSlot","userSlot"+n,this.dp_slotList+100-n,initObj);
			var mc = this["userSlot"+n];
			mc._y = this.marginUp+this.lineHeight+this.slotHeight*n;
			this.slotList.push(mc);			
		}
		// BUTTON
		if(this.flOwn){
			this.genButton("lancer la partie",{obj:this,method:"launchGame"});
		}
		this.genButton("quitter la partie",{obj:this,method:"leaveGame"});
	}

	function initDoc(){
		//_root.test+="[PanWaitGame]initDoc\n"
		var ws = Standard.getWinStyle();
		var initObj={
			doc:this.root.manager.playerPanel,
			docStyle:Standard.getFrusionDocStyle(ws.frDef)
		};
		_root.test+="this.root.manager.playerPanel("+this.root.manager.playerPanel+")\n"
		this.attachMovie( "cpDocument", "doc", 10, initObj );
		this.doc._y = 200;
	};
	
	
	function setUserList(userList,flStart){	// text - status -
		//_root.test += "[WaitGame]  setUserList("+userList+","+flStart+") flOwn("+flOwn+")\n";
		this.userList = userList;
		for(var i=0; i<this.slotMax; i++){
			//_root.test+="-\n"
			var info = this.userList[i]
			/*
			_root.test+="-----------------------\n"
			for(var elem in info) _root.test+="-"+elem+" = "+info[elem]+"\n";
			for(var elem in info.user) _root.test+="  -"+elem+" = "+info.user[elem]+"\n";
			_root.test+="-----------------------\n"
			*/
			var list = new Array();
			if(this.flOwn){
				if( i > 1){
					list.push( { link:"closeSlot", callback:{obj:this,method:"closeSlot",args:i} } );
				};	
				if( i > 0 && !info.type != frusion.Context.EMPTY_TYPE){
					list.push( { link:"kick", callback:{obj:this,method:"kick",args:i} } );
				};
			}
			//_root.test+="endInconList("+list+")\n"
			info.endIconList = list;
			this.slotList[i].updateUser( info );
		}    
	}
	
	function update(){
		super.update();
		for(var i=0; i<this.slotMax; i++){
			var mc = this.slotList[i];
			mc.size.w = this.size.w;
			mc.updateSize();
		}
		//
		this.doc.extWidth = this.size.w;
		this.doc.extHeight = this.size.h-(this.marginUp+this.marginBottom)
		this.doc.updateSize();		
	}
		
	function launchGame(){
		this.root.manager.startGame()
		//_root.test+="launchGame\n"
	}			
	
	function activeCreate(){
	
	}
	
	function closeSlot(id){
		//_root.test+="closeSlot("+id+")\n"
		this.root.manager.closeSlot(id)
	}

	function kick(id){
		//_root.test+="kickFromGame("+id+")\n"
		this.root.manager.kickFromGame(id)
	}
	
	function leaveGame(){
		this.root.manager.leaveGame();
	}
	
//{	
}
























