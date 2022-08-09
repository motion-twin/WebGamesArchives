// WIN URL



class win.Url extends win.Advance{//}
	var panel:cp.Url;
	
	function Url(){
		this.init();
	}
	
	function init(){
		super.init();
	}
	
	function initFrameSet(){
		super.initFrameSet();
		var args = {
		
		}
		var frame = {
			name:"panel",
			link:"cpUrl",
			type:"compo",
			min:{w:100,h:100},
			args:args
		}
		
		this.panel = this.main.addElement(frame)
	}
	
	function setPanel(panel){ //panel:{url,initObj,w,h}
	
		this.main.panel.min.w = panel.w
		this.main.panel.min.h = panel.h
		
		this.panel.loadUrl( panel.url, panel.initObj )
		
	}	
	
//{	
}