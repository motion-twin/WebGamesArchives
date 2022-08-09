class gfx.List extends MovieClip{//}
	
	// VARIABLES
	var pos:Object;
	
	// PARAM
	var frame;
	var link:String;
	
	// MOVIECLIPS
	var content:MovieClip;
	
	function List(){
		//this.pos = new Object();
		if(this.link==undefined)this.link="carre";
		if(this.frame==undefined)this.frame=1;
		//_root.test+="[gfxList]init() link("+link+") frame("+frame+")\n";
		this.attachMovie(link,"content",1);
		this.content.gotoAndStop(this.frame);
		//_root.test+="this.content("+this.content+")\n";
	}
	function update(){
		this._x = this.pos.x;
		this._y = this.pos.y;
		//this._xscale = this.pos.w;
		//this._yscale = this.pos.w;
	}
//}
}
	