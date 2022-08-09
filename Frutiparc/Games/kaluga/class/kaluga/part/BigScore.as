class kaluga.part.BigScore extends kaluga.Part{//}

	var frame:Number;
	var score:String;
	
	var field:TextField;
	
	function BigScore(){
		//_root.test+="bigScore\n"
		this.init();
	}
	
	function init(){
		super.init();
		this.gotoAndStop(frame);
		this.field.text = this.score;		
	}
	
	
	
//{	
}