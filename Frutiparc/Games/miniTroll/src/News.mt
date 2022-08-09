class News extends Slot{//}

	var itemList:Array<int>
	var pic:MovieClip;
	var field0:TextField;
	
	var score:int;
	
	function new(){
		super();
	}
	
	function init(){
		super.init();
		
	}

	function maskInit(){
		super.maskInit();
		initButQuit();
		butQuit.onPress = callback(this,tryToQuit)
	}	
	
	
	function update(){
		super.update();
	}
	
	function setNews(id){
		
		switch(id){
			case 0:
				gotoAndStop("2")
				field0.text = "Bravo vous avez etabli un nouveau record !!\n"+score+" points!"
				break;
		}
		
		if( id>10 ){
			gotoAndStop("1")
			pic.gotoAndStop(string(id-9))
			field0.text = "Felicitations vous avez atteint "+Lang.checkpointName[id-10]+" !!"
			
		}
	}
	
	function tryToQuit(){
		if(itemList.length>0){
			Manager.fadeSlot("inventory",120,120);
			downcast(Manager.slot).setExtraList(itemList);
			downcast(Manager.slot).flNoExtraDisplay = true;
			Manager.slot.postInit();
		}else{
			Manager.fadeSlot("menu",Cs.mcw,Cs.mch)
		}
		butQuit.removeMovieClip();
	}
	

	
//{	
}