class box.Shop extends box.Standard{

	var currentItem:Object;
	var currentKikooz:Number;
	var alertBox;
	var displayedPack:Number;
  var currentPackName:String;
	
	function Shop(obj){
		this.winType = "winShop";
		//_root.test+="shopBox Contructor\n"
		for(var n in obj){
			this[n] = obj[n];
		}
		
		_global.uniqWinMng.setBox("shop",this);

    if(this.displayedPack != undefined){
      this.displayPack(this.displayedPack);
    }
	}
	
	function preInit(){
		// called only at start of the first init
		this.desktopable = true;
		this.tabable = true;
		this.title = Lang.fv("shop.title");
		super.preInit();	
	}

	function init(slot,depth){
		var rs = super.init(slot,depth);

		if(rs){
			// first init
			var loader = new HTTP("ft/tree",[],{type: "xml",obj: this,method: "onTree"});
			
			
			_global.me.addListener("kikooz",{obj: this,method: "onKikooz"});
			this.onKikooz(_global.me.kikooz);
		}else{
			// change mode init
		}

		return rs;
	}
	
	function close(){
		_global.me.removeListener("kikooz",this);
		_global.uniqWinMng.unsetBox("shop");
		super.close();
	}
	
	function onTree(success,node){
		if(!success){
			_global.debug("Unable to get the shop tree from server");
			this.window.displayError(Lang.fv("error.shop.tree"));
		}else{
			if(node.lastChild.nodeName != "c"){
				_global.debug("A valid ShopTree XML must starts with a node c");
				this.window.displayError(Lang.fv("error.shop.tree"));
			}else{
				this.window.setTree(this.analyseTree(node.lastChild));
				var dPack = Number(node.lastChild.attributes.d);
				/*	ET PAF LE GROS HACK !! - SOUS LE SOLEIL DE BELGIQUE ? 
          // Mettre ça dans le client !! Beurk beurk beurk !
					dPack = 5; 
				//*/
				if(!isNaN(dPack) && dPack != undefined){
          if(this.displayedPack == undefined)	this.displayPack(dPack);
				}
			}
		}
	}
	
