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
    int line = 1, column = 1;
%}

ALPHA       [a-zA-Z]
DIGIT       [0-9]

%%

"function"      { printf("FUNCTION\n");         column += yyleng; }
"beginparams"   { printf("BEGIN_PARAMS\n");     column += yyleng; }
"endparams"     { printf("END_PARAMS\n");       column += yyleng; }
"beginlocals"   { printf("BEGIN_LOCALS\n");     column += yyleng; }
"endlocals"     { printf("END_LOCALS\n");       column += yyleng; }
"beginbody"     { printf("BEGIN_BODY\n");       column += yyleng; }
"endbody"       { printf("END_BODY\n");         column += yyleng; }
"integer"       { printf("INTEGER\n");          column += yyleng; }
"array"         { printf("ARRAY\n");            column += yyleng; }
"of"            { printf("OF\n");               column += yyleng; }
"if"            { printf("IF\n");               column += yyleng; }
"then"          { printf("THEN\n");             column += yyleng; }
"endif"         { printf("ENDIF\n");            column += yyleng; }
"else"          { printf("ELSE\n");             column += yyleng; }
"while"         { printf("WHILE\n");            column += yyleng; }
"do"            { printf("DO\n");               column += yyleng; }
"beginloop"     { printf("BEGINLOOP\n");        column += yyleng; }
"endloop"       { printf("ENDLOOP\n");          column += yyleng; }
"continue"      { printf("CONTINUE\n");         column += yyleng; }
"read"          { printf("READ\n");             column += yyleng; }
"write"         { printf("WRITE\n");            column += yyleng; }
"and"           { printf("AND\n");              column += yyleng; }
"or"            { printf("OR\n");               column += yyleng; }
"not"           { printf("NOT\n");              column += yyleng; }
"true"          { printf("TRUE\n");             column += yyleng; }
"false"         { printf("FALSE\n");            column += yyleng; }
"return"        { printf("RETURN\n");           column += yyleng; }

"-"             { printf("SUB\n");              column += yyleng; }
"+"             { printf("ADD\n");              column += yyleng; }
"*"             { printf("MULT\n");             column += yyleng; }
"/"             { printf("DIV\n");              column += yyleng; }
"%"             { printf("MOD\n");              column += yyleng; }

"=="            { printf("EQ\n");               column += yyleng; }
"<>"            { printf("NEQ\n");              column += yyleng; }
"<"             { printf("LT\n");               column += yyleng; }
">"             { printf("GT\n");               column += yyleng; }
"<="            { printf("LTE\n");              column += yyleng; }
">="            { printf("GTE\n");              column += yyleng; }

";"             { printf("SEMICOLON\n");        column += yyleng; }
":"             { printf("COLON\n");            column += yyleng; }
","             { printf("COMMA\n");            column += yyleng; }
"("             { printf("L_PAREN\n");          column += yyleng; }
")"             { printf("R_PAREN\n");          column += yyleng; }
"["             { printf("L_SQUARE_BRACKET\n"); column += yyleng; }
"]"             { printf("R_SQUARE_BRACKET\n"); column += yyleng; }
":="            { printf("ASSIGN\n");           column += yyleng; }

[ \t]+          { column += yyleng; }
"##".*          { column = 1; }
\n              { line++;   column = 1; }

{DIGIT}+        { printf("NUMBER %s\n", yytext);   column += yyleng; }

{ALPHA}+(_*({ALPHA}|{DIGIT})+)* { printf("IDENT %s\n", yytext); column += yyleng; }

(([0-9]|\_)([[:alnum:]]|\_)*)|(([[:alnum:]]|\_)*\_) {printf("Error: invalid identifier at line %d, column %d, yytext: %s\n", line, column, yytext); column+=yyleng; exit(0);}

.               { printf(" Error at line %d, column %d: unrecognized symbol \"%s\"\n", line, column, yytext); exit(0); }

%%

int main (int argc, char * argv[]) {
    if (argc >= 2) {
        yyin = fopen(argv[1], "r");
        if (yyin == NULL)
            yyin = stdin;
    }
    else
        yyin = stdin;
        
    yylex();
}
