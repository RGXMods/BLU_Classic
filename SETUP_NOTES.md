# BLU Classic Setup Notes

## Distribution Sites Setup Required

Once you create the BLU Classic pages on each distribution platform, update the following:

### 1. TOC Files (BLU_Classic.toc and BLU_Classic_Cata.toc)

Replace these placeholder IDs with the actual ones from each platform:

```
## X-Curse-Project-ID: 697841  → Replace with new CurseForge project ID
## X-Wago-ID: vEGPgWK1         → Replace with new Wago.io project ID  
## X-WoWI-ID: 26465            → Replace with new WoWInterface project ID
```

### 2. GitHub Actions Workflow (.github/workflows/release.yml)

Uncomment and update these sections with actual IDs:

```yaml
# CurseForge Upload
project_id: YOUR_CURSEFORGE_PROJECT_ID  → Replace with actual ID

# Wago Upload  
-p YOUR_WAGO_PROJECT_ID                 → Replace with actual ID
-w YOUR_WOWINTERFACE_ID                 → Replace with actual ID
```

### 3. README.md Links

Update download links to point to the new BLU Classic pages:

- CurseForge: `https://www.curseforge.com/wow/addons/blu-classic`
- Wago.io: `https://addons.wago.io/addons/blu-classic`
- WoWInterface: `https://www.wowinterface.com/downloads/info[NEW_ID]-BLU-Classic.html`

## Distribution Platform Checklist

### CurseForge
- [ ] Create new addon project "BLU Classic"
- [ ] Set categories: UI Media, Questing & Leveling, Audio & Video
- [ ] Upload initial v1.0.0 release
- [ ] Get project ID from project settings

### Wago.io
- [ ] Create new addon "BLU Classic"
- [ ] Link to GitHub repository
- [ ] Get project ID from URL or API

### WoWInterface
- [ ] Submit new addon "BLU Classic | Better Level-Up! Classic"
- [ ] Set appropriate categories
- [ ] Get addon ID from URL after approval

## GitHub Secrets Required

Add these secrets to the GitHub repository settings:

1. `CF_API_KEY` - CurseForge API token
2. `WAGO_API_TOKEN` - Wago.io API token
3. `WOWI_USERNAME` - WoWInterface username (if using packager)
4. `WOWI_PASSWORD` - WoWInterface password (if using packager)

## Notes

- Keep BLU and BLU_Classic as replicas until all distribution sites are set up
- Version numbering starts fresh at v1.0.0 for Classic
- Ensure all branding mentions "BLU Classic" not just "BLU"