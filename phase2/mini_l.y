/*
 * Shawn Lee (861090401) 
 * Harrison Ray (861123139)
 * 
 * CS152 Phase 2
 * 
 * WRITE the grammar for the MINI-L language, based on the specIFication for MINI-L
 * that was provided.
 * 
 * Create the bison parser specIFication file using the MINI-L grammar. Ensure that
 * you specIFy helpful syntax error messages to be outputted by the parser in the
 * event OF any syntax errors.
 *
 * Run bison to generate the parser for MINI-L using your specIFication. The -d flag
 * is necessary to create a .h file that will link your flex lexical analyzer AND
 * your bison parser. The -v flag is helpful for creating an output file that can be
 * used to analyze any conflicts in bison. The --file-prefi option can be used to 
 * change the prefix OF the file names outputted by bison.
 * Example: execute the COMMAnd bison -v -d --file-prefix=y mini_l.y. This will
 * create the parser in a file called y.tab.c, the necessary .h file called y.tab.h,
 * AND the informative output file called y.output.
 *
 * Ensure that your MINI-L lexical analyzer from the first phase OF the class project
 * has been constructed.
 *
 * Compile everything together:
 * gcc -o parser y.tab.c lex.yy.c -lfl. The program parser should be available for use.
 *
 *
 * bison -v -d --file-prefix=y mini_l.y
 * flex mini_l.lex
 * g++ -o mini_l y.tab.c lex.yy.c -lfl
 * 
 * Format:
 *     definitions - name definitions
 *     %%
 *     rules - pattern action
 *     %%
 *     user code - yylex() routine
 */

%{
 #include <stdlib>
 
 void yyerror(const char *msg);
 extern int line;
 extern int column;
 FILE * yyin;
%}

%union{
  char* identToken;
  int numberToken;
}

%error-verbose
%start prog_start
%token PROGRAM FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF
%token ELSE ELSEIF WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE RETURN
%token NOT TRUE FALSE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token <identToken> IDENT 
%token <numberToken> NUMBER 
%left OR AND SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE
%nonassoc IF_PREC ELSE_PREC

%% 
prog_start:
			|
			function prog_start { printf("prog_start -> FUNCTION\n"); }
			;
function:
			FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statement SEMICOLON statements END_BODY { printf("FUNCTION -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statement SEMICOLON statements END_BODY\n"); }
			;
			
declarations:
			declaration SEMICOLON declarations{printf("declarations -> declaration SEMICOLON declarations\n"); }
			|  { printf("declarations -> EMPTY\n"); }
			;

declaration:
			IDENT more_idents COLON ARRAY L_PAREN NUMBER R_PAREN OF INTEGER {printf("declaration -> IDENT more_idents COLON ARRAY L_PAREN NUMBER R_PAREN OF INTEGER\n"); }
			| IDENT more_idents COLON INTEGER {printf("declaration -> IDENT more_idents COLON INTEGER\n"); }

more_idents:
			COMMA IDENT more_idents {printf("more_idents -> COMMA IDENT more_idents\n"); }
			|  { printf("more_idents -> EMPTY\n"); }
			;
statements:
			statements statement SEMICOLON {printf("statements -> statements statements SEMICOLON\n"); }
			| statement SEMICOLON {printf("statements -> statement SEMICOLON\n"); }
			;			
statement:
			var ASSIGN expression {printf("statement -> var ASSIGN expression\n"); }
			| IF bool_exp THEN st_statement else_statement ENDIF {printf("statement -> IF bool_exp THEN st_statement else_statement ENDIF\n"); }
			| WHILE bool_exp BEGINLOOP st_statement ENDLOOP {printf("statement -> WHILE bool_exp BEGINLOOP st_statement ENDLOOP\n"); }
			| DO BEGINLOOP st_statement ENDLOOP WHILE bool_exp {printf("statement -> DO BEGINLOOP st_statement ENDLOOP WHILE bool_exp\n"); }
			| READ vars {printf("statement -> READ vars\n"); }
			| WRITE vars {printf("statement -> WRITE vars\n");}
			| CONTINUE {printf("statement -> CONTINUE\n");}
			;			
