# DAML for Zed

DAML language support for the [Zed](https://zed.dev/) editor.

## Features

- Syntax highlighting for `.daml` files (via tree-sitter-haskell grammar with DAML keyword extensions)
- Language server integration (`damlc ide` / `damlc multi-ide`)
- Multi-package project support (automatic `multi-ide` for SDK >= 2.9.0)
- Document outline (data types, functions, classes, instances)
- Code completion with type signature display
- Bracket matching and indentation
- Text object selections

## Requirements

- [DAML SDK](https://docs.daml.com/getting-started/installation.html) installed and available in your `PATH`
- Supports both `dpm` (preferred) and `daml` commands

## Configuration

The extension works out of the box if `dpm` or `daml` is on your `PATH`. For custom setups, add to your Zed settings (`Cmd+,`):

```json
{
  "lsp": {
    "daml-language-server": {
      "binary": {
        "path": "/path/to/dpm",
        "arguments": ["damlc", "ide"]
      }
    }
  }
}
```

### Multi-IDE mode

For multi-package projects, the extension automatically uses `damlc multi-ide` when your `daml.yaml` declares SDK version >= 2.9.0. To force single-package mode, override the arguments:

```json
{
  "lsp": {
    "daml-language-server": {
      "binary": {
        "arguments": ["damlc", "ide"]
      }
    }
  }
}
```

## License

Apache-2.0
