
// A REFORMATER 

class cp.InputField extends Component{

	// A RECEVOIR
	var colorId:Number;
	var text:String;
	
	var fieldProperty:Object;
	var textFormat:Object;
	
	var base:MovieClip;
	var side1:MovieClip;
	var side2:MovieClip;
	var field:MovieClip;
	
	/*-----------------------------------------------------------------------
		Function: InputField()
		constructeur;
	 ------------------------------------------------------------------------*/	
	function InputField(){
		this.init();
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		
		this.fix={h:14};	//14
		
		super.init();
		
		this.min={w:40,h:14}
		
		if(this.colorId==undefined)this.colorId=1;
		if(this.fieldProperty){
			for( var property in this.fieldProperty){
				this.field[property] = this.fieldProperty[property]
			}
		}
		if(this.textFormat){
			var format = this.field.getTextFormat();
			for( var property in this.textFormat){
				format[property] = this.textFormat[property]
			}
			this.field.setNewTextFormat(format)
		}
		
		this.base.stop();
		this.side1.stop();
		this.side2.stop();
		
		//this.updateColor()
	}

	/*-----------------------------------------------------------------------
		Function: updateSize()
	 ------------------------------------------------------------------------*/	
	function updateSize(){
		super.updateSize();
		this.base._width= this.width-(this.side1._width+ this.side2._width);
		this.side2._x= this.width-this.side2._width;
		this.field._width= this.width;	
	}

	/*-----------------------------------------------------------------------
		Function: getInput()
	 ------------------------------------------------------------------------*/	
	function getInput(){
		return this.text;	
	}
	
	/*-----------------------------------------------------------------------
		Function: setInput()
	 ------------------------------------------------------------------------*/	
	function setInput(text){
		this.text = text;	
	}
	
	/*-----------------------------------------------------------------------
		Function: setBox()
	 ------------------------------------------------------------------------*/	
	function setBox(box){
		this.field.myBox = box;
	};
	
	function focus(){
		Selection.setFocus(this.field);
	}

}

/* OBSOLETE
inputFieldClass.prototype.updateColor = function(){
	this.side1.gotoAndStop(this.colorId);
	this.side2.gotoAndStop(this.colorId);
	this.base.gotoAndStop(this.colorId);
}
*/
