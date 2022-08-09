class win.Login extends WinStandard{//}
	
	var flModule:Boolean = false;
	var center:Object  = {x:181,y:124};
	var eventList:Array;
	var moduleList:Array;
	
	var textField:TextField;
	
	//var butBack:MovieClip;
	var white:MovieClip;
	var grey:MovieClip;
	var black:MovieClip;
	var pleaseWait:MovieClip;
	var textNick;
	var inputName;
	var textPass;
	var inputPass;
	var butValidate;
	var textError;
	var butBack;

	/*-----------------------------------------------------------------------
		Function: Login()
		Constructeur    
	 ------------------------------------------------------------------------*/	
	function Login(){    
		this.init();
	}

	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/
	function init(){
		this.flResizable = false;
		this.flInterface = false;
		super.init();
		
		this.eventList = new Array();
		// position              
		this.minimum = {w:0,h:0};
		this.pos.w = this._width/2-2
		this.pos.h = this._height/2-2
		this.pos.x = (_global.mcw - _global.main.cornerX)/2
		this.pos.y = (_global.mch - _global.main.cornerY)/2

		this.topIconList.splice(0,3);
		
		this.moduleList=[
			{id:0, name:"subscribe",	size:86,	pos:{x:131,	y:-43	},	exist:false	},
			{id:1, name:"demo",		size:56,	pos:{x:121,	y:38	},	exist:false	},
			{id:2, name:"forgetPassword",	size:76,	pos:{x:-136,	y:-3	},	exist:false	}
		];
		this.pleaseWait._visible = false;
			
		this.animList.addAnim("checkEvent",setInterval(this,"checkEvent",2000))	
		this.genLoginScreen()
		this.endInit();
		//this.initDeskTopMode();
		//this.updatePos();

	}
	
	/*-----------------------------------------------------------------------
		Function: genLoginScreen()
	 ------------------------------------------------------------------------*/		
	function genLoginScreen(){
		// text
		var style = new TextInfo();
		
		style.pos = {x: -101,y: -30,w: 80,h: 20};
		style.textFormat.bold = true;
		style.textFormat.align = "right";
		style.attachField(this,"textNick",4);
		this.textNick.text = Lang.fv("loginForm.nickname");
	
		this.attachMovie("inputField","inputName",8,{fieldProperty: {tabIndex: 1,myBox: this.box}})
		this.inputName._x = -20 //162
		this.inputName._y = -28
		this.inputName.resize(90);
		//	
		style.pos = {x: -101,y: -12,w: 80,h: 20};
		style.attachField(this,"textPass",2);
		this.textPass.text = Lang.fv("loginForm.passwd");;
			
		this.attachMovie("inputField","inputPass",6,{fieldProperty:{password:true,tabIndex: 2,myBox: this.box}})
		this.inputPass._x = -20 //162
		this.inputPass._y = -8
		this.inputPass.resize(90);
		
		// Button
		this.attachMovie("pinkBut","butValidate",12,{tabIndex: 3})
		this.butValidate.setText(Lang.fv("validate"))
		this.butValidate._x = -28;
		this.butValidate._y = 14;
		this.butValidate.setButtonMethod("onRelease",box,"ident");
		
		// moduleList
		for(var i=0; i<moduleList.length; i++){
			this.initModule(moduleList[i])
			this.eventList.push({mc:this["module"+this.moduleList[i].id],type:"rotation",marge:20});
		}
	
	}
	

	/*-----------------------------------------------------------------------
		Function: removeLoginScreen()
	 ------------------------------------------------------------------------*/		
	function removeLoginScreen(){

		this.inputName.removeMovieClip();
		this.inputPass.removeMovieClip();
		this.butValidate.removeMovieClip();
		this.textNick.removeTextField()
		this.textPass.removeTextField()
		
		for(var i=0; i<this.moduleList.length; i++){
			var mc = this["module"+i]
			var x = (this.moduleList[i].pos.x)/2;
			var y = (this.moduleList[i].pos.y)/2;
			this.animList.addAnim("module"+i, setInterval(this, "moveModule", 25, i, {x:x,y:y}))
		}	
	}
	
	/*-----------------------------------------------------------------------
		Function: initModule(mod)
	 ------------------------------------------------------------------------*/		
	function initModule(mod){
		if(!mod.exist){
			this.attachMovie("module"+mod.name,"module"+mod.id,20+mod.id);
				var mc = this["module"+mod.id]
				mc._x = 0
				mc._y = 0
				mc.morphToButton();
				// TODO: ça existe tjs ça onFrutiRelease ? c juste pour être sûr
				mc.onFrutiRelease = function(){
					this._parent.box[arguments.callee.name]();
				}
				mc.onFrutiRelease.name = mod.name		
			this.white.attachMovie("moduleCircle","rond"+mod.id,mod.id)
				var mc = white["rond"+mod.id]
				mc.gotoAndStop(1)
				mc._width = mod.size+10
				mc._height = mod.size+10		
			this.grey.attachMovie("moduleCircle","rond"+mod.id,mod.id)
				var mc = grey["rond"+mod.id]
				mc.gotoAndStop(2)
				mc._width = mod.size+14
				mc._height = mod.size+14		
			this.black.attachMovie("moduleCircle","rond"+mod.id,mod.id)
				var mc = black["rond"+mod.id]
				mc.gotoAndStop(3)
				mc._width = mod.size+16
				mc._height = mod.size+16	
			mod.exist=true;
		}
		this.animList.addAnim("module"+mod.id, setInterval(this, "moveModule", 25, mod.id,{x:mod.pos.x,y:mod.pos.y}))		
	}
	
	/*-----------------------------------------------------------------------
		Function: moveModule(num,pos)
	 ------------------------------------------------------------------------*/		
	function moveModule(num,pos){
	
		var modName = this.moduleList[num].name;
		var mc = this["module"+num];
		var mc2 = this.white["rond"+num];
		var mc3 = this.grey["rond"+num];
		var mc4 = this.black["rond"+num];
		var c = Math.pow(0.8,_global.tmod);

		mc._x = mc._x*c + pos.x*(1-c)
		mc._y = mc._y*c + pos.y*(1-c)
		
		mc._xscale = Math.max(100-Math.abs(mc._x - this.moduleList[num].pos.x)*4,0)
		mc._yscale = mc._xscale
	
		mc2._x = mc._x; mc3._x = mc._x; mc4._x = mc._x
		mc2._y = mc._y; mc3._y = mc._y; mc4._y = mc._y
	
		if(Math.round(mc._x/2)==Math.round(mc.x/2) and Math.round(mc._y/2)==Math.round(mc.y/2)){
			this.animList.remove("module"+num)
		}
	}
	
	/*-----------------------------------------------------------------------
		Function: checkEvent()
	 ------------------------------------------------------------------------*/		
	function checkEvent(){
		var o = this.eventList[random(this.eventList.length)]
		if(o.type=="rotation"){
			o.mc.marge = o.marge
			this.animList.addAnim("turn"+o.mc._name,setInterval(this,"turn",25,o.mc))
		}else if(o.type=="play"){
			o.mc.play();
		}
	}
	
	/*-----------------------------------------------------------------------
		Function: turn()
	 ------------------------------------------------------------------------*/		
	function turn(mc){
		if(mc.marge == undefined) mc.marge = 0;
		if(mc.rot == undefined) mc.rot = 0;
		
		mc.marge=Math.max(mc.marge-(_global.tmod/10),0);
		mc.rot=(mc.rot+(_global.tmod*mc.marge*2))%628
		mc._rotation=Math.cos((mc.rot-314)/100)*mc.marge;
		if(mc.marge==0){
			this.animList.remove("turn"+mc._name);
		}
	}
		
	/*-----------------------------------------------------------------------
		Function: morphSize(mc,scale)
	 ------------------------------------------------------------------------*/		
	function morphSize(mc,scale){
		var c = Math.pow(0.8,_global.tmod);
		mc._xscale = mc._xscale*c + scale*(1-c)
		mc._yscale = mc._yscale*c + scale*(1-c)
		if(Math.round(mc._xscale/2)==Math.round(scale/2)){
			this.animList.remove("morphSize"+mc._name)
			if(mc.scale==0)mc._visible=false;
			if(mc==this){
				this.box.close();
			}
		}
	}
	
	/*-----------------------------------------------------------------------
		Function: getInput(field)
	 ------------------------------------------------------------------------*/		
	function getInput(field){
		return this[field].getInput();
	}
	
	/*-----------------------------------------------------------------------
		Function: setInput(field,value)
	 ------------------------------------------------------------------------*/		
	function setInput(field,value){
		this[field].setInput(value);
	}
	
	function setInputFocus(field){
		this[field].focus();
	}
			
	/*-----------------------------------------------------------------------
		Function: displayIdent()
	 ------------------------------------------------------------------------*/		
	function displayIdent(){
		if(this.textError != undefined){
			this.textError.removeTextField();
			this.butBack.removeMovieClip();
		}
		this.genLoginScreen();
	}
	
	/*-----------------------------------------------------------------------
		Function: displayError(str)
	 ------------------------------------------------------------------------*/		
	function displayError(str){
		if(this.pleaseWait._visible){
			animList.addAnim("morphSizepleaseWait",setInterval(this,"morphSize",25,pleaseWait,0))
		}
		this.createTextField ("textError",4,	-101,-30,200,60)
		var style = {align:"center", font:"Verdana", size:10}
		var fieldStyle = {selectable:false,multiline: true,wordWrap: true}
		this.textError.text=str;
		this.textError.addToTextFormat(style);
		this.textError.addProp(fieldStyle);
			
		// Button
		this.attachMovie("pinkBut","butBack",12)
		this.butBack.setText(Lang.fv("back"))
		this.butBack._x = -28;
		this.butBack._y = 14;
		this.butBack.setButtonMethod("onRelease",this.box,"displayIdent");
	
	}

	/*-----------------------------------------------------------------------
		Function: displayWait()
	 ------------------------------------------------------------------------*/		
	function displayWait(){
		this.pleaseWait._visible=true;
		this.pleaseWait._xscale = 0;
		this.pleaseWait._yscale = 0;
		this.animList.addAnim("morphSizepleaseWait",setInterval(this,"morphSize",25,this.pleaseWait,100))
	}

	/*-----------------------------------------------------------------------
		Function: squeezeOut()
	 ------------------------------------------------------------------------*/		
	function squeezeOut(){
		this.animList.addAnim("squeeze",setInterval(this,"morphSize",25,this,0));
	}
	
	function updateDeskSize(){
		//this.minimum.w = 0;
		//this.minimum.h = 0;
		
	}	
	//{
}

