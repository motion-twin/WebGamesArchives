/*
$Id: Pref.as,v 1.14 2004/07/16 12:23:20  Exp $

Class: Pref
*/
class Pref{
	var types:Object = {
		b: "bool",
		i: "int",
		s: "string"
	};
	
	var loader:HTTP;
	var prefs:Object; // prefs[name] = {type,default_value,value,id}
	var prefsId:Array; // prefsId[id] = name

	function Pref(){
		this.prefs = new Object();
		this.prefsId = new Array();
		//this.loadPrefDef();	
	}
	
	function loadMyPreffunction(){
		this.loader = new HTTP("do/mypref",{},{type: "loadvars",obj: this,method: "onLoadMyPref"});
	}
	
	function loadPrefDef(){
		this.loader = new HTTP("do/prefdef",{},{type: "loadvars",obj: this,method: "onLoadPrefDef"});
	}

	function onLoadPrefDef(success,data){
		if(success){
			var str = data.PrefDef;
			while(str.length > 0){
				var id = FEString.decode62(str.substr(0,2));
				str = str.substr(2);
				
				var t = types[str.substr(0,1)];
				str = str.substr(1);
				
				var l = FEString.decode62(str.substr(0,2));
				var name = str.substr(2,l);
				str = str.substr(l+2);
	
				var l = FEString.decode62(str.substr(0,2));
				var default_value = str.substr(2,l);
				str = str.substr(l+2);
				
				default_value = convert(default_value,t);
				
				this.prefs[name] = {type: t,default_value: default_value,value: default_value,id: id};
				this.prefsId[id] = name;
			}
		}else{
			_global.debug("Error loading preferences definitions");
		}
	}
	
	function useMyPref(str:String){
		while(str.length > 0){
			var id = FEString.decode62(str.substr(0,2));

			var l = FEString.decode62(str.substr(2,2));
			var value = str.substr(4,l);
			str = str.substr(l+4);

			var name = this.prefsId[id];

			var t = this.prefs[name].type;

			value = this.convert(value,t);
			
			if(value != undefined){
				this.prefs[name].value = value;
			}
		}
	}
	
	function onLoadMyPref(success:Boolean,data:Object){
		if(success){
			this.useMyPref(data.myPref);
		}else{
			_global.debug("Error loading personal preferences");
		}
	}
	
	function getFormatedPref(){
		var r = "";
		for(var n in this.prefs){
			var o = this.prefs[n];
			if(o.value != o.default_value){
				switch(o.type){
					case 'bool':
						var content = o.value?'Y':'N'; // 'Y' | 'N'
						break;
					case 'int':
						var content = FENumber.encode62(o.value);
						break;
					case 'string':
					default:
						var content = o.value;
						break;
				}
				r += FENumber.encode62(o.id,2);
				r += FENumber.encode62(content.length,2)+content;
			}
		}
		return r;
	}
	
	function getPref(n){
		if(n == "cache_length" && prefs[n].value == undefined) return 30;
		return this.prefs[n].value;
	}
  
  function setPref(n,v){
    this.prefs[n].value = v;
  }

  function setAndSave(n,v){
    var o = this.prefs[n];

    o.value = v;

    var obj = {i: o.id}

    if(o.value != o.default_value){
      if(o.type == "bool"){
        obj.v = o.value?'Y':'N';
      }else{
        obj.v = o.value;
      }

    }
      
    var l:HTTP = new HTTP("do/prefsavepartial",obj,{type: "loadvars",obj: this,method : "onSavePartial"});
  }

	function setFromCopy(nPrefs){
		for(var n in nPrefs){
			var u = nPrefs[n];
			var o = this.prefs[u.name];
			
			if(o == undefined) continue;
			
			o.value = u.value;
		}
	}
	
	function getACopy(){
		return this.prefs.recursiveClone();
	}
	
	function convert(value,t){
		if(t == "int"){
			value = FEString.decode62(value);
			if(isNaN(value)) value = undefined;
		}else if(t == "bool"){
			value = (value == "Y");
		}
		return value;
	}
	
	function save(){
		var l:HTTP = new HTTP("do/prefsave",{s: this.getFormatedPref()},{type: "loadvars",obj: this,method : "onSave"});
	}
	
	function onSave(success,vars){
		if(!success){
			_global.openErrorAlert(Lang.fv("error.host_unreachable"));
		}
		if(vars.state != "0"){
			_global.openErrorAlert(Lang.fv("error.pref.save")+Lang.fv("error.http."+vars.state));
		}
	}
}
