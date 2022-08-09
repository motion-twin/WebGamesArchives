class But extends Component/*MovieClip*/{//}
	
	//var flActive:Boolean;
	
	var pos:Object;
	var link:String;
	var frameDecal:Number;
	var buttonAction:Object;
	var butType:String;
	//var frameDecal:Number;
	
	var min:Object;
	var gfx:MovieClip;
	var but:MovieClip;
	var win:MovieClip;	// POUR LES XML QUI PEUVENT PAS ENVOYER DE PATH ( LES PAUVRES )
	var doc:cp.Document;
	
	var tipId:String;
	var tipCb:Object;
	
	var flTrace:Boolean;
	
	var menu:ContextMenu;
	
	/*-----------------------------------------------------------------------
		Function: Init()
	------------------------------------------------------------------------*/	
	function init(){
		super.init();
		/*
		if(this.flTrace!=undefined){
			_root.test+="this.buttonAction.onPress[0].obj("+this.buttonAction.onPress[0].obj+")\n"
			for(var elem in this.buttonAction){
				_root.test+=" - "+elem+" "+this.buttonAction[elem]+"\n"
			}
		}
		*/
		//this.flActive = true;
		//if(this.win!=undefined)_root.test+="j'ai bien recu la win("+this.win+")\n";
		//if(this.frameDecal==undefined)this.frameDecal=0;
		if(this.min==undefined)this.min=new Object();
		initBut();
		initTip();
		
		this.setButtonMethod("onRelease",this,"toggle");
	}
	
	function initTip(){
		if(this.tipId != undefined){
			if(this.tipCb != undefined){
				this.setButtonMethod("onRollOver",_global.tip,"displayCallBack",{cb: this.tipCb,id: this.tipId});
				this.setButtonMethod("onDragOver",_global.tip,"displayCallBack",{cb: this.tipCb,id: this.tipId});
				this.setButtonMethod("onRollOut",_global.tip,"remove",this.tipId);
				this.setButtonMethod("onDragOut",_global.tip,"remove",this.tipId);
				this.setButtonMethod("onPress",_global.tip,"remove",this.tipId);
			}else{
				this.setButtonMethod("onRollOver",_global.tip,"displayBuiltIn",this.tipId);
				this.setButtonMethod("onDragOver",_global.tip,"displayBuiltIn",this.tipId);
				this.setButtonMethod("onRollOut",_global.tip,"remove",this.tipId);
				this.setButtonMethod("onDragOut",_global.tip,"remove",this.tipId);
				this.setButtonMethod("onPress",_global.tip,"remove",this.tipId);
			}
		}
	}
	
	/*-----------------------------------------------------------------------
		Function: InitBut()
	------------------------------------------------------------------------*/
	function initBut(){
		this.but.parent = this;
		for(var elem in this.buttonAction){
			//_root.test+="[initBut]elem:"+elem+"\n"
			this.but[elem] = function(){  
				var arr = this.parent.buttonAction[arguments.callee.event]
				for(var i=0;i<arr.length;i++){  
					if(typeof arr[i].obj == "string"){
						arr[i].obj=this.parent[arr[i].obj];	// POUR LES XML QUI PEUVENT PAS ENVOYER DE PATH ( LES PAUVRES )
					}
					arr[i].obj[arr[i].method](arr[i].args);  
				} 
			};
			this.but[elem].event = elem;
		}
		if(this.tabIndex != undefined){
			this.but.tabIndex = this.tabIndex;
		}
		this.but._focusrect = false;
	}
	
	/*-----------------------------------------------------------------------
		Function: setButtonMethod(event,obj,method,args)
	------------------------------------------------------------------------*/	
	function setButtonMethod(event,obj,method,args){  
		if(this.buttonAction[event] == undefined){  
			this.but[event] = function(){  
				//_root.test+="[setBut]elem:"+event+"\n"
				var arr = this.parent.buttonAction[arguments.callee.event];
				for(var i=0;i<arr.length;i++){  
					if(typeof arr[i].obj == "string"){
						arr[i].obj=this.parent[arr[i].obj];	// POUR LES XML QUI PEUVENT PAS ENVOYER DE PATH ( LES PAUVRES )
					}
					arr[i].obj[arr[i].method](arr[i].args);
					
				} 
			};
			this.but[event].event = event;
	  
			if(this.buttonAction == undefined){  
				this.buttonAction = new Object();  
			}  
			this.buttonAction[event] = new Array();  
		}  
		this.buttonAction[event].push({obj: obj,method: method,args: args});  
	};  
	
	/*-----------------------------------------------------------------------
		Function: delButtonEvent(event)
	------------------------------------------------------------------------*/	
	function delButtonEvent(event){  
		delete this.buttonAction[event];  
		delete this.but[event];  
	};

	/*-----------------------------------------------------------------------
		Function: update()
	------------------------------------------------------------------------*/	
	function update(){
		this._x = this.pos.x;
		this._y = this.pos.y;
		//_root.test+="this.gfx("+this.gfx+") pos("+this.pos.x+","+this.pos.y+") width("+this.gfx._width+") height("+this.gfx._height+")\n"
		//_root.test+="pos("+this.gfx._x+","+this.gfx._y+")\n"
		/*
			this.clear()
			this.lineStyle(1,0x66AA22)
			this.moveTo(0,0)
			this.lineTo(this.pos.w,0)
			this.lineTo(this.pos.w,this.pos.h)
			this.lineTo(0,this.pos.h)
			this.lineTo(0,0)
		*/
		this.setMin()
	}
	
	function updateSize(){
		super.updateSize();

	}
	
	
	/*-----------------------------------------------------------------------
		Function: setMin()
	------------------------------------------------------------------------*/	
	function setMin(){
		this.min.h = this._height;
		this.min.w = this._width;
		//_root.test+="this.min.h"+this.min.h+"\n";
	}
	
	/*-----------------------------------------------------------------------
		Function: initCustomMode()
	------------------------------------------------------------------------*/	
	function initCustomMode(){
		/*	
		permet de donner une structure de bouton standard flash
		necessite : "link" pour le lien vers lemovie de graph
		facultatif: "butType" pour le lien vers le bouton (defaut->"transp")	
		*/
		this.attachMovie(this.link,"gfx",10)
		if(this.butType==undefined)this.butType="transp";
		this.attachMovie(this.butType,"but",80)
		this.gfx.gotoAndStop(1+this.frameDecal);
		this.but._xscale = this.gfx._width;
		this.but._yscale = this.gfx._height;
	}

	/*-----------------------------------------------------------------------
		Function: defineCustomAction()
	------------------------------------------------------------------------*/	
	function defineCustomAction(){
		this.setButtonMethod("onRollOut",		this,	"gfxGotoFrame",	1	);
		this.setButtonMethod("onDragOut",		this,	"gfxGotoFrame",	1	);
		this.setButtonMethod("onReleaseOutside",	this,	"gfxGotoFrame",	1	);
		this.setButtonMethod("onRollOver",		this,	"gfxGotoFrame",	2	);
		this.setButtonMethod("onPress",			this,	"gfxGotoFrame",	3	);
		this.setButtonMethod("onRelease",		this,	"gfxGotoFrame",	2	);
	}

	/*-----------------------------------------------------------------------
		Function: gfxGotoFrame(num)
	------------------------------------------------------------------------*/	
	function gfxGotoFrame(num){
		this.gfx.gotoAndStop(num+this.frameDecal)
	}
	
	function active(){
		this.but._visible = true;
	}
	
	function deActive(){
		this.but._visible = false;
	}
	
	
//{	
}







