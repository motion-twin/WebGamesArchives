class listener.mouse{
	static function onMouseDown(){
		if(_global.dragIcon != undefined){
			_global.deleteDragIcon();
		}
	}
	
	static function onMouseWheel(delta:Number){
		_global.slotList.activeSlot.activeBox.onWheel(delta);
	}
}
