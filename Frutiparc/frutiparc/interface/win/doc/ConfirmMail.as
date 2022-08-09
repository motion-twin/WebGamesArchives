class win.doc.ConfirmMail extends win.Doc{//}

	//var myDoc:cp.Document;
	
	/*-----------------------------------------------------------------------
		Function: ConfirmMail()
	 ------------------------------------------------------------------------*/	
	function ConfirmMail(){
		this.init();	
	}

	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		
		//_root.test+="winDocConfirmMail init\n"
		
		this.frameInfo = {
			flBackground:true,
			mainStyleName:"frDef"
		}
		this.docInfo = {
			flDocumentFit:true
		}
		//
		this.flTabable = false;
		this.flResizable = false;
		//this.flDocumentFit = true;
		super.init();
		this.pos.w = 280
		this.pos.h = 100
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
	
	function validate(){
		//_root.test+="validate("+this.myDoc.card.codeMail.value+")\n"
		//this.box.checkKey(this.myDoc.card.codeMail.value)
		this.box.validate(this.myDoc.card.codeMail.value)
	}
	
	function sendAgain(){
		this.box.sendAgain();
	}

	function changeMail(){
		var docString = "<p><l h=\"60\"><t>"+Lang.fv("cmail.change_form_desc")+"</t></l>"
		docString += "<l h=\"24\"><s b=\"1\"/><i w=\"160\" v=\"email\"/><s b=\"1\"/></l>"
		docString += "<l><s b=\"1\"/><b t=\""+Lang.fv("cmail.change")+"\" l=\"butPushStandard\" o=\"win\" m=\"newMail\"/><s b=\"1\"/></l></p>"
		this.myDoc.setDoc(new XML(docString))
		this.removeWait();
		this.frameSet.update();
	}	
	
	function newMail(){
		this.box.changeEmail(this.myDoc.card.email.value);
	}
	
	function getMainDoc(str){
		var doc = "<p>";
		if(str != undefined){
			doc += "<l><t m=\"0\">"+str+"<p><textFormat align=\"center\"/></p></t></l>";
		}
		doc += "<l><t m=\"0\">"+Lang.fv("cmail.enter_key")+"<p><textFormat align=\"center\"/></p></t></l>"
		doc += "<l h=\"22\"><s b=\"1\"/><i w=\"160\" v=\"codeMail\"/><s b=\"1\"/></l>"
		doc += "<l h=\"26\"><s b=\"1\"/><b t=\""+Lang.fv("validate")+"\" l=\"butPushStandard\" o=\"win\" m=\"validate\"/><s b=\"1\"/></l>"
		doc += "<l>"
		doc += "<t b=\"1\">"+Lang.fv("cmail.send_again_desc")+"<p><textFormat align=\"center\"/></p></t>"
		doc += "<t b=\"1\">"+Lang.fv("cmail.change_desc")+"<p><textFormat align=\"center\"/></p></t>"
		doc += "</l>"
		doc += "<l h=\"26\">"
		doc += "<s b=\"1\"/><b t=\""+Lang.fv("cmail.send_again")+"\" l=\"butPushStandard\" o=\"win\" m=\"sendAgain\"/>"
		doc += "<s b=\"1\"/><b t=\""+Lang.fv("cmail.change")+"\" l=\"butPushStandard\" o=\"win\" m=\"changeMail\"/><s b=\"1\"/>"
		doc += "</l>"
		doc += "</p>"		
		return new XML(doc);
	}
	
	function displayMain(str){
		this.myDoc.setDoc(this.getMainDoc(str));
		this.removeWait();
		this.frameSet.update();
	}
	
	function displayAcceptCharte(){
		var pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			big:true,
			lineList:[]		
		}
		
		pageObj.lineList.push(
			{	
				list:[
					{	type:"text",
						big: 1,
						param:{
							text: Lang.fv("cmail.charte"),
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
							def: false
						}
					}
				]
			}
		);
		
		var arr = new Array();
		arr.push({	type: "spacer", big: 1 });
		arr .push({	type:"button",
			param:{
				initObj: { txt: Lang.fv("ok") },
				buttonAction: {onRelease: [{obj: this,method: "acceptCharte"}]}
			}
		});
		arr.push({	type: "spacer", big: 1 });
		pageObj.lineList.push({list: arr});
		
	
		this.myDoc.setPageObj(pageObj)
		this.removeWait();
		this.frameSet.update();
	}
	
	function acceptCharte(){
		if(this.myDoc.card.charte.value){
			this.box.acceptCharte();
		}else{
		
		}
	}
	
//{	
}




