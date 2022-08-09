class but.push.Standard extends but.push.Text{//}
	
	// VARIABLES
	var type:Number;
	
	function Standard(){
		//_root.test = "but.push.Standard init\n"
		this.init();
	}
	
	function init(){
		
		super.init()
		if(this.type==undefined){
			var tw = this.field.textWidth;
			if(tw<30){
				this.type = 0 ;
			}else if(tw<70){
				this.type = 1 ;
			}else{
				this.type = 2 ;
			}
		}
		switch(Number(this.type)){
			case 0:
				this.field._width = 40
				break;
			case 1:
				this.field._width = 80
				break;
			case 2:
				this.field._width = 120
				break;			
		}
		//this.field._width
		this.width = this._width;
		this.gotoAndStop(this.type+1)
	}
	
	function initTextStyle(){
		super.initTextStyle()
		this.ts.textFormat.color = 0x660000;
		this.ts.textFormat.size = 10;
		this.ts.textFormat.bold = true;		
	}

//{
}