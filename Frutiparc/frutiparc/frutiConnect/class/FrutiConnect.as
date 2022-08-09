class FrutiConnect extends MovieClip{//}

	// CONSTANTES
	var mcw:Number = 700
	var mch:Number = 480
	
	// PARAMETRES
	var roomId:Number;
	
	// VARIABLES
	var gameName:String;
	var manager:Object;	//<----- à typer plus précisemment
	var colorSet:Array;	
	var keyEnterCallback:Object;
	//var keyListener:Object;
	
	// MOVIECLIP
	var room:fc.Room;
	var menu:fc.Menu
	var error:fc.Error;
	
	function FrutiConnect(){
		this.init()
	}
	
	function init(){
		//_root.test+="FrutiConnect init\n"
		this.initColorSet();
		if( this.roomId == undefined ){
			this.initMenu();
		}else{
			//this.manager.joinRoom(this.roomId)
			//this.manager.joinRoom(this.roomId)
			this.initRoom();
		}
		
		//this.initRoom();
		this.initKeyListener();
		
		/* TEST 
		var o = {
			title:"ta frusion a éclaté",
			text:"mon dieu c'est affreux !",
			butList : [
				{text:"hurler",callback:{obj:this,method:"debug",args:"hurler"}},
				{text:"crier",callback:{obj:this,method:"debug",args:"crier"}},
				{text:"pleurer",callback:{obj:this,method:"debug",args:"pleurer"}}
			]
		}
		this.displayError(o)
		//*
		
		/*
		var myOnKeyDown = function (){
			_root.test += "Key pressed : "
			var n = Key.getCode() 
			switch(n){
				case Key.ENTER :
				_root.test += "Key.ENTER \n"
				break;
				
			}
		}
		this.onKeyDown = myOnKeyDown
		*/
		
	}
	
	function initKeyListener(){
		var keyListener = {mng:this}
		keyListener.onKeyDown = function (){
			//_root.test += "Key pressed : "
			var n = Key.getCode() 
			switch(n){
				case Key.ENTER :
					var c = this.mng.keyEnterCallback;
					c.obj[c.method](c.args);
					break;
				case Key.BACKSPACE :
					_root.test=""
					break;
			}
		}
		Key.addListener(keyListener)
	}
	
	function initColorSet(){
		if(this.colorSet==undefined){
			this.colorSet = [
				{	// GREEN
					lighter:0xDDF5AD,
					main:0x9DDF44
				},
				{	// YELLOW
					lighter:0xFDF0D7,
					main:0xFFD050
				},			
				{	// RED
					lighter:0xFECFCF,
					main:0xF87474
				}			
			]
		}		
	}	
	
	function initRoom(){
		this.attachMovie("fcRoom","room",1,{root:this})
	}
	
	function initMenu(){
		this.attachMovie("fcMenu","menu",1,{root:this})
	}
		
	function kill(){
		this.removeMovieClip();
	}
	
	function displayError(initObj,colorId){
		if( initObj == undefined ) initObj = new Object();
		if( colorId == undefined ) colorId = 2
		initObj.color = this.colorSet[colorId].main
		this.attachMovie( "fcError", "error", 10, initObj )
		this.error._x = (this.mcw-this.error.width)/2
		this.error._y = (this.mch-this.error.height)/2
		
	}
	
	function debug(str){
		_root.test+="- "+str+"\n"
	}
	
//{	
}
