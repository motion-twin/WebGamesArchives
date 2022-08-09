package mt.flash;

import flash.events.TouchEvent;

enum ViewportState {
	V_Inactive;
	V_Moving;
	V_Scaling;
}

class MultiTouchViewport {

	static var MIN_DELTA = 1;

	public var state(default,null) = V_Inactive;

	var touch = [];
	var touchProps = new haxe.ds.IntMap<TouchEvent>();

	var currentDragPoint : Null<Int> = null;
	var currentZoomPoint : Null<Int> = null;

	public function new(){
		flash.ui.Multitouch.inputMode = flash.ui.MultitouchInputMode.TOUCH_POINT;

		var stage = flash.Lib.current.stage;
		stage.addEventListener( TouchEvent.TOUCH_BEGIN, onTouchDown, false );
		stage.addEventListener( TouchEvent.TOUCH_END, onTouchUp, false );
		stage.addEventListener( TouchEvent.TOUCH_MOVE, onTouchMove, false );
	}

	public function unregister(){
		var stage = flash.Lib.current.stage;
		stage.removeEventListener( TouchEvent.TOUCH_BEGIN, onTouchDown );
		stage.removeEventListener( TouchEvent.TOUCH_END, onTouchUp );
		stage.removeEventListener( TouchEvent.TOUCH_MOVE, onTouchMove );
	}

	public dynamic function doMove( dx: Float, dy: Float ){
	}
	
	public dynamic function doZoom( delta: Float, centerX: Float, centerY: Float ){
	}

	public dynamic function onStateChanged( state : ViewportState ){
	}

	function onTouchDown( ev : TouchEvent ){
		touch.remove( ev.touchPointID );
		touch.push( ev.touchPointID );
		touchProps.set( ev.touchPointID, ev );
		onUpdateTouch();
	}

	function onTouchUp( ev : TouchEvent ){
		touch.remove( ev.touchPointID );
		touchProps.remove( ev.touchPointID );
		onUpdateTouch();
	}

	function onTouchMove( ev : TouchEvent ){
		// Move
		if( ev.touchPointID == currentDragPoint && currentZoomPoint == null ){
			var oldEv = touchProps.get( currentDragPoint );
			if( oldEv != null ){
				var dX = ev.stageX - oldEv.stageX;
				var dY = ev.stageY - oldEv.stageY;
				if( Math.abs(dX) < MIN_DELTA && Math.abs(dY) < MIN_DELTA )
					return;
				if( state != V_Moving )
					onStateChanged( state = V_Moving );
				doMove( dX, dY );
			}
		// Move&Zoom
		}else if( currentZoomPoint != null && (ev.touchPointID == currentZoomPoint || ev.touchPointID == currentDragPoint) ){
			var oldA = touchProps.get( currentDragPoint );
			var oldB = touchProps.get( currentZoomPoint );
			if( oldA != null && oldB != null ){
				var a = ev.touchPointID==currentDragPoint ? ev : oldA;
				var b = ev.touchPointID==currentZoomPoint ? ev : oldB;

				var oldCenterX = (oldA.stageX+oldB.stageX) * 0.5;
				var oldCenterY = (oldA.stageY+oldB.stageY) * 0.5;
				var newCenterX = (a.stageX+b.stageX) * 0.5;
				var newCenterY = (a.stageY+b.stageY) * 0.5;

				var dx = oldA.stageX - oldB.stageX;
				var dy = oldA.stageY - oldB.stageY;
				var oldDistance = Math.sqrt( dx*dx+dy*dy );

				dx = a.stageX - b.stageX;
				dy = a.stageY - b.stageY;
				var newDistance = Math.sqrt( dx*dx+dy*dy );

				if( newDistance != oldDistance )
					doZoom( newDistance / oldDistance, newCenterX, newCenterY );

				if( newCenterX!=oldCenterX || newCenterY!=oldCenterY )
					doMove( newCenterX-oldCenterX, newCenterY-oldCenterY );
			}
		}
		// Update touchProps
		touchProps.set( ev.touchPointID, ev );
	}

	function onUpdateTouch(){
		var oldState = state;

		switch( touch.length ){
		case 0: // STOP
			state = V_Inactive;
			currentDragPoint = currentZoomPoint = null;

		case 1: // start drag
			// only downgrade state
			if( state == V_Scaling )
				state = V_Moving;
			currentDragPoint = touch[0];
			currentZoomPoint = null;

		case 2: // start zoom & drag
			state = V_Scaling;
			currentDragPoint = touch[0];
			currentZoomPoint = touch[1];
		}

		if( state != oldState )
			onStateChanged( state );
	}


}
