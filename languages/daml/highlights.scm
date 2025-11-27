; ----------------------------------------------------------------------------
; DAML-specific keywords (treated as regular identifiers by Haskell grammar)
; These need to be at the top for higher priority
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
    ; Exception
    "exception"
    "message"
    "throw"
    ; Contract references
    "this"
    "self"
    ; Ledger actions
    "create"
    "exercise"
    "exerciseByKey"
    "fetch"
    "fetchByKey"
    "lookupByKey"
    "archive"
    "createAndExercise"
    ; Script/testing
    "script"
    "submit"
    "submitMustFail"
    "submitMulti"
    "submitMultiMustFail"
    "query"
    "queryContractId"
    "queryContractKey"
    "allocateParty"
    "allocatePartyWithHint"
    ; Commands
    "createCmd"
    "exerciseCmd"
    "exerciseByKeyCmd"
    "createAndExerciseCmd"
    "archiveCmd"
    ; Control flow
    "abort"
    "assert"
    "assertMsg"
    "assertAfter"
    "assertBefore"
    "error"
    "debug"
    "trace"
    ; Time
    "getTime"
    "pass"
    "passToDate"
    "setTime"
    ; Monadic
    "pure"
    "return"
    "when"
    "unless"
    "forA"
    "forA_"
    "mapA"
    "mapA_"
    "sequence"
    ; Optional
    "Some"
    "None"
    "optional"
    "fromSome"
    "fromOptional"
    "isSome"
    "isNone"
    ; Either
    "Left"
    "Right"
    "either"
    "fromLeft"
    "fromRight"
    "isLeft"
    "isRight"
    ; Common functions
    "fmap"
    "void"
    "identity"
    "const"
    "flip"
    "coerce"
    "toParties"
    "partyToText"
    "partyFromText"
    "intToDecimal"
    "truncate"
    "round"
    "ceiling"
    "floor"
    "show"))

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

(char) @character

(string) @string

(unit) @string.special.symbol ; unit, as in ()

(comment) @comment

((haddock) @comment.documentation)

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

(apply
  [
    (expression/variable) @function.call
    (expression/qualified
      (variable) @function.call)
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
; Exceptions/error handling
((variable) @keyword.exception
  (#any-of? @keyword.exception
    "error" "undefined" "try" "tryJust" "tryAny" "catch" "catches" "catchJust" "handle" "handleJust"
    "throw" "throwIO" "throwTo" "throwError" "ioError" "mask" "mask_" "uninterruptibleMask"
    "uninterruptibleMask_" "bracket" "bracket_" "bracketOnErrorSource" "finally" "fail"
    "onException" "expectationFailure"))

; ----------------------------------------------------------------------------
; Fields
(field_name
  (variable) @variable.member)

(import_name
  (name)
  .
  (children
    (variable) @variable.member))