vars:
			vars COMMA var {printf("vars -> vars COMMA var\n"); }
			| var {printf("vars -> var\n");}
st_statement:
			statement SEMICOLON st_statement {printf("st_statement -> statement SEMICOLON st_statement\n"); }
			| {printf("st_statement -> EMPTY\n"); }
			;
else_statement:
			ELSE st_statement {printf("else_statement -> ELSE st_statement\n"); }
			| {printf("else_statement -> EMPTY\n"); }
			;
bool_exp:
			relation_and_exp relationexplist {printf("bool_exp -> relation_and_exp relationexplist\n"); }
			;
relation_and_exp: 
			relation_exp andlist { printf("relation_and_exp -> relation_exp andlist\n"); }
			;
relationexplist: 
			OR relation_and_exp relationexplist{ printf("relationexplist -> OR relation_and_exp relationexplist\n"); }
			| {printf("relatoinexplist -> EMPTY\n"); }
			;
andlist:
			AND relation_exp andlist {printf("andlist -> AND relation_exp andlist\n"); }
			| {printf("andlist -> EMPTY\n"); }
			;
relation_exp:
		    NOT	expression comp expression {printf("relational_exp -> NOT expression comp expression\n"); }
			| NOT TRUE {printf("relational_exp -> NOT TRUE\n"); }
			| NOT FALSE {printf("relational_exp -> NOT FALSE\n"); }
			| NOT  L_PAREN bool_exp R_PAREN  {printf("relational_exp -> NOT L_PAREN bool_exp R_PAREN\n"); }
			| expression comp expression {printf("relational_exp -> expression comp expression\n"); }
			| TRUE {printf("relational_exp -> TRUE\n"); }
			| FALSE {printf("relational_exp -> FALSE\n"); }
			| L_PAREN bool_exp R_PAREN  {printf("relational_exp -> L_PAREN bool_exp R_PAREN\n"); }
			;
var:
			IDENT { printf("var -> identIFer\n"); }
			| IDENT L_PAREN expression R_PAREN { printf("var -> IDENT L_PAREN expression R_PAREN\n"); }
			;
expression:
			multiplicative_exp exp_list { printf("expression -> multiplicative_exp exp_list\n"); }
			;
multiplicative_exp:
			term terms {printf("multiplicative_exp -> term terms\n"); }
			;
term:
			var {printf("term -> var\n"); }
			| NUMBER {printf("term -> NUMBER\n"); }
			| L_PAREN expression R_PAREN {printf("term -> L_PAREN expression R_PAREN\n"); }
			| SUB var {printf("term -> SUB var\n"); }
			| SUB NUMBER {printf("term -> SUB NUMBER\n"); }
			| SUB L_PAREN expression R_PAREN {printf("term -> SUB L_PAREN expression R_PAREN\n"); } 
terms:
			{printf("terms -> EMPTY\n");}
			| terms MULT term {printf("terms -> terms MULT term\n"); }
			| terms DIV term {printf("terms -> terms DIV term\n"); }
			| terms MOD term {printf("terms -> terms MOD term\n"); }
			;
exp_list:
			ADD multiplicative_exp exp_list  {printf("exp_list -> ADD multiplicative_exp exp_list\n"); }
			| SUB multiplicative_exp exp_list {printf("exp_list -> SUB multiplicative_exp exp_list\n"); }
			| {printf("exp_list -> EMPTY\n"); }
			;

comp:
			EQ {printf("comp -> EQ\n"); }
			| NEQ {printf("comp -> NEQ\n"); }
			| LT {printf("comp -> LT\n"); }
			| GT {printf("comp -> GT\n"); }
			| LTE {printf("comp -> LTE\n"); }
			| GTE {printf("comp -> GTE\n"); }
			;

%%

int main(int argc, char **argv){
	if(argc >= 2)
	{
		yyin = fopen(argv[1], "r");
		if(yyin == NULL)
		{
			yyin = stdin;
		}
   }
   else
   {
      yyin = stdin;
   }
   yyparse();
   return 0;
}

void yyerror(const char *msg) {
   printf("** Line %d, position %d: %s\n", line, column, msg);
}
