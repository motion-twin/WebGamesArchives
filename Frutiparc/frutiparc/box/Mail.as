class box.Mail extends box.Standard{
	var to:String;
	var subject:String;
	var content:String;
	var uid:String;
	var saveToOutbox:Boolean;
	
	function Mail(obj){
		this.winType = "winMail";
		//_root.test+="boxMail init\n"
		for(var n in obj){
			this[n] = obj[n];
		}
		this.title = Lang.fv("mail.write_new_mail");
	}
	
	function preInit(){
		// called only at start of the first init
		this.desktopable = true;
		this.tabable = true;
		super.preInit();
		
		if(this.winOpt == undefined) this.winOpt = new Object();
		this.winOpt.fromName = _global.me.name+" &lt;"+_global.me.name+"@frutiparc.com&gt;";
		
		this.saveToOutbox = _global.userPref.getPref("save_to_outbox");
		if(this.saveToOutbox == undefined) this.saveToOutbox = true;
	}

	function init(slot,depth){
		var rs = super.init(slot,depth);

		if(rs){
			// first init
			if(this.to != undefined){
				this.window.setRecipient(this.to);
			}
			if(this.content != undefined){
				this.window.setContent(this.content);
			}
			if(this.subject != undefined){
				this.window.setSubject(this.subject);
			}
			this.window.setCbOutbox(this.saveToOutbox);
		}else{
			// change mode init
		}

		return rs;
	}
	
	function getFormValue(){
		this.content = this.window.getContent();
		this.subject = this.window.getSubject();
		this.to = this.window.getRecipient();
		this.saveToOutbox = this.window.getCbOutbox();
	}
	
	function setFormValue(){
		//_global.debug("Set content: "+FEString.unHTML(this.content));
		this.window.setContent(this.content);
		this.window.setSubject(this.subject);
		this.window.setRecipient(this.to);
		this.window.setCbOutbox(this.saveToOutbox);
	}
	
	function sendMail(to,subject,content){
		this.getFormValue();
	
		// Check to and subject length
		if(this.to.length == 0){
			_global.openAlert(Lang.fv("mail.to_empty"));
			return;
		}else if(this.subject.length == 0){
			_global.openAlert(Lang.fv("mail.subject_empty"));
			return;
		}
		
		this.window.displayWait();
		
		var content = FEString.simplifyHTML(this.content);
	
		var loader:HTTP = new HTTP("fm/sendmail",{t: this.to,s: this.subject,c: content,o: this.saveToOutbox?'1':'0'},{type: "xml",obj: this,method: "onSend"},"POST");
	}
	
	function onSend(success,xml){
		if(!success){
			this.window.removeWait();
			this.setFormValue();
			return _global.openErrorAlert(Lang.fv("error.host_unreachable"));
		}
		xml = xml.lastChild;
		if(xml.nodeName != "r"){
			this.window.removeWait();
			this.setFormValue();
			return _global.openErrorAlert(Lang.fv("error.http.1"));
		}
		
		if(xml.attributes.k != undefined){
			var errStr = "";
			if(xml.hasChildNodes()){
				if(xml.attributes.k != "1"){
					errStr += Lang.fv("error.http."+xml.attributes.k)+"\n";
				}
				for(var n=xml.firstChild;n.nodeType>0;n=n.nextSibling){
					if(n.attributes.s != undefined){
						errStr += n.attributes.s+": "+Lang.fv("error.http."+n.attributes.k)+"\n";
					}else{
						errStr += Lang.fv("error.http."+n.attributes.k)+"\n";
					}
				}
			}else{
				errStr += Lang.fv("error.http."+xml.attributes.k);
			}
			
			this.window.removeWait();
			this.setFormValue();
			return _global.openErrorAlert(errStr);
		}
		
		_global.openAlert(Lang.fv("mail.send_success"),Lang.fv("mail.send_success_title"));
		this.close();
	}
	
	function saveDraft(to,subject,content){
		_global.openErrorAlert("L'enregistrement de vos brouillons sera bientôt disponible.");
		return;
	
		this.getFormValue();
		this.window.displayWait();
		
		var content = FEString.simplifyHTML(this.content);
		
		if(this.uid != undefined){
			var loader:HTTP = new HTTP("fm/sd",{t: this.to,s: this.subject,c: content,u: this.uid},{type: "xml",obj: this,method: "onSaveDraft"},"POST");
		}else{
			var loader:HTTP = new HTTP("fm/sd",{t: this.to,s: this.subject,c: content},{type: "xml",obj: this,method: "onSaveDraft"},"POST");
		}
	}
	
	function onSaveDraft(success,xml){
		if(!success){
			this.window.removeWait();
			this.setFormValue();
			return _global.openErrorAlert(Lang.fv("error.host_unreachable"));
		}
		xml = xml.lastChild;
		if(xml.nodeName != "r"){
			this.window.removeWait();
			this.setFormValue();
			return _global.openErrorAlert(Lang.fv("error.http.1"));
		}
		
		if(xml.attributes.k != undefined){
			var errStr = "";
			if(xml.hasChildNodes()){
				if(xml.attributes.k != "1"){
					errStr += Lang.fv("error.http."+xml.attributes.k)+"\n";
				}
				for(var n=xml.firstChild;n.nodeType>0;n=n.nextSibling){
					if(n.attributes.s != undefined){
						errStr += n.attributes.s+": "+Lang.fv("error.http."+n.attributes.k)+"\n";
					}else{
						errStr += Lang.fv("error.http."+n.attributes.k)+"\n";
					}
				}
			}else{
				errStr += Lang.fv("error.http."+xml.attributes.k);
			}
			
			this.window.removeWait();
			this.setFormValue();
			return _global.openErrorAlert(errStr);
		}
		
		_global.openAlert(Lang.fv("mail.savedraft_success"),Lang.fv("mail.savedraft_success_title"));
		this.close();
	}
	
	function onDrop(obj){
		if(obj.type == "contact"){
			var t = this.window.getRecipient();
			t = obj.desc[0]+" , "+t;
			this.window.setRecipient(t);
		}
	}

	function onWheel(delta){
		this.window.scrollText(-10 * delta);
	}
}
