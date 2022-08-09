
// ma bouille 0a0602000000020000

class Frutibouille extends MovieClip{//}

	var flTrace:Boolean;
	var flReady:Boolean;
	var flLoadComplete:Boolean;
	var flLoadInit:Boolean;
	var flJteCasse:Boolean
	//var strId:String;
	//var numId:Number;
	var id:String;
	var mcl:FEMCLoader;
	var face:MovieClip;
	var actionCallBack:Object;
	var animStopId:Number;
	//var actionList:Array;
	var loadInitCallback:Object;
	
	var actionBase:Object;
	var emoteBase:Number;
	
	
	var pos:Object;
	
	/*-----------------------------------------------------------------------
		Function: Frutibouille()
		constructeur
	 ------------------------------------------------------------------------*/	
	function Frutibouille(){
		//_root.test+="init Frutibouille("+this.id+")\n"
		this.init();
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		//_global.debug("Frutibouille.init(); [id: "+this.id+"]");
		//if(this.flTrace)_root.test+="[Frutibouille] init()\n";
		this.actionBase = {id:0}
		this.emoteBase = 0
		
		this.flReady = false;
		this.flLoadComplete = false;
		this.flLoadInit = false;
		this.createEmptyMovieClip("face",20);
		if(this.id!=undefined){
			this.loadBouille();
		}
	}	
	
	/*-----------------------------------------------------------------------
		Function: initBouille()
	 ------------------------------------------------------------------------*/	
	private function initBouille(){
		
		//if(this.flTrace)_root.test+="initBouille\n";
		
		this.flReady = true;
		
		this.face.parent = this;
		this.face.gotoAndStop("end")
		this.face.apply(this.id)
		this.face.applyEmote(this.emoteBase)
		this.action(this.actionBase.id,this.actionBase.length)

		//this.face.loadComplete = true;
		// VERIFIE QUE DES ACTIONS OU DES EMOTES N'ONT PAS ETE ENVOYE PENDANT LE CHARGEMENT
		
		/*
		var j = 0;
		while(this.actionList.length>0){
			j++;
			if(j > 20){
				_global.debug("WARN: fbouille infinite loop stopped !");
				break;
			}
			
			var a = this.actionList[0]
			//_root.test+="LOADINIT actionList[0] : a.type:"+a.type+"\n"
			if(a.type=="action"){
				this.action(a.id,a.length)
			}else if(a.type=="applyEmote"){
				this.action(0)
				this.applyEmote(a.id)
			}
			this.actionList.shift();
		}
		*/
		
		// APPEL UN CALLBACK SI BESOIN
		//if(this.flTrace)_root.test+="this.loadInitCallback("+this.loadInitCallback+")\n";
		if(this.loadInitCallback!=undefined){
			this.loadInitCallback.obj[this.loadInitCallback.method](this.loadInitCallback.args)
		}
	}
	
	/*-----------------------------------------------------------------------
		Function: loadBouille()
	 ------------------------------------------------------------------------*/	
	private function loadBouille(){
		//if(this.flTrace)_root.test+="loadBouille("+this.id+")\n";
		
		//if(typeof id == "string")id = FEString.decode62(id);
		//_global.debug("Frutibouille.loadBouille () [id: "+this.id+"]");

		this.mcl = new FEMCLoader();
		
		var listener = new Object();
		listener.fbObj = this;
		listener.onLoadStart = function(mc) {
			//_root.test+="onLoadStart()\n"
		}
		listener.onLoadInit = function(mc) {
			//_root.test+="onLoadInit("+this.fbObj.flLoadComplete+","+this.fbObj.flLoadInit+")\n"
			this.fbObj.flLoadInit=true;
			if(this.fbObj.flLoadComplete)this.fbObj.initBouille();
		}
		listener.onLoadComplete = function(mc){
			//_root.test+="onLoadComplete("+this.fbObj.flLoadComplete+","+this.fbObj.flLoadInit+")\n"
			this.fbObj.flLoadComplete=true;
			if(this.fbObj.flLoadInit)this.fbObj.initBouille();
		}
		listener.onLoadError = function(mc, errorCode) {
			_root.test+="errorCode:"+errorCode+"\n"
		}


		this.mcl.addListener(listener)
		
		//_root.test+="listener "+listener.onLoadStart+"\n"
		
		var s = this.id.substring(0,2)
		var famId = FEString.decode62(s);
		//_root.test+="famId "+famId+"\n"
		//_root.test+="this.mcl.loadClip "+this.mcl.loadClip+")\n"
		//_root.test+="this.mcl.loadClip("+FEString.formatVars(Path.frutibouille,{i: famId})+","+this.face+")\n"
		this.mcl.loadClip( FEString.formatVars(Path.frutibouille,{i: famId}), this.face )
	}	
	
