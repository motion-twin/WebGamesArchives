class miniwave.box.InfoMain extends miniwave.Box{//}
	
	var mainTxtHeight:Number = 94
	var fadeSpeed:Number = 15
	
	var illusList:Array;
	var content:MovieClip;
	var firstPage:Number;
	
	var mainTxt:String;
	var mainTxtIndex:Number;
	
	function InfoMain(){
		this.init();
	}
	
	function init(){
		super.init();
		if(this.firstPage == undefined )this.firstPage = 0;
		this.illusList = new Array();
		this.content._visible = false;
		this.content.screen.d = 0
	}
	
	function setPage(id){
		//_root.test+="setPage("+id+")\n"
		
		this.mainTxtIndex = 0;
		
		var titleTxt, mainTxt, illusFrame;
		switch(id){
		
			case 0:
				titleTxt = "bienvenue"
				var mng = this.page.menu.mng
				var d = new Date();
				var h = d.getHours();
				var b;
				if( h > 5 && h < 16 ){
					b = "Bonjour "
				}else{
					b = "Bonsoir "
				}
				this.mainTxt = b+mng.gradeName[mng.fc[0].$lvl]+" "+mng.client.getUser()+", choisissez votre section."
				illusFrame = 1
				break;
			case 1:
				titleTxt = "action"
				this.mainTxt = "Repoussez les  fruits mutants au confin du Frunivers et gagnez des Crédits."
				illusFrame = 2
				break;
			case 2:
				titleTxt = "missions"
				this.mainTxt = "Débloquez et validez les 8 missions du mode bonus."
				illusFrame = 3
				break;
			case 3:
				titleTxt = "secret?"
				this.mainTxt = "Decouvrez les projets les plus secrets de la mini-airforce."
				illusFrame = 4
				break;
			case 4:
				titleTxt = "achats"
				this.mainTxt = "Dépensez vos crédits et améliorez votre arsenal."
				illusFrame = 5
				break;
			case 5:
				titleTxt = "options"
				this.mainTxt = "Modifiez les paramètres du jeu."
				illusFrame = 6
				break;					
			
		}
		
		this.content.titleField.text = titleTxt

		this.setIllus(illusFrame)
		
	}
	
	function setIllus(frame){
		var d = this.content.screen.d++;
		this.content.screen.attachMovie("illus","illus"+d,d);
		var mc = this.content.screen["illus"+d];
		mc.gotoAndStop( frame );
		mc.alpha = 0;
		mc._alpha = 0;
		this.illusList.push(mc)
	}
	
	function update(){
		super.update();
		
		for( var i=0; i<this.illusList.length; i++ ){
			var mc = this.illusList[i];
			if(i<this.illusList.length-1){
				mc.alpha -= this.fadeSpeed*Std.tmod
				mc.removeMovieClip();
			}else{
				mc.alpha = Math.min( 100, mc.alpha+this.fadeSpeed*Std.tmod )
			}
			mc._alpha = mc.alpha
		}
		
		this.mainTxtIndex += Std.tmod
		
		var i = Math.round(mainTxtIndex)
		var str = this.mainTxt.slice(0,this.mainTxtIndex)
		if( this.mainTxtIndex < this.mainTxt.length ) str += "_";
		
		this.content.mainField.text = str
		var h = this.gh - this.mainTxtHeight
		this.content.mainField._y = mainTxtHeight+ (h-this.content.mainField.textHeight)/2

	}
	
	function initContent(){
		super.initContent();
		this.content._visible = true;
		this.setPage(this.firstPage)
		
	};
	
	function removeContent(){
		super.removeContent();
		this.content._visible = false;
	}
	
	
	
	
	
//{	
}