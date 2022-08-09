class win.NewBouille extends win.Advance{//}
	
	// a recevoir
	var modifList:Array;
	var str:String;
	var cbValidate:Object;	//callback

	var screen:cp.FrutiScreen;
	var fb:MovieClip;
	var info:Array;
	
	var doc:cp.Document;
	var flTrace:Boolean;
	
	function NewBouille(){

		this.init();
	}
	
	function init(){
		//_root.test+="initNewBouille\n"

		super.init();
		
		this.topIconList.splice(0,3);
		if( this.modifList == undefined ) this.modifList = new Array(1,2,3,4,5,6,7,8,9,10,11);	//DEBUG
		if( this.str == undefined ) this.str = "000000000000020000"//"000602000000020000";			//DEBUG
		this.endInit();
	}
	
	function endInit(){
		super.endInit();
		this.screen.onStatusObj( {fbouille:this.str}, {obj:this,method:"initControlPanel"})

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
		//
		var margin = Standard.getMargin();
		margin.y.ratio = 0;
		margin.y.min = 10;
		
		var pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[
				{
					list: [
						{
							type: "text",
							big: 1,
							param: {
								text:"nom:"
							}
						},
						{	type:"input",
							width:100,
							param:{
								name: "name",
								variable: "name",
								text: "chapeau x",
								fieldProperty: {maxChars: 50}
							}
						}					
					]
				},
				{
					list: [
						{
							type: "text",
							big: 1,
							param: {
								text:"nombre:"
							}
						},
						{	type:"input",
							width:100,
							param:{
								name: "nb",
								variable: "nb",
								text: "20",
								fieldProperty: {maxChars: 50}
							}
						}					
					]
				},
				{
					list: [
						{
							type: "text",
							big: 1,
							param: {
								text:"prix:"
							}
						},
						{	type:"input",
							width:100,
							param:{
								name: "price",
								variable: "price",
								text: "60",
								fieldProperty: {maxChars: 50}
							}
						}					
					]
				}				
			]
		}
		var args = {
			flMask:true,
			pageObj:pageObj
		}
		
		var frame = {
			type:"compo",
			name:"docFrame",
			link:"cpDocument",
			min:{w:200,h:100},
			mainStyleName:"frSystem",
			win:this,
			margin:margin,
			args:args
		};
		this.doc = this.main.newElement(frame);		
	}
	
	function initControlPanel(){
		
		this.fb = this.screen.last
		this.updateInfo();
		
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
		var value = this.str
		var name = this.doc.card["name"].value;
		var qty = this.doc.card["nb"].value;
		var price = this.doc.card["price"].value;
		this.box.sendBouille( value, name, qty, price )
		//this.box.validate(this.str)
		//this.fb.action();
	}
	

	
//{
}
