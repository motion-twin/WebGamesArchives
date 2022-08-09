package data;

import data.LevelDesign;
import mt.data.GetText;
import ui.Button;

/**
 * ...
 * @author Tipyx
 */

enum TypePopUp {
	TPOptions;
	TPPause;
	TPCollection;
	TPNotifications;
	TPMoreLifes;
	TPAskYourFriends;
	TPLevel;
	TPEndLoose;
	TPEndWin;
	TPNoMoreMoves;
	TPBoughtPickaxe;
	TPShop;
	TPAskLog;
	TPPlayMobile;
	TPInviteFriends;
}

enum TypeVarious {
	TVClickToBegin;
	TVTouchToBegin;
	TVChoosePlanet;
	TVComingSoon;
	TVAskBoughtLife;
	TVAskYourFriends;
	TVSelectUnselectAll;
	TVNextLife;
	TVGoal;
	TVGoalScore;
	TVGoalCollect;
	TVGoalGelat;
	TVGoalMercure;
	TVPoints;
	TVIfSucceed;
	TVMoreMoves;
	TVNoNotif;
	TVLoading;
	TVNoGiveUp;
	TVLootGet;
	TVOneMoreLife;
	TVYouHave;
	TVGotoShop;
	TVFree;
	TVFreeFirstLevel;
	TVOtherPayment;
	TVReloadGame;
	TVLoggedAs;
	TVBenef;
	TVSave;
	TVAchiev;
	TVFriend;
	TVForum;
	TVPlayMobile;
	TVGameAvailable;
	TVGetGold;
	TVMoreLifes;
	TVGiveLifes;
	TVNewLife;
	TVMiss;
	TVMe;
}

enum TypeSocial {
	TSReqAskLife;
	TSReqGiveLife;
	TSAsk(n:String);
	TSAsks(n:Int);
	TSGive(n:String);
	TSGives(n:Int);
	TSReqInvite;
}

class Lang
{
	public static var LANG = "en";
	public static var T : GetText;

	public static function INIT(l:String) {
		if( l.length == 2 && Lambda.has( haxe.Resource.listNames(), l ) )
			LANG = l;
		#if parseGetText
		GetText.parse("src","lang/client.pot", "lang/client.en.po");
		#end
		T = new GetText();
		T.readMo( haxe.Resource.getBytes(LANG) );
	}
	
	public static function GET_BUTTON(tb:TypeButton):String {
		return switch(tb) {
			case TypeButton.TBAsk :			T._("Demander");
			case TypeButton.TBAskToFriend : T._("Demander à mes amis");
			case TypeButton.TBContinue :    T._("Continuer");
			case TypeButton.TBRefill :    	T._("Recharger maintenant");
			case TypeButton.TBGiveUp :      T._("Abandonner");
			case TypeButton.TBHome :        T._("Carte du monde");
			case TypeButton.TBMobo :        T._("Télécharger la musique");
			case TypeButton.TBMusic :       T._("Musique");
			case TypeButton.TBNext :        T._("Suivant");
			case TypeButton.TBPlay :        T._("Jouer");
			case TypeButton.TBResume :      T._("Reprendre");
			case TypeButton.TBRetry :       T._("Réessayer");
			case TypeButton.TBSound :       T._("Son");
			case TypeButton.TBShop :		T._("Boutique");
			case TypeButton.TBReload :		T._("Recharger le jeu");
			case TypeButton.TBLogOut :		T._("Se déconnecter");
			case TypeButton.TBLogIn :		T._("Se connecter");
			case TypeButton.TBLater :		T._("Plus tard");
			case TypeButton.TBHint :		T._("Aide visuelle");
			case TypeButton.TBInvite :		T._("inviter des amis");
		}
	}
	
