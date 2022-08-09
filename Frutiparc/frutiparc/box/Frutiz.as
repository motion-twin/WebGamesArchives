class box.Frutiz extends box.Standard {

	var user:String;
	var frutizInfo:FrutizInfo;
	var group:String;
	
	function Frutiz(obj){
		//_root.test+="[boxFrutiz] init()\n"
		this.winType = "winFrutiz";
		
		for(var n in obj){
			this[n] = obj[n];
		}
		
		this.frutizInfo = new FrutizInfo({user: this.user,box: this});
		if(this.winOpt==undefined) this.winOpt = new Object();
		this.winOpt.iconList = this.getIconList();
	}
	
	function preInit(){
		// called only at start of the first init
		this.desktopable = true;
		this.tabable = true;
		super.preInit();	
	}

	function init(slot,depth){
		// Securité pour éviter bcp de pbs
		if(this.user == undefined){
			_global.debug("WARN: box.Frutiz try to init whithout this.user");
			this.close();
			return;
		}
	
		var rs = super.init(slot,depth);

		if(rs){
			// first init
		}else{
			// change mode init
		}

		return rs;
	}
	
	function close(){	
		this.frutizInfo.onKill();
		_global.frutizInfMng.unsetBox(this.user);
		super.close();
	}
	
	function onUserNotFound(){
		this.close();
	}
	
	function getIconList(){
		var arr = new Array();
		if(this.user == _global.me.name){
			arr.push({frame: 10,tipId: "frutiz_edit_info",callBack: {obj: _global.uniqWinMng,method: "open",args: "editinfo"}});
			//arr.push({frame: 11,tipId: "frutiz_edit_mail",callBack: {obj: this,method: "editMail"}});
		}else{
			arr.push({frame: 2,tipId: "frutiz_chat_now",callBack: {obj: _global,method: "chatNow",args: this.user}});
			arr.push({frame: 3,tipId: "frutiz_new_mail",callBack: {obj: _global,method: "openMail",args: this.user+"@frutiparc.com"}});
			arr.push({frame: 13,tipId: "frutiz_blog",callBack: {obj: _global,method: "openBlog",args: this.user}});
			if(!_global.myContactListCache.isIn(this.user)){
				arr.push({frame: 4,tipId: "frutiz_add_to_contact",callBack: {obj: _global.fileMng,method: "addUserToContact",args: this.user,flNotClose: true}});
			}
			if(!_global.myBlackListCache.isIn(this.user)){
				arr.push({frame: 5,tipId: "frutiz_add_to_blacklist",callBack: {obj: this,method: "addUserToBlackList"}});
			}else{
				arr.push({frame: 12,tipId: "frutiz_remove_from_blacklist",callBack: {obj: _global.fileMng,method: "removeUserFromBlackList",args: this.user,flNotClose: true}});
			}
			if(_global.me.flMode){
				if(this.group != undefined){
					arr.push({frame: 6,tipId: "frutiz_kick",callBack: {obj: this,method: "kick"}});
				}
				arr.push({frame: 7,tipId: "frutiz_ban",callBack: {obj: this,method: "ban",flNotClose: true}});
				//arr.push({frame: 14,tipId: "frutiz_unban",callBack: {obj: this,method: "unban",flNotClose: true}});
				arr.push({frame: 8,tipId: "frutiz_mute",callBack: {obj: this,method: "mute"}});
				//arr.push({frame: 9,callBack: {obj: this,method: "gomu"}});
			}

			if(_global.me.flAnimator && FEString.startsWith(this.group,"quizz")){
				if( !_global.me.flMode ){
					arr.push({frame: 6,tipId: "frutiz_kick",callBack: {obj: this,method: "kick"}});
				}
				arr.push({frame: 7,tipId: "frutiz_banquick",callBack: {obj: this,method: "banQuick",flNotClose: true}});
			}else if( _global.me.flAnimator ){
				//arr.push({frame: 14,tipId: "frutiz_unbanquick",callBack: {obj: this,method: "unbanQuick",flNotClose: true}});
			}
		}
		return arr;
	}
	
	function execCallBack(cb){
		cb.obj[cb.method](cb.args);
		if(!cb.flNotClose){
			this.tryToClose();
		}
	}
	
	function kick(){
		_global.mainCnx.cmd("kick",{u: this.user,g: this.group});
	}
	
	function ban(){
    if(Key.isDown(Key.CONTROL)){
			
			_global.mainCnx.cmd("ban",{u: this.user,g: "0"});
			this.tryToClose();

		}
	}

	function unban(){
    if(Key.isDown(Key.CONTROL)){
			
			_global.mainCnx.cmd("unban",{u: this.user,g: "0"});
			this.tryToClose();

		}
	}

	function banQuick(){
		if(Key.isDown(Key.CONTROL)){
			var t = _global.servTime.getTime() + 24 * 60 * 60 * 1000; // time + 24 hours
			var end = Lang.formatDateTime(t,"prog_server");
			_global.mainCnx.cmd("ban",{u: this.user,g: this.group,e: end});
			this.tryToClose();
    }
	}

	function unbanQuick(){
		if(Key.isDown(Key.CONTROL)){
			_global.mainCnx.cmd("unban",{u: this.user,g: "quizz"});
			this.tryToClose();
    }
	}


	function mute(){
		var t = _global.servTime.getTime() + 10 * 60 * 1000; // time + 10 minutes
		var end = Lang.formatDateTime(t,"prog_server");
		_global.mainCnx.cmd("mute",{u: this.user,e: end});
	}
	
	function editMail(){
		_global.uniqWinMng.open("confirm",undefined,{flCloseAuth: true});
	}
	
	function getUrl(u){
		getURL(u,"_blank");
	}
	
	function addUserToBlackList(){
		_global.topDesktop.addBox(new box.Alert({
			text: Lang.fv("frutiz.add_user_to_blacklist",{u: this.user}),
			butActList: [
				{name: "Oui",action: {obj: _global.fileMng,method: "addUserToBlackList",args: this.user}},
				{name: "Non"}
			]
		}));		
	}

	function onWheel(delta){
		this.window.scrollText(-10 * delta);
	}
}
