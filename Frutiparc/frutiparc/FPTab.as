/*
$Id: FPTab.as,v 1.5 2004/01/27 16:48:49  Exp $

Class: FPTab
*/
class FPTab extends Tab{
	var mc:MovieClip;
	var tmpObj:Object;
	
	function FPTab(obj){
		this.tmpObj = obj;
		this.flDesktopable = true;
	}
	
	function init(slotList,depth,flGo){
		super.init(slotList,depth,flGo);
		
		if(this.tmpObj != undefined){
			this.tmpObj.slot.move(this.tmpObj.box,this);
			this.title = this.tmpObj.box.title;
		}
		this.tmpObj = undefined;
	}
	
	function addBox(box){
		box.mode = "tab";
		super.addBox(box);
	}

	function moveToDesktop(){
		var box = this.arr[this.depth];

		_global.slotList.activate(_global.desktop);

		this.move(box,_global.desktop);

	}

	function onStageResize(){
		for(var i=0;i<this.arr.length;i++){
			this.arr[i].onStageResize();
		}
	}

	function getMenu(){
		return [
			{title: "Vers bureau", action:{onRelease: [{obj:this, method:"moveToDesktop"}]}},
			{title: "Fermer", action:{onRelease: [{obj:this, method:"tryToClose"}]}}
		];
	}

	function onDeactivate(){
		this.mc.deactivate();
		return super.onDeactivate();
	}

	function onActivate(){
		this.mc.activate();
		return super.onActivate();
	}

	
	function onWarning(){
		this.mc.warning();
		super.onWarning();
	}
	
	function onStopWarning(){
		this.mc.stopWarning();
		super.onStopWarning();
	}

	function setTitle(t){
		this.mc.setTitle(t);
		super.setTitle(t);
	}

	function close(){
		super.close();
	}
	
	function getIconLabel(){
		for(var i=0;i<this.arr.length;i++){
			var o = arr[i];
			if(o != undefined){
				return o.getIconLabel();
			}
		}
		return "unknow";
	}
}
