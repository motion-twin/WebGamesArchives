class fc.Slot extends MovieClip{//}

	// CONSTANTES
	var dp_content:Number = 10;
	var dp_bg:Number = 4;
	
	// VARIABLES
	var flOpen:Boolean;
	var col:Object;
	var id:Number;
	var width:Number
	var big:Number;
	var type:String;
	var pos:Object;
	var trg:Object
	var animList:AnimList;
	
	// REFERENCES
	var root:FrutiConnect;
	var room:fc.Room;
	
	// MOVIECLIP
	var content:MovieClip;
	var bg:MovieClip;

	
	function Slot(){

	}
	
	function init(){
		//_root.test+="initSlot("+this.col+")\n"
		this.pos={x:0,y:0,w:0,h:0}
		this.trg={x:0,y:0,w:0,h:0}
		this.animList = new AnimList();
		this.initBg();
	}
	
	function genContent( link, initObj ){
		//_root.test+="genContent()\n"
		this.content.kill();
		if(initObj==undefined)initObj = new Object();
		initObj.slot = this;
		initObj.root = this.root;
		initObj.col = this.col;
		this.attachMovie(link,"content",1,initObj);
		//_root.test+="[Slot] genContent() content:"+this.content+" link:"+link+"\n"
		this.type = link
	}
	
	function updateContent(){
		this.content.size.w = this.pos.w
		this.content.size.h = this.pos.h
		//_root.test+="this.content.update("+this.content.update+")\n"
		this.content.update();

	}
	
	function killContent(){
		this.content.kill();
		delete this.type;
	}
	
	function initBg(){
		this.createEmptyMovieClip("bg",this.dp_bg)
		
	};
	
	function update(){
		this.updatePos();
		this.updateSize();
	}
	
	function updatePos(){
		this._x = this.pos.x
		this._y = this.pos.y
	}
	
	function updateSize(){
		//
		this.clear();
		var pos = {x:0, y:0, w:this.pos.w, h:this.pos.h }
		FEMC.drawSquare(this,pos,this.col.main)
		this.bg._alpha=10
		this.bg._width = this.pos.w
		this.bg._height = this.pos.h
		//
		//
	}	
	
	function initMove(){
		this.animList.addAnim("move",setInterval(this,"move",25));
	}
	
	function move(){
		var ratio = 2;
		var c = Math.pow(0.8,_global.tmod*ratio);
		this.pos.x = this.pos.x*c + this.trg.x*(1-c);
		this.pos.y = this.pos.y*c + this.trg.y*(1-c);
		this.pos.w = this.pos.w*c + this.trg.w*(1-c);
		this.pos.h = this.pos.h*c + this.trg.h*(1-c);	
		this.update();
		if(Math.round(this.pos.x)==Math.round(this.trg.x) and 
		   Math.round(this.pos.y)==Math.round(this.trg.y) and 
		   Math.round(this.pos.w)==Math.round(this.trg.w) and 
		   Math.round(this.pos.h)==Math.round(this.trg.h) ){
			this._x = this.trg.x
			this._y = this.trg.y
			this.animList.remove("move")
			this.content._visible = this.flOpen
			if(this.flOpen){
				delete this.onPress
			}else{
				this.onPress = function(){
					this.toggle();
				}
			}
			this.updateContent()
				
		}
	}
	
	function toggle(){
		//_root.test+="toggle!\n"
		this.flOpen = !this.flOpen
		this.room.updateSlotTarget();
	}
	


	
//{
}