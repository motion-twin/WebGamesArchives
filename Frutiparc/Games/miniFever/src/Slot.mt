class Slot extends MovieClip{//}

	var infoList:Array<int>
	var dm:DepthManager;
	
	function new(){
		dm = new DepthManager(this);
	}	
		
	function init(){
		
	}
	
	function update(){
	}
	
	function quit(){
		Manager.genSlot("menu")
		Manager.slot.init();
	}
	
	function kill(){
		removeMovieClip();
	}
		
	function leave(){
		if(Manager.queue.length>0){
			var o = Manager.queue.pop()
			Manager.genSlot(o.link)
			Manager.slot.infoList = o.infoList
			
		}else{
			Manager.genSlot("menu")
		}
		Manager.slot.init();
	}
	
	
//{
}
