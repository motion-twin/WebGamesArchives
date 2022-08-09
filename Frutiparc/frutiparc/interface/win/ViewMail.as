class win.ViewMail extends win.Advance{//}


	// a recevoir
	var fromName:String;
	var toName:String;
	var subject:String;
	var content:String;
	var date:String;
	
	// VARIABLES
	
	var infoDoc:cp.Document;
	var mainDoc:cp.Document;
	
	var debugIntervalId:Number;
	
	
	function ViewMail(){
		this.init();
	}
	
	function init(){
		//_root.test+="winViewMail init\n"
		this.date = Lang.fv("please_wait");
		this.fromName = Lang.fv("please_wait");
		this.toName = Lang.fv("please_wait");
		this.subject = Lang.fv("please_wait");
		super.init();
		
		this.pos = {x:50,y:50,w:500,h:400};
		
		this.endInit();
		// DEBUG TEST
		//this.debugIntervalId = setInterval(this,"debugFunc",5000)
		
	}
	
	function initFrameSet(){
		super.initFrameSet();
		this.attachInfo();
		//this.attachTool();
		this.attachMain();
		this.attachEndButton();
	}

	function setMail(mail){	// {date,from,to,subject,content}
		//_root.test+="setMail("+mail+")\n"
		//
		//mail.content = "<b>bonjour</b>"
		//
		
		this.infoDoc.console.date.setText(mail.date)
		this.infoDoc.console.from.setText(mail.from)
		this.infoDoc.console.to.setText(mail.to)
		this.infoDoc.console.subject.setText(mail.subject)
		//var content = "<font color=\"#558811\">"+mail.content+"</font>"
		this.mainDoc.console.content.setText(mail.content);
		
		if(this.mainDoc.flWait)this.mainDoc.removeWait();
		
		this.main.update();
	}
	
	function attachInfo(){
		var pageObj,args,frame;
		var h = 20
		var w = 60
		pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[
				{	height:h,	// DATE
					list:[
						{	type:"text",
							width:w,
							param:{
								text: Lang.fv("mail.date"),
								textFormat: {align: "right"}
							}
						},
						{	type:"text",
							big:1,
							param:{
								name:"date",
								text:this.date,
								fieldProperty: {multiline: false,wordWrap: false}
								//flBackground:true
							}
						}						
					]
				},
				{	height:h,	// SENDING
					list:[
						{	type:"text",
							width:w,
							param:{
								text: Lang.fv("mail.from"),
								textFormat: {align: "right"}
							}
						},
						{	type:"text",
							big:1,
							param:{
								name:"from",
								text:this.fromName,
								fieldProperty: {html: true,multiline: true,wordWrap: true}
								//flBackground:true
							}
						}						
					]
				},
				{	height:h,	// RECEIVING	
					list:[
						{	type:"text",
							width:w,
							param:{
								text:Lang.fv("mail.to"),
								textFormat: {align: "right"}
							}
						},
						{	type:"text",
							big:1,
							param:{
								name:"to",
								text:this.toName,
								fieldProperty: {html: true,multiline: false,wordWrap: false}
							}
						}						
					]
				},
				{	height:h,	
					list:[
						{	type:"text",
							width:w,
							param:{
								text: Lang.fv("mail.subject"),
								textFormat: {align: "right"}
							}
						},
						{	type:"text",
							big:1,
							param:{
								name:"subject",
								text:this.subject,
								fieldProperty: {multiline: false,wordWrap: false}
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
			name:"infoFrame",
			link:"cpDocument",
			type:"compo",
			mainStyleName:"frSystem",
			min:{w:200,h:0},				
			args:args
		}
		this.infoDoc = this.main.newElement( frame )
	
	}
	
	function attachEndButton(){
		var doc,args,frame,margin;
		
		doc = "<p><l><b t=\""+Lang.fv("mail.move_to_recyclebin")+"\" l=\"butPushStandard\" o=\"win\" m=\"moveToRecycleBin\"/><s b=\"1\"/><b t=\""+Lang.fv("mail.reply")+"\" l=\"butPushStandard\" o=\"win\" m=\"reply\"/><s w=\"8\"/><b t=\""+Lang.fv("mail.forward")+"\" l=\"butPushStandard\" o=\"win\" m=\"forward\"/></l></p>"
		
		args = {
			flDocumentFit:true,
			doc:new XML(doc)
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
			min:{w:200,h:0},				
			args:args
		}
		this.margin.bottom.newElement( frame )
	}
	
	function attachMain(){
		var pageObj,args,frame;
		pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[
				{	big:1,
					list:[
						{	type:"text",
							big:1,
							param:{
								name:"content",
								text:this.content,
								textFormat: {size: 12},
								fieldProperty: {html: true,selectable: true,mouseWheelEnabled: true,myBox: this.box}
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
			flMask:true,
			flWait:true
		}
		var margin = Standard.getMargin();
		frame = {
			margin: margin,
			name:"mainFrame",
			link:"cpDocument",
			type:"compo",
			flBackground:true,
			mainStyleName:"frDef",
			min:{w:200,h:80},
			args:args
		}
		this.mainDoc = this.main.newElement( frame )
		this.main.bigFrame = this.main.mainFrame;		
	}
	
	/*
	function attachEndButton(){
	
		var pageObj,args,frame;
		pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[
				{	
					list:[
						{	type:"spacer",
							big:1
						},	
						{	type:"button",
							param:{
								initObj:{txt:"sauvegarder"},
								buttonAction:{onPress:[{obj:this,method:"saveMail"}]}
							}
						},
						{	type:"button",
							param:{
								initObj:{txt:"envoyer"},
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
			min:{w:204,h:0},				
			args:args
		}
		this.margin.bottom.newElement( frame )
			
	}
	*/
	
	//TODO FUNCTION:
	function reply(){
		this.box.openReply();
	}
	function forward(){
		this.box.openForward();
	}
	function moveToRecycleBin(){
		this.box.moveToRecycleBin();
	}

	function scrollText(delta){
		this.mainDoc.mask.y.path.pixelScroll(delta);
	}
//{	
}