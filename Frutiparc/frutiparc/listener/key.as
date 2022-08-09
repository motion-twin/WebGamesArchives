class listener.key{
	static function onKeyDown(){
		var tf = eval(Selection.getFocus());
		if(tf.myBox) tf.myBox.activate();
		if(Key.isDown(Key.ENTER)){
			_global.slotList.activeSlot.activeBox.onEnter();
		}
		if(Key.isDown(Key.DOWN)){
			_global.slotList.activeSlot.activeBox.onDown();
		}
		if(Key.isDown(Key.UP)){
			_global.slotList.activeSlot.activeBox.onUp();
		}
	};
}
