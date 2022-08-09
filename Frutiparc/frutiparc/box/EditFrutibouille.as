class box.EditFrutibouille extends box.Standard{
	var fbouille:String;
	var part:Array;
	var flLoading:Boolean = false;
	
	function EditFrutibouille(obj){
		this.winType = "winEditFrutibouille";
		for(var n in obj){
			this[n] = obj[n];
		}
		if(this.winOpt == undefined) this.winOpt = new Object();
		
		var ml = new Array();
		var m = -1;
		for(var i=0;i<this.part.length;i++){
			switch(this.part[i]){
				case "1":
					if(m < 1) m = 1;
					ml.pushUniq(4);
					ml.pushUniq(5);
					break;
				case "2":
					if(m < 2) m = 2;
					ml.pushUniq(1);
					ml.pushUniq(2);
					break;
				case "3":
					if(m < 3) m = 3;
					ml.pushUniq(3);
					ml.pushUniq(6);
					break;
				case "4":
					ml.pushUniq(5);
					ml.pushUniq(6);
			}
		}
		switch(m){
			case 1:
				this.fbouille = this.fbouille.substr(0,6)+"02"+this.fbouille.substr(8,10);
				break;
			case 2:
				this.fbouille = this.fbouille.substr(0,6)+"03"+this.fbouille.substr(8,10);
				break;
			case 3:
				this.fbouille = this.fbouille.substr(0,6)+"04"+this.fbouille.substr(8,10);
				break;
		}
		ml.sort();
		
		this.winOpt.str = this.fbouille;
		this.winOpt.modifList = ml;
		this.title = Lang.fv("my_frutibouille");
		
		_global.uniqWinMng.setBox("editbouille",this);
	}
	
	function close(){
		_global.uniqWinMng.unsetBox("editbouille");
		super.close();
	}
	
	function tryToClose(){
		return false;
	}
	
	function preInit(){
		// called only at start of the first init
		this.desktopable = true;
		this.tabable = false;
		super.preInit();	
	}

	function init(slot,depth){
		var rs = super.init(slot,depth);

		if(rs){
			// first init
		}else{
			// change mode init
		}

		return rs;
	}
	
	function validate(fbouille){
		if(this.flLoading) return;
		
		if(!this.window.hasTouchAllButton()){
			_global.openAlert(Lang.fv("edit_bouille.must_touch_all_buttons"),Lang.fv("warning"));
			return;
		}
		
		this.flLoading = true;
		this.fbouille = fbouille;
		var l = new HTTP("do/eb",{b: fbouille},{type: "loadVars",obj: this,method: "onEB"});
	}
	
	function onEB(success,vars){
		this.flLoading = false;
		if(vars.k == "0"){
			_global.mainCnx.cmd("fbouille",{f: this.fbouille});
			this.close();
		}else{
			_global.openErrorAlert(Lang.fv("error.http."+vars.k));
		}
	}

}
