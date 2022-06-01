%{
    #include <stdlib.h>
    #include <stdio.h>
    #include <string.h>
%}

DIGIT [0-9]
ALPHA [a-zA-Z]
ALPHANUMERIC [0-9a-zA-Z]

%%

"int"                       return INT;
"char"                      return CHAR;
"float"                     return FLOAT;
"string"                    return STRING;
"const"                     return CONST;
"bool"                      return BOOL;
"func"                      return FUNCTION;        
"exit"                      return EXIT;
"symbolTable"               return SYMBOL_TABLE;

"if"                        return IF;
"else"                      return ELSE;
"do"                        return DO;
"while"                     return WHILE;
"for"                       return FOR;
"switch"                    return SWITCH;
"case"                      return CASE;
"break"                     return BREAK;
"default"                   return DEFAULT;
"true"                      return TRUE;
"false"                     return FALSE;


"<="                        return LESS_OR_EQUAL;
">="                        return GREATER_OR_EQUAL;
"!="                        return NOT_EQUALS;
"=="                        return EQUALS;
"<"                         return LESS_THAN;                     
">"                         return GREATER_THAN;
"&&"                        return AND;
"||"                        return OR;
"!"                         return NOT;

[*+-/=%;~&|^(){}:]          {return yytext[0];}

{ALPHA}{ALPHANUMERIC}*      {
                                yylval.INTGR = *yytext-'a';
                                return ID;
                            }

\-?{DIGIT}+	                {   yylval.INTGR = atoi(yytext);
                                return NUM;
                            }

\-?{DIGIT}*"."{DIGIT}+      {
                                yylval.FLT = atof(yytext);
                                return FLOATING_NUM;
                            }

\'.\'                       {
                                yylval.CHR = yytext[1];
                                return CHAR_VALUE;
                            }

\"{ALPHANUMERIC}+\"         {
                                yylval.STRNG = yytext;
                                return STRING_VALUE;
                            }
%%


int yywrap(void)
{
    return 1;
}