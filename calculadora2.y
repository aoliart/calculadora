/* Este archivo contiene un reconocedor de expresiones aritm�ticas junto
   con algunas reglas sem�nticas que calculan los valores de las
   expresiones que se reconocen. Las expresiones son muy sencillas y
   consisten �nicamente de sumas, restas, multiplicaciones y divisiones de
   n�meros enteros. 

   Autor: Alberto Oliart Ros */

%{
#include<stdio.h>
#include<stdlib.h>
#include<math.h>
  typedef struct nodo_arbol_tag {
    int tipo;  /* Hay dos tipos, operador y operando. 1 es operando y 0 operador */
    int valor; /* Si es un operando, el valor del operando. */
    int oper; /* Indica qu� operador se trata si acaso es un operador */
    struct nodo_arbol_tag* izq;
    struct nodo_arbol_tag* der;
  }nodo_arbol;

#define YYSTYPE nodo_arbol *

nodo_arbol * crea_nodo_operador(int, nodo_arbol*, nodo_arbol*);
nodo_arbol * crea_nodo_operando(int);
int interpreta(nodo_arbol *);

char* yytext;
%}

/* Los elementos terminales de la gram�tica. La declaraci�n de abajo se
   convierte en definici�n de constantes en el archivo calculadora.tab.h
   que hay que incluir en el archivo de flex. */



%token NUM SUMA RESTA DIVIDE MULTI PAREND PARENI FINEXP
%start exp

%%

exp : expr FINEXP {printf("Valor = %d\n", interpreta($1));}
;

expr : expr SUMA term    {$$ = crea_nodo_operador(SUMA, $1, $3);}
     | expr RESTA term   {$$ = crea_nodo_operador(RESTA, $1, $3);}
     | term              {$$ = $1;}
;

term : term MULTI factor   {$$ = crea_nodo_operador(MULTI, $1, $3);}
     | term DIVIDE factor  {$$ = crea_nodo_operador(DIVIDE, $1, $3);}
     | factor              {$$ = $1;}
;

factor : PARENI expr PAREND  {$$ = $2;}
       | NUM                 {$$ = crea_nodo_operando(atoi(yytext));}
;

%%

nodo_arbol* crea_nodo_operando(int valor) {

  nodo_arbol* nodo = (nodo_arbol*) malloc(sizeof(nodo_arbol));
  nodo -> tipo = 1;
  nodo -> valor = valor;
  nodo -> izq = NULL;
  nodo -> der = NULL;
  return nodo;
}

nodo_arbol* crea_nodo_operador(int operador, nodo_arbol* izq, nodo_arbol* der) {

  nodo_arbol* nodo = (nodo_arbol*) malloc(sizeof(nodo_arbol));
  
  nodo -> tipo = 0;
  nodo -> valor = 0;
  nodo -> oper = operador;
    nodo -> izq = izq;
  nodo -> der = der;
  return nodo;
}

int interpreta(nodo_arbol * exp) {

  int x,y;
  
  if (exp -> tipo) return exp -> valor;
  else {

    switch (exp -> oper) {
    case SUMA : return interpreta(exp -> izq) + interpreta(exp -> der);
      break;
    case RESTA : return interpreta(exp -> izq) - interpreta(exp -> der);
      break;
    case MULTI : return interpreta(exp -> izq) * interpreta(exp -> der);
      break;
    case DIVIDE : 
      x = interpreta(exp -> izq);
      y = interpreta(exp -> der);
      if (y == 0) {
	  printf("Error fatal, divisi�n por cero\n");
	  exit(1);
	}
      else return x/y;
      break;
    default : printf("Error fatal\n");
    }
  }
}

int yyerror(char const * s) { 
  fprintf(stderr, "%s\n", s);
}

void main() {

  yyparse();
}

