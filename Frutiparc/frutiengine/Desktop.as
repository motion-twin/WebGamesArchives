/*
$Id: Desktop.as,v 1.3 2003/09/18 07:37:07  Exp $

Class: Desktop
*/

class Desktop extends Slot{
	
	var iconList:Array;
	
	function Desktop(){
	
	}
	
	function init(slotList,depth,flGo){
		super.init(slotList,depth,flGo);
		this.iconList = new Array();
	}
}
