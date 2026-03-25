; Document outline for DAML files

(data_type
  "data" @context
  name: (name) @name) @item

(newtype
  "newtype" @context
  name: (name) @name) @item

(type_synomym
  "type" @context
  name: (name) @name) @item

(decl/function
  name: (variable) @name) @item

(decl/signature
  name: (variable) @name) @item

(class
  "class" @context
  name: (name) @name) @item

(instance
  "instance" @context
  name: (name) @name) @item
