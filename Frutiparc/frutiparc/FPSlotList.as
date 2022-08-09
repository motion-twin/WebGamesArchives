/*
$Id: FPSlotList.as,v 1.6 2004/04/30 15:47:35  Exp $

Class: FPSlotList
*/
class FPSlotList extends SlotList{//}
	var mc:MovieClip;
	
	function FPSlotList(){
	
	}

	function init(){
		super.init();

		_global.main.createEmptyMovieClip("slotListMc",Depths.slotListBase);
		this.mc = _global.main.slotListMc;
	}

	function addSlot(slot,flGo){
		if(_global.main.mainBar.tabListIsTooFull(1)){
			this.tryToRemoveTab();
		}

		super.addSlot(slot,flGo);
		slot.mc = _global.main.mainBar.addTab(slot);
		if(flGo){
			slot.mc.activate();
		}
		return true;
	}

	function rmSlot(slot){
		var wasActive = (slot == this.activeSlot)
		var rs = super.rmSlot(slot);
		_global.main.mainBar.removeTab(slot);
			
		if(wasActive){
			this.activate(_global.desktop);
		}

		return rs;
	}

	function onStageResize(){
		// Only activeSlot is now called
		// See also FPSlotList::activate
		/*
		for(var i=0;i<this.arr.length;i++){
			this.arr[i].onStageResize();
		}
		*/
		this.activeSlot.onStageResize();
		
		
		if(_global.main.mainBar.tabListIsTooFull(0)){
			var lastNb;
			do{
				lastNb = this.arr.length;
				this.tryToRemoveTab();
			}while(_global.main.mainBar.tabListIsTooFull(0) && this.arr.length != lastNb);
			
			if(_global.main.mainBar.tabListIsTooFull(0)){
				_global.debug("SLOTLIST ERROR : tabListIsTooFull but nothing to remove...");
			}
		}
	}
	
	function tryToRemoveTab(){
		for(var i=0;i<this.arr.length;i++){
			var o = this.arr[i];
			if(o.flDesktopable){
				o.moveToDesktop();
				break;
			}
		}
	}
	
	function activate(slot){
		var rs = super.activate(slot);
		
		// See also FPSlotList::onStageResize
		if(rs == true){
			this.activeSlot.onStageResize();
		}
		
		return rs;
	}
//{
}
