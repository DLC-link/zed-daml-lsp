use zed_extension_api::settings::LspSettings;
use zed_extension_api::{self as zed, Result};

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
                    args: binary_settings.arguments.unwrap_or_else(|| vec!["damlc".to_string(), "ide".to_string()]),
                    env: worktree.shell_env(),
                });
            }
        }

        // Default to daml in PATH
        let path = worktree
            .which("daml")
            .ok_or_else(|| "DAML SDK not found. Install from https://docs.daml.com/getting-started/installation.html".to_string())?;

        Ok(zed::Command {
            command: path,
            args: vec!["damlc".to_string(), "ide".to_string()],
            env: worktree.shell_env(),
        })
    }
}

zed::register_extension!(DamlExtension);
