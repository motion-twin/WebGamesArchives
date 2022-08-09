import Protocole;

class LangEn implements haxe.Public
{//}
	static var PIX = "<font color='#92d930'>.</font>";
	static var PIX2 = "<font color='#52b31e'>.</font>";
	static var DARK_PINK = "#FF8888";
	static var PINK = "#FFAAAA";
	static var WHITE = "#FFFFFF";

	static var MOJO_LEFT = "mojo left";
	static var MOJO_FULL = "mojo full";
	static var CARD_LEFT = "You don't have enough cards:";
	static var CARD_FULL = "You have too many cards:";
	static var START_GAME = "Start game";
	
	static var SELECT_CARDS = "Select which cards to use in your game.";
	static var TOO_MUCH_CARDS = "Select fewer cards to start your game.";
	
	static var EACH_USE = "When used: ";
	static var I_SUBSCRIBE = "Sign me up!";

	static var UP_LEVEL = "lvl." ;
	
	static var BROWSER_PARAMS = [ "Order by price", "Hide cards which are too expensive", "Hide cards whilst reloading" ];
	static var BROWSER_TUTO = "Select cards worth up to 6 mojo points.";
	static var BROWSER_NO_CARD = "You can't reach 6 mojo points"+PIX2+" with the available cards"+PIX2+".\nAll your cards will become available again\n at midnight!\n\nYou can also buy "+PIX2+" extra cards from the shop:";
	static var BROWSER_HAND_LIMIT = "You can only use %0 cards";
	static var BROWSER_MULTI_LIMIT = "You can only use 1 of these cards.";
	static var BROWSER_MIDNIGHT = "This card will become available again at midnight.";
	static var BUY_CARD = "buy card";
	static var BUY = "acheter";
	
	static var SUCCESS = "Quest Completed!";
	static var FRUIT_UNKNOWN = "Unknown Fruit";

	static var FRUIT_TAGS = ["sweet", "red", "leaf", "small", "nut", "flower", "citrus", "green", "plant", "alien", "berry", "long", "squash", "pear", "blue","apple","drop"];
	
	static var CONTROL = "Controls";
	static var CHOOSE_CONTROL = "Choose which controls to use:";
	static var CONTROL_NAMES = ["Mouse","Keyboard A","Keyboard B"];
	static var DESC_CONTROL = [
			"The snake follows the "+pink("mouse")+". Click or hold the "+pink("left mouse button")+" to speed up.",
			""+pink("up down left")+" and "+pink("right")+" arrow keys to choose the snake's direction.\n"+pink("space bar")+" to speed up.",
			""+pink("left")+" and "+pink("right")+" arrow keys to make your snake turn.\n"+pink("up")+" arrow to speed up.",
			pink("Concentrate")+" on a point in the gameboard to move the snake there.\nTo speed up, concentrate "+pink("harder")+".",
	];
	static var PAUSE_TITLE = 	"Game Paused";
	static var PAUSE_OFF = 		"Resume";
	static var GORE = 			"Gore";
	static var YES = 			"On";
	static var NO = 			"Off";
	static var QUIT = 			"Quit";
	static var OPTIONS = 		"Options";
	
	static var STATS = ["Time Played", "Fruits Collected", "Frutibar Completion", "Maximum Length"];
	static var SECTION_FRIENDS = "My Friends";
	static var SECTION_ARCHIVE = "My Archives";
	static var SECTION_TOP = "Hall of Fame";
	static var SECTION_DRAFT = "My Tournament";

	static var SECTION_RAINBOW = "Rainbow ranking"; //### ### TODO
	static var DRAFT_CHOOSE = "Choose a card!" ; //### ### TODO
	
	static var CNX_IMPOSSIBLE = "Connection impossible";
	static var CNX_TRY = "retry";
	
	static var LOADING = "Loading......";
	static var ENCYLOPEFRUIT_PROGRESSION = "Encyclopefruit Progress";
	static var BONUS = "Bonus";
	static var PLAY_AGAIN = "Play Again";
	static var LENGTH_UNIT = "cm";
	static var TRAINING_GAME = "Trial Game";
	static var TRAINING_INSTRUCTION = "Learn how to control your snake with this free trial.\nYou can change your controls after each game.";
	
	static var CAL_UNIT = "calories";
	static var WEIGHT_UNIT = "mg";
	static var FRUIT_PROPS = ["Value", "Vitamins", "Nutrition", "Appears For"];
	static var TIME_UNIT = "sec";
	
