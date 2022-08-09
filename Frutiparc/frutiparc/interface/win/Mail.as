class win.Mail extends win.Advance{//}

	// a recevoir
	var fromName:String;
	var mainDoc:cp.Document;
	var infoDoc:cp.Document;
	var panelToolDoc:cp.Document;
	var butDoc:cp.Document;
	
	var ati:AdvancedTextInput;
	
	function Mail(){
		this.init();
		
		//this.minimum = {w: 500,h: 300}
	}
	
	function init(){
		//_root.test+="winMail init\n"
		if(this.fromName==undefined)this.fromName= Lang.fv("unknow_user")
		super.init();
		this.endInit();
	}
	
	function initFrameSet(){
		super.initFrameSet();
		this.attachInfo();
		this.attachEditTool();
		this.attachMain();
		this.attachEndButton();
		
		this.ati = new AdvancedTextInput({
			field: this.mainDoc.console.content,
			
			docPanel: this.panelToolDoc,
			btBold: "flBold",
			btItalic: "flItalic",
			btUnderline: "flUnderline",
			cbColor: "",
			cbSize: "textSize"
		
		});
	}
	
	function onClose(){
		this.ati.onKill();
		super.onClose();
	}

	function attachInfo(){
		var pageObj,args,frame;
		var h = 20
		var w = 60
		pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[
				{	height:h,
					list:[
						{	type:"text",
							width:w,
							param:{
								text: Lang.fv("mail.from")
							}
						},
						{	type:"text",
							big:1,
							param:{
								text:this.fromName,
								flBackground:true,
								fieldProperty: {html: 1}
							}
						}						
					]
				},
				{	height:h,	
					list:[
						{	type:"text",
							width:w,
							param:{
								text: Lang.fv("mail.to")
							}
						},
						{	type:"input",
							big:1,
							param:{
								variable:"recipient",
								name: "recipient",
								fieldProperty: {dropBox: this.box}
							}
						}						
					]
				},
				{	height:h,	
					list:[
						{	type:"text",
							width:w,
							param:{
								text: Lang.fv("mail.subject")
							}
						},
						{	type:"input",
							big:1,
							param:{
								variable:"subject",
								name: "subject"
							}
						}						
					]
				}				
			]
		}
		args = {
			flDocumentFit:true,
			//flBackground:true,
			pageObj:pageObj
		}
		frame = {
			name:"infoFrame",
			link:"cpDocument",
			type:"compo",
			mainStyleName:"frSystem",
			min:{w:200,h:0},				
			args:args
		}
		this.infoDoc = this.main.newElement( frame, 0 )
	
	}
	
	function attachEditTool(){
		var pageObj,args,frame;
		pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[
				{	height:28,
					list:[
						{	type:"link",
							link:"butFlag",
							width:20,
							param:{
								variable: "flBold",
								link:"butFlagSmallPink",
								frame:2
							}
						},
						{	type:"link",
							link:"butFlag",
							width:20,
							param:{
								variable: "flItalic",
								link:"butFlagSmallPink",
								frame:3
							}
						},
						{	type:"link",
							link:"butFlag",
							width:20,
							param:{
								variable: "flUnderline",
								link:"butFlagSmallPink",
								frame:4
							}
						},
						{	type:"spacer",
							big:1
						},	
						{	type:"comboBox",
							width:100,
							dy:4,
							param:{
								variable:"textSize",
								def:"normal",
								text:Lang.fv("mail.font_size")
							}
						}
					]
				}				
			]
		}
		args = {
			flDocumentFit:true,
			pageObj:pageObj
		}
		frame = {
			name:"editToolFrame",
			link:"cpDocument",
			type:"compo",
			mainStyleName:"frSystem",
			min:{w:200,h:0},				
			args:args
		}
		this.panelToolDoc = this.main.newElement( frame, 1 )
	}
	
	function attachMain(){
		var pageObj,args,frame;
		pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[
				{	big:1,
					list:[
						{	type:"input",
							big:1,
							param:{
								variable:"content",
								name:"content",
								flBackground:false,
								flSingleLine:false,
								textFormat: {size: 12},
								fieldProperty: {html: true,multiline: true,wordWrap: true,myBox: this.box,dropBox: this.box},
								colorToUse: "overdark"
							}
						}
					]
				}
			]
		}
		args = {
			//flDocumentFit:true,
			pageObj:pageObj,
			flGravity:false,
			flMask:true
		}
		frame = {
			name:"mainFrame",
			link:"cpDocument",
			type:"compo",
			flBackground:true,
			mainStyleName:"frDef",
			min:{w:200,h:120},				
			args:args
		}
		this.mainDoc = this.main.newElement( frame, 2 )
		this.main.bigFrame = this.main.mainFrame;		
	}
	
	function attachEndButton(){
	
		var pageObj,args,frame;
		pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[
				{	
					list:[
						{	type:"spacer",
							width:4
						},
						{	type: "checkBox",
							width: 210,
							param: {
								variable: "savetooutbox",
								text: Lang.fv("mail.add_in_outbox")
							}							
						},
						{	type:"spacer",
							big:1
						},	
						/*
						{	type:"button",
							param:{
								initObj:{txt:Lang.fv("mail.save")},
								buttonAction:{onPress:[{obj:this,method:"saveMail"}]}
							}
						},
						*/
						{	type:"button",
							param:{
								initObj:{txt:Lang.fv("mail.send")},
								buttonAction:{onPress:[{obj:this,method:"sendMail"}]}
							}
						}						
					]
				}				
			]
		}
		args = {
			flDocumentFit:true,
			pageObj:pageObj
		}
		var margin = Standard.getMargin();
		margin.x.min = 4;
		margin.x.ratio = 0;
		margin.y.min = 6;
		margin.y.ratio = 0.66;
		frame = {
			name:"infoFrame",
			link:"cpDocument",
			type:"compo",
			mainStyleName:"frSystem",
			margin:margin,
			min:{w:414,h:0},				
			args:args
		}
		this.butDoc = this.margin.bottom.newElement( frame )
			
	}
	
	function displayWait(){
		this.main.removeElement("infoFrame");
		this.main.removeElement("editToolFrame");
		this.margin.bottom.removeElement("infoFrame");
		
		this.mainDoc.console.content.setText("");
		this.mainDoc.displayWait();
		
		this.frameSet.update();
	}
	
	function removeWait(){
		this.attachInfo();
		this.attachEditTool();
		this.attachEndButton();
		
		this.mainDoc.removeWait();

		this.frameSet.update();
	}
	
	//TODO FUNCTION:
	function setRecipient(r){
		this.infoDoc.console.recipient.setText(r);
	}
	
	function getRecipient(){
		return this.infoDoc.card.recipient.value;
	}
	
	function setSubject(r){
		this.infoDoc.console.subject.setText(r);
	}
	
	function setCbOutbox(v){
		this.butDoc.setVariable("savetooutbox",v);
	}
	
	function getSubject(){
		return this.infoDoc.card.subject.value;
	}
	
	function setContent(r){
		r = this.mainDoc.console.content.addHtmlStyle(r);
		this.mainDoc.console.content.setText(r);
		this.ati.setDefaultNewTextFormat();
	}
	
	function getContent(){
		return this.mainDoc.console.content.field.htmlText;
	}
	
	function getCbOutbox(){
		return this.butDoc.card.savetooutbox.value;
	}
	
/*	function saveMail(){
		this.box.saveDraft();
	}
*/
	function sendMail(){
		this.box.sendMail();
	}
	
	function scrollText(delta){
		this.mainDoc.mask.y.path.pixelScroll(delta);
	}
//{	
}
