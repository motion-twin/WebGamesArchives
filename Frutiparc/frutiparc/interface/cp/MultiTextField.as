class cp.MultiTextField extends Component{//}
	
	var flVersicolor:Boolean;	
	var maxDisplayed:Number;
	var lineSpacing:Number;
	//var flBackground:Boolean;
	
	var flBold:Boolean;
	
	var last:MovieClip;
	var dropBox;
	var color:Number;
	
	var defaultFont:String = "Verdana";
	
	/*-----------------------------------------------------------------------
		Function: MultiTextField()
		constructeur;
	 ------------------------------------------------------------------------*/	
	function MultiTextField(){
		this.init()
	}

	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		//_root.test += "multiTextField init\n"
		if(this.maxDisplayed == undefined) this.maxDisplayed = _global.userPref.getPref("cache_length");
		if(this.maxDisplayed == undefined) this.maxDisplayed = 50;
		if(this.lineSpacing == undefined) this.lineSpacing = 2;
		super.init();
		if(this.flVersicolor == undefined ) this.flVersicolor=false;
		if(this.color == undefined)this.color = this.style.color[0].overdark //this.color=0x000000;
		
		this.content.win = this.win;
	}
	
	/*-----------------------------------------------------------------------
		Function: addText(str)
	 ------------------------------------------------------------------------*/	
	function addText(str,forceColor){
		var prev = this.last;
		if(prev == undefined){
			var id = 0;
			var realId = 0;
		}else{
			var id = (prev.id+1)%this.maxDisplayed;
			var realId = prev.id + 1;
		}
		if(this.content["tf_"+id] != undefined){
			this.content["tf_"+id].removeTextField();	
		}
		this.content.createTextField("tf_"+realId,10+id,prev._x,prev._y+prev.textHeight,this.width,prev._height);
		var tf = this.content["tf_"+realId];
		
		tf.id = realId;
		tf.multiline = true;
		tf.wordWrap = true;
		tf.html = true;
		tf.autoSize = "left";
		tf.textWidth = this.width;
		
		var col;
		if(forceColor != undefined){
			col = forceColor.toString(16);
		}else if(this.flVersicolor){
			col = FEObject.toColNumber({r:random(220),g:random(220),b:random(220)})
		}else{
			col = this.color.toString(16)
		}
		var htmlText = "<font color=\"#"+col+"\">"+str+"</font>";
		if(this.flBold)htmlText ="<b>"+htmlText+"</b>";
		
		
		tf.htmlText = htmlText;
		tf.myBox = this.win.box;
		tf.dropBox = this.dropBox;
		var tformat = new TextFormat();
		tformat.font = this.defaultFont;
		tformat.leading = this.lineSpacing;
		tf.setTextFormat(tformat);
		
		this.last = tf;
		
		//_root.test+="my TextField("+tf._width+","+tf._height+")\n"
		
		// TODO: voir pourquoi il y a un décalage d'une ligne...
		this.checkScrollBar("onTargetUpdate");

		// Merci de ne pas virer ce qui suit si on ne comprend pas exactement ce que ça fait !!!!	Non mais !
		// scroll not active => move content
		if(!this.mask.y.flScrollActive){
			var b = this.getContentBounds();
			this.content._y = -b.yMin;
		}

	};
	
	/*-----------------------------------------------------------------------
		Function: updateSize(str)
	 ------------------------------------------------------------------------*/	
	function updateSize(){
		
		
		//_root.test+="this.last.id : "+this.last.id+"\n"
		//_root.test+="Math.max(0,maxId - this.maxDisplayed) : "+Math.max(0,this.last.id - this.maxDisplayed)+"\n"

		super.updateSize();

		var maxId = this.last.id;
		if(maxId==undefined){
			maxId=0;
		}
		var minId = Math.max(0,maxId - this.maxDisplayed);
		
		//_root.test+="----\nmaxDisplayed"+this.maxDisplayed+"\n"
		//_root.test+="maxId"+maxId+"\n"
		//_root.test+="minId"+minId+"\n"		

		var prev_y = 0;
		for(var i=minId;i<=maxId;i++){
			var mc = this.content["tf_"+i];
			mc._y = prev_y;
			mc._width = this.width;
			prev_y = mc._y + mc.textHeight;
		};

		
		this.checkScrollBar("onTargetUpdate");
		
		// Merci de ne pas virer ce qui suit si on ne comprend pas exactement ce que ça fait !!!! Non mais !
		if(!this.mask.y.flScrollActive){
			var b = this.getContentBounds();
			this.content._y = -b.yMin;
		}

	};
	
	/*-----------------------------------------------------------------------
		Function: clean()
	 ------------------------------------------------------------------------*/	
	function clean(){
		if(this.last.id != undefined){
			var maxId = this.last.id;
		}else{
			var maxId = 0;
		}
		var minId = Math.max(0,maxId - this.maxDisplayed);
		for(var i=minId;i<=maxId;i++){
			this.content["tf_"+i].removeTextField();
		};
		this.last = undefined;
	};	

//{	
}
