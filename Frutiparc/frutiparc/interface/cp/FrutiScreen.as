/*----------------------------------------------

		FRUTIPARC 2 FRUTISCREEN



----------------------------------------------*/

// ma bouille 0a0602000000020000

class cp.FrutiScreen extends Component{//}
	
	//var mainStyle:String;
	var last:MovieClip;
	var flCLB:Boolean;
	var current:String;
	var contentList:Array;
	var contentDepth:Number;
	var supContentDepth:Number;
	var maxContent:Number;
	var minSide:Number;
	var animList:AnimList;
	//var ratio:Object;
	
	function FrutiScreen(){
		this.init();	
	}
	
	function init(){
		//_root.test+="[FrutiScreen] init()\n"
		//if(this.mainStyle==undefined)this.mainStyle = "content";
		super.init()
		//this.ratio={ x:1, y:1 };
		if(this.mainStyleName==undefined)this.mainStyleName="frSystem";
		if(this.maxContent==undefined)this.maxContent=3;
		this.initScreen();
		if(this.fix != undefined){
			this.width = this.fix.w
			this.height = this.fix.h
			this.minSide = Math.max(this.width,this.height)
			this.drawScreen();
		}

		/*
		if(this.flCLB){
			this.win.box.addUserActionListener(this,"onCLBEvent")
		}
		*/

		this.contentDepth = 0;
		this.supContentDepth = 0;
		this.contentList = new Array();
		this.animList = new AnimList();
	}
	
	function updateSize(){
		//_root.test+="[FrutiScreen] updateSize("+this.width+","+this.height+")\n"
		super.updateSize();
		this.minSide = Math.min(this.width,this.height);
		if(this.fix==undefined)this.drawScreen();
	}
	
	function initScreen(){
		this.content.createEmptyMovieClip("screen",10);
		this.content.createEmptyMovieClip("mask",40);
		this.content.createEmptyMovieClip("inside",30);
		this.content.attachMovie("frutiScreenLight","light",50);
		this.content.inside.attachMovie("frutiScreenBackGround","bg",10);
		this.content.inside.bg.stop();
		this.content.inside.setMask(this.content.mask);
		this.content.screen.initDraw();
		this.content.mask.initDraw();
	};
	
	function drawScreen(){
		//_root.test+="[FrutiScreen] drawScreen("+this.width+","+this.height+")\n"
		this.content.screen.clear();
		/*
		var style = Standard.getWinStyle()[this.mainStyle]
		style.inline=1;
		style.color.inline=style.color.overdark;
		style.curve=6;
		*/
		var s = Standard.getWinStyle()[this.mainStyleName]
		var col = s.color[0]
		var col2 = s.color[1]
		var style = {
			outline:2,
			inline:1,
			curve:6,
			color:{
				main:col2.darker,
				inline:col.darker,
				outline:col.shade
			}
		}
		
		
		var pos = {x:0,y:0,w:this.width,h:this.height};
		this.content.screen.drawCustomSquare(pos,style);
		var d = style.inline;
		var pos = {x:d,y:d,w:this.width-(d*2),h:this.height-(d*2)};
		this.content.mask.drawSmoothSquare(pos,0,style.curve);

		this.content.inside.bg._width = this.width;
		this.content.inside.bg._height = this.height;
		
		//this.ratio.x = this.minSide / this.content.inside._xscale;
		//this.ratio.y = this.minSide / this.content.inside._yscale;
		
		//_root.test+="this.ratio.x: "+this.ratio.x+" ; this.ratio.y: "+this.ratio.y+"\n"
	
		this.content.light._x = this.width;
	};
	
	function addContent(link,param,removeId){
		//_root.test+="[FrutiScreen] addContent("+link+","+param+","+removeId+")\n"
		if(removeId==1){
			this.removeAllContent();
		}
		this.contentDepth++;
		//_root.test+="addContent param.flTrace("+param.flTrace+")\n"
		this.content.inside.attachMovie(link,"content"+this.contentDepth,1020+this.contentDepth,param)
		this.last = this.content.inside["content"+this.contentDepth]
		this.last._xscale = this.minSide// * this.ratio.x;
		this.last._yscale = this.minSide// * this.ratio.y;
		
		//_root.test+="scale("+this.last._xscale+","+this.last._yscale+")\n"
		
		
		this.contentList.push(this.last)
		//this.c = this.content.inside.content;
		this.current=link;
	};
	
	function removeContent(index){
		var mc = this.contentList[index];
		mc.removeMovieClip("");
		this.contentList.splice(index,1)
	}
	
	function removeAllContent(){
		while(this.contentList.length>0){
			this.removeContent(0)
		}		
	}
	
