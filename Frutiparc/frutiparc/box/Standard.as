/*
$Id: Standard.as,v 1.4 2004/02/11 08:27:15  Exp $

Class: box.Standard
*/
class box.Standard extends box.FP{
	var pluginList;
	
	function Standard(){
	
	}
	
	function preInit(){
		if(this.desktopable == undefined) this.desktopable = true;
		if(this.tabable == undefined) this.tabable = true;
		super.preInit();
	}
	
	function init(slot,depth){
		var rs = super.init(slot,depth);
		
		// this.mode = "desktop", "tab", "trash"
		// this.window
		if(rs){
		
		}else{
	
		}
		
		this.window.setTitle(this.title);
	
		return rs;
	}
}

