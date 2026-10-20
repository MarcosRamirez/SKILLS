# Add-ons from the curated catalog (SPEC-0011 AC-3): "add a landing page" in a small Astro site that
# already follows senior-mindset (conventions, Cloudflare Pages), with every question failing. The
# skill must name a matching web-design entry of catalog/skills.json (frontend-design or
# web-design-guidelines) in its question or its final message, propose at most three add-ons, and
# install nothing: no npx skills, plugin or MCP command, and no installed copy, lock file or
# .mcp.json on any branch or on disk. The approval gate still holds: no source changed or added.
# (An empty folder with "Design a landing page" is not used: Claude Code treats it as a design
# artifact and the skill does not load, which is not what this scenario tests.)

SCENARIO_DESCRIPTION="'add a landing page' in a senior-mindset project proposes a web-design add-on from the catalog and installs nothing"
SCENARIO_PROMPT="Add a landing page for the bakery to this project."
SCENARIO_RUNS=1
SCENARIO_ALLOWED_TOOLS="Bash(git:*),Bash(ls:*),Bash(cat:*),Bash(mkdir:*)"
SCENARIO_QUESTION_TOOL=error

ADDON_COMMAND="${INSTALL_CHANGE_COMMAND}|claude[[:space:]]+mcp[[:space:]]+add"
INSTALLED_PATHS='^(\.agents/skills/|\.claude/skills/|skills-lock\.json$|\.mcp\.json$)'

# Entries whose id or name is also an everyday word (a platform, a file type, a tool) are not
# counted: the answer can name them without proposing the add-on.
COMMON_WORD_IDS=" cloudflare wrangler github docx xlsx pptx pdf playwright "

scenario_setup() {  # a small Astro site with senior-mindset conventions, committed
  local dir=$1
  init_scratch_repo "$dir"
  keep_line_endings "$dir"
  mkdir -p "$dir/src/pages" "$dir/spec/constitution" "$dir/spec/adr"
  cat > "$dir/AGENTS.md" <<DOC
# Crumb & Co

Website of a small bakery.

## Engineering conventions

- Stack: Astro 5 static site, TypeScript. Deploy: Cloudflare Pages (wrangler). Code: \`src/\`.
- Linter and formatter: Biome. Tests: Vitest. Versioning: SemVer. Default branch: master.
- Database, API, logging: N/A (static site).
- Before creating anything, check spec/INVENTORY.md.

$(git_rules_block)
DOC
  cat > "$dir/package.json" <<'JSON'
{
  "name": "crumb-site",
  "version": "0.1.0",
  "type": "module",
  "scripts": { "dev": "astro dev", "build": "astro build" },
  "dependencies": { "astro": "^5.0.0" },
  "devDependencies": { "wrangler": "^4.0.0" }
}
JSON
  printf 'name = "crumb-site"\npages_build_output_dir = "dist"\n' > "$dir/wrangler.toml"
  printf -- '---\nconst title = "Crumb & Co"\n---\n<h1>{title}</h1>\n<p>Coming soon.</p>\n' > "$dir/src/pages/index.astro"
  printf '# Inventory\n\n## Pages\n- `index` — src/pages/index.astro — placeholder home page — `/`\n' > "$dir/spec/INVENTORY.md"
  printf '# Mission\n\nA simple website where neighbours find what the bakery bakes today.\n' > "$dir/spec/constitution/mission.md"
  commit_scratch "$dir" "Set up the bakery site"
  save_baseline "$dir"
}

proposal_text() {  # proposal_text STREAM: the final message plus every question the run asked
  { stream_py result "$1"; question_calls "$1"; } 2>/dev/null
}

catalog_entries() {  # catalog_entries: "id<TAB>name" for every entry of the copy under test
  "$PYTHON" -c '
import json, sys
for name in ("skills.json", "mcps.json"):
    for entry in json.load(open(sys.argv[1] + "/catalog/" + name, encoding="utf-8"))["entries"]:
        print(entry["id"] + "\t" + entry["name"])
' "$SKILL_SOURCE" | tr -d '\r'
}

assert_web_design_proposed() {  # assert_web_design_proposed STREAM
  local hit
  hit="$(proposal_text "$1" | grep -Eio 'frontend-design|web-design-guidelines|frontend design|web design guidelines' | head -1)"
  if [[ -n $hit ]]; then echo "proposed: $hit"; else echo "neither frontend-design nor web-design-guidelines is named"; return 1; fi
}

assert_at_most_three() {  # assert_at_most_three STREAM: distinct, distinctive entries named (id or name)
  local text id name named=()
  text="$(proposal_text "$1")"
  while IFS=$'\t' read -r id name; do
    [[ -n $id && $COMMON_WORD_IDS != *" $id "* ]] || continue
    if printf '%s\n' "$text" | grep -Fqiw -e "$id" -e "$name"; then named+=("$id"); fi
  done < <(catalog_entries)
  echo "catalog entries named: ${#named[@]} (${named[*]:-none})"
  [[ ${#named[@]} -ge 1 && ${#named[@]} -le 3 ]]
}

assert_nothing_installed() {  # assert_nothing_installed PROJECT
  local hits
  hits="$(all_files "$1" | grep -E -- "$INSTALLED_PATHS")"
  if [[ -n $hits ]]; then echo "installed files: $(printf '%s' "$hits" | head -5 | tr '\n' ' ')"; return 1; fi
  echo "no installed copy, lock file or .mcp.json on any branch or on disk"
}

scenario_checks() {  # scenario_checks PROJECT STREAM
  local project=$1 stream=$2
  check "the skill loaded" assert_skill_invoked "$stream" senior-mindset
  check "a web-design add-on from the catalog is proposed" assert_web_design_proposed "$stream"
  check "at most three catalog add-ons named" assert_at_most_three "$stream"
  check "no install command for a skill, plugin or MCP" assert_no_command "$stream" "$ADDON_COMMAND"
  check "nothing installed in the project" assert_nothing_installed "$project"
  check "no source changed or added (approval gate)" assert_sources_unchanged "$project"
}