	function onStatusObj(o,callback){
		//_global.debug("[FrutiScreen] onStatusObj() o.fbouille("+o.fbouille+")\n")
		
		//if(this.flTrace)_root.test+="coucou!\n"
		
		if(o!=undefined){					// A virer des que de skool me filera plus de o == undefined
			//_root.test+="fbouilleId("+o.fbouille+")\n"
			if(this.current!="frutibouille"){
				
				var initObj = {
					id: o.fbouille,
					loadInitCallback:callback
				}
				
				this.addContent("frutibouille", initObj,1)
				if(o.status.emote != undefined){
					this.last.applyEmote(o.status.emote)
				}
			}else{
				var mc = this.last;
				mc.apply(o.fbouille);
				if(o.status.emote != undefined){
					mc.applyEmote(o.status.emote);
				}
			}
		}else{
			_root.test+="Et mes arguments ? ils sont ou bordel de merde !\n"
		}
	}
	
	function onInfoBasic(o){
		this.onStatusObj(o);
	}	
	
	function onAction(o,index){
		//_root.test+="[FrutiScreen] onAction("+o+","+index+")\n"
		//_global.debug(this+".onAction");
		if(index==undefined){
			var mc = this.last
		}else{
			var mc = this.contentList[index]
		}
		//_root.test+="onAction mc:"+mc+" o.id:"+o.id+" o.length:"+o.length+"  this.flCLB:"+this.flCLB+"\n"
		mc.action(o.id,o.length);
		//mc.time = o.length;
		
		// Indique a la frutibouille de s'autodetruire a la fin de son anim si le screen en mode CLB
		if(this.flCLB){
			mc.actionCallBack = {obj:this, method:"launchIntoTheSpace", args:mc}
		}
		
	}	
	
	function onKill(){
		this.removeContent();
		super.onKill();
	}
	
	function onCLBEvent(user,frutibouille,actObj){
		
		var index;
		
		// Verifie que la bouille n'est pas déjà affichée;
		for(var i=0; i<this.contentList.length; i++){
			var mc = this.contentList[i];
			if(mc.user==user){
				index=i;
				break;
			};
		};
		// Affiche une nouvelle bouille si besoin est;
		if(index==undefined){
			this.addContent("frutibouille",{id :frutibouille});
			this.last.user=user;
			this.last._x = -this.width;
			
			// Essaie de trouver une hauteur un peu dégagée;
			var y;
			var t = 0;
			do{
				t++;
				y = random(this.height-this.minSide);
			}while(this.checkContentCollide(y) and t<20);
			//
			
			this.last._y = y
			index = this.contentList.length-1;
		};
		
				
		var mc = this.contentList[i]
		mc.pos = {x:0,y:mc._y};
		this.animList.addSlide("contentSlide"+mc.user, mc, {} , 1.5 );	// ESSAYER DE CODER LE LANCEMENT DE L'ACTION EN CALLBACK
				
		// Lance l'action
		this.onAction(actObj,index) 					// ESSAYER DE CODER LE LANCEMENT DE L'ACTION EN CALLBACK	
		
		// Enleve les bouilles en trop si besoin
		if(this.contentList.length>this.maxContent){			// C'ETAIT UN WHILE
			this.launchIntoTheSpace(this.contentList[0],0)
		};		
		
	};

	function launchIntoTheSpace(mc,index){
		mc.pos = { x: -this.minSide, y:mc._y };
		this.animList.addSlide("contentSlide"+mc.user, mc, { obj:this, method:"removeCLBContent",args:mc}, 1.5 );
	}
	
	function removeCLBContent(mc){
		this.contentList.splice(getContentIndex(mc),1)
		mc.removeMovieClip("")

	}	

	function getContentIndex(mc){
		for(var i=0; i<this.contentList.length; i++){
			if(mc==this.contentList[i])return i;
		};
		return -1;
	}	
	
	function checkContentCollide(y){
		for(var i=0; i<this.contentList.length; i++){
			var mc = this.contentList[i];
			if(Math.abs(mc._y-y)<this.minSide/2){
				return true;
			}
		};
		return false;
	}
	
	function addSupContent(link,initObj){

		this.supContentDepth++;
		this.content.inside.attachMovie(link,"supContent"+this.supContentDepth,200+this.supContentDepth,initObj)
		var mc = this.content.inside["supContent"+this.supContentDepth]
		//mc._xscale = this.minSide
		//mc._yscale = this.minSide
			
		return mc;
	}
	
	function setAction( callback ){
		this.content.callback = callback
		this.content.onPress = function(){
			this.callback.obj[this.callback.method](this.callback.args);
		}		
	}
	
	function setTip(tipId,tipCb){
		this.content.tipId = tipId;
		this.content.tipCb = tipCb;
		this.content.onRollOver = function(){
			_global.tip.displayCallBack({cb: this.tipCb,id: this.tipId});
		};
		this.content.onDragOver = this.content.onRollOver;
		this.content.onRollOut = function(){
			_global.tip.remove(this.tipId);
		};
		this.content.onDragOut = this.content.onRollOut;
	}
	
	
//{	
}



















