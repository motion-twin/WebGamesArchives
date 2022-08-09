class miniwave.page.SelectShip extends miniwave.Page{//}

	var lowHeight:Number = 20
	
	
	var timer:Number;
	var shipMax:Number;
	var shipStockList:Array;
	var lifePanel:MovieClip;
	var label:miniwave.box.Desc
	
	function SelectShip(){
		this.init();
	}
	
	function init(){
		super.init();
		
	}
	
	function initBox(){
		super.initBox();

		// DECRIPTION
		var w = this.width-(20+this.menu.gameInfo.shipMax*16)
		var  initObj = {
			gx:0,
			gy:this.height-this.lowHeight,
			gw:w,
			gh:this.lowHeight,
			waitTimer:16
		}
		this.label = this.newBox("miniWave2BoxDesc",initObj)
		// LIFEPANEL
		var  initObj = {
			gx:8+w,
			gy:this.height-this.lowHeight,
			gw:this.width-(8+w),
			gh:this.lowHeight,
			waitTimer:24
		}
		this.lifePanel = this.newBox("miniWave2BoxLife",initObj)				
		
		//this.menu.setBadsLow(true)
		this.shipStockList = new Array();
		
		// SHIPS
		
		var shipList = new Array();

		for( var i=0; i<6; i++ ){
			if(this.menu.mng.fc[0].$ship[i])  shipList.push(i)				
		}

		var max = shipList.length
		var x = 0
		var w = ( this.width - (max-1)*8 )/max

		for( var i=0; i<max; i++){
			var  initObj = {
				gx:x,
				gy:0,
				gw:w,
				gh:this.height-(this.lowHeight+8),
				waitTimer:i*8,
				id:shipList[i],
				totalSlot:max
			}
			var mc = this.newBox("miniWave2BoxShipDemo",initObj)
			x += 8+w
		}
		
	
	}
	
	function select(id){
		this.shipStockList.push(id);
		this.lifePanel.addLife(id);
		
		if( this.shipStockList.length == this.menu.gameInfo.shipMax ){
			this.flActive = false;
			this.timer = 20;
		}
	}
	
	function rOver(id){
		this.label.setText(this.menu.mng.heroInfo[id].name)
		this.label.setSmallText("")
	}
	
	function rOut(id){
		this.label.setText("")
		this.label.setSmallText("escadron selection")
	}
		
	function update(){
		super.update()
		
		if(this.step ==0 && !this.flActive){
			if(this.timer<0){
				this.menu.gameInfo.heroList = this.shipStockList;
				this.vanish();

				
				if( this.menu.gameInfo.missionNum == undefined ){
					this.menu.setNextPage({link:"launchGame"});
				}else{
					var initObj = {
						type:"briefing",
						num:this.menu.gameInfo.missionNum,
						nextPage:{ link:"launchGame" },
						size:{ w:210, h:170 }
					}
					this.menu.setNextPage( { link:"miniWave2PagePowerUp", initObj:initObj } )
				}
				
			}else{
				this.timer -= Std.tmod
			}
		}
		
		
	}

	
	
	
	
//{
}