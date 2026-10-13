# Documentation Repository

This repository contains the Lean code and the documentation of a research project whose objective is to **build mathematical proofs with the Lean 4 theorem prover** (University of Alberta). It combines:

* a **Lean 4 library** (`ResearchLean`, in `ResearchLean/`) built with Lake on top of **Mathlib**; every theorem is checked by `lake build`;
* a **MyST / Jupyter Book 2** site (`docs/`) that explains the proofs, embeds their Lean source, and exports PDFs;
* large files (data, literature PDFs, images) that are **not versioned in git** and are synchronized with **Google Drive** through `rclone`.

| What | Where it lives | How it is synchronized |
|---|---|---|
| Lean code, configs, docs, notebooks, `references.bib` | GitHub `juantztz/research-project-lean` | `git pull` / `git push` |
| Data (`_data/`), literature PDFs, images (`docs/assets/_*`) | Google Drive `gdriveuofa:repositories/research-project-lean` | `make -f MAKE pull_drive` / `push_drive` / `sync_drive` |
| Lean toolchain (`~/.elan`) and Mathlib (`.lake/`) | Local only | `elan` reads `lean-toolchain`; `lake exe cache get` reads `lakefile.toml` + `lake-manifest.json` |
| Python environment (`.venv/`) for Jupyter Book | Local only | `uv sync` from `pyproject.toml` + `uv.lock` |

---

## Quick start

For someone who already has the prerequisites installed:

```bash
cd ~/Documents/repositories                      # any parent folder works
git clone git@github.com:juantztz/research-project-lean.git
cd research-project-lean
rclone config                                    # once: create the "gdriveuofa" remote (see below)
bash setup.sh                                    # pulls Drive data, creates .venv, downloads Mathlib, builds the library
make -f MAKE start_jupyter                       # live preview of the book at http://localhost:3000
```

---

(content:documentacion:requisitos)=
## Technical requirements

