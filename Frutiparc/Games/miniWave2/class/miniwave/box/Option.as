class miniwave.box.Option extends miniwave.Box{//}
	
	
	var content:MovieClip;
	var pref:Object;
	var tabCode:asml.KeyManager;
	var optList:Array;
	
	function Option(){
		this.init();
	}
	
	function init(){
		super.init();
		//_root.test+="[ BOX OPTION ] init()\n"
		this.content._visible = false;
		this.pref = this.page.menu.mng.fc[1]
		this.tabCode = new asml.KeyManager()
		this.optList = new Array();
	}
	
	function update(){
		super.update();

		for( var i=0; i<this.optList.length; i++ ){
			var mc = this.optList[i]
			var t = mc.ta
			if(mc.fta != undefined ) t = mc.fta
			
			mc.a = mc.a*0.9 + t*0.1
			mc.bg._alpha = mc.a
			//mc.bg._visible = Math.floor(a)
		}
		
		
	}
	
	function initContent(){
		super.initContent();
		this.content._visible = true;
		
		
		var nameList = [
			"Aller à gauche",
			"Aller à droite",
			"Tirer",
			"Super Attaque"
		]
		var y = 28
		for( var i=0; i<6; i++ ){
			this.content.attachMovie("optField","opt"+i,10+i)
			var mc = this.content["opt"+i]
			mc.id  = i
			switch(i){
				case 0:
				case 1:
					mc.flag = this.pref.$sound[i]
					break;
				case 2:
					y+=8
				case 3:
				case 4:
				case 5:
					mc.kid = i-2
					mc.name = nameList[mc.kid]
					break;
				
			}
			this.updateOpt(mc);
			
			// BUT
			mc.but.onPress = function(){
				this._parent._parent._parent.pushBut(this._parent)
			}
			mc.but.onRollOver = function(){
				this._parent.ta = 50
			}
			mc.but.onRollOut = function(){
				this._parent.ta = 0
			}
			mc.but.onDragOut = mc.but.onRollOut;
			
			// A
			mc.a = 0
			mc.ta = 0
			
			// Y
			mc._y = y
			y+=17
			
			optList.push(mc)
			
		}
		
		
		
	};

	function removeContent(){
		super.removeContent();
		this.content._visible = false;
	}

	function updateOpt(mc){
		switch(mc.id){
			case 0:
				if(mc.flag){
					mc.field.text = "Musique activée"
				}else{
					mc.field.text = "Musique desactivée"
				}
				break;
			case 1:
				if(mc.flag){
					mc.field.text = "Effets sonores activés"
				}else{
					mc.field.text = "Effets sonores desactivés"
				}				
				break;
			case 2:
			case 3:
			case 4:
			case 5:
				mc.field.text = mc.name+" : "+this.tabCode.getKeyName( this.pref.$key[mc.kid] )
				break;
			
		}	
	}

	function pushBut(mc){
		mc.a = 100
		this.page.menu.mng.sfx.play( "sMenuBeep")
		switch(mc.id){
			case 0:
			case 1:
				
				mc.flag = !mc.flag;
				this.pref.$sound[mc.id] = mc.flag
				//this.mng.updateParams();
				this.updateOpt(mc)
				this.page.menu.mng.updateSound()
				break;
			case 2:
			case 3:
			case 4:
			case 5:
				mc.fta = 50
				if( this.content.mck != undefined ){
					if(this.content.mck == mc)return;
					this.pushKey(this.pref.$key[this.content.mck.kid])
				}
				this.content.mck = mc;
				var listener = new Object();
				listener.root = this;
				listener.onKeyDown = function (){
					this.root.pushKey(Key.getCode())
				}
				//mc.gotoAndPlay(2);		
				mc.field.text = mc.name+" : ---";
				Key.addListener(listener)				
				break;
			
		}

	}
	
	function pushKey(n){
		if( this.content.mck != undefined ){
			this.page.menu.mng.sfx.play( "sMenuBeep")
			var id = this.content.mck.kid
			//this.setKeyCode(this.content.mck,n)
			this.pref.$key[id] = n;
			this.updateOpt(this.content.mck)
			delete this.content.mck.fta;
			delete this.content.mck;
			
		}
		
	}
	
	
	
	
	
//{	
}