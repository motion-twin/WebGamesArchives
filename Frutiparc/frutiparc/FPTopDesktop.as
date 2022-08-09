/*
$Id: FPTopDesktop.as,v 1.4 2004/05/06 14:26:44  Exp $

Class: FPTopDesktop
*/
class FPTopDesktop extends FPDesktop{
	var boxToAdd:Array;
	var flAvailable:Boolean;

	function FPTopDesktop(){
		this.baseDepth = 0;
		this.flActive = true;
		this.flAvailable = true;
		this.boxToAdd = new Array();
		_global.main.createEmptyMovieClip("topDesktopMc",Depths.topDesktop);
		this.slotList = {
			mc: _global.main.topDesktopMc
		};
	}
	
	function addBox(box){
		/*
		if(!this.flAvailable){
			this.boxToAdd.push(box);
			return;
		}
		*/
		
		super.addBox(box);
		box.tabable = false;
	}
	
	function disable(){
		if(!this.flAvailable) return;
		
		this.flAvailable = false;
		
		this.onDeactivate();
		_global.debug("Disable END, flActive: "+this.flActive);
	}
	
	function enable(){
		if(this.flAvailable) return;
		
		this.flAvailable = true;
		/*
		for(var i=0;i<this.boxToAdd.length;i++){
			this.addBox(this.boxToAdd[i]);
		}
		this.boxToAdd = new Array();
		*/
		this.onActivate();
		
		_global.debug("Enable END, flActive: "+this.flActive);
	}
	
}