/*
 * Shawn Lee (861090401) 
 * Harrison Ray (861123139)
 * 
 * CS152 Phase 2
 * 
 * Write the grammar for the MINI-L language, based on the specification for MINI-L
 * that was provided.
 * 
 * Create the bison parser specification file using the MINI-L grammar. Ensure that
 * you specify helpful syntax error messages to be outputted by the parser in the
 * event of any syntax errors.
 *
 * Run bison to generate the parser for MINI-L using your specification. The -d flag
 * is necessary to create a .h file that will link your flex lexical analyzer and
 * your bison parser. The -v flag is helpful for creating an output file that can be
 * used to analyze any conflicts in bison. The --file-prefi option can be used to 
 * change the prefix of the file names outputted by bison.
 * Example: execute the command bison -v -d --file-prefix=y mini_l.y. This will
 * create the parser in a file called y.tab.c, the necessary .h file called y.tab.h,
 * and the informative output file called y.output.
 *
 * Ensure that your MINI-L lexical analyzer from the first phase of the class project
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
 extern int currLine;
 extern int currPos;
 FILE * yyin;
%}

%union{
  char* identToken;
  int numberToken;
}

%error-verbose
%start function
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF
%token ELSE ELSEIF WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE RETURN
%token NOT TRUE FALSE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token <identToken> IDENT 
%token <numberToken> NUMBER 
%left OR AND SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE
%nonassoc IF_PREC ELSE_PREC

%% 
function:
			|
			function identifier semicolon block endbody return {printf( "function -> function ident semicolon block endbody return\n"); } 
			;
block: 
			declarations beginbody statements {printf("block -> declarations beginbody statements\n");}
			;

declarations:
			declaration semicolon declarations{printf("declarations -> declaration semicolon declarations\n"); }
			|  { printf("declarations -> EMPTY\n"); }
			;

declaration:
			identifier more_idents colon array l_paren number r_paren of integer {printf("declaration -> identifier more_idents colon array l_paren number r_paren of integer\n"); }
			| identifier more_idents colon integer {printf("declaration -> identifier more_idents colon integer\n"); }

more_idents:
			COMMA identifier more_idents {printf("more_idents -> COMMA identifier more_idents\n"); }
			|  { printf("more_idents -> EMPTY\n"); }
			;
statements:
			statements statement semicolon {printf("statements -> statements statements semicolon\n"); }
			| statement semicolon {printf("statements -> statement semicolon\n"); }
			;			
statement:
			Var assign expression {printf("statement -> Var assign expression\n"); }
			| if bool_exp then ststatement optionalelse end_if {printf("statement -> if bool_exp then ststatement optionalelse end_if\n"); }
			| while bool_exp begin_loop ststatement end_loop {printf("statement -> while bool_exp begin_loop ststatement end_loop\n"); }
			| do begin_loop ststatement end_loop while bool_exp {printf("statement -> do begin_loop ststatement end_loop while bool_exp\n"); }
			| read Vars {printf("statement -> read Vars\n"); }
			| write Vars {printf("statement -> write Vars\n");}
			| continue {printf("statement -> continue\n");}
			;			
Vars:
			Vars comma Var {printf("Vars -> Vars comma Var\n"); }
			| Var {printf("Vars -> Var\n");}
ststatement:
			statement semicolon ststatement {printf("ststatement -> statement semicolon ststatement\n"); }
			| {printf("ststatement -> EMPTY\n"); }
			;
optionalelse:
			else ststatement {printf("optionalelse -> else ststatement\n"); }
			| {printf("optionalelse -> EMPTY\n"); }
			;
bool_exp:
			relation_and_exp relationexplist {printf("bool_exp -> relation_and_exp relationexplist\n"); }
			;
relation_and_exp: 
			relation_exp andlist { printf("relation_and_exp -> relation_exp andlist\n"); }
			;
relationexplist: 
			or relation_and_exp relationexplist{ printf("relationexplist -> or relation_and_exp relationexplist\n"); }
			| {printf("relatoinexplist -> EMPTY\n"); }
			;
andlist:
			and relation_exp andlist {printf("andlist -> and relation_exp andlist\n"); }
			| {printf("andlist -> EMPTY\n"); }
			;
relation_exp:
		    not	expression comp expression {printf("relational_exp -> not expression comp expression\n"); }
			| not true {printf("relational_exp -> not true\n"); }
			| not false {printf("relational_exp -> not false\n"); }
			| not  l_paren bool_exp r_paren  {printf("relational_exp -> not l_paren bool_exp r_paren\n"); }
			| expression comp expression {printf("relational_exp -> expression comp expression\n"); }
			| true {printf("relational_exp -> true\n"); }
			| false {printf("relational_exp -> false\n"); }
			| l_paren bool_exp r_paren  {printf("relational_exp -> l_paren bool_exp r_paren\n"); }
			;
Var:
			identifier { printf("Var -> identifer\n"); }
			| identifier l_paren expression r_paren { printf("Var -> identifier l_paren expression r_paren\n"); }
			;
expression:
			multiplicative_exp exprlist { printf("expression -> multiplicative_exp exprlist\n"); }
			;
multiplicative_exp:
			term terms {printf("multiplicative_exp -> term terms\n"); }
			;
term:
			Var {printf("term -> Var\n"); }
			| number {printf("term -> number\n"); }
			| l_paren expression r_paren {printf("term -> l_paren expression r_paren\n"); }
			| sub Var {printf("term -> sub Var\n"); }
			| sub number {printf("term -> sub number\n"); }
			| sub l_paren expression r_paren {printf("term -> sub l_paren expression r_paren\n"); } 
terms:
			{printf("terms -> EMPTY\n");}
			| terms multiply term {printf("terms -> terms multiply term\n"); }
			| terms divide term {printf("terms -> terms divide term\n"); }
			| terms mod term {printf("terms -> terms mod term\n"); }
			;
exprlist:
			add multiplicative_exp exprlist  {printf("exprlist -> add multiplicative_exp exprlist\n"); }

			| sub multiplicative_exp exprlist {printf("exprlist -> sub multiplicative_exp exprlist\n"); }
			| {printf("exprlist -> EMPTY\n"); }
			;


function:
			FUNCTION { printf("function -> FUNCTION\n"); }
			;
beginparams:
			BEGIN_PARAMS { printf("beginparams -> BEGIN_PARAMS\n"); }
			;
endparams:
			END_PARAMS { printf("endparams -> END_PARAMS\n"); }
			;
beginlocals:
			BEGIN_LOCALS { printf("beginlocals -> BEGIN_LOCALS\n"); }
			;
endlocals:
			END_LOCALS { printf("endlocals -> END_LOCALS\n"); }
			;
beginbody:
			BEGIN_BODY { printf("beginbody -> BEGIN_BODY\n"); }
			;
endbody:
			END_BODY { printf("endbody -> END_BODY\n"); }
			;
identifier: 
			IDENT { printf("identifier -> IDENT(%s)\n", $1); }
			;
semicolon:
			SEMICOLON { printf("semicolon -> SEMICOLON\n"); }
			;
colon:
			COLON { printf("colon -> COLON\n"); }
			;
integer:    
			INTEGER { printf("integer -> INTEGER\n"); }
			;			
array:
			ARRAY { printf("array -> ARRAY\n"); }
			;
l_paren:  
			L_PAREN { printf("l_paren -> L_PAREN\n"); }
			;	
r_paren:  
			R_PAREN { printf("r_paren -> R_PAREN\n"); }
			;	
number:
			NUMBER { printf("number -> NUMBER(%d)\n", $1); }
			;
of:
			OF {printf("of -> OF\n"); }
			;
comma:
			COMMA {printf("comma -> COMMA\n"); }
			;	
assign:
			ASSIGN {printf("assign -> ASSIGN\n"); }
			;
if:
			IF {printf("if -> IF\n"); }
			;
then:
			THEN {printf("then -> THEN\n"); }
			;
end_if:
			ENDIF {printf("end_if -> ENDIF\n"); }
			;
else:
			ELSE {printf("else -> ELSE\n"); }
			;
while:
			WHILE {printf("while -> WHILE\n"); }
			;

do:
			DO {printf("do -> DO\n"); }
			;
begin_loop:
			BEGINLOOP {printf("begin_loop -> BEGINLOOP\n"); }
			;
end_loop:
			ENDLOOP {printf("end_loop -> ENDLOOP\n"); }
			;
continue: 
			CONTINUE {printf("continue-> CONTINUE\n"); }
			;
read:
		    READ {printf("read -> READ\n"); }
			;
write:
			WRITE {printf("write -> WRITE\n"); }
			;
and:	
			AND {printf("and -> AND\n"); }
			;
or:
			OR {printf("or -> OR\n"); }
			;
not:
			NOT {printf("not -> NOT\n"); }
			;
true:
			TRUE {printf("true -> TRUE\n"); }
			;
false:
			FALSE {printf("false -> FALSE\n"); }
			;
sub:		SUB {printf("false -> SUB\n"); }
			;
add:
			ADD {printf("false -> ADD\n"); }
			;
multiply:
			MULT {printf("false -> MULT\n"); }
			;
divide:
			DIV {printf("false -> DIV\n"); }
			;
mod:
			MOD {printf("false -> MOD\n"); }
			;
comp:
			EQ {printf("comp -> EQ\n"); }
			| NEQ {printf("comp -> NEQ\n"); }
			| LT {printf("comp -> LT\n"); }
			| GT {printf("comp -> GT\n"); }
			| LTE {printf("comp -> LTE\n"); }
			| GTE {printf("comp -> GTE\n"); }
			;
return:
			RETURN { printf("return -> RETURN\n"); }
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
   printf("** Line %d, position %d: %s\n", currLine, currPos, msg);
}
