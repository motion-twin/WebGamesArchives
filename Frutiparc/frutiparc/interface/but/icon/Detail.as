class but.icon.Detail extends but.Icon{//}
	
	// CONSTANTE
	var h:Number = 15;
	
	// VARIABLE
	//var infoSupList:Array;
	
	// var titleField:TextField;
	// var dateField:TextField;
	var dateDsp;
		
	/*-----------------------------------------------------------------------
		Function: Detail()
		constructeur
	------------------------------------------------------------------------*/
	function Detail(){
		this.flSaveMousePos = false;
		this.init();
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/
	function init(){
		super.init();
	}
	
	/*-----------------------------------------------------------------------
		Function: display()
	------------------------------------------------------------------------*/	
	function display(){
		super.display()
		
		this.dateDsp = Lang.formatDateString(this.date,"numeric");

		
		// ICON
		var scale = this.height * this.icoRatio //25 * this.icoScale / 100;			// = 15px
		this.ico._x = 2;
		this.ico._xscale = scale;
		this.ico._yscale = scale;
		//BUT
		this.but._xscale = this.width//240;
		this.but._yscale = this.height;

		// TODO (autres champs de textes)
		//FIELD 1
		var x = 0
		var list = this.iconList.templateInfo.supList
		//_root.test+="list("+list+")\n"
		for(var i=0; i<list.length; i++){
			var o = list[i]
			var ti = new TextInfo();
			ti.pos = {x:x, y:0, w:o.min, h:this.h};
			if(i==0){
				ti.pos.x+=20;
				ti.pox.w-=20;
			}
			ti.textFormat.color = this.textColor;
			ti.attachField(this,"titleField"+i,this.dp_field+i);
			var tf = this["titleField"+i]
			tf.text = this[o.name];
			x += o.min;
			if(o.big)x+=this.iconList.templateInfo.bonus;
			//_root.test+="("+this.iconList.templateInfo.total+","+this.iconList.templateInfo.bonus+")\n"
		}
		
		// SEPARATEUR
		/*
		this.createEmptyMovieClip("sep",568)
		var pos = { x:0, y:20, w:240, h:1}
		FEMC.drawSquare(this["sep"],pos,this.textColor)
		this["sep"]._alpha = 20
		*/

	}
	
	
	
//{
}