	public static function GET_POPUP_TITLE(tp:TypePopUp):String {
		return switch(tp) {
			case TypePopUp.TPAskYourFriends :	T._("Demander à mes amis");
			case TypePopUp.TPBoughtPickaxe :	T._("Plus de pioches !");
			case TypePopUp.TPCollection :		T._("Collection");
			case TypePopUp.TPEndLoose :			T._("Vie perdue !");
			case TypePopUp.TPEndWin :			T._("Félicitations !");
			case TypePopUp.TPLevel :			T._("Niveau");
			case TypePopUp.TPMoreLifes :		T._("Plus de vies");
			case TypePopUp.TPNoMoreMoves :		T._("Plus de coups !");
			case TypePopUp.TPNotifications :	T._("Notifications");
			case TypePopUp.TPOptions :			T._("Options");
			case TypePopUp.TPPause :			T._("Pause");
			case TypePopUp.TPShop :				T._("Boutique");
			case TypePopUp.TPAskLog :			T._("Connectez vous !");
			case TypePopUp.TPPlayMobile :		T._("Jouez sur mobile !");
			case TypePopUp.TPInviteFriends :	T._("Inviter mes amis");
		}
	}
	
	public static function GET_VARIOUS(tv:TypeVarious):String {
		return switch (tv) {
			case TypeVarious.TVClickToBegin :		T._("Cliquez pour commencer");
			case TypeVarious.TVTouchToBegin :		T._("Touchez pour commencer");
			case TypeVarious.TVChoosePlanet :		T._("Choisissez une planète");
			case TypeVarious.TVComingSoon :			T._("Bientôt disponible");
			case TypeVarious.TVAskBoughtLife :		T._("Demandez à vos amis des vies supplémentaires ou faites le plein tout de suite !");
			case TypeVarious.TVAskYourFriends :		T._("Demandez à vos amis des vies supplémentaires !");
			case TypeVarious.TVSelectUnselectAll :	T._("Sélectionner/Désélectionner tous");
			case TypeVarious.TVNextLife :			T._("Prochaine vie");
			case TypeVarious.TVGoal :				T._("Objectif");
			case TypeVarious.TVGoalScore :			T._("Objectif :\nAtteignez ce score");
			case TypeVarious.TVGoalCollect :		T._("Objectif :\nCollectez tout ces éléments");
			case TypeVarious.TVGoalGelat :			T._("Objectif :\nÉliminez tout l'or");
			case TypeVarious.TVGoalMercure :		T._("Objectif :\nÉtalez tout le ciment");
			case TypeVarious.TVIfSucceed :			T._("Gagnez ce niveau pour l'ajouter à votre collection !");
			case TypeVarious.TVMoreMoves :			T._("Voulez vous des coups supplémentaires ?");
			case TypeVarious.TVNoNotif :			T._("Pas de messages !");
			case TypeVarious.TVLoading :			T._("Chargement !");
			case TypeVarious.TVNoGiveUp :			T._("Courage ! N'abandonnez pas !");
			case TypeVarious.TVLootGet :			T._("Trésors déterrés");
			case TypeVarious.TVPoints :				T._("Points");
			case TypeVarious.TVOneMoreLife :		T._("6 vies max dès le premier achat !");
			case TypeVarious.TVYouHave :			T._("Vous avez");
			case TypeVarious.TVGotoShop :			T._("Vous n'avez pas assez de pièces d'or, faites un tour à la boutique si vous en voulez plus !");
			case TypeVarious.TVFree :				T._("Pour cette fois-ci, c'est gratuit !");
			case TypeVarious.TVFreeFirstLevel :		T._("Pour les premiers niveaux, c'est gratuit !");
			case TypeVarious.TVOtherPayment :		T._("Autres moyens de paiement ?");
			case TypeVarious.TVReloadGame :			T._("Une erreur s'est produite. Veuillez recharger le jeu, s'il vous plaît.");
			case TypeVarious.TVLoggedAs :			T._("Connecté en tant que");
			case TypeVarious.TVBenef :				T._("Et bénéficiez de nombreux avantages !");
			case TypeVarious.TVSave :				T._("- Sauvegardez votre progression !");
			case TypeVarious.TVAchiev :				T._("- Collectionnez tous les titres !");
			case TypeVarious.TVFriend :				T._("- Comparez votre avancée \nà celle de vos amis !");
			case TypeVarious.TVForum :				T._("- Participez aux forums \navec d'autres joueurs !");
			case TypeVarious.TVPlayMobile :			T._("jouez sur mobile et gagnez 250");
			case TypeVarious.TVGameAvailable :		T._("- Votre jeu préféré disponible\npartout avec vous !");
			case TypeVarious.TVGetGold :			T._("- Gagnez 250 pièces de plus !");
			case TypeVarious.TVMoreLifes :			T._("- Bénéficiez de 2 fois plus de vie !");
			case TypeVarious.TVGiveLifes :			T._("N'hésitez pas à donner des vies à vos amis, cela ne consommera pas les vôtres !");
			case TypeVarious.TVNewLife :			T._("Nouvelle vie disponible !");
			case TypeVarious.TVMiss :				T._("Il vous manque juste");
			case TypeVarious.TVMe :					T._("Moi");
		}
	}
	
