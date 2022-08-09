class but.push.Text extends MovieClip{//}
	
	var ts:Object;
	var txt:String;
	var field:MovieClip;
	var width:Number;
	var height:Number;
	
	function Text(){
	}

	function init(){
		this.width = this._width;
		this.height = this._height;
		if(this.ts==undefined)this.initTextStyle();
		var ti = new TextInfo(this.ts);
		ti.pos = {x:0,y:-1,w:80,h:16};
		ti.attachField(this,"field",10);
		this.field.text = this.txt;
	}
	
	function initTextStyle(){
		var tsg = Standard.getTextStyle()
		this.ts = tsg.def
		ts.textFormat.align = "center";
	}
//{	
}