package data;

import ods.Data;


typedef Resource = {
	var id : String;
	var qty : Int;
}

typedef DataBuilding = {
	var drop : data.Drop;
	var id : Int;
	var key : String;
	var parent : Null<String>;
	var nom : String;
	//var isNew : ModsCheck;
	var isDef : OdsSkip<Bool>;
	var isTmp : OdsCheck;
	var isUnbreakable : OdsCheck;
	var PA : Int;
	var def : Int;
	var mod : Null<String>;
	var bois1 : Null<Int>;
	var bois2 : Null<Int>;
	var metal1 : Null<Int>;
	var metal2 : Null<Int>;
	var beton : Null<Int>;
	var vis	: Null<Int>;
	var eau : Null<Int>;
	var tole : Null<Int>;
	var tube : Null<Int>;
	var electro : Null<Int>;
	var explo : Null<Int>;
	//var itemDef: Null<Int>;
	var _raw : Null<String>;
	//realise en post process
	var resources : OdsSkip<List<Resource>>;
	// a realiser en post process en recuperant ces donnees depuis des locale xml
	//var description : ModsSkip<String>;
	//a renseigner en post process avec le fichier cityUpgrades dont les noeuds possèdent l'attribut parent égal a key.
	//var hasLevels : ModsSkip<Bool>;
	//var icon : String; TODO en post process aussi
}
