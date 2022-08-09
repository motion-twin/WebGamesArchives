class box.Search extends box.Standard{

	private var countryList:Array;
	private var countryKey:Array;
	private var regionList:Array;
	private var regionKey:Array;
  
	private var flLoading:Boolean;
  private var currentSearch:Object;

  private var nbPerPage:Number;
  private var nbResult:Number;  

	function Search(obj){
		this.winType = "winSearchFrutiz";
		
		for(var n in obj){
			this[n] = obj[n];
		}

    this.flLoading = false;

    this.title = Lang.fv("search.title");

		this.countryList = [Lang.fv("search.country_combo_title")];
		this.countryKey = [undefined];
		for(var n in _global.langText.countries){
			this.countryList.push(_global.langText.countries[n].name);
			this.countryKey.push(n);
		}
		this.regionList = [Lang.fv("search.choose_country_first")];
		this.regionKey = [undefined];    

    _global.mainCnx.addListener("searchuser",this,"onSearch");
    _global.uniqWinMng.setBox("search",this);

    if(this.winOpt==undefined) this.winOpt = new Object();
    this.winOpt.flAdvanceAvailable = _global.me.hasItem(833);
	}

	function onCountryChange(){
    _global.debug("box.onCountryChange");
		var country = this.countryKey[this.window.getInput("country")];
		if(country == undefined){
			this.regionList = [Lang.fv("search.choose_country_first")];
			this.regionKey = [undefined];
		}else{
			var o = _global.langText.countries[country];
			if(o.regionNb == 0){
				this.regionList = [Lang.fv("search.region_combo_none")];
				this.regionKey = [undefined];
			}else{
				this.regionList = [Lang.fv("search.region_combo_title",{n: o.regionName.toLowerCase()})];
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
		// called only at start of the first init
		this.desktopable = true;
		this.tabable = true;
		super.preInit();	
	}

	function init(slot,depth){
		var rs = super.init(slot,depth);

		if(rs){
			this.window.infoRegion = this.regionList.join(";");
      this.window.infoCountry = this.countryList.join(";");

      _global.debug("HasItem: "+_global.me.hasItem(833));

		}else{
			// change mode init
		}

		return rs;
	}
	
	// Called on window closing
	// This method MUST call super.close()
	function close(){
    _global.mainCnx.removeListenerCmdObj("searchuser",this);
    _global.uniqWinMng.unsetBox("search");
    super.close();
	}
	
	// Called when an element want to close the window
	// This function can call this.close() or not...
	function tryToClose(){
    if(this.flLoading) return false;

		this.close();
	}

  function onAdvanceSearch(b){
    if(b){
       _global.me.useFrutibouille("Bananocle");
    }else{
       _global.me.useFrutibouille("Normal"); 
    }
  }

  function launchSearch(obj){
    if(this.flLoading) return false;
//    _global.debug("blocMax: "+this.window.blocMax);
    this.nbPerPage = this.window.blocMax;    
    
    var sObj = new Object();

    sObj.s = 0;
    sObj.l = this.nbPerPage;

    if(obj.pseudo.length >= 2){
      sObj.u = obj.pseudo;
    }
    if(obj.gender.length){
      sObj.sx = obj.gender;
    }
   
    var dObj = _global.servTime.getCompleteObject(); 
    var cYear = Number(FEString.formatVars("$Y",dObj));
    
    if(obj.ageMin.length){
      var a = Number(obj.ageMin);
      
      if(a > 0){
         sObj.bdm = (cYear - a)+FEString.formatVars("-$N-$D",dObj);
      }
    }

    if(obj.ageMax.length){
      var a = Number(obj.ageMax);

      sObj.bd = (cYear - a - 1)+FEString.formatVars("-$N-$D",dObj);
    }

    if(obj.city.length){
      sObj.ct = obj.city;
    }

    // country, region
    if(this.countryKey[obj.country] != undefined){
      sObj.co = this.countryKey[obj.country];

      if(this.regionKey[obj.region] != undefined){
        sObj.rg = this.regionKey[obj.region];
      }
    }

    this.currentSearch = sObj;
    this.flLoading = true;
    _global.mainCnx.cmd("searchuser",sObj);
  }

  function nextPage(){
    if(this.flLoading) return false;
    this.nbPerPage = this.window.blocMax;
    
    if(this.currentSearch.s >= this.nbResult - this.nbPerPage) return false;
  
    this.currentSearch.s = Math.min(this.currentSearch.s + this.nbPerPage,this.nbResult);
    this.flLoading = true;    
    _global.mainCnx.cmd("searchuser",this.currentSearch);

    return true;
  }

  function prevPage(){
    if(this.flLoading) return false;
    this.nbPerPage = this.window.blocMax;    

    if(this.currentSearch.s <= 0) return false;

    this.currentSearch.s = Math.max(0,this.currentSearch.s - this.nbPerPage);
    this.flLoading = true;    
    _global.mainCnx.cmd("searchuser",this.currentSearch);    

    return true;
  }

  function onSearch(node){
    this.flLoading = false;
  
    if(node.attributes.k != undefined){
      _global.openErrorAlert(Lang.fv("error.cbee."+node.attributes.k));
      return false;
    }

    var page = Math.ceil(Number(node.attributes.s)/this.nbPerPage+1);
    if(node.attributes.s == "0"){
      this.nbResult = Number(node.attributes.n);
    }

    var list = new Array();
    
    for(var n=node.firstChild;n.nodeType;n=n.nextSibling){
      
      var o = UserMng.formatInfoBasic(n);
      
      o.fbouille = n.attributes.f;
      o.city = n.attributes.ct;
      o.presence = Number(n.attributes.p);
      if(n.attributes.s != undefined){
         o.status = StatusMng.analyseStr(n.attributes.s);
      }else{
         o.status = new Object();
      }
      list.push(o);
      
    }
    
    
    this.window.displayBloc(list,page,this.nbResult);
  }

}
