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
 #include <algorithm>
 
 using namespace std;
 
 // functions
 void yyerror(const char *msg);
 bool is_duplicate(const string var);
 int get_index_by_name(const string var);
 
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
 
 struct status {
 	int label_sz;
 	string loop_label;
 	bool read;
 	bool write;
 	
 	status() {
 		label_sz = 0;
 		loop_label = "";
 		read = false;
 		write = false;
 	}
 };
 
 // containers
 extern FILE * yyin;
 extern char * yytext;
 vector<symbol> symbol_table;
 vector<string> tmp;
 vector<string> pred;
 vector<string> identifiers;
 vector<string> label;
 vector<string> ending_label;
 vector<string> loop;
 vector<string> 
 
 // variables
 extern int currLine;
 extern int currPos;
 status global;
 string fn_name, file;
 
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
program:    functions { }
            ;

functions:  function functions { }
			| { } 
            ;

function:	function IDENT SEMICOLON params locals block END_BODY {
				fn_name = $2;
			} 
			;

params:     BEGIN_PARAMS declarations END_PARAMS { }
            ;

locals:     BEGIN_LOCALS declarations END_LOCALS { }
            | BEGIN_LOCALS END_LOCALS { }
            ;

block:		BEGIN_BODY declarations statements { }
			;

declarations:
			declaration SEMICOLON declarations{ }
			| declaration SEMICOLON { }
	        ;		

declaration:
			IDENT identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {
				if (is_duplicate($1)) {
					error << "Error line " << currLine << ": used array / variable \"" + $1 + "\" is already defined\n";
				}
				else {
					symbol temp(1, atoi($6), $1);
					symbol_table.push_back(temp);
				}
			}
			| IDENT identifiers COLON INTEGER {
				if (is_duplicate($1)) {
					error << "Error line " << currLine << ": used array / variable \"" + $1 + "\" is already defined\n";
				}
				else {
					symbol temp(0, 0, $1);
					symbol_table.push_back(temp);
				}
			}

identifiers:
			COMMA IDENT identifiers {
				if (is_duplicate($2)) {
					error << "Error line " << currLine << ": used array / variable \"" + $2 + "\" is already defined\n";
				}
				else {
					symbol temp(0, 0, $2);
					symbol_table.push_back(temp);
				}
			}
			| { }
			;

statements:	statement SEMICOLON statements { }
			| statement SEMICOLON { }
			;

statement:	var ASSIGN expression {
				// e.g.: =[] dst, src, index; []= dst, index, src
				string var = $1;
				int i1 = var.find(" ", 0);
				if (i1 == string::npos) {
					string expression = $3;
					int i2 = expression.find(" ");
					if (i2 != string::npos) {
						string a = expression.substr(0, i2);
						string b = expression.substr(i2 + 1);
						code << "=[] " << var << ", " << a << ", " << b << endl;
					}
					else code << "= " << var << ", " << expression << endl;
				}
				else {
					string dst = var.substr(0, i1);
					string src1 = var.substr(i1 + 1);
					string src2 = $3;
					
					int i2 = src2.find(" ");
					if (i2 != string::npos) {
						string a = src2.substr(0, i2);
						string b = src2.substr(i2 + 1);
						
						int size = tmp.size();
						tmp.push_back("t" + size);
						code << "=[] " << "t" << size << ", " << a << ", " << b << endl;
						code << "[]= " << src1 << ", " << src2 ", " << "t" << size << endl;
					}
					else code << "[]= " << src1 << ", " << src2 ", " << "t" << size << endl;
				}
			}
			| IF bool_exp THEN statements optionalelse ENDIF { }
			| WHILE {
				label.push_back("L" + global.label_sz);
				global.label_sz++;
				
				code << ": " << label[label.size() - 1] << endl;
				
				global.label_sz++;
				ending_label.push_back("L" + global.label_sz);
			} bool_exp BEGINLOOP statements {
				code << ": " << ending_label[ending_label.size() - 1] << endl;
				ending_label.pop_back();
			} ENDLOOP {
				code << ":= " << label[label.size() - 2] << endl;
				code << ": " << label[label.size() - 1] << endl;
				
				label.pop_back();
				label.pop_back();
			}
			| DO BEGINLOOP {
				loop.push_back("L" + global.label_sz);
				global.label_sz++;
				
				code << ": " << loop[loop.size() - 1] << endl;
				
				global.label_sz++;
				ending_label.push_back("L" + global.label_sz);
			} statements {
				code << ": " << ending_label[ending_label.size() - 1] << endl;
				ending_label.pop_back();
			} ENDLOOP WHILE bool_exp {
				int size = pred.size();
				pred.push_back("p" + pred.size());
				code << "== " << "p" << size << ", " << loop_label << ", 0" << endl;
				code << "?:= " << loop[loop.size() - 1] << ", "
				     << pred[pred.size() - 1] << endl;
				code << ": " << label[label.size() - 1] << endl;
				
				label.pop_back();
				loop.pop_back();
			}
			| READ { global.read = true; } vars { global.read = false; }
			| WRITE { global.write = true; } vars { global.write = false; }
			| CONTINUE { code << ":= " << ending_label[ending_label.size() - 1] << endl; }
            | RETURN expression { }
			;
			