	public static function GET_SOCIAL(ts:TypeSocial):String {
		return switch (ts) {
			case TypeSocial.TSReqAskLife	: T._("Peux tu me donner une vie, s'il te plaît ?");
			case TypeSocial.TSReqGiveLife	: T._("Voilà une vie pour toi :)");
			case TypeSocial.TSAsk(n)		: T._("::n:: a besoin d'une vie, voulez-vous l'aider ?", {n:n});
			case TypeSocial.TSAsks(n)		: T._("::n:: amis ont besoin d'une vie, voulez-vous les aider ?", {n:n});
			case TypeSocial.TSGive(n)		: T._("::n:: vous a donné une vie, voulez-vous la récupérer ?", {n:n});
			case TypeSocial.TSGives(n)		: T._("Ces ::n:: amis vous ont envoyé une vie, voulez-vous les récupérer ?", {n:n});
			case TypeSocial.TSReqInvite		: T._("vous invite à creuser avec lui vers le centre de la terre !");
		}
	}
	
	public static function GET_FAMILYLOOT(fl:FamilyLoot) {
		return switch (fl) {
			case FamilyLoot.FLAnimal		: T._("Bestioles");
			case FamilyLoot.FLAnime			: T._("animés");
			case FamilyLoot.FLCocktail		: T._("Cocktails");
			case FamilyLoot.FLDragon		: T._("Draconis");
			case FamilyLoot.FLFood			: T._("Gourmands");
			case FamilyLoot.FLFossil		: T._("Fossilisés");
			case FamilyLoot.FLFrozen		: T._("Gelés");
			case FamilyLoot.FLFruit			: T._("Fruités");
			case FamilyLoot.FLGame			: T._("Gamers");
			case FamilyLoot.FLGear			: T._("Machina");
			case FamilyLoot.FLHat			: T._("Chapeautés");
			case FamilyLoot.FLHelmet		: T._("Casqués");
			case FamilyLoot.FLIcecream		: T._("Glacés");
			case FamilyLoot.FLLoot			: T._("Surprises");
			case FamilyLoot.FLMatter		: T._("Materiaux");
			case FamilyLoot.FLMush			: T._("Champignâtres");
			case FamilyLoot.FLPower			: T._("Energétiques");
			case FamilyLoot.FLRetro			: T._("Retros");
			case FamilyLoot.FLRock			: T._("Echantillons");
			case FamilyLoot.FLStones		: T._("Joyaux");
			case FamilyLoot.FLUnder			: T._("Grouillants");
			case FamilyLoot.FLBot			: T._("Robotiques");
			case FamilyLoot.FLBook			: T._("Cultivés");
			case FamilyLoot.FLJap			: T._("Orientaux");
			case FamilyLoot.FLHallo			: T._("Fêtards");
		}
	}
	
