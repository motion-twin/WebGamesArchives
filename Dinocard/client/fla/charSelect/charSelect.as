/********************************
 *	CARACTER SELECT 	*
 ********************************/



 function init(){


// VIGNETTES

	 confirm._visible = false;

initx = 20;	// coordonnées initiales supérieures gauches
inity = 45;

dimx = 58;	// dimension d'une vignette
dimy = 58;

espace = 5;	// espacement entre 2 vignettes

maxPlayer = 10;	// nombre de perso

maxLine = 5;	// nombre de vignettes maximum par ligne


_root.selectedP = 1;// perso par defaut
	 
domaine = _root.dom;

state = "charSelect";

pal._visible = false;

colId0 = 0;
colId1 = 0;
colId2 = 0;
colId3 = 0;

stringB = 0;

rollBox = false;

bNext.gl._visible = false;


avatarToString = 0;

clap.pan2.n.fieldPseudo.text = (clap.pan2.n.fieldPseudo.text + String(_root.userName)).toUpperCase();


// 	 createEmptyMovieClip("vign",1);
// 	 vign._x = 0;
// 	 vign._y = 0;

	 for( var i=1 ; i<=maxPlayer ; i++){

		 vign.attachMovie("vignette", "v"+i, i);
		 this["v"+i]._width = dimx;
		 this["v"+i]._height = dimy;


		 if(i>1){
			this["v"+i]._x = this["v"+(i-1)]._x + dimx + espace;
		 }else{
			 this["v"+1]._x = initx;
		}


		
		if(i >= maxLine+1){
			if(i == maxLine + 1){
				this["v"+i]._x = initx;
			}else{
				this["v"+i]._x = this["v"+(i-1)]._x + dimx + espace;
			}
	
			this["v"+i]._y = this["v"+(1)]._y + dimy + espace;
			

		}else{
			this["v"+i]._y = inity;
		}
		if(i >= maxLine*2+1){
			this["v"+i]._y = this["v"+(1)]._y + dimy*2 + espace*2;
			this["v"+i]._x = this["v"+(i-maxLine)]._x + espace;

		}
		this["v"+i].gotoAndStop(i);
	}

	attachMovie("vRoll","vRoll",100);

	vRoll._x = this["v"+_root.selectedP]._x;
	vRoll._y = this["v"+_root.selectedP]._y;


}


function main(){

// 	indic = stringB;
	
	stringB = _root.selectedP-1 + ";" + 0 + ";" + colId0 + ";" + colId1 + ";" + colId2 + ";" + colId3;
	
	vRoll._x = this["v"+_root.selectedP]._x;
	vRoll._y = this["v"+_root.selectedP]._y;


// 	for( var i=1 ; i<=maxPlayer ; i++){
// 		this["v"+i].onPress = function (){
// 			_root.selectedP = _currentframe;

// 		}
// 	}
	
// 	trace(_root.selectedP);
	
	if(rollBox){
		box._x = _xmouse + 30;
		box._y = _ymouse + 20;
	}
	

	bNext.onRelease = function(){
		
		
		if(state == "charSelect"){
			if(artwork._currentframe == 1){
				gotoColSelect();
			}
		}else{
			if(artwork._currentframe == 27){
				gotoCharSelect();
			}
		}
	}
	
	bNext.onRollOver = function(){
		bNext.gl._visible = true;
	}
	bNext.onRollOut = function(){
		bNext.gl._visible = false;
	}
	bNext.onReleaseOutside = function(){
		bNext.gl._visible = false;
	}
	


// 	setColor(pal.col3.sub.col,0xFFCC99);
// 	setColor(pal.colo,0xFFCC99);
	
	pressButton();
	valid();



}

