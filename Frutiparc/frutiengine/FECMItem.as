class FECMItem extends ContextMenuItem{
	// Viva Macromedia !!
	// This static function will be defined as local "onSelect" method in every FEMCItem (in constructor)
	// argument "menuItem" is probably equals to "this" here, but the parser refuses "this" in this function... 
	// Viva Macromedia !!
	static function onSelect(mc,menuItem){
		menuItem.callBack.obj[menuItem.callBack.method](menuItem.callBack.args);
	}
	
	//
	
	var callBack:Object;
	
	function FECMItem(caption,callBack,flSeparatorBefore,flEnabled,flVisible){
		super(caption,onSelect,flSeparatorBefore,flEnabled,flVisible);
		this.callBack = callBack;
	}
}