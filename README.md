# VXJediUI

> A complete ElvUI UI suite for World of Warcraft, built by VXJediXV.  
> Compatible with the latest WoW and ElvUI versions.

---

## Repository Structure

```
VXJediUI-Website/              ← root of your GitHub repo
  VXJediUI.toc
  Core.lua
  ... all addon files ...

docs/
  index.html                ← Your website (deployed to GitHub Pages)

.github/
  workflows/
    release.yml             ← Runs on version tags: packages zip, uploads to CurseForge, creates GitHub Release, deploys site
    deploy-site.yml         ← Runs on pushes to main that touch docs/: just redeploys the site
```

---

## One-time Setup

### 1. Enable GitHub Pages

1. Go to your repo on GitHub → **Settings** → **Pages**
2. Under **Source**, select **GitHub Actions**
3. Save

### 2. Add your Secrets

Go to your repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add these two secrets:

| Secret Name | Where to get it |
|---|---|
| `CURSEFORGE_API_TOKEN` | CurseForge → [My API Tokens](https://authors.curseforge.com/account/api-tokens) → Create token |
| `CURSEFORGE_PROJECT_ID` | Your CurseForge project page URL — the number in `curseforge.com/wow/addons/YOUR-PROJECT/123456` |

> `GITHUB_TOKEN` is automatic — GitHub provides it, you don't need to add it.

### 3. Update the game version ID in release.yml

In `.github/workflows/release.yml`, find this line:

```yaml
game-version-id: '11.0.7'
```

Replace `11.0.7` with the current WoW version ID from CurseForge.  
You can find the correct ID at:  
**CurseForge API** → `https://wow.curseforge.com/api/game/versions` → find the latest retail version.

---

## How to Release a New Version

1. Update your addon version in `VXJediUI.toc`:
   ```
   ## Version: 1.1.0
   ```

2. Update the version in `docs/index.html` if you want (the workflow also does this automatically via `sed`).

3. Commit and push your changes:
   ```bash
   git add .
   git commit -m "Release v1.1.0"
   git push
   ```

4. Tag the release — this is what triggers the full pipeline:
   ```bash
   git tag v1.1.0
   git push origin v1.1.0
   ```

That's it. The workflow then automatically:

- ✅ Packages `VXJediUI/` into `VXJediUI.zip`
- ✅ Uploads the zip to CurseForge as a new file
- ✅ Creates a GitHub Release with the zip attached and a download link
- ✅ Updates the version number on your website
- ✅ Deploys the updated site to GitHub Pages

---

## Download URL Format

Once you've pushed your first release tag, the permanent latest download URL is:

```
https://github.com/VXJediXV/VXJediUI-Website/releases/latest/download/VXJediUI.zip
```

Paste this into your download buttons in `docs/index.html`.  
The workflow also injects the exact version URL on each release.

---

## Updating Just the Website

If you only want to update the site (copy changes, design fixes, no new addon version):

1. Edit `docs/index.html`
2. Commit and push to `main`

The `deploy-site.yml` workflow fires automatically and redeploys — no tag needed.

---

## Local Development

To preview the site locally, just open `docs/index.html` in a browser — it's a single self-contained HTML file with no build step required.
