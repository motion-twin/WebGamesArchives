class kaluga.part.Stats extends kaluga.Part{//}

	// CONSTANTES
	var margin:Number = 8;
	
	// PARAMETERS
	var name:String;
	var score:String;
	
	// MOVIECLIPS
	//var fieldName:TextField;
	//var fieldScore:TextField;
	var content:MovieClip;
	var mask:MovieClip;
	
	
	function Stats(){
		this.init();	
	}
	
	function init(){
		//_root.test+="[Stats] name("+this.name+")\n"
		//_root.test+="[Stats] score("+this.score+")\n"
		super.init();
		this.drawBackground();
		this.initFields();
	}
	
	function initFields(){
		this.attachMovie("whiteSquare","mask",130)
		this.mask._x = this.box.x
		this.mask._y = this.box.y
		this.mask._xscale = this.box.w
		this.mask._yscale = this.box.h
		this.createEmptyMovieClip("content",125)
		this.content.setMask(this.mask)
		
		this.content.createTextField( "fieldName", 10, box.x+margin, box.y, box.w-margin, box.h );
		this.content.fieldName.html = true;
		this.content.fieldName.selectable = false;
		this.content.fieldName.htmlText = this.name;
		
		var tf = this.content.fieldName.getTextFormat();
		tf.font = "Verdana";
		tf.size = 10;
		tf.align = "left";
		tf.color = 0x637c32
		this.content.fieldName.setTextFormat(tf);
		//
		this.content.createTextField( "fieldScore", 12, box.x, box.y, box.w-margin, box.h );
		this.content.fieldScore.selectable = false;
		this.content.fieldScore.text = this.score;
		var tf = this.content.fieldScore.getTextFormat();
		tf.font = "Verdana";
		tf.size = 10;
		tf.align = "right"
		tf.color = 0x637c32
		this.content.fieldScore.setTextFormat(tf);	

		
		this.content.fieldName._height = this.content.fieldName.textHeight+8
		this.content.fieldScore._height = this.content.fieldScore.textHeight+8

		
	}

	
	function update(){
		//_root.test+="coucou!\n"
		var h = this.box.h/2
		var m = 40
		
		var dif = (this._ymouse-this.box.y)-h;
		
		if( Math.abs(dif) < h ){
			var y = this.content._y - dif/50;
			this.content._y = Math.min(Math.max( y ,  this.box.h-(this.content._height) ) , 0 )
		}
		
		
		/*
		if( this._ymouse>0 && this._ymouse ){
			this.content._y--;
		}
		if( dif> h && dif < m ){
			this.content._y++;
		}		
		*/
		
	}
	
//{	
}