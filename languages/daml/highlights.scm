; ============================================================================
; DAML syntax highlighting for Zed (tree-sitter-haskell grammar)
; ============================================================================

; ----------------------------------------------------------------------------
; Parameters and variables
; NOTE: These are at the top, so that they have low priority,
; and don't override destructured parameters
(variable) @variable

(pattern/wildcard) @variable

(decl/function
  patterns: (patterns
    (_) @variable.parameter))

(expression/lambda
  (_)+ @variable.parameter
  "->")

(decl/function
  (infix
    (pattern) @variable.parameter))

; ----------------------------------------------------------------------------
; Literals and comments
(integer) @number

(negation) @number

(expression/literal
  (float)) @number

(char) @string

(string) @string

(unit) @string.special.symbol ; unit, as in ()

(comment) @comment

((haddock) @comment)

; ----------------------------------------------------------------------------
; Punctuation
[
  "("
  ")"
  "{"
  "}"
  "["
  "]"
] @punctuation.bracket

[
  ","
  ";"
] @punctuation.delimiter

; ----------------------------------------------------------------------------
; Keywords, operators, includes
[
  "forall"
] @keyword

(pragma) @attribute

[
  "if"
  "then"
  "else"
  "case"
  "of"
] @keyword

[
  "import"
  "qualified"
  "module"
] @keyword

[
  (operator)
  (constructor_operator)
  (all_names)
  (wildcard)
  "."
  ".."
  "="
  "|"
  "::"
  "=>"
  "->"
  "<-"
  "\\"
  "`"
  "@"
] @operator

(module
  (module_id) @module)

[
  "where"
  "let"
  "in"
  "class"
  "instance"
  "pattern"
  "data"
  "newtype"
  "family"
  "type"
  "as"
  "hiding"
  "deriving"
  "via"
  "stock"
  "anyclass"
  "do"
  "mdo"
  "rec"
  "infix"
  "infixl"
  "infixr"
] @keyword

; ----------------------------------------------------------------------------
; Functions and variables
(decl
  [
   name: (variable) @function
   names: (binding_list (variable) @function)
  ])

(decl/bind
  name: (variable) @variable)

; Consider signatures (and accompanying functions)
; with only one value on the rhs as variables
(decl/signature
  name: (variable) @variable
  type: (type))

(decl/bind
  name: (variable) @function
  (match
    expression: (expression/lambda)))

; view patterns
(view_pattern
  [
    (expression/variable) @function.call
    (expression/qualified
      (variable) @function.call)
  ])

; consider infix functions as operators
(infix_id
  [
    (variable) @operator
    (qualified
      (variable) @operator)
  ])

; function calls with infix operator (e.g. func <$> a)
(infix
  [
    (variable) @function.call
    (qualified
      ((module) @module
        (variable) @function.call))
  ]
  .
  (operator))

; function calls with $ and bind operators
([
    (expression/variable) @function.call
    (expression/qualified
      (variable) @function.call)
  ]
  .
  (operator) @_op
  (#any-of? @_op "$" "<$>" ">>=" "=<<"))

; function composition (lhs)
(
  [
    (expression/variable) @function
    (expression/qualified
      (variable) @function)
  ]
  .
  (operator) @_op
  (#any-of? @_op "." ">>>" "***" ">=>" "<=<"))

; function composition (rhs)
((operator) @_op
  .
  [
    (expression/variable) @function
    (expression/qualified
      (variable) @function)
  ]
  (#any-of? @_op "." ">>>" "***" ">=>" "<=<"))

; function composition in definition
(decl/function
  name: (variable) @function
  (match
    expression: (infix
      operator: (operator) @_op
      (#any-of? @_op "." ">>>" "***" ">=>" "<=<"))))

(apply
  [
    (expression/variable) @function.call
    (expression/qualified
      (variable) @function.call)
  ])

; variables being passed to a function call
(apply
  (_)
  .
  [
    (expression/variable) @variable
    (expression/qualified
      (variable) @variable)
  ])

; main is always a function
(decl/bind
  name: (variable) @function
  (#eq? @function "main"))

; scoped function types (func :: a -> b)
(signature
  pattern: (pattern/variable) @function
  type: (quantified_type))

; signatures that have a function type
(decl/signature
  name: (variable) @function
  type: (quantified_type))

; ----------------------------------------------------------------------------
; Types
(name) @type

(type/star) @type

(constructor) @constructor

; True or False
((constructor) @boolean
  (#any-of? @boolean "True" "False"))

; otherwise (= True)
((variable) @boolean
  (#eq? @boolean "otherwise"))

; ----------------------------------------------------------------------------
; Quasi-quotes
(quoter) @function.call

; ----------------------------------------------------------------------------
; Fields
(field_name
  (variable) @variable.member)

(import_name
  (name)
  .
  (children
    (variable) @variable.member))

; ============================================================================
; DAML-specific keywords
; These are at the bottom for highest priority — they override any previous
; matches for variables/functions that happen to be DAML keywords.
; ============================================================================
((variable) @keyword
  (#any-of? @keyword
    ; Template structure
    "template"
    "choice"
    "controller"
    "can"
    "signatory"
    "observer"
    "ensure"
    "agreement"
    "key"
    "maintainer"
    "with"
    ; Consuming annotations
    "preconsuming"
    "postconsuming"
    "nonconsuming"
    ; Interface
    "interface"
    "requires"
    "viewtype"
    "view"
    "implements"
    "method"
    "for"
    ; Exception
    "exception"
    "message"
    "throw"))
