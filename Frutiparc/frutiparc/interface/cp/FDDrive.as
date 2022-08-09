class cp.FDDrive extends Component{
	

	var flOpen:Boolean;
	var flDisc:Boolean
	var flRotating:Boolean;
	var flRunning:Boolean;
	
	var animList:AnimList;
	
	var slot:MovieClip;
	var doorA:MovieClip;
	var doorB:MovieClip;
	
	/*-----------------------------------------------------------------------
		Function: FDDrive()
	------------------------------------------------------------------------*/		
	function FDDrive(){
		this.init();
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/	
	function init(){
		
		//_root.test+="FDDriveInit\n"
		
		super.init();
		
		this.width = 72;
		this.height = 72;

		
		this.flOpen = false
		this.flDisc = false;
		this.flRotating = false;
		this.flRunning = false;
		
		this.animList = new AnimList();
		
		// A remplacer par un setColor nouvelle generation;
		this.animList.addPaint("colorSlot",this.slot,{r:0,g:0,b:0},50)
		
		this.slot.dropBox = this;
				
	}
	
	/*-----------------------------------------------------------------------
		Function: openSlot()
	------------------------------------------------------------------------*/	
	function openSlot(){
		//this.animList.addAnim("moveSlot",setInterval(this,"moveSlot",25,140))
		this.doorA.pos = {x:11,y:0}
		this.doorB.pos = {x:61,y:0}
		this.animList.addSlide("moveDoorA",this.doorA)
		this.animList.addSlide("moveDoorB",this.doorB)
		this.animList.addPaint("colorSlot",this.slot,{r:0,g:0,b:0},0)
		this.flOpen=true;
	};

	/*-----------------------------------------------------------------------
		Function: closeSlot()
	------------------------------------------------------------------------*/	
	function closeSlot(){
		this.doorA.pos = {x:36,y:0}
		this.doorB.pos = {x:36,y:0}
		this.animList.addSlide("moveDoorA",this.doorA)
		this.animList.addSlide("moveDoorB",this.doorB)
		this.animList.addPaint("colorSlot",this.slot,{r:0,g:0,b:0},50)
		this.flOpen=false;
	};
	
	/*-----------------------------------------------------------------------
		Function: moveSlot(y)
	------------------------------------------------------------------------*/	
	
	/*-----------------------------------------------------------------------
		Function: runDisc()
	------------------------------------------------------------------------*/	
	function runDisc(){
		this.animList.addAnim("rotateDisc",setInterval(this,"rotateDisc",25,1))
		this.flRotating=true;
	}

	/*-----------------------------------------------------------------------
		Function: stopDisc()
	------------------------------------------------------------------------*/	
	function stopDisc(){
		this.animList.addAnim("rotateDisc",setInterval(this,"rotateDisc",25,-2))
		this.flRunning=false;
	}

	/*-----------------------------------------------------------------------
		Function: rotateDisc(sens)
	------------------------------------------------------------------------*/	
	function rotateDisc(sens){
		var mc = this.slot.disc.ico.disc
		if(mc.speed == undefined) mc.speed = 0;
		mc.speed+=_global.tmod*sens
		mc._rotation-=mc.speed
		if(sens==1 and mc.speed>140){
			this.flRunning = true;
			this.animList.remove("rotateDisc");
			mc.label.gfx.gotoAndPlay(2)
		}
		if(sens==-1 and mc.speed<0){
			this.flRotating=false;
			this.animList.remove("rotateDisc");
			mc.label.gfx.gotoAndStop(1)
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
		if(this.flOpen){
			this.closeSlot();
		}
	}

	/*-----------------------------------------------------------------------
		Function: onDrop(o)
	------------------------------------------------------------------------*/	
	function onDrop(o){
		if(o.type=="disc" and !this.flDisc and this.flOpen){
			this.flDisc=true;
			this.slot.attachMovie("fileIconStandard","disc",1,{type:o.type, desc:o.desc, uid:o.uid})
			//this.slot.disc._x=-30;
			//this.slot.disc._y=-63;
			this.closeSlot();
			//_global.frusionMng.launchDisc(o.uid);
		}
	}
	
	/*-----------------------------------------------------------------------
		Function: removeDisc()
	------------------------------------------------------------------------*/	
	function removeDisc(){
		this.flDisc=true;
		this.slot.disc.removeClip("");
	}
	
	
	
}