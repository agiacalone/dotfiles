#!/usr/bin/env bash
# ── Make a fresh Fedora KDE VM into a working "KDE desktop over RDP" box. ──────────────
# Run this ONCE inside a new guest (needs sudo). Idempotent — safe to re-run.
#
# This is the distilled recipe from the 2026-07-12 session where we learned, the hard way,
# every way this can go wrong. Read notes/desktop-vm-on-reason.md for the full story.
#
# THE ONE RULE THAT MATTERS: use xrdp with DEFAULT KDE rendering. Do NOT set KWIN_COMPOSE,
# LIBGL_ALWAYS_SOFTWARE, GALLIUM_DRIVER, or a kwinrc compositing override. KDE Plasma 6
# auto-falls-back to software rendering on a GPU-less VM ALL BY ITSELF. Every one of those
# "helpful" env vars BROKE a working desktop last time (KWIN_COMPOSE=Q forced an XRender
# backend KWin 6 doesn't have -> crash cascade). Plain is correct.
set -euo pipefail
echo "== vm-provision-rdp: making this VM a KDE-over-RDP box =="

# 1. xrdp + the X11 Plasma session (Wayland can't drive xrdp). NOT KRdp: KRdp only offers
#    H.264 graphics and hangs up on clients that can't decode it (e.g. the iOS RDP app).
sudo dnf install -y xrdp xorgxrdp plasma-workspace-x11

# 2. Plain .xsession — no env overrides. This is the whole fix. Leave rendering to KDE.
printf '#!/bin/bash\nexec startplasma-x11\n' > "$HOME/.xsession"
chmod +x "$HOME/.xsession"

# 3. If KRdp was ever enabled, stop it fighting xrdp for port 3389. Editing krdpserverrc
#    is NOT enough — the systemd *user unit* stays enabled and fails on every boot, so
#    disable the unit too.
systemctl --user disable --now app-org.kde.krdpserver.service 2>/dev/null || true
systemctl --user reset-failed app-org.kde.krdpserver.service 2>/dev/null || true
[ -f "$HOME/.config/krdpserverrc" ] && \
  sed -i 's/Autostart=true/Autostart=false/; s/SystemUserEnabled=true/SystemUserEnabled=false/' \
      "$HOME/.config/krdpserverrc" || true

# 4. A VM must never sleep — suspend kills all remote access, and the black screen it
#    causes looks exactly like a network failure (cost us an hour once).
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# 5. Stop the login-time "enter password to change network" polkit nag: let wheel manage
#    NetworkManager without a prompt (single-user VM, reached only over RDP).
sudo tee /etc/polkit-1/rules.d/49-nm-no-password.rules >/dev/null <<'POLKIT'
polkit.addRule(function(action, subject) {
    if (action.id.indexOf("org.freedesktop.NetworkManager.") == 0 &&
        subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});
POLKIT

# 5b. Same polkit loop bites Flatpak/PackageKit in Discover over RDP — let wheel install
#     software without the repeating password prompt. Also unfilter Flathub (Fedora ships
#     it filtered to a FOSS subset, so most apps are hidden).
sudo tee /etc/polkit-1/rules.d/49-flatpak-no-password.rules >/dev/null <<'POLKIT'
polkit.addRule(function(action, subject) {
    if ((action.id.indexOf("org.freedesktop.Flatpak.") == 0 ||
         action.id.indexOf("org.freedesktop.packagekit.") == 0) &&
        subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});
POLKIT
command -v flatpak >/dev/null && sudo flatpak remote-modify --system flathub --no-filter 2>/dev/null || true

# 5c. ==The KDE "Restart"/"Shut Down" menu HANGS over RDP and black-screens the box.==
#     An RDP session is not a local seat (logind: Seat="" Remote=yes), so
#     org.freedesktop.login1.reboot resolves to auth_admin_keep -> admin password prompt.
#     But Plasma's shutdown sequence STOPS plasma-polkit-agent.service while tearing the
#     session down, so that prompt can never be answered: plasma-shutdown blocks in poll()
#     forever, kwin is already dead, and you get a BLACK SCREEN on a box that never
#     rebooted -- and xrdp reconnects you to the corpse session, so it looks permanent.
#     (Cost an evening on 2026-07-13; it was misdiagnosed as "reboot broke the VM".)
#     Let wheel do login1 actions unprompted. Not a real loosening: anyone who can log in
#     can already `sudo reboot`. This just makes the menu tell the truth.
sudo tee /etc/polkit-1/rules.d/49-login1-no-password.rules >/dev/null <<'POLKIT'
polkit.addRule(function(action, subject) {
    if (action.id.indexOf("org.freedesktop.login1.") == 0 &&
        subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});
POLKIT
sudo systemctl restart polkit

# 6. Enable xrdp + sesman at boot, open the guest firewall.
sudo systemctl enable --now xrdp xrdp-sesman
sudo firewall-cmd --permanent --add-port=3389/tcp >/dev/null

# 6b. sshd — the ONLY sane way back in when the desktop is black. Every black screen this
#     VM has ever had was diagnosed over ssh (and one was recoverable ONLY over ssh).
#     Turn it on before you need it, not after.
sudo systemctl enable --now sshd
sudo firewall-cmd --permanent --add-service=ssh >/dev/null
sudo firewall-cmd --reload >/dev/null

echo
echo "== done. xrdp: $(systemctl is-active xrdp) on $(hostname) =="
echo "   Log in over RDP as your Fedora user (session: Xorg)."
echo
echo "IMPORTANT — do NOT run a local console desktop session for the SAME user while using"
echo "RDP. KDE allows only one Plasma session per user; a leftover console (autologin, or a"
echo "session you left open in the Cockpit console) makes the RDP session come up BLACK."
echo "No autologin is the default; if you set one, turn it off."
