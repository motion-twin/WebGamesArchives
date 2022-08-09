/*
$Id: Tab.as,v 1.2 2003/09/17 11:42:26  Exp $

Class: Tab
*/
class Tab extends Slot{
	function Tab(){
	
	}
	
	function init(slotList,depth,flGo){
		super.init(slotList,depth,flGo);
	}

	function addBox(box:WinBox){
		if(this.nbBox == 0){
			return super.addBox(box);
		}else{
			return false;	
		}
	}

	function rmBox(box:WinBox){
		super.rmBox(box);
		this.cleanDepths();
		if(this.nbBox == 0){
			this.close();
		}
	}
}
