import Types;

class WinAppOptions extends WinApp {
	var ls				: LocalSettings;
	var sensField		: MCField;
	var capField		: MCField;
	var shortcutButtons	: Array<MCField>;
	var capture			: Int;

	public function new(t) {
		super(t);
		shortcutButtons = new Array();
		capture = null;
		setTitle("local_settings");
	}

	override public function start() {
		super.start();

		ls = term.ls;

		scrollUp._visible = false;
		scrollDown._visible = false;

		// sensibilité souris
		addField(sdm, 10,10, Lang.get.OptSensitivity);
		addButton(sdm, 10,30, "<", callback(sensitivy,-1));
		sensField = addField(sdm, 40,30, "??", false);
		addButton(sdm, 70,30, ">", callback(sensitivy,1));

		// raccourcis
		capField = addField(sdm, 10,200, Lang.get.OptCapture, false );
		capField.field.multiline = true;
		capField.field.wordWrap = true;
		capField.field._width = wid-20;
		capField.field._height = 70;

		addField(sdm, 10,70, Lang.get.OptShortcuts);
		var i = 0;
		var x = 0;
		var y = 0;
		for (s in ls.shortcuts) {
			addField(sdm, 30+x*75,90+y*55, "Virus "+(i+1), false);
			var mc = addButton(sdm, 30 + x*75, 110+y*55, "NUMPAD 5", callback(onShortcut,i) );
			mc.smc._width = mc.field._width+5;
			shortcutButtons.push(mc);
			x++;
			if ( x>=5 ) {
				x = 0;
				y++;
			}
			i++;
		}

		addButton(sdm, 10,hei-30, Lang.get.OptReset, onReset);

		updateView();
	}

	override public function stop() {
		term.saveSettings(ls);
		super.stop();
	}

	function sensitivy(delta:Int) {
		if ( delta<0 && ls.wheelSpeed<=1 )
			return;
		if ( delta>0 && ls.wheelSpeed>=20 )
			return;
		ls.wheelSpeed += delta;
		term.startAnim( A_Blink, sensField );
		updateView();
	}

	function onReset() {
		term.saveSettings(null, false);
		ls = term.loadSettings();
		capture = null;
		updateView();
	}

	function onShortcut(i:Int) {
		capture = i;
		updateView();
	}

	override function onKey(c) {
		if ( capture!=null ) {
			if ( c!=flash.Key.ESCAPE )
				ls.shortcuts[capture] = c;
			term.startAnim( A_Blink, shortcutButtons[capture].smc );
			capture = null;
			updateView();
		}
		else
			super.onKey(c);
	}


	function updateView() {
		sensField.field.text = Data.leadingZeros(ls.wheelSpeed);
		capField._visible = capture!=null;
		var keyNames = getKeyNames();
		var i = 0;
		for (mc in shortcutButtons) {
			mc.field.text = keyNames[ls.shortcuts[i]];
			i++;
		}
	}

	override public function update() {
		super.update();
	}

