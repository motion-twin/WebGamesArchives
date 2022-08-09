class box.RoomList extends box.Standard{
	
	function RoomList(obj){
		this.winType = "winRoomList";
		//_root.test+="boxRoomList\n"
		for(var n in obj){
			this[n] = obj[n];
		}
		this.title = Lang.fv("public_chat");
		_global.uniqWinMng.setBox("roomList",this);
	}
	
	function preInit(){
		// called only at start of the first init
		this.desktopable = true;
		this.tabable = true;
		super.preInit();	
	}

	function init(slot,depth){
		var rs = super.init(slot,depth);

		if(rs){
			// first init
			_global.mainCnx.addListener("channelList",this,"onChannelList");
			_global.mainCnx.cmd("channellist");
			
		}else{
			// change mode init
		}

		return rs;
	}
	
	function close(){
		_global.mainCnx.rmListenerCmdObj("channelList",this);
		_global.uniqWinMng.unsetBox("roomList");

		super.close();
	}

	function sortRand () {
    if (random(2) == 0) {
			return -1;
    }
    return 1;
	}

	
	
	function onChannelList(node){
		if(node.attributes.k != undefined){
			_global.openErroAlert(Lang.fv("error.cbee."+node.attributes.k));
			return;
		}
		
		var arr = new Array();
		var spe = new Array();
		for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){
			if(n.nodeName == "g"){
				if( n.attributes.g == "quizz" ){
					spe.push({id: n.attributes.g,name: n.firstChild.firstChild.nodeValue.toString(),nbUser: Number(n.attributes.n)});
				}else{
					arr.push({id: n.attributes.g,name: n.firstChild.firstChild.nodeValue.toString(),nbUser: Number(n.attributes.n)});
				}
			}
		}
		arr.sort(this.sortRand);
		for(var i=0;i<spe.length;i++){
			arr.push(spe[i]);
		}
		this.window.setList(arr);
	}
	
	function join(n){
		_global.channelMng.open(n);
		this.close();
	}
	
	function createChannel(n){
		if(n == undefined || n.length == 0){
			_global.openErrorAlert(Lang.fv("error.chat.topic_required"));
			return;
		}
		
		_global.channelMng.create(n);
		this.close();
	}
	
	function getIconLabel(){
		return "winChat";
	}
}
