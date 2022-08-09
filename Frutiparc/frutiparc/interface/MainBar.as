/* IDEES

- Statut de connexion 
- se deconnecter, reconnecter
- determination des attitudes
- ScrollText
- Jour nuit
- Heure
- trou noir


- mini-lien	-> forum
		-> boite au lettre
		->

*/

class MainBar extends MovieClip{//MovieClip{//}

	// CONSTANTE
	var hideHeight:Number =	220
	//var dp_butSearch =	41;
	//var dp_searchField = 	40;
	
	var dp_digit =		44;
	var dp_hole =		50;
	var dp_frameSet = 	200;	var dp_frameSetMax = 800;
	var dp_tab = 		10000;

	var tabMax:Number =	500;
	var infoMax:Number =	8;
	var tabSpace:Number =	110;
	
	var height:Number = 	76;
	var minWidth:Number = 	600;
	var margin  =		6;
	/*
	var baseWdth:Number =	300;
	var endWdth:Number =	199;
	var holeWdth:Number =	32
	*/
			
	// VARIABLES
	var dp_frameSetList:DepthList;
	var flHalfHide:Boolean;
	var tabNum:Number;
	var style:Object;
	var emoteIconList:Array;
	var sideIconList:Array;
	var tabList:Array;
	var frameSet:Frame;
	var animList:AnimList;
	var pos:Object;
	var regular:Object;
	var maxTab:Number;
	
	//var flSearch:Boolean;
	var flGreenHole:Boolean;
	var flBlackHole:Boolean;
	
	// MOVIE CLIPS
	var mcInterface:MovieClip;
	var mcInterfaceBlack:MovieClip;
	var mcTab:MovieClip;
	var mcTabBlack:MovieClip;
	var mcEmoteIconList:MovieClip;
	var mcSideIconList:MovieClip;
	
	var screen:MovieClip;
	var digit:bar.Digital;
	
	var pa:MovieClip;
	var pb:MovieClip;
	var pc:MovieClip;
	
	var fondM:MovieClip;
	var fondD:MovieClip;
	
	var hole1:MovieClip;
	var hole2:MovieClip;
	
	var testRetour:MovieClip;

	function MainBar(){
		this.init();
	}	
	
	function init(){
		//_root.test+="MainBar init\n"
		this.style = Standard.getWinStyle();
		this.dp_frameSetList = new DepthList(this.dp_frameSetMax);
		
		this.tabList = new Array();
		this.tabNum = 0;
		_global.main.cornerY = 106;
		this.tabNum = 0;
		this.flHalfHide=false;
		this.flBlackHole=false;
		this.flGreenHole=false;
		this.pos={x:0,y:0};
		this.animList = new AnimList();
		
		this.initEmoteIconList()
		this.initSideIconList()

		this.initInterface()
		this.initFrameSet();


	}
	
	function initEmoteIconList(){
		this.emoteIconList = new Array();
		for(var i=0; i<7; i++){
			var o = {
				link:"butPush",
				param:{
					link:"butPushEmoteIcon",
					frame:1+i,
					outline:2,
					curve:8,
					buttonAction:{ 
						onPress:[{
							obj:_global.me.status,
							method:"setEmote",
							args:i
						}]
					}
				}
			}
			this.emoteIconList.push(o)
		}
		/*
		var o = {
			link:"butPush",
			param:{
				link:"butPushEmoteIcon",
				frame:1+i,
				outline:2,
				curve:8,
				buttonAction:{ 
					onPress:[{
						obj:_global.me.status,
						method:"setEmote",
						args:i
					}]
				}
			}
		}		
		
		this.emoteIconList.push()
		*/
		
		
	}

