// ##################################################################
// Lexical grammar
// ##################################################################
%lex

%options flex case-insensitive

aggr_types                      ("Sum"|"Min"|"Max"|"Only"|"Mode"|"FirstSortedValue"|"MinString"|"MaxString"|"Concat"| "Count"|"NumericCount"|"TextCount"|"NullCount"|"MissingCount"|"Avg"|"stdev"|"median"|"fractile"|"skew"|"kurtosis"|"correl"|"sterr"|"steyx"|"linest_m"|"linest_b"|"linest_r2"|"linest_sem"|"linest_seb"|"linest_sey"|"linest_df"|"linest_f"|"linest_ssreg"|"linest_ssresid")
operators                   	("+"|"-"|"*"|"/")
field_selection_operators       ("="|"+="|"-="|"*="|"/=")

%%

\s+                             /* skip whitespace */
{aggr_types}                    return 'aggr_type';

{field_selection_operators}     							return 'field_selection_operator';
{operators}													return 'operator';
"["															return '[';
"]"															return ']';
"[-\w_:\?]+"												return 'string';
"{"                             							return '{';
"}"                             							return '}';
"("                             							return '(';
")"                             							return ')';
"<"                             							return 'anglebr_open';
">"                             							return 'anglebr_close';
"$"															return "$";
<<EOF>>                         							return "EOF";

/lex

// ##################################################################
// operator associations and precedence
// ##################################################################


%left '+' '-'
%left '*' '/'
%left '^'
%left UMINUS


// ##################################################################
// Language grammar
// ##################################################################

%start start
%%

start
    :  definition EOF
        {return $1;}
    ;

// ******************************************************************
// Root
// ******************************************************************
definition

    // Sum({..}Sales)
    : aggr_type '(' set_expression string ')'
            {$$ = $1 + $2 + $3 + $4 + $5;}
          // Sum(Sales)
    | aggr_type '(' field_expression ')'
        {$$ = $1 + $2 + $3 + $4;}

    ;

// ******************************************************************
//
// ******************************************************************
field_expression

	  // Sales
	: string
		{ $$ = $1;}

	  // [Sales]
	| '[' string ']'
		{ $$ = $1 + $2 + $3; }

	  // Units*Price
	| field_expression operator field_expression
		{ $$ = $1 + $2 + $3; }

	|  // [Units]*Price or [Units]*Price-1
		'[' field_expression ']' operator field_expression
		{ $$ = $1 + $2 + $3 + $4 + $5; }
	;




// ******************************************************************
// set_expression ::= { set_entity { set_operator set_entity } }
// ******************************************************************
set_expression

	: '{' set_entity '}'
		{$$ = $1 + $2 + $3; }
	;


// ******************************************************************
// set_entity ::= set_identifier [ set_modifier ]
// ******************************************************************
set_entity

	: set_identifier
		{$$ = $1; }

	;

// ******************************************************************
// * set_identifier ::= 1 | $ | $N | $_N | bookmark_id | bookmark_name
// ******************************************************************
set_identifier
	: '1'
		{$$ = $1; }
	| '$'
		{$$ = $1; }
	;

// ******************************************************************
// set_operator ::= + | - | * | /
// ******************************************************************
set_operator
    : '+'
        {$$ = $1;}
    | '-'
        {$$ = $1;}
    | '*'
        {$$ = $1;}
    | '/'
        {$$ = $1;}
    ;
