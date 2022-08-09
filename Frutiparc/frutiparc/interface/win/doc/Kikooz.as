class win.doc.Kikooz extends win.Doc{//}

	//var myDoc:cp.Document;
	var countries:Array;
	var callTypes:Object;
	
	/*-----------------------------------------------------------------------
		Function: Kikooz()
	 ------------------------------------------------------------------------*/	
	function Kikooz(){
		this.init();	
	}

	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		this.frameInfo = {
			//flBackground:true,
			mainStyleName:"frSystem"
		}
		this.docInfo = {
			flDocumentFit:true
		}
		
		this.countries = ["ot","fr","ch","ca","be"]
		//
		this.flTabable = false;
		this.flResizable = false;
		//
		super.init();
		//
		this.pos.w = 280
		//
		this.endInit();
		this.moveToCenter();
	}
	
	/*-----------------------------------------------------------------------
		Function: genDocument()
	------------------------------------------------------------------------*/	
	function genDocument(){
		super.genDocument();
		this.doc = new XML();
	}
	
	function displayStep(step,args){
		if(step == "wait"){
			this.displayWait();
			return false;
		}
	
		var e;
		var line;
		var pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			big:true,
			lineList:[]		
		}
		
		///////////////////////////////////////////////////////////////////
		if(step == 1){
			line = { 
				height:36,
				list:[

					{	
						type:"text",
						param:{
							sid:1,
							text: Lang.fv("kikooz.choose_country"),
							textFormat:{align:"center"}
						}	
					}
				]
			};
			pageObj.lineList.push(line);

			// buttons
			var line = { height:50, list:[{type:"spacer", big:true}]}
			for( var i=0; i<4; i++){
				e = {
					type:"link",
					link:"butPush",
					param:{
						link:"butPushCountry",
						frame:i+1,
						buttonAction:{onRelease:[{obj:this,method:"selectCountry",args:i+1}]}
					}			
				}
				line.list.push(e)
				line.list.push({type:"spacer", big:true})
			}
			pageObj.lineList.push(line)
			//
			pageObj.lineList.push({height:4})
			//
			line = {
				list:[
					{type:"spacer", big:true},
					{type:"button", param:{ initObj:{txt:Lang.fv("kikooz.other_country")}, buttonAction: {onRelease:[{obj:this,method:"selectCountry",args:0}]} }},
					{type:"spacer", big:true}
				]
			}
			pageObj.lineList.push(line)
		
		///////////////////////////////////////////////////////////////////
		}else if(step == 2){
			line = {
				list:[
					{
						type:"text",
						param:{
							sid:2,
							text: Lang.fv("kikooz.choose_call_type"),
							textFormat:{align:"left"}
						}
					}
				]
			}
			pageObj.lineList.push(line)
			
			for(var n in this.callTypes){
				var o = this.callTypes[n];
				
				if(o.available){
					line = {
						list:[
							{
								type:"text",
								param:{
									sid:1,
									text: o.variable_price?Lang.fv("kikooz.choose_call_type_line_variable_price",{f: o.fname}):Lang.fv("kikooz.choose_call_type_line",{f: o.fname,p: o.price,k: o.kikooz}),
									textFormat:{align:"left"},
									fieldProperty: {html: true,multiline: true}
								}
							},
							{
								type:"button",
								param:{ 
									initObj:{txt:Lang.fv("ok")}, 
									buttonAction:{onRelease:[{obj:this.box,method:"chooseCallType",args: n}]}
								}
							}
						]
					}
				}else{
					line = {
						list:[
							{
								type:"text",
								param:{
									sid:1,
									text: Lang.fv("kikooz.choose_call_type_line_soon",{f: o.fname}),
									textFormat:{align:"left"},
									fieldProperty: {html: true,multiline: true}
								}
							}
						]
					}
				}
				pageObj.lineList.push(line)
				pageObj.lineList.push({height:4})

			}
			
			line = {
				list:[
					{
						type:"text",
						param:{
							sid:1,
							text: Lang.fv("kikooz.choose_call_type_warn"),
							textFormat:{align:"left"}
						}
					}
				]
			}
			pageObj.lineList.push(line)

      if(args.infosParents){
   			line = {
	 		    list:[
            {type: "spacer", big: true},
	 				  {
	 					  type:"button",
	 					  param:{
	 					    initObj: {txt: Lang.fv("kikooz.button_infos_parents")},
	 					    buttonAction:{onRelease:[{obj: this.box,method: "openInfosParents"}]}
	 					  }
	 				  },
            {type: "spacer", big: true}
	 			  ]
	 		  }
	 		  pageObj.lineList.push(line)
      }
			
			
		///////////////////////////////////////////////////////////////////
		}else if(step == 3){
		
			if(args.display_popup_info){
				//
				line = {
					list:[
						{
							type:"text",
							param:{
								sid:1,
								text: Lang.fv("kikooz.info_popup"),
								textFormat:{align:"center"}
							}
						}
					]
				}
				pageObj.lineList.push(line)
				//
				pageObj.lineList.push({height:8})
			}
			
			if(args.other_info.length > 0){
				//
				line = {
					list:[
						{
							type:"text",
							param:{
								sid:1,
								text: args.other_info,
								fieldProperty: {html: 1},
								textFormat:{align:"center"}
							}
						}
					]
				}
				pageObj.lineList.push(line)
				//
				pageObj.lineList.push({height:8})
			}
			
			//
			line = {
				list:[
					{
						type:"text",
						param:{
							sid:2,
							text: Lang.fv("kikooz.enter_code_here"),
							textFormat:{align:"center"}
						}
					}
				]
			}
			pageObj.lineList.push(line)
			//
			line = {
				list:[
					{type:"spacer", big:true},
					{width:100, type:"input", param:{variable:"code",fieldProperty: {maxChars: 16}}},
					{type:"spacer", big:true}
				]
			}
			pageObj.lineList.push(line)		
			//
			pageObj.lineList.push({height:8})
			//
			line = {
				list:[
					{type:"spacer", big:true},
					{type:"button", param:{ initObj:{txt:Lang.fv("validate")}, buttonAction:{onRelease:[{obj:this,method:"validate"}]} }},
					{type:"spacer", big:true}
				]
			}
			pageObj.lineList.push(line);
			
		///////////////////////////////////////////////////////////////////
		}else if(step == 4){ // OK
			//
			line = {
				list:[
					{
						type:"text",
						param:{
							sid:1,
							text: Lang.fv("kikooz.all_ok",{k: args}),
							textFormat:{align:"center"}
						}
					}
				]
			}
			pageObj.lineList.push(line)
			//
			pageObj.lineList.push({height:8})
			//
			line = {
				list:[
					{type:"spacer", big:true},
					{type:"button", param:{ initObj:{txt:Lang.fv("ok")}, buttonAction:{onPress:[{obj:this.box,method:"tryToClose"}]} }},
					{type:"spacer", big:true}
				]
			}
			pageObj.lineList.push(line)
			
		///////////////////////////////////////////////////////////////////
		}else if(step == 5){ // ERROR
			line = {
				list:[
					{
						type:"text",
						param:{
							sid:2,
							text: Lang.fv("error.kikooz.title"),
							textFormat:{align:"center"}
						}
					}
				]
			}
			pageObj.lineList.push(line)
			//
			line = {
				list:[
					{
						type:"text",
						param:{
							sid:1,
							text: args,
							textFormat:{align:"center"}
						}
					}
				]
			}
			pageObj.lineList.push(line)
			//
			pageObj.lineList.push({height:8})
			//
			line = {
				list:[
					{type:"spacer", big:true},
					{type:"button", param:{ initObj:{txt:Lang.fv("back")}, buttonAction:{onPress:[{obj:this.box,method:"chooseCallType"}]} }},
					{type:"spacer", big:true}
				]
			}
			pageObj.lineList.push(line)
		}
		///////////////////////////////////////////////////////////////////
		
		this.myDoc.setPageObj(pageObj)
		this.removeWait();
		this.frameSet.update();
	}
	
	function selectCountry(id){
		this.box.selectCountry(this.countries[id]);
	}
	
	function validate(){
		this.box.check(this.myDoc.card.code.value);
	}	
	
	
		
//{	
}




