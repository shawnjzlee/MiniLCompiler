/*
 * Shawn Lee (861090401) 
 * Harrison Ray (861123139)
 * 
 * CS152 Phase 3
 * 
 * In the previous phases OF the class project, you used the flex and bison tools 
 * to create a lexical analyzer and a parser for the "MINI-L" programming language. 
 * In this phase OF the class project, you will take a syntactically-correct MINI-L 
 * program (a program that can be parsed without any syntax error), verify that 
 * it has no semantic error, and then generate its corresponding intermediate code. 
 * The generated code can then be executed (using a tool we will provide) to run 
 * the compiled MINI-L program.
 *
 * You should perform one-pass code generation and directly output the generated 
 * code. There is no need to build/traverse a syntax tree. However, you will need 
 * to maintain a symbol table during code generation.
 *
 * The intermediate code you will generate is called "MIL" code. We will provide 
 * you with an interpreter called mil_run that can be used to execute the MIL code.

 * The output OF your code generator will be a file containing the generated MIL 
 * code. If any semantic error are encountered by the code generator, then 
 * appropriate error messages should be emitted and no other output should be 
 * produced.
 *
 * Compile everything together:
 * gcc -o parser y.tab.c lex.yy.c -lfl. The program parser should be available for use.
 *
 *
 * bison -v -d --file-prefix=y mini_l.y
 * flex mini_l.lex
 * g++ -o mini_l y.tab.c lex.yy.c -lfl
 * mil_run mil_code.mil < input.txt
 * 
 * Format:
 *     definitions - name definitions
 *     %%
 *     rules - pattern action
 *     %%
 *     user code - yylex() routine
 */

%{
 // includes
 #include <stdlib.h>
 #include <stdio.h>

 #include <iostream>
 #include <fstream>
 #include <sstream>
 #include <vector>
 #include <stack>
 #include <list>
 #include <string>
 
 using namespace std;
 
 // functions
 void yyerror(const char *msg);
 //bool check_duplicate(string name);
 //bool is_temp(string name);
 //int get_type(string name);
 //int get_index(string name);
 
 extern int yylex(void);
 
 struct symbol {
 	int type;
 	int arr_size;
 	string name;
 	
 	symbol() : type(0), arr_size(0), name() {}
 	symbol(int type, int size, string name) {
 		type = type;
 		arr_size = size;
 		this->name = name;
 	}
 };
 
 // containers
 extern FILE * yyin;
 extern char * yytext;
 vector<symbol> symbol_table;
 vector<string> v_tmp_var;
 vector<string> v_p_var;
 vector<string> v_t;
 vector<string> v_v;
 vector<string> v_identifiers;
 vector<string> v_leaders;
 vector<string> mil_code;
 vector<string> tmp_code;
 
 // variables
 extern int currLine;
 extern int currPos;
 int i_label, i_temp, i_pred, i_lead, i_bool_op = 0;
 string fn_name, tmp_name, tmp_var, file;
 bool r_flag, if_flag, error_flag, array_access_flag = false;
 
 // ostringstream
 ostringstream code;
 ostringstream final_code;
 ostringstream error;
%}

%union{

  char* identToken;
  int numberToken;
   
}

%error-verbose
%start program
%token FUNCTION
%token BEGIN_PARAMS
%token END_PARAMS 
%token BEGIN_LOCALS 
%token END_LOCALS 
%token BEGIN_BODY
%token END_BODY 
%token INTEGER
%token ARRAY 
%token OF
%token IF THEN ELSE ELSEIF ENDIF 
%token END_OF_PROGRAM
%token WHILE DO BEGINLOOP ENDLOOP CONTINUE RETURN
%token READ WRITE
%token NOT TRUE FALSE
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token <identToken> IDENT 
%token <numberToken> NUMBER
%token <commentToken> COMMENT

%left OR AND SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE

%type <identToken> program
%type <identToken> functions
%type <identToken> function
%type <identToken> params
%type <identToken> locals
%type <identToken> block
%type <identToken> declarations
%type <identToken> declaration
%type <identToken> identifiers
%type <identToken> statements
%type <identToken> statement
%type <identToken> vars
%type <identToken> var
%type <identToken> optionalelse
%type <identToken> bool_exp
%type <identToken> relation_and_exp
%type <identToken> relationexplist
%type <identToken> andlist
%type <identToken> relation_exp
%type <identToken> expression
%type <identToken> multiplicative_exp
%type <identToken> terms
%type <identToken> term
%type <identToken> exprlist

%nonassoc IF_PREC ELSE_PREC

%% 
program:    functions {
				// printf("program -> functions END_OF_PROGRAM\n");
				
				// if (error_flag) {
				// 	error << "Error: Unable to print program. \n";
				// }
				// else {
				// 	for (const auto &i : mil_code) error << i << endl;
				// 	error << "endfunc\n";
				// }
			}
            ;
            
