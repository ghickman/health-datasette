# just has no idiom for setting a default value for an environment variable
# so we shell out, as we need VIRTUAL_ENV in the justfile environment
export VIRTUAL_ENV  := `echo ${VIRTUAL_ENV:-.venv}`

export BIN := VIRTUAL_ENV + if os_family() == "unix" { "/bin" } else { "/Scripts" }
export PIP := BIN + if os_family() == "unix" { "/python -m pip" } else { "/python.exe -m pip" }
# enforce our chosen pip compile flags
export COMPILE := BIN + "/pip-compile --allow-unsafe --generate-hashes"

export DEFAULT_PYTHON := if os_family() == "unix" { "python3.10" } else { "python" }


# list available commands
default:
    @{{ just_executable() }} --list


# ensure valid virtualenv
virtualenv:
    #!/usr/bin/env bash
    # allow users to specify python version in .env
    PYTHON_VERSION=${PYTHON_VERSION:-$DEFAULT_PYTHON}

    # create venv and upgrade pip
    test -d $VIRTUAL_ENV || { $PYTHON_VERSION -m venv $VIRTUAL_ENV && $PIP install --upgrade pip; }

    # ensure we have pip-tools so we can run pip-compile
    test -e $BIN/pip-compile || $PIP install pip-tools


_compile src dst *args: virtualenv
    #!/usr/bin/env bash
    # exit if src file is older than dst file (-nt = 'newer than', but we negate with || to avoid error exit code)
    test "${FORCE:-}" = "true" -o {{ src }} -nt {{ dst }} || exit 0
    $BIN/pip-compile --allow-unsafe --generate-hashes --output-file={{ dst }} {{ src }} {{ args }}


# update requirements.txt if requirements.in has changed
requirements *args:
    "{{ just_executable() }}" _compile requirements.in requirements.txt {{ args }}


# ensure prod requirements installed and up to date
env: requirements
    #!/usr/bin/env bash
    # exit if .txt file has not changed since we installed them (-nt == "newer than', but we negate with || to avoid error exit code)
    test requirements.txt -nt $VIRTUAL_ENV/.reqs || exit 0

    $PIP install -r requirements.txt
    touch $VIRTUAL_ENV/.reqs


# upgrade dev or prod dependencies (specify package to upgrade single package, all by default)
upgrade package="": virtualenv
    #!/usr/bin/env bash
    opts="--upgrade"
    test -z "{{ package }}" || opts="--upgrade-package {{ package }}"
    FORCE=true "{{ just_executable() }}" requirements $opts


# Build the database from scratch
build: env
    #!/usr/bin/env bash
    rm healthkit.db
    $BIN/healthkit-to-sqlite export.zip healthkit.db


# Run the dev project
run: env
    $BIN/datasette healthkit.db
