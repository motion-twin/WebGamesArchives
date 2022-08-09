
class MainBarTab extends MovieClip{//}

	var tabMenuSpace:Number =	18;
	var tabMenuMargeUp:Number =	8;
	var tabMenuMargeLeft:Number =	4;
	
	var animList:AnimList;
	
	var flMenu:Boolean;
	var flMenuAttach:Boolean;
	var flDead:Boolean;
	var flActive:Boolean;
	
	var slot:Object;
	
	var yScroll:Number;
	var pos:Object;
	var id:Number;
	var num:Number;
	var name:String;
	var followList:Array;
	var bar:MainBar;
	
	var fond:MovieClip;
	var bottom:MovieClip;
	var barre:MovieClip;
	var menuMc:MovieClip;
	
	// VA DISPARAITRE
	var animMoveAndDestroy:Number;
	
	
	/*-----------------------------------------------------------------------
		Function: MainBarTab()
		constructeur
	------------------------------------------------------------------------*/
	function MainBarTab(){
		this.init()
	}

	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/	
	function init(){
	
		this.animList = new AnimList();
		
		this._x = this.id*this.bar.tabSpace;
		this._y = -30
		
		this.flActive =false;
		
		//this.x = this.id*this.bar.tabSpace
		this.yScroll=0;
	
		
		this.name = this.slot.title;
		//this.animList.addAnim("move",setInterval(this,"move",25))
		this.pos = {x:this._x,y:0};
		this.animList.addSlide("slide",this);
		
		this.flMenu = false;
		this.flMenuAttach = false;
		this.flDead = false;
		
		//this.anim = false;
		this.stop();
		
		// CONTOUR
		this.bar.mcTabBlack.attachMovie("tabFond","tab"+this.num, this.bar.dp_tab+(this.bar.tabMax-this.id*2))
		this.fond = this.bar.mcTabBlack["tab"+this.num]
		//_root.test+="fond("+this.fond+")"
		this.fond._x = this._x;
		this.fond._y = this._y;
		this.followList = [this.fond]
		
		
		// BOUTON
		this.bottom.but.tab = this
		this.bottom.but.onRollOver = function (){
			if(this.tab.flMenu){
				this._parent.ico.gotoAndStop(3)
			}else{		
				var menuArr = this.tab.slot.getMenu();
				//_root.test = "> "+menuArr+"\n"
				if(menuArr.length>0){
					this._parent.ico.gotoAndStop(2)
				}			
			}
		}		
		this.bottom.but.onRollOut = function (){
			this.tab.setIcon();
		}
	
		this.bottom.but.onPress = function(){
			/*
			if(!_global.frameMode){
				//_global.slotList.activate(this.slot);

				if(this.tab.flMenu){
					//_root.test+="On ferme !!\n"
					this.tab.animList.addAnim( "scroll", setInterval(this.tab,"scrollUp",25) )
					this.tab.flMenu = false;
				}else{
					var menuArr = this.tab.slot.getMenu();
					if(menuArr.length>0){
						//_root.test+="attach\n"
						this.tab.attachMenu();
						this.tab.animList.addAnim( "scroll", setInterval(this.tab,"scrollDown",25))
						this.tab.flMenu = true;
					}
				}
			}else{
				//_root.test+="this.slot("+this.tab.slot+")\n"
				_global.slotList.activate(this.tab.slot);
			}
			//*/
			//*
			//_root.test+=_global.frameMode+"\n"
			if(this.tab.flMenu){
				//_root.test+="On ferme !!\n"
				this.tab.animList.addAnim( "scroll", setInterval(this.tab,"scrollUp",25) )
				this.tab.flMenu = false;
			}else{
				if(_global.frameMode){
					
					//_global.slotList.activate(this.tab.slot);
					_global.slotList.activate(_global.desktop)
					//_global.slotList.activate(_global.desktop)
					//this.tab.flActive = false;
				}
				var menuArr = this.tab.slot.getMenu();
				if(menuArr.length>0){
					//_root.test+="attach\n"
					this.tab.attachMenu();
					this.tab.animList.addAnim( "scroll", setInterval(this.tab,"scrollDown",25))
					this.tab.flMenu = true;
				}				



				
			}
			//*/
			this.tab.setIcon();
		}
		// ICON
		this.setIcon();

		
	}
	
	/*-----------------------------------------------------------------------
		Function: moveAndDestroy()
	------------------------------------------------------------------------*/
	function moveAndDestroy(){
		var c = Math.pow(0.8,_global.tmod);
		this.barre._y = this.barre._y*c + (-this.bottom._height)*(1-c)
		this.bottom._y = this.barre._y
		if(this.flMenuAttach){
			this.menuMc._y = this.barre._y
		}
		
		if(this.barre._y-3<-this.bottom._height){
			this._visible=false;
			this.fond._visible=false;
		}
		if(Math.round(this.barre._y)==Math.round(-this.bottom._height)){
			clearInterval(this.animMoveAndDestroy);
			this.fond.removeMovieClip()
			this.removeMovieClip();
		}
		this.updateFond()
	}
	
