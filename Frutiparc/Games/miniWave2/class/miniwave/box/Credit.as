class miniwave.box.Credit extends miniwave.Box{//}
	
	var cred:String;
	
	var field:TextField;
	var symb:MovieClip;
	
	function Credit(){
		this.init();
	}
	
	function init(){
		super.init();
		this.field._visible = false;		
		this.symb._visible = false;		
	}
	
	function initContent(){
		super.initContent();
		this.field._visible = true;
		this.symb._visible = true;
		this.field._width = this.gw;
	}

	function removeContent(){
		super.removeContent();
		this.field._visible = false;
		this.symb._visible = false;
	}
	
	function updateCredit(){
		this.cred = this.page.menu.mng.fc[0].$credit
		this.symb._x = this.gw/2 + this.field.textWidth/2
		this.field._x = -11
	}
	
//{	
}