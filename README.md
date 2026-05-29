# Server Infra

Ansible-projekt der klargør en frisk Ubuntu 24.04-server til selvhosting: pakke-baseline, SSH-hærdning, firewall og Docker Engine.

Kører **på serveren selv** — ingen ekstern control node. Klones direkte på serveren og køres lokalt.

Del af [selfhosted-collab-stack](https://github.com/Glunzhammeken/selfhosted-collab-stack) — køres som Fase 1 inden apps og integrationer deployes.

---

## Hvad deployes?

| Rolle | Hvad gøres |
|---|---|
| `baseline` | Opgraderer pakker, aktiverer UFW, deaktiverer SSH-adgangskode-login, konfigurerer fail2ban |
| `hardening` | Åbner porte 80, 443 og 3478 (Nextcloud Talk), aktiverer automatiske sikkerhedsopdateringer |
| `docker` | Installerer Docker Engine og Docker Compose plugin |

---

## Forudsætninger

- **OS:** Ubuntu 24.04 LTS (frisk installation)
- **RAM:** Minimum 1 GB
- **Adgang:** SSH-adgang med nøgle (adgangskode-login deaktiveres af `baseline`)

---

## Installation

Kør dette på den friske server:

```bash
sudo apt update && sudo apt install -y python3-pip pipx git && pipx install ansible-core --force && export PATH="$PATH:$HOME/.local/bin" && git clone https://github.com/Glunzhammeken/server-infra.git ~/server-infra && cd ~/server-infra && ./deploy.sh
```

Det er alt. Playbooken er idempotent — det er sikkert at køre igen.

> **Hvis scriptet stopper med "reboot påkrævet":**
> En kernel-opdatering kræver genstart. Kør `sudo reboot`, log ind igen og kør `./deploy.sh` forfra.

---

## Brug

```bash
./deploy.sh
```

Scriptet tjekker at Ansible er installeret og inventory findes, derefter kører det `site.yml`.

---

## Konfiguration

Nøglevariabler i `roles/*/defaults/main.yml`:

| Fil | Variabel | Standard | Beskrivelse |
|---|---|---|---|
| `roles/baseline/defaults/main.yml` | `fail2ban_bantime` | `1h` | Spærringstid efter for mange fejlede SSH-login |
| `roles/hardening/defaults/main.yml` | `unattended_upgrades_reboot_time` | `04:00` | Tidspunkt for automatisk genstart efter opdateringer |
| `roles/docker/defaults/main.yml` | `docker_log_max_size` | `10m` | Maks logfilstørrelse per container |

---

## Projektstruktur

```
server-infra/
├── site.yml                          # Playbook — kører baseline → hardening → docker
├── deploy.sh                         # Deploy-script med præflight-tjek
├── ansible.cfg                       # Standardinventory og Python-indstillinger
│
├── inventories/
│   └── opgavehelten/
│       ├── hosts.yml                 # Local connection (gitignored)
│       ├── hosts.yml.example         # Skabelon — kopiér til hosts.yml
│       └── group_vars/all/
│           └── config.yml.example    # Skabelon til domæne/email-variabler
│
└── roles/
    ├── baseline/                     # Pakker, UFW, fail2ban, SSH-hærdning
    ├── hardening/                    # Porte, automatiske opdateringer
    └── docker/                       # Docker Engine + Compose plugin
```

---

## Fejlfinding

### "reboot påkrævet" stopper playbooken
Forventet adfærd — en kernel-opdatering kræver genstart. Kør `sudo reboot`, log ind igen og kør `./deploy.sh` forfra.

### SSH-adgangskode-login virker ikke efter deploy
`baseline`-rollen deaktiverer adgangskode-login og kræver SSH-nøgle. Sørg for at din nøgle er i `~/.ssh/authorized_keys` **inden** første kørsel.

### Tjek Docker-installation

```bash
docker version
docker compose version
```