function pressButton(){
	
	var famille = _root.selectedP - 1;
	
	// random couleurs
	pal.rand.onRollOver = function () {
		pal.rand.gotoAndStop(2);
		attachMovie("box","box",216);
		box._x = _xmouse + 30;
		box._y = _ymouse + 20;
		rollBox = true;
	}
	
	pal.rand.onRollOut = function () {
		pal.rand.gotoAndStop(1);
		box.removeMovieClip();
	}
		
	pal.rand.onPress = function () {
		resetColor();
		pal.rand.gotoAndStop(3);
		pal.circle.vit += 5;
		
	}
	
	pal.rand.onRelease = function () {
		pal.rand.gotoAndStop(1);
	}
	
	pal.rand.onReleaseOutside = function () {
		pal.rand.gotoAndStop(1);
		box.removeMovieClip();
	}
	
	// bouton 1
	pal.col0.sub.onRollOver = function () {
		pal.col0.gotoAndStop(2);
	}
	
	pal.col0.sub.onRollOut = function () {
		pal.col0.gotoAndStop(1);
	}
	
	pal.col0.sub.onPress = function () {
		pal.col0.gotoAndStop(3);
		pal.col0.sub.gotoAndPlay(2);
		colId0 ++;
		if(colId0 > palette[paltab[famille][0]].length -1){
			colId0 = 0;
		}
		applyColors();
	}
	
	pal.col0.sub.onRelease = function () {
		pal.col0.gotoAndStop(1);
	}
	
	pal.col0.sub.onReleaseOutside = function () {
		pal.col0.gotoAndStop(1);
	}
	
	// bouton 2
	pal.col1.sub.onRollOver = function () {
		pal.col1.gotoAndStop(2);
	}
	
	pal.col1.sub.onRollOut = function () {
		pal.col1.gotoAndStop(1);
	}
	
	pal.col1.sub.onPress = function () {
		pal.col1.gotoAndStop(3);
		pal.col1.sub.gotoAndPlay(2);
		colId1 ++;
		if(colId1 > palette[paltab[famille][1]].length -1){
			colId1 = 0;
		}
		applyColors();
	}
	
	pal.col1.sub.onRelease = function () {
		pal.col1.gotoAndStop(1);
	}
	
	pal.col1.sub.onReleaseOutside = function () {
		pal.col1.gotoAndStop(1);
	}
	
	// bouton 3
	pal.col2.sub.onRollOver = function () {
		pal.col2.gotoAndStop(2);
	}
	
	pal.col2.sub.onRollOut = function () {
		pal.col2.gotoAndStop(1);
	}
	
	pal.col2.sub.onPress = function () {
		pal.col2.gotoAndStop(3);
		pal.col2.sub.gotoAndPlay(2);
		colId2 ++;
		if(colId2 > palette[paltab[famille][2]].length -1){
			colId2 = 0;
		}
		applyColors();
	}
	
	pal.col2.sub.onRelease = function () {
		pal.col2.gotoAndStop(1);
	}
	
	pal.col2.sub.onReleaseOutside = function () {
		pal.col2.gotoAndStop(1);
	}
	
	// bouton 4
	pal.col3.sub.onRollOver = function () {
		pal.col3.gotoAndStop(2);
	}
	
	pal.col3.sub.onRollOut = function () {
		pal.col3.gotoAndStop(1);
	}
	
	pal.col3.sub.onPress = function () {
		pal.col3.gotoAndStop(3);
		pal.col3.sub.gotoAndPlay(2);
		colId3 ++;
		if(colId3 > palette[paltab[famille][3]].length -1){
			colId3 = 0;
		}
		applyColors();
	}
	
	pal.col3.sub.onRelease = function () {
		pal.col3.gotoAndStop(1);
	}
	
	pal.col3.sub.onReleaseOutside = function () {
		pal.col3.gotoAndStop(1);
	}
}

