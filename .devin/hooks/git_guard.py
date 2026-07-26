import json
import re
import sys


# Matches "git" as a standalone token, not inside "github", "repo.git", etc.
GIT_TOKEN = re.compile(r"(?<!\S)git(?!\S)", re.IGNORECASE)

# Shell operators / chaining / redirection / command substitution that would
# mean more than one command is running in a single Exec call.
OPERATORS = re.compile(r"[;&|<>]|&&|\|\||\r|\n|\$\(")

# Any token starting with "-" before the git subcommand (e.g. -c, -C, --no-pager).
LEADING_OPTION = re.compile(r"^-")


def main():
    data = json.load(sys.stdin)
    command = data.get("tool_input", {}).get("command", "")

    # If the command doesn't mention git as a standalone word, we don't enforce.
    if not GIT_TOKEN.search(command):
        sys.exit(0)

    # Strip single-quoted strings first so literal '$(date)' is not flagged.
    bare = re.sub(r"'([^'\\]|\\.)*'", "", command)

    # After single quotes are gone, flag any $(...) command substitution that
    # remains.  In PowerShell and POSIX shells $(...) is evaluated inside
    # double-quoted strings, so this catches subexpression substitution.
    if re.search(r"\$\(", bare):
        print(
            json.dumps(
                {
                    "decision": "block",
                    "reason": "Git Exec calls may not use command substitution ($( ... )).",
                }
            )
        )
        sys.exit(2)

    # Now strip double-quoted strings, backtick command substitution, and
    # remaining $(...) blocks so git inside arguments/commit messages/URLs
    # doesn't cause false positives.
    for pat in (
        r'"([^"\\]|\\.)*"',   # double-quoted strings
        r"`[^`]*`",              # backtick command substitution
        r"\$\([^)]*\)",         # $(...) command substitution (non-nested)
    ):
        bare = re.sub(pat, "", bare)

    if OPERATORS.search(bare):
        print(
            json.dumps(
                {
                    "decision": "block",
                    "reason": "Git Exec calls must be a single git <command> with no shell operators, chaining, redirection, or command substitution.",
                }
            )
        )
        sys.exit(2)

    stripped = bare.strip()

    # The command must start with git (no env prefixes, no leading cd/echo/etc.).
    if not re.match(r"^git(?:\s|$)", stripped, re.IGNORECASE):
        print(
            json.dumps(
                {
                    "decision": "block",
                    "reason": "Exec calls that mention git must start with 'git <command>' and contain no other commands.",
                }
            )
        )
        sys.exit(2)

    # Split into tokens to inspect the first argument after "git".
    tokens = re.split(r"\s+", stripped)
    if len(tokens) >= 2 and LEADING_OPTION.match(tokens[1]):
        print(
            json.dumps(
                {
                    "decision": "block",
                    "reason": "Git Exec calls must be 'git <subcommand> [args]'. Leading options like -c, -C, or --no-pager are not allowed; cd first or use git config instead.",
                }
            )
        )
        sys.exit(2)

    sys.exit(0)


if __name__ == "__main__":
    main()
