/*----------------------------------------------

		FRUTIPARC 2 icon

----------------------------------------------*/

class but.Icon extends But{//}
	
	//CONSTANTES
	var dp_field:Number = 10;
	var dp_icon:Number = 20;
	var dp_but:Number = 30;
	//var icoRatio:Number = 1.66;
	
	// VARIABLE
	var textColor:Number;
	var uid:String;
	var type:String;
	var name:String;
	var desc:Object;
	var date:String;
	var access:String;
	var scaleModif:Number;
	
	// REFERENCE
	var iconList:cp.IconListFile;
	
	var flTitle:Boolean;
	var flButton:Boolean;
	var flSaveMousePos:Boolean;
	var dropBox:MovieClip;
	//var title:MovieClip;
	var ico:MovieClip;
	
	var fbouille:String;
	
	var icoRatio:Number;
	
	
	
	/*-----------------------------------------------------------------------
		Function: Icon()
		constructeur
	------------------------------------------------------------------------*/
	function Icon(){
		//this.init();
		this.icoRatio = 1.66;
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/
	function init(){
		//if(this.date!=undefined)Lang.formatDateString( this.date , "short" );
		if(this.flButton==undefined)this.flButton=true;
		if(this.flSaveMousePos==undefined)this.flSaveMousePos=true;
		if(this.flButton){
			this.attachMovie("transp","but",this.dp_but)
		}
		//_root.test+="this.Button("+this.but+")\n"
		
		this.menu = _global.getFileContextMenu(this);
		
		super.init();
		
		this.attach();
		

	};
	
	function onStatusObj(obj){
		//_global.debug("but.Icon.onStatusObj() [name: "+this.name+"]");
		if(obj.fbouille != undefined){
			this.applyFBouille(obj.fbouille);
		}
		if(obj.presence == 0){
			this.applyEmote(0);
		}else if(obj.status.emote != undefined){
			this.applyEmote(obj.status.emote);
		}
	}
	
	function onInfoBasic(obj){
		this.onStatusObj(obj);
	}
	
	function applyFBouille(id){
		//_global.debug("but.Icon.applyFBouille("+id+");");
		if(id == undefined) return;
		
		this.fbouille = id;
		this.ico.apply(id);
	}
	
	function applyEmote(id){
		if(id == undefined) return;
		
		this.ico.applyEmote(id);
	}
	
	function attach(){
		//ATTACH
		this.attachMovie("iconGFX","ico",20)

/*
		this.createEmptyMovieClip("ico",20)
		var listener = new Object();		
		var mcl = new FEMCLoader();
				
		var listener = new Object();
		
		listener.obj = this;
		listener.onLoadInit = function(mc) {
			//_root.test+="loadInit("+mc+")\n"
		}
		listener.onLoadComplete = function(mc){
			//_root.test+="loadComplete\n"
			this.obj.display();
		}
		listener.onLoadError = function(mc, errorCode) {
			_root.test+="de.URL errorCode:"+errorCode+"\n"
		}

		mcl.addListener(listener)

		mcl.loadClip(Path.fileIcon,this.ico)
*/
		this.display();	

		
	
	}
	
	function display(){
		
		//BORDEL
		this.ico.stop();
		if(this.type == "link"){
			if(this.uid.substr(0,4) == "link"){
				this.ico.gotoAndStop(this.uid);
			}else{
				this.ico.gotoAndStop(this.type);
			}
    }else if(this.type == "url"){
 			this.ico.gotoAndStop(this.uid);
		}else{
			this.ico.gotoAndStop(this.type);
			this.ico.dropBox = this.dropBox;
			this.ico.myIconGFX = this;
			if(this.type=="disc"){
				this.ico.disc.gotoAndStop(Number(this.desc[0])+1);
				this.ico.disc.label.gotoAndStop(this.desc[1]);
				this.ico.disc.label.gfx.stop();
			}else if(this.type == "folder"){
				this.ico.s1.gotoAndStop(this.desc[1]);
		}else if(this.type == "bouille"){
			this.ico.removeMovieClip();
			this.attachMovie("frutibouille","ico",20,{id: this.desc[1]});
			this.icoRatio = 1;
		}else if(this.type == "contact"){
			var domain = this.name.substring(this.name.indexOf("@"),this.name.length).toLowerCase();
			if(this.name.indexOf("@") < 0){
				// Faudrait voir à améliorer ça... 
				/*
				this.ico.s1.gotoAndStop("internal");
				this.ico.s1.attachMovie("frutibouille","fb",5,{id: this.fbouille});
				this.ico.s1.fb._xscale = 60;
				this.ico.s1.fb._yscale = 60;
				*/
				this.ico.removeMovieClip();
				this.attachMovie("frutibouille","ico",20,{id: this.fbouille});
				this.icoRatio = 1;

				//this.ico.s1.fb._x = -20;
				//this.ico.s1.fb._y = -20;
			}else if(domain == "@hotmail.com" || domain == "@hotmail.fr" || domain == "@msn.com" || domain == "@msn.fr"){
				this.ico.s1.gotoAndStop("msn");
			}else if(domain == "@aol.com" || domain == "@aol.fr" || domain == "@aol.ch" || domain == "@aol.be" || domain == "@aol.ca"){
				this.ico.s1.gotoAndStop("msn");
			}else if(domain == "@yahoo.com" || domain == "@yahoo.fr" || domain == "@yahoo.ch" || domain == "@yahoo.be" || domain == "@yahoo.ca"){
				this.ico.s1.gotoAndStop("yahoo");
			}
			}else if(this.type == "mail"){
				if(this.access != undefined){
					this.ico.s1.gotoAndStop(2);
				}else{
					this.ico.s1.gotoAndStop(1);
				}
			} else {
				//_root.test+="[ICON] type("+this.type+")\n"
			}
		}
		this.ico.s1.dropBox = this.ico.dropBox;
		this.ico.s1.myIconGFX = this;
		this.ico.s1.s2.dropBox = this.ico.dropBox;
		this.ico.s1.s2.myIconGFX = this;		


		
	}
	

	// TODO: voir si on pourrait pas rassembler ça avec le reste
	/*-----------------------------------------------------------------------
		Function: onDragRollOver()
	------------------------------------------------------------------------*/
	function onDragRollOver(){
		this.iconList.playAnimDragRollOver(this);
	};
	
	/*-----------------------------------------------------------------------
		Function: onDragRollOut()
	------------------------------------------------------------------------*/
	function onDragRollOut(){
		this.iconList.playAnimRollOut(this);
	};
	
	function onAccess(val){
		this.access = val;
		if(this.type == "mail"){
			this.ico.s1.gotoAndStop(2);
		}
	}
//{
}


















