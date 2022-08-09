class Component extends MovieClip{
//}	
	var dpContent_wait =		101010;
	//
	var dp_scrollBarx = 		41;
	var dp_scrollBary = 		40;
	var dp_mask = 			30;
	var dp_content = 		20;
	//var dp_background = 		1;
	
	var flGravity:Boolean;
	var flMask:Boolean;
	var flBackground:Boolean;
	var flWait:Boolean;
	
	var mask:Object;
	var scrollInfo:Object;
	var pos:Object;
	var fix:Object;
	var min:Object;
	
	var width:Number;
	var height:Number;
	
	var extWidth:Number;
	var extHeight:Number;
	
	var margin:Object;
	
	var mainStyleName:String;
	var style:Object;
	var frame:Frame;
	
	// MOVIELCLIP
	var background:MovieClip;
	var win:MovieClip;
	var content:MovieClip;
	var mcMask:MovieClip;
	var scrollBarx:MovieClip;
	var scrollBary:MovieClip;
	
	//DEBUG
	var marker:MovieClip;
	var flTrace:Boolean;
	var flMarker:Boolean;
	
	/*-----------------------------------------------------------------------
		Function: init()
		constructeur fantome
	 ------------------------------------------------------------------------*/
	function Component(){
		if( this.mainStyleName == undefined ) this.mainStyleName = this.frame.mainStyleName;
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/
	function init(){
		// /!\ ATTENTION Y A DU CODE PLANQUE DANS LE CONSTRUCTEUR /!\
		
		if(this.flWait == undefined)this.flWait=false;
		this.style = this.win.style[this.mainStyleName]
		// _root.test += "this.win.style.global.color[0]("+this.win.style.global.color[0].main+")\n"
		// this.flMarker = true;
		if(this.fix != undefined){
			this.min = this.fix
		}
		
		if(this.min == undefined){
			
			this.min={w:0,h:0};
		}
		if(this.pos==undefined){
			this.pos = {x:0,y:0,w:this.min.w,h:this.min.h};
		};
		this.genContent();
		if(this.flWait)this.displayWait();
		if(this.flMask)this.initMask();
		if(this.flBackground){
			_root.test+="try to draw Component backGround... component("+this+")\n "
		};
		if(this.flGravity==undefined)this.flGravity=false;
		if(this.margin==undefined) this.margin = Standard.getMargin();
	}
	/*-----------------------------------------------------------------------
		Function: initMask()
	 ------------------------------------------------------------------------*/
	function initMask(){
		// Y'a pas a dire ce scrollInfo c'est vraiment le Bordel !
		if(this.scrollInfo==undefined){
			this.scrollInfo = {
				link:"sbRound",
				param:{
					color:{	
						fore:this.win.style.global.color[0],
						back:this.style.color[0]//this.style.color.inline
					},
					size:14,
					margin:{top:4,side:2}
				}
			}
		}
		this.scrollInfo.param.win = this.win;
		this.scrollInfo.param.flGravity=this.flGravity

		if(this.mask==undefined){
			this.mask={
				x:{
					flScrollable:false,
					flScrollActive:false
				},
				y:{
					flScrollable:true,
					flScrollActive:false
				}				
			}
		}
		/*
		this.mask = new Object();
		this.mask.flScrollActive=false;
		if(this.mask.flScrollable==undefined)this.mask.flScrollable=true;
		*/
		this.attachMask();

	}
	/*-----------------------------------------------------------------------
		Function: genContent()
	 ------------------------------------------------------------------------*/	
	function genContent(){
		if(this.flMarker)this.attachMovie("marker","marker",5)
		this.createEmptyMovieClip("content",this.dp_content)
	}
	/*-----------------------------------------------------------------------
		Function: attachMask()
	 ------------------------------------------------------------------------*/	
	function attachMask(){
		var link = "carre";
		if(this.mask.link!=undefined) link = this.mask.link;
		this.attachMovie("carre","mcMask",this.dp_mask);
		//_root.test+="this.mcMask("+this.mcMask+")\n"
		this.content.setMask(this.mcMask)
	}
	/*-----------------------------------------------------------------------
		Function: updateSize()
	 ------------------------------------------------------------------------*/	
 	function updateSize(){
		if(this.fix.w){
			this.width = this.fix.w
			this.extWidth = this.width + this.margin.x.min;
		}else if(this.extWidth != undefined){
			this.width = this.extWidth - this.margin.x.min;
		}else{
			this.extWidth = this.width + this.margin.x.min;
		}
		if(this.fix.h){
			this.height = this.fix.h;
			this.extHeight = this.height + this.margin.y.min;
		}else if(this.extHeight != undefined){
			this.height = this.extHeight - this.margin.y.min;
		}else{
			this.extHeight = this.height + this.margin.y.min;
		}
		
		/*
		if(this.flTrace){
			_root.test+="size("+this.width+","+this.height+") extSize("+this.extWidth+","+this.extHeight+")\n"
		}
		*/
		
		this.content._x = this.margin.x.min * this.margin.x.ratio;
		this.content._y = this.margin.y.min * this.margin.y.ratio;
		
		// Euh, c'est sur que c'est une fonctionnalité de base d'un component là ??
		// Ben c'est présent sur plusieurs composants plutots differents oui, je me suis dit
		// qu'une classe WaitableComponent n'etait pas indispensable...
		if(this.flWait){
			var mc = this.content.folderWaitMessage;
			mc._x = Math.round(this.width/2);
			mc._y = Math.round(this.height/2);
		}
		if(this.flMask)this.updateMask();
		// DEBUG
		if(this.flMarker){
			this.marker._width = this.width;
			this.marker._height = this.height;
		}		
	};
	/*-----------------------------------------------------------------------
		Function: drawBackground()
	 ------------------------------------------------------------------------*/	
	/*
	function drawBackground(){
		this.background.clear();
		var pos = {x:0,y:0,w:this.width,h:this.height};
		var style = this.style;
		this.background.drawCustomSquare(pos,style);	
	}
	*/
	/*-----------------------------------------------------------------------
		Function: updateMask()
	 ------------------------------------------------------------------------*/	
	function updateMask(){
		this.mcMask._x = this.margin.x.min * this.margin.x.ratio;
		this.mcMask._y = this.margin.y.min * this.margin.y.ratio;
	
		this.mcMask._width = this.width;
		this.mcMask._height = this.height;

		if(this.mask.x.flScrollActive){
			var mc = this.mask.x.path
			mc.onMaskUpdate();
		}
		if(this.mask.y.flScrollActive){
			var mc = this.mask.y.path
			mc.onMaskUpdate();
		}
		
		this.checkScrollBar()
	}
	/*-----------------------------------------------------------------------
		Function: getContentBounds()
	 ------------------------------------------------------------------------*/	
	function getContentBounds(){
		return this.content.getBounds()
	}
	/*-----------------------------------------------------------------------
		Function: kill()
	 ------------------------------------------------------------------------*/	
	function kill(){
		this.onKill();
		this.removeMovieClip("")
	}
	/*-----------------------------------------------------------------------
		Function: onKill()
	 ------------------------------------------------------------------------*/	
	function onKill(){
		//
	}

	/*-----------------------------------------------------------------------
		Function: displayWait()
	 ------------------------------------------------------------------------*/	
	function displayWait(){
		//_root.test+="displayWait()\n"
		this.content.attachMovie("folderWaitMessage","folderWaitMessage",this.dpContent_wait)
		var mc = this.content.folderWaitMessage
		var col = this.style.color[0].darker
		FEMC.setColor(mc,col)
		mc._x = Math.round(this.width/2);
		mc._y = Math.round(this.height/2);
		this.flWait=true;

	}
	
	/*-----------------------------------------------------------------------
		Function: removeWait()
	 ------------------------------------------------------------------------*/	
	function removeWait(){
		this.content.folderWaitMessage.removeMovieClip("");
		this.flWait=false;
	}	
		
	/*-----------------------------------------------------------------------
		Function: addScrollBar()
	 ------------------------------------------------------------------------*/	
	function addScrollBar(s){
		//_root.test+="addScrollBar("+s+")\n";
		this.scrollInfo.param.mask = {x:this.mcMask._x, y:this.mcMask._y, w:this.mcMask._width, h:this.mcMask._height};
		this.scrollInfo.param.component = this;
		this.scrollInfo.param.target = this.content;
		this.scrollInfo.param.dir=s;
		this.attachMovie( this.scrollInfo.link, "scrollBar"+s,this["dp_scrollBar"+s], this.scrollInfo.param );
		this.mask[s].flScrollActive =true;
		this.mask[s].path = this["scrollBar"+s];
		//this.updateMask();
		
		// Update width or height (internals)
		/*
		if(s == "x"){
			this.height -= this.mask.x.path.height;
		}else if(s == "y"){
			this.width -= this.mask.y.path.width;
		}
		*/
		
		if(s == "x"){
			this.margin.y.ratio = 0;
			this.margin.y.min = this["scrollBar"+s].height;
		}else{
			this.margin.x.ratio = 0;
			this.margin.x.min = this["scrollBar"+s].width;
		}
		
		this.updateSize();
	}
	
	/*-----------------------------------------------------------------------
		Function: rmScrollBar()
	 ------------------------------------------------------------------------*/	
	function rmScrollBar(s){
		FEMC.setPos(this.content,s,0)
		this.mask[s].path.removeMovieClip("")
		this.mask[s].flScrollActive=false;
		//this.updateMask();
		
		// Update width or height (internals)
		/*
		if(s == "x"){
			this.height += this.mask.x.path.height;
		}else if(s == "y"){
			this.width += this.mask.y.path.width;
		}
		*/

		if(s == "x"){
			this.margin.y.ratio = 0.5;
			this.margin.y.min = 0;
		}else{
			this.margin.x.ratio = 0.5;
			this.margin.x.min = 0;
		}
		
		this.updateSize();
	}
	
	/*-----------------------------------------------------------------------
		Function: updateScrollBar(mode)
	 ------------------------------------------------------------------------*/	
	function checkScrollBar(method){
		//_root.test+="updateScrollBar\n
		if(method==undefined)method="onMaskUpdate";
		
		var flUpdate = false;
		for(var i=0; i<2; i++){
			if(i==0){
				var s="x";
			}else{
				var s="y";
			}
			var b = this.mask[s]
			if(b.flScrollable){
				if(checkScrollNeed(s)){
					if(b.flScrollActive){
						b.path[method]();
					}else{
						this.addScrollBar(s)
						flUpdate=true;
					}
				}else{
					if(b.flScrollActive){
						this.rmScrollBar(s)
						flUpdate=true;
					}			
				}
			}
		}
		if(flUpdate)this.updateMask();

	}
	
	/*-----------------------------------------------------------------------
		Function: checkScrollNeed()
	 ------------------------------------------------------------------------*/	
	function checkScrollNeed(s){
		//_root.test+="checkScrollNeed : this.content._height("+this.content._height+") > this.mcMask._height("+this.mcMask._height+")"
		if(s=="x"){
			return this.content._width > this.mcMask._width;
		}else{
			return this.content._height > this.mcMask._height;	// a affiner
		}
	}

	/*-----------------------------------------------------------------------
		Function: resize(w,h)
	 ------------------------------------------------------------------------*/	
	function resize(w:Number,h:Number){
		var changed:Boolean = false;
		if(w != undefined){
			this.width = w;
			changed = true;
		}
		if(h != undefined){
			this.height = h;
			changed = true;
		}
		if(changed) this.updateSize();
	}
	

/*

	function addScrollBar(){
		//_root.test+="addScrollBar\n";
		this.scrollInfo.param.target = this.content;
		this.scrollInfo.param.mask = {y:this.mcMask._y, h:this.mcMask._height};
		this.scrollInfo.param.component = this;
		this.scrollInfo.param.mainStyleName = this.mainStyleName;
		this.attachMovie(this.scrollInfo.link,"scrollBar",this.dp_scrollBar,this.scrollInfo.param);
		//_root.test += "scrollBar("+this.scrollInfo.link+")>"+this.scrollBar+"\n"
		this.mask.flScrollActive =true;
		//this.updateSize();
		this.updateMask();

	};

	function rmScrollBar(){
		if(this.mask.flScrollActive){
			this.content._y=0
			this.scrollBar.removeMovieClip("")
			this.mask.flScrollActive=false;
			this.updateMask();
		}
	};
	
	function updateScrollBar(mode){
		//_root.test+="updateScrollBar\n"
		
		if(this.mask.flScrollable and this.checkScrollNeed() ){
			if(!this.mask.flScrollActive){
				this.addScrollBar();
			}else{
				this.scrollBar.mask={y:0, h:this.mcMask._height}
				this.scrollBar._x = this.mcMask._width
				this.scrollBar[mode]();
			}
			return true;
		}else{
			this.rmScrollBar();
		}
		return false;
	};
	
	function checkScrollNeed(){
		//_root.test+="checkScrollNeed : this.content._height("+this.content._height+") > this.mcMask._height("+this.mcMask._height+")"
		return this.content._height > this.mcMask._height;	// a affiner
	};
	
	
*/
	
	
//{
}





















