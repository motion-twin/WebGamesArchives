/*----------------------------------------------

		FRUTIPARC 2 FRUSION

----------------------------------------------*/

class Frusion extends MovieClip{//}

    var _step : Number;
    var _id : Number;

	var width:Number;
	var margin:Number;
		
	var flOpen:Boolean;
	var flDisc:Boolean
	var flRotating:Boolean;
	var flRunning:Boolean;
	
	var iconInfo:Object;
	
	var discDestiny:String;
	
	var animList:AnimList;
	var pos:Object;

	//MOVIECLIP
	var slot:MovieClip;
	var fondSlot:MovieClip;
	//

	/*-----------------------------------------------------------------------
		Function: Frusion()
		constructeur
	------------------------------------------------------------------------*/	
	function Frusion(){
		this.init()
        _step = 0;
	}

	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/	
	function init(){
		this.pos = {x:0,y:0};
		//_root.test+="frusionInit\n"
		this.width = 116;
		this.margin = 16;
		
		this.slot._y = 71
		
		this.flOpen = false
		this.flDisc = false;
		this.flRotating = false;
		this.flRunning = false;
		
		this.animList = new AnimList();
		
		this.slot.dropBox = this;		
		
		_global.dragListener.addListener("disc",{obj: this,startMethod: "onStartDragDisc",stopMethod: "onEndDragDisc"});
	}
	
	/*-----------------------------------------------------------------------
		Function: openSlot()
	------------------------------------------------------------------------*/	
	function openSlot(){
		this.animList.addAnim("moveSlot",setInterval(this,"moveSlot",25,140))
		this.flOpen=true;
	};

	/*-----------------------------------------------------------------------
		Function: closeSlot()
	------------------------------------------------------------------------*/	
	function closeSlot(){
		this.animList.addAnim("moveSlot",setInterval(this,"moveSlot",25,71))
		this.flOpen=false;
	};
	
	/*-----------------------------------------------------------------------
		Function: moveSlot(y)
	------------------------------------------------------------------------*/	
	function moveSlot(y){
		var c = Math.pow(0.8,_global.tmod);
		this.slot._y = this.slot._y*c + y*(1-c)
		this.fondSlot._y = this.slot._y
		if(Math.round(this.slot._y)==Math.round(y)){
			this.slot._y=y;
			this.animList.remove("moveSlot")
			if(y==71 and this.flDisc){
				this.runDisc();
			}
		}	
	};
	
	/*-----------------------------------------------------------------------
		Function: runDisc()
	------------------------------------------------------------------------*/	
	function runDisc(){
		//_root.test+="runDisk\n"
		this.animList.addAnim("rotateDisc",setInterval(this,"rotateDisc",25,1))
		this.flRotating=true;
	}

	/*-----------------------------------------------------------------------
		Function: stopDisc()
	------------------------------------------------------------------------*/	
	function stopDisc(endMethod){
		_root.test+="stopDisc("+endMethod+")\n"
		var mc = this.slot.disc.ico.disc
		mc.label.gfx.gotoAndStop(1);
		this.animList.addAnim("rotateDisc",setInterval(this,"rotateDisc",25,-2))
		this.flRunning=false;
		this.discDestiny=endMethod;
	}


	/*-----------------------------------------------------------------------
		a cheater was found! hang the frusion ! ;)
        SO LET'S HAVE FUN WITH THE CHEATER MANAGEMENT !!
	------------------------------------------------------------------------*/	
    function breakFrusion()
    {
		this.animList.addAnim("hangFrusion",setInterval(this,"hangFrusion",25))
    }


	function hangFrusion()
    {
        _xscale = 100 + Math.cos( _step );
        _yscale = 100 + Math.sin( _step );          
        _step += ((Random(2)/10) + 0.4 )* _global.tmod;

        //_id = setInterval( this, "_breakEverything", 2000 );
	}

    function _breakEverything()
    {
        _root._xscale = 100 + Math.cos( _step );
        _root._yscale = 100 + Math.sin( _step );          
        _step += ((Random(2)/10) + 0.2 )* _global.tmod;

        setInterval( this, "_setShadowOnFrutiparc", 2000 );
        setInterval( this, "_setRedOnFrutiparc", 3000 );
        _randomErrorMessage();
    }

    function _setRedOnFrutiparc()
    {
        // change colors ;)
        var myColor = new Color ( _root );
        var amount = 20;
        var r=255;
        var g=0;
        var b=0;
        var trans = new Object();
        trans.ra = trans.ga = trans.ba = 100 - amount;
        var ratio = amount / 100;
        trans.rb = r * ratio;
        trans.gb = g * ratio;
        trans.bb = b * ratio;
        myColor.setTransform(trans); 
    }

    function _setShadowOnFrutiparc()
    {
        // change colors ;)
        var myColor = new Color ( _root );
        var amount = 20;
        var r=0;
        var g=0;
        var b=0;
        var trans = new Object();
        trans.ra = trans.ga = trans.ba = 100 - amount;
        var ratio = amount / 100;
        trans.rb = r * ratio;
        trans.gb = g * ratio;
        trans.bb = b * ratio;
        myColor.setTransform(trans); 
    }


    function _randomErrorMessage()
    {
        clearInterval( _id );
        //_global.openErrorAlert( "WARNING !")
        _global.openErrorAlert( "Frutiparc Failure !")
        _id = setInterval( this, "_closeFrutiparc", 2000 );
    }