	function initSideIconList(){
		this.sideIconList = [
			{
				link:"butPush",
				param:{
					link:"butPushVerySmallPink",
					frame:1,
					outline:2,
					curve:3,
					buttonAction:{ 
						onPress:[{
							obj:this,
							method:"toggleHalfHide"
						}]
					}
				}
			},
			{
				link:"butPush",
				param:{
					link:"butPushVerySmallPink",
					frame:1,
					outline:2,
					curve:3,
					buttonAction:{ 
						onPress:[{
							obj:this,
							method:"toggleFullScreen"
						}]
					}
				}
			},
			{
				link:"butPush",
				param:{
					link:"butPushVerySmallPink",
					frame:1,
					outline:2,
					curve:3,
					buttonAction:{ 
						onPress:[{
							obj:this,
							method:"toggleHalfHide"
						}]
					}
				}
			}			
		]
	}
		
	function initInterface(){
		this.createEmptyMovieClip("mcInterface",10)
		this.createEmptyMovieClip("mcTab",8)
		this.createEmptyMovieClip("mcTabBlack",4)
		this.createEmptyMovieClip("mcInterfaceBlack",2)
		this.mcTab._y = this.height
		this.mcTabBlack._y = this.height
		
		//this.drawInterface()
	}
	
	function drawInterface(w){

		this.mcInterfaceBlack.clear();
		this.mcInterface.clear();
		
		var out = 2
		var i = 2
		var c = 10
		var col = this.style.global.color[0]
		
		var pos = {
			x:-c,
			y:-c,
			w:w+c,
			h:this.height+c
		}
		
		FEMC.drawSmoothSquare(	this.mcInterfaceBlack, 	{x:pos.x-out,	y:pos.y-out,	w:pos.w+out*2,	h:pos.h+out*2	},col.darkest,	c+out 	);
		FEMC.drawSmoothSquare(	this.mcInterface,	{x:pos.x,	y:pos.y,	w:pos.w,	h:pos.h		},col.shade,	c	);
		FEMC.drawSmoothSquare(	this.mcInterface,	{x:pos.x+i,	y:pos.y+i,	w:pos.w-i*2,	h:pos.h-i*2	},col.main,	c-i	);		

	}
	
