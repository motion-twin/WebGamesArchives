class ScrollBar extends MovieClip{//}
	
	// A RECEVOIR
	var dir:String;
	var margin:Object;
	var minSquareSize:Number;
	var flGravity:Boolean;
	var flPosPriority:Boolean;
	var size:Number;
	
	// VARIABLES
	var dirSize:String;
	var dirSizeLong:String;
	var fir:String;
	var firSize:String;
	var firSizeLong:String;
	var mainStyleName:String;
	var mask:Object;
	var posRatio:Number;
	var sizeRatio:Number;
	var target_pos:Number;
	var target_dpos : Number;
	var target_size:Number;
	var long:Number;
	var squareLong:Number;
	

	
	//MOVIECLIP
	var target:MovieClip;
	var component:Component;
	var square:MovieClip;
	var bg:MovieClip;
	var win:MovieClip;
	
	
	function ScrollBar(){
		this.init();
	}
	
	function init(){
		
		//_root.test+="scrollBar("+this.dir+")\n"
		
		if(this.dir == undefined){
			this.dir = "y";
		}
		if(this.minSquareSize == undefined){
			this.minSquareSize = 0;
		}		
		if(this.mainStyleName == undefined){
			this.mainStyleName = "content";
		}		
		if(this.dir == "y"){
			this.fir = "x"
			this.dirSize = "h";
			this.firSize = "w";
			this.dirSizeLong = "height";
			this.firSizeLong = "width";
		}else{
			this.fir = "y";
			this.dirSize = "w";
			this.firSize = "h";
			this.dirSizeLong = "width";
			this.firSizeLong = "height";
		}
	
		// INIT MARGIN :
		if(this.margin==undefined){
			this.margin = {side:0, top:0};
		}	
		
		// INIT DE FLAG DOUTEUX :
		if(this.flGravity == undefined){
			this.flGravity = false;
		};
		if(this.flGravity){
			this.posRatio = 1;
		}else{
			this.posRatio = 0;
		};
		if(this.flPosPriority == undefined){
			this.flPosPriority=true;
		};	
		
		
		// INIT SQUARE :
		
		this.initSquare()
		this.square.onPress = function(){
			this._parent.squarePress();
		};
		this.square.onRelease = function(){
			this._parent.squareRelease();
		};
		this.square.onReleaseOutside = this.square.onRelease;
		this.square.useHandCursor = false;
		
		
		// INIT BG
		this.bg.onRelease = function(){
			this._parent.bgPress();
	
		};
		this.bg.useHandCursor = false;
		

		this.setTargetBounds();		
	}
	
	function onMaskUpdate(){
		//_root.test+="onMaskUpadate\n"
		this.mask = {
			x:this.component.mcMask._x,
			y:this.component.mcMask._y,
			w:this.component.mcMask._width,
			h:this.component.mcMask._height
		}
		
		this.buildScrollBar();
		this.checkLimit();
		this.sizeRatio = this.mask[this.dirSize] / this.target_size;
		if(this.flPosPriority){
			this.moveTarget();
		}else{
			this.posRatio = ( this.mask[this.dir] - this.target_pos ) / (this.target_size-this.mask[this.dirSize]);
		}
		this.updateSquare();
	};
	
	function onTargetUpdate(){
		
		//_root.test+="onTargetUpdate\n"
		if(this.flGravity){
			this.posRatio=1;
		}
		this.setTargetBounds();
		this.checkLimit();
		this.sizeRatio = this.mask[this.dirSize] / this.target_size;
		if(this.flPosPriority){
			this.moveTarget();
		}
		this.updateSquare();	
	};
	
	function setTargetBounds(){
		//d'ou sorte getPos et setPos ?
		var b = this.component.getContentBounds();
		
		this.target_size = b[this.dir+"Max"] - b[this.dir+"Min"];
	
		this.target_pos = this.target.getPos(this.dir) + b[this.dir+"Min"];
		this.target_dpos = b[this.dir+"Min"];
		if(!this.flPosPriority){
			this.posRatio = (-this.target.getPos(this.dir) + this.mask[this.dir] + b[this.dir+"Min"]) / (this.target_size-this.mask[this.dirSize]);
		}
	};
	
	function checkLimit(){
		if(this.target_pos>this.mask[this.dir]){
			var dif = this.mask[this.dir] - this.target_pos;
			this.target.setPos(this.dir,this.target.getPos(this.dir) + dif);
			this.setTargetBounds();
		}
		if( ( this.mask[this.dir] - this.target_pos ) > (this.target_size-this.mask[this.dirSize]) ){
			var dif = (this.target_size-this.mask[this.dirSize])-( this.mask[this.dir] - this.target_pos )
			this.target.setPos(this.dir,this.target.getPos(this.dir) - dif);
			this.setTargetBounds();
		}	
	};
	
	function updateSquare(){
		this.resizeSquare();
		//_root.test+="updateSquare("+this.mask[this.firSize]+this.margin.side+")\n"
		FEMC.setPos( this.square, this.fir, this.mask[this.firSize]+this.margin.side )
		FEMC.setPos( this.square, this.dir, this.margin.top + (this.long-this.squareLong) * this.posRatio )
		
	};
	
	function updateTarget(){
		//_root.test += "release at : "+this.square._y+"\n"
		this.posRatio = (FEMC.getPos(this.square,this.dir) - this.margin.top) / (this.long-this.squareLong);
		this.moveTarget();
	};
	
	function resizeSquare(){
		this.squareLong = Math.max( Math.round(this.long * this.sizeRatio), this.minSquareSize )
	};
	
	function buildScrollBar(){
		this.long = this.mask[this.dirSize]-(this.margin.top*2)
	};
	
	function pageScroll(sens){
		var run = this.mask[this.dirSize] / (this.target_size-this.mask[this.dirSize]);
		this.posRatio = Math.min(Math.max(this.posRatio+run*sens,0),1)
		this.updateSquare();
		this.moveTarget();
	};
	
	function pixelScroll(delta){
		var run = 1 / (this.target_size-this.mask[this.dirSize]);
		this.posRatio = Math.min(Math.max(this.posRatio+run*delta,0),1)
		this.updateSquare();
		this.moveTarget();
	}
	
	function moveTarget(){
		/*
		_root.test+="this.target.setPos("+this.dir+","+(this.mask[this.dir] - this.posRatio * (this.target_size-this.mask[this.dirSize]) - this.target_dpos)+");\n"
		_root.test+="this.mask[this.dir]("+this.mask[this.dir]+")\n"
		_root.test+="this.posRatio("+this.posRatio+")\n"
		_root.test+="this.target_size("+this.target_size+")\n"
		_root.test+="this.mask[this.dirSize]("+this.mask[this.dirSize]+")\n"
		_root.test+="this.target_dpos("+this.target_dpos+")\n"
		*/
		this.target.setPos(this.dir,this.mask[this.dir] - this.posRatio * (this.target_size-this.mask[this.dirSize]) - this.target_dpos);
		this.setTargetBounds()
	};
	
	function squarePress(){
		var m = new Object();
		m[this.fir] = this.mask[this.firSize]+this.margin.side;	// bug de barre en x  = this.mask[this.firSize] a virgule
		m[this.dir] = this.margin.top;
		m[this.firSize] = this.mask[this.firSize]+this.margin.side
		m[this.dirSize] = this.long-this.squareLong+m[this.dir];
		//_root.test+="dragSquare("+m.x+","+m.y+","+m.w+","+m.h+")\n"
		this.square.startDrag( false, m.x, m.y, m.w, m.h );
	}
	
	function squareRelease(){
		stopDrag()
		this.updateTarget();	
	}
	
	function bgPress(){
		if(this._ymouse<this.square._y){
			this.pageScroll(-1)	
		}else{
			this.pageScroll(1)
		};
	};
	
	
	function initSquare(){

	}
	
//{	
}











