class inter.Dialog extends Inter{//}

	var fieldName:TextField;
	var fieldText:TextField;
	
	var fi:FaerieInfo
	
	function new(b){
		super(b);
		//init();
	}
	
	function init(){
		link = "interDialog";
		super.init();
		fieldName = downcast(skin).fieldName;
		fieldText = downcast(skin).fieldText;
	}
	
	function setFaerie(f){
		fi = f
		fi.intDialog = this;
		fieldName.text = fi.fs.$name;
	}
		
	function update(){
	
	}
	
	
	
	
	
	
	
	
	
	
	
//{	
}