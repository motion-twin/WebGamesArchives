class cp.ProductMenu extends Component{//}
	
	// CONSTANTES
	var dp_button:Number = 100
	var dp_screen:Number = 2
	
	// VARIABLES
	var flShopItemLoaded:Boolean;
	var butList:Array;
	var picto:Object;
	
	var mcl:FEMCLoader;
	
	/*-----------------------------------------------------------------------
		Function:  ProductMenu()
	------------------------------------------------------------------------*/	
	function ProductMenu(){
		this.init();
	}	

	/*-----------------------------------------------------------------------
		Function:  init()
	------------------------------------------------------------------------*/	
	function init(){
		
		this.flShopItemLoaded=false;
		
		this.min={w:100,h:300};
		//_root.test+="cp.ProductMenu init\n"
		super.init();
		//this.initButList();	// a recevoir en parametre
		//this.genButList();
		
	}

	/*-----------------------------------------------------------------------
		Function:  genContent()
	------------------------------------------------------------------------*/	
	function genContent(){
		super.genContent();
		this.genScreen();
		//this.genButList();
	}

	/*-----------------------------------------------------------------------
		Function:  genScreen()
	------------------------------------------------------------------------*/
	function genScreen(){
		this.content.attachMovie("shopScreen","screen",this.dp_screen);
		this.content.screen.attachMovie("shopScreenLight","screen",10);
		this.content.screen._y = 4;
	};

	/*-----------------------------------------------------------------------
		Function:  genButList()
	------------------------------------------------------------------------*/	
	function genButList(){
		for(var i=0; i<this.butList.length; i++){
			var o = this.butList[i];
			if(o.name!=undefined){
				var param = {
					link:"butPushShop",
					initObj:{txt:o.name},
					buttonAction:{onRelease: [o.action]},
					curve:8,
					color:this.style.color[0].shade
					
				};
				//_root.test+="this.mainStyleName = "+this.mainStyleName+"\n"
				//_root.test+="attach butPushShop\n";
				this.content.attachMovie("butPush","but"+i,this.dp_button+i,param);
				var mc = this.content["but"+i];
				mc._y  = 110+i*22;
				mc._x = (100-mc._width)/2;
			};
		}
	}
	
	/*-----------------------------------------------------------------------
		Function:  remButList()
	------------------------------------------------------------------------*/		
	function remButList(){
		for(var i=0; i<this.butList.length; i++){
			this.content["but"+i].removeMovieClip();
		}
	}
	
	/*-----------------------------------------------------------------------
		Function:  setButList(butList:Array)
	------------------------------------------------------------------------*/		
	function setButList(arr){
		this.remButList();
		this.butList = arr;
		this.genButList();
	};

	/*-----------------------------------------------------------------------
		Function:  setItem(picto:Array,butList:Array)
	------------------------------------------------------------------------*/		
	function setItem(picto,butList){	
		/* HACK TEST
		picto = {
			type:"bouille",
			id:"0007060g000b090000"
		}
		//*/
		//this.content.screen.shopItem.removeMovieClip();
		this.picto = picto;
		//_root.test += "[ProductMenu]"+this.picto.type+"\n"
		switch(this.picto.type){
			
			case "bouille":
				this.loadFrutibouille();
				break;
			default:
				this.loadShopItem();
				break;
			
			
		}
		
		this.setButList(butList);		
	};
	
	function loadFrutibouille(){
		//_root.test+="[ProductMenu] loadFrutibouille()\n"
		//this.content.screen.createEmptyMovieClip("shopItem",5)
		var initObj = {
			flTrace:true,
			id:this.picto.id			
		}
		this.content.screen.shopItem.attachMovie( "frutibouille", "fb", 5, initObj );

		//_root.test+=">"+this.content.screen+"\n"
	}	
	
	/*-----------------------------------------------------------------------
		Function:  loadShopItem()
	------------------------------------------------------------------------*/		
	function loadShopItem(){	
		//_root.test+="loadShopItem()\n"
		this.content.screen.shopItem.createEmptyMovieClip("trg",5)
		
		this.mcl = new FEMCLoader();
		
		var listener = new Object();
		listener.obj = this;
		listener.onLoadInit = function(mc) {
			mc.infoList = this.obj.picto;
			mc.gotoAndStop(this.obj.picto[0]);
			mc.item.gotoAndStop(this.obj.picto[1]);
		}
		listener.onLoadComplete = function(mc){
			this.obj.flShopItemLoaded = true
			//_root.test+="loadComplete\n"
		}
		listener.onLoadError = function(mc, errorCode) {
			_root.test+="errorCode:"+errorCode+"\n"
		}

		this.mcl.addListener(listener)
		this.mcl.loadClip(Path.shopItem,this.content.screen.shopItem.trg)		
	};
	
	
//{
}




























