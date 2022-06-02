%{
    #include "y.tab.h"
    #include "lex.yy.c"
    #include "functionsFile.h"
    int yylex(void);
    int yyerror(const char* s);
    int main(void);

%}

//Tokens Definition
%union {int INTGR; char* STRNG; float FLT; char CHR;}
%start statement
%token IF ELSE DO WHILE FOR SWITCH CASE BREAK DEFAULT FUNCTION
%token INT CHAR FLOAT STRING CONST BOOL
%token TRUE FALSE
%token SYMBOL_TABLE
%token <INTGR> ID
%token <INTGR> NUM
%token <FLT> FLOATING_NUM
%token <CHR> CHAR_VALUE
%token <STRNG> STRING_VALUE
%token EXIT
%type <INTGR> intMathExpression
%type <INTGR> intHighPriorityExpression
%type <INTGR> intMathElement
%type <FLT> floatMathExpression
%type <FLT> floatHighPriorityExpression
%type <FLT> floatMathElement
%left '+' '-'
%left '*' '/'
%left <STRNG> AND OR NOT EQUALS NOT_EQUALS GREATER_OR_EQUAL LESS_OR_EQUAL GREATER_THAN LESS_THAN

%%

statement                       :   variableDeclarationStatement ';'
                                |   constantDeclarationStatement ';'
                                |   assignStatement ';'
                                |   conditionalStatement ';'
                                |   intMathExpression ';'
                                |   floatMathExpression ';'
                                |   functionStatement {;}
                                |   EXIT ';' {checkExit();}
                                |   showSymbolTable ';' 
                                |   statement variableDeclarationStatement ';'
                                |   statement constantDeclarationStatement ';'
                                |   statement assignStatement ';'
                                |   statement conditionalStatement ';'
                                |   statement intMathExpression ';'
                                |   statement floatMathExpression ';'
                                |   statement functionStatement {;}
                                |   statement EXIT ';' {checkExit();}
                                |   statement showSymbolTable ';'
                                |   statement openBrace statement closeBrace {;}
                                |   openBrace statement closeBrace statement {;}
                                ;

variableDeclarationStatement    :   INT ID {appendVariable($2, 0, -1, -1.0, '\0', NULL, -1); allocateRegister($2);}
                                |   FLOAT ID {appendVariable($2, 1, -1, -1.0, '\0', NULL, -1); allocateRegister($2);}
                                |   CHAR ID {appendVariable($2, 2, -1, -1.0, '\0', NULL, -1); allocateRegister($2);}
                                |   STRING ID {appendVariable($2, 3, -1, -1.0, '\0', NULL, -1); allocateRegister($2);}
                                |   BOOL ID {appendVariable($2, 4, -1, -1.0, '\0', NULL, -1); allocateRegister($2);}
                                |   INT ID '=' intMathExpression  { if(typeIdentifier == 0)
                                                                  { 
                                                                    appendVariable($2, 0, $4, -1.0, '\0', NULL, -1); //Integer Type
                                                                    allocateINTValueToRegisterWithID($2, $4);
                                                                  }
                                                                  else
                                                                  {
                                                                    printf("Type mismatch\n");
                                                                    exit(1);
                                                                  };
                                                                }

                                |   FLOAT ID '=' floatMathExpression { if(typeIdentifier == 1)
                                                                        {
                                                                          appendVariable($2, 1, -1, $4, '\0', NULL, -1); //Float Type
                                                                          allocateFLOATValueToRegisterWithID($2, $4);
                                                                        }
                                                                        else
                                                                        {
                                                                          printf("Type mismatch\n");
                                                                          exit(1);
                                                                        };
                                                                    } 

                                |   CHAR ID '=' CHAR_VALUE  {
                                                              appendVariable($2, 2, -1, -1.0, $4, NULL, -1);
                                                              allocateCHARValueToRegisterWithID($2, $4);
                                                            } //Char Type

                                |   STRING ID '=' STRING_VALUE  {
                                                                  appendVariable($2, 3, -1, -1.0, '\0', $4, -1);
                                                                  allocateSTRINGValueToRegisterWithID($2, $4);
                                                                } //String Type
                                |   BOOL ID '=' TRUE {appendVariable($2, 4, -1, -1.0, '\0', NULL, 1); allocateBOOLValueToRegisterWithID($2, 1);}

                                |   BOOL ID '=' FALSE {appendVariable($2, 4, -1, -1.0, '\0', NULL, 0); allocateBOOLValueToRegisterWithID($2, 0);}
                                ;

constantDeclarationStatement    :   CONST variableDeclarationStatement {;}
                                ;

