
/**@file tmedia_machine_utils.rl
 * @brief Ragel file.
 *

 *

 */
%%{

	machine tmedia_machine_utils;
	
	OCTET = "0x"[0-9A-Fa-f]+;
	CHAR = 0x01..0x7f;
	VCHAR = 0x21..0x7e;
	ALPHA = 0x41..0x5a | 0x61..0x7a;
	DIGIT = 0x30..0x39;
	CTL = 0x00..0x1f | 0x7f;
	HTAB = "\t";
	LF = "\n";
	CR = "\r";
	SP = " ";
	DQUOTE = "\"";
	BIT = "0" | "1";
	HEXDIG = DIGIT | "A"i | "B"i | "C"i | "D"i | "E"i | "F"i;
	CRLF = CR LF;
	WSP = SP | HTAB;
	LWSP = ( WSP | ( CRLF WSP ) )*;
	LWS = ( WSP* CRLF )? WSP+;
	SWS = LWS?;
	EQUAL = SWS "=" SWS;
	LHEX = DIGIT | 0x61..0x66;
	HCOLON = ( SP | HTAB )* ":" SWS;
	separators = "(" | ")" | "<" | ">" | "@" | "," | ";" | ":" | "\\" | DQUOTE | "/" | "[" | "]" | "?" | "=" | "{" | "}" | SP | HTAB;
	STAR = SWS "*" SWS;
	SLASH = SWS "/" SWS;
	LPAREN = SWS "(" SWS;
	RPAREN = SWS ")" SWS;
	COMMA = SWS "," SWS;
	SEMI = SWS ";" SWS;
	COLON = SWS ":" SWS;
	LAQUOT = SWS "<";
	LDQUOT = SWS DQUOTE;
	RAQUOT = ">" SWS;
	RDQUOT = DQUOTE SWS;
	UTF8_CONT = 0x80..0xbf;
    ##### FIXME: UTF8_NONASCII up to 2bytes will fail on Android
	UTF8_NONASCII = ( 0x80..0xff );
	#UTF8_NONASCII = ( 0xc0..0xdf UTF8_CONT ) | ( 0xe0..0xef UTF8_CONT{2} ) | ( 0xf0..0xf7 UTF8_CONT{3} ) | ( 0xf8..0xfb UTF8_CONT{4} ) | ( 0xfc..0xfd UTF8_CONT{5} );	ctext = 0x21..0x27 | 0x2a..0x5b | 0x5d..0x7e | UTF8_NONASCII | LWS;
	qvalue = ( "0" ( "." DIGIT{,3} )? ) | ( "1" ( "." "0"{,3} )? );
	alphanum = ALPHA | DIGIT;
	token = ( alphanum | "-" | "." | "!" | "%" | "*" | "_" | "+" | "`" | "'" | "~" )+;
	ietf_token = token;
	x_token = "x-"i token;
	iana_token = token;
	token_nodot = ( alphanum | "-" | "!" | "%" | "*" | "_" | "+" | "`" | "'" | "~" )+;
	word = ( alphanum | "-" | "." | "!" | "%" | "*" | "_" | "+" | "`" | "'" | "~" | "(" | ")" | "<" | ">" | ":" | "\\" | DQUOTE | "/" | "[" | "]" | "?" | "{" | "}" )+;
}%%
