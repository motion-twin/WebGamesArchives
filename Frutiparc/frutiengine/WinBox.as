/*
$Id: WinBox.as,v 1.12 2004/02/11 08:27:22  Exp $

Class: WinBox
*/
class WinBox{
	var initialized:Boolean = false;
	var slot;
	var depth:Number;
	var flShow:Boolean = false;
	var flActive:Boolean = false;
	var wasShow:Boolean = false;
	var title:String;
	var flClosed:Boolean = false;
	var window;
	
	var mode:String;

	function WinBox(){
	}

	function preInit(){
		if(this.title == undefined) this.title = "";
	}

	// Called when the box is added to a slot
	function init(slot,depth){
		var rs = !this.initialized;
		if(rs){
			this.preInit();
		}
		this.initialized = true;
		this.slot = slot;
		this.depth = depth;
		this.flShow = true;

		return rs;
	};

	function setDepth(depth){
		this.depth = depth;
	};

	function close(){
		this.slot.rmBox(this);
		this.flClosed = true;
	};

	function tryToClose(){
		this.close();
	};

	function hide(){
		this.flShow = false;
	};

	function show(){
		this.flShow = true;
	};

	function onActivate(){
		this.flActive = true;
	};

	function onDeactivate(){
		this.flActive = false;
	};


	function onSlotActivate(){
		if(this.wasShow){
			this.show();
		}
		this.wasShow = false;
	};

	function onSlotDeactivate(){
		if(this.flShow){
			this.wasShow = true;
			this.hide();
		}else{
			this.wasShow = false;
		}
	};

	function activate(){
		this.slot.activate(this);
	};

	function move(newSlot){
		if(this.slot == newSlot) return false;
		
		this.slot.move(this,newSlot);
	};

	function setTitle(t){
		this.title = t;
	};
//{
}