assignStatement                 :   ID '=' intMathExpression {checkAssignmentCompatibility($1, typeIdentifier);
                                                              if(checkVariableType($3) == -1) //constant value
                                                              {
                                                                appendVariable($1, 0, $3, -1.0, '\0', NULL, -1);
                                                                allocateINTValueToRegisterWithID($1, $3);
                                                              }
                                                              else if(checkVariableType($3) == 0)//variable value
                                                              {
                                                                appendVariable($1, 0, $3, -1.0, '\0', NULL, -1);
                                                                allocateINTValueToRegisterWithID($1, getINTVariableValue($3)); 
                                                              }
                                                              else
                                                              {
                                                                printf("Type mismatch\n");
                                                                exit(1);
                                                              }
                                                            }
                                |   ID '=' floatMathExpression {checkAssignmentCompatibility($1, typeIdentifier);
                                                               if(checkVariableType($3) == -1) //constant value
                                                                {
                                                                  appendVariable($1, 0, -1, $3, '\0', NULL, -1);
                                                                  allocateFLOATValueToRegisterWithID($1, $3);
                                                                }
                                                                else if(checkVariableType($3) == 1)//variable value
                                                                {
                                                                  printf("Type match\n");
                                                                  appendVariable($1, 0, -1, $3, '\0', NULL, -1);
                                                                  allocateFLOATValueToRegisterWithID($1, getFLOATVariableValue($3)); 
                                                                }
                                                                else
                                                                {
                                                                  printf("Type mismatch\n");
                                                                  exit(1);
                                                                } 
                                                            }
                                |   ID '=' CHAR_VALUE {checkAssignmentCompatibility($1, 2); allocateCHARValueToRegisterWithID($1, getCHARVariableValue($1));}
                                |   ID '=' STRING_VALUE {checkAssignmentCompatibility($1, 3); allocateSTRINGValueToRegisterWithID($1, getSTRINGVariableValue($1));}
                                |   ID '=' TRUE {checkAssignmentCompatibility($1, 4); allocateBOOLValueToRegisterWithID($1, 1);}
                                |   ID '=' FALSE {checkAssignmentCompatibility($1, 4); allocateBOOLValueToRegisterWithID($1, 0);}
                                ;

conditionalStatement            :   ifStatement statement{;}
                                |   whileLoopStatement statement {;}
                                |   forLoopStatement statement {;}
                                |   doWhileStatement statement {;}
                                |   switchStatement statement {;}
                                ;

intMathExpression               :   '(' intMathExpression ')' {;}
                                |   intMathExpression '+' intHighPriorityExpression {$$ = $1 + $3; addINTTwoRegisters(getINTVariableValue($1), getINTVariableValue($3));}
                                |   intMathExpression '-' intHighPriorityExpression {$$ = $1 - $3; subINTTwoRegisters(getINTVariableValue($1), getINTVariableValue($3));}
                                |   intHighPriorityExpression {;}
                                ;

intHighPriorityExpression       :   intHighPriorityExpression '*' intMathElement {$$ = $1 * $3; mulINTTwoRegisters(getINTVariableValue($1), getINTVariableValue($3));}
                                |   intHighPriorityExpression '/' intMathElement {$$ = $1 / $3; divINTTwoRegisters(getINTVariableValue($1), getINTVariableValue($3));}
                                |   intMathElement
                                ;

intMathElement                  :   NUM{$$ = $1; typeIdentifier = 0;}
                                |   ID {$$ = getINTVariableValue($1); typeIdentifier = checkVariableType($1);}
                                |   '('intMathExpression')' {$$ = $2;} //If the expreesion contains several operations inside the brackets
                                ;

floatMathExpression             :   '(' floatMathExpression ')' {;}
                                |   floatMathExpression '+' floatHighPriorityExpression {$$ = $1 + $3; addFLOATTwoRegisters(getFLOATVariableValue($1), getFLOATVariableValue($3));}
                                |   floatMathExpression '-' floatHighPriorityExpression {$$ = $1 - $3; subFLOATTwoRegisters(getFLOATVariableValue($1), getFLOATVariableValue($3));}
                                |   floatHighPriorityExpression {;}
                                ;

floatHighPriorityExpression     :   floatHighPriorityExpression '*' floatMathElement {$$ = $1 * $3; mulFLOATTwoRegisters(getFLOATVariableValue($1), getFLOATVariableValue($3));}
                                |   floatHighPriorityExpression '/' floatMathElement {$$ = $1 / $3; divFLOATTwoRegisters(getFLOATVariableValue($1), getFLOATVariableValue($3));}
                                |   floatMathElement
                                ;

floatMathElement                :   FLOATING_NUM{$$ = $1; typeIdentifier = 1;}
                                |   ID {$$ = getFLOATVariableValue($1); typeIdentifier = checkVariableType($1);}
                                |   '('floatMathExpression')' {$$ = $2;} //If the expreesion contains several operations inside the brackets
                                ;

functionStatement               :   FUNCTION ID '(' variableDeclarationStatement ',' variableDeclarationStatement ')' functionOpenBrace statement functionCloseBrace {printf("Function Statement\n");}
                                ;
                                

functionOpenBrace               :   '{' {bracketCounter++; printf("open parenthesis of function\n");}
                                ;

