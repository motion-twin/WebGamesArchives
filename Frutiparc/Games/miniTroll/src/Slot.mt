class Slot extends MovieClip{//}
	
	static var DP_HINT = 	51;
	static var DP_BUT = 	30;
	
	var dpCursorFront:int;
	var dpCursorBack:int;
	//
	var partList:Array<sp.Part>;
	var hintList:Array<Hint>;
	var diaList:Array<Dialog>
	//
	var dial:Dialog;
	var dm:DepthManager;
	var cursor:sp.pe.Cursor;
	
	//
	var choice:{>MovieClip,yes:Button,no:Button,field:TextField}
	var butQuit:{>MovieClip,but:MovieClip}

	function new(){
		dm = new DepthManager(this);
		partList = new Array();
		hintList = new Array();
		diaList = new Array();
	}
	
	
	function init(){
	
	}
	
	function postInit(){
	
	};
	
	function maskInit(){
	
	};
		
	function update(){
		for( var i=0; i<hintList.length; i++){
			var h = hintList[i]
			if(h.fade!=null){
				h.fade*=0.8
				h.skin._alpha = h.fade
				if( h.skin._alpha < 1 ){
					h.kill()
					hintList.splice(i--,1)
				}
			}
		}
		
		if(dial!=null){
			dial.timer-=Timer.tmod;
			if(dial.timer<0){
				dial.kill();
				if(diaList.length>0)attachDialog(diaList.shift());
			}
		}
		
		
	};	

	function initCursor(fi:FaerieInfo,mc:MovieClip){
		cursor = new sp.pe.Cursor();
		cursor.slot = this;
		cursor.setInfo(fi)
		
		cursor.init();	
		cursor.birth(mc)
		cursor.showStatus();
		
	}
	
	function moveCursor(){
		cursor.update();
		cursor.trg.x = _xmouse;
		cursor.trg.y = _ymouse;
	}
	
	function removeCursor(){
		cursor.kill();
		cursor = null;
	}
	
	function movePart(){
		for( var i=0; i<partList.length; i++ ){
			partList[i].update();
		}	
	}
	
	function newPart(link,d):sp.Part{
		var sp = new sp.Part();
		sp.setSkin( dm.attach( link, d  ) )
		sp.addToList(partList);
		return sp;
	}
	
	//
	function initButQuit(){
		var mc = downcast(dm.attach("mcButQuit",DP_BUT))
		mc._x = Cs.mcw;
		mc._y = Cs.mch;
		mc.stop();
		mc.but.onRollOver = fun(){
			mc.gotoAndStop("2")
		}
		mc.but.onRollOut = fun(){
			mc.gotoAndStop("1")
		}
		mc.but.onPress = callback(this,quit)
		
		mc.but.onDragOut = mc.but.onRollOut
		butQuit = mc;
	}	
	
	//
	function attachChoice(txt){
		if(choice!=null)removeChoice();
		choice = downcast(dm.attach("panChoice",DP_BUT))
		choice._x = Cs.mcw*0.5
		choice._y = Cs.mch*0.5
		choice.field.text = txt
		choice.field._y = - ( 10+choice.field.textHeight*0.5 )
		choice.no.onPress = callback( this, removeChoice )
		
	}
	function removeChoice(){
		choice.removeMovieClip();
		choice = null;
	}	
	
	// HINT
	function attachHint(mc,txt,w){
		if(Manager.oldSlot!=null)return;
		for( var i=0; i<hintList.length; i++ ){
			var h = hintList[i]
			if(h.parent==mc ){
				h.skin._alpha = 100
				h.fade =null;
				return
			}
		}		
		hintList.push(new Hint(mc,txt,w))
	}
	function removeHint(mc){
		for( var i=0; i<hintList.length; i++ ){
			var h = hintList[i]
			if(h.parent==mc && h.fade == null ){
				h.fade = 100;
			}
		}
	}	
	
	// DIALOG
	function speak(txt){
		addDialog(txt);
	}
	
	function newDialog(txt){
		var d = new Dialog(txt)
		if(dial!=null){
			dial.kill();
		}
		attachDialog(d)
	}
	
	function addDialog(txt){
		var d = new Dialog(txt)
		if(dial==null){
			attachDialog(d)
		}else{
			diaList.push(d)
		}
		return d
	}	
	
	function attachDialog(d){
		dial = d;
		d.setSkin(downcast(dm.attach("mcDialog",DP_HINT)) )
	}

	
	//
	function quit(){
		butQuit.removeMovieClip();
		Manager.fadeSlot("menu",Cs.mcw,Cs.mch)
	
	}
	
	function kill(){
		removeMovieClip();
	}
		
	
	
	
//{
}