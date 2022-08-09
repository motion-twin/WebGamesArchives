class win.RoomList extends win.Advance{//}
	
	var mcTool:cp.Document;
	var mcRoomList:cp.RoomList;

	/*-----------------------------------------------------------------------
		Function: Shop()
	 ------------------------------------------------------------------------*/	
	function RoomList(){
		this.init();	
	}

	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		//
		super.init();
		this.endInit();
		//
	}

	/*-----------------------------------------------------------------------
		Function: initFrameSet()
	 ------------------------------------------------------------------------*/	
	function initFrameSet(){
		
		super.initFrameSet();
		
		// ROOMLIST
		var args = {
			flMask:true,
			flWait:true
		};
		var frame = {
			name:"roomListFrame",
			link:"cpRoomList",
			type:"compo",
			flBackground:true,
			mainStyleName:"frRoomList",
			min:{w:200,h:240},
			args:args	
		};
		this.mcRoomList = this.main.newElement(frame,0);
		this.main.bigFrame = this.main.roomListFrame;
		
		// ACTION
		
		var doc = "<p><l>";
		doc += "<s w=\"4\"/><b t=\""+Lang.fv("chat.create_channel")+"\" l=\"butPushStandard\" o=\"win\" m=\"createNewRoom\"/><s w=\"10\"/>"
		doc += "<i v=\"roomName\" dy=\"1\" b=\"1\"></i><s w=\"3\"/>"
		//doc += "<l l=\"butPush\" ><p link=\"butPushVerySmallPink\" frame=\"2\"><buttonAction><array name=\"onPress\"><o obj=\"win\" method=\"search\"></array></buttonAction></p></l>" 
		doc += "</l></p>"
		
		var margin = Standard.getMargin();
		margin.x.min = 4;
		margin.x.ratio = 0;
		margin.y.min = 6;
		margin.y.ratio = 0.66;
				
		var args={
			flDocumentFit:true,
			doc:new XML(doc)
		};
		var frame = {
			type:"compo",
			name:"frameCreate",
			link:"cpDocument",
			mainStyleName:"frSystem",
			min:{w:260,h:18},
			margin:margin,
			args:args
		};
		this.mcTool = this.margin.bottom.newElement(frame);
		
	
	}
	
	/*-----------------------------------------------------------------------
		Function: initFrameSet()
	 ------------------------------------------------------------------------*/	
	function setList(list){
		this.mcRoomList.setList(list);
		this.frameSet.update();
	}
	
	
	/*-----------------------------------------------------------------------
		Function: createNewRoom()
	 ------------------------------------------------------------------------*/	
	function createNewRoom(){
		_root.test+="createNewRoom("+this.mcTool.card.roomName.value+")\n"
		this.box.createChannel(this.mcTool.card.roomName.value)
	}

	/*-----------------------------------------------------------------------
		Function: search()
	 ------------------------------------------------------------------------*/	
	/*
	function search(){
		_root.test+="search("+this.mcTool.card.search.value+")"
		this.box.search(this.mcTool.card.search.value);
	}
	*/
	
//{	
}




