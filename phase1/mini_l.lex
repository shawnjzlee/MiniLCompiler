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
    #include <iostream>
    int line = 1, column = 1;
    using namespace std;
    extern "C" int yylex();
%}

ALPHA       [a-zA-Z]
DIGIT       [0-9]
IDENTIFIER  {ALPHA}+(_*({ALPHA}|{DIGIT})+)*

%%

"function"      { cout << "FUNCTION\n";         column += yyleng; }
"beginparams"   { cout << "BEGIN_PARAMS\n";     column += yyleng; }
"endparams"     { cout << "END_PARAMS\n";       column += yyleng; }
"beginlocals"   { cout << "BEGIN_LOCALS\n";     column += yyleng; }
"endlocals"     { cout << "END_LOCALS\n";       column += yyleng; }
"beginbody"     { cout << "BEGIN_BODY\n";       column += yyleng; }
"endbody"       { cout << "END_BODY\n";         column += yyleng; }
"integer"       { cout << "INTEGER\n";          column += yyleng; }
"array"         { cout << "ARRAY\n";            column += yyleng; }
"of"            { cout << "OF\n";               column += yyleng; }
"if"            { cout << "IF\n";               column += yyleng; }
"then"          { cout << "THEN\n";             column += yyleng; }
"endif"         { cout << "ENDIF\n";            column += yyleng; }
"else"          { cout << "ELSE\n";             column += yyleng; }
"while"         { cout << "WHILE\n";            column += yyleng; }
"do"            { cout << "DO\n";               column += yyleng; }
"beginloop"     { cout << "BEGINLOOP\n";        column += yyleng; }
"endloop"       { cout << "ENDLOOP\n";          column += yyleng; }
"continue"      { cout << "CONTINUE\n";         column += yyleng; }
"read"          { cout << "READ\n";             column += yyleng; }
"write"         { cout << "WRITE\n";            column += yyleng; }
"and"           { cout << "AND\n";              column += yyleng; }
"or"            { cout << "OR\n";               column += yyleng; }
"not"           { cout << "NOT\n";              column += yyleng; }
"true"          { cout << "TRUE\n";             column += yyleng; }
"false"         { cout << "FALSE\n";            column += yyleng; }

"-"             { cout << "SUB\n";              column += yyleng; }
"+"             { cout << "ADD\n";              column += yyleng; }
"*"             { cout << "MULT\n";             column += yyleng; }
"/"             { cout << "DIV\n";              column += yyleng; }
"%"             { cout << "MOD\n";              column += yyleng; }

"=="            { cout << "EQ\n";               column += yyleng; }
"<>"            { cout << "NEQ\n";              column += yyleng; }
"<"             { cout << "LT\n";               column += yyleng; }
">"             { cout << "GT\n";               column += yyleng; }
"<="            { cout << "LTE\n";              column += yyleng; }
">="            { cout << "GTE\n";              column += yyleng; }

{IDENTIFIER}    { cout << "IDENT " << yytext << endl;    column += yyleng; }
{DIGIT}+        { cout << "NUMBER " << yytext << endl;   column += yyleng; }

";"             { cout << "SEMICOLON\n";        column += yyleng; }
":"             { cout << "COLON\n";            column += yyleng; }
","             { cout << "COMMA\n";            column += yyleng; }
"("             { cout << "L_PAREN\n";          column += yyleng; }
")"             { cout << "R_PAREN\n";          column += yyleng; }
"["             { cout << "L_SQUARE_BRACKET\n"; column += yyleng; }
"]"             { cout << "R_SQUARE_BRACKET\n"; column += yyleng; }
":="            { cout << "ASSIGN\n";           column += yyleng; }

[ \t]+          { column += yyleng; }
"##".*          { column = 1; }
"\n"            { line++;   column = 1; }

%%