| Tool | Needed for | Install |
|---|---|---|
| `git` + SSH key on GitHub | Cloning and pushing code; Lake also uses git to fetch Mathlib | [GitHub SSH guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh) |
| `elan` | Installs the Lean version written in `lean-toolchain` (Lean, `lake`) | `curl https://elan.lean-lang.org/elan-init.sh -sSf \| sh -s -- -y --default-toolchain none` · [install guide](https://lean-lang.org/install/) |
| VS Code + *Lean 4* extension | Interactive proving (Infoview with goals and errors) | [VS Code](https://code.visualstudio.com/) · extension `leanprover.lean4` (recommended in `.vscode/extensions.json`) |
| `uv` | Python 3.11–3.13 environment for Jupyter Book 2 | macOS: `brew install uv` · Linux: `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| Node.js ≥ 18 | Jupyter Book 2 (MyST) runtime; offered automatically on the first build if missing | [nodejs.org](https://nodejs.org/) or `brew install node` |
| `rclone` | Google Drive synchronization | macOS: `brew install rclone` · Linux: `curl https://rclone.org/install.sh \| sudo bash` |
| `make` | Running the `MAKE` targets | macOS: `xcode-select --install` · Linux: `sudo apt install build-essential` |
| GitHub CLI (`gh`) | Issues, labels, pull requests from the terminal | macOS: `brew install gh` · Linux: [install guide](https://github.com/cli/cli/blob/trunk/docs/install_linux.md) |
| LaTeX (`xelatex`/`pdflatex`) | PDF exports of the book only | macOS: [MacTeX](https://tug.org/mactex/) · Linux: `sudo apt install texlive-full` |

`make -f MAKE dependencies` installs `rclone`, `uv`, and `elan` with their official install scripts. Mathlib needs about **6 GB** of disk space in `.lake/`.

---

## First-time setup

### 1. Clone the repository

```bash
cd ~/Documents/repositories
git clone git@github.com:juantztz/research-project-lean.git
cd research-project-lean
```

The `MAKE` file resolves local paths from the folder it is run in, so the clone can have any name; the Google Drive folder is always `repositories/research-project-lean`.

### 2. Install the Lean toolchain

```bash
curl https://elan.lean-lang.org/elan-init.sh -sSf | sh -s -- -y --default-toolchain none
source ~/.elan/env                     # or open a new terminal
elan --version
```

There is no need to choose a Lean version: inside the repository, `elan` reads `lean-toolchain` (currently `leanprover/lean4:v4.35.0`) and downloads that exact version the first time `lean` or `lake` runs.

### 3. Configure the Google Drive remote (once per computer)

The `MAKE` file expects an rclone remote called **`gdriveuofa`** whose root contains the folder `repositories/research-project-lean`. It is the same remote used by `research-project-py`; skip this step if `rclone listremotes` already prints `gdriveuofa:`.

```bash
rclone config
#   n  -> new remote
#   name> gdriveuofa
#   Storage> drive            (Google Drive)
#   client_id / client_secret -> leave empty (or use your own)
#   scope> 1                  (full access)
#   Edit advanced config? n
#   Use web browser to authenticate? y   -> log in with the University of Alberta Google account
#   Configure as a Shared Drive? n
rclone listremotes                                     # should print gdriveuofa:
rclone lsd gdriveuofa:repositories/research-project-lean  # lists _data and docs (after the first push)
```

On a remote server without a browser, answer `n` to the browser question and follow the `rclone authorize "drive"` instructions on your laptop.

### 4. Download data and assets from Google Drive

```bash
make -f MAKE pull_drive              # dry run: shows what would be copied
make -f MAKE pull_drive DRYRUN=""    # actually copies
```

This copies `_data/` and `docs/assets/{_imagenes,_literature}` into the local repository.

### 5. Install the Python environment (Jupyter Book 2)

```bash
uv sync                    # creates .venv with the exact versions in uv.lock (jupyter-book)
uv sync --extra dev        # optional: jupyterlab, ipykernel, ipywidgets
uv run jupyter book --version
```

Activate the environment with `source .venv/bin/activate`, or prefix commands with `uv run`. There is no Python package in this repository (`package = false` in `pyproject.toml`); uv only manages the environment.

### 6. Download Mathlib and build the library

```bash
make -f MAKE get_cache       # same as: lake exe cache get   (downloads Mathlib and its precompiled .olean files)
make -f MAKE build_lean      # same as: lake build           (checks every proof in ResearchLean)
```

```{important}
Always run `lake exe cache get` before the first `lake build` and after every Mathlib update. Without the cache, Lake compiles Mathlib from source, which takes hours.
```

`make -f MAKE setup` runs steps 5–6 (`uv sync --extra dev`, `lake exe cache get`, `lake build`) and then installs the build tools for the operating system: `build-essential` via `apt` on Linux, the Xcode Command Line Tools on macOS (only if they are missing).

### 7. Verify the setup

```bash
lake env lean ResearchLean/Tutorial.lean     # prints the #eval / #check outputs, no errors
make -f MAKE check_sorry                     # "No sorry found"
code .                                       # open ResearchLean/Basic.lean; the Infoview shows the goals
```

`setup.sh` automates steps 4–6: it checks for `git`, `rclone`, `uv`, `elan`, and `make` (and warns if LaTeX is missing), pulls `_data` and `docs/assets` from Drive when the `gdriveuofa` remote exists, and runs `make setup`. Run it after steps 2–3 with `bash setup.sh` (it can be called from any folder; `MAKEFILE=<file>` overrides the default `MAKE`).

---

## Daily workflow

### Code: pull and push with git

```bash
git pull origin master                          # start of the day
git checkout -b number-theory/infinite-primes   # branch pattern: TOPIC/FEATURE NAME
# ... write proofs ...
lake build                                      # must succeed before committing
git add <files>
git commit -m "[NEW] prove infinitude of primes"
git push -u origin number-theory/infinite-primes
```

Commit messages start with one of `[NEW]`, `[UPDATE]`, `[FIX]`, `[DELETE]` (see *Project rules* below). Never commit `.lake/`, data, PDFs, or anything inside a folder that starts with `_` — those are rebuilt locally or go to Google Drive. GitHub Actions (`.github/workflows/lean.yml`) runs `lake build` on every push and pull request.

### Data and assets: pull and push with Google Drive

Google Drive is the **source of truth** for everything listed in `.gitignore` except `.lake/` and `.venv/`. All `MAKE` targets run as a **dry run by default** (`DRYRUN=--dry-run`); add `DRYRUN=""` to transfer files.

| Command | Direction | Effect |
|---|---|---|
| `make -f MAKE pull_drive DRYRUN=""` | Drive → local | Copies new/changed files of `_data/` and `docs/assets/_*`. Never deletes local files. |
| `make -f MAKE push_drive DRYRUN=""` | local → Drive | Copies new/changed local files to Drive. Never deletes Drive files. |
| `make -f MAKE sync_drive DRYRUN=""` | Drive → local | Makes local **identical** to Drive: **deletes local files that are not on Drive**. |
| `make -f MAKE chek_diff_drive` | — | Writes a Drive-vs-local difference report to `_data/sims/debug/rclone/`. |
| `make -f MAKE pull_one DIR=docs/assets/_literature DRYRUN=""` | Drive → local | Copies one folder. |
| `make -f MAKE push_one DIR=docs/assets/_imagenes DRYRUN=""` | local → Drive | Copies one folder. |
| `make -f MAKE sync_one DIR=docs/assets/_literature DRYRUN=""` | Drive → local | Mirrors one folder (deletes local extras). |
| `make -f MAKE pull_file FILE=docs/assets/_literature/moura2021lean4.pdf DRYRUN=""` | Drive → local | Copies one file. |
| `make -f MAKE push_file FILE=docs/assets/_literature/moura2021lean4.pdf DRYRUN=""` | local → Drive | Copies one file. |

`DIR` and `FILE` are relative to the repository root. Paths listed in `.rcignore` are skipped by the `sync`, `pull_one`, and `check` targets.

**Rules for Drive files**

1. Add, rename, update, or delete files **on Google Drive** (web or mounted drive), then run `pull_drive` (or `sync_drive` to propagate deletions).
2. The only change allowed from local is **adding new files**, which are then uploaded with `push_drive`/`push_one`/`push_file`.
3. Always run the dry run first, especially before `sync_drive`/`sync_one`, because they delete local files.
4. Name literature PDFs by their citation key in `docs/references.bib` (e.g. `moura2021lean4.pdf`).

A typical day:

```bash
git pull origin master
make -f MAKE pull_drive DRYRUN=""
# ... write proofs, add PDFs or images ...
lake build
make -f MAKE push_drive                 # review the dry run
make -f MAKE push_drive DRYRUN=""
git add ... && git commit -m "[UPDATE] ..." && git push
```

---

(content:documentacion:lean)=
## Writing proofs in Lean

### Interactive work

Open the repository folder (not a single file) in VS Code. With the *Lean 4* extension, the **Infoview** (`Ctrl+Shift+Enter` / `Cmd+Shift+Enter`) shows the goal at the cursor, errors, and the output of `#eval`/`#check`. A file is correct when the Infoview shows no red errors and the theorem has no `sorry` warning.

Useful commands while proving:

| Command / tactic | Purpose |
|---|---|
| `#check Nat.exists_infinite_primes` | Show the statement of a lemma. |
| `exact?` / `apply?` | Search Mathlib for a lemma that closes / advances the goal. |
| `simp?` | Run `simp` and print the lemmas it used (replace it with `simp only [...]`). |
| `rw?` | Search for rewrite rules. |
| `omega`, `decide`, `norm_num`, `ring`, `linarith`, `nlinarith`, `positivity` | Automation for arithmetic, decidable facts, and inequalities. |
| `sorry` | Placeholder for an unfinished proof (compiles with a warning). |

Searching Mathlib: [Loogle](https://loogle.lean-lang.org/) (search by type/pattern), [Mathlib docs](https://leanprover-community.github.io/mathlib4_docs/), and the [Zulip chat](https://leanprover.zulipchat.com/).

### Adding a new file

1. Create `ResearchLean/<Topic>.lean`, starting with `import Mathlib` (or a narrower import, e.g. `import Mathlib.NumberTheory.Primes`) and `namespace ResearchLean`.
2. Add `import ResearchLean.<Topic>` to `ResearchLean.lean`; `lake build` only compiles modules imported there.
3. Run `lake build`.
4. Document it in `docs/docs/proofs/<topic>.md` with a `{literalinclude}` of the file (see `docs/docs/proofs/basic.md`) and add the page to `docs/toc.yml`.

### Lean commands

| Command | Effect |
|---|---|
| `make -f MAKE build_lean` | `lake build`: compiles and checks every module of `ResearchLean`. |
| `lake env lean ResearchLean/Basic.lean` | Checks a single file. |
| `make -f MAKE check_sorry` | Lists every `sorry` in the library. |
| `make -f MAKE get_cache` | `lake exe cache get`: downloads precompiled Mathlib. |
| `make -f MAKE clean_lean` | `lake clean`: deletes the build of `ResearchLean` (keeps Mathlib). |
| `make -f MAKE update_lean` | Moves to the newest Lean and Mathlib (see below). |

### Updating Lean and Mathlib

The Lean version (`lean-toolchain`) and the Mathlib version (`rev` in `lakefile.toml`, locked in `lake-manifest.json`) must match. To update:

1. Set `rev` in `lakefile.toml` to the new Mathlib tag (e.g. `"v4.36.0"`, list them with `git ls-remote --tags https://github.com/leanprover-community/mathlib4 'v4.*'`) and write the same version in `lean-toolchain` (`leanprover/lean4:v4.36.0`).
2. Run `lake update && lake exe cache get && lake build`.
3. Fix any proof broken by renamed lemmas and commit `lakefile.toml`, `lean-toolchain`, and `lake-manifest.json` together.

`make -f MAKE update_lean` runs step 2 after downloading Mathlib's current `lean-toolchain`; use it only when `rev` points to a tag of that same version.

---

(content:documentacion:issues)=
## Managing issues, labels, and projects from the terminal

Tasks, theorems to formalize, and bugs are tracked as GitHub issues in `juantztz/research-project-lean`. The commands below use the [GitHub CLI](https://cli.github.com/manual/) from the repository folder (add `-R juantztz/research-project-lean` to run them elsewhere).

### One-time setup

```bash
brew install gh
gh auth login                         # GitHub.com -> SSH -> log in with a browser
gh auth refresh -s project            # add the "project" scope, needed for GitHub Projects
gh repo set-default juantztz/research-project-lean
```

### Issues and pull requests

```bash
gh issue create --title "Formalize Bertrand's postulate" --body "Statement and references..." \
  --label "theorem,number-theory" --assignee @me
gh issue list --label theorem
gh issue view 12 --comments
gh issue develop 12 --base master --name number-theory/12-bertrand --checkout
git commit -m "[NEW] Bertrand's postulate statement (refs #12)"
git push -u origin number-theory/12-bertrand
gh pr create --base master --title "[NEW] Bertrand's postulate" --body "Closes #12"
gh pr checks                                 # waits for the Lean build in GitHub Actions
gh pr merge --squash --delete-branch
```

### Labels

```bash
gh label create "theorem" --color 1D76DB --description "A result to formalize"
gh label create "sorry" --color D93F0B --description "Proof with unfinished sorry"
gh label list
```

Suggested labels: type (`theorem`, `definition`, `bug`, `documentation`, `literature`), area (`number-theory`, `analysis`, `algebra`, `probability`, `optimization`, ...), status (`in-progress`, `sorry`, `blocked`).

---

(content:documentacion:estructura)=
## Repository structure

Folders starting with `_` are ignored by git and synchronized with Google Drive.

```text
research-project-lean/
├── AGENTS.md              <- Project context and coding rules for AI assistants.
├── README.md              <- Short pointer to this documentation (shown on GitHub).
├── MAKE                   <- Makefile: setup, Lean build, Google Drive sync, book build (use make -f MAKE ...).
├── setup.sh               <- First-time setup script (checks tools, pulls Drive data, creates the environments).
│
├── lean-toolchain         <- Lean version used by elan (must match the Mathlib version).
├── lakefile.toml          <- Lake package: Lean options, Mathlib dependency (rev), library ResearchLean.
├── lake-manifest.json     <- Locked commit of Mathlib and its dependencies (commit it whenever it changes).
├── ResearchLean.lean      <- Library root: imports every module that lake build checks.
├── ResearchLean/          <- Lean source: one topic per file.
│   ├── Tutorial.lean      <- Lean 4 basics (core only, no Mathlib).
│   └── Basic.lean         <- First theorems with Mathlib.
├── .lake/                 <- [local] Mathlib checkout and build outputs (ignored).
│
├── pyproject.toml         <- Python environment (jupyter-book) managed by uv.
├── uv.lock                <- Locked Python versions (commit it whenever dependencies change).
├── .gitignore             <- Files kept out of git (data, assets, builds, .lake, .venv).
├── .rcignore              <- Paths excluded from rclone sync/check.
├── .vscode/               <- Editor settings and recommended extensions (Lean 4, Jupyter, MyST).
├── .github/workflows/     <- lean.yml: lake build on every push and pull request.
│
├── _data/                 <- [Drive] Data (input/, output/, sims/debug/).
│
└── docs/                  <- MyST / Jupyter Book 2 project.
    ├── myst.yml           <- Book configuration (title, authors, bibliography, numbering).
    ├── toc.yml            <- Table of contents of the site.
    ├── export.yml         <- PDF export definitions (articles included and LaTeX template).
    ├── references.bib     <- Bibliography; one entry per PDF in assets/_literature.
    ├── introduction.md    <- Landing page.
    ├── docs/              <- Markdown pages: README.md (this file), proofs/ (one page per Lean file).
    ├── notebooks/         <- Jupyter notebooks (experiments, figures).
    ├── templates/         <- LaTeX templates for exports (plain_latex).
    ├── assets/
    │   ├── _literature/   <- [Drive] Paper PDFs named by their citation key in references.bib.
    │   └── _imagenes/     <- [Drive] Figures and diagrams.
    └── _build/            <- Generated site/PDF (ignored).
```

---

(content:documentacion:build-docs)=
## Building the documentation (Jupyter Book 2)

The book is a [MyST](https://mystmd.org/guide) project built with Jupyter Book 2 (`jupyter-book>=2`), installed in `.venv` by `uv sync`. All commands run **from `docs/`**; the `make` targets do the `cd` for you. The first run may ask to install Node.js.

### Project files

| File | Role |
|---|---|
| `docs/myst.yml` | Project metadata: title, authors, bibliography (`references.bib`), numbering, excluded paths, site theme (`book-theme`). It `extends` the two files below. |
| `docs/toc.yml` | Table of contents of the site. A page that is not listed here does not appear in the navigation. |
| `docs/export.yml` | PDF exports: format, LaTeX template, title, authors, and the ordered list of `articles` combined into the PDF. |
| `docs/templates/` | Local LaTeX templates (`plain_latex`). |
| `docs/references.bib` | Bibliography used by `{cite}` roles in all pages. |
| `docs/_build/` | Generated output (git-ignored). |

### Showing Lean code and theorems

Embed the checked source instead of copying it, so the book always shows the code that `lake build` accepted (paths are relative to the page):

````markdown
```{literalinclude} ../../../ResearchLean/Basic.lean
:language: lean
:lines: 10-17
```
````

State results in prose with the `prf` directives (`theorem`, `lemma`, `definition`, `proof`, ...) and reference them with `{prf:ref}` or `[](#label)`:

````markdown
```{prf:theorem}
:label: thm-sum-odd
For every $n$, $\sum_{i<n} (2i+1) = n^2$.
```
````

### Live preview (while writing)

```bash
make -f MAKE start_jupyter            # same as: cd docs && uv run jupyter book start
```

Open <http://localhost:3000>. The site is rebuilt every time a file is saved; stop it with `Ctrl+C`. Use `uv run jupyter book start --port 3001` (from `docs/`) if the port is busy.

### HTML (static website)

```bash
make -f MAKE build_jupyter BUILD_TYPE=html    # same as: cd docs && uv run jupyter book build --html
```

The site is written to `docs/_build/html/`. It uses absolute links, so serve the folder instead of double-clicking `index.html`:

```bash
cd docs/_build/html && python -m http.server 8000      # open http://localhost:8000
```

To publish it under a sub-path (for example GitHub Pages at `https://juantztz.github.io/research-project-lean/`), build with the base URL:

```bash
cd docs && BASE_URL=/research-project-lean uv run jupyter book build --html
```

### PDF export

```bash
make -f MAKE build_jupyter BUILD_TYPE=pdf     # same as: cd docs && uv run jupyter book build --pdf
```

* The PDF is generated from the exports in `docs/export.yml` and written to `docs/_build/exports/lean-research-project.pdf` with the `plain_latex` template.
* LaTeX (`xelatex`/`pdflatex`) must be installed. When LaTeX reports warnings, the logs are in `docs/_build/temp/<id>/`.
* **To change the content** of the PDF, edit the `articles` list in `docs/export.yml` (paths relative to `docs/`, in reading order). **To create another PDF**, add a new item under `project.exports` with its own `output`.
* Other formats use the same mechanism: `--tex`, `--docx`, `--typst`, or `--all`; they require a matching `format:` entry in the exports.

### Notebooks

Notebooks in `docs/notebooks/` are rendered with their saved outputs; they are **not** executed during the build. Add `--execute` to `jupyter book start`/`build` to execute them with the `.venv` kernel.

### Cleaning and troubleshooting

```bash
cd docs && uv run jupyter book clean --all -y     # delete every generated file in docs/_build
```

| Message | Fix |
|---|---|
| `No file exports with kind "pdf" found` | The command was run from the repository root; run it from `docs/` (or use the `make` target). |
| `Duplicate identifier in file ...` / `Reference ... undefined` | Two labels share a name, or a `(label)=` / `:label:` is missing; fix the label in the page. |
| `Language is not defined for code block` | Add a language after the opening fence of the code block (e.g. `bash`, `lean`). |
| `literalinclude` file not found | The path is relative to the page, not to `docs/`. |
| A page is missing from the site | Add it to `docs/toc.yml`. |

---

(readme-known-issues)=
## Known issues

* Opening a single `.lean` file (instead of the repository folder) in VS Code makes the Lean server ignore `lakefile.toml`, so `import Mathlib` fails; open the folder.
* `unknown package 'Mathlib'` or a very slow first build means the cache was not downloaded: run `lake exe cache get`.
* After switching branches that change `lake-manifest.json`, run `lake exe cache get` again.

---

## Project rules

* Commit messages start with `[NEW]`, `[UPDATE]`, `[FIX]`, or `[DELETE]`.
* Branches follow `TOPIC/FEATURE NAME` (e.g. `number-theory/infinite-primes`); `master` must always build.
* A pull request is merged only when the *Lean build* check passes.
* `sorry` is allowed in branches but must be listed in the pull request description; `master` should be free of `sorry`.
* Every new Lean file has a page in `docs/docs/proofs/` listed in `docs/toc.yml`.
