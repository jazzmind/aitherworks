# AItherworks — Brass & Steam Edition

Welcome to **AItherworks**, a steampunk puzzle‑sim in which you build and train artificial minds using gears, valves and aether.  The goal of this repository is to provide a clean foundation for developing the game in [Godot 4](https://godotengine.org/) with a data‑driven workflow.  A small set of scenes and scripts are provided to get you started; the rest of the content can be generated automatically by a custom editor plugin and large language models (LLMs).

## Project Overview

This repository uses the following top‑level structure:

- `addons/steamfitter/` – a custom Godot editor plugin intended to import YAML specifications and generate Godot scenes and scripts.  At the moment it contains only a stub plugin (`plugin.gd`) and configuration file (`plugin.cfg`).  You can expand this plugin to create levels from JSON/YAML specs automatically.
- `data/specs/` – location for puzzle specifications.  Each file should follow a schema describing the allowed parts, budgets and win conditions for a level.  See the example `example_puzzle.yaml` for guidance.
- `data/parts/` – location for part definitions.  Each file describes a machine component (e.g. Weight Wheel, Matrix Frame, Looking‑Glass Array) in a format the editor can interpret.
- `game/` – the runtime side of the game.  This contains reusable scenes and scripts used by generated levels.  For instance, `game/parts/` holds basic scenes for the core parts (with placeholders), and `game/sim/` contains a stub script for the deterministic simulation.
- `art/` – a placeholder folder for meshes, textures and other assets.  When you start modelling, drop your `.glb` or `.png` files here.
- `tools/ci/` – helpers for continuous integration.  You can add scripts here to run headless imports, baking and multi‑platform exports.
- `export_presets.cfg` – a sample Godot export preset file enabling desktop, web and mobile builds.  Adjust these to suit your target platforms.

For a more in‑depth design, refer to the design documents provided earlier in the conversation.  The long‑term intention is to maintain a clear separation between content (data) and behaviour (code), enabling AI‑assisted generation of levels and parts.

## Getting Started

1. Install [Godot 4.x](https://godotengine.org/download).  Clone this repository into a working directory.
2. Open Godot and import the project by selecting the `aitherworks` folder.  You should see a nearly empty project with the folder structure described above.
3. Explore the `addons/steamfitter` plugin.  The plugin is disabled by default; enable it in the **Project → Project Settings → Plugins** tab and experiment with extending it to parse YAML specs and generate scenes.
4. Review the sample YAML specification in `data/specs/example_puzzle.yaml` and the sample part definition in `data/parts/example_part.yaml`.  These illustrate the data format expected by the plugin.
5. Use the `cursor_rules.md` and `CLAUDE.md` documents to guide your use of AI in this project.  They define conventions and constraints for AI‑driven editing with the Cursor IDE and Claude models respectively.

## Web Deployment

AItherworks can be deployed to the web using Godot's WebAssembly export and a Next.js wrapper. The game runs directly in the browser with near-native performance.

### Quick Start

1. **Export the game to WASM:**
   ```bash
   ./scripts/export_web.sh
   ```

2. **Build and run the web app:**
   ```bash
   cd web
   npm install
   npm run dev
   ```

3. **Deploy to Vercel:**
   - Push to GitHub
   - Import project in Vercel
   - Set root directory to `web`
   - Deploy!

For detailed instructions, see [docs/web_deployment.md](docs/web_deployment.md).

### Architecture

- **Godot 4** game compiled to WebAssembly (WASM)
- **Next.js 15** static site wrapper with loading UI
- **Vercel** hosting with proper CORS headers for SharedArrayBuffer support

## License

This scaffold is provided under the **MIT License**.  See the `LICENSE` file (to be added) for details.  You are free to use, modify and distribute this code as long as the license terms are respected.