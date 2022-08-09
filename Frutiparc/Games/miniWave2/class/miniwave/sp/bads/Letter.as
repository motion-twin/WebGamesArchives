class miniwave.sp.bads.Letter extends miniwave.sp.Bads {//}

	
	var code:Number;
	var field:TextField;
	
	// CAST
	var game:miniwave.game.Letter
	
	var keyCode:Array;
	var displayCode:Number;
	
	
	function Letter(){
		this.init();
	}
	
	function init(){
		//_root.test+="Letter init("+this.code+")\n"
		this.type = 50;
		super.init();
		
		this.translateCode()
		
		
		this.field.text = chr(this.displayCode)
		
	}
	

	
	function waveUpdate(){
		super.waveUpdate();
		this.endUpdate();
	}
	
	function update(){
		//_root.test="ty("+ty+")\n"
		super.update();
	}
	
	function translateCode(){
	
		if( this.code >= 0 && this.code < 26 ){
			this.displayCode = this.code+65
			this.keyCode = [ this.code+65 ]
			
		};
		
		if( this.code >= 26 && this.code < 36 ){
			this.displayCode = 22+this.code
			this.keyCode = [ 22+this.code, 70+this.code ]
			
		};

	}	
	
//{
}