	function getKeyNames(?lang="fr") {
		var keyNames_US = new Array() ;
		var keyNames_FR = new Array() ;

		// Premier passage pour remplir de "?"
//		for (i=0;i<256;i++) {
		for (i in 0...256) {
			keyNames_US[i]="?" ;
			keyNames_FR[i]="?" ;
		}

		// Les lettres normales
//		for (i=65;i<=90;i++) {
		for (i in 65...91) {
			keyNames_US[i]=String.fromCharCode(i) ;
			keyNames_FR[i]=String.fromCharCode(i) ;
		}

		// Les chiffres
//		for (i=48;i<=57;i++) {
		for (i in 48...58) {
			keyNames_US[i]=String.fromCharCode(i) ;
			keyNames_FR[i]=String.fromCharCode(i) ;
		}

		// Les chiffres du pavé numérique
//		for (i=96;i<=105;i++) {
		for (i in 96...106) {
			keyNames_US[i]="NumPad "+(i-96) ;
			keyNames_FR[i]="PavNum "+(i-96) ;
		}

		// Touches spéciales du pavé
		keyNames_US[106]="NumPad *" ;
		keyNames_US[107]="NumPad +" ;
		keyNames_US[108]="NumPad Enter" ;
		keyNames_US[109]="NumPad -" ;
		keyNames_US[110]="NumPad Del" ;
		keyNames_US[111]="NumPad /" ;
		keyNames_FR[106]="PavNum *" ;
		keyNames_FR[107]="PavNum +" ;
		keyNames_FR[108]="PavNum Entrée" ;
		keyNames_FR[109]="PavNum -" ;
		keyNames_FR[110]="PavNum Suppr" ;
		keyNames_FR[111]="PavNum /" ;

		// Touches de fonction
//		for (i=112;i<=123;i++) {
		for (i in 112...124) {
			keyNames_US[i]= "F " + (i-111) ;
			keyNames_FR[i]= "F " + (i-111) ;
		}

		// La partie lourde: tout le reste !
		keyNames_FR[1]="Mouse left" ;
		keyNames_FR[2]="Mouse right" ;
		keyNames_FR[4]="Mouse middle" ;
		keyNames_US[8]="Backspace " ;
		keyNames_US[9]="TAB " ;
		keyNames_US[12]="Delete " ;
		keyNames_US[13]="Return " ;
		keyNames_US[16]="Shift " ;
		keyNames_US[17]="Control " ;
		keyNames_US[18]="Alt " ;
		keyNames_US[20]="CapsLock " ;
		keyNames_US[27]="Escape " ;
		keyNames_US[32]="Spacebar " ;
		keyNames_US[33]="Page up" ;
		keyNames_US[34]="Page down" ;
		keyNames_US[35]="End " ;
		keyNames_US[36]="Home " ;
		keyNames_US[37]="Left " ;
		keyNames_US[38]="Up " ;
		keyNames_US[39]="Right " ;
		keyNames_US[40]="Down " ;
		keyNames_US[45]="Insert " ;
		keyNames_US[46]="Delete " ;
		keyNames_US[47]="Help " ;
		keyNames_US[144]="VerrNum " ;
		keyNames_US[186]="; :" ;
		keyNames_US[187]="= +" ;
		keyNames_US[189]="- _" ;
		keyNames_US[191]="/ ?" ;
		keyNames_US[192]="~" ;
		keyNames_US[219]="[ {" ;
		keyNames_US[220]="\\ |" ;
		keyNames_US[221]="] }" ;
		keyNames_US[222]="\" '" ;

		keyNames_FR[1]="Souris gauche" ;
		keyNames_FR[2]="Souris droite" ;
		keyNames_FR[4]="Souris milieu" ;
		keyNames_FR[8]="Retour " ;
		keyNames_FR[9]="TAB " ;
		keyNames_FR[12]="Supprimer " ;
		keyNames_FR[13]="Entrée " ;
		keyNames_FR[16]="Majuscule " ;
		keyNames_FR[17]="Controle " ;
		keyNames_FR[18]="Alt " ;
		keyNames_FR[20]="Verr.Maj." ;
		keyNames_FR[27]="Echappe " ;
		keyNames_FR[32]="Espace " ;
		keyNames_FR[33]="Page préc." ;
		keyNames_FR[34]="Page suiv." ;
		keyNames_FR[35]="Fin " ;
		keyNames_FR[36]="Début " ;
		keyNames_FR[37]="Gauche " ;
		keyNames_FR[38]="Haut " ;
		keyNames_FR[39]="Droite " ;
		keyNames_FR[40]="Bas " ;
		keyNames_FR[45]="Insérer" ;
		keyNames_FR[46]="Supprimer " ;
		keyNames_FR[47]="Aide " ;
		keyNames_FR[144]="VerrNum " ;
		keyNames_FR[186]="$ £" ;
		keyNames_FR[187]="= +" ;
		keyNames_FR[189]="- _" ;
		keyNames_FR[191]=": /" ;
		keyNames_FR[192]="ù %" ;
		keyNames_FR[219]="° )" ;
		keyNames_FR[220]="* µ" ;
		keyNames_FR[221]="^ ¨" ;
		keyNames_FR[222]="²" ;

		if ( lang.toLowerCase()=="fr" )
			return keyNames_FR;
		else
			return keyNames_US;
	}
}