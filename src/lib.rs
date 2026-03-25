use zed_extension_api::lsp::{Completion, Symbol, SymbolKind};
use zed_extension_api::settings::LspSettings;
use zed_extension_api::{self as zed, CodeLabel, CodeLabelSpan, Result};

struct DamlExtension;

impl zed::Extension for DamlExtension {
    fn new() -> Self {
        Self
    }

    fn language_server_command(
        &mut self,
        language_server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<zed::Command> {
        let lsp_settings = LspSettings::for_worktree(language_server_id.as_ref(), worktree)?;

        // If the user has specified a binary in their LSP settings, use that
        if let Some(binary_settings) = lsp_settings.binary {
            if let Some(path) = binary_settings.path {
                return Ok(zed::Command {
                    command: path,
                    args: binary_settings
                        .arguments
                        .unwrap_or_else(|| vec!["damlc".to_string(), "ide".to_string()]),
                    env: worktree.shell_env(),
                });
            }
        }

        // Try dpm first (newer DPM assistant), then fall back to daml
        let path = worktree
            .which("dpm")
            .or_else(|| worktree.which("daml"))
            .ok_or_else(|| {
                "DAML SDK not found. Install from https://docs.daml.com/getting-started/installation.html"
                    .to_string()
            })?;

        // Use multi-ide for multi-package support (SDK >= 2.9.0)
        let ide_command = if should_use_multi_ide(worktree) {
            "multi-ide"
        } else {
            "ide"
        };

        Ok(zed::Command {
            command: path,
            args: vec!["damlc".to_string(), ide_command.to_string()],
            env: worktree.shell_env(),
        })
    }

    fn label_for_completion(
        &self,
        _language_server_id: &zed::LanguageServerId,
        completion: Completion,
    ) -> Option<CodeLabel> {
        let detail = completion.detail.as_deref()?.trim();
        if detail.is_empty() {
            return None;
        }

        let label = &completion.label;
        // Strip leading :: if the LSP already includes it
        let detail = detail.strip_prefix("::").unwrap_or(detail).trim();

        // Build "name :: type" as valid Haskell code for tree-sitter to highlight
        let separator = " :: ";
        let code = format!("{}{}{}", label, separator, detail);
        let label_len = label.len();
        let detail_start = label_len + separator.len();

        Some(CodeLabel {
            spans: vec![
                CodeLabelSpan::code_range(0..label_len),
                CodeLabelSpan::literal(separator, Some("operator".to_string())),
                CodeLabelSpan::code_range(detail_start..code.len()),
            ],
            filter_range: (0..label_len).into(),
            code,
        })
    }

    fn label_for_symbol(
        &self,
        _language_server_id: &zed::LanguageServerId,
        symbol: Symbol,
    ) -> Option<CodeLabel> {
        let name = &symbol.name;

        let (code, name_start) = match symbol.kind {
            SymbolKind::Class | SymbolKind::Interface => (format!("class {}", name), 6),
            SymbolKind::Struct | SymbolKind::Enum => (format!("data {}", name), 5),
            SymbolKind::Module => (format!("module {}", name), 7),
            SymbolKind::Function | SymbolKind::Method => {
                // Show as type signature for tree-sitter highlighting
                let code = format!("{} :: a", name);
                let len = name.len();
                return Some(CodeLabel {
                    spans: vec![CodeLabelSpan::code_range(0..len)],
                    filter_range: (0..len).into(),
                    code,
                });
            }
            _ => return None,
        };

        let name_end = name_start + name.len();

        Some(CodeLabel {
            spans: vec![CodeLabelSpan::code_range(0..code.len())],
            filter_range: (name_start..name_end).into(),
            code,
        })
    }
}

/// Check if the project should use multi-ide mode by reading the SDK version from daml.yaml.
/// multi-ide requires SDK >= 2.9.0 and supports multi-package projects.
fn should_use_multi_ide(worktree: &zed::Worktree) -> bool {
    let yaml_content = match worktree.read_text_file("daml.yaml") {
        Ok(content) => content,
        Err(_) => return false,
    };

    for line in yaml_content.lines() {
        let line = line.trim();
        if let Some(version_str) = line.strip_prefix("sdk-version:") {
            return version_gte(version_str.trim(), 2, 9);
        }
    }

    false
}

/// Check if a version string (e.g. "3.4.11") is >= major.minor.
fn version_gte(version: &str, min_major: u32, min_minor: u32) -> bool {
    let parts: Vec<&str> = version.split('.').collect();
    if parts.len() < 2 {
        return false;
    }

    let major: u32 = match parts[0].parse() {
        Ok(v) => v,
        Err(_) => return false,
    };
    let minor: u32 = match parts[1].parse() {
        Ok(v) => v,
        Err(_) => return false,
    };

    major > min_major || (major == min_major && minor >= min_minor)
}

zed::register_extension!(DamlExtension);