	static var CARD_PRICE = "Card Price: ";
	static var DRAW = "Drawing Card......";
	static var CARD_ADDED = "This card has been added to your collection";
	static var NOT_ENOUGH_TOKEN = "You don't have enough tokens!";
	
	static var TIME_INTERVAL = ["This week", "This month", "This year"];
	
	// COLLECTIONS 
	static var PAGE = "page";
	static var CARDS = "cards";
	static var COMPLETION = "completion";
	static var COLLECTION_SECTIONS = ["Collection","Shop","Tombola","Bazaar"];
	static var LOTTERY_DESC = "Every night at midnight, the card of the day is drawn out of all the lottery players.";
	static var YESTERDAY_WINNER = "Yesterday's winner : ";
	static var COLLECTION_TITLE_SHOP = 		"The Serpentine Shop";
	static var COLLECTION_TITLE_LOTTERY = 	"The Loterine Tombola";
	static var COLLECTION_TITLE_BAZAR = 	"Mephistoof's Bazaar";
	static var SHOP_ITEMS = ["Extra card", "Pack of 10 cards", "Lottery ticket"];
	static var SHOP_DESC = [
		"The card is drawn at random:\n- common card: 60%\n- standard card: 30%\n- rare card: 10%",
		"Pack of 10 randomly-drawn cards:\n -6x common cards\n- 3x standard cards\n- 1x rare card",
		"One lottery ticket with every card of the day!\nDrawn tonight at midnight...",
	];
	static var DAILY_CARD = "Card of the day:";
	static var LOTTERY_STATS = ["You have:", "Tickets sold:", "Chance of winning:"];
	
	// NEW !
	static var PLAY = "play";
	static var GAME_WILL_START = "The game will begin in ";
	static var SECONDES = "seconds";
	static var START = "start!";
	
	
	static var BAZAR_OFFER = [
		"I am interested in your %1 card... I'll give you %2 tokens for it. What do you say?",
		"I really need your %1 card, It's a %3 card, so I'll give you %2 tokens!",
		"I'll give you %2 tokens for your %1 card. Deal?",
		"I can give you %2 tokens in exchange for your %1 card. How does that sound?",
		"I've got a great combo to try out with %4 and %5 so all I'm missing is your %1 card, will you sell me it for %2 tokens?",
		"Wow, you have a %1 card!! I'll give you %2 tokens in exchange for it, ok?",
		"Meh... Apart from your %1 card, I don't see anything I like... I'll take it off your hands for %2 tokens?",
	];
	static var BAZAR_RAISE = [
		"What? OK, %2 tokens, and that's my final offer!",
		"Playing hardball, huh! Let's say %2 tokens!",
		"What? But it's only a %3 card! Tsss.. Well, ok. %2 tokens then...",
	];
	static var BAZAR_STAY = [
		"No way dude! It's %2 tokens or nothing!",
		"%2 jetons for the card, you won't get a better offer, take it.",
		"No no no, I've already done you a favour in getting rid of %1 for you so it's %2 or nothing!",
		"I will find a %1 card for %2 tokens elsewhere you know... ",
		"I'll never pay more than %2 tokens for a %3 card",
		"I'd love to kid, but I've only got %2 tokens on me...",
	];
	static var BAZAR_NEXT = [
		"Do you think I'm some kind of Toby? Forget about that card...",
		"I think we'll be able to do business, but not on that card...",
		"I won't pay more than a %1 should cost, so let's move on!",
		"OK then I think I'm going to save my cash for another card...",
		"Never mind, let's see the next card...",
	];
	static var BAZAR_GIVE_UP = [
		"Ah well!",
		"Shame.",
		"Well, if you need it...",
		"Not to worry, I know where I can find one.",
		"You're the boss!",
		"It's up to you!",
		"Dammit! I'll never find on at this rate...",
	];
	static var BAZAR_QUIT = [
		"OK, there's clearly no negotiating with you, I'm off!",
		"Ok I reckon I can find a less tight-fisted seller.",
		"I don't have enough tokens, sorry...",
		"I think someone's calling me, see you around!",
		"I'll come back tomorrow to see if you're in in a better mood",
		"I'm going through a 'shh' tunnel, I'll 'shh' at the next 'shhstsss'"
	];
	static var BAZAR_FINISH = [
		"I'm not interested in anything else for the moment...",
		"Well, apart from that one, there are no more cards in your collection that I'm interested in.",
	];
	static var BAZAR_DEAL = [
		"Awesome!! I've been looking for that for 3 days!",
		"Thanks!",
		"Cool!",
		"Many thanks!",
		"It's been a pleasure doing business with you!",
	];
	
