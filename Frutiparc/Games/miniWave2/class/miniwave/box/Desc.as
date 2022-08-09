class miniwave.box.Desc extends miniwave.Box{//}
	
	var content:MovieClip;
	
	function Desc(){
		this.init();
	}
	
	function init(){
		super.init();
		this.content._visible = false;
		this.content.field._width = this.gw
		this.content.field2._width = this.gw
	}
	
	function update(){
		super.update();
	}
	
	function setText(str){
		this.content.field.text = str
	}
	
	function setSmallText(str){
		this.content.field2.text = str
	}	
	
	function initContent(){
		super.initContent();
		this.content._visible = true;
	};

	function removeContent(){
		super.removeContent();
		this.content._visible = false;
	}
		
	
	
	
	
//{	
}