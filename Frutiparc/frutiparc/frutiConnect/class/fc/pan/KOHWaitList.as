class fc.pan.KOHWaitList extends fc.Panel{//}

	// CONSTANTES
	var dp_slotList:Number = 1000
	var slotHeight:Number = 20;
	var listMax:Number = 10
	// PARAMETRES
	var user:Object;
	//var docInfo:Object;
	
	//var waitList:Array;
	var slotList:Array;
	var doc:cp.Document;
	
	
	function KOHWaitList(){
		this.init();
	}
	
	function init(){
		this.title = "Liste des défis de "+user.name+" ("+user.ranking+")\n"  
		this.slotList = new Array();
		_root.test+=" [KOHWaitList] init()\n"
		//this.title = "Partie en attente..."
		//this.slotList = new Array();
		super.init();
	}
	
	function display(){
		super.display();
		this.genButton("defier "+this.user.name,{obj:this.root.manager,method:"defyPlayer",args:this.user});
	}

	/*
	function setWaitList(waitList,flStart){	// text - status -
		//_root.test += "[WaitGame]  setUserList("+userList+","+flStart+") flOwn("+flOwn+")\n";
		this.waitList = waitList;
		for(var i=0; i<this.slotMax; i++){
			//_root.test+="-\n"
			var list = new Array();
			var user = this.userList[i];
			//_root.test+="endInconList("+list+")\n"
			user.endIconList = list
			this.slotList[i].updateUser( user );
		}    
	}
	*/
	
	function setDoc(doc){
		_root.test+="[fc.pan.KOHWaitList] setDoc("+doc+")\n"
		//_root.test+="[PanWaitGame]initDoc\n"
		var ws = Standard.getWinStyle();
		var initObj={
			doc:doc,
			docStyle:Standard.getFrusionDocStyle(ws.frDef)
		};
		//_root.test+="this.root.manager.playerPanel("+this.root.manager.playerPanel+")\n"
		this.attachMovie( "cpDocument", "doc", 10, initObj );
		this.doc._y = this.listMax*this.slotHeight + 20;
	};

	//	
	function update(){
		//_root.test+="youhouh\n"
		super.update();
		
		while( this.slotList.length>0 ){
			this.slotList.pop().removeMovieClip();
		}
		var list = this.user.waitList
		//_root.test+="------- player in waitList ----------------\n"
		var max = Math.min( this.listMax, list.length );
		for(var i=0; i<max; i++){
			var player = list[i];
			//_root.test+="- player("+player+")\n"
			for(var elem in player) _root.test+="-"+elem+" = "+player[elem]+"\n";
			
			// ATTACH
			var initObj = {
				panel:this,
				flEndLine:true
			};
			this.attachMovie("fcUserSlot","userSlot"+i,this.dp_slotList+1000-i,initObj);
			var mc = this["userSlot"+i];
			mc._y = this.marginUp+this.lineHeight+this.slotHeight*i;
			var info = {
				type:frusion.Context.USER_TYPE,
				user:player,
				link:1
			};
			mc.updateUser(info);
			this.slotList.push(mc);	
		};
		
		this.doc.extWidth = this.size.w;
		this.doc.extHeight = this.size.h-(this.marginUp+this.marginBottom)
		this.doc.updateSize();		

	}
		

//{	
}
























