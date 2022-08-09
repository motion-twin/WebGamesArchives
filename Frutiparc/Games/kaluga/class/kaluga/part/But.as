class kaluga.part.But extends kaluga.Part{
	
	//CONSTANTE
	var center:Number = 232
	
	// PARAMS
	var title:String;
	var callback:Object;
	
	// MOVIECLIPS
	var field:TextField;
	var tz1:MovieClip;
	var tz2:MovieClip;
	
	function But(){
		//_root.test+="butInit\n"
		this.init();
	}
	
	function init(){
		super.init();
		this.field.text = this.title
		this.initTzongres()

	};

	function initTzongres(){
		var dx = 36+(this.field.textWidth/2)
		this.tz1._x = this.center-dx
		this.tz2._x = this.center+dx
		this.tz1._visible = false
		this.tz2._visible = false	
	}
	
	function select(){
		this.callback.obj[this.callback.method](this.callback.args)
	}

	function rOver(){
		this.tz1._visible = true
		this.tz2._visible = true
	}
	
	function rOut(){
		this.tz1._visible = false;
		this.tz2._visible = false;	
	}

	
	
	
	
}