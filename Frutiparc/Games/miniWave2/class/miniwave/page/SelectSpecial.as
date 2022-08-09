class miniwave.page.SelectSpecial extends miniwave.Page{//}

		
	
	function SelectSpecial(){
		this.init();
	}
	
	function init(){
		//_root.test+="selectSpecial\n"
		super.init();
		
	}
	
	function initBox(){
		super.initBox();
		
		
		
		
		
		var list = this.menu.mng.fc[0].$mode[2]
		var max = list.length;
		var m = 6;
		var h = (this.height-m*(max-1))/max;
		
		for(var i=0; i<max; i++){
			var  initObj = {
				gx:0,
				gy:(h+m)*i,
				gw:this.width,
				gh:h,
				waitTimer:8*i,
				id:i,
				flLock:!list[i]
			}
			var mc = this.newBox("miniWave2BoxSpecial",initObj)
		}

	
	
	}
	
	
	function select(id){
		switch(id){
			case 0:
				var info = miniwave.lvl.Letter.level
				this.menu.gameInfo.type	= "GameLetter"
				this.menu.gameInfo.waveInfo = info.lvl
				this.menu.gameInfo.name = info.name
				break;
			case 1:
				this.menu.gameInfo.type	= "GameSurvival"
				break;
			case 2:
				this.menu.gameInfo.type	= "GameTime"
				break;		
		}
		this.menu.setNextPage({link:"launchGame"});		
	}

	
	
	
	
//{
}