/*
http://nolanlawson.github.io/jison-debugger/
http://www.lysator.liu.se/(nobg)/c/ANSI-C-grammar-y.html
http://stackoverflow.com/questions/24397160/jison-google-like-parser
http://stackoverflow.com/questions/27056486/error-handling-in-jison
http://stackoverflow.com/questions/26899381/jison-getting-parsed-token-instead-of-what-is-defined-in-grammar
https://regex101.com/

http://stackoverflow.com/questions/15801592/how-is-this-grammar-ambiguous
*/

/*
 * definition ::= aggr_type ( [ set_expression ] field_expression )
 *
 * From the documentation
 * set_expression ::= { set_entity { set_operator set_entity } }
 * set_entity ::= set_identifier [ set_modifier ]
 * set_identifier ::= 1 | $ | $N | $_N | bookmark_id | bookmark_name
 * set_operator ::= + | - | * | /
 * set_modifier ::= < field_selection {, field_selection } >
 * field_selection ::= field_name [ = | += | ¬–= | *= | /= ] element_set_expression
 * element_set_expression ::= element_set { set_operator element_set }
 * element_set ::= [ field_name ] | { element_list } | element_function
 * element_list ::= element { , element }
 * element_function ::= ( P | E ) ( [ set_expression ] [ field_name ] )
 * element ::= field_value | " search_mask "
 */

/* lexical grammar */
%lex
%options flex case-insensitive

aggr_types                      ("Sum"|"Min"|"Max"|"Only"|"Mode"|"FirstSortedValue"|"MinString"|"MaxString"|"Concat"| "Count"|"NumericCount"|"TextCount"|"NullCount"|"MissingCount"|"Avg"|"stdev"|"median"|"fractile"|"skew"|"kurtosis"|"correl"|"sterr"|"steyx"|"linest_m"|"linest_b"|"linest_r2"|"linest_sem"|"linest_seb"|"linest_sey"|"linest_df"|"linest_f"|"linest_ssreg"|"linest_ssresid")
operators                   	("+"|"-"|"*"|"/")
field_selection_operators       ("="|"+="|"-="|"*="|"/=")

%%

\s+                             /* skip whitespace */
{aggr_types}                    return 'aggr_type';
//{set_operators}                 return 'set_operator';

// ******************************************************************
// set_identifier
// ~~
// See https://regex101.com/r/dF4hX4/9
// ******************************************************************
\$\d+|\$_\d+|^\$|[1][-]\$|[1]{1}|^[1]_\$$|[\$]      		return 'set_identifier';

{field_selection_operators}     							return 'field_selection_operator';
{operators}													return 'operator';
"["															return '[';
"]"															return ']';
#\w+                             							return 'field_inner_expression';
\w+|d+														return 'field_inner_expression';
"{"                             							return '{';
"}"                             							return '}';
"("                             							return '(';
")"                             							return ')';
"<"                             							return 'anglebr_open';
">"                             							return 'anglebr_close';
/*[a-zA-Z0-9]+                    							return 'function_expression'*/
<<EOF>>                         							return "EOF";
/lex

// ##################################################################
// ##################################################################

/* operator associations and precedence */

%left '+' '-'
%left '*' '/'
%left '^'
%left UMINUS

// ##################################################################
// ##################################################################

%start start
%% /* language grammar */



start
    :  definition EOF
        {return $1;}
    ;

// ******************************************************************
// Root
// ******************************************************************
definition

      // Sum(Sales)
    : aggr_type '(' field_expression ')'
        {$$ = $1 + $2 + $3 + $4;}

      // Sum({..}Sales)
    | aggr_type '(' set_expression field_expression ')'
        {$$ = $1 + $2 + $3 + $4 + $5;}
    ;

// ******************************************************************
//
// ******************************************************************
field_expression

	  // Sales
	: field_inner_expression
		{ $$ = $1;}

	  // [Sales]
	| '[' field_inner_expression ']'
		{ $$ = $1 + $2 + $3; }

	  // Units*Price
	| field_expression operator field_expression
		{ $$ = $1 + $2 + $3; }

	|  // [Units]*Price or [Units]*Price-1
		'[' field_expression ']' operator field_expression
		{ $$ = $1 + $2 + $3 + $4 + $5; }
	;

// ******************************************************************
// set_operator ::= + | - | * | /
// ******************************************************************
set_operator
    : '+'
        {$$ = $1;}
/*    | '-'
        {$$ = $1;}*/
    | '*'
        {$$ = $1;}
    | '/'
        {$$ = $1;}
    ;

/*
set_identifier
    : '$'
        {$$ = $1;}
    ;
*/

set_expression
      // {..}
    : '{' set_entity '}'
        { $$ = '{' + $2 + '}';}
    ;

set_entity
    //{$} or {1} or ...
    : set_identifier
        { $$ =  $1; }
    //{$..} or {1..} or ...
    | set_identifier set_modifier
        { $$ = $1 + $2; }
    ;

// set_modifier ::= < field_selection {, field_selection } >
set_modifier
    : anglebr_open anglebr_close
        { $$ = '<>'; }
    // <..>
    | anglebr_open field_selection anglebr_close
        { $$ = '<' + $2 + '>'; }
    ;

//  field_selection ::= field_name [ = | += | ¬–= | *= | /= ] element_set_expression
field_selection
    : field_expression
        { $$ = $1; }
    | field_expression field_selection_operator element_set_expression
        { $$ = $1 + $2 + $3; }
    ;

// element_set_expression ::= element_set { set_operator element_set }
element_set_expression
    : field_expression
        { $$ = $1; }
    ;

// element_set ::= [ field_name ] | { element_list } | element_function
element_set
    : ''
    { $$ = $1; }
    ;

field_name
    : ''
    { $$ = $1; }
    ;

field_value
    : ''
    { $$ = $1; }
    ;

search_mask
    : ''
    { $$ = $1; }
    ;

// element_list ::= element { , element }
element_list
    : ''
    { $$ = $1; }
    ;

// element_function ::= ( P | E ) ( [ set_expression ] [ field_name ] )
element_function
    : ''
    { $$ = $1; }
    ;

// element ::= field_value | " search_mask "
element
    : ''
    { $$ = $1; }
    ;