	function initFrameSet(){
		var h = this.height-this.margin*2
		var marginInt = Standard.getMargin();
		marginInt.y.min = this.margin*2;
		marginInt.x.min = this.margin*2;
		var frame = {
			name:"frameSet",
			type:"h",
			root:this,
			marginInt:marginInt,
			win:this
		}
		this.frameSet = new Frame(frame)
		
		// SCREEN
		var args = {
			fix:{w:h,h:h},
			mainStyleName:"frSystem"
		}
		var frame = {
			type:"compo",
			name:"screen",
			link:"FrutiScreen",
			min:{w:h,h:h},
			win:this,
			args:args
		};
		this.screen = this.frameSet.newElement(frame);
		
		/*// SIDEICON
		var margin = Standard.getMargin()
		margin.x.min = 2
		margin.x.ratio = 1
		
		var struct = Standard.getStruct();
		struct.x.size = 19;
		struct.y.space = 2;
		struct.y.size = 19;
							
		var args = {
			//flMarker:true,
			list:this.sideIconList,
			struct:struct,
			flMask:true,
			mask:{flScrollable:false}
		};
		
		var frame = {
			name:"sideIcon",
			link:"basicIconList",
			type:"compo",
			min:{w:20,h:h},
			margin:margin,
			//flBackground:true,
			args:args
		}
		
		this.mcSideIconList = this.frameSet.newElement(frame);		
		//*/
		
		// INFO
		var margin = Standard.getMargin()
		margin.x.min = 3
		margin.x.ratio = 1
		var frame = { 
			name:"info",	
			type:"w",
			min:{w:150,h:h},
			root:this,
			win:this,
			margin:margin
		}
		this.frameSet.newElement(frame)
		
			// DIGITAL
			var margin = Standard.getMargin()
			margin.y.min = -2
			var frame = {
				type:"compo",
				name:"digital",
				link:"cpDigital",
				min:{w:130,h:45},
				margin:margin,
				win:this
			};
			this.frameSet.info.newElement(frame);
			
			// EMOTEICONLIST
			var struct = Standard.getSmallStruct();
			struct.x.margin = 2;
			struct.x.size = 19;
			struct.y.margin = 2;
			struct.y.size = 19;
			struct.x.align = "start"
			struct.y.align = "start"
								
			var args = {
				//flMarker:true,
				list:this.emoteIconList,
				struct:struct,
				flMask:true,
				mask:{flScrollable:false}
			};
			
			var frame = {
				name:"emote",
				link:"basicIconList",
				type:"compo",
				min:{w:20,h:24},
				args:args
			}
			this.mcEmoteIconList = this.frameSet.info.newElement( frame );
			this.frameSet.info.bigFrame = this.frameSet.info.emote;
			
		// BIG SPACE
		var frame = { 
			name:"tile",	
			type:"w",
			min:{w:100,h:h},
			root:this,
			win:this
		}
		this.frameSet.newElement(frame)			
		this.frameSet.bigFrame = this.frameSet.tile		
			
		// SCREEN
		var args = {
			bar:this
		}
		var frame = {
			type:"compo",
			name:"screen",
			link:"cpWheelMng",
			win:this,
			args:args
		};
		this.frameSet.newElement(frame);		
		
		
		/*
		this.frameSet.newElement(		{ name:"top",		type:"w",	min:{w:0,h:6}			})
		this.frameSet.newElement(		{ name:"center",	type:"h"					})
		this.frameSet.newElement(		{ name:"bottom",	type:"w", 	min:{w:0,h:6}			})
		
		this.frameSet.center.newElement(	{ name:"left",		type:"w", 	min:{w:6,h:0}			})
		this.frameSet.center.newElement(	{ name:"center",	type:"w"					})
		this.frameSet.center.newElement(	{ name:"right",		type:"w", 	min:{w:6,h:0}			})
		
		this.frameSet.bigFrame = 	this.frameSet.center;
		this.frameSet.center.bigFrame = this.frameSet.center.center;
		
		this.margin.left =		this.frameSet.center.left;
		this.margin.right =		this.frameSet.center.right;
		this.margin.top =		this.frameSet.top;
		this.margin.bottom =		this.frameSet.bottom;
		
		this.main = 			this.frameSet.center.center
		
		this.frameSet.pos.x = 0;
		this.frameSet.pos.y = 0;
		*/
		this.frameSet.pos.x = 0;
		this.frameSet.pos.y = 0;		
	}
	
	function update(){
		this.pos.x = _global.main.cornerX;
		this._x = this.pos.x;
		var w = Stage.width-(_global.main.cornerX+_global.main.frusion.width+_global.main.frusion.margin)
		w = Math.max(w,this.minWidth)
		this.maxTab = Math.floor(w/this.tabSpace)
		this.drawInterface(w)
		this.frameSet.pos.w = w;
		this.frameSet.pos.h = this.height;
		this.frameSet.update();
		
	}
	
	function tabListIsTooFull(mod){
		//_root.test+="-------------------------------------"+this.maxTab+" n("+n+") mod("+mod+")\n"
		//_root.test+="-------------------------------------"+this.tabList.length+"\n"
		var n = this.tabList.length+mod
		return n>this.maxTab;
	}
	
