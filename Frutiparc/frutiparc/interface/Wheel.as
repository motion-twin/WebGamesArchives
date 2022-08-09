class Wheel extends MovieClip{//}

	// VARIABLE 
	var flMove:Boolean;
	var flLoadComplete:Boolean;
	var flLoadInit:Boolean;
	var wheelId:Number
	var rot:Number;
	var skin:MovieClip;
	var mcl:FEMCLoader;
	var mng:cp.WheelMng;
	var animList:AnimList;
	
	function Wheel(){
		
	}

	function initDefault(){
		if( this.flMove == undefined ) this.flMove = true;
	}
	
	function init(){
		this.initDefault();
		this.loadSkin();
	}
	
	function wheelInit(){
		//_root.test+="wheelInit()\n"
	}
	
	function loadSkin(){
		this.flLoadComplete=false;
		this.flLoadInit=false;		
		this.createEmptyMovieClip("skin",1)
		this.mcl = new FEMCLoader();
		
		var listener = new Object();
		listener.fbObj = this;
		listener.onLoadInit = function(mc) {
			//_root.test+="loadInit("+this.flLoadComplete+")\n"
			this.fbObj.flLoadInit = true;
			if(this.fbObj.flLoadComplete)this.fbObj.wheelInit();
		}
		listener.onLoadComplete = function(mc){
			//_root.test+="loadComplete("+this.flLoadInit+")\n"
			this.fbObj.flLoadComplete = true;
			if(this.fbObj.flLoadInit)this.fbObj.wheelInit();
		}
		listener.onLoadError = function(mc, errorCode) {
			//_root.test+="errorCode:"+errorCode+"\n"
		}

		this.mcl.addListener(listener)
		this.mcl.loadClip(FEString.formatVars(Path.wheel,{i: this.wheelId}),this.skin)
	}
	
	function setRot(deg){
		this._rotation = deg
	}
	
	function update(){
	
	};
	
	function startUpdateLoop(){
		this.animList.addAnim("update",setInterval(this,"update",25))
		
	}
	
	function onBaseTurn(){
	
	}

	function kill(){
		this.removeMovieClip();
	}	
	
	
//{
}