	public static function GET_TUTO(lvl:Int, step:Int) {
		#if mBase
			var isMobile = true;
		#else
			var isMobile = false;
		#end
		
		if (lvl == 1) {
			if (step == 1) return T._("Dans Rockfaller Journey, vous devez faire\nun groupe de 4 éléments pour les faire disparaître !");
			else if (step == 2) {
				if (isMobile)
					return T._("Tapez au centre de ce groupe\npour le faire tourner !");
				else
					return T._("Cliquez sur ce groupe\npour le faire tourner !");
			}
			else if (step == 3) return T._("Essayez encore sur ce groupe là !");
			else if (step == 4) return T._("Ainsi qu'ici !");
			else if (step == 5) return T._("A vous de faire 3 groupes de plus\npour terminer ce niveau !");
		}
		else if (lvl == 2) {
			if (step == 1)			return T._("Si vous assemblez un groupe de 5,\nvous créerez une petite bombe qui vous aidera dans votre périple !\n Essayez ici !");
			else if (step == 2)		return T._("Les bombes explosent\navec un combo à côté d'elles !");
		}
		else if (lvl == 3) {
			if (step == 1)			return T._("Mais vous pouvez aussi créer\ndes bombes plus puissantes\navec de plus gros groupes !");
			else if (step == 2)		return T._("Et n'oubliez pas !\nLes bombes explosent avec un combo à côté d'elles !");
		}
		else if (lvl == 4) {
			if (step == 1)			return T._("Chaque niveau a un objectif à atteindre\n pour avancer dans le jeu !");
			else if (step == 2)		return T._("Mais attention, vous avez\nun nombre limité de coups !\n Bonne chance !");
		}
		else if (lvl == 5) {
			if (step == 1)			return T._("Eliminez le nombre requis d'éléments pour pouvoir passer au niveau suivant !");
			else if (step == 2)		return T._("Comme par exemple avec ce groupe-ci !");
		}
		else if (lvl == 6) {
			if (step == 1)			return T._("Vous voyez ce trésor ?\n Vous pouvez le récupérer en détruisant un groupe à coté !");
			else if (step == 2)		return T._("Vous devez terminer le niveau\n pour garder cet objet,\n collectionnez les tous !");
		}
		else if (lvl == 7) {
			if (step == 1)			return T._("Afin de gagner ce niveau, il va falloir éliminer tout l'or du tableau !");
			else if (step == 2)		return T._("Pour cela, vous devez éliminer des groupes sur celle-ci !");
		}
		else if (lvl == 8) {
			if (step == 1)			return T._("Ces pierres sont plutôt gênantes.\nIl va falloir faire au moins 3 combos à côté pour les éliminer !");
		}
		else if (lvl == 10) {
			if (step == 1)			return T._("Vous pouvez maintenant bouger les pièces sans être obligé de faire un groupe.\nCommencez par tourner ce groupe-ci...");
			else if (step == 2)		return T._("Grâce au coup précédent, vous pouvez créer une super bombe en tournant ce groupe-là !");
		}
		else if (lvl == 12) {
			if (step == 1)			return T._("La pioche peut détruire n'importe quel élément !\nEn voici une. Sélectionnez la !");
			else if (step == 2)		return T._("Essayez la sur ce bloc !");
		}
		else if (lvl == 13) {
			if (step == 1)			return T._("On a retrouvé 5 pioches dans le taupinotron, incroyable !\n Si vous n'en avez plus, vous pouvez toujours en créer !");
		}
		else if (lvl == 16) {
			if (step == 1)			return T._("Cassez la glace en détruisant un groupe à côté d'elle !");
		}
		else if (lvl == 36) {
			if (step == 1)			return T._("Attention, la colonne de lave restera 3 tours !");
		}
		else if (lvl == 56) {
			if (step == 1)			return T._("Attention aux bulles qui prolifèrent ! Éliminez les au plus vite !");
		}
		else if (lvl == 76) {
			if (step == 1)			return T._("Vous perdrez si une de ces bombes descend à 0 !");
			else if (step == 2)		return T._("Pour l'éliminer, détruisez un groupe à côté !");
		}
		else if (lvl == 96) {
			if (step == 1)			return T._("Attention, les zones de brouillard empêchent toute action !");
		}
		else if (lvl == 121) {
			if (step == 1)			return T._("Il va falloir étaler tout ce ciment\n si nous voulons traverser ce niveau !\nEssayez ici !");
		}
		
		return cast "NEED A TUTO HERE";
	}
}
