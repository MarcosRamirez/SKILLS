# Script fast path (PM-0004): "Write a python script that renames photos by date" must load the
# skill, which gives the script English names and skips the project ceremony. In the 1.1.0 run the
# skill did not load, and the file name, the functions and the flags came out in Spanish.

SCENARIO_DESCRIPTION="a one-off script request loads the skill: one file, English names, no spec or ADR"
SCENARIO_PROMPT="Write a python script that renames photos by date"
SCENARIO_RUNS=1
SCENARIO_ALLOWED_TOOLS="Bash(git:*),Bash(python:*),Bash(python3:*)"
SCENARIO_QUESTION_TOOL=none

# Whole words that are Spanish and not English. Identifiers are split on _ and camelCase first.
SPANISH_DENYLIST='renombrar|renombra|fecha|fechas|foto|fotos|archivo|archivos|carpeta|directorio|ruta|nombre|nombres|imagen|imagenes|origen|destino|ejecutar|cambiar|mover|obtener|leer|guardar|prueba|ayuda|hora|mes|dia|salida|entrada|contador|resultado|ejemplo'

scenario_setup() {  # an empty folder
  :
}

app_source_files() {  # app_source_files PROJECT: application source files on any branch or on disk
  all_files "$1" | grep -Ev "$DOCUMENT_PATHS" | grep -E "$APP_SOURCE_PATTERN"
}

assert_single_script() {  # assert_single_script PROJECT
  local files count
  files="$(app_source_files "$1")"
  count="$(printf '%s\n' "$files" | grep -c .)"
  echo "$count source file(s): $(printf '%s' "$files" | tr '\n' ' ')"
  [[ $count -eq 1 ]]
}

# Words of the names defined in the script (functions, classes, arguments, variables, argparse
# flags) and of its file name; none may be on the denylist. Python source only.
assert_english_identifiers() {  # assert_english_identifiers PROJECT
  local project=$1 file hit ref source_file words bad
  file="$(app_source_files "$project" | head -1)"
  [[ -n $file ]] || { echo "no script found"; return 1; }
  hit="$(find_file "$project" "^$(printf '%s' "$file" | sed 's/[.[\*^$/]/\\&/g')\$")" || { echo "$file not readable"; return 1; }
  ref="${hit%% *}"
  source_file="$(mktemp)"
  file_at "$project" "$ref" "$file" > "$source_file"
  words="$("$PYTHON" -I - "$file" "$source_file" <<'PY'
import ast, re, sys
name, path = sys.argv[1:3]
tree = ast.parse(open(path, encoding="utf-8").read())
names = {name.rsplit("/", 1)[-1].rsplit(".", 1)[0]}
for node in ast.walk(tree):
    for attr in ("name", "id", "arg", "asname", "attr"):
        value = getattr(node, attr, None)
        if isinstance(value, str):
            names.add(value)
    if isinstance(node, ast.Call):  # argparse flags such as add_argument("--origen")
        for arg in node.args:
            if isinstance(arg, ast.Constant) and isinstance(arg.value, str) and arg.value.startswith("-"):
                names.add(arg.value)
words = set()
for item in names:
    for part in re.split(r"[^A-Za-z]+", re.sub(r"([a-z])([A-Z])", r"\1_\2", item)):
        if part:
            words.add(part.lower())
print("\n".join(sorted(words)))
PY
)"
  rm -f "$source_file"
  bad="$(printf '%s\n' "$words" | grep -Ex "$SPANISH_DENYLIST")"
  if [[ -n $bad ]]; then echo "Spanish words in the names of $file: $(printf '%s' "$bad" | tr '\n' ' ')"; return 1; fi
  echo "$file: $(printf '%s\n' "$words" | grep -c .) identifier words, none on the denylist"
}

assert_no_spec_or_adr() {  # assert_no_spec_or_adr PROJECT
  local hits
  hits="$(all_files "$1" | grep -E '^(spec|docs)/|(^|/)adr/|(^|/)ADR-?[0-9]')"
  if [[ -n $hits ]]; then printf '%s\n' "$hits" | head; return 1; fi
  echo "no file under spec/, docs/ or adr/ on any branch"
}

scenario_checks() {  # scenario_checks PROJECT STREAM
  local project=$1 stream=$2
  check "the skill loaded" assert_skill_invoked "$stream" senior-mindset
  check "a single script file" assert_single_script "$project"
  check "English identifiers and file name (no Spanish words)" assert_english_identifiers "$project"
  check "no spec and no ADR" assert_no_spec_or_adr "$project"
}
