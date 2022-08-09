/*----------------------------------------------

		FRUTIPARC 2 sideList

$Id: SideList.as,v 1.20 2004/07/30 07:28:15  Exp $
----------------------------------------------*/

class SideList extends MovieClip{//}
	
	// DEPTH
	var dp_bg:Number = 		5 
	var dp_list:Number = 		20;
	var dp_butSearch:Number = 	24;
	var dp_scrollBar:Number = 	40;	
	var dp_element:Number = 	100;

	// GFX
	var wSide:Number = 9;
	var wMain:Number = 120;
	var wShade:Number = 3 ;
	var hSearch:Number = 24
	
	// VARIABLES
	var flActive:Boolean;
	var flScroll:Boolean;
	var flMoving:Boolean;
	var list:ContactList;
	var uid:Number;
	var currentLine:Number;
	var elementNum:Number;

	// A NETTOYER
	var mc:MovieClip;
	var traceUsrList:Array;
	var traceObjList:Array;
	var traceMethodList:Array;
	var name;
	var presence;
	var internal;
	var external;
	
	
	//MOVIECLIP
	var mcSide:MovieClip;
	var toggleBut:Button;
	//
	var mcList:MovieClip;
	var mcListMask:MovieClip;
	var butSearch:MovieClip;
	var bg:MovieClip;
	//
	var ombre:MovieClip;
	var butContact:MovieClip;
	
	function SideList(){
		this.init();
	}
	
	function init(){
		this.elementNum=0;
		
		this.flActive=false;
		//this.list=false;
		this.flScroll=false;
		this.flMoving=false;
		
		_global.fileMng.wantContact(this,"onReceiveList");
		_global.main.cornerX = this.wSide;

		_global.main.attachMovie("carreFond","sideListFond",Depths.sideListFond);
		this.ombre = _global.main.sideListFond;
		this.ombre._width=2;

		this.mcSide.onPress = function(){
			this._parent.toggle();
		}
		
		this.attachMovie("sideListContact","butContact",3)
		//_root.test+="this.butContact("+this.butContact+")\n"
		
		this.butContact._x = this.wSide;
		this.butContact.onPress = function(){
			this._parent.toggle();
		}
	}
	
	function update(){
	
		this.clear();
		var w = this.wSide;
		var h = _global.mch
		if(this.flActive) w += this.wMain;
		
		var pos = {	x:0,	y:0,			w:w,		h:h	};
		FEMC.drawSquare(this,pos,0xFFFFFF);
		
		var pos = {	x:w-this.wShade,	y:0,	w:this.wShade,	h:h	};
		FEMC.drawSquare( this, pos, 0xDDDDDD );

		//var pos = {	x:w,	y:0,	w:1,	h:h	};
		//FEMC.drawSquare( this, pos, 0x444444 );
		
		this.butContact._x = this.wSide + this.flActive*this.wMain
		
	}
	
	function onStageResize(){
		this.update();
		this.mcSide._height = _global.mch;
		this.ombre._x = _global.main.cornerX;
		this.ombre._height = _global.mch;
		this.toggleBut._height = _global.mch;
		this.butContact._y = _global.mch;
		
		if(this.flActive){
			this.bg._height=_global.mch;
			this.mcListMask._yscale = _global.mch-this.hSearch;
			this.butSearch._y = (_global.mch-hSearch)+3
		};
	}
	
	
	function activate(){
		_global.main.cornerX = this.wMain + this.wSide;
		//this._x = this.wMain;
		this.flActive=true;
		this.attachList();
		_global.main.onResize();
		this.update();		
	}
	
	function deActivate(){
		_global.main.cornerX = this.wSide;
		//this._x = 0;
		this.detachList();
		this.flActive=false;
		_global.main.onResize();
		this.update();		
	};
	
	function toggle(){
		if(this.flActive){
			this.deActivate();
		}else{
			this.activate();
		}	
	};

	function attachList(){
		this.attachMovie("carre","bg",this.dp_bg);
		this.bg._width = this.wMain;
		this.bg._height = _global.mch;
		this.bg._x = -this.wMain;
		this.bg.dropBox = this;
		
		if(this.list){
			this.buildList();
		}
	}

	function detachList(){
		this.bg.removeMovieClip();
		this.mcList.removeMovieClip();
		this.mcListMask.removeMovieClip();
		this.butSearch.removeMovieClip();
	};
	
	function onReceiveList(l){
		if(l != undefined){
			this.list.onKill();
			this.list = new ContactList(l,{obj: this,method: "buildList"},{obj: _global.myContactListCache,methodAdd: "addUser",methodRemove: "removeUser"});
			_global.mainCnx.traceFlush();
			this.uid = l.uid;
		};
		
		this.buildList();
	};

/*	
			l.onDrop = function(o){
				for(var i=0;i<this.list.length;i++){
					if(this.list[i].uid == o.uid) return;
				}
				_global.fileMng.move(o.uid,this.uid);
			};

*/

