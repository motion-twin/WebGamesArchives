class fc.pan.Chat extends fc.Panel{//}
	
	// CONSTNTES
	var dp_arrow = 28;
	var dp_input = 26;
	var marginBottom:Number = 20;
	
	// MovieClip
	var inputArrow:MovieClip;
	var field:cp.MultiTextField;
	var inputField:TextField;

	
	function Chat(){
		this.init();
	}
	
	function init(){
		//_root.test+="[panChat] init()\n"
		this.title="Chat"
		super.init();
	}
		
	function display(){
		super.display();
		// MULTITEXTFIELD
		var initObj = {
			color:0xFFFFFF,
			flBold:true,
			flMask:true,
			scrollInfo:{
				link:"sbRound",
				param:{
					color:{	
						//fore:{main:0x0000FF},
						//back:{shade:0xFF0000}
						fore:{main:this.slot.col.main, shade:0xFFFFFF},
						back:{shade:this.slot.col.main, dark:0xFFFFFF}						
					},
					shadeSpace:2,
					size:14,
					margin:{top:4,side:2}
				}
			}			
		};		
		this.attachMovie("cpMultiTextField","field",100,initObj)
		this.field._y = this.marginUp+this.lineHeight
		//this.field.addText("Skool>Qu’est-ce que les Lumières ? La sortie de l’homme de sa minorité dont il est lui-même responsable. Minorité, c’est-à-dire incapacité de se servir de son entendement (pouvoir de penser) sans la direction d’autrui, minorité dont il est lui-même responsable (faute) puisque la cause en réside non dans un défaut de l’entendement mais dans un manque de décision et de courage de s’en servir sans la direction d’autrui. Sapere aude ! (Ose penser) Aie le courage de te servir de ton propre entendement. Voilà la devise des Lumières.\n")
		//this.field.addText("Deepnight>La paresse et la lâcheté sont les causes qui expliquent qu’un si grand nombre d’hommes, après que la nature les a affranchi depuis longtemps d’une (de toute) direction étrangère, reste cependant volontiers, leur vie durant, mineurs, et qu’il soit facile à d’autres de se poser en tuteur des premiers. Il est si aisé d’être mineur ! Si j’ai un livre qui me tient lieu d’entendement, un directeur qui me tient lieu de conscience, un médecin qui décide pour moi de mon régime, etc., je n’ai vraiment pas besoin de me donner de peine moi-même. Je n’ai pas besoin de penser pourvu que je puisse payer ; d’autres se chargeront bien de ce travail ennuyeux. Que la grande majorité des hommes (y compris le sexe faible tout entier) tienne aussi pour très dangereux ce pas en avant vers leur majorité, outre que c’est une chose pénible, c’est ce à quoi s’emploient fort bien les tuteurs qui très aimablement (par bonté) ont pris sur eux d’exercer une haute direction sur l’humanité. Après avoir rendu bien sot leur bétail (domestique) et avoir soigneusement pris garde que ces paisibles créatures n’aient pas la permission d’oser faire le moindre pas, hors du parc ou ils les ont enfermé. Ils leur montrent les dangers qui les menace, si elles essayent de s’aventurer seules au dehors. Or, ce danger n’est vraiment pas si grand, car elles apprendraient bien enfin, après quelques chutes, à marcher ; mais un accident de cette sorte rend néanmoins timide, et la frayeur qui en résulte, détourne ordinairement d’en refaire l’essai.\n")
		//this.field.addText("Yota>Il est donc difficile pour chaque individu séparément de sortir de la minorité qui est presque devenue pour lui, nature. Il s’y est si bien complu, et il est pour le moment réellement incapable de se servir de son propre entendement, parce qu’on ne l’a jamais laissé en faire l’essai. Institutions (préceptes) et formules, ces instruments mécaniques de l’usage de la parole ou plutôt d’un mauvais usage des dons naturels, (d’un mauvais usage raisonnable) voilà les grelots que l’on a attachés au pied d’une minorité qui persiste. Quiconque même les rejetterait, ne pourrait faire qu’un saut mal assuré par-dessus les fossés les plus étroits, parce qu’il n’est pas habitué à remuer ses jambes en liberté. Aussi sont-ils peu nombreux, ceux qui sont arrivés par leur propre travail de leur esprit à s’arracher à la minorité et à pouvoir marcher d’un pas assuré.\n")
		//this.field.addText("Warp>Mais qu’un public s’éclaire lui-même, rentre davantage dans le domaine du possible, c’est même pour peu qu’on lui en laisse la liberté, à peu près inévitable. Car on rencontrera toujours quelques hommes qui pensent de leur propre chef, parmi les tuteurs patentés (attitrés) de la masse et qui, après avoir eux-mêmes secoué le joug de la (leur) minorité, répandront l’esprit d’une estimation raisonnable de sa valeur propre et de la vocation de chaque homme à penser par soi-même. Notons en particulier que le public qui avait été mis auparavant par eux sous ce joug, les force ensuite lui-même à se placer dessous, une fois qu’il a été incité à l’insurrection par quelques-uns de ses tuteurs incapables eux-mêmes de toute lumière : tant il est préjudiciable d’inculquer des préjugés parce qu’en fin de compte ils se vengent eux-mêmes de ceux qui en furent les auteurs ou de leurs devanciers. Aussi un public ne peut-il parvenir que lentement aux lumières. Une révolution peut bien entraîner une chute du despotisme personnel et de l’oppression intéressée ou ambitieuse, (cupide et autoritaire) mais jamais une vraie réforme de la méthode de penser ; tout au contraire, de nouveaux préjugés surgiront qui serviront, aussi bien que les anciens de lisière à la grande masse privée de pensée.\n")

		// INPUTFIELD
		var tf = new TextInfo();
		tf.textFormat.color = 0xFFFFFF//0x888800
		tf.textFormat.size = 11;
		tf.textFormat.bold = true;
		tf.fieldProperty.selectable = true;
		tf.fieldProperty.type = "input"
		tf.attachField(this,"inputField",this.dp_input)
		this.inputField._height = this.marginBottom
		this.inputField._x = 18
		this.inputField.onSetFocus = function(){
			this._parent.root.keyEnterCallback = {obj:this._parent, method:"sendMessage"}
		}
		// INPUTARROW
		this.attachMovie("inputArrow","inputArrow",this.dp_arrow)
	};
	
	function update(){
		super.update();
		this.drawLine(this.size.h - this.marginBottom);	
		// MULTITEXTFIELD
		this.field.extWidth = this.size.w 
		this.field.extHeight = this.size.h - (this.marginUp + this.marginBottom + this.lineHeight*2 )
		this.field.updateSize();
		// INPUTFIELD
		this.inputField._width = this.size.w-18;
		this.inputField._y = this.size.h+2 - this.marginBottom;
		// INPUTARROW
		this.inputArrow._y = this.size.h		
	}
	
	function sendMessage(){
		//_root.test += "sendMessage\n"
		if(this.inputField.text!=""){
			var t = this.inputField.text;
			t = FEString.unHTML(t);
			this.root.manager.sendMessage(t);
		}
		this.inputField.text = "";
	}
	
	function receiveMessage(txt){
		this.field.addText(FEString.unHTML(txt))
	}
	
	
//{	
}
