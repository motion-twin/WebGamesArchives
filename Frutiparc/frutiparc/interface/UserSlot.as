/*
$Id: UserSlot.as,v 1.28 2005/08/04 16:06:03  Exp $

Class: UserSlot
*/
class UserSlot extends MovieClip{//}

	
	// PARAMS
	var flButton:Boolean
	var flgender:Boolean
	var displayType:String;
	var userName:String;
	
	// VARIABLES
	var flTrace:Boolean;
	var flUser:Boolean;
	var backgroundId:Number
	var iconBackgroundId:Number;	
	
	var box:Object;
	var userBox:Object;
	var dropBox;
	var statusDspMode:String;

	
	var mcUser:MovieClip;
	var icon:MovieClip;
	var bg:MovieClip;
	
	var menu:ContextMenu;
	
	var fbouille:String;
		
	
	function UserSlot(){
		this.init();
		//_root.test=" init userSlot:"+this.name+"\n";
	}
	
	function init(){
		
		//if(this.flTrace)_root.test+="[UserSlot]this.init()\n"
		
		this.initDefault()
		
		this.initText();
		this.attachMovie("status", "icon", 1);

		
		

		this.setIconBackground(this.iconBackgroundId)
		this.setBackground(this.backgroundId);
		
		this.flUser=false;
		
		if(this.flButton) this.initButtons();

		if(this.dropBox != undefined){
			this.mcUser.field.dropBox = this.dropBox;
		}
		
		
	}
	
	function initDefault(){
		if( this.flButton == undefined )		this.flButton  = 		true;
		//if( this.flTextOnly == undefined )		this.flTextOnly  = 		true;
		if( this.iconBackgroundId == undefined )	this.iconBackgroundId = 	3;
		if( this.backgroundId == undefined )		this.backgroundId =		1;		
		if( this.displayType == undefined )		this.displayType =		"gender";		
	}
	
	function initText(){
		var ts = Standard.getTextStyle().def;
		ts.textFormat.bold = true;
		//ts.textFormat.size = 12;
		var initObj = {
			//flTrace:true,
			width:100,
			height:20,
			textStyle:ts,
			_x:20
		}
		
		this.attachMovie("butText", "mcUser", 2, initObj);

		if(!this.flButton){
			this.mcUser.deActive();
		}		
	}
	
	function initButtons(){
		this.mcUser.setButtonMethod("onPress",this.mcUser,"saveMousePos");
		if(this.userBox != undefined){
			this.mcUser.setButtonMethod("onPress",this.userBox,"pressIcon");
			this.mcUser.setButtonMethod("onRelease",this.userBox,"click");
			this.mcUser.setButtonMethod("onDragOut",this.userBox,"createDragIcon");
		}else{
			this.mcUser.setButtonMethod("onRelease",this,"click");
			this.mcUser.setButtonMethod("onDragOut",this,"createDragIcon");
		}
	}
	
	function click(){
		// TODO: �tre un peu moins.... crade ;)
		if(this.box.group != undefined){
			_global.frutizInfMng.open(this.userName,undefined,this.box.group);
		}else{
			_global.onFileClick({uid: "new", type: "contact", desc: [this.userName+"@frutiparc.com"],name: this.userName});
		}
	}
	
	function createDragIcon(){
		if(this.userName != undefined){
			_global.createDragIcon({uid: "new", type: "contact", desc: [this.userName+"@frutiparc.com"],name: this.userName,fbouille: this.fbouille});
		}
	}
	
	function setIconBackground(frame){
		this.icon.bg.gotoAndStop(frame)
	}
	
	function setBackground(frame){
		this.bg.gotoAndStop(frame)
	}
	
	function onStatusObj(o){
		/*
		o = {
			presence:Number,// (0:offline/1:online/2:invisible)
			fbouille:String,
			status:Object = {
				internal:String,
				external:String,
				emote:Number
			}
		}
		*/
		if(o == undefined){
			this.icon.gotoAndStop(1);
		}else{
			this.fbouille = o.fbouille;
			
			if(o.presence == 0){
				if(this.statusDspMode == "all"){
					this.icon.gotoAndStop("presence");
					this.icon.ico.gotoAndStop(o.presence + 1);
				}else{
					this.icon.gotoAndStop(1);
				}
				
			}else if(o.status.internal != undefined){
				this.icon.gotoAndStop("internal");
				this.icon.ico.gotoAndStop(o.status.internal);
			}else if(o.status.external != undefined){
				this.icon.gotoAndStop("external");
				this.icon.ico.gotoAndStop(o.status.external);			
			}else{
				if(this.statusDspMode == "all"){
					this.icon.gotoAndStop("presence");
					this.icon.ico.gotoAndStop(o.presence + 1);				
				}else{
					this.icon.gotoAndStop(1);
				}
			}
		}	
	}
	
	function onInfoBasic(o){
		//if(this.flTrace)_root.test+="[UserSlot]this.onInfoBasic("+o+")\n";

   //this.userBox.flMode

		if(o.gender != undefined){
			var behavior
			if( this.displayType == "gender" ){
				var color
				if( o.gender == "M" ){
					behavior ={ type:"colorText", color:{ base:0x242169, over:0x2E42B1, press:0x5669B3 } }
				}else{
					behavior = { type:"colorText", color:{ base:0xBB4444, over:0xE77575, press:0xFEABAB } }
				}
			}else if( this.displayType == "xp" ){
				// A CODER
				behavior = { type:"colorText", color:{ base:0x335511, over:0x558811, press:0x66AA22 } }
			}

			this.mcUser.setBehavior(behavior)
		}

		this.onStatusObj(o)
		
		

	};
	
	
	function setUser(name){
		if(name == this.userName) return;
		this.cleanUser();
		this.newUser(name);
	};
	
	function newUser(name){
		this.userName = name;
		
		this.menu = _global.getFileContextMenu({type: "contact",name: this.userName,uid: "new",desc: [this.userName+"@frutiparc.com"],fbouille: this.fbouille});
		
		this.mcUser.setText(name);
		//this.onStatusObj();
		this.flUser=true;
		
		if(this.flButton){
			this.mcUser.tipId = "uSlot"+this.userName;
			this.mcUser.tipCb = {obj: this.box,method: "getTipDoc",args: this.userName};
			this.mcUser.initTip();
		}
		
		// Previens la box que le mc defini un nouveau user
		this.box.userList.defineMc(this.userName, this)
	};
	
	function cleanUser(){
		if(this.flUser){
			this.mcUser.setText();
			//this.onStatusObj()
			this.flUser=false;
			// previens la box que le user en cours n'est plus defini le mc
			this.box.userList.undefineMc(this.userName, this)
			this.userName = undefined;
		}
	}
//{
};
	
	
	
	
