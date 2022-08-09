/*
$Id: SlotList.as,v 1.8 2004/05/05 14:21:45  Exp $

Class: SlotList
*/
class SlotList{
	var arr:Array;
	var depth:Number = -1;
	var activeSlot:Slot = undefined;

	function SlotList(){

	}

	function init(){
		this.arr = new Array();
	};

	function addSlot(slot:Slot,flGo){
		var d = this.getNextDepth();
		this.arr[d] = slot;
		slot.init(this,Depths.slotList.start + Depths.slotList.dst*d,flGo);

		if(!flGo){

		}
	};

	function rmSlot(slot:Slot){
		var id = this.arr.indexOf(slot);
		if(id > -1){
			this.arr[id] = undefined;
			if(this.activeSlot == slot){
				this.activeSlot = undefined;
			}
			return true;
		}else{
			return false;
		}
	};

	function getNextDepth(){
		if(this.depth + 1 > (Depths.slotList.max - Depths.slotList.start)){
			this.cleanDepths();
		}
		this.depth++
		return this.depth;
	};

	function cleanDepths(){
		for(var i=0;i<this.arr.length;i++){
			if(this.arr[i] == undefined){
				this.arr.splice(i,1);
				i--;
			}else{
				this.arr[i].setDepth(Depths.slotList.start + Depths.slotList.dst*i);
			}
		}
	};

	function putOnTop(slot:Slot){
		var id = this.arr.indexOf(slot);
		if(id > -1){
			this.arr[id] = undefined;
			var d = this.getNextDepth();
			this.arr[d] = slot;
			slot.setDepth(Depths.slotList.start + Depths.slotList.dst*d);
		}
	};

	function activate(slot){
		if(slot == undefined) return false;
		if(this.activeSlot == slot) return false;
		if(slot.flClose) return false;
		
		if(this.activeSlot != undefined){
			this.activeSlot.onDeactivate();
		}

		this.activeSlot = slot;
		this.activeSlot.onActivate();
		return true;
	};
}
