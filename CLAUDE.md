# Salesforce Cosmos Themes

## Publishing to VS Code Marketplace

Publisher ID: `digitalchemist`

### Authentication

`vsce login` is broken with org-scoped PATs (fails with TF400813). This is a known architectural issue — `login` hits the Security Roles API which rejects org-scoped tokens, while `publish --pat` hits the Gallery API which accepts them.

Always use `--pat` directly:

```sh
npx @vscode/vsce publish --pat "<PAT>"
```

Or set the env var (vsce reads it automatically):

```sh
export VSCE_PAT="<PAT>"
npx @vscode/vsce publish
```

### PAT requirements

- Created at https://dev.azure.com under the **adigitalchemist@gmail.com** account
- Organization: `adigitalchemist`
- Scope: Marketplace > Manage
- Global PATs ("All accessible organizations") are being retired — use org-scoped

### Publish workflow

```sh
npx @vscode/vsce publish --pat "$VSCE_PAT"
```

To bump version and publish in one step:

```sh
npx @vscode/vsce publish patch --pat "$VSCE_PAT"   # 1.0.0 -> 1.0.1
npx @vscode/vsce publish minor --pat "$VSCE_PAT"   # 1.0.0 -> 1.1.0
npx @vscode/vsce publish major --pat "$VSCE_PAT"   # 1.0.0 -> 2.0.0
```

### Pre-publish checklist

- Ensure `.vscodeignore` excludes `resources/originals/**` (large PNGs)
- Ensure `cosmos-tokens-full.json` and theme JSONs are in sync
- Verify with `npx @vscode/vsce ls` to see what will be packaged

### Future: Azure credential (no PAT)

```sh
npx @vscode/vsce publish --azure-credential
```

Uses Azure CLI login or managed identity. No PAT rotation needed. Not yet fully documented by Microsoft but functional.