	function buildList(){
		//_root.test+="buildList\n"
		
		if(!this.flActive) return;
		// CASSE LA LISTE SI ELLE EXISTE
		if(this.mcList)this.mcList.removeMovieClip();
		
		// MCLIST
		this.createEmptyMovieClip("mcList",this.dp_list);
		this.createEmptyMovieClip("mcListMask",this.dp_list+2);
		var pos = { x:0, y:0, w:100, h:100 };
		FEMC.drawSquare(this.mcListMask, pos, 0xFF0000);
		this.mcListMask._xscale = wMain
		this.mcListMask._yscale = _global.mch-this.hSearch;
		this.mcList.setMask( this.mcListMask );
		
		// SEARCH
		this.attachMovie( "mcSearchButton", "butSearch", 10 )
		this.butSearch.onPress = function(){
			_global.uniqWinMng.open("search");
		}
		this.butSearch._y = (_global.mch-hSearch)+3
		
		
		this.currentLine=0;
		for(var i=0; i<this.list.list.length; i++){
			//this.buildElement(this.list.list[i],-this.wMain,true);
			this.buildElement(this.list.list[i],0,true);
		}
		
	};
	
	function buildElement(element,decal,open){
		if(element.list){
			if(open){
				this.elementNum++
				this.mcList.attachMovie("sideListTitle","folder"+this.elementNum,this.elementNum)
				var mc = this.mcList["folder"+this.elementNum];
				mc._x = decal
				mc._y = this.currentLine*18
				mc.title = element.name
				mc.element = element
	
				mc.fondD.gotoAndStop(1);
				mc.fondD._x = -mc.fondD._width+this.wMain-decal;
				mc.fond._width = mc.fondD._x;
	
				mc.fond.onPress = function(){
					this._parent.element.open = !this._parent.element.open;
					// TODO: enlever le nom absolu
					_global.main.sideList.buildList();
				};
				mc.fond.dropBox = element;
				mc.fondD.dropBox = element;
				mc.tf.dropBox = element;
				this.currentLine++;
				
				element.path = mc;
			}else{
				element.path = undefined;
			}
			
			for(var i=0; i<element.list.length; i++){
				this.buildElement(element.list[i],decal+5,open & element.open);
			}
			if(open){
				this.currentLine+=0.2
			}
		}else{
			if(open){
				/*
				this.elementNum++
				this.mcList.createEmptyMovieClip("line"+this.elementNum,this.elementNum)
				// Attache le nom
				mc.attachMovie("butText","field",10,{ textFormat:{bold:true}, text: element.name} )
				mc.field._x = 18;
				mc.field.dropBox = element;
	
				// Attache l'icone
				mc.attachMovie("status","status",5)
				mc.fond.gotoAndStop(1)
	
				mc.field.setButtonMethod("onRelease",element,"click");
				mc.field.setButtonMethod("onDragOut",element,"createDragIcon");
				mc.field.field.dropBox = element;
				
				if(element.flMoving){
					mc._alpha = 50;
				}
	
				//_root.test+="->"+element.internal+"\n"
	
				// TODO: Utiliser un objet standard pour g�rer les status (il me semble que le code qui est fait l� est plutot crade)
				mc.status.applyStatusObj = function(obj){
					if(obj.internal!=null){
						this.gotoAndStop("internal")
						this.ico.gotoAndStop(obj.internal);
					}else if(obj.external!=null){
						this.gotoAndStop("external")
						this.ico.gotoAndStop(obj.external);
					}else{
						this.gotoAndStop("presence")
						this.ico.gotoAndStop(obj.presence+1);
					}
				};
				mc.status.user = element.name;
				mc.status.applyStatusObj(element);
				element.mc = mc;
				// FIN DU CODE CRADE A SKOOL
				*/
	
				/*
				element ={
						name:"benjamin"
						status:{
							internal:0-1-2-3-4-5-6-7-8-...
							external:0-1-2-3-4-5-6-7-8-...
							presence:0-1-2
						}
				}
				*/
				
				// TRANSFERT AU USER CLASS EN COURS ( CLB )
				
				this.elementNum++
				this.mcList.attachMovie("userSlot","line"+this.elementNum,this.elementNum,{backgroundId: 2,iconBackgroundId: 2,userBox: element,dropBox: element,statusDspMode: "all"});
				var mc = this.mcList["line"+this.elementNum];
				mc._x = decal;
				mc._y = this.currentLine*18;
				mc.setUser(element.name);
		
				element.path = mc;
				element.onPath();
				this.currentLine++;
			}else{
				element.path = undefined;
			}
		}
		
	};

	function onDrop(o){
		for(var i=0;i<this.list.list.length;i++){
			if(this.list.list[i].uid == o.uid) return false;
		}
		var destUid = _global.fileMng.mycontact;
		
		if(o.uid == "new"){
			_global.fileMng.make(o,destUid);
		}else{
			if(Key.isDown(Key.CONTROL)){
				_global.fileMng.copy(o.uid,destUid);
			}else{
				_global.fileMng.move(o.uid,destUid);
			}
		}
	}
//{
}


