function valid(){
	
	// VALID
	clap.pan2.valid.onRollOver = function () {
		clap.pan2.valid.gotoAndStop(2);
	}
	clap.pan2.valid.onRollOut = function () {
		clap.pan2.valid.gotoAndStop(1);
	}
	
	clap.pan2.valid.onRelease = function () {
		confirm._visible = true;
		artwork.gotoAndPlay("confirm");
	}
	
	// OUI
	confirm.box.oui.onRollOver = function () {
		confirm.box.oui.gotoAndStop(2);
	}
	confirm.box.oui.onRollOut = function () {
		confirm.box.oui.gotoAndStop(1);
	}
	confirm.box.oui.onRelease = function () {
		confirm.gotoAndPlay(2);
		
		
		var lv = new LoadVars();
		lv.perso = stringB;
		lv.send(domaine + "/user/signUpDone","_self","POST");
	}
	
	// NON
	confirm.box.non.onRollOver = function () {
		confirm.box.non.gotoAndStop(2);
	}
	confirm.box.non.onRollOut = function () {
		confirm.box.non.gotoAndStop(1);
	}
	confirm.box.non.onRelease = function () {
		if(artwork._currentframe == 38){
			confirm._visible = false;
			artwork.gotoAndPlay("retry");
		}
	}
	
	// UNDO (clique sur la zone autour, meme action que non)

	confirm.undo.onRelease = function () {
		if(artwork._currentframe == 38){
			confirm._visible = false;
			artwork.gotoAndPlay("retry");
		}
	}
	
}

function applyColors(){

	var famille = _root.selectedP - 1;
	
	for(var i = 0 ; i <= 3 ; i++){
// 		setColor(pal.col0.sub.col,palette[famille][1])
		
		// setcolor sur les boutons
		setColor(pal.col0.sub.col,palette[paltab[famille][0]][colId0])
		setColor(pal.col0.sub2.col,palette[paltab[famille][0]][colId0])
		setColor(pal.col1.sub.col,palette[paltab[famille][1]][colId1])
		setColor(pal.col1.sub2.col,palette[paltab[famille][1]][colId1])
		setColor(pal.col2.sub.col,palette[paltab[famille][2]][colId2])
		setColor(pal.col2.sub2.col,palette[paltab[famille][2]][colId2])
		setColor(pal.col3.sub.col,palette[paltab[famille][3]][colId3])
		setColor(pal.col3.sub2.col,palette[paltab[famille][3]][colId3])
		
		
		// setcolor sur les artworks
		setColor(artwork.n.gfx.col0,palette[paltab[famille][0]][colId0])
		setColor(artwork.n.gfx2.col0,palette[paltab[famille][0]][colId0])
		
		setColor(artwork.n.gfx.col1,palette[paltab[famille][1]][colId1])
		setColor(artwork.n.gfx2.col1,palette[paltab[famille][1]][colId1])
		
		setColor(artwork.n.gfx.col2,palette[paltab[famille][2]][colId2])
		setColor(artwork.n.gfx2.col2,palette[paltab[famille][2]][colId2])
		
		setColor(artwork.n.gfx.col3,palette[paltab[famille][3]][colId3])
		setColor(artwork.n.gfx2.col3,palette[paltab[famille][3]][colId3])

		
	}
	
}

function gotoColSelect(){


	// tranforme la fenetre en selection des couleurs

	state = "colSelect";
	clap.gotoAndPlay("colSelect");
	artwork.gotoAndPlay("colSelect");
	bNext.gotoAndPlay("colSelect");
	bg.gotoAndPlay("colSelect");
	
	title.s1.gotoAndPlay("persToCol");
	title.s2.gotoAndPlay("persToCol");
	
	title2.s1.gotoAndPlay("persToCol");
	title2.s2.gotoAndPlay("persToCol");



	for( var i=1 ; i<=maxPlayer ; i++){

		this["v"+i]._visible = false;

	}
	gBox._visible = false;
	vRoll._visible = false;
	desc._visible = false;
	
// 	pal._visible = true;
}



