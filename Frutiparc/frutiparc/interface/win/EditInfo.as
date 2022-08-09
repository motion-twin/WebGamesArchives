class win.EditInfo extends win.Advance{//}
	
	var mainDoc:cp.Document;
	var errors:Array;

	/*-----------------------------------------------------------------------
		Function: Subscribe()
	 ------------------------------------------------------------------------*/	
	function EditInfo(){
		this.flResizable = false;
		this.errors = new Array();
		
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
		
		this.main.showFrame.removeElement("docFrame");
		this.errors = new Array();

		var pageObj,args,frame;
		pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[]
		}
		

		if(step == 1){
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
			pageObj.lineList.push({	big: 1 });

		}else if(step == 2){
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
			pageObj.lineList.push({	big: 1 });
		}else if(step == 3){
			// SITEURL
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							big: 1,
							param:{
								name: "error_"+"siteUrl",
								text: Lang.fv("editinfo.details.siteUrl")
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
								text: Lang.fv("editinfo.siteUrl")
							}
						},
						{	type:"input",
							big: 1,
							param:{
								name: "siteUrl",
								variable: "siteUrl",
								text: values.siteUrl,
								fieldProperty: {maxChars: 50,tabIndex: 1,restrict: "0-9A-Za-z:/.%_&?,;=\\-"}
							}
						}
					]
				}
			);
			
			// Comment
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							big: 1,
							param:{
								sid: 2,
								text: Lang.fv("editinfo.comment")
							}
						}
					]
				}
			);
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							big: 1,
							param:{
								name: "error_"+"comment",
								text: Lang.fv("editinfo.details.comment")
							}
						}
					]
				}
			);
			pageObj.lineList.push(
				{	
					big: 1,
					list:[
						{	type:"input",
							big: 1,
							param:{
								name: "comment",
								variable: "comment",
								text: values.comment,
								flSingleLine:false,
								fieldProperty: {maxChars: 255,tabIndex: 2,multiline: true,wordWrap: true}
							}
						}
					]
				}
			);
		}
		
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
		if(step < 3){
			arr .push({	type:"button",
				param:{
					initObj: { txt: Lang.fv("subscribe.next_step") },
					buttonAction: {onRelease: [{obj: this.box,method: "goStep",args: true}]}
				}
			});
		}
		if(step == 3){
			arr .push({	type:"button",
				param:{
					initObj: { txt: Lang.fv("save") },
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
		if(step == 1){
			this.mainDoc.setVariable("gender",values.gender);
		}else if(step == 2){
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




