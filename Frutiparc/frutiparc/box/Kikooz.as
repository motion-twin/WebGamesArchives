class box.Kikooz extends box.Standard{
	
	var callTypes:Object;
	var currentCallType:String;
	var currentCode:String;
	
	function Kikooz(obj){
		//_root.test+="boxKikoozInit\n"
		
		this.winType = "winDocKikooz";
		
		for(var n in obj){
			this[n] = obj[n];
		}
		this.setTitle(Lang.fv("kikooz.title"));
		_global.uniqWinMng.setBox("kikooz",this);
	}
	
	function close(){
		_global.uniqWinMng.unsetBox("kikooz");
		super.close();
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
			this.window.displayStep(1);
		}else{
			// change mode init
		}

		return rs;
	}
	
	function selectCountry(country:String){
		var loader:HTTP = new HTTP("ft/listct",{c: country},{type: "xml",obj: this,method: "onCallTypeList"});
		this.window.displayStep("wait");
	}
	
	function onCallTypeList(success,xml){
		if(!success){
			return _global.openErrorAlert(Lang.fv("error.host_unreachable"));
		}
		
		xml = xml.firstChild;
		if(xml.nodeName != "l" || !xml.hasChildNodes()){
			return _global.openErrorAlert(Lang.fv("error.host_unreachable"));
		}
		
		
		this.callTypes = new Object();
		for(var n=xml.firstChild;n.nodeType>0;n=n.nextSibling){
			if(n.nodeName == "t"){
				this.callTypes[n.attributes.n] = {
					fname: n.attributes.f,
					popup_url: n.attributes.u,
					popup_props: n.attributes.p,
					kikooz: n.attributes.k,
					price: n.attributes.c,
					use_code: (n.attributes.uc=='1' || n.attributes.uc == undefined),
					variable_price: (n.attributes.vp=='1'),
					other_info: n.firstChild.nodeValue,
					available: true
				};
			}else if(n.nodeName == "s"){
				this.callTypes[n.attributes.n] = {
					fname: n.attributes.f,
					available: false
				};
			}
		}
		
		this.window.callTypes = this.callTypes;
		
    var infosParents = (_global.me.age <= 16);
    
		this.window.displayStep(2,{infosParents: infosParents});
	}
	
	function chooseCallType(ct){
		if(ct != undefined){
			this.currentCallType = ct;
		}
		
		// Open PopUp
		if(this.callTypes[this.currentCallType].popup_url.length > 0){
			getURL("javascript:fpWinOpenKikooz('"+this.callTypes[this.currentCallType].popup_url+"','"+this.callTypes[this.currentCallType].popup_props+"')","");
		}

		if(this.callTypes[this.currentCallType].use_code){
			this.window.displayStep(3,{display_popup_info: this.callTypes[this.currentCallType].popup_url.length > 0, other_info: this.callTypes[this.currentCallType].other_info});
		}else{
			this.close();
		}
	}
	
	function check(code){
		this.currentCode = code;
		
		var loader:HTTP = new HTTP("ft/check",{ct: this.currentCallType,c: code},{type: "loadVars",obj: this,method: "onCheck"});
		this.window.displayWait();
	}
	
	function onCheck(success,vars){
		if(!success || vars.state == undefined){
			this.window.displayStep(5,Lang.fv("error.host_unreachable"));
		}else{
			if(vars.state == "0"){
				_global.me.kikooz = Number(vars.k);
				this.window.displayStep(4,Number(vars.k));
			}else{
				if(vars.state == "702"){ // code already used
					this.window.displayStep(5,Lang.fv("error.kikooz.already_used",{c: this.currentCode}));
				}else if(vars.state == "710"){ // bad code 
					this.window.displayStep(5,Lang.fv("error.kikooz.not_valid",{c: this.currentCode,e: vars.email}));
				}else{ // other errors
					this.window.displayStep(5,Lang.fv("error.http."+vars.state));
				}
			}
		}
	}

  function openInfosParents(){
    getURL("javascript:fp_openPopup('/h/infosParents','infosParents','width=400,height=400')","");
  }
}
