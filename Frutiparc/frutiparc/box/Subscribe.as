/*
$Id: Subscribe.as,v 1.15 2004/04/20 15:46:50  Exp $

Class: box.Subscribe
*/
class box.Subscribe extends box.Standard{//}

	//
	
	private var step:Number = 0;
	private var absolute_ref:String;
	private var subscribed:Boolean;
	
	private var countryList:Array;
	private var countryKey:Array;
	
	private var regionList:Array;
	private var regionKey:Array;
	private var flLoading:Boolean;
	
	private var httpErrorCategory:Object;
	private var httpError:Array;
	
	
	//
	
	var name:String;
	var pass:String;
	var pass2:String;
	var email:String;
	var ref:String;
	
	//var bouille:String;

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
	var charte:Boolean;
	
	var u:String;
	
	function Subscribe(obj){
		for(var n in obj){
			this[n] = obj[n];
		}
		
		this.httpErrorCategory = new Object();
		this.httpErrorCategory["201"] = [1,"email"];
		this.httpErrorCategory["203"] = [1,"email"];
		this.httpErrorCategory["1201"] = [1,"pass"];
		this.httpErrorCategory["1202"] = [1,"pass"];
		this.httpErrorCategory["1203"] = [1,"name"];
		this.httpErrorCategory["1204"] = [1,"name"];
		this.httpErrorCategory["1205"] = [4,"country"];
		this.httpErrorCategory["1206"] = [4,"country"];
		this.httpErrorCategory["1207"] = [3,"birthday"];
		this.httpErrorCategory["1208"] = [3,"gender"];
		this.httpErrorCategory["1209"] = [1,"ref"];
		this.httpErrorCategory["1210"] = [1,"ref"];
		this.httpErrorCategory["1211"] = [3,"lastname"];
		this.httpErrorCategory["1212"] = [3,"firstname"];
		this.httpErrorCategory["1213"] = [3,"lastname"];
		this.httpErrorCategory["1214"] = [4,"city"];
		this.httpErrorCategory["1215"] = [4,"realJob"];
		
		this.flLoading = false;
		
		this.winType = "winSubscribe";
		this.title = Lang.fv("subscribe.title");
		this.subscribed = false;
		if(_root.ref != undefined && _root.ref.length > 0){
			this.absolute_ref = _root.ref;
		}
		
		this.countryList = [Lang.fv("subscribe.country_combo_title")];
		this.countryKey = [undefined];
		for(var n in _global.langText.countries){
			this.countryList.push(_global.langText.countries[n].name);
			this.countryKey.push(n);
		}
		this.regionList = [Lang.fv("subscribe.choose_country_first")];
		this.regionKey = [undefined];
		
		var shob = SharedObject.getLocal("gomu");
		if(shob.data.e != undefined){
			this.u = shob.data.e;
		}else{
			this.u = "";
		}
	}
	
