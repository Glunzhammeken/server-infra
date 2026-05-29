#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ok()  { echo -e "  ${GREEN}✓${NC}  $*"; }
err() { echo -e "  ${RED}✗${NC}  $*" >&2; }
sep() { echo -e "${CYAN}─────────────────────────────────────────────────${NC}"; }

sep
echo -e "  ${BOLD}Server Infra — deploy${NC}"
sep

fail=0

if ! command -v ansible-playbook &>/dev/null; then
    err "Ansible ikke fundet. Installér med: pipx install ansible"
    fail=1
else
    ok "Ansible $(ansible --version | head -1 | awk '{print $3}' | tr -d ']')"
fi

if [[ ! -f inventories/opgavehelten/hosts.yml ]]; then
    err "inventories/opgavehelten/hosts.yml mangler."
    fail=1
else
    ok "Inventory fundet"
fi

if [[ $fail -ne 0 ]]; then
    echo ""
    err "Ret fejlene ovenfor og prøv igen."
    exit 1
fi

sep
echo ""
ansible-playbook site.yml
echo ""
sep
ok "Deploy færdig"
sep
