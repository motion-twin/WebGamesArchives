class box.ConfirmMail extends box.Standard{
	var isSending:Boolean;
	var flCloseAuth:Boolean;
	
	function ConfirmMail(obj){
		for(var n in obj){
			this[n] = obj[n];
		}
		if(this.flCloseAuth == undefined) this.flCloseAuth = false;
		this.winType = "winDocConfirmMail";
		this.isSending = false;
		this.setTitle(Lang.fv("cmail.title"));
		_global.uniqWinMng.setBox("confirm",this);
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
			this.initConfirm();
		}else{
			// change mode init
		}

		return rs;
	}
	
	function close(){
		_global.uniqWinMng.unsetBox("confirm");
		super.close();
	}
	
	function tryToClose(){
		if(this.flCloseAuth && !this.isSending){
			this.close();
		}else{
			return false;
		}
	}
	
	// 
	
	function initConfirm(){
		this.isSending = true;
		var loader:HTTP = new HTTP("do/iconfirm",{name:_global.me.name, pass:MD5.encode(_global.me.pass)},{type: "loadvars",obj: this,method: "onInitConfirm"});
		this.window.displayWait();
	}
	
	function validate(aKey){
		this.isSending = true;
		var loader:HTTP = new HTTP("do/check_key",{key: aKey,name: _global.me.name,pass: MD5.encode(_global.me.pass)},{type: "loadvars",obj: this,method: "onCheckKey"});
		this.window.displayWait();
	}
	
	function sendAgain(){
		this.isSending = true;
		var loader:HTTP = new HTTP("do/send_confirm",{name: _global.me.name,pass: MD5.encode(_global.me.pass)},{type: "loadvars",obj: this,method: "onSendAgain"});
		this.window.displayWait();
	}

	function changeEmail(email){
		this.isSending = true;
		var loader:HTTP = new HTTP("do/change_email",{name: _global.me.name,pass: MD5.encode(_global.me.pass),email: email},{type: "loadvars",obj: this,method: "onChangeEmail"});
		this.window.displayWait();
	}
	
	function acceptCharte(){
		this.isSending = true;
		var loader:HTTP = new HTTP("do/ac",{name: _global.me.name,pass: MD5.encode(_global.me.pass)},{type: "loadvars",obj: this,method: "onAcceptCharte"});
		this.window.displayWait();
	}

	//
	
	function onInitConfirm(success,vars){
		this.isSending = false;
		if(!success) return _global.openErrorAlert(Lang.fv("error.host_unreachable"));
		
		if(vars.state == "6"){
			this.window.displayAcceptCharte();
		}else if(vars.state == "209" || vars.state == "205"){ // no email or already confirmed
			this.window.changeMail();
		}else if(vars.state == "0"){
			this.window.displayMain(Lang.fv("cmail.actual_status",{m: vars.email,d: Lang.formatDateString(vars.st,"sentence_long")}));
		}else{
			return _global.openErrorAlert(Lang.fv("error.http."+vars.state));
		}
	}
	
	function onAcceptCharte(success,vars){
		this.isSending = false;
		if(!success) return _global.openErrorAlert(Lang.fv("error.host_unreachable"));
		
		if(vars.state == "0"){
			this.restart();
		}else{
			_global.openErrorAlert(Lang.fv("error.http."+vars.state));
			this.window.displayAcceptCharte();
		}
	}
	
	function onCheckKey(success,vars){
		this.isSending = false;
		if(!success) return _global.openErrorAlert(Lang.fv("error.host_unreachable"));
		
		if(vars.state == "0"){
			this.identAndClose();
		}else{
			if(vars.state != undefined){
				_global.openErrorAlert(Lang.fv("error.http."+vars.state));
			}else{
				_global.openErrorAlert(Lang.fv("error.http.1"));
			}
			this.window.displayMain();
		}
	}
	
	function onSendAgain(success,vars){
		this.isSending = false;
		if(!success) return _global.openErrorAlert(Lang.fv("error.host_unreachable"));
		
		if(vars.state == "0"){
			_global.openAlert(Lang.fv("confirm_mail.mail_send"));
		}else{
			_global.openErrorAlert(Lang.fv("error.http."+vars.state));
		}
		this.window.displayMain();
	}
	
	function onChangeEmail(success,vars){
		this.isSending = false;
		if(!success) return _global.openErrorAlert(Lang.fv("error.host_unreachable"));
		
		if(vars.state == "0"){
			_global.openAlert(Lang.fv("change_mail_ok"));
			this.identAndClose();
		}else{
			_global.openErrorAlert(Lang.fv("error.http."+vars.state));
			this.window.displayMain();
		}
	}

	function identAndClose(){
		_global.desktop.addBox(new box.Charte());
		_global.mainCnx.ident();
		this.close();
	}
	
	function displayCharte(){
		getURL("javascript:fp_openPopup('/h/charte','ForgetPass','width=400,height=500,resizable=yes,scrollbars=yes')","");
	}
	
	function restart(){
		this.initConfirm();
	}
}