function gotoCharSelect(){

	// tranforme la fenetre en choix du perso

	state = "charSelect";
	clap.gotoAndPlay("charSelect");
	artwork.gotoAndPlay("charSelect");
	bNext.gotoAndPlay("charSelect");
	bg.gotoAndPlay("charSelect");
	
	title.s1.gotoAndPlay("colToPers");
	title.s2.gotoAndPlay("colToPers");
	
	title2.s1.gotoAndPlay("colToPers");
	title2.s2.gotoAndPlay("colToPers");
	
// 	if(clap._currentframe >= 52){
		

		for( var i=1 ; i<=maxPlayer ; i++){

			this["v"+i]._visible = true;

		}
		gBox._visible = true;
		vRoll._visible = true;
		desc._visible = true;
		pal._visible = false;
// 	}


}


//PALETTE


paltab = [
	[0,1,2,3],
	[0,1,2,3],
	[4,5,5,5],
	[8,8,10,10],
	[4,5,12,12],
	[4,5,5,5],
	[13,14,15,16],
	[4,5,5,5],
	[0,1,2,16],
	[0,1,2,3]

// 3 2 0 10

]

function resetColor(){
	
	var famille = _root.selectedP - 1;
	
	
	switch(_root.selectedP){
		
		case 1 : 
		// MILO
		var id1 = random(palette[paltab[famille][0]].length);
		var id2 = random(palette[paltab[famille][1]].length);
		var id3 = random(palette[paltab[famille][2]].length);
		var id4 = random(palette[paltab[famille][3]].length);
		resetColApply(id1,id2,id3,id4);
		break; 
		
		case 2 : 
		// PATMOS
		var id1 = random(palette[paltab[famille][0]].length);
		var id2 = random(palette[paltab[famille][1]].length);
		var id3 = random(palette[paltab[famille][2]].length);
		var id4 = random(palette[paltab[famille][3]].length);
		resetColApply(id1,id2,id3,id4);
		break; 
		
		case 3 :
		// SIMEON
		var id1 = random(palette[paltab[famille][0]].length);
		var id2 = random(palette[paltab[famille][1]].length);
		var id3 = random(palette[paltab[famille][2]].length);
		var id4 = random(palette[paltab[famille][3]].length);
		resetColApply(id1,id2,id3,id4);
		break; 
		
		case 4 :
		// APOSTOPH
		var id1 = random(palette[paltab[famille][0]].length);
		var id2 = random(palette[paltab[famille][1]].length);
		var id3 = random(palette[paltab[famille][2]].length);
		var id4 = random(palette[paltab[famille][3]].length);
		resetColApply(id1,id2,id3,id4);
		break; 
		
		case 5 :
		// ISADORA
		var id1 = random(palette[paltab[famille][0]].length);
		var id2 = random(palette[paltab[famille][1]].length);
		var id3 = random(palette[paltab[famille][2]].length);
		var id4 = random(palette[paltab[famille][3]].length);
		resetColApply(id1,id2,id3,id4);
		break; 
		
		case 6 :
		// MATHIAS
		var id1 = random(palette[paltab[famille][0]].length);
		var id2 = random(palette[paltab[famille][1]].length);
		var id3 = random(palette[paltab[famille][2]].length);
		var id4 = random(palette[paltab[famille][3]].length);
		resetColApply(id1,id2,id3,id4);
		break; 
		
		case 7 :
		// SHUN
		var id1 = random(palette[paltab[famille][0]].length);
		var id2 = random(palette[paltab[famille][1]].length);
		var id3 = random(palette[paltab[famille][2]].length);
		var id4 = random(palette[paltab[famille][3]].length);
		resetColApply(id1,id2,id3,id4);
		break; 
		
		case 8 :
		// CHRONOPAUL
		var id1 = random(palette[paltab[famille][0]].length);
		var id2 = random(palette[paltab[famille][1]].length);
		var id3 = random(palette[paltab[famille][2]].length);
		var id4 = random(palette[paltab[famille][3]].length);
		resetColApply(id1,id2,id3,id4);
		break; 
		
		case 9 :
		// TOASTERON
		var id1 = random(palette[paltab[famille][0]].length);
		var id2 = random(palette[paltab[famille][1]].length);
		var id3 = random(palette[paltab[famille][2]].length);
		var id4 = random(palette[paltab[famille][3]].length);
		resetColApply(id1,id2,id3,id4);
		break; 
		
		case 10 :
		// HEMILIO
		var id1 = random(palette[paltab[famille][0]].length);
		var id2 = random(palette[paltab[famille][1]].length);
		var id3 = random(palette[paltab[famille][2]].length);
		var id4 = random(palette[paltab[famille][3]].length);
		resetColApply(id1,id2,id3,id4);
		break; 
	}
	
	
	
}

