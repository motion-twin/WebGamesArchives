/*
$Id: Slot.as,v 1.10 2004/05/05 14:21:45  Exp $

Class: Slot
*/
class Slot{//}
	var slotList;
	var arr:Array;
	var nbBox:Number;
	var flActive:Boolean;
	var baseDepth:Number;
	var depth:Number;
	var activeBox:WinBox;
	var title:String;					
	var flWarning:Boolean;
	var flDesktopable:Boolean;
	
	var flClose:Boolean;
	
	function Slot(){
		this.nbBox = 0;
		this.flActive = false;
		this.flWarning = false;
		this.depth = -1;
		this.activeBox = null;
		this.flDesktopable = false;
		this.flClose = false;
	}

	function init(slotList,baseDepth,flGo){
		this.arr = new Array()
		this.slotList = slotList;
		this.baseDepth = baseDepth;

		if(flGo){
			this.slotList.activate(this);
		}
	}

	function setDepth(baseDepth){
		this.baseDepth = baseDepth;
		this.cleanDepths();
	}

	function addBox(box){
		//_root.test+="addBox\n"
		var d = this.getNextDepth();
		this.arr[d] = box;
		this.nbBox++;
		box.init(this,this.baseDepth + Depths.boxList.start + Depths.boxList.dst*d );
		this.activate(box);
		this.onBoxListChanged();
	}

	function rmBox(box){
		var id = this.arr.indexOf(box);
		if(id > -1){
			this.arr[id] = undefined;
			this.nbBox--;
			this.onBoxListChanged();
		}
	}

	function getNextDepth(){
		if(this.depth + 1 > (Depths.boxList.max - Depths.boxList.start) ){
			this.cleanDepths();
		}
		this.depth++;
		return this.depth;
	}

	function cleanDepths(){
		for(var i=0;i<this.arr.length;i++){
			if(this.arr[i] == undefined){
				this.arr.splice(i,1);
				i--;
			}else{
				this.arr[i].setDepth( this.baseDepth + Depths.boxList.start + Depths.boxList.dst*i );
			}
		}
	}

	function putOnTop(box){
		var id = this.arr.indexOf(box);
		if(id > -1){
			this.arr[id] = undefined;
			var d = this.getNextDepth();
			this.arr[d] = box;
			box.setDepth( this.baseDepth + Depths.boxList.start + Depths.boxList.dst*d );
		}
	}

	function onBoxListChanged(){
		//
	}

	function close(){
		this.flClose = true;
		this.slotList.rmSlot(this);
	}


	function tryToClose(){
		if(this.arr.length == 0){
			this.close();
		}else{
			for(var i=0;i<this.arr.length;i++){
				this.arr[i].tryToClose();
			}
		}
	}

	function onActivate(){
		this.flActive = true;
		
		if(this.flWarning){
			this.onStopWarning();
		}
		
		for(var i=0;i<this.arr.length;i++){
			if(this.arr[i] != undefined){
				this.arr[i].onSlotActivate();
			}
		}
	}

	function onDeactivate(){
		this.flActive = false;
		for(var i=0;i<this.arr.length;i++){
			if(this.arr[i] != undefined){
				this.arr[i].onSlotDeactivate();
			}
		}
	}

	function activate(box){
		if(this.activeBox == box) return false;
		if(this.activeBox != null){
			this.activeBox.onDeactivate();
		}

		this.activeBox = box;
		this.putOnTop(box);
		this.activeBox.onActivate();
		return true;
	}

	function move(box,newSlot){
		this.rmBox(box);
		newSlot.addBox(box);
	}

	function setTitle(t){
		this.title = t;
	}
	
	function warning(){
		if(this.flActive) return false;
		if(this.flWarning) return false;
		
		this.onWarning();
		
		return true;
	}
	
	function onWarning(){
		if(this.flWarning) return false;
		
		this.flWarning = true;
	}
	
	function onStopWarning(){
		if(!this.flWarning) return false;
		
		this.flWarning = false;
	}
	
	function onStageResize(){
	
	}
	
//{
}