	function onCountryChange(){
		var country = this.countryKey[this.window.getInput("country")];
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
	
	function preInit(){
		this.desktopable = true;
		this.tabable = false;
		super.preInit();
	}

	function init(slot,depth){
		var rs = super.init(slot,depth);

		if(rs){
			this.window.setTitle(this.title);
			this.goStep(true);
			
			/*
			this.step = 4;
			this.displayStep();
			//*/
		}
		return rs;
	}
	
	function tryToClose(){
		if(this.flLoading) return false;
		
		if(!this.subscribed){
			_global.uniqWinMng.open("login");
		}
		super.tryToClose();
	}

	function checkStep(){
		var isOk = true;
		switch(this.step){
			case 1:
				// Name, pass, pass2, email
				if(!this.checkName(this.name)){
					this.window.displayError("name",Lang.fv("subscribe.error_form.name"));
					isOk = false;
				}
				if(this.pass2 != this.pass){
					this.window.displayError("pass",Lang.fv("subscribe.error_form.pass2"));
					isOk = false;
				}
				if(!this.checkPass(this.pass)){
					this.window.displayError("pass",Lang.fv("subscribe.error_form.pass"));
					isOk = false;
				}
				if(this.pass == this.name){
					this.window.displayError("pass",Lang.fv("subscribe.error_form.pass_equals_name"));
					isOk = false;
				}
				if(!this.checkMail(this.email)){
					this.window.displayError("email",Lang.fv("subscribe.error_form.email"));
					isOk = false;
				}
				if(this.checkMisc(this.ref) && !this.checkName(this.ref)){
					this.window.displayError("ref",Lang.fv("subscribe.error_form.ref"));
					isOk = false;
				}
				if(this.ref == this.name && this.ref.length > 0){
					this.window.displayError("ref",Lang.fv("subscribe.error_form.ref_equals_name"));
					isOk = false;
				}
				
				return isOk;
			case 2:
				// Frutibouille

				return isOk;
			case 3:
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
			case 4:
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
				
				if(!this.charte){
					this.window.displayError("charte",Lang.fv("subscribe.error_form.charte"));
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
				// Name, pass, pass2, email
				this.name = FEString.trim(this.window.getInput("name"));
				this.pass = FEString.trim(this.window.getInput("pass"));
				this.pass2 = FEString.trim(this.window.getInput("pass2"));
				this.email = FEString.trim(this.window.getInput("email"));
				this.ref = FEString.trim(this.window.getInput("ref"));
				break;
			case 2:
				// Frutibouille
				//this.bouille = this.window.getFBouille();
				break;
			case 3:
				// firstname, lastname (public), birthday, gender
				this.firstname = FEString.trim(this.window.getInput("firstname"));
				this.lastname = FEString.trim(this.window.getInput("lastname"));
				this.lastname_public = this.window.getInput("lastname_public");
				this.birthday_dd = Number(this.window.getInput("birthday_dd"));
				this.birthday_mm = Number(this.window.getInput("birthday_mm"));
				this.birthday_yyyy = Number(this.window.getInput("birthday_yyyy"));
				this.gender = this.window.getInput("gender");
				break;
			case 4:
				// country, region, city, realJob
				this.country = this.countryKey[this.window.getInput("country")];
				this.region = this.regionKey[this.window.getInput("region")];
				this.city = this.window.getInput("city");
				this.realJob = this.window.getInput("realJob");
				this.charte = this.window.getInput("charte");
				break;
		}
	}
	
	function goStep(next){
		this.window.cleanError();
		this.getFormContent();
		if(next){
			if(this.checkStep()){
				if(this.step == 1){
					// on saut l'�tape bouille...
					this.step = 3;
					this.displayStep();
				}else if(this.step < 4){
					this.step++;
					this.displayStep();
				}else{
					this.send();
				}
			}
		}else{
			this.step--;
			if(this.step == 2) this.step--; // on saute l'�tape bouille
			this.displayStep();
		}
	}
	
	function displayStep(){
		var inf = new Object();
		switch(this.step){
			case 1:
				inf.name = (this.name==undefined)?'':this.name;
				inf.pass = (this.pass==undefined)?'':this.pass;
				inf.pass2 = (this.pass2==undefined)?'':this.pass2;
				inf.email = (this.email==undefined)?'':this.email;
				if(this.absolute_ref != undefined){
					inf.dsp_ref = false;
				}else{
					inf.dsp_ref = true;
					inf.ref = (this.ref==undefined)?'':this.ref;
				}
				break;
			case 2:
				//inf.bouille = (this.bouille==undefined)?'000000010000000000':this.bouille;
				break;
			case 3:
				inf.firstname = (this.firstname==undefined)?'':this.firstname;
				inf.lastname = (this.lastname==undefined)?'':this.lastname;
				inf.lastname_public = (this.lastname_public==undefined)?false:this.lastname_public;
				inf.birthday_dd = (this.birthday_dd==undefined||isNaN(this.birthday_dd))?'':FENumber.toStringL(this.birthday_dd,2);
				inf.birthday_mm = (this.birthday_mm==undefined||isNaN(this.birthday_mm))?'':FENumber.toStringL(this.birthday_mm,2);
				inf.birthday_yyyy = (this.birthday_yyyy==undefined||isNaN(this.birthday_yyyy))?'':FENumber.toStringL(this.birthday_yyyy,4);
				inf.gender = (this.gender==undefined)?'':this.gender;
				break;
			case 4:
				inf.country_text = this.countryList.join(";");
				inf.country_sel = this.countryKey.indexOf(this.country);
				inf.region_text = this.regionList.join(";");
				inf.region_sel = this.regionKey.indexOf(this.region);
				inf.city = (this.city==undefined)?'':this.city;
				inf.realJob = (this.realJob==undefined)?'':this.realJob;
				inf.charte = (this.charte==undefined)?false:this.charte;
				break;
		}
		inf.errors = this.httpError[this.step];
		if(this.step == 2){
			//this.window.displayStepTwo(inf);
		}else{
			this.window.displayStep(this.step,inf);
		}
	}
	
	////

	function send(){
		this.window.displayWait();
		this.flLoading = true;
		
		var load:HTTP = new HTTP("do/subscribe",{
			u: this.u,
			n: this.name,
			p: MD5.encode(this.pass),
			m: this.email,
			//b: this.bouille,
			d: FENumber.toStringL(this.birthday_yyyy,4)+"-"+FENumber.toStringL(this.birthday_mm,2)+"-"+FENumber.toStringL(this.birthday_dd,2),
			f: this.firstname,
			l: this.lastname,
			q: this.lastname_public?'1':'0',
			g: this.gender,
			j: this.realJob,
			c: this.city,
			o: this.country,
			r: (this.region==undefined)?'':this.region,
			e: (this.absolute_ref==undefined)?this.ref:this.absolute_ref
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
			this.onSubscribe();
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
	
	function displayCharte(){
		getURL("javascript:fp_openPopup('/h/charte','ForgetPass','width=400,height=500,resizable=yes,scrollbars=yes')","");
	}

	function onSubscribe(){
		_global.mainCnx.ident(this.name,this.pass);
		this.subscribed = true;
		this.close();
	}

	// Test functions
	private function checkName(str){
		if(str == undefined || str.length <= 0) return false;
		if(escape(str) != str) return false;
		if(str.length < 4 || str.length > 18) return false;
		return true;
	}
	
	private function checkPass(str){
		if(str == undefined || str.length <= 0) return false;
		if(str.length < 6) return false;
		return true;
	}

	private function checkMail(str){
		if(str == undefined || str.length <= 0) return false;

		var arr = str.split("@");
		if(arr.length < 2) return false;
		if(arr[0].length < 2) return false;	
		if(arr[1].length < 4) return false;
		var d = arr[1].toLowerCase();
		if(d == "frutiparc.com" || d == "fruitiparc.com" || d == "frutiparc.net") return false;
		return true;
	}
	
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
//{
}







