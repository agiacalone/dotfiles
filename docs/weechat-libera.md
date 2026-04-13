# WeeChat on Libera.Chat via ZNC

This repo now tracks a WeeChat `4.9` profile in `.config/weechat/` with:

- ZNC preconfigured on `services.tilde.club:6699` with TLS
- secure login via WeeChat secured data
- Gruvbox-leaning colors and denser buflist/status bars
- relay enabled on port `9001`
- service aliases for `NickServ`, `ChanServ`, and `MemoServ`

The profile takes inspiration from Strykar's long-running WeeChat notes:
https://gist.github.com/Strykar/ebcc0dbfec27ddcc303e73e7f809c072

## Quick setup

Run:

```bash
~/bin/weechat-znc-setup
```

`~/bin/weechat-libera-setup` still exists as a compatibility wrapper.

Close any running WeeChat session first so the script does not race a live config.

The script prompts for:

- IRC nick
- IRC ident
- real name
- ZNC host
- ZNC port
- TLS on/off
- ZNC account user
- ZNC client name
- ZNC network name
- ZNC password
- relay password
- WeeChat secure passphrase

It then stores:

- `irc_nick`
- `irc_ident`
- `irc_realname`
- `znc_password`
- `relay_password`

in WeeChat secured data and generates `~/.config/weechat/tls/relay.pem` unless you pass `--no-relay-cert`.

## Manual setup

If you want to set the secrets yourself:

```text
/secure passphrase <your-passphrase>
/secure set irc_nick <your-irc-nick>
/secure set irc_ident <your-irc-ident>
/secure set irc_realname <your-real-name>
/secure set znc_password <your-znc-password>
/secure set relay_password <strong-relay-password>
/set irc.server.znc.addresses services.tilde.club/6699
/set irc.server.znc.tls on
/set irc.server.znc.nicks ${sec.data.irc_nick},${sec.data.irc_nick}_,${sec.data.irc_nick}__
/set irc.server.znc.username anthonyg@weechat/libera
/set irc.server.znc.realname ${sec.data.irc_realname}
/set irc.server.znc.password ${sec.data.znc_password}
/save
```

Then connect with:

```text
/connect znc
```

## Profile notes

- `irc.server.znc.autoconnect` is enabled.
- `irc.server.znc.username` defaults to `anthonyg@weechat/libera`.
- `irc.server.znc.password` uses `${sec.data.znc_password}`.
- relay uses `relay.network.password = ${sec.data.relay_password}`.
- relay TLS expects `~/.config/weechat/tls/relay.pem`.
- aliases: `/znc`, `/libera`, `/ns`, `/cs`, `/ms`, `/identify`, `/ghost`

## Useful first tweaks

Inside WeeChat:

```text
/set irc.server.znc.username "anthonyg@weechat/libera"
/set irc.server.znc.addresses "services.tilde.club/6699"
/connect znc
/save
```
