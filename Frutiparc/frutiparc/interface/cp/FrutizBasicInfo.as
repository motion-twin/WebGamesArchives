class cp.FrutizBasicInfo extends Component{//}
	
	// CONSTANTE
	var closeButtonWidth:Number = 14
	
	
	var flWaiting:Boolean;
	var info:Object;
	
	
	// MOVIECLIPS
	var userSlot:UserSlot;
	var ageField:TextField;
	var locField:TextField;
	
	var closeButton:but.Group
	
	function FrutizBasicInfo(){
		this.init();
	}

	function init(){
		super.init();
		//_root.test+="[cpFrutizInfo]init()\n"
		this.flWaiting = true;
		this.initCloseButton();
		
	}
	
	function initCloseButton(){
		var initObj = {
			link:"WinTop",
			frame:1,
			buttonAction:{ 
				onPress:[{
					obj:this.win,
					method:"tryToClose"
				}]
			}
		}
		this.attachMovie("butGroup","closeButton",4,initObj)
		this.closeButton._y = -7
	}
	
	function updateSize(){
		super.updateSize();
		this.closeButton._x = this.width - this.closeButtonWidth
	}
	
	function setInfo(info){
		this.info = info;
		if(this.flWaiting)this.displayInfo();
		
		this.userSlot.setUser(info.nickname)
		this.userSlot.onInfoBasic(info)
		this.ageField.text = info.age+" ans - "+info.region //+" ("+info.country+")"
		//this.locField.text = info.region+" ("+info.country+")"
		
	}
	
	function displayInfo(){
		//_root.test+="[cpFrutizBasicInfo]displayInfo("+this.info+")\n"
		
		var color
		var displayType = _global.userPref.getPref("userSlot_display")
		switch(displayType){
			case 0 :
				color = 0x000000
				break;
			case 1 :
				if(this.info.gender=="M"){
					color = _global.colorSet.purple.darker
				}else{
					color = _global.colorSet.pink.darker
				}
				break;
			case 2 :
				// A CODER
				color = _global.colorSet.green.darker
				break;			
		}
		
		var dy = -2
		
		// STATUS + NICKNAME
		var initObj = {
			flTrace:true,
			iconBackgroundId:1,
			backgroundId:2,
			flButton:false,
			statusDspMode:"all",
			_x:4,
			_y:dy
		}
		this.attachMovie("userSlot","userSlot",11,initObj);
		
		// AGE
		var ti = new TextInfo()
		var w = 200
		ti.textFormat.color = color
		ti.textFormat.align = "right"
		ti.pos = { x:this.width-(w+this.closeButtonWidth), y:dy, w:w, h:18 }
		ti.attachField(this,"ageField",12)
		
		/*
		// VILLE :
		ti.textFormat.align = "center"
		ti.pos = { x:0, y:0, w:this.width, h:18 }
		ti.attachField(this,"locField",13)
		*/
		
		
	}
	
	
	
	
//{	
}