class box.ViewMail extends box.Standard{
	
	var from:String;
	var to:String;
	var subject:String;
	
	var fromHTML:String;
	var toHTML:String;
	
	var date:String;
	var uid:String;
	var name:String;
	var desc:Array;
	var content:String;
	
	function ViewMail(obj){
		this.winType = "winViewMail";
		for(var n in obj){
			this[n] = obj[n];
		}
	}
	
	function preInit(){
		// called only at start of the first init
		this.desktopable = true;
		this.tabable = true;
		super.preInit();	
	}
	
	function init(slot,depth){
		var rs = super.init(slot,depth);
		if(rs){
			_global.fileViewMng.setBox(this.uid,this);
		
			this.setTitle(this.name);
			this.subject = this.name;
			
			this.from = this.desc[0];
			this.to = this.desc[2];
			this.fromHTML = FPString.toDisplayMail(this.from);
			this.toHTML = FPString.toDisplayMail(this.to);
			
			var loader = new HTTP("ff/get",{uid: this.uid},{type: "data",obj: this,method: "onGet"});
		}else{
			// change mode init
		}

		return rs;
	}

	function close(){
		_global.fileViewMng.unsetBox(this.uid,this);
		super.close();
	}
	
	function onGet(success,dat){
		if(!success){
			_global.openErrorAlert(Lang.fv("error.host_unreachable"));
			this.close();
		}
		var err = FEString.decode62(dat.substr(0,4));
		if(err != 0){
			_global.openErrorAlert(Lang.fv("error.http."+err));
			this.close();
		}else{
			_global.fileMng.accessFile(this.uid);
			this.content = dat.substr(4);
			this.window.setMail({date: Lang.formatDateString(this.date,"long"),from: this.fromHTML,to: this.toHTML,subject: FEString.unHTML(this.subject),content: this.content});
		}
	}
	
	function openReply(){
		if(FEString.startsWith(this.subject.toLowerCase(),"re:") || FEString.startsWith(this.subject.toLowerCase(),"re :")){
			var subj = this.subject;
		}else{
			var subj = "Re: "+this.subject;
		}
		
		// TODO: ajouter des liens sur les adresses mails
		var content = Lang.fv("mail.reply_tpl",{d: Lang.formatDateString(this.date,"long"),f: FEString.unHTML(this.from),t: FEString.unHTML(this.to),c: this.content,s: this.subject})
		
		_global.desktop.addBox(new box.Mail({to: this.from,subject: subj,content: content}));
		this.tryToClose();
	}
	
	function openForward(){
		if(FEString.startsWith(this.subject.toLowerCase(),"tr:") || FEString.startsWith(this.subject.toLowerCase(),"tr :")){
			var subj = this.subject;
		}else{
			var subj = "Tr: "+this.subject;
		}
		
		// TODO: ajouter des liens sur les adresses mails
		var content = Lang.fv("mail.forward_tpl",{d: Lang.formatDateString(this.date,"long"),f: FEString.unHTML(this.from),t: FEString.unHTML(this.to),c: this.content,s: this.subject})
		
		_global.desktop.addBox(new box.Mail({subject: subj,content: content}));
		this.tryToClose();
	}
	
	function moveToRecycleBin(){
		_global.fileMng.moveToRecycleBin(this.uid);
		this.tryToClose();
	}

	function onWheel(delta){
		this.window.scrollText(-10 * delta);
	}
}
