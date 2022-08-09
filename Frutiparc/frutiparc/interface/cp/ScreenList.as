class cp.ScreenList extends Component{
//}
	
	
	//CONSTANTE
	var ecart:Number = 2 ;
	
	//VARIABLES
	
	var flMultiScreen:Boolean
	var flCLBScreen:Boolean
	var size:Number;
	var max:Number;
	var win:MovieClip;
	var multiScreenList:Array;
	var list:Array;
	
	var screen:MovieClip;
	
	function ScreenList(){
		this.init();
	}
	function init(){
		//_root.test+="initScreenList v1.5\n"
		super.init();
		this.multiScreenList = new Array();
		this.flCLBScreen = false;
		this.flMultiScreen = false;
	}
	
	function updateSize(){
		super.updateSize();
		this.size = this.width;
		this.max = Math.floor(this.height/(this.size+this.ecart))
		this.win.box.userList.wantList(this,"setUserList", 0, this.max);
	}
	function setUserList(list, userTotal){
		this.list = list;
		if( this.max >= userTotal ){
			if(this.flCLBScreen)	this.removeCLBScreen();
			if(!this.flMultiScreen)	this.attachMultiScreen();
			this.updateMultiScreen();
		}else{
			if(this.flMultiScreen)	this.removeMultiScreen();
			if(!this.flCLBScreen)	this.attachCLBScreen();
			this.updateCLBScreen();
		}
	}
	
	//-------------- MultiScreen -----------------
	function attachMultiScreen(){
		this.flMultiScreen = true;
		for(var i=0; i<this.list.length; i++){
			this.attachFrutiScreen(i);
		}
		
	}
	function removeMultiScreen(){
		this.flMultiScreen = false;
		while(this.multiScreenList.length){
			this.detachFrutiScreen(0);
		}
	}	
	function updateMultiScreen(){
	
		// On ajoute ce qui manque
		for(var i=this.multiScreenList.length; i<this.list.length; i++){
			this.attachFrutiScreen(i);
			if(i>20){
				_root.test += "plantage ! screenAttach !\n";
				return;
			}
		};

		// On met à jour les screen
		for(var i=0;i<this.list.length;i++){
			this.updateScreen(i);
			if(i>20){
				_root.test += "plantage ! screenUpdate !\n";
				return;
			}
		}

		// On nettoie ce qui dépasse
		while(this.list.length<this.multiScreenList.length){
			this.detachFrutiScreen(this.multiScreenList.length-1);
			if(i>20){
				_root.test += "plantage ! screenDetach !\n";
				return;
			}
		};
		
	}
	function attachFrutiScreen(n){
		var user = this.list[n];
		this.content.attachMovie("frutiScreen","screen"+n,n,{user:user,fix:{w: this.size,h: this.size}});
		var mc = this.content["screen"+n];
		mc._y = n*(this.size+this.ecart)
		this.multiScreenList[n] = mc;
		this.win.box.userList.defineMc(user,mc)
		mc.setAction({obj: this.win.box,method: "openFrutizInfo",args: user});
		mc.setTip("frutiScreen"+user,{obj: this.win.box,method: "getTipDocLong",args: user});
		
		//_root.test+="this.win.box.userList.defineMc("+user+","+mc+")\n"
	}
	function detachFrutiScreen(n){
		//_root.test+="detach\n"
		var mc = this.multiScreenList[n];
		this.win.box.userList.undefineMc(mc.user,mc)
		//_root.test+="undefineMc("+mc.user+","+mc+")\n"
		mc.removeMovieClip("");
		this.multiScreenList.splice(n,1);
	}
	
	function updateScreen(n){
		var user = this.list[n];
		var mc = this.multiScreenList[n];
		if(mc.user!=user){
			if(mc.user!=undefined)this.win.box.userList.undefineMc(mc.user,mc);
			mc.user = user;
			this.win.box.userList.defineMc(user,mc);
			mc.setAction({obj: this.win.box,method: "openFrutizInfo",args: user});
		}
	}

	//-------------- CLBScreen -----------------
	function attachCLBScreen(){
		this.flCLBScreen = true;
		this.content.attachMovie("frutiScreen","screen",1,{flCLB:true,win: this.win});
		this.win.box.addUserActionListener(this.content.screen,"onCLBEvent")
	}
	function removeCLBScreen(){
		this.flCLBScreen = false;
		this.win.box.removeUserActionListener(this.content.screen,"onCLBEvent");
		this.content.screen.removeMovieClip("");
	}
	function updateCLBScreen(){
		//_root.test+="updateCLBScreen("+this.width+","+this.height+")\n"
		this.content.screen.extWidth = this.width;
		this.content.screen.extHeight = this.height;
		this.content.screen.updateSize();
	}

	//-----------------------------------------
	
	/*-----------------------------------------------------------------------
		Function: onKill()
	------------------------------------------------------------------------*/		
	function onKill(){
		_global.debug("onKill");
		
		if(this.flCLBScreen) this.removeCLBScreen();
		if(this.flMultiScreen) this.removeMultiScreen();
		super.onKill();
	}

	
//{	

}








