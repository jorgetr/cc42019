/*
 *  The scanner definition for COOL.
 */

import java_cup.runtime.Symbol;

%%

%{

/*  Stuff enclosed in %{ %} is copied verbatim to the lexer class
 *  definition, all the extra variables/functions you want to use in the
 *  lexer actions should go here.  Don't remove or modify anything that
 *  was there initially.  */

    // Max size of string constants
    static int MAX_STR_CONST = 1025;

    // For assembling string constants
    StringBuffer string_buf = new StringBuffer();
  private int comment_level = 0;
    private int curr_lineno = 1;
    int get_curr_lineno() {
		return curr_lineno;
    }

    private AbstractSymbol filename;

    void set_filename(String fname) {
	filename = AbstractTable.stringtable.addString(fname);
    }

    AbstractSymbol curr_filename() {
	return filename;
    }

		Symbol lenExeced() {
      if (string_buf.length() >= MAX_STR_CONST) {
        yybegin(STRING_ERROR);
        return new Symbol(TokenConstants.ERROR, "String constant too long");
      } else {
        return null;
      }


    }
%}

%init{

/*  Stuff enclosed in %init{ %init} is copied verbatim to the lexer
 *  class constructor, all the extra initialization you want to do should
 *  go here.  Don't remove or modify anything that was there initially. */

    // empty for now
%init}

%eofval{

/*  Stuff enclosed in %eofval{ %eofval} specifies java code that is
 *  executed when end-of-file is reached. EOF symbol is returned other
 *whise the lexer won't
 know when its done.  */

    switch(yy_lexical_state) {
    case YYINITIAL:
        /* nothing special to do in the initial state */
        break;

				case BLOCK_COMMENT:
			yybegin(YYINITIAL);
			return new Symbol(TokenConstants.ERROR, "EOF in Comment");
	case STRING:
			yybegin(YYINITIAL);
			return new Symbol(TokenConstants.ERROR, "EOF in String");
	case STRING_ERROR:
			yybegin(YYINITIAL);
			return new Symbol(TokenConstants.ERROR, "EOF in String");
	case STRING_BACKSLASH:
			yybegin(YYINITIAL);
		  return new Symbol(TokenConstants.ERROR, "EOF in String");
    }
    return new Symbol(TokenConstants.EOF);
%eofval}

%class CoolLexer
%cup
%state STRING

%state SINGLE_COMMENT
%state BLOCK_COMMENT

%state STRING_ERROR
%state STRING_BACKSLASH

%%

<YYINITIAL>[cC][lL][aA][sS][sS]     { return new Symbol(TokenConstants.CLASS); }
<YYINITIAL>[eE][lL][sS][eE]         { return new Symbol(TokenConstants.ELSE); }
<YYINITIAL>[f][aA][lL][sS][eE]      { return new Symbol(TokenConstants.BOOL_CONST, false); }
<YYINITIAL>[t][rR][uU][eE]          { return new Symbol(TokenConstants.BOOL_CONST, true); }

<YYINITIAL>[fF][iI] { return new Symbol(TokenConstants.FI); }
<YYINITIAL>[iI][fF] { return new Symbol(TokenConstants.IF); }
<YYINITIAL>[iI][nN] { return new Symbol(TokenConstants.IN); }
<YYINITIAL>[iI][nN][hH][eE][rR][iI][tT][sS] { return new Symbol(TokenConstants.INHERITS); }
<YYINITIAL>[iI][sS][vV][oO][iI][dD] { return new Symbol(TokenConstants.ISVOID); }
<YYINITIAL>[lL][eE][tT] { return new Symbol(TokenConstants.LET); }
<YYINITIAL>[lL][oO][oO][pP] { return new Symbol(TokenConstants.LOOP); }
<YYINITIAL>[pP][oO][oO][lL] { return new Symbol(TokenConstants.POOL); }
<YYINITIAL>[tT][hH][eE][nN] { return new Symbol(TokenConstants.THEN); }
<YYINITIAL>[wW][hH][iI][lL][eE] { return new Symbol(TokenConstants.WHILE); }
<YYINITIAL>[cC][aA][sS][eE] { return new Symbol(TokenConstants.CASE); }
<YYINITIAL>[eE][sS][aA][cC] { return new Symbol(TokenConstants.ESAC); }
<YYINITIAL>[nN][eE][wW] { return new Symbol(TokenConstants.NEW); }
<YYINITIAL>[oO][fF] { return new Symbol(TokenConstants.OF); }
<YYINITIAL>[nN][oO][tT] { return new Symbol(TokenConstants.NOT); }


