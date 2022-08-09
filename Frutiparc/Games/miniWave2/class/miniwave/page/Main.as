class miniwave.page.Main extends miniwave.Page{//}

	var boxInfo:miniwave.box.InfoMain

	function Main(){
		this.init();
	}
	
	function init(){
		super.init();
	}
	
	function initBox(){
		super.initBox();
		//_root.test+="initBox\n"
		var list = [
			{ 
				name:"ARCADE",	
				cb:{
					obj:this.menu,
					method:"selectMainLevel"
				}
			},
			{
				name:"BONUS",
				cb:{
					obj:this.menu,
					method:"setNextPage",
					args:{
						link:"SelectLevel",
						initObj:{
							shipMax:3
						}	
					}	
				}				
			},
			{ 
				name:"SPECIAL"
			},
			{
				name:"STAND",
				cb:{
					obj:this.menu,
					method:"setNextPage",
					args:{
						link:"miniWave2PageShop"
					}	
				}					
			},
			{
				name:"OPTION"
			}
		]
		
		var y = 0	
		for(var i=0; i<list.length; i++ ){
			//_root.test+="mc("+this.menuIsActive(this.menu.mng.fc[0].$mode[i])+")\n"
			var  initObj = {
				id:i,
				gx:0,
				gy:y,
				waitTimer:i*8,
				name:"bonjour",
				flLock:!this.menuIsActive(this.menu.mng.fc[0].$mode[i])
				
			}
			var info = list[i]
			for( var elem in info ){
				initObj[elem] = info[elem]
			}					
			var mc = this.newBox("miniWave2BoxMenu",initObj)
			
			y+=30
			if(i==2)y+= (this.height-(list.length*30-10));
		}

		// DECRIPTION
		var  initObj = {
			gx:110,
			gy:0,
			gw:110,
			gh:this.height,
			waitTimer:0
		}
		this.boxInfo = this.newBox("miniWave2BoxInfoMain",initObj)
	
	}
	
	function select (id){
		switch(id){
			case 0:
				this.menu.gameInfo.type = "GameMain"
				this.menu.selectMainLevel()
				break;
			case 1:
				this.menu.gameInfo.type = "GameMission"
				this.menu.setNextPage({link:"miniWave2PageSelectLevel"})
				break;
			case 2:
				this.menu.setNextPage({link:"miniWave2PageSelectSpecial"})
				break;
			case 3:
				this.menu.setNextPage({link:"miniWave2PageShop"})
				break;
			case 4:
				this.menu.setNextPage({link:"miniWave2PageOption"})
				break;				
		}
	}
	
	function rOver(id){
		this.boxInfo.setPage(id+1)
	}
	
	function rOut(id){
		this.boxInfo.setPage(0)
	}	
	
	

//{
}