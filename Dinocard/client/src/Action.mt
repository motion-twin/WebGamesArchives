class Action{//}

	static var DEBUG_LAST:int;
	
	var flInit:bool;
	var flClick:bool;
	
	var waitTimer:float;
	
	var primedata:DataAction;
	var playList:Array<Action>
	var parentList:Array<Action>
	
	function new(d){
		primedata = d
		flInit = false;
	}
	
	function init(){
		flInit = true;
		DEBUG_LAST = primedata.$type;
		//Cs.log("initAction("+primedata.$type+")",1)
		
	}
	
	function update(){

		if(!flInit)init();
		if(playList.length>0)playList[0].update();
		if(waitTimer!=null){
			waitTimer-=Timer.tmod;
			if(waitTimer<=0 )kill();
		}		
	}

	function setPlayList(list:Array<DataAction>){
		playList = new Array();
		for( var i=0; i<list.length; i++ ){
			Cs.game.addAction(list[i],playList)
		}	
	}
	
	function kill(){
		Cs.game.flClick = false
		parentList.remove(this)
	}

//{
}