	function analyseTree(node){
		var r = new Array();
		for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){
			if(n.nodeName == "c"){
				if(n.hasChildNodes()){
					r.push({text: n.attributes.n,list: this.analyseTree(n),bulletLink: "shopBullet"});
				}
			}else if(n.nodeName == "p"){
				r.push({text: n.attributes.n,action: {obj: this,method: "displayPack",args: Number(n.attributes.i)},bulletLink: "shopBullet"});
			}
		}
		return r;
	}
	
	function displayPack(id){
		this.displayedPack = id;
		var loader = new HTTP("ft/pack",{id: id},{type: "xml",obj: this,method: "onPack"});
		this.window.displayWait();
	}
	
	function onPack(success,node){
		if(!success){
			_global.debug("Unable to get the shop pack details from server");
			this.window.displayError(Lang.fv("error.shop.pack"));
		}else{
			if(node.lastChild.nodeName == "r" && node.lastChild.attributes.k != undefined){
				_global.debug("HTTP Error: "+Lang.fv("error.http."+node.lastChild.attributes.k));
				this.window.displayError(Lang.fv("error.http."+node.lastChild.attributes.k));
			}else if(node.lastChild.nodeName != "p"){
				_global.debug("A valid ShopPack XML must starts with a node p");
				this.window.displayError(Lang.fv("error.shop.pack"));
			}else{
				node = node.lastChild;
				var o = new Object();
				
				o.id = Number(node.attributes.i);
				o.name = node.attributes.n;
				//snif
				o.icon = node.attributes.i;
				//snif
				o.picto = node.attributes.p.split(",");
      
        if(o.picto[0] == "bouille"){
          o.picto = {
            type: "bouille",
            id: _global.me.fbouille.substr(0,14) + o.picto[1]
          };
        }
        
				o.quantity = Number(node.attributes.q);
				o.alreadyBuy = (node.attributes.h=="1");
        o.screens = new Array();
				for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){
					if(n.nodeName == "d"){
						o.description = n.firstChild.nodeValue.toString();
					}else if(n.nodeName == "r"){
						o.price = {price: Number(n.attributes.p),start: n.attributes.s,end: n.attributes.e,comment: n.firstChild.nodeValue.toString()}
					}else if(n.nodeName == "s"){
            var screen = {returnId: o.screens.length, title: n.attributes.n};
            for(var j=n.firstChild;j.nodeType>0;j=j.nextSibling){
               if(j.nodeName == "b"){
                  screen.big = {url: j.attributes.u, width: Number(j.attributes.w), height: Number(j.attributes.h)};
               }else if(j.nodeName == "t"){
                  screen.thumb = {url: j.attributes.u, width: Number(j.attributes.w), height: Number(j.attributes.h)};
               }
            }
            o.screens.push(screen);
          }
				}
				// ET MOI ALORS ON ME DIT JAMAIS RIEN !!
				this.window.displayItem(o);
				
				this.currentItem = o;
			}
		}
	}
	
	function buy(pack_id){
		_global.debug("Buy pack #"+pack_id);
		
		if(this.currentItem.id != pack_id){
			return _global.openErrorAlert(Lang.fv("error.shop.unknow_pack"));
		}
		
		if(this.alertBox != undefined && !this.alertBox.flClosed) return false;
		
		if(this.currentKikooz < this.currentItem.price.price){
			this.alertBox = new box.Alert({
				title: Lang.fv("shop.title"),
				text: Lang.fv("shop.not_enough_kikooz"),
				butActList: [{
						name: Lang.fv("cancel")
					},{
						name: Lang.fv("shop.obtain_kikooz"),
						action: {
							obj: this,
							method: "obtainKikooz"
						}
					}
				]
			});
			_global.topDesktop.addBox(this.alertBox);
		}else{
      this.currentPackName = this.currentItem.name;
			this.alertBox = new box.Alert(
				{
					title: Lang.fv("shop.title"),
					text: Lang.fv("shop.confirm_buy",{p: this.currentItem.price.price,n: this.currentItem.name}),
					butActList: [
						{
							name: Lang.fv("cancel")
						},
						{
							name: Lang.fv("shop.buy"),
							action: {
								obj: this,
								method: "doBuy",
								args: pack_id
							}
						}
					]
				}
			);
			_global.topDesktop.addBox(this.alertBox);
		}
	}
	
	function obtainKikooz(){
		_global.uniqWinMng.open("kikooz");
	}
	
	function doBuy(pack_id){
		var loader:HTTP = new HTTP("ft/buy",{i: pack_id},{type: "xml",obj: this,method: "onBuy"});		
	}
	
	function onBuy(success,xml){
		if(!success){
			return _global.openErrorAlert(Lang.fv("error.host_unreachable"));
		}
		
		xml = xml.firstChild;
		if(xml.nodeName != "r") return _global.openErrorAlert(Lang.fv("error.http.1"));
		
		if(xml.attributes.k != undefined && Number(xml.attributes.k) != 0){
			return _global.openErrorAlert(Lang.fv("error.http."+xml.attributes.k));
		}
		
		
		var kikooz = Number(xml.attributes.i);
		if(isNaN(kikooz) || kikooz == undefined){
			return _global.openErrorAlert(Lang.fv("error.http.1"));
		}
		
		_global.me.kikooz = kikooz;
	
		for(var n=xml.firstChild;n.nodeType>0;n=n.nextSibling){
			if(n.nodeName == "f"){ // folder
				_global.fileMng.callListeners(n.firstChild.nodeValue.toString(),"refresh");
			}else if(n.nodeName == "i"){ // item
				_global.me.addItem(n.firstChild.nodeValue);
      }else if(n.nodeName == "b"){
         _global.me.bouilleList.push({name: n.firstChild.nodeValue,bouille: n.attributes.b});
			}else{
				_global.debug("Unknow ft/buy modif response : "+n.nodeName);
			}
		}
		
		this.displayPack(this.displayedPack);
		
    _global.openAlert(Lang.fv("shop.buy_success",{n: this.currentPackName,k: kikooz}),Lang.fv("shop.buy_success_title"));
    
		this.window.onBuySuccess(kikooz);
	}
	
	function onKikooz(k){
		this.currentKikooz = k;
		this.window.setKikooz(k);
	}
	
	function onWheel(delta){
		this.window.scrollText(-10 * delta);
	}

  function displayScreenshot(id){
    //
    _global.desktop.addBox(
      new box.DocScreen({
        pos: {
          w: this.currentItem.screens[id].big.width,
          h: this.currentItem.screens[id].big.height
        },
        doc: new XML('<p><l><u u="'+this.currentItem.screens[id].big.url+'"/></l></p>'),
        title: this.currentItem.screens[id].title 
      })
    );

    
  }
}
