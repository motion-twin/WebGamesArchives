/*---------------------------------------------
		
		FRUTIPARC windowComponent

---------------------------------------------*/

class cp.RoomList extends Component{//}
	
	// CONSTANTES
	var dp_butText:Number = 10;
	
	// VARIABLE
	
	var flList:Boolean;
	
	var pal:Object;	//text bg
	var list:Array;
	
	
	
	/*-----------------------------------------------------------------------
		Function: UserList()
		constructeur;
	 ------------------------------------------------------------------------*/	
	function RoomList(){
		this.init();
		//_root.test+="userList init\n"
	}

	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/
	function init(){


		this.flList=false;
		super.init();
		if(this.pal==undefined){
			this.pal={
				bg:this.style.color[0]
			}
		}		
	}
	
	/*-----------------------------------------------------------------------
		Function: genContent()
	 ------------------------------------------------------------------------*/	
	function genContent(){
		super.genContent();
		if(this.list!=undefined)this.setList(this.list);
	}

	/*-----------------------------------------------------------------------
		Function: updateSize()
	 ------------------------------------------------------------------------*/	
	function updateSize(){
		super.updateSize();
		for(var i=0; i<this.list.length; i++){
			var mc = this.content["butText"+i]
			mc.extWidth = this.width;
			mc.updateSize();
		}
	}

	/*-----------------------------------------------------------------------
		Function: setList()
	 ------------------------------------------------------------------------*/	
	function setList(list){
		//_root.test+="setList("+list+")\n"
		/*
		var list = [
	
			{ name:"bumdum", nbUser:240, id:1 },
			{ name:"bumdum2", nbUser:210, id:2 },
			{ name:"bumdum3", nbUser:10, id:3 },
			{ name:"bumdum4", nbUser:22, id:4 }
		
		]
		*/
		if(this.flWait)this.removeWait();
		this.list = list;
		var h = 20
		for(var i=0; i<this.list.length; i++){
			var info = this.list[i];
			var initObj = {
				text:info.name+" ("+info.nbUser+")",
				width:this.width,
				height:h,
				behavior:{
					type:"colorBackground",
					color:{
						base:this.pal.bg.darker,
						over:this.pal.bg.dark,
						press:this.pal.bg.main,
						bg:pal.bg.lighter
					}		
				},
				buttonAction:{
					onRelease:[{obj:this.win.box,method:"join",args:info.id}]
				}
			}
			var tsg = Standard.getTextStyle();
			initObj.textStyle = tsg.def;
			initObj.textStyle.textPropery.color = 0x000000//this.pal.bg.darkest;
			if( i%2 == 0 ){
				//_root.test+="pal.bg("+this.pal.bg+") pal("+this.pal+")\n this.style.color("+this.style.color+")\n"
				initObj.flBackground=true;
				initObj.bgColor= this.pal.bg.shade;
			}			
			this.content.attachMovie("butText","butText"+i,this.dp_butText+i,initObj);
			var mc  = this.content["butText"+i];
			//_root.test+=" - mc("+mc+")\n"
			mc._y = i*h;
		}
		this.flList=true;
	}	
	
	/*-----------------------------------------------------------------------
		Function: removeList()
	 ------------------------------------------------------------------------*/	
	function removeList(){
		for(var i=0; i<this.list.length; i++){
			var mc  = this.content["butText"+i];
			mc.removeMovieClip();
		}		
		this.flList=false;
	}
	
	
//{	
}






