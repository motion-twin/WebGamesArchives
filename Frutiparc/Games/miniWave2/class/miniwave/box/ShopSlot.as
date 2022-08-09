class miniwave.box.ShopSlot extends miniwave.Box{//}
	
	// PARAMETRES
	var id:Number;
	var name:String;
	var price:String;
	
	var field:TextField;
	var ico:MovieClip;
	var but:Button;
	
	var creditPanel:miniwave.box.Credit
	
	function ShopSlot(){
		this.init();
	}
	
	function init(){
		//_root.test+="ShotSlot init()\n"
		super.init();
		this.ico._visible = false;
		this.field._visible = false;
	}
	
	function initContent(){
		super.initContent();
		this.ico._visible = true;
		this.field._visible = true;
		this.field._width = this.gw
		
		if(this.id<10 || this.id>12){
			this.ico._xscale = this.gw-10
			this.ico._yscale = this.gw-10
		}
		
		this.ico._x = this.gw/2
		this.ico._y = this.gh/2	+ 6
				
		this.field.text = this.price;
		this.ico.gotoAndStop(this.id+1)
		
		this.attachMovie( "transp", "but", 10 )
		this.but._xscale = this.gw
		this.but._yscale = this.gh
		
		this.but.onPress = function(){
			this._parent.select();
		}
		
		
	};
		
	function removeContent(){
		super.removeContent();
		this.ico._visible = false;
		this.field._visible = false;	
		this.but._visible = false;	
	};
	
	function select(){
		//this.page.buy(this);
		var fc = this.page.menu.mng.fc[0]
		if( this.price <= fc.$credit /*&& this.id != 13 && this.id != 14*/ ){
			this.page.menu.mng.sfx.play( "sMenuBeep")
			fc.$shop[this.id] = 0;
			fc.$credit -= price;
			this.creditPanel.updateCredit();
			this.lock();
			
			switch(this.id){
				case 0:
				case 1:
				case 2:
				case 3:
				case 4:
					fc.$ship[this.id+1] = 1;
					this.page.menu.mng.client.giveItem("$ship0"+(this.id+1));				
					break;
				case 5:
				case 6:
				case 7:
					fc.$mode[1][this.id-5] = 1;
					break;
				case 8:	
				case 9:
					fc.$mode[2][this.id-8] = 1;
					break;
				case 10:
					this.page.menu.mng.client.giveItem("$smiley_love")
					break
				case 11:
					this.page.menu.mng.client.giveItem("$smiley_laugh")
					break
				case 12:
					this.page.menu.mng.client.giveItem("$smiley_twirl")
					break
				case 13:
					this.page.menu.mng.client.giveItem("$wpMinistar")
					break
				case 14:
					this.page.menu.mng.client.giveItem("$wpNostromo")
					break
				case 15:
				case 16:
				case 17:
					fc.$mode[1][this.id-12] = 1;
					break;
			}
			var g = 0
			g += fc.$stats.$play.$main
			g += fc.$stats.$play.$mission
			g += fc.$stats.$play.$survival
			g += fc.$stats.$play.$letter
			fc.$stats.$buy.push({id:this.id,g:g})
			
			
			this.page.menu.mng.client.saveSlot(0);
			
		}else{
			this.page.menu.mng.sfx.play( "sMenuBeepWrong")
		}
	}
		
	
	
	
	
	
	
//{	
}