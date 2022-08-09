class box.EditInfo extends box.Standard{
	//
	
	private var step:Number = 0;
	
	private var countryList:Array;
	private var countryKey:Array;
	
	private var regionList:Array;
	private var regionKey:Array;
	private var flLoading:Boolean;
	
	private var httpErrorCategory:Object;
	private var httpError:Array;
	
	
	//
	
	var name:String;

	var firstname:String;
	var lastname:String;
	var lastname_public:Boolean;
	var birthday_dd:Number;
	var birthday_mm:Number;
	var birthday_yyyy:Number;
	var gender:String;
	
	var country:String;
	var region:String;
	var city:String;
	var realJob:String;
	
	var siteUrl:String;
	var comment:String;


	function EditInfo(obj){
		this.winType = "winEditInfo";
		
		for(var n in obj){
			this[n] = obj[n];
		}
		
		this.httpErrorCategory = new Object();
		this.httpErrorCategory["1205"] = [4,"country"];
		this.httpErrorCategory["1206"] = [4,"country"];
		this.httpErrorCategory["1207"] = [3,"birthday"];
		this.httpErrorCategory["1208"] = [3,"gender"];
		this.httpErrorCategory["1211"] = [3,"lastname"];
		this.httpErrorCategory["1212"] = [3,"firstname"];
		this.httpErrorCategory["1213"] = [3,"lastname"];
		this.httpErrorCategory["1214"] = [4,"city"];
		this.httpErrorCategory["1215"] = [4,"realJob"];
		
		this.flLoading = false;
		
		this.countryList = [Lang.fv("subscribe.country_combo_title")];
		this.countryKey = [undefined];
		for(var n in _global.langText.countries){
			this.countryList.push(_global.langText.countries[n].name);
			this.countryKey.push(n);
		}
		this.regionList = [Lang.fv("subscribe.choose_country_first")];
		this.regionKey = [undefined];
		
		_global.uniqWinMng.setBox("editinfo",this);
		this.setTitle(Lang.fv("editinfo.title"));
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
			var l:HTTP = new HTTP("do/gmi",{},{type: "xml",obj: this,method: "onGMI"});
			
			this.window.displayWait();
			/*
			this.step = 4;
			this.displayStep();
			//*/
		}else{
			// change mode init
		}

		return rs;
	}
	
	function close(){
		_global.uniqWinMng.unsetBox("editinfo");
		super.close();
	}
	
	function tryToClose(){
		this.close();
	}
	
	function onGMI(success,node){
		if(!success){
			_global.openErrorAlert(Lang.fv("error.host_unreachable"));
			this.close();
			return ;
		}
		
		node = node.firstChild;
		if(node.nodeName != "i"){
			_global.openErrorAlert(Lang.fv("error.http.1"));
			this.close();
			return ;
		}
		
		for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){
			var s = n.firstChild.nodeValue.toString();
			switch(n.nodeName){
				case "d":
					this.birthday_dd = s.substr(8,2);
					this.birthday_mm = s.substr(5,2);
					this.birthday_yyyy = s.substr(0,4);
					break;
				case "f":
					this.firstname = s;
					break;
				case "l":
					this.lastname = s;
					this.lastname_public = (n.attributes.p=="Y");
					break;
				case "g":
					this.gender = s;
					break;
				case "j":
					this.realJob = s;
					break;
				case "c":
					this.city = s;
					break;
				case "o":
					this.country = s;
					break;
				case "r":
					this.region = s;
					break;
				case "u":
					this.siteUrl = s;
					break;
				case "m":
					this.comment = s;
					break;
			}
		}
		
		this.onCountryChange();
		this.window.removeWait();
		this.goStep(true);
	}
	
	function onCountryChange(){
		if(this.step == 2){
			var country = this.countryKey[this.window.getInput("country")];
		}else{
			var country = this.country;
		}
		if(country == undefined){
			this.regionList = [Lang.fv("subscribe.choose_country_first")];
			this.regionKey = [undefined];
		}else{
			var o = _global.langText.countries[country];
			if(o.regionNb == 0){
				this.regionList = [Lang.fv("subscribe.region_combo_none")];
				this.regionKey = [undefined];
			}else{
				this.regionList = [Lang.fv("subscribe.region_combo_title",{n: o.regionName.toLowerCase()})];
				this.regionKey = [undefined];
				for(var n in o.region){
					if(o.displayCode){
						this.regionList.push(n+" - "+o.region[n]);
					}else{
						this.regionList.push(o.region[n]);
					}
					this.regionKey.push(n);
				}
			}
		}
		this.window.updateRegionCombo(this.regionList.join(";"))
	}
	
	function checkStep(){
		var isOk = true;
		switch(this.step){
			case 1:
				// firstname, lastname (public), birthday, gender
				if(!this.checkMisc(this.firstname)){
					this.window.displayError("firstname",Lang.fv("subscribe.error_form.firstname"));
					isOk = false;
				}
				if(!this.checkMisc(this.lastname)){
					this.window.displayError("lastname",Lang.fv("subscribe.error_form.lastname"));
					isOk = false;
				}
				if(!this.checkDate(this.birthday_yyyy,this.birthday_mm,this.birthday_dd)){
					this.window.displayError("birthday",Lang.fv("subscribe.error_form.birthday"));
					isOk = false;
				}
				if(!this.checkGender(this.gender)){
					this.window.displayError("gender",Lang.fv("subscribe.error_form.gender"));
					isOk = false;
				}

				return isOk;
			case 2:
				// country, region, city, realJob
				if(!this.checkCountry(this.country)){
					this.window.displayError("country",Lang.fv("subscribe.error_form.country"));
					isOk = false;
				}else if(!this.checkRegion(this.country,this.region)){
					this.window.displayError("country",Lang.fv("subscribe.error_form.region"));
					isOk = false;
				}
				
				if(!this.checkMisc(this.city)){
					this.window.displayError("city",Lang.fv("subscribe.error_form.city"));
					isOk = false;
				}
				if(!this.checkMisc(this.realJob)){
					this.window.displayError("realJob",Lang.fv("subscribe.error_form.realJob"));
					isOk = false;
				}
				
				return isOk;
				
			case 3:
				// country, region, city, realJob
				if(this.siteUrl.length && !this.checkUrl(this.siteUrl)){
					this.window.displayError("siteUrl",Lang.fv("editinfo.error_form.siteUrl"));
					isOk = false;
				}
			
				return isOk;
				
			default:
				return isOk;
		}
	}

	function getFormContent(){
		switch(this.step){
			case 1:
				// firstname, lastname (public), birthday, gender
				this.firstname = FEString.trim(this.window.getInput("firstname"));
				this.lastname = FEString.trim(this.window.getInput("lastname"));
				this.lastname_public = this.window.getInput("lastname_public");
				this.birthday_dd = Number(this.window.getInput("birthday_dd"));
				this.birthday_mm = Number(this.window.getInput("birthday_mm"));
				this.birthday_yyyy = Number(this.window.getInput("birthday_yyyy"));
				this.gender = this.window.getInput("gender");
				break;
			case 2:
				// country, region, city, realJob
				this.country = this.countryKey[this.window.getInput("country")];
				this.region = this.regionKey[this.window.getInput("region")];
				this.city = this.window.getInput("city");
				this.realJob = this.window.getInput("realJob");
				break;
			case 3:
				this.siteUrl = this.window.getInput("siteUrl");
				this.comment = this.window.getInput("comment");
				break;
		}
	}
	
	function goStep(next){
		this.window.cleanError();
		this.getFormContent();
		if(next){
			if(this.checkStep()){
				if(this.step < 3){
					this.step++;
					this.displayStep();
				}else{
					this.send();
				}
			}
		}else{
			this.step--;
			this.displayStep();
		}
	}
	
	function displayStep(){
		var inf = new Object();
		switch(this.step){
			case 1:
				inf.firstname = (this.firstname==undefined)?'':this.firstname;
				inf.lastname = (this.lastname==undefined)?'':this.lastname;
				inf.lastname_public = (this.lastname_public==undefined)?false:this.lastname_public;
				inf.birthday_dd = (this.birthday_dd==undefined||isNaN(this.birthday_dd))?'':FENumber.toStringL(this.birthday_dd,2);
				inf.birthday_mm = (this.birthday_mm==undefined||isNaN(this.birthday_mm))?'':FENumber.toStringL(this.birthday_mm,2);
				inf.birthday_yyyy = (this.birthday_yyyy==undefined||isNaN(this.birthday_yyyy))?'':FENumber.toStringL(this.birthday_yyyy,4);
				inf.gender = (this.gender==undefined)?'':this.gender;
				break;
			case 2:
				inf.country_text = this.countryList.join(";");
				inf.country_sel = this.countryKey.indexOf(this.country);
				inf.region_text = this.regionList.join(";");
				inf.region_sel = this.regionKey.indexOf(this.region);
				inf.city = (this.city==undefined)?'':this.city;
				inf.realJob = (this.realJob==undefined)?'':this.realJob;
				break;
			case 3:
				inf.siteUrl = this.siteUrl;
				inf.comment = this.comment;
				break;
		}
		inf.errors = this.httpError[this.step];

		this.window.displayStep(this.step,inf);
	}
	
	////

	function send(){
		this.window.displayWait();
		this.flLoading = true;
		
		var load:HTTP = new HTTP("do/smi",{
			d: FENumber.toStringL(this.birthday_yyyy,4)+"-"+FENumber.toStringL(this.birthday_mm,2)+"-"+FENumber.toStringL(this.birthday_dd,2),
			f: this.firstname,
			l: this.lastname,
			q: this.lastname_public?'1':'0',
			g: this.gender,
			j: this.realJob,
			c: this.city,
			o: this.country,
			r: (this.region==undefined)?'':this.region,
			u: this.siteUrl,
			m: this.comment
		},{type: "xml",obj: this,method: "onSend"},"POST");
	}
	
	function onSend(success,node){
		this.window.removeWait();
		this.flLoading = false;
		this.httpError = new Array();
		
		if(!success){
			_global.openErrorAlert(Lang.fv("error.host_unreachable"));
			this.displayStep();
			return ;
		}
		
		node = node.firstChild;
		if(node.nodeName != "r"){
			_global.openErrorAlert(Lang.fv("error.http.1"));
			this.displayStep();
			return ;
		}
		
		if(node.attributes.k == undefined){
			// All ok !
			_global.openAlert(Lang.fv("editinfo.edit_ok"));
			this.close();
		}else{
			if(node.hasChildNodes()){
				for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){
					if(n.nodeName != "e") continue;
					
					var s = this.httpErrorCategory[n.attributes.k][0];
					var c = this.httpErrorCategory[n.attributes.k][1];
					
					if(this.httpError[s] == undefined) this.httpError[s] = new Array();
					this.httpError[s].push({cat: c,txt: Lang.fv("error.http."+n.attributes.k)});
				}
				this.step = 1;
				this.displayStep();
			}else{
				_global.openErrorAlert(Lang.fv("error.http."+node.attributes.k));
				this.displayStep();
			}
		}
	}

	// Test functions
	private function checkGender(str){
		if(str == "M" || str == "F") return true;
		return false;
	}

	private function checkDate(yyyy,mm,dd){
		if(isNaN(yyyy) || yyyy == undefined) return false;
		if(isNaN(mm) || mm == undefined) return false;
		if(isNaN(dd) || dd == undefined) return false;

		var obj = _global.servTime.getObject()

		if(yyyy > obj.y) return false;
		if(yyyy < 1900) return false;

		if(mm > 12) return false;
		if(mm < 1) return false;

		if(dd > 31) return false;
		if(dd < 1) return false;

		return true;
	}

	private function checkMisc(str){
		if(str == undefined || str.length <= 0) return false;
		return true;
	}
	
	private function checkCountry(country){
		if(country == undefined) return false;
		if(_global.langText.countries[country] == undefined) return false;
		
		return true;
	}
	
	// country must be tested before region...
	private function checkRegion(country,region){
		var o = _global.langText.countries[country];
		if(o.regionNb == 0){
			if(region != undefined) return false;
			return true;
		}else{
			if(region == undefined) return false;
			if(o.region[region] == undefined) return false;
			return true;
		}
	}
	
	
	private function checkUrl(u){
		if(u.substr(0,7) != "http://") return false;
		
		return true
	}

}
