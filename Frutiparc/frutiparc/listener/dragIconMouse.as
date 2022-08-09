class listener.dragIconMouse{//}
	static var lastDropTarget;
	static function onMouseUp(){
		_global.debug("drop: "+_global.dragIcon._droptarget+" ("+(eval(_global.dragIcon._droptarget).dropBox != undefined)+")");
		var mc = eval(_global.dragIcon._droptarget);
		if(mc == undefined){
			_global.desktop.onDrop(_global.dragIconOrig);
		}else{
			if(mc.dropBox != undefined){
				mc.dropBox.onDrop(_global.dragIconOrig,mc);
			}else{
				mc.onDrop(_global.dragIconOrig);
			}
		}
		_global.deleteDragIcon();
	}
	
	static function onMouseMove(){
		var mc = eval(_global.dragIcon._droptarget);
		if(mc != lastDropTarget){
			if(lastDropTarget == undefined){
				_global.desktop.onDragRollOut(_global.dragIcon);
			}else{
				if(lastDropTarget.dropBox != undefined){
					lastDropTarget.dropBox.onDragRollOut(_global.dragIcon,lastDropTarget);
				}else{
					lastDropTarget.dropBox.onDragRollOut(_global.dragIcon);
				}
			}
			if(lastDropTarget.myIconGFX != undefined){
				lastDropTarget.myIconGFX.onDragRollOut();
			}
			lastDropTarget = mc;
			if(mc == undefined){
				_global.desktop.onDragRollOver(_global.dragIcon);
			}else{
				if(mc.dropBox != undefined){
					mc.dropBox.onDragRollOver(_global.dragIcon,mc);
				}else{
					mc.dropBox.onDragRollOver(_global.dragIcon);
				}
			}
			if(mc.myIconGFX != undefined){
				mc.myIconGFX.onDragRollOver();
			}
		}
	}
//{
}