function resetColApply(id1,id2,id3,id4){
	
	var famille = _root.selectedP - 1;
	
	setColor(pal.col0.sub.col,palette[paltab[famille][0]][id1])
	setColor(pal.col0.sub2.col,palette[paltab[famille][0]][id1])
	setColor(pal.col1.sub.col,palette[paltab[famille][1]][id2])
	setColor(pal.col1.sub2.col,palette[paltab[famille][1]][id2])
	setColor(pal.col2.sub.col,palette[paltab[famille][2]][id3])
	setColor(pal.col2.sub2.col,palette[paltab[famille][2]][id3])
	setColor(pal.col3.sub.col,palette[paltab[famille][3]][id4])
	setColor(pal.col3.sub2.col,palette[paltab[famille][3]][id4])
	
	
	setColor(artwork.n.gfx.col0,palette[paltab[famille][0]][id1])
	setColor(artwork.n.gfx2.col0,palette[paltab[famille][0]][id1])
	
	setColor(artwork.n.gfx.col1,palette[paltab[famille][1]][id2])
	setColor(artwork.n.gfx2.col1,palette[paltab[famille][1]][id2])
	
	setColor(artwork.n.gfx.col2,palette[paltab[famille][2]][id3])
	setColor(artwork.n.gfx2.col2,palette[paltab[famille][2]][id3])
	
	setColor(artwork.n.gfx.col3,palette[paltab[famille][3]][id4])
	setColor(artwork.n.gfx2.col3,palette[paltab[famille][3]][id4])
	
	colId0 = id1;
	colId1 = id2;
	colId2 = id3;
	colId3 = id4;	
}

function setColor(mc,col){
	var c = {
		r:col>>16,
		g:(col>>8)&0xFF,
		b:col&0xFF
	}
	var co = new Color(mc);

	var ct = {
		ra:100,
		ga:100,
		ba:100,
		aa:100,
		rb:c.r-255,
		gb:c.g-255,
		bb:c.b-255,
		ab:0
	}
	co.setTransform( ct );
}