	/*-----------------------------------------------------------------------
		Function: apply(id)
	 ------------------------------------------------------------------------*/	
	public function apply(id){
		//_global.debug("Frutibouille["+this.id+"].apply("+id+")");
		if(this.flLoadComplete){
			if(id.substr(0,2) != this.id.substr(0,2)){
				// this.face.unloadMovie(); devient -->
				//_global.debug("+ casseFace id("+id+")\n")
				this.face.removeMovieClip(); 
				this.id = id;
				this.flJteCasse = true;
				this.init();
			}else{
				this.face.apply(id);
				this.id = id;
			}			
		}else{
			this.id = id;
			if(this.mcl == undefined){
				this.loadBouille();
			}
		}
	}
	
	/*-----------------------------------------------------------------------
		Function: action(id,length)
	 ------------------------------------------------------------------------*/	
	public function action(id,length){
		//_global.debug("Frutibouille["+this.id+"].action("+id+","+length+")");
		//_root.test+="action reçue ! id:"+id+" length:"+length+" (this.face.loadComplete:"+this.face.loadComplete+")\n"
				
		if(!this.flReady){
			this.actionBase = {id:id,length:length}
			return;
		}
		
		if(id==0){
			clearInterval(this.animStopId);
		}
		this.face.action(id);
		if(length!=undefined){
			clearInterval(this.animStopId);
			this.animStopId = setInterval(this,"endLengthAnim",length*100);
			//_root.test+="interval length("+length+") id("+this.animStopId+")\n";
		}else{
			//if(id!=0)_root.test+="noLength!!!\n";
		}
	}
	
	function endLengthAnim(){
		this.action(0)
		this.endAnim();
	}
	
	/*-----------------------------------------------------------------------
		Function: endAnim()
	 ------------------------------------------------------------------------*/	
	function endAnim(){
		//_root.test+="endAnim\n"
		this.actionCallBack.obj[this.actionCallBack.method](this.actionCallBack.args)
	}	
	
	/*-----------------------------------------------------------------------
		Function: applyEmote(id)
	 ------------------------------------------------------------------------*/
	public function applyEmote(id){
		
		if(!this.flReady){
			this.emoteBase = id
			return
		}

		this.face.applyEmote(id);

	}

	/*-----------------------------------------------------------------------
		Function: onEndAction(id)
	 ------------------------------------------------------------------------*/		
	/*
	function onEndAction(id){
		if(this.actionCallBack!=undefined){
			this.actionCallBack.obj[this.actionCallBack.method](this.actionCallBack.args);
		}
	}
	*/

	function getInfo(){
		this.face.updateInfo();
		return this.face.info
	}
	
	/*-----------------------------------------------------------------------
		Function: update()
			Frutibouille devient utilisable comme docElement (de type link)
	 ------------------------------------------------------------------------*/		
	function update(){
		this._x = this.pos.x;
		this._y = this.pos.y;
		this._xscale = this.pos.w;
		this._yscale = this.pos.w;
	}
//{
}