    function _closeFrutiparc()
    {
        clearInterval( _id );
        getURL( "javascript:self.close()", "_self" );
    }


	/*-----------------------------------------------------------------------
		Function: rotateDisc(sens)
	------------------------------------------------------------------------*/	
	function rotateDisc(sens){
		//_root.test+="rotateDisc("+sens+")\n"
		var mc = this.slot.disc.ico.disc
		if(mc.speed == undefined) mc.speed = 0;
		mc.speed+=_global.tmod*sens
		mc._rotation-=mc.speed
		if(sens>0 and mc.speed>140){
			//_root.test+="removeAnim(1)\n"
			this.animList.remove("rotateDisc");
			mc.label.gfx.gotoAndPlay(2)
		}
		//if(sens==-1)_root.test+="mc.speed("+mc.speed+")\n"
		if(sens<0 and mc.speed<0){
			//_root.test+="removeAnim(-1)\n"
			this.animList.remove("rotateDisc");
			this.flRotating=false;
			if(this.discDestiny!=undefined)this[this.discDestiny]();
		}	
	}
	
	/*-----------------------------------------------------------------------
		Function: onStartDragDisc()
	------------------------------------------------------------------------*/	
	function onStartDragDisc(){
		if(!this.flDisc and !this.flOpen){
			this.openSlot();
		}
	}

	/*-----------------------------------------------------------------------
		Function: onEndDragDisc()
	------------------------------------------------------------------------*/	
	function onEndDragDisc(){
		if(!this.flDisc and this.flOpen){
			this.closeSlot();
		}
	}

	/*-----------------------------------------------------------------------
		Function: onDrop(o)
	------------------------------------------------------------------------*/	
	function onDrop(o){
		if(o.type=="disc" and !this.flDisc and this.flOpen){
			//_root.test+="dropDisc("+o+")\n"
			this.flDisc=true;
			var initObj = {type:o.type, desc:o.desc, uid:o.uid, parent: o.parent, date: o.date, access: o.acces, size: o.size, name: o.name};
			this.iconInfo = initObj;
			initObj.flButton = false;
			this.slot.attachMovie("fileIconFull","disc",1, initObj);
			// On vire tout de suite le flButton, pour le pas contaminer tout le monde !
			delete initObj.flButton;
			this.slot.disc._x=-31 //-37;	//-30
			this.slot.disc._y=-63;
			this.closeSlot();
			_global.frusionMng.launchDisc(o.uid);
			_global.fileMng.frusionOn(this.iconInfo);
			//_global.topDesktop.disable();
			
		}
	}
	
	/*-----------------------------------------------------------------------
		Function: removeDisc()
	------------------------------------------------------------------------*/	
	function removeDisc(){
		this.flDisc=false;
		this.slot.disc.removeMovieClip("");
	}
	
	/*-----------------------------------------------------------------------
		Function: burstDisc()
	------------------------------------------------------------------------*/
	function burstDisc(){
		_global.fileMng.frusionOff();
		//_global.topDesktop.enable();
		
		//_root.test+="burstDisc\n"
		this.animList.addAnim("fadeDisc",setInterval(this,"fadeDisc",25,this.slot.disc))	// ici
		//this.removeDisc();
	}
	
	/*-----------------------------------------------------------------------
		Function: ReleaseDisc()
	------------------------------------------------------------------------*/
	function releaseDisc(){
		_global.fileMng.frusionOff();	
		//_global.topDesktop.enable();
		
		this.openSlot();
		this.slot.disc.frusion = this; //this.slot.disc.ico.disc.label.gfx.frusion = this;
		// je suis pas trops sur de ca :
		this.slot.disc.onPress = function(){
			this.frusion.takeDisc();
		}
		
	}
	
	/*-----------------------------------------------------------------------
		Function: takeDisc()
	------------------------------------------------------------------------*/	
	function takeDisc(){
		//_root.test+="takeDisc("+this.iconInfo+")\n"
		this.removeDisc();		
		//this.closeSlot();
		
		this.iconInfo.comeFromFrusion = true;
		_global.createDragIcon( this.iconInfo )
		this.iconInfo = undefined;
	}
	
	/*-----------------------------------------------------------------------
		Function: fadeDisc()
	------------------------------------------------------------------------*/	
	function fadeDisc(mc){
		mc._alpha -= _global.tmod
		if(mc._alpha<5){
			this.animList.remove("fadeDisc")
			this.removeDisc();
		}
	}
	
	/*-----------------------------------------------------------------------
		Function: forceCloseSlot()
			To call when the slot MUST be closed
	------------------------------------------------------------------------*/	
	function forceCloseSlot(){
		if(this.flOpen){
			if(this.flDisc){
				_global.fileMng.frusionDiscStopDrag();
				this.removeDisc();
			}
			
			this.closeSlot();
		}
	}
	
	function pushReset(){
		_root.test+="[Frusion] pushReset()\n"
		_global.frusionMng.reset()
	};
	
	function pushEject(){
		_root.test+="[Frusion] pushEject()\n"
		_global.frusionMng.eject()
	};	
	
	function jumpTo(y){
		this.pos.y = y;
		//_root.test+="("+pos.x+")\n"
		this.animList.addSlide("jump",this)
	}
	
//{
}


