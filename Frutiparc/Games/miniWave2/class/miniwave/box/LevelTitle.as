class miniwave.box.LevelTitle extends miniwave.Box{//}
	
	var id:Number;
	var text:String;
	var field:TextField;
	var but:Button;
	
	function LevelTitle(){
		this.init();
	}
	
	function init(){
		super.init();
		this.field._visible = false
	}
	
	function initContent(){
		super.initContent();
		this.field._visible = true;
		this.field.text = this.text
		this.field._width = this.gw
		var tf = this.field.getTextFormat();
		tf.align = "center"
		this.field.setTextFormat(tf);
		
		// BUTTON
		this.attachMovie("transp","but",10)
		this.but._xscale = this.gw
		this.but._yscale = this.gh
		this.but.onPress = function(){
			this._parent.select();
		}
		
		
	}

	function removeContent(){
		super.removeContent();
		this.but._visible = false;
		this.field._visible = false;
	}
	
	function select(){
		this.page.select(this.id)
	}
	
	
	
	
	
//{	
}