/*
$Id: Pref.as,v 1.7 2004/04/16 08:46:36  Exp $

Class: box.Pref
*/
class box.Pref extends box.Standard {
	var prefDetails:Object;
	var selected:Number;
	
	function Pref(obj){
		this.winType = "winPref";
		
		for(var n in obj){
			this[n] = obj[n];
		}
		_global.uniqWinMng.setBox("pref",this);
		this.prefDetails = new Object();
		this.title = Lang.fv("pref.title");
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
			var loader:HTTP = new HTTP("do/prefForm",{},{type: "xml",obj: this,method: "onPrefForm"});
		}else{
			// change mode init
		}

		return rs;
	}

	function close(){	
		_global.uniqWinMng.unsetBox("pref");
		super.close();
	}
	
	function onPrefForm(success,x){
		if(!success){
			_global.openErrorAlert(Lang.fv("error.host_unreachable"));
			this.close();
			return;
		}
		
		x = x.firstChild;
		if(x.nodeName != "p"){
			_global.openErrorAlert(Lang.fv("error.pref.loading_form"));
			this.close();
			return;
		}
		
		this.window.setTree(this.analysePrefForm(x));
	}

	function analysePrefForm(x){
		var r = new Array();

		for(var c=x.firstChild;c.nodeType>0;c=c.nextSibling){
			// Category
			if(c.nodeName == "c"){
				r.push({text: c.attributes.n,list: this.analysePrefForm(c)});
					
			// Preference
			}else if(c.nodeName == "p"){
				var p_id:Number = Number(c.attributes.i);
				var p_fname:String = c.attributes.f;
				var p_desc:String = "";
				var p_form:XML = new XML();
				var p_name:String = _global.userPref.prefsId[p_id];
				if(p_name == undefined) continue;

				var p_inf:Object = _global.userPref.prefs[p_name];

				for(var u=c.firstChild;u.nodeType>0;u=u.nextSibling){
					
					if(u.nodeName == "d"){
							p_desc = u.firstChild.nodeValue.toString();
					}else if(u.nodeName == "f"){
							p_form = u.firstChild;
					}
					
				} // end for
				
				if(p_inf.type == "bool"){
					var p_fValue = p_inf.value?'Y':'N';
				}else{
					var p_fValue = p_inf.value;
				}
				
				this.prefDetails[p_id] = {
					id: p_id,
					fName: p_fname,
					desc: p_desc,
					form: p_form,
					name: p_name,
					formValue: p_fValue,
					value: p_inf.value,
					defVal: p_inf.default_value,
					type: p_inf.type
				};

				r.push({text: p_fname,action: {obj: this,method: "displayPref",args: p_id}});
			} // end if/else if
		} // end for
		
		return r;
	} // end function

	function displayPref(id){
		this.updateFromForm();
	
		var o = this.prefDetails[id];
		if(o == undefined){
			this.selected = undefined;
			this.window.displayPref();
		}else{
			this.selected = id;
			this.window.displayPref(o);
		}
	}
	
	function updateFromForm(){
		if(this.selected == undefined) return;
		
		var v = this.window.getCurrentValue();
		var p = this.prefDetails[this.selected];

		if(p.type == "bool"){
			var v = (v=='Y')?true:false;
		}else if(p.type == "int"){
			var v = Number(v);
			if(isNaN(v)) v = p.defVal;
		}else{
			//
		}
		
		//_global.debug("Value d�finit pour "+p.name+" : "+v+" [was: "+p.value+"]");

		p.value = v;
		
		if(p.type == "bool"){
			p.formValue = p.value?'Y':'N';
		}else{
			p.formValue = p.value;
		}
	}
	
	function useDefault(){
		//_global.debug("useDefault");
		
		var t = this.selected;
		this.displayPref();
		for(var n in this.prefDetails){
			var p = this.prefDetails[n];
			
			p.value = p.defVal;
			
			if(p.type == "bool"){
				p.formValue = p.value?'Y':'N';
			}else{
				p.formValue = p.value;
			}
		}
		this.displayPref(t);
	}
	
	function save(){
		//_global.debug("save");
		this.updateFromForm();
		
		_global.userPref.setFromCopy(this.prefDetails);
		_global.userPref.save();
		
		this.close();
	}
}
