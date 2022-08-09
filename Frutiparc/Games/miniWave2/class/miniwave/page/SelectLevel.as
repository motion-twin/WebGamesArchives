class miniwave.page.SelectLevel extends miniwave.Page{//}

	var lowHeight:Number = 20
	
	
	var timer:Number;
	var shipMax:Number;
	var shipStockList:Array;
	var lifePanel:MovieClip;
		
	
	function SelectLevel(){
		this.init();
	}
	
	function init(){
		super.init();
		
	}
	
	function initBox(){
		super.initBox();
		
		var list = miniwave.lvl.Bonus.level
		for(var i=0; i<list.length; i++){
			var info = list[i]
			// DECRIPTION
			var w = 150
			var  initObj = {
				gx:0,
				gy:23*i,
				gw:this.width-56,
				gh:18,
				waitTimer:4*i,
				text:info.name,
				id:i,
				flLock:!this.menu.mng.fc[0].$mode[1][i]
				
			}
			var mc = this.newBox("miniWave2BoxLevelTitle",initObj)
		}
		
		
		
		for(var i=0; i<list.length; i++){
			var info = list[i]
			
			// DECRIPTION
			var w = 150
			var  initObj = {
				gx:this.width-50,
				gy:23*i,
				waitTimer:20+4*i,
				ratio:this.menu.mng.fc[0].$cons.$bonus[i],
				flLock:!this.menu.mng.fc[0].$mode[1][i]
			}
			var mc = this.newBox("miniWave2BoxPourcentage",initObj)
		}		
	
	}
	
	
	function select(id){
		this.menu.mng.sfx.play("sMenuBeep")
		//var info = this.menu.mng.lvlInfoBonus[id]
		var info = miniwave.lvl.Bonus.level[id]
		
		this.menu.gameInfo.waveInfo = info.lvl
		//_root.test+="info.lvl("+info.lvl+")\n"
		this.menu.gameInfo.name = info.name
		this.menu.gameInfo.shipMax = info.ship
		this.menu.gameInfo.prime= info.prime
		this.menu.gameInfo.missionNum = id
		this.menu.setNextPage({link:"miniWave2PageSelectShip"});
	}

	
	
	
	
//{
}