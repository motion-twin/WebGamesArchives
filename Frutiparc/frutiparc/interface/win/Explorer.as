class win.Explorer extends win.Advance{//}
	
	//var flNewDirectory:Boolean;
	//var flRemoveAll:Boolean;
	var flNewDirectoryPanel:Boolean;
	var flError:Boolean;
	var folderType:Object;
	
	var navigatorIconList:Array;
	var mcNavigator:MovieClip;
	var mcFileIconList:MovieClip;
	
	var lister:cp.ListField;
	
	var nbAlertFrame:Number;
	

	function Explorer(){
		this.init();
	}
	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		//this.iconLabel="explorer"
		super.init()
		this.pos = {x:50,y:50,w:400,h:400};
		this.nbAlertFrame = 0;
		this.flNewDirectoryPanel=false;
		if( this.folderType == undefined ){
			this.folderType = {
				styleName:"frFileStandard",
				flNewDirectory:true,
				flRemoveAll:false
			}		
		}
		
		this.initNavigatorIconList()
		this.displayNavigatorIconList()
		// TODO: vérifier qu'on pouvait bien mettre en commentaire... paske y'a pas de methode avec ce nom là, et je vois pas à quoi ça fait référence
		this.displayExplorer();
		this.endInit();
		this.moveToCenter();
	}

	/*-----------------------------------------------------------------------
		Function: initNavigatorIconList()
		Génére la liste de bouton de l'explorer.
	 ------------------------------------------------------------------------*/	
	function initNavigatorIconList(){
		
		this.navigatorIconList = [];
		
		if(this.folderType.flUp){
			var but = 	{link:"butPush", param:{
						link:"butPushNavigator",
						frame:2,
						outline:2,
						curve:4,
						tipId: "explorer_up",
						buttonAction:{ 
							onPress:[{
								obj:this.box,
								method:"getParent"
							}]
						}
							
					}
			};
			this.navigatorIconList.push(but);
		}
			
		if(this.folderType.flNewDirectory){
			var but = {link:"butPush", param:{
						link:"butPushNavigator",
						frame:3,
						outline:2,
						curve:4,
						tipId: "explorer_new_folder",
						buttonAction:{ 
							onPress:[{
								obj:this,
								method:"displayNewDirectoryFrame"
							}]
						}
					}
				}
			this.navigatorIconList.push(but);		
		}
		
		if(this.folderType.flRemoveAll){
			var but = {link:"butPush", param:{
						link:"butPushNavigator",
						frame:4,
						outline:2,
						curve:4,
						tipId: "explorer_empty_recyclebin",
						buttonAction:{ 
							onPress:[{
								obj:this.box,
								method:"tryToRemoveAll"
							}]
						}
					}
				}
			this.navigatorIconList.push(but);		
		}
		
		if(this.folderType.flMail){
			var but = {link:"butPush", param:{
						link:"butPushNavigator",
						frame:5,
						outline:2,
						curve:4,
						tipId: "explorer_new_mail",
						buttonAction:{ 
							onPress:[{
								obj:this.box,
								method:"newMail"
							}]
						}
					}
				}
			this.navigatorIconList.push(but);		
		}			
	}
	
	/*-----------------------------------------------------------------------
		Function: displayNavigatorIconList()
	 ------------------------------------------------------------------------*/	
	function displayNavigatorIconList(){
		if(!this.navigatorIconList.length) return;
		
		var struct = Standard.getStruct();
		struct.limit="y";
		struct.x.size = 24;
		struct.y.size = 24;
		struct.x.space = 2;
		struct.y.space = 2;
		var args = {
			list:this.navigatorIconList,
			struct:struct,
			_y:margin.top,
			flMask:true,
			mask:{flScrollable:false} 
		};
		var frame = {
			name:"navigatorFrame",
			link:"basicIconList",
			type:"compo",
			min:{w:80,h:28},
			args:args	
		}
		this.mcNavigator = main.newElement(frame,0)
	}

	/*---------------------
	--------------------------------------------------
		Function: initExplorer()
	 ------------------------------------------------------------------------*/	
	function displayExplorer(){
		var args = {
			// SKOOL: on n'as ni variable dir, ni variable list par ici, faudrait préciser ce que vous voulez dire mon bon monsieur !
			// BUM: ben j'aurais des variables list et dir, si mesdemoiselles les boxs etaient foutues de mes les envoyer en temps réél plutot que de m'envoyer un displayList quand la guerre de l'init est finie.
			// SKOOL: mesdemoiselles les box en seraient capables si le contenu des dossiers n'était pas géré par un serveur, et donc serait fixe !
			// Mais pensez vous qu'au niveau fonctionnalité ce serait aussi interessant ?
			// D'autre part, mademoiselle la window n'a toujours pas integré la fonction displayWait qui a pourtant été choisie avant même sa naissance !
			// template:dir.tpl,
			// list : list,
			// dropBox:box,
			flMask:true
		};
		var frame ={
			name:"fileIconListFrame",
			link:"fileIconList",
			type:"compo",
			min:{w:100,h:100},
			flBackground:true,
			flWait:true,
			mainStyleName:this.folderType.styleName,
			args:args
		}
		this.mcFileIconList = this.main.newElement(frame)
		this.main.bigFrame = this.main.fileIconListFrame
	}

	/*-----------------------------------------------------------------------
		Function: displayList(dir)
	 ------------------------------------------------------------------------*/	
	function displayList(dir){
		this.mcFileIconList.removeWait();
		//if(dir.tpl=="default" or dir.tpl==undefined) dir.tpl = _global.userPref.getPref("icon_display_style");
		if(dir.tpl=="default" or dir.tpl==undefined) dir.tpl = "normal";
		//_root.test+="displayList("+dir+") template("+dir.tpl+")\n"
		//
		
		//
		switch(dir.tpl){
			case "normal":
				this.mcFileIconList.min.w = 200;
				break;
			case "mail":
				this.mcFileIconList.min.w = 400;
				if(dir.tplInfo==undefined){
					//_root.test += " BIIIIP ---> tpl info manquant ! valeur d'urgence activé ! \n"
					dir.tplInfo = {supList: this.folderType.lister};
				}
				break;
			default:
				this.mcFileIconList.min.w = 200;
				break;			
		}
		//
		var list = new Array();
		for(var i=0; i<dir.list.length; i++){
			var o = new Object();
			o.param = dir.list[i];
			if(dir.tpl=="normal"){
				if(o.param.type == "disc" ){	
					o.link = "fileIconFull"
				}else{
					o.link = "fileIconStandard"
				}
				
			}else if(dir.tpl=="mail"){
				o.link = "fileIconDetail"				
			}else{
				o.param.infoSupList = [
					{name:"name",min:120}
				]
				o.link = "fileIconDetail"
				
			}
			//_root.test+="o.link("+o.link+")\n"
			list.push(o)
		}
		//this.mcFileIconList.template=dir.tpl;
		this.mcFileIconList.updateList(list,dir.tpl,dir.tplInfo);
		this.mcFileIconList.updateSize();
		//this.mcFileIconList.alignIcon();
	}
	
	function displayNewDirectoryFrame(){
		if(!flNewDirectoryPanel){
			var args = {
				doc:new XML("<p><l h=\"24\"><i b=\"1\" v=\"dirName\" r=\"A-Za-z0-9 éàèëïêùûüâñç-+=()[]\">"+Lang.fv("explorer.new_folder")+"</i><s w=\"6\"/><b dy=\"-2\" t=\"Valider\" l=\"butPushStandard\" o=\"win\" m=\"createNewDirectory\"/></l></p>"),
				mainStyleName:"global",
				secondStyleName:"content"
			};
			var frame ={
				name:"newDirectoryFrame",
				link:"cpDocument",
				type:"compo",
				min:{w:100,h:24},
				args:args
			}
			this.main.newElement(frame,"navigatorFrame");
			this.frameSet.update();
			this.flNewDirectoryPanel=true;
		}else{
			this.removeNewDirectoryPanel();
			this.main.update();
		}
	}
	
	function removeNewDirectoryPanel(){
		this.main.removeElement("newDirectoryFrame");
		this.flNewDirectoryPanel=false;
	}

	function createNewDirectory(){
		//_root.test+="createDirectorty("+this.main.newDirectoryFrame.path.card.dirName.value+")\n"
		this.box.addFolder(this.main.newDirectoryFrame.path.card.dirName.value)
		this.removeNewDirectoryPanel();
		this.frameSet.update();
	}
	
	function setFolderType(newFolderType){
		var flUpdate = false;
		if(this.flNewDirectoryPanel){
			this.removeNewDirectoryPanel();
			//this.main.update();
			flUpdate = true;
		}

		if( newFolderType.styleName != this.folderType.styleName ){
			this.folderType.styleName  = newFolderType.styleName ;
			this.main.removeElement("fileIconListFrame");
			this.displayExplorer();
			
			flUpdate = true;
		}		
		
		if( newFolderType.flNewDirectory != this.folderType.flNewDirectory or newFolderType.flRemoveAll != this.folderType.flRemoveAll or newFolderType.flMail != this.folderType.flMail or newFolderType.flUp != this.folderType.flUp){
			this.folderType.flNewDirectory  = newFolderType.flNewDirectory;
			this.folderType.flRemoveAll  = newFolderType.flRemoveAll;
			this.folderType.flMail = newFolderType.flMail;
			this.folderType.flUp = newFolderType.flUp;
			this.main.removeElement("navigatorFrame");
			this.initNavigatorIconList();
			this.displayNavigatorIconList();
			flUpdate = true;
		}
		/*
		newFolderType.lister = [		// HACK
			{displayName:"Auteur",name:"from",min:140,sort:1},
			{displayName:"Sujet",name:"name",min:200, big:true},
			{displayName:"Date",name:"dateDsp",min:80}				
		]
		*/
		if( newFolderType.lister){
			if( this.folderType.lister == undefined ){
				this.displayLister()
			}
			this.folderType.lister = newFolderType.lister;
			this.updateLister()
			flUpdate = true;
		}else{
			if( this.folderType.lister != undefined ) this.removeLister();
			delete this.folderType.lister;
		}
		
		if(flUpdate)this.frameSet.update();
		
		
	}
	
	function displayLister(){
		//_root.test+="displayLister\n"
		this.margin = Standard.getMargin();
		margin.y.ratio = 0;
		margin.y.min = 6;
		
		var args = {
			color:this.style.frFileStandard.color[0],
			callback:{obj:this.box,method:"sortBy"}
		};
		var frame ={
			name:"listerFrame",
			link:"cpListField",
			type:"compo",
			flBackground:true,
			margin:margin,
			mainStyleName:this.folderType.styleName,
			min:{w:200,h:16},
			args:args
		}
		this.lister = this.main.newElement(frame,"navigatorFrame");
		//_root.test+="a("+a+")\n"
	}
	
	function removeLister(){
		this.main.removeElement("listerFrame");
	}
	
	function updateLister(){
		//_root.test+="updateLister()\n"
		//for(var elem in this.main.listerFrame)_root.test+="-"+elem+"("+this.main.listerFrame[elem]+")\n"
		this.lister.setInfo(this.folderType.lister);
	}
	
	function displayWait(){
		this.displayList()
		this.mcFileIconList.displayWait();
	}
	
	function displayError(error){
		//_root.test+="displayError("+error+")\n"
		var margin = Standard.getMargin();
		margin.y.min = 6;
		margin.y.ratio = 0;
		
		var docString = "<p><l><t>"+error+"</t></l></p>"
		var args = {
			doc:new XML(docString),
			flDocumentFit:true
		};
		var frame ={
			name:"errorFrame",
			link:"cpDocument",
			type:"compo",
			min:{w:100,h:40},
			flBackground:true,
			//flTrace:true,
			mainStyleName:"frSystem",
			margin:margin,
			args:args
		}
		this.main.newElement(frame,"navigatorFrame")
		this.frameSet.update();
	}
	
	function removeError(){
		this.main.removeElement("errorFrame");
		this.frameSet.update();
	}
	
	function displayAlert(arr){
		this.removeAlert();
		
		var margin = Standard.getMargin();
		margin.y.min = 6;
		margin.y.ratio = 0;
		
		for(var i=0;i<arr.length;i++){
			var args = {
				doc:new XML(arr[i]),
				flDocumentFit:true
			};
			var frame ={
				name:"alertFrame"+i,
				link:"cpDocument",
				type:"compo",
				min:{w:100,h:20},
				flBackground:true,
				mainStyleName:"frSystem",
				margin:margin,
				args:args
			}
			this.main.newElement(frame,"navigatorFrame")
		}
		this.nbAlertFrame = arr.length;
		this.frameSet.update();
	}
	
	function removeAlert(){
		for(var i=0;i<this.nbAlertFrame;i++){
			this.main.removeElement("alertFrame"+i);
		}
		this.nbAlertFrame = 0;
		this.frameSet.update();
	}
	
	function scrollContent(delta){
		this.mcFileIconList.mask.y.path.pixelScroll(delta);
	}
//{
}




