<YYINITIAL>"<-" { return new Symbol(TokenConstants.ASSIGN); }
<YYINITIAL>";"  { return new Symbol(TokenConstants.SEMI); }
<YYINITIAL>":"  { return new Symbol(TokenConstants.COLON); }
<YYINITIAL>","  { return new Symbol(TokenConstants.COMMA); }
<YYINITIAL>"."  { return new Symbol(TokenConstants.DOT); }
<YYINITIAL>"=>" { return new Symbol(TokenConstants.DARROW); }
<YYINITIAL>"+"  { return new Symbol(TokenConstants.PLUS); }
<YYINITIAL>"-"  { return new Symbol(TokenConstants.MINUS); }
<YYINITIAL>"*"  { return new Symbol(TokenConstants.MULT); }
<YYINITIAL>"/"  { return new Symbol(TokenConstants.DIV); }
<YYINITIAL>"~"  { return new Symbol(TokenConstants.NEG); }
<YYINITIAL>"<"  { return new Symbol(TokenConstants.LT); }
<YYINITIAL>"<=" { return new Symbol(TokenConstants.LE); }
<YYINITIAL>"="  { return new Symbol(TokenConstants.EQ); }
<YYINITIAL>"("  { return new Symbol(TokenConstants.LPAREN); }
<YYINITIAL>")"  { return new Symbol(TokenConstants.RPAREN); }
<YYINITIAL>"{"  { return new Symbol(TokenConstants.LBRACE); }
<YYINITIAL>"}"  { return new Symbol(TokenConstants.RBRACE); }
<YYINITIAL>"@"  { return new Symbol(TokenConstants.AT); }

<YYINITIAL>[0-9]+ { return new Symbol(TokenConstants.INT_CONST, AbstractTable.inttable.addString(yytext())); }
<YYINITIAL>[A-Z][_0-9a-zA-Z]* { return new Symbol(TokenConstants.TYPEID, AbstractTable.idtable.addString(yytext())); }
<YYINITIAL>[a-z][_0-9a-zA-Z]* { return new Symbol(TokenConstants.OBJECTID, AbstractTable.idtable.addString(yytext())); }

<YYINITIAL>"\"" { string_buf.setLength(0); yybegin(STRING); }

<STRING>\"   { yybegin(YYINITIAL); return new Symbol(TokenConstants.STR_CONST, AbstractTable.stringtable.addString(string_buf.toString())); }
<STRING>"\b" { if(lenExeced() != null) { return lenExeced(); } string_buf.append('\b'); }
<STRING>"\t" { if(lenExeced() != null) { return lenExeced(); } string_buf.append('\t'); }
<STRING>"\n" { if(lenExeced() != null) { return lenExeced(); } string_buf.append('\n'); }
<STRING>"\f" { if(lenExeced() != null) { return lenExeced(); } string_buf.append('\f'); }
<STRING>\\ { if(lenExeced() != null) { return lenExeced(); } yybegin(STRING_BACKSLASH); }
<STRING>\n { yybegin(YYINITIAL); return new Symbol(TokenConstants.ERROR, "Unterminated string constant"); }
<STRING>\0 { yybegin(STRING_ERROR); return new Symbol(TokenConstants.ERROR, "String contains null character"); }
<STRING>[^\0] { if(lenExeced() != null) { return lenExeced(); } string_buf.append(yytext()); }

<STRING_BACKSLASH>\0 { yybegin(STRING_ERROR); return new Symbol(TokenConstants.ERROR, "String contains null character"); }
<STRING_BACKSLASH>[^\0] { yybegin(STRING); string_buf.append(yytext()); }

<STRING_ERROR>\n|\"             { yybegin(YYINITIAL); }
<STRING_ERROR>[^\0]             { }

<YYINITIAL>--                   { yybegin(SINGLE_COMMENT); }
<YYINITIAL,BLOCK_COMMENT>"(*"   { ++comment_level; yybegin(BLOCK_COMMENT); }

<SINGLE_COMMENT>\n              { ++curr_lineno; yybegin(YYINITIAL); }
<BLOCK_COMMENT>"*)"             { if(--comment_level == 0) { yybegin(YYINITIAL); } }

<SINGLE_COMMENT,BLOCK_COMMENT>. { }

<YYINITIAL>"*)"                 { return new Symbol(TokenConstants.ERROR, "Unmatched *)"); }

\n                              { ++curr_lineno; }
[ \n\f\r\t\x0B]                     { }
.                               {  return new Symbol(TokenConstants.ERROR, yytext()); }