	static var BAZAR_NO = [ "I'm keeping it!", "No!", "I'd rather die", "Never!", "No thanks"];
	static var BAZAR_UP = [ "That's not enough", "I've no more tokens!", "Try again", "Dreadful price","A little more?" ];
	static var BAZAR_YES = [ "Done!", "Ok!", "It's yours!" ];
	
	static var BAZAR_CHOICES = ["I'm keeping it", "Up the price", "Deal" ];
	static var BAZAR_NO_ENTER = "You need at least " + col("%1","#FF6666") + " cards to go into the bazaar!!";
	static var BAZAR_END = "Mephistoof is gone! If he's in a good mood, he'll probably come back tomorrow to buy your new cards.";
	static var FREQ = ["common", "standard", "rare"];
	
	
	// DRAFT
	static var DRAFT_DESC_CLOSE = "Every day, tournaments of %1 players start between %2 and %3 o'clock.\n\nTournament registrations are currently " + col("closed", WHITE) + ", next tournament in %4 ";
	static var DRAFT_DESC_OPEN = "Tournament registrations will remain open for %1.\nThere are %2 place(s) remaining!";
	static var DRAFT_SUBSCRIBE_ERROR = ["Your registration has not been accepted!", "You don't have enough tokens.", "Registrations for this tournament are full."];
	
	static var DRAFT_RULES = white("Tournament rules")+" : Each player receives "+pink("10 new cards")+", they choose "+pink("one")+" then pass the rest to their neighbour. This is repeated until no cards remain. Everyone plays as many games as they can with their chosen cards, then "+pink("the highest score")+" wins the tournament.\nOne game in the tournament could be worth between "+green("1")+" and "+green("6")+" mojo points.\nEveryone leaves with their 10 cards and the top 3 win a prize.";
	static var DRAFT_TEASING = "Tournaments are available every day between %1h and %2h --- The 10 cards selected for the tournament will be added to your collection --- In a tournament, you can start a game with as little as 1 mojo point --- Check out games you've played in tournaments in the rankings section --- ";
	static var DRAFT_CARD_NOT_AVAILABLE = "That card cannot be used in the tournament.";
	static var DRAFT_LEFT_TIME = "Time left" ;
	static var SERVER_CONNECT = "connectnig to server...";
	static var WAITING_FOR_PLAYER = "Waiting for player(s): ";
	static var PLEASE_WAIT = "please wait";
	static var WAITING_NEW_PLAYERS = "Waiting for %1 more player(s)";
	static var ABORT = "The tournament has been " + red("cancelled") + " !\n" + green("(It's scandalous)") + "\nYour " + Data.DRAFT_COST + " tokens have been returned.";
	static var DISCONNECT = "You are disconnected.\nDon't panic, you can rejoin the tournament:";
	static var RECONNECT = "Reconnect";
	static var CANT_CONNECT = "It has not been possible to connect to the server. Please try again shortly.";
	static var PRIZES = "Prizes";
	static var POS = ["1st", "nd", "3rd"];
	
	static public inline function white(str) {
		return col(str, WHITE);
	}
	
	static public inline function pink(str) {
		return col(str, "#FF0088");
	}
	static public inline function red(str) {
		return col(str, "#FF5555");
	}
	static public inline function green(str) {
		return col(str, "#88DD00");
	}
	
	static public function col(str,col) {
		return "<font color='" + col + "'>" + str + "</font>";
	}
		
	static public function killLatin(str) {
		return mt.db.Phoneme.removeAccentsUTF8(str);
	}
	
	static public function init() {
		
		var c:Dynamic = null;
		#if fr
		return;
		#elseif en
		c = LangEn;
		#elseif de
		c = LangDe;
		#elseif es
		c = LangEs;
		#end
		
		for( f in Type.getClassFields(c) ) {
			var v : Dynamic = Reflect.field(c, f);
			if( Reflect.isFunction(v) ) continue;
			Reflect.setField(Lang, f, v );
		}
	}
	
	static function rep(str, a, b = "b", c = "c", d = "d", e = "e") {
		str = StringTools.replace(str, "%1", a);
		str = StringTools.replace(str, "%2", b);
		str = StringTools.replace(str, "%3", c);
		str = StringTools.replace(str, "%4", d);
		str = StringTools.replace(str, "%5", e);
		return str;
	}
	

		
	
//{
}
