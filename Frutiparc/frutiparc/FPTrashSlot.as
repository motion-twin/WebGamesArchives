/*
$Id: FPTrashSlot.as,v 1.1 2003/09/19 14:27:17  Exp $

Class: FPTrashSlot
*/
class FPTrashSlot extends Slot{
	function FPTrashSlot(){
		this.title = "trash";
	}
	
	function addBox(box){
		box.mode = "trash";
		super.addBox(box);
	}
}
