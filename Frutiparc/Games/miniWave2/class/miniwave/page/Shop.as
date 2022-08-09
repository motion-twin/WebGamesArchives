class miniwave.page.Shop extends miniwave.Page{//}

	var lowHeight:Number = 20
	
	var xMax:Number = 5;
	var yMax:Number = 3;
	
	var slotList:Array;
	
	var creditPanel:miniwave.box.Credit

	function Shop(){
		this.init();
	}
	
	function init(){
		//_root.test+="miniwave.page.Shop\n"
		this.genSlotList();
		super.init();
		
	}
	
	function initBox(){
		super.initBox();

		var m = 5
		var w = (this.width-((this.xMax-1)*m))/this.xMax;
		var h = (this.height-(((this.yMax-1)*m)+this.lowHeight+7) )/this.yMax;
		
		
		var  initObj = {
			gx:0,
			gy:this.height-this.lowHeight,
			gw:this.width-(100+5),
			gh:this.lowHeight,
	
			waitTimer:15
		}
		this.creditPanel = this.newBox("miniWave2BoxCredit",initObj)
		this.creditPanel.updateCredit()

		var  initObj = {
			id:100,
			gx:this.width-100,
			gy:this.height-this.lowHeight,
			waitTimer:35,
			name:"RETOUR"
		}
		var mc = this.newBox("miniWave2BoxMenu",initObj)

		var slotIndex = 0
		var fc = this.menu.mng.fc[0]
		for( var y=0; y<this.yMax; y++ ){
			for( var x=0; x<this.xMax; x++ ){
			
				
				var si = slotIndex;
				
				if( slotIndex == 5 && fc.$mode[1][0] != 0 ) si = 15;
				if( slotIndex == 6 && fc.$mode[1][1] != 0 ) si = 16;
				var info = this.slotList[si]
				
				var  initObj = {
					id:si,
					gx:x*(w+m),
					gy:y*(h+m),
					gw:w,
					gh:h,
					name:info.name,
					price:info.price,
					creditPanel:this.creditPanel,					
					flLock:!this.menu.mng.fc[0].$shop[si],
					waitTimer:slotIndex*3
				}
				var mc = this.newBox("miniWave2BoxShopSlot",initObj)		
				slotIndex++;
			}		
		}		

	
	}
	
	function select (id){

		switch(id){
			
			case 100:
				this.menu.setNextPage({link:"miniWave2PageMain"})
				break;
	
		}
	}
	
	/*
	function tryToBuy(mc){
		var fc = this.menu.mng.fc[0]
		var price = this.slotList[mc.id].price
		if( price <= fc.$credit ){
			fc.$shop[mc.id] = 0;
			fc.$credit -= price;
			this.creditPanel.updateCredit();
			mc.lock();
		}
		
		switch(mc.id){
			case 0:
			case 1:
			case 2:
			case 3:
			case 4:
				fc.$ship[mc.id+1] = 1
				break;

	
		}		

		
		
		
	}
	*/
	
	function genSlotList(){
		this.slotList = [
			{ name:"Proto",		price:80	},	
			{ name:"Gapatsa",	price:140	},	
			{ name:"Namazan",	price:160	},	
			{ name:"Sacuro",	price:320	},	
			{ name:"Rycher",	price:680	},
			
			{ name:"Mission 1",	price:10	},
			{ name:"Mission 2",	price:50	},	
			{ name:"Mission 3",	price:80	},	
			{ name:"Letter Invader",price:120	},	
			{ name:"Endurance",	price:120	},
			
			{ name:"Smiley 1",	price:30	},			
			{ name:"Smiley 2",	price:220	},			
			{ name:"Smiley 3",	price:480	},
			{ name:"Wallpaper 1",	price:1600	},
			{ name:"Wallpaper 2",	price:2400	},
			
			{ name:"Mission 4",	price:200	},
			{ name:"Mission 5",	price:400	},	
			{ name:"Mission 6",	price:80	}			
		]		
	}

	
//{
}	