	/*
	function initWheel(){
		//_root.test+="mainBar: initWheel\n"
		this.pc.attachMovie("wheelMng","wheelMng",1)
		_global.wheelMng = this.pc.wheelMng;
	
	}
	
	function initDigital(){
		this.attachMovie("barDigital","digit",this.dp_digit)
		this.digit._x = 70
		this.digit._y = 6
	}
		
	function onResize(x){
		
		//_root.test+="mainBar : onResize("+x+")\n"
		
		this._x =_global.main.cornerX
	
		this.pb._x = this.baseWdth;
		this.pb._width = x - (this.baseWdth + this.endWdth);
		this.pc._x = this.baseWdth+this.pb._width;

		this.fondM._width = this.pb._width;
		this.fondD._x = this.pc._x;

		if(this.pb._width > this.holeWdth){
			if(!this.flGreenHole){
				this.attachHole(1);
				this.flGreenHole=true;
			}
		}else{
			if(this.flGreenHole){
				this.detachHole(1);
				this.flGreenHole=false;
			}		
		}
		
		if(this.pb._width > this.holeWdth*2){
			if(!this.flBlackHole){
				this.attachHole(2);
				this.flBlackHole=true;
			}
		}else{
			if(this.flBlackHole){
				this.detachHole(2);
				this.flBlackHole=false;
			}		
		}		
		
		if(this.flGreenHole){
			this.hole1._x = this.pc._x - this.holeWdth
		}
		if(this.flBlackHole){
			this.hole2._x = this.pc._x - this.holeWdth
		}		

				
	}

	function attachHole(id){
		//_root.test+="attachHole("+id+")\n"
		var param = {
			id:id,
			doorNb:5,
			size:this.holeWdth
		};
		this.attachMovie("hole","hole"+id,this.dp_hole+id,param);
		var mc = this["hole"+id];
		mc._x = (this.baseWdth+this.pb._width)//-(2-id)*this.holeWdth;
		mc._y = 5+(id-1)*(this.holeWdth+2);
	}
	
	function detachHole(id){
		//_root.test+="detachHole("+id+")\n";
		this["hole"+id].kill();
	}	
	*/
	
	// TAB
	function addTab(o){
		this.tabNum++
		var id = this.tabList.length
		this.mcTab.attachMovie("tab","tab"+this.tabNum, this.dp_tab+(this.tabMax-id*2),{bar:this,slot:o,id:id,num:tabNum} )
		var mc = this.mcTab["tab"+this.tabNum]
		this.tabList.push(mc)
		return mc;
	};
	
	function removeTab(o){
		var tab = null
		for(var i=0; i<this.tabList.length; i++){
			if(this.tabList[i].slot==o){
				tab = this.tabList[i];
				break;
			}
		}
		if(tab==null)return false;
		var d = tab.getDepth()+1;
		tab.swapDepths(d);
		tab.fond.swapDepths(d);
		tab.animList.removeAll();
		tab.flDead = true;
		tab.animMoveAndDestroy = setInterval(tab,"moveAndDestroy",25);
	
		var id = tab.id;
		this.tabList.splice(id,1);
	
		for(var i=id; i<this.tabList.length; i++){
			var mc = this.tabList[i];
			mc.id--;
			var d = this.dp_tab+(this.tabMax-mc.id*2);
			mc.swapDepths(d);
			mc.fond.swapDepths(d);
			mc.pos.x = mc.id*this.tabSpace;
			mc.animList.addSlide("move",mc);
		}
	}
	
	function tabRelease(mc){
		//_root.test+="mc.slot("+mc.slot+")\n"
		_global.slotList.activate(mc.slot);
	}
	
	// HALFHIDE
	function toggleHalfHide(forceFlag){
		if(forceFlag!=undefined){
			this.flHalfHide = forceFlag;
		}else{
			this.flHalfHide = !this.flHalfHide
		}
		if(this.flHalfHide){
			//this._visible = false;
			this.pos.y = -this.hideHeight
			_global.main.frusion.jumpTo(-this.hideHeight)
			this.attachMovie("testRetour","testRetour",1328)
			this.testRetour._visible = false;
			this.testRetour.onPress = function (){
				this._parent.toggleHalfHide();
			}
			this.testRetour._y =this.hideHeight;
			
		}else{
			this.testRetour.removeMovieClip()
			this.pos.y = 0
			_global.main.frusion.jumpTo(0)	
			
		}
		this.animList.addSlide("barSlide",this,{obj:this,method:"endMove"},2)

		_global.main.cornerY = 10+ 96*!this.flHalfHide;
		_global.main.onResize();	
	}
	function endMove(){
		this.testRetour._visible = true;
	}
	
	
//{
}












