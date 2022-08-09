/*
$Id: Login.as,v 1.12 2004/06/10 16:21:08  Exp $

Class: box.Login
*/
class box.Login extends box.FP{
	var login:String;
	var pass:String;
	var state:Number; // 1: ident, 2: wait, 3: error
	var shObj:SharedObject;
	
	var flAlerted:Boolean = false;
	
	function Login(obj){
		for(var n in obj){
			this[n] = obj[n];
		}
		this.winType = "winLogin";
		if(this.title == undefined) this.title = Lang.fv("login");
		_global.uniqWinMng.setBox("login",this);

	}
	
	function preInit(){
		this.desktopable = true;
		this.tabable = false;
		super.preInit();
		
		this.shObj = SharedObject.getLocal("last_ident");
	}

	function init(slot,depth){
		var rs = super.init(slot,depth);

		if(rs){
			//this.window.setTitle(this.title);
			this.state = 1;
			if(this.shObj.data.login != undefined && this.shObj.data.login.length >= 4){
				this.window.setInput("inputName",this.shObj.data.login);
				this.window.setInputFocus("inputPass");
			}else{
				this.window.setInputFocus("inputName");
			}
		}
		return rs;
	}
	
	function close(){
		_global.uniqWinMng.unsetBox("login");
		super.close();
	}

	function ident(){
		this.login = this.window.getInput("inputName");
		this.pass = this.window.getInput("inputPass");
		
		this.shObj.data.login = this.login;

		if(this.login == undefined || this.login.length <= 0){
			if(!this.flAlerted){
				_global.openAlert(Lang.fv("loginForm.name_required"));
				this.flAlerted = true;
			}
		}else if(this.pass == undefined || this.pass.length <= 0){
			if(!this.flAlerted){
				_global.openAlert(Lang.fv("loginForm.pass_required"));
				this.flAlerted = true;
			}
		}else{
			_global.mainCnx.addListener("ident",this,"onIdent");
			_global.mainCnx.ident(this.login,this.pass);

			this.state = 2;
			this.window.removeLoginScreen();
			this.window.displayWait();
		}
	}
	
	function onIdent(node){
		_global.mainCnx.removeListenerCmdObj("ident",this);
		if(this.state != 2) return false;
		
		if(node.attributes.k == undefined){
			//this.tryToClose();
		}else{
			var err = Number(node.attributes.k);
			if(err == 53){
				this.tryToClose();
			}else{
				this.state = 3;
				this.window.displayError(Lang.fv("error.cbee."+node.attributes.k));
			}
		}
	}
	
	function displayIdent(){
		this.state = 1;
		this.window.displayIdent();
		this.window.setInput("inputName",this.login);
		this.window.setInputFocus("inputName");
	}	

	function tryToClose(){
		this.window.squeezeOut();
	}

	function subscribe(){
		_global.desktop.addBox(new box.Subscribe());
		this.tryToClose();
	}

	function forgetPassword(){
		getURL("javascript:fp_openPopup('/h/fp','ForgetPass','width=400,height=400,resizable=yes')","");
	}

	function demo(){
		getURL("javascript:fp_openPopup('http://img.frutiparc.com/press/dossier.html','Demo','width=800,height=400,resizable=yes,scrollbars=yes')","");
	}
	
	function onEnter(){
		if(this.state == 1){
			this.ident();
		}else if(this.state == 3){
			this.displayIdent();
		}
	}
}

