class de.Url extends DocElement{//}
	
	// a recevoir
	var flLoadComplete:Boolean;
	var flResizable:Boolean;
	var url:String;
	var mcl:FEMCLoader;
	var content:MovieClip;
	var param:Object;
	
	function Url(){
		this.init()
	}
	
	function init(){
		//_root.test+="init deUrl\n"
		if(this.flResizable==undefined)this.flResizable=false;
		super.init();
	}

	/*--------------------------------------------------------------------
		function display()
	--------------------------------------------------------------------*/
	function display(){
		super.display();
		//_root.test+="this.display\n"
		this.createEmptyMovieClip("content",1)
		
		this.mcl = new FEMCLoader();
				
		var listener = new Object();
		
		listener.obj = this;
		listener.onLoadInit = function(mc) {
			//_root.test+="loadInit("+mc+")\n"
		}
		listener.onLoadComplete = function(mc){
			//_root.test+="loadComplete\n"
			this.obj.flLoadComplete = true;
			mc.flLoadComplete = true;
			for(var n in this.obj.param){
				mc[n] = this.obj.param[n];
			}
			
			//mc.init();
			
		}
		listener.onLoadError = function(mc, errorCode) {
			_root.test+="de.URL errorCode:"+errorCode+"\n"
		}

		this.mcl.addListener(listener)

		this.mcl.loadClip(this.url,this.content)

	}
	
	function update(){
		super.update();
		//_root.test+="updateSize("+this.pos.x+","+this.pos.y+","+this.pos.w+","+this.pos.h+")\n"
		if(this.flLoadComplete and this.flResizable){
			this.content._width = this.pos.w
			this.content._height = this.pos.h
		}
		
	}
	
	
	
//{
}






