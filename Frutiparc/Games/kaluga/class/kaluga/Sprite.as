class kaluga.Sprite extends MovieClip{//}

	// VARIABLES
	var flGround:Boolean;
	var flFreeze:Boolean
	
	var x:Number;
	var y:Number;
	var vitx:Number;
	var vity:Number;
	var depth:Number;
	var groundId:Number;	

	var type:String;

	//REFERENCES
	var gList:Array;
	var game
	var map:kaluga.Map;
	
	function Sprite(){
		//this.init();
	}
	
	function init(){
		this.map = this.game.map;
		this.initDefault();
	}
	
	function initDefault(){
		if(this.x == undefined)		this.x = 0;
		if(this.y == undefined)		this.y = 0;
		if(this.vitx == undefined)	this.vitx = 0;
		if(this.vity == undefined)	this.vity = 0;	
		if(this.flFreeze == undefined)	this.flFreeze = false;	
	}
	
	function update(){
	
		/* TEST GROUND ID MODE
		if( this.groundId != undefined ){
			var c = this.game.groundCaseSize
			var x = this.groundId * c
			var y = this.map.height - this.map.groundLevel;
			this.game.debugDraw.lineStyle()
			this.game.debugDraw.beginFill(0xFF0000,40)
			this.game.debugDraw.moveTo( x,		y-c	)
			this.game.debugDraw.lineTo( x+c,	y-c	)
			this.game.debugDraw.lineTo( x+c,	y	)
			this.game.debugDraw.lineTo( x,		y	)
			this.game.debugDraw.lineTo( x,		y-c	)
			this.game.debugDraw.endFill()
		
		}
		//*/
		
	}
	
	function endUpdate(){
 		/*
		if(this.type=="Bird"){
			_root.test="position("+this.x+","+this.y+")\n"
			_root.test+="this.game.mapDecal("+this.game.mapDecal.x+","+this.game.mapDecal.y+")\n"
			_root.test+="this.flFreeze("+this.flFreeze+")\n"
		}
		*/
		if(!this.flFreeze){
			//if(this.type=="Tzongre")_root.test+="this.x("+this.x+") + this.game.mapDecal.x("+this.game.mapDecal.x+");\n";
			this._x = this.x + this.game.mapDecal.x;
			this._y = this.y + this.game.mapDecal.y;	
		}
	}

	function kill(){
		if(this.flGround){
			this.game.removeFromGround(this.gList,this)
		}		
		if(this.depth!=undefined)this.game.depthList.push(this.depth);
		this.game.removeFromList(this,"spriteList")
		this.removeMovieClip();
	}

	function initGroundMode(){
		this.flGround = true;
	}
	
	function exitGroundMode(){
		this.flGround = false
		this.game.removeFromGround(this.gList,this)
		delete this.groundId;
	}
	
	function updateGroundId(){
		//if(this.flGround==false)_root.test+="error!!!\n";
		//_root.test="[Sprite] updateGroundId("+this.groundId+")"
		var id = Math.floor(this.x/this.game.groundCaseSize)
		if(id != this.groundId){
			this.game.removeFromGround(this.gList,this)
			this.gList = this.game.groundList[id]
			this.gList.push(this)
			this.groundId = id;
		}
	}
		
	// UTILS
	function getDist(mc){
		var difx = this.x - mc.x
		var dify = this.y - mc.y
		return Math.sqrt((difx*difx)+(dify*dify))
	}	

	
	//{
}