functionCloseBrace              :   '}' {bracketCounter--; printf("closed parenthesis of function\n");}
                                ;

ifStatement                     :   IF {ifStatementBegin();} '(' condition ')' ifOpenBrace statement ifCloseBrace {ifStatementEnd();}
                                |   ELSE IF {ifStatementBegin();}'(' condition ')' ifOpenBrace statement ifCloseBrace {ifStatementEnd();}
                                |   ELSE {ifStatementElseBegin();} elseOpenBrace statement elseCloseBrace {ifStatementElseEnd();}
                                ;

condition                       :   '(' condition ')' {;}
                                |   condition OR highPriorityCondition {;}
                                |   condition AND highPriorityCondition {;}
                                |   NOT condition {;}
                                |   highPriorityCondition {;}
                                ;

highPriorityCondition           :   intMathExpression EQUALS intMathExpression {checkCondition("==", $1, $3);}
                                |   intMathExpression NOT_EQUALS intMathExpression {checkCondition("!=", $1, $3);}
                                |   intMathExpression GREATER_THAN intMathExpression {checkCondition(">", $1, $3);}
                                |   intMathExpression GREATER_OR_EQUAL intMathExpression {checkCondition(">=", $1, $3);}
                                |   intMathExpression LESS_THAN intMathExpression {checkCondition("<", $1, $3);}
                                |   intMathExpression LESS_OR_EQUAL intMathExpression {checkCondition("<=", $1, $3);}
                                ;

ifOpenBrace                     :   '{' {bracketCounter++; printf("open parenthesis of if and bracketCount = %d\n", bracketCounter);}
                                ;

ifCloseBrace                    :   '}' {bracketCounter--; printf("closed parenthesis of if condition and bracketCount = %d\n", bracketCounter);}
                                ;

elseOpenBrace                   :   '{' {bracketCounter++; printf("open parenthesis of else and bracketCount = %d\n", bracketCounter);}
                                ;

elseCloseBrace                  :   '}' {bracketCounter--; printf("closed parenthesis of else and bracketCount = %d\n", bracketCounter);}
                                ;

whileLoopStatement              :   WHILE {loopInitial();}'(' condition ')' whileOpenBrace statement whileCloseBrace {loopEnd();}
                                ;

whileOpenBrace                  :   '{' {bracketCounter++; printf("open parenthesis of while loop\n");}
                                ;

whileCloseBrace                 :   '}' {bracketCounter--; printf("closed parenthesis of while loop\n");}
                                ;

forLoopStatement                :   FOR {loopInitial();}'(' assignStatement forLoopStep1 condition forLoopStep2 assignStatement ')' forLoopOpenBrace statement forLoopCloseBrace {loopEnd();}
                                ;

forLoopStep1                    :   ';' {printf("for loop first semicolon\n");}
                                ;

forLoopStep2                    :   ';' {printf("for loop second semicolon\n");}
                                ;

forLoopOpenBrace                :   '{' {bracketCounter++; printf("open parenthesis of for loop\n");}
                                ;

forLoopCloseBrace               :   '}' {bracketCounter--; printf("closed parenthesis of for loop\n");}
                                ;

doWhileStatement                :   DO '{'{bracketCounter++;} statement '}'{bracketCounter--;} WHILE {loopInitial();} '(' condition ')' {loopEnd();}
                                ;

switchStatement                 :   SWITCH '(' switchStatementVariable ')' switchStatementBody {;}
                                ;

switchStatementVariable         :   ID {
                                          if(checkVariableType($1) == 0)
                                          {
                                              printf("Type match\n");                       
                                          }
                                          else
                                          {
                                              printf("Error... Type mismatch\n");
                                              exit(EXIT_FAILURE);
                                          }
                                       }
                                ;

switchStatementBody             :   openBrace switchCases closeBrace
                                |   openBrace switchCases defaultStatement switchCaseBreakStatement closeBrace
                                ;

switchCases                     :   CASE switchCaseComparater ':' statement switchCaseBreakStatement {printf("Case...\n");}
                                |   switchCases switchCases {printf("Case...\n");}
                                ;

switchCaseComparater            :   NUM {;}
                                |   CHAR_VALUE {;}
                                |   STRING_VALUE {;}
                                |   FLOATING_NUM {;}
                                ;

switchCaseBreakStatement        :   BREAK ';' {;}
                                ;

defaultStatement                :   DEFAULT ':' statement {;}
                                |   DEFAULT ':' {;}

openBrace                       :   '{' {bracketCounter++; printf("open parenthesis of a scope\n");}
                                ;

closeBrace                      :   '}' {bracketCounter--; printf("closed parenthesis of a scope\n");}
                                ;

showSymbolTable                 :   SYMBOL_TABLE {printf("Show Symbol Table\n");} //ADD THIS TO THE END OF THE PROGRAM
                                ;
%%

int yyerror(const char* s)
{
  fprintf(stderr, "%s\n",s);
  return 1;
}

int main(void)
{
  yyparse();
  return 0;
}