	/*-----------------------------------------------------------------------
		Function: attachMenu()
	------------------------------------------------------------------------*/
	function attachMenu(){
		
		this.flMenuAttach = true;
		var menuArr = this.slot.getMenu();
		this.createEmptyMovieClip("menuMc",1);
		this.barre._height = this.tabMenuMargeUp+(menuArr.length*this.tabMenuSpace);
		this.menuMc._y = this.barre._y;

		for(var i=0; i<menuArr.length; i++){
			var o = menuArr[i];
			
			var close = {
				obj:this,
				method:"deactivate"
			}
			o.action.onRelease.push(close)
			
			
			var initObj = {
				width:100,
				height:this.tabMenuSpace,
				text:o.title,
				textFormat:{bold:true},
				buttonAction:o.action
			}
			//_root.test+="- o.action"+o.action+"\n"
			this.menuMc.attachMovie( "butText", "btext"+i, i, initObj );
			var mc = this.menuMc["btext"+i];
			mc._x = this.tabMenuMargeLeft;
			mc._y = -( i*this.tabMenuSpace + 16);
			
			
			
			/*
			for(var a=0; a<o.action.length; a++){
				//_root.test+="- mc"+mc.setAction+"\n"
				//_root.test+="- mc.setAction"+mc.setAction+"\n"
				var action = o.action[a]
				mc.setAction(action.event, action.obj, action.method);
			}
			*/
		}
	}
	
	/*-----------------------------------------------------------------------
		Function: scrollMenu()
	------------------------------------------------------------------------*/
	function scrollMenu(){
		var coef=Math.pow(0.8,_global.tmod)
		this.barre._height =  this.barre._height*coef + this.yScroll*(1-coef);
		this.bottom._y = this.barre._height;
		this.menuMc._y = this.barre._height+this.menuMc.baseY
		
		if(Math.round(this.barre._height)==this.yScroll){
			this.animList.remove("moveMenu")
		}	
	}
	
	/*-----------------------------------------------------------------------
		Function: removeMenu()
	------------------------------------------------------------------------*/
	function removeMenu(){
		this.flMenuAttach = false;
		this.menuMc.removeMovieClip();
	}
	
	/*-----------------------------------------------------------------------
		Function: setIcon()
	------------------------------------------------------------------------*/
	function setIcon(){
		this.bottom.ico.gotoAndStop(1);
		this.bottom.ico.ico.stop();	// DEFAUT
		//_root.test+="this.slot:\n"
		/*
		for(var elem in this.slot){
			_root.test+=" - "+elem+" = "+this.slot[elem]+"\n"
		}
		*/
		//_root.test+="this.slot.getIconLabel() ["+this.slot.getIconLabel()+"]\n"
		this.bottom.ico.ico.gotoAndStop(this.slot.getIconLabel());
	}
	
	/*-----------------------------------------------------------------------
		Function: scrollDown()
	------------------------------------------------------------------------*/
	function scrollDown(){
		var coef=Math.pow(0.8,_global.tmod)
		this.barre._y = this.barre._y*coef + this.barre._height*(1-coef)
		this.bottom._y = this.barre._y
		if(this.flMenuAttach){
			this.menuMc._y = this.barre._y
		}
		if(Math.round(this.barre._height)==this.barre._y){
			this.animList.remove("scroll")
		}
		this.updateFond();
	}
	
	/*-----------------------------------------------------------------------
		Function: scrollDown()
	------------------------------------------------------------------------*/
	function scrollUp(){
		//_root.test+="scroll_Up\n"
		var coef=Math.pow(0.8,_global.tmod)
		var objectif = this.flActive*4
		this.barre._y = this.barre._y*coef + objectif*(1-coef)
		this.bottom._y = this.barre._y
		if(this.flMenuAttach){
			this.menuMc._y = this.barre._y//this.barre._height+this.menuMc.baseY
		}
		if(this.flMenuAttach){
			this.menuMc._y = this.barre._y//this.barre._height+this.menuMc.baseY
		}		
		if(Math.round(this.barre._y)==objectif){
			//_root.test+="tryToRemove\n"
			this.animList.remove("scroll")
			this.barre._height = objectif
			if(this.flMenuAttach)this.removeMenu();	
		}
		this.updateFond();
	}	

	/*-----------------------------------------------------------------------
		Function: activate()
	------------------------------------------------------------------------*/
	function activate(){
		//_root.test+="youhyouhy\n"
		this.flActive=true;
		this.barre._height = Math.max(4,this.barre._height)
		this.animList.addAnim("scroll",setInterval(this,"scrollDown",25))
	}
	
	/*-----------------------------------------------------------------------
		Function: deactivate()
	------------------------------------------------------------------------*/
	function deactivate(){
		if(!this.flDead){
			this.flActive=false;
			this.flMenu=false;
			this.animList.addAnim("scroll",setInterval(this,"scrollUp",25))
		}
	};
	
	/*-----------------------------------------------------------------------
		Function: updateFond()
	------------------------------------------------------------------------*/
	function updateFond(){
		this.fond.fondH._height = this.barre._height;
		this.fond.fondH._y = this.barre._y;
		this.fond.fondB._y = this.bottom._y;
		this.fond._y = this._y;
	};
	
	/*-----------------------------------------------------------------------
		Function: setTitle(title)
	------------------------------------------------------------------------*/
	function setTitle(title){
		this.name = title;
	}	
	
	function warning(){
		this.animList.addColorFlash("warning",this,{color: 0xFFABAB,alpha: 30,tempo: 500});
	}
	
	function stopWarning(){
		this.animList.remove("warning");
		FEMC.killColor(this);
	}
	
//{
}