vars:		var COMMA vars {
				index = get_index_by_name($1);
				symbol current_sym;
				if (index != -1) current_sym = symbol_table.at(index); 
				
				if (global.read) {
					if (current_sym.type == 0) code << ".<" << current_sym.name << endl;
					else {
						int i = current_sym.name.find(" ");
						string a = current_sym.name.substr(0, i);
						string b = current_sym.name.substr(i + 1);
						
						code << ".[]< " << a << ", " << b << endl;
					}
				}
				if (globa.write) {
					if (current_sym.type == 0) code << ".> " << current_sym.name << endl;
					else {
						int i = current_sym.name.find(" ");
						string a = current_sym.name.substr(0, i);
						string b = current_sym.name.substr(i + 1);
						
						code << ".[]> " << a << ", " << b << endl;
					}
				}
			}
			| var {
				index = get_index_by_name($1);
				symbol current_sym;
				if (index != -1) current_sym = symbol_table.at(index); 
				
				if (global.read) {
					if (current_sym.type == 0) code << ".<" << current_sym.name << endl;
					else {
						int i = current_sym.name.find(" ");
						string a = current_sym.name.substr(0, i);
						string b = current_sym.name.substr(i + 1);
						
						code << ".[]< " << a << ", " << b << endl;
					}
				}
				if (globa.write) {
					if (current_sym.type == 0) code << ".> " << current_sym.name << endl;
					else {
						int i = current_sym.name.find(" ");
						string a = current_sym.name.substr(0, i);
						string b = current_sym.name.substr(i + 1);
						
						code << ".[]> " << a << ", " << b << endl;
					}
				}
			}
            ;
optionalelse:
			ELSE statements { }
			| { }
			;
bool_exp:
			relation_and_exp relationexplist { }
			;
relation_and_exp: 
			relation_exp andlist {  }
			;
relationexplist: 
			OR relation_and_exp relationexplist{  }
			| { }
			;
andlist:
			AND relation_exp andlist { }
			| { }
			;
relation_exp:
		    NOT	expression comp expression { }
			| NOT TRUE { }
			| NOT FALSE { }
			| NOT  L_PAREN bool_exp R_PAREN  { }
			| expression comp expression { }
			| TRUE { }
			| FALSE { }
			| L_PAREN bool_exp R_PAREN  { }
			;
var:
			IDENT { 
				if(is_duplicate($1)) $$ = $1;
				else error << "Error line " << currLine << ": used array / variable \"" + $1 + "\" is already defined\n";
			}
			| IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
				if(is_duplicate($1) && symbol_table.at(get_index_by_name($1)).type != 1)) {
					string temp = $1 + " " + $3;
					strcpy($$, temp.c_str());
				}
				else error << "Error line " << currLine << ": used array / variable \"" + $1 + "\" is already defined\n";
			}
			;
expression:
			multiplicative_exp exprlist {  }
			;
multiplicative_exp:
			term terms { }
			;
term:
			var { }
			| NUMBER { }
			| L_PAREN expression R_PAREN { }
			| SUB var { }
			| SUB NUMBER { }
			| SUB L_PAREN expression R_PAREN { } 
terms:
			{}
			| terms MULT term { }
			| terms DIV term { }
			| terms MOD term { }
			;
exprlist:
			ADD multiplicative_exp exprlist  { 
				if ($3 != NULL) 
			}

			| SUB multiplicative_exp exprlist { }
			| { }
			;
comp:
			EQ {  }
			| NEQ {  }
			| LT {  }
			| GT {  }
			| LTE {  }
			| GTE {  }
			;

%%

bool is_duplicate(const string var) {
    if (var == fn_name) return true;
    if (get_index_by_name(var) != -1) return true;
    return false;
}

int get_index_by_name(const string var) {
    auto it = find_if(symbol_table.begin(), symbol_table.end(), 
        [&](symbol const& i) { return i.name == var; });
    if (it != symbol_table.end()) return it - symbol_table.begin();
    else return -1;
}

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
