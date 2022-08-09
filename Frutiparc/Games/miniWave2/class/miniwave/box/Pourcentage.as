class miniwave.box.Pourcentage extends miniwave.Box{//}
	
	var ratio:Number;
	var field:TextField;
	var bar:MovieClip;
	
	function Pourcentage(){
		this.init();
	}
	
	function init(){
		this.gw = 50;
		this.gh = 18;
		super.init();
		this.field._visible = false;
		this.bar._visible = false;
	
	}
	
	function initContent(){
		super.initContent();
		this.field._visible = true;
		this.bar._visible = true;
		this.bar._xscale = ratio;
		this.field.text =ratio+"%"
	}
		
	function removeContent(){
		super.removeContent();
		this.bar._visible = false;
		this.field._visible = false;
	}
	
	
	
	
	
	
	
	
	
//{	
}