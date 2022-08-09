class cp.Test extends Component{

	var cw:Number;
	var ch:Number;
	var img:String;
	var mcImg:MovieClip;
	var mcl:FEMCLoader;
	
	/*-----------------------------------------------------------------------
		Function: Test()
		constructeur;
	 ------------------------------------------------------------------------*/	
	function Test(){
		//_root.test+="compoTest Init\n"
		if(this.cw==undefined)this.cw = 100;
		if(this.ch==undefined)this.ch = 100;
		this.init();
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		this.min = {w:10+random(100),h:10+random(100)}
		super.init();
		
		
		if(this.img != undefined){
			var mcl = new FEMCLoader();
			var myListener = {obj:this}
			myListener.onLoadInit = function(){
				this.obj.updateSize();
			};
			mcl.addListener(myListener);
			this.content.createEmptyMovieClip("mcImg",1);
			mcl.loadClip(this.img,this.content.mcImg);
			//this.content.mcImg.loadMovie(img);
		}else{
			this.content.clear();
			var pos = {x:0,	y:0,	w:this.cw,	h:this.ch}
			FEMC.drawSquare(this.content,pos,random(0xFFFFFF))
			this.content._alpha=40;
		}
	}
	
	/*-----------------------------------------------------------------------
		Function: updateSize()
	 ------------------------------------------------------------------------*/	
	function updateSize(){
		super.updateSize();
	}
}


