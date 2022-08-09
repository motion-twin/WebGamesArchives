/*
$Id: FP.as,v 1.12 2004/07/30 08:47:53  Exp $

Class: box.FP
*/
class box.FP extends WinBox{//}
	var desktopable:Boolean;
	var tabable:Boolean;
	var winOpt:Object;
	var winType:String;
	
	function FP(){
	}

	function preInit(){
		if(this.desktopable == undefined) this.desktopable = true;
		if(this.tabable == undefined) this.tabable = true;
		super.preInit();
	}

	function init(slot,depth){
		//_root.test="boxInit\n"
		
		var oldSlot = this.slot;
		var rs = super.init(slot,depth);
		
		if(rs){
			var mcName = this.winType+FEString.uniqId();
			if(this.winOpt == undefined){
				this.winOpt = new Object();
			}
			this.winOpt.box = this;
			this.winOpt.title = this.title;
			this.slot.slotList.mc.attachMovie(this.winType,mcName,this.depth,this.winOpt);
			//_root.test+="attach "+this.winType+", "+mcName+", "+this.depth+" ---> "+this.slot.slotList.mc[mcName]+"\n"
			
			this.window = this.slot.slotList.mc[mcName];
			if(!this.slot.flActive){
				this.wasShow = true;
				this.hide();
			}
		}else{
			this.window.swapDepths(this.depth);
			this.onChangeMode();
		}

    if(oldSlot != undefined){
   		if(this.slot.flActive && !oldSlot.flActive){
   			this.onSlotActivate();
   		}
   		if(!this.slot.flActive && oldSlot.flActive){
   			this.onSlotDeactivate();
   		}
    }

		return rs;
	}
	
	function putInTab(flGo){
		if(this.tabable){
			this.slot.tab(this,flGo);
		}
	}

	function setDepth(depth){
		super.setDepth(depth);
		this.window.swapDepths(this.depth);
	}

	function callHelp(){
	}
	
	function putInDesktop(){
		if(this.desktopable){
			this.slot.moveToDesktop();
		}
	}

	function hide(){
		//this.window._x = -4000
		//this.window._y = -4000
		this.window._visible = false;
		//this.window._alpha = 22
		return super.hide();
	}

	function show(){
		//this.window._x = this.window.pos.x
		//this.window._y = this.window.pos.y
		this.window._visible = true;
		//this.window._alpha = 100
		return super.show();
	}

	function close(){
		this.window.onClose();
		this.window.removeMovieClip();

		super.close();
	}

	function onChangeMode(){
		this.window.onChangeMode();
	}

	function onStageResize(){
		this.window.onStageResize();
	}

	function setTitle(t){
		super.setTitle(t);
		this.window.setTitle(t);
		if(this.mode == "tab"){
			this.slot.setTitle(t);
		}
	}
	
	function getIconLabel(){
		return this.winType;
	}
	
	function activate(){
		if(this.mode == "tab"){
			this.slot.slotList.activate(this.slot);
		}else{
			super.activate();
		}
	}
//{
}

