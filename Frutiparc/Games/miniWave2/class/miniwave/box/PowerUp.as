class miniwave.box.PowerUp extends miniwave.Box{//}
	
	var top:Number = 78
	var id:Number;
	var content:MovieClip;
	
	function PowerUp(){
		this.init();
	}
	
	function init(){
		//_root.test+="[BOX POWERUP] init() \n"
		super.init();
		this.content._visible = false;
		this.content.field0._width = this.gw
		this.content.field1._x = 5
		this.content.field1._width = this.gw-10
		this.content.field1._height = this.gw-this.top
		this.content.illus._x = (this.gw-this.content.illus._width)/2
		
	}
	
	function update(){
		super.update();
	}
	
	function setText(num,str){
		var field = this.content["field"+num]
		field.text = str;
		if( num == 1 ){
			field._y = this.top+(this.gh-this.top)/2 - Math.round(field.textHeight/2)
		}
		
	}

	function setIllus(frame){
			this.content.illus.gotoAndStop(frame)
	}
	
	function initContent(){
		super.initContent();
		this.content._visible = true;
		this.content.illus.gotoAndStop(id+1)
		
		
	};

	function removeContent(){
		super.removeContent();
		this.content._visible = false;
	}
		
	
	
	
	
//{	
}