class Capsule extends MovieClip{//}

	var id:Number
	var box:Object;
	var tree:cp.Tree;
	var width:Number;
	var height:Number;
	var parent:MovieClip;
	var pos:Object;
	
	var bulletSize:Number;
	var bulletEcart:Number = 2;
	
	var but:but.TextBasic;
	var bullet:MovieClip;
	
	var style:Object;
	
	function Capsule(){
		//this.init();
	}

	function init(){
		
		this.pos={x:0,y:0}
		
		for( var element in this.box.textFormat ){
			this.style.ts.textFormat[element] = this.box.textFormat[element];
		}
		for( var element in this.box.fieldProperty ){
			this.style.ts.fieldProperty[element] = this.box.fieldProperty[element];
		}

		this.height = this.style.ts.textFormat.size+6
		
		this.initBullet();
		this.bulletSize = this.bullet._width + this.bulletEcart*2
		this.initBut();
		
		/*
		var marker:MovieClip();
		this.attachMovie("marker","marker",1020)
		marker._width = this.width;
		marker._height = this.height;
		*/
		
		
	}

	function initBullet(){
		var link;
		if( this.box.bulletLink != undefined ){
			link = this.box.bulletLink
		}else{
			link = this.style.bullet
		}
		this.attachMovie( link, "bullet", 1 )
		this.bullet._x = this.bullet._width/2 + this.bulletEcart;
		this.bullet._y = this.height/2;
		
		
		
	}

	function initBut(){
		var param = {
			text:this.box.text,
			width:this.width-this.bulletSize,
			textStyle:this.style.ts,
			behavior:"nothing"
		}
		this.attachMovie("butText", "but", 2, param);
		//_root.test+="this.bulletSize("+this.bulletSize+")\n"
		this.but._x = this.bulletSize;
	}
	
	function moveTo(y,flDirect){
		this.pos.y = y
		
		if(false or flDirect){
			this._y = this.pos.y
		}else{
			this.tree.animList.addSlide("slide"+this._name,this,{obj:this.tree,method:"updateScrollBar",args:"onTargetUpdate"},2);
		}
	}
	
	function fadeIn(){
		var color = FENumber.toColorObj(this.tree.style.color[0].main);
		FEMC.setPColor( this, color, 0 )
		this.tree.animList.addPaint( "paint"+this._name, this, color, 100 )
	}
	
	function getNextMark(){
		return this.pos.y + this.style.ts.textFormat.size + this.tree.space;
	}
	
	function getLevel(){
		var level = 0
		var mc = this
		while(mc.parent!=undefined){
			mc = mc.parent;
			level++;
		}
		return level;	
	}
	
	function kill(){
		this.tree.animList.remove("slide"+this._name)
		this.removeMovieClip();
	}
//{	
}




