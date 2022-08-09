class win.Subscribe extends win.Advance{//}
	
	var mainDoc:cp.Document;
	var errors:Array;
	//var flStepTwo:Boolean;
	//var screen:cp.FrutiScreen;
	//var info;
	//var bouilleStr;
	//var fb;

	/*-----------------------------------------------------------------------
		Function: Subscribe()
	 ------------------------------------------------------------------------*/	
	function Subscribe(){
		this.flResizable = false;
		this.errors = new Array();
		//this.flStepTwo = false;
		
		this.init();
		
	}

	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		//
		super.init();
		
		this.endInit();
		//
	}
	
	function initFrameSet(){
		super.initFrameSet();
	
	}



	/*-----------------------------------------------------------------------
		Function: initFrameSet()
	 ------------------------------------------------------------------------*/	
	function displayStep(step,values){
		if(this.main.showFrame == undefined){
			// initialise la frame show
			var margin = Standard.getMargin();
			this.main.newElement({ name:"showFrame", type:"h", min:{w:360,h:280}, flBackground:true, margin:margin})
			this.main.bigFrame = this.main.showFrame;
		}
		
		//if(this.flStepTwo) this.removeStepTwo();
	
		this.main.showFrame.removeElement("docFrame");
		this.errors = new Array();

		var pageObj,args,frame;
		pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[]
		}
		

		if(step == 1){
			// PRESENT
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							big: 1,
							param:{
								text: Lang.fv("subscribe.present")
							}
						}
					]
				}
			);
			
			// NAME
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							big: 1,
							param:{
								name: "error_"+"name",
								text: Lang.fv("subscribe.details.name")
							}
						}
					]
				}
			);
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							width: 100,
							param:{
								sid: 2,
								text: Lang.fv("subscribe.name")
							}
						},
						{	type:"input",
							big: 1,
							param:{
								name: "name",
								variable: "name",
								text: values.name,
								fieldProperty: {restrict: "A-Za-z0-9",maxChars: 18,tabIndex: 1}
							}
						}
					]
				}
			);
			// PASS
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							big: 1,
							param:{
								name: "error_"+"pass",
								text: Lang.fv("subscribe.details.pass")
							}
						}
					]
				}
			);
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							width: 100,
							param:{
								sid: 2,
								text: Lang.fv("subscribe.pass")
							}
						},
						{	type:"input",
							big: 1,
							param:{
								name: "pass",
								variable: "pass",
								text: values.pass,
								fieldProperty: {password: true,tabIndex: 2}
							}
						}
					]
				}
			);
			// PASS2
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							width: 100,
							param:{
								sid: 2,
								text: Lang.fv("subscribe.pass2")
							}
						},
						{	type:"input",
							big: 1,
							param:{
								name: "pass2",
								variable: "pass2",
								text: values.pass2,
								fieldProperty: {password: true,tabIndex: 3}
							}
						}
					]
				}
			);
			// EMAIL
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							big: 1,
							param:{
								name: "error_"+"email",
								text: " "
							}
						}
					]
				}
			);
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							width: 100,
							param:{
								sid: 2,
								text: Lang.fv("subscribe.email")
							}
						},
						{	type:"input",
							big: 1,
							param:{
								name: "email",
								variable: "email",
								text: values.email,
								fieldProperty: {maxChars: 150,tabIndex: 4}
							}
						}
					]
				}
			);
			// REF
			if(values.dsp_ref){
				pageObj.lineList.push(
					{	
						list:[
							{	type:"text",
								big: 1,
								param:{
									name: "error_"+"ref",
									text: Lang.fv("subscribe.details.ref"),
									fieldProperty: {
										html: true
									}
								}
							}
						]
					}
				);
				pageObj.lineList.push(
					{	
						list:[
							{	type:"text",
								width: 100,
								param:{
									sid: 2,
									text: Lang.fv("subscribe.ref")
								}
							},
							{	type:"input",
								big: 1,
									param:{
										name: "ref",
										variable: "ref",
										text: values.ref,
										fieldProperty: {restrict: "A-Za-z0-9",maxChars: 18,tabIndex: 5}
								}
							}
						]
					}
				);
			}
		}else if(step == 3){
			// FIRSTNAME
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							big: 1,
							param:{
								name: "error_"+"firstname",
								text: Lang.fv("subscribe.details.firstname")
							}
						}
					]
				}
			);
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							width: 100,
							param:{
								sid: 2,
								text: Lang.fv("subscribe.firstname")
							}
						},
						{	type:"input",
							big: 1,
							param:{
								name: "firstname",
								variable: "firstname",
								text: values.firstname,
								fieldProperty: {maxChars: 50,tabIndex: 1}
							}
						}
					]
				}
			);
			// LASTNAME
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							big: 1,
							param:{
								name: "error_"+"lastname",
								text: Lang.fv("subscribe.details.lastname")
							}
						}
					]
				}
			);
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							width: 100,
							param:{
								sid: 2,
								text: Lang.fv("subscribe.lastname")
							}
						},
						{	type:"input",
							big: 1,
							param:{
								name: "lastname",
								variable: "lastname",
								text: values.lastname,
								fieldProperty: {maxChars: 80,tabIndex: 2}
							}
						}
					]
				}
			);
			pageObj.lineList.push(
				{	
					list:[
						{	type:"checkBox",
							big: 1,
							param:{
								name: "lastname_public",
								variable: "lastname_public",
								text: Lang.fv("subscribe.details.lastname_public"),
								def: values.lastname_public
							}
						}
					]
				}
			);
			// BIRTHDAY
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							big: 1,
							param:{
								name: "error_"+"birthday",
								text: " "
							}
						}
					]
				}
			);
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							width: 100,
							param:{
								sid: 2,
								text: Lang.fv("subscribe.birthday")
							}
						},
						{	type:"input",
							width: 25,
							param:{
								name: "birthday_dd",
								variable: "birthday_dd",
								text: values.birthday_dd,
								fieldProperty: {maxChars: 2,tabIndex: 3,restrict: "0-9"}
							}
						},
						{	type:"text",
							width: 12,
							param:{
								text: "/"
							}
						},
						{	type:"input",
							width: 25,
							param:{
								name: "birthday_mm",
								variable: "birthday_mm",
								text: values.birthday_mm,
								fieldProperty: {maxChars: 2,tabIndex: 4,restrict: "0-9"}
							}
						},
						{	type:"text",
							width: 12,
							param:{
								text: "/"
							}
						},
						{	type:"input",
							width: 40,
							param:{
								name: "birthday_yyyy",
								variable: "birthday_yyyy",
								text: values.birthday_yyyy,
								fieldProperty: {maxChars: 4,tabIndex: 5,restrict: "0-9"}
							}
						}
					]
				}
			);
			// GENDER
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							big: 1,
							param:{
								name: "error_"+"gender",
								text: " "
							}
						}
					]
				}
			);
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							width: 100,
							param:{
								sid: 2,
								text: Lang.fv("subscribe.gender")
							}
						},
						{	type:"radio",
							width: 90,
							param:{
								name: "gender_m",
								variable: "gender",
								val: "M",
								text: Lang.fv("gender.M")
							}
						},
						{	type:"radio",
							width: 90,
							param:{
								name: "gender_f",
								variable: "gender",
								val: "F",
								text: Lang.fv("gender.F")
							}
						}
					]
				}
			);



		}else if(step == 4){
			// COUNTRY
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							big: 1,
							param:{
								name: "error_"+"country",
								text: Lang.fv("subscribe.details.country")
							}
						}
					]
				}
			);
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							width: 100,
							param:{
								sid: 2,
								text: Lang.fv("subscribe.country")
							}
						},
						{	type:"comboBox",
							big: 1,
							param:{
								name: "country",
								variable: "country",
								text: values.country_text
							}
						}
					]
				}
			);
			// REGION
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							width: 100,
							param:{
								sid: 2,
								text: Lang.fv("subscribe.region")
							}
						},
						{	type:"comboBox",
							big: 1,
							param:{
								name: "region",
								variable: "region",
								text: values.region_text
							}
						}
					]
				}
			);
			// CITY
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							big: 1,
							param:{
								name: "error_"+"city",
								text: Lang.fv("subscribe.details.city")
							}
						}
					]
				}
			);
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							width: 100,
							param:{
								sid: 2,
								text: Lang.fv("subscribe.city")
							}
						},
						{	type:"input",
							big: 1,
							param:{
								name: "city",
								variable: "city",
								text: values.city,
								fieldProperty: {maxChars: 50,tabIndex: 1}
							}
						}
					]
				}
			);
			// REALJOB
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							big: 1,
							param:{
								name: "error_"+"realJob",
								text: Lang.fv("subscribe.details.realJob")
							}
						}
					]
				}
			);
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							width: 100,
							param:{
								sid: 2,
								text: Lang.fv("subscribe.realJob")
							}
						},
						{	type:"input",
							big: 1,
							param:{
								name: "realJob",
								variable: "realJob",
								text: values.realJob,
								fieldProperty: {maxChars: 50,tabIndex: 1}
							}
						}
					]
				}
			);
			// CHARTE
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							big: 1,
							param:{
								name: "error_"+"charte",
								text: Lang.fv("subscribe.details.charte"),
								fieldProperty: {html: 1}
							}
						}
					]
				}
			);
			pageObj.lineList.push(
				{	
					list:[
						{	type:"checkBox",
							big: 1,
							param:{
								name: "charte",
								variable: "charte",
								text: Lang.fv("subscribe.charte"),
								def: values.charte
							}
						}
					]
				}
			);
		}
		
		pageObj.lineList.push({	big: 1 });

		
		var arr = new Array();
		if(step > 1){
			arr .push({	type:"button",
				param:{
					initObj: { txt: Lang.fv("subscribe.previous_step") },
					buttonAction: {onRelease: [{obj: this.box,method: "goStep",args: false}]}
				}
			});
		}
		// central
		arr.push({	type: "spacer", big: 1 });
		if(step < 4){
			arr .push({	type:"button",
				param:{
					initObj: { txt: Lang.fv("subscribe.next_step") },
					buttonAction: {onRelease: [{obj: this.box,method: "goStep",args: true}]}
				}
			});
		}
		if(step == 4){
			arr .push({	type:"button",
				param:{
					initObj: { txt: Lang.fv("subscribe.validate_form") },
					buttonAction: {onRelease: [{obj: this.box,method: "goStep",args: true}]}
				}
			});
		}
		pageObj.lineList.push({list: arr});
		
		args = {
			//flDocumentFit:true,
			flMask:true,
			flBackground:true,
			pageObj:pageObj
		}
		var margin = Standard.getMargin();
		margin.x.min = 10;
		margin.x.ratio = 0.5;
		margin.y.min = 8;
		margin.y.ratio = 0.7;
		frame = {
			name:"docFrame",
			link:"cpDocument",
			type:"compo",
			mainStyleName:"frSheet",
			margin: margin,
			min:{w:350,h:272},
			args:args
		}
		
		this.mainDoc = this.main.showFrame.newElement(frame)
		this.main.showFrame.bigFrame = this.main.showFrame.listFrame;

		// Special for radio button (gender) and comboBox (country/region)
		if(step == 3){
			this.mainDoc.setVariable("gender",values.gender);
		}else if(step == 4){
			this.mainDoc.setVariable("country",values.country_sel);
			this.mainDoc.setVariable("region",values.region_sel);
			
			this.mainDoc.removeVariableListener("country","country_combo_on_change");
			this.mainDoc.addVariableListener("country",{obj: this.box,method: "onCountryChange",uniq: "country_combo_on_change"});
		}
		
		if(values.errors != undefined){
			for(var i=0;i<values.errors.length;i++){
				var o = values.errors[i];
				this.displayError(o.cat,o.txt);
			}
		}

		this.frameSet.update();
	}
	
	/*
	function displayStepTwo(values){
		if(this.main.showFrame != undefined){
			this.main.removeElement("showFrame");
		}
		
		///
		this.flStepTwo = true;
		
		var pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[{
				list: [{
					type: "text",
					big: 1,
					param: {
						text: Lang.fv("subscribe.details.bouille"),
						fieldProperty: {html: true}
					}
				}]
			}]
		}
		var args = {
			flDocumentFit:true,
			flMask:true,
			flBackground:false,
			pageObj:pageObj
		}
		var margin = Standard.getMargin();
		margin.y.ratio = 0;
		margin.y.min = 10;
		var frame = {
			type:"compo",
			name:"docFrame",
			link:"cpDocument",
			type: "compo",
			min:{w:350,h:20},
			mainStyleName:"frSystem",
			margin:margin,
			args:args
		};
		this.main.newElement(frame);
		
		var margin = Standard.getMargin();
		margin.y.ratio = 0;
		margin.y.min = 10;
		margin.x.ratio = 0.5;
		margin.x.min = 20;
		
		var args = { fix:{w:100,h:100} }
		
		var frame = {
			type:"compo",
			name:"screenFrame",
			link:"frutiScreen",
			min:{w:350,h:100},
			mainStyleName:"frSystem",
			win:this,
			margin:margin,
			args:args
		};
		this.screen = this.main.newElement(frame);
		
		this.bouilleStr = values.bouille;
		
		this.screen.onStatusObj( {fbouille:values.bouille}, {obj:this,method:"initControlPanel"})
	}
	
	function initControlPanel(){
		this.fb = this.screen.last;
		this.info = this.fb.getInfo();
		
		// Buttons
		var modifList = [4];
		for( var i=0; i<modifList.length; i++){
			var id = modifList[i]
			var margin = Standard.getMargin();
			margin.y.ratio = 1;
			margin.y.min = 10;
			var args={
				id:id,
				val:FEString.decode62( this.bouilleStr.substring( 2*id, (2*id)+2 ) ),
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
		
		var pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[{
				list: [{
					type: "button",
					param:{
						initObj: { txt: Lang.fv("subscribe.previous_step") },
						buttonAction: {onRelease: [{obj: this.box,method: "goStep",args: false}]}
					}
				},{	
					type: "spacer", 
					big: 1
				},{
					type: "button",
					param:{
						initObj: { txt: Lang.fv("subscribe.next_step") },
						buttonAction: {onRelease: [{obj: this.box,method: "goStep",args: true}]}
					}
				}]
			}]
		}
		var args = {
			flDocumentFit:true,
			flMask:true,
			flBackground:false,
			pageObj:pageObj
		}
		var margin = Standard.getMargin();
		margin.y.ratio = 1;
		margin.y.min = 10;
		var frame = {
			type:"compo",
			name:"buttonFrame",
			link:"cpDocument",
			type: "compo",
			min:{w:350,h:20},
			mainStyleName:"frSystem",
			margin:margin,
			args:args
		};
		this.main.newElement(frame);
		
		this.frameSet.update();

	}
	
	function setVal(id,val){
		//_root.test+="setValue("+id+","+val+")\n"
		this.bouilleStr = this.bouilleStr.substring(0,id*2)+FENumber.encode62(val,2)+this.bouilleStr.substring((id+1)*2)
		this.fb.apply(this.bouilleStr);
		//UPDATE CONSOLE:
		if(this.info[id].control!=undefined){
			this.info = this.fb.getInfo();
			this.main["console"+this.info[id].control].path.val = 0
			this.setVal(this.info[id].control,0);
		}		
	}
	
	function getFBouille(){
		return this.bouilleStr;
	}
	
	function removeStepTwo(){
		this.main.removeElement("docFrame");
		this.main.removeElement("screenFrame");
		this.main.removeElement("console0");
		this.main.removeElement("console1");
		this.main.removeElement("console2");
		this.main.removeElement("buttonFrame");
	}
	*/
	function updateRegionCombo(t){
		this.mainDoc.console.region.text = t;
		this.mainDoc.console.region.initElementList();
		this.mainDoc.setVariable("region",0);
		this.mainDoc.console.region.valSetTo(0); // pour s'assurer que l'affichage est bien mis à jour
	}
	
	function displayError(cat,txt){
		this.errors.pushUniq(cat);
		
		this.mainDoc.console["error_"+cat].style.textFormat.color = 0x990000;
		this.mainDoc.console["error_"+cat].field.textColor = 0x990000;
		this.mainDoc.console["error_"+cat].setText(txt);
		
		this.mainDoc.updateSize();
	}
	
	function cleanError(){
		for(var i=0;i<this.errors.length;i++){
			this.mainDoc.console["error_"+this.errors[i]].setText(" ");
		}
		this.mainDoc.updateSize();
	}
	
	function getInput(n){
		return this.mainDoc.card[n].value;
	}
	
	function displayWait(){
		this.mainDoc.setPageObj();
		this.mainDoc.displayWait();
		
		this.frameSet.update();
	}
	
	function removeWait(){
		this.mainDoc.removeWait();
	}
//{	
}




