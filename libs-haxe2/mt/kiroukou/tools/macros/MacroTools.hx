package mt.kiroukou.tools.macros;

import haxe.macro.Expr;

class MacroTools
{

	///Attempts to extract a string constant from an expression.
	static public function getString(e:Expr) {
		return
			switch (e.expr) {
				case EConst(c):
					switch (c) {
						case CString(string): string;
						default: //e.pos.makeFailure(NOT_A_STRING);
					}
				default: //e.pos.makeFailure(NOT_A_STRING);
			}
	}
	///Attempts to extract an integer constant from an expression.
	static public function getInt(e:Expr) {
		return
			switch (e.expr) {
				case EConst(c):
					switch (c) {
						case CInt(id): Std.parseInt(id);
						default: //e.pos.makeFailure(NOT_AN_INT);
					}
				default: //e.pos.makeFailure(NOT_AN_INT);
			}
	}
	///Attempts to extract an identifier (CIdent or CType) from an expression.
	static public function getIdent(e:Expr) {
		return
			switch (e.expr) {
				case EConst(c):
					switch (c) {
						case CIdent(id), CType(id): id;
						default:// e.pos.makeFailure(NOT_AN_IDENT);
					}
				default:
					//e.pos.makeFailure(NOT_AN_IDENT);
			}
	}
	///Attempts to extract a name (identifier or string) from an expression.
	static public function getName(e:Expr) {
		return
			switch (e.expr) {
				case EConst(c):
					switch (c) {
						case CString(s), CIdent(s), CType(s): (s);
						default:// e.pos.makeFailure(NOT_A_NAME);
					}
				default: //e.pos.makeFailure(NOT_A_NAME);
			}
	}
	///Attempts to extract a function from an expression.
	static public function getFunction(e:Expr)
	{
		return
			switch (e.expr) {
				case EFunction(_, f): (f);
				default: //e.pos.makeFailure(NOT_A_FUNCTION);
			}
	}
	static inline var NOT_AN_INT = "integer constant expected";
	static inline var NOT_AN_IDENT = "identifier expected";
	static inline var NOT_A_STRING = "string constant expected";
	static inline var NOT_A_NAME = "name expected";
	static inline var NOT_A_FUNCTION = "function expected";
	static inline var EMPTY_EXPRESSION = "expression expected";

}