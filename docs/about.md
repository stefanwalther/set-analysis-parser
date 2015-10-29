### Why?
The backbone of the new Set Analysis Wizard will be a parser which is able to parse and therefore "decode" existing Set Analysis statements into a structure which can be used in programmatic way.
This is not only beneficial for the Set Analysis Wizard but instead this parser could be used in many other projects.

### Semantic Sugar Layer
On top of that it is the goal to return a descriptive explanation of a Set Analysis statement.

**For example:**
The goal is that you can paste in the following expression

```
Sum({$<Customer=P({1<Product={'Shoe'}>}Customer)>}Sales)
```

and you'll get back the following description

> Returns the Sum of Sales for the current selection, but only for those customers that have bought the product "Shoe".


### The Parser
I have chosen to use [Jison](http://zaach.github.io/jison/) to parse existing Set Analysis statements.

If you have a look into the online documentation of Qlik Sense, you'll find the [BNF](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_Form) syntax for sets there:

```
// Added entry point
definition ::= aggr_type ( set_expression field_expression )

// From the online help
// http://help.qlik.com/sense/2.0/en-US/online/Subsystems/Hub/Content/ChartFunctions/SetAnalysis/syntax-for-sets.htm
set_expression ::= { set_entity { set_operator set_entity } }
set_entity ::= set_identifier [ set_modifier ]
set_identifier ::= 1 | $ | $N | $_N | bookmark_id | bookmark_name
set_operator ::= + | - | * | /
set_modifier ::= < field_selection {, field_selection } >
field_selection ::= field_name [ = | += | ¬–= | *= | /= ] element_set_expression
element_set_expression ::= element_set { set_operator element_set }
element_set ::= [ field_name ] | { element_list } | element_function
element_list ::= element { , element }
element_function ::= ( P | E ) ( [ set_expression ] [ field_name ] )
element ::= field_value | " search_mask "
```
