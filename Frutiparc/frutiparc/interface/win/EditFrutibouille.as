class win.EditFrutibouille extends win.Advance{//}
	
	// a recevoir
	var modifList:Array;
	var str:String;
	var cbValidate:Object;	//callback

	var screen:cp.FrutiScreen;
	var fb:MovieClip;
	var info:Array;
	var changedProps:Array;
	
	var flTrace:Boolean;
	
	function EditFrutibouille(){
		this.changedProps = new Array();
		this.init();
	}
	
	function init(){
		//_root.test+="initEditFrutibouille\n"
		//this.flTrace=true;
		super.init();
		
		this.topIconList.splice(0,3);
		
		if( this.modifList == undefined ) this.modifList = new Array(1,2,3,4,5,6,7,8);	//DEBUG
		if( this.str == undefined ) this.str = "000000000000020000"//"000602000000020000";			//DEBUG
		this.endInit();
	}
	
	function endInit(){
		super.endInit();
		this.screen.onStatusObj( {fbouille:this.str}, {obj:this,method:"initControlPanel"})
		//this.screen.addContent("frutibouille",{loadInitCallback:{obj:this,method:"initControlPanel"}})
	}

	function initFrameSet(){
		super.initFrameSet();
		// FRUTISCREEN
		
		var margin = Standard.getMargin();
		margin.y.ratio = 0;
		margin.y.min = 10;
		
		var args = { fix:{w:100,h:100} }
		
		var frame = {
			type:"compo",
			name:"screenFrame",
			link:"frutiScreen",
			min:{w:200,h:100},
			mainStyleName:"frSystem",
			win:this,
			margin:margin,
			args:args
		};
		this.screen = this.main.newElement(frame);
		
	}
	
	function initControlPanel(){
		//_root.test+="initControlPanel\n"
		this.fb = this.screen.last
		
		//this.info = this.fb.getInfo();
		this.updateInfo();
		//_root.test+="initControlPanel this.info("+this.fb+") this.info("+this.info+")\n"
		
		// COMPOSANTS
		for( var i=0; i<this.modifList.length; i++){
			var id = this.modifList[i]
			var margin = Standard.getMargin();
			margin.y.ratio = 1;
			margin.y.min = 10;
			var args={
				id:id,
				val:FEString.decode62( str.substring( 2*id, (2*id)+2 ) ),
				parent:this
			}
			var frame = {
				type:"compo",
				name:"console"+i,
				link:"cpFBConsole",
				min:{w:140,h:26},
				win:this,
				args:args
			};
			this.main.newElement(frame);			
		}
		
		// VALIDER
		var args={
			doc:new XML("<p><l><s b=\"1\"/><b t=\"valider\" l=\"butPushStandard\" o=\"win\" m=\"validate\"/><s b=\"1\"/></l></p>")
		}
		var frame = {
			type:"compo",
			name:"frameValidate",
			link:"cpDocument",
			min:{w:140,h:22},
			margin:margin,
			args:args
		};	
		this.main.newElement(frame);
		this.frameSet.update();
		
	}
	
	function setVal(id,val){
		//_root.test+="setValue("+id+","+val+")\n"
		this.changedProps[id] = true;
		this.str = this.str.substring(0,id*2)+FENumber.encode62(val,2)+this.str.substring((id+1)*2)
		this.fb.apply(str);
		//UPDATE CONSOLE:
		if(this.info[id].control!=undefined){
			this.updateInfo();
			this.main["console"+this.info[id].control].path.val = 0
			this.setVal(this.info[id].control,0);
		}		
	}
	
	function updateInfo(){
		this.info = this.fb.getInfo();
	}
	
	function validate(){
		// TODO
		_root.test+="validate\n"
		this.box.validate(this.str)
		//this.fb.action();
	}
	
	function hasTouchAllButton(){
		//_global.debug("Tient au fait, est ce que le frutiz il est touche à tout ?");
		for(var i=0;i<this.modifList.length;i++){
			//_global.debug("i: "+i+", id: "+this.modifList[i]+" ==> "+this.changedProps[this.modifList[i]]);
			if(!this.changedProps[this.modifList[i]]) return false;
		}
		return true;
	}
	
//{
}
