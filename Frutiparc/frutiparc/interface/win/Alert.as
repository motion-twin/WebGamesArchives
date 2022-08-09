class win.Alert extends WinStandard{//}
	
	var info:Object;
	
	/*-----------------------------------------------------------------------
		Function: Login()
		Constructeur
	 ------------------------------------------------------------------------*/	
	function Alert(){
		//_root.test+="win.Alerto\n"
		this.init();
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/		
	function init(){
		//this.iconLabel="alert"
		this.flResizable=false;
		super.init();
		
		this.topIconList.splice(0,3);

		/*
		var obj = {
			text:"Attention ca bug !!!\n C'est affreux",
			butList:[
				{name:"yes",action:{}},
				{name:"no",action:{}}
			]
		}
		*/
		if(this.info!=undefined)this.setAlert(this.info)
		
		this.endInit();
		this.moveToCenter()
	}

	/*-----------------------------------------------------------------------
		Function: pressYes()
	 ------------------------------------------------------------------------*/		
	function pressYes(){
		// TODO
	}	

	/*-----------------------------------------------------------------------
		Function: pressNo()
	 ------------------------------------------------------------------------*/		
	function pressNo(){
		// TODO
	}
	
	/*-----------------------------------------------------------------------
		Function: setAlert(obj)
		
		Parameters:					// ANCIEN FORMAT
			obj - object - {
				type: "ok" | "yesno",
				text: "Blah blah",
				yes: {obj: obj, method: "method"},
				no: {obj: obj, method: "method"},
			}
		
		Parameters:					// JE PREFERE CE FORMAT SI CA TE DERANGE PAS TROPS	
		obj - object - {
			text: "Blah blah",
			butList:[
				{name:"yes", action:{obj:obj, method:"method"},
				{name:"no", action:{obj:obj, method:"method"}
			]
		}
	
	
	 ------------------------------------------------------------------------*/		
	function setAlert(obj){
		//_root.test+="set Alert("+obj.text+")\n"
		
		// BASE
		var pageObj = {
			pos:{x:0,y:0,w:200,h:0},
			lineList:[
				{	height:80,
					list:[
						{	type:"text",
							param:{
								text:obj.text,
								fieldProperty: {html: true}
							}
						}
					]
				}
			]
		}
		var args = {
			flMask:true,
			flBackground:true,
			pageObj:pageObj
		}
		var frame = {
			name:"frameDoc",
			link:"cpDocument",
			type:"compo",
			mainStyleName:"frSystem",
			min:{w:200,h:80},				
			args:args
		}
		this.main.newElement( frame )
		this.main.bigFrame = this.main.frameDoc;	
		
		
		// BOUTONS
		var pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[
				{height:24,list:new Array()}
			]
		}
		pageObj.lineList[0].list.push( { width:0, big:"1", type:"spacer" } )
		for(var i=0; i<obj.butList.length;i++){
			var o = obj.butList[i];
			var e = {
				type:"button",
				param:{
					link:"butPushStandard",
					buttonAction:{
						onPress:[o.action]
					},
					initObj:{
						txt:o.name
					}				
				}
			}
			pageObj.lineList[0].list.push(e)
			pageObj.lineList[0].list.push( { width:0, big:"1", type:"spacer" } )			
		}
		var args = {
			pageObj:pageObj
		}
		var margin = Standard.getMargin()
		margin.y.min = 8
		margin.y.ratio = 1
		var frame = {
			name:"frameButton",
			link:"cpDocument",
			type:"compo",
			mainStyleName:"frSystem",
			min:{w:200,h:24},			
			args:args,
			margin:margin
		}
		this.main.newElement( frame )
	}

	/*-----------------------------------------------------------------------
		Function: setText(text)
	 ------------------------------------------------------------------------*/		
	/* OLD
	function setText(text){
		mainField.text = text
		var sup = 6
		if(mainField.textHeight+sup>mainField._height){
			mainField._height = mainField.textHeight+sup
		}
		mid._height = mainField._height-30
		bottom._y = mid._y+mid._height
		
		pos.h = 120 + mid._height;
	}
	*/

	
//{
}


