class box.NewBouille extends box.Standard{
	
	function NewBouille(obj){
		this.winType = "winNewBouille";
		for(var n in obj){
			this[n] = obj[n];
		}
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
		}else{
			// change mode init
		}

		return rs;
	}

  function sendBouille(value,name,qty,price){
		_global.debug("FB Value: "+value);
    value = value.substr( value.length-10, 10 );
    var load = new HTTP("do/newbouille",{v: value,p: price,n: name,q: qty},{type: "xml",obj: this,method: "onSend"});
    this.window.displayWait();
  }

  function onSend(success,xml){
    xml = xml.firstChild;
   
    this.window.removeWait();
    
    if(!success || xml.nodeName != "r"){
      return _global.openErrorAlert(Lang.fv("error.http.1"));
    }

    if(xml.attributes.k != undefined && Number(xml.attributes.k) > 0){
      return _global.openErrorAlert(Lang.fv("error.http."+xml.attributes.k));
    }
    
    if(xml.attributes.k == 0){
      return _global.openAlert(Lang.fv("newbouille.ok"),Lang.fv("newbouille.title_ok"));
    }
  }
	
	// Called on window closing
	// This method MUST call super.close()
	function close(){
		super.close();
	}
	
	// Called when an element want to close the window
	// This function can call this.close() or not...
	function tryToClose(){
		this.close();
	}

}