//PALETTES
//{
	palette = [
		/*0xFFFFFF,
		0xFFFFCC,
		0xCCDBFB,
		0xFFFF00,
		0xFFCC00,
		0xFF8800,
		0x88FF00,
		0x44FFDD,
		0x22DDFF,
		0xAAAA44,
		0xCC2288,
		0xFF66FF
		*/
	
		// SAUVAGES
	
		[	// 0 - peau sauvages
			0xFBBF84,
			0xFF996F,
			0xFFAA1E,
			0xE69866,
			0xC07403,
			0xBC5F21,
			0xEAB49D
	
		],
		[	// 1 - cheveux sauvages
			0xFFCC79,
			0xBA9501,
			0xFFCC99,
			0xB7A404,
			0xFDEDD7,
			0xC10202
	
		],
		[	// 2 - accessoire 1, yeux sauvages
			0xFFF2DF,
			0xFFCC79,
			0xFFAA1E,
			0xECFFD9,
			0xCBFF97,
			0xD5EAFF,
			0x97CBFF,
			0x8BA3D7,
			0xDF7E37,
			0xB85F1D,
			0xD31818,
			0xFFF9AE,
			0xF0DC99
		],
		[	// 3 - accessoire 2 sauvages
			0xFFF2DF,
			0xFFCC79,
			0xFFAA1E,
			0xECFFD9,
			0xCBFF97,
			0xD5EAFF,
			0x97CBFF,
			0x8BA3D7,
			0xDF7E37,
			0xB85F1D,
			0xD31818,
			0xFFF9AE,
			0xF0DC99
		],
	
		// URBAINS
	
		[	// 4 - peau urbains
			0xF5C9AB,
			0xF5C0B4,
			0xDFAC97,
			0xE3BA93,
			0xEDB8A3,
			0xC69A7D
	
		],
		[	// 5 - cheveux urbains
			0xEADAD0,
			0xB0754F,
			0x95776A,
			0xEA9D6A,
			0xA5A7B8,
			0xB1ACCA,
			0xEDA55F,
			0xBFCAD9,
			0xF0DC99,
			0x1F9471,
			0xFCCFE6,
			0x0984A2
		],
		[	// 6 - accessoire 1, yeux urbains
			0xFDEDD7,
			0x475AA7,
			0x8792BC,
			0xC77C7C,
			0xEA9DB5,
			0x9B5A31,
			0xECC160,
			0x7182C1
	
		],
		[	// 7 - accessoire 2 urbains
			0xFDEDD7,
			0xFFCC79,
			0xFFAA1E,
			0xECFFD9,
			0xCBFF97,
			0xD5EAFF,
			0x97CBFF,
			0x8BA3D7,
			0xDF7E37,
			0xB85F1D,
			0xD31818,
			0xFFF9AE,
			0xFFCCFF,
			0xF0DC99
		],
	
		// ATLANTES
	
		[	// 8 - peau
			0xD8D5DD,
			0xA3A6BA,
			0x9FBDB4,
			0x86ACA0,
			0xB1C8E7,
			0x92B0DC
	
		],
		[	// 9 - nageoires
			0xEADAD0,
			0xB0754F,
			0x95776A,
			0xEA9D6A,
			0xA5A7B8,
			0xB1ACCA,
			0xF0DC99
		],
		[	// 10 - accessoire 1
			0xFFF2DF,
			0xFFCC79,
			0xFFAA1E,
			0xECFFD9,
			0xCBFF97,
			0xD5EAFF,
			0x97CBFF
	
		],
		[	// 11 - accessoire 2
			0xFDEDD7,
			0xFFCC79,
			0xFFAA1E,
			0xECFFD9,
			0xCBFF97,
			0xD5EAFF,
			0x97CBFF,
			0x8BA3D7,
			0xDF7E37,
			0xB85F1D,
			0xD31818,
			0xFFF9AE,
			0xF0DC99
		],
		[	// 12 - accessoire filles
	
			0xFFCCFF,
			0xFFE6FF,
			0xEAE6FF,
			0xECFFD9,
			0xCBFF97,
			0xD5EAFF,
			0x97CBFF,
			0xDF7E37,
	
			0xFFF9AE
		],
		// ATLANTE SHUN
	
		[	// 13 - peau
			0xD3C9E0,
			0xF2E1E1,
			0xE3BDBE,
			0xF4EEDF,
			0xE8D9B9,
			0xC8E9B8,
			0xE0F3D8,
			0xC1AED5
	
		],
		[	// 14 - nageoires
			0xB7CDC6,
			0xB75348,
			0xF0DC99,
			0xF6F6D9,
			0xDDE4FF,
			0xB4C4FE,
			0xE1FFDD,
			0xABFFA2,
			0xFFDDDD,
			0xFFC4C4,
			0xFCCFE6,
			0xF0DC99
		],
		[	// 15 - cheveux
			0xB187A4,
			0xA26F93,
			0xA26F93,
			0x9DBFB1,
			0x97CBFF
	
		],
		[	// 16 - nuage
			0xF6F6D9,
			0xDDE4FF,
			0xB4C4FE,
			0xE1FFDD,
			0xABFFA2,
			0xFFDDDD,
			0xFFC4C4,
			0xFCCFE6,
			0xFFEEAA
		]
	
	];
//}

