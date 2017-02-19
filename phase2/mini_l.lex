/*
 * Shawn Lee (861090401) 
 * Harrison Ray (861123139)
 * 
 * CS152 Phase 1
 * 
 * Write the specification for a flex lexical analyzer for the MINI-L language. For
 * this phase of the project, your lexical analyzer need only output the list of 
 * tokens identified from an inputted MINI-L program.
 * Example: write the flex specification in a file named mini_l.lex.
 * 
 * Run flex to generate the lexical analyzer for MINI-L using your specification.
 * Example: execute the command flex mini_l.lex. This will create a file called 
 * lex.yy.c in the current directory.
 * 
 * Compile your MINI-L lexical analyzer. This will require the -lfl flag for gcc.
 * Example: compile your lexical analyzer into the executable lexer with the 
 * following command: gcc -o lexer lex.yy.c -lfl. The program lexer should now be 
 * able to convert an inputted MINI-L program into the corresponding list of tokens.
 * 
 * flex mini_l.lex
 * gcc lex.yy.c -lfl
 * ./a.out < sampleTest.min
 * 
 * Format:
 *     definitions - name definitions
 *     %%
 *     rules - pattern action
 *     %%
 *     user code - yylex() routine
 */

%{
    #include "y.tab.h"
    #include <string>
    int line = 1, column = 1;
%}

ALPHA       [a-zA-Z]
DIGIT       [0-9]

%%

"function"      { column += yyleng; return FUNCTION; }
"beginparams"   { column += yyleng; return BEGIN_PARAMS; }
"endparams"     { column += yyleng; return END_PARAMS; }
"beginlocals"   { column += yyleng; return BEGIN_LOCALS; }
"endlocals"     { column += yyleng; return END_LOCALS; }
"beginbody"     { column += yyleng; return BEGIN_BODY; }
"endbody"       { column += yyleng; return END_BODY; }
"integer"       { column += yyleng; return INTEGER; }
"array"         { column += yyleng; return ARRAY; }
"of"            { column += yyleng; return OF; }
"if"            { column += yyleng; return IF; }
"then"          { column += yyleng; return THEN; }
"endif"         { column += yyleng; return ENDIF; }
"else"          { column += yyleng; return ELSE; }
"while"         { column += yyleng; return WHILE; }
"do"            { column += yyleng; return DO; }
"beginloop"     { column += yyleng; return BEGINLOOP; }
"endloop"       { column += yyleng; return ENDLOOP; }
"continue"      { column += yyleng; return CONTINUE; }
"read"          { column += yyleng; return READ; }
"write"         { column += yyleng; return WRITE; }
"and"           { column += yyleng; return AND; }
"or"            { column += yyleng; return OR; }
"not"           { column += yyleng; return NOT; }
"true"          { column += yyleng; return TRUE; }
"false"         { column += yyleng; return FALSE; }
"return"        { column += yyleng; return RETURN; }

"-"             { column += yyleng; return SUB; }
"+"             { column += yyleng; return ADD; }
"*"             { column += yyleng; return MULT; }
"/"             { column += yyleng; return DIV; }
"%"             { column += yyleng; return MOD; }

"=="            { column += yyleng; return EQ; }
"<>"            { column += yyleng; return NEQ; }
"<"             { column += yyleng; return LT; }
">"             { column += yyleng; return GT; }
"<="            { column += yyleng; return LTE; }
">="            { column += yyleng; return GTE; }

";"             { column += yyleng; return SEMICOLON; }
":"             { column += yyleng; return COLON; }
","             { column += yyleng; return COMMA; }
"("             { column += yyleng; return L_PAREN; }
")"             { column += yyleng; return R_PAREN; }
"["             { column += yyleng; return L_SQUARE_BRACKET; }
"]"             { column += yyleng; return R_SQUARE_BRACKET; }
":="            { column += yyleng; return ASSIGN; }

[ \t]+          { column += yyleng; }
"##".*          { column = 1; }
\n              { line++;   column = 1; }

{DIGIT}+        { column += yyleng; return NUMBER; }

{ALPHA}+(_*({ALPHA}|{DIGIT})+)* { column += yyleng; return IDENT; }

(([0-9]|\_)([[:alnum:]]|\_)*)|(([[:alnum:]]|\_)*\_) {printf("Error: invalid identifier at line %d, column %d, yytext: %s\n", line, column, yytext); column+=yyleng; exit(0);}

.               { printf(" Error at line %d, column %d: unrecognized symbol \"%s\"\n", line, column, yytext); exit(0); }
