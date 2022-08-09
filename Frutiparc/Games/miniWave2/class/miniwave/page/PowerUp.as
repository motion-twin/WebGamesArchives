class miniwave.page.PowerUp extends miniwave.Page{//}

	/*
	
	- TOUCHES CLAVIERS :
		GAUCHE
		DROITE
		TIR
		SUPER ATTAQUE
	- MUSIC ON/OFF
	- SFX ON/OFF
	- PARTICULE ON/OFF
	
	
	*/
	
	var box:miniwave.box.PowerUp
	var type:String;
	var num:Number;
	var nextPage:Object
	var size:Object;
	
	
	function PowerUp(){
		this.init();
	}
	
	function init(){
		//_root.test+="[PAGE POWERUP] init() \n"
		if( this.size == undefined ){
			this.size = { w:160, h:160 };
		};
		super.init();
		this.onPress = function (){
			this.menu.setNextPage(this.nextPage);
		}
	}
	
	function initBox(){
		super.initBox();
		
		// DECRIPTION
		var b = 24
		var initObj = {
			gx:( this.width-this.size.w )/2,
			gy:( this.height-this.size.h )/2,
			gw:this.size.w,
			gh:this.size.h,
			waitTimer:0
		}
		this.box = this.newBox("miniWave2BoxPowerUp",initObj);
		switch(this.type){
			case "titem" :
					this.box.setIllus(1);
					this.box.setText(0,"récompense!");
					this.box.setText(1,"Vous avez gagné un nouveau titem !!");
				break;			
			case "mission" :
					this.box.setIllus(10+this.num);
					this.box.setText(0,"bonus!");
					this.box.setText(1,"Une nouvelle mission a été débloqué dans la section bonus.");			
				break;				
			case "grade" :
					this.box.setIllus(20+this.num);
					this.box.setText(0,"promotion!");
					this.box.setText(1,"Félicitation, votre nouveau grade est : "+this.menu.mng.gradeName[this.num]+"\n");
				break;
			case "briefing":
					this.box.setIllus(40+this.num);
					this.box.setText(0,"- briefing -");
					switch( this.num ){
						case 1:
							this.box.setText(1,"Votre mission est de freiner le developpement des fruits mutants jaunes qui sevissent actuellement dans le secteur d'ananas-centauri. \n");		
							break;
						case 0:
							this.box.setText(1,"Nous venons d'intercepter un message de l'ennemi. Vous allez devoir faire face à une nouvelle escouadre qualifiée \"d'explosive\" par ces démoniaques fruits mutants. Soyez très prudent !\n");	
							break;
						case 2:
							this.box.setText(1,"Selon nos services de renseignement, les fruits mutants ont commencé a construire un canon a pulpe géant d'une puissance colossale. Retrouvez-le et Détruisez-le.\n");
							break;
						case 3:
							this.box.setText(1,"L'état-major a reçu ce matin une demande de cessez-le-feu de la part des fruits mutants. Nous avons besoin d'un émissaire pour établir un contact avec eux\n");
							break;
						case 4:
							this.box.setText(1,"Une nouvelle offensive des fruits mutants a été lancé dans le secteur Sirion-Banana. Défendez au mieux la zone contre cette nouvelle vague.\n");
							break;							
					}
									
		}		
	}

//{
}