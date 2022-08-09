/*
$Id: FPForumSlot.as,v 1.9 2004/07/16 12:22:37  Exp $

Class FPForumSlot
*/
class FPForumSlot extends Slot{
	var mcDesk:MovieClip;
	var mc:MovieClip;
	
	function FPForumSlot(){
	
	}
	
	function init(slotList,depth,flGo){
		super.init(slotList,depth,flGo);

		this.title = Lang.fv("forum");

		getURL("javascript:fp_goURLResize('/fb/?sid="+_root.sid+"',1)","");

		var mcName = "ForumSlot"+FEString.uniqId();
		this.slotList.mc.attachMovie("ForumSlot",mcName,this.baseDepth + Depths.desktop.bg);
		this.mcDesk = this.slotList.mc[mcName];
	}

	function onActivate(){
		super.onActivate();
		this.mcDesk._visible = true;

		if(_root.cwm == "1"){
			getURL("javascript:fp_resizeMe(1)","");
		}else{
			getURL("javascript:fp_activatePopupForum()","");
		}
		
		_global.me.status.setInternal("forum");

   	_global.topDesktop.disable();
    _global.wallPaper.hide();
		this.mc.activate();
	}

	function onDeactivate(){
		super.onDeactivate();
		this.mcDesk._visible = false;

		if(_root.cwm == "1"){
			getURL("javascript:fp_resizeMe(0)","");
		}
		
		_global.me.status.unsetInternal("forum");

   	_global.topDesktop.enable();
    _global.wallPaper.show();
		this.mc.deactivate();
	}

	
	function onWarning(){
		this.mc.warning();
		super.onWarning();
	}
	
	function onStopWarning(){
		this.mc.stopWarning();
		super.onStopWarning();
	}

	function close(){
		if(_root.cwm == "1"){
			getURL("javascript:fp_closeFrame(1)","");
		}else{
			getURL("javascript:fp_closePopupForum()");
		}

		_global.me.status.unsetInternal("forum");

		this.mcDesk.removeMovieClip();
		_global.topDesktop.enable();
    _global.wallPaper.show();
		super.close();
	}

	function getMenu(){
		return [
			{title: "Fermer", action: {onRelease: [{obj:this, method:"tryToClose"}]}}
		];
	}
	
	function getIconLabel(){
		return "slotForum";
	}
}