functions:  function functions { }
			| { } 
            ;

function:	function IDENT SEMICOLON params locals block END_BODY {
				// printf( "function -> function ident SEMICOLON params locals block END_BODY\n");
				fn_name = $2;
			} 
			;
			
params:     BEGIN_PARAMS declarations END_PARAMS {printf("params -> BEGIN_PARAMS declarations END_PARAMS\n"); }
            ;
            
locals:
            BEGIN_LOCALS declarations END_LOCALS { }
            | BEGIN_LOCALS END_LOCALS { }
            ;
            
block: 
			BEGIN_BODY declarations statements {printf("block -> declarations BEGIN_BODY statements\n"); }
			;
			
declarations:
			   declaration SEMICOLON declarations{printf("declarations -> declaration SEMICOLON declarations\n"); }
			|  declaration SEMICOLON { printf("declarations -> declaration SEMICOLON\n"); }
            |  { printf("declarations -> EMPTY\n"); }
	        ;		

declaration:
			IDENT identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {
				if ($1 == fn_name || $1 == [=]() { for(auto &i : symbol_table) { if($1 == name) return true; }}) {
					error << "Error line " << currLine << ": used variable \"" + $1 + "\" is already defined\n";
				}
				else {
					symbol temp(1, atoi($5), $1);
					symbol_table.push_back(temp);
				}
			}
			| IDENT identifiers COLON INTEGER {
				if ($1 == fn_name || $1 == [=]() { for(auto &i : symbol_table) { if($1 == name) return true; }}) {
					error << "Error line " << currLine << ": used variable \"" + $1 + "\" is already defined\n";
				}
				else {
					symbol temp(0, 0, $1);
					symbol_table.push_back(temp);
				}
			}

identifiers:
			COMMA IDENT identifiers {
				if ($2 == fn_name || $2 == [=]() { for(auto &i : symbol_table) { if($2 == name) return true; }}) {
					error << "Error line " << currLine << ": used variable \"" + $2 + "\" is already defined\n";
				}
				else {
					symbol temp(0, 0, $2);
					symbol_table.push_back(temp);
				}
			}
			| { }
			;
			
statements:
			statement SEMICOLON statements {printf("statements -> statement SEMICOLON statements\n"); }
			| statement SEMICOLON {printf("statements -> statement SEMICOLON\n"); }
			;
			
statement:
			var ASSIGN expression {printf("statement -> var ASSIGN expression\n"); }
			| IF bool_exp THEN statements optionalelse ENDIF {printf("statement -> if bool_exp then statements optionalelse end_if\n"); }
			| WHILE bool_exp BEGINLOOP statements ENDLOOP {printf("statement -> WHILE bool_exp BEGINLOOP statements ENDLOOP\n"); }
			| DO BEGINLOOP statements ENDLOOP WHILE bool_exp {printf("statement -> do BEGINLOOP statements ENDLOOP WHILE bool_exp\n"); }
			| READ vars {printf("statement -> READ vars\n"); }
			| WRITE vars {printf("statement -> WRITE vars\n");}
			| CONTINUE {printf("statement -> CONTINUE\n");}
            | RETURN expression {printf("statement -> RETURN\n"); }
			;			
vars:
			var COMMA vars {printf("vars -> var COMMA vars\n"); }
			| var {printf("vars -> var\n");}
            ;
optionalelse:
			ELSE statements {printf("optionalelse -> else statements\n"); }
			| {printf("optionalelse -> EMPTY\n"); }
			;
bool_exp:
			relation_and_exp relationexplist {printf("bool_exp -> relation_and_exp relationexplist\n"); }
			;
relation_and_exp: 
			relation_exp andlist { printf("relation_and_exp -> relation_exp andlist\n"); }
			;
relationexplist: 
			OR relation_and_exp relationexplist{ printf("relationexplist -> or relation_and_exp relationexplist\n"); }
			| {printf("relatoinexplist -> EMPTY\n"); }
			;
andlist:
			AND relation_exp andlist {printf("andlist -> and relation_exp andlist\n"); }
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
			IDENT { printf("var -> identifer\n"); }
			| IDENT L_PAREN expression R_PAREN { printf("var -> IDENT L_PAREN expression R_PAREN\n"); }
			;
expression:
			multiplicative_exp exprlist { printf("expression -> multiplicative_exp exprlist\n"); }
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
exprlist:
			ADD multiplicative_exp exprlist  {printf("exprlist -> ADD multiplicative_exp exprlist\n"); }

			| SUB multiplicative_exp exprlist {printf("exprlist -> SUB multiplicative_exp exprlist\n"); }
			| {printf("exprlist -> EMPTY\n"); }
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
	
	yyparse();
	
	if(!error.str().empty()){ //Output error
		cout<<  error.str() << endl;
		return 0;
	}
	

	
	return 0;
}

void yyerror(const char *msg) {
   fprintf(stderr, "%s\n", msg);
}
