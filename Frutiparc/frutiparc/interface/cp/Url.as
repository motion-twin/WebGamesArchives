class cp.Url extends Component{//}

	
	var mcl:MovieClipLoader;
	var flEmpty:Boolean;
	var flLoadComplete:Boolean;
	
	function Url(){
		this.init();
	}
	
	function init(){
		this.flEmpty = true;
	}
	
	function loadUrl(url, initObj){
		
		this.flLoadComplete = false;
		this.flEmpty = false;
		
		this.createEmptyMovieClip("content",1)
		
		this.mcl = new FEMCLoader();
				
		var listener = new Object();
		
		listener.obj = this;
		listener.initObj = initObj
		listener.onLoadInit = function(mc) {
			//_root.test+="loadInit("+mc+")\n"
		}
		listener.onLoadComplete = function(mc){
			//_root.test+="loadComplete\n"
			this.obj.flLoadComplete = true;
			this.flLoadComplete = true;
			for(var n in this.initObj ){
				mc[n] = this.initObj[n];
			}
		}
		listener.onLoadError = function(mc, errorCode) {
			_root.test+="cp.URL errorCode:"+errorCode+"\n"
		}
		this.mcl.addListener(listener)
		this.mcl.loadClip(url,this.content)		
	}
	
	
//{	
}