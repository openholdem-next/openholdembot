# OpenHoldem Next

A maintained community fork of **OpenHoldem**, the open-source poker bot framework.

> **This is a modified version of OpenHoldem, not the original project.**
> Forked from [OpenHoldem/openholdembot](https://github.com/OpenHoldem/openholdembot) in August 2026.
> Not affiliated with or endorsed by the original authors. Licensed under GPLv3.

---

## What this is

OpenHoldem is a framework: it reads the table, exposes the game state as symbols, and executes
the decisions your own logic makes. It does not come with a strategy, and it never will.

**The engine is shared. Your game logic is yours.** Table maps and bot logic stay with whoever
writes them — that has always been how this community works, and nothing here asks you to change it.

## Why this fork exists

The work on OpenHoldem never stopped, it just stopped landing. Contributions kept arriving through
2025, but nothing was merged into the main branch after December 2021, issues were disabled, and
there was nobody available to merge anything.

This fork exists to give that work a home: review what was pending, publish builds anyone can
reproduce, and write down how the thing actually works. Everything merged here keeps the name of
whoever wrote it.

---

## What this is not

Being clear about this up front, because unmet expectations are what wore out everyone involved
last time.

For now this is a fork that one person maintains and publishes. It is not a project with a roadmap,
a release schedule or a support desk.

| | |
|---|---|
| **Releases** | When there is something worth releasing. No schedule. |
| **Issues** | Open, and read. No promise of a reply or a fix. |
| **Roadmap** | None. Things get done when someone does them. |
| **User support** | The community forum, not here. |
| **Scope** | Windows desktop poker clients, Windows 7 or later, 32-bit. |
| **Outside that scope** | Patches welcome, but unsupported and untested. |

Nothing here obliges anyone to anything. That is deliberate: it is the only version of this that
is sustainable.

---

## Status

**Current release: 14.1.0** — see [release notes](##_OpenHoldem_Release_Directory_##/documents/OpenHoldem%20Release%20Notes.txt).

Version numbering continues upstream, and the major version tracks compatibility: `14.x` means
your existing scripts, table maps and user DLLs still work. A future `15.0.0` will be the release
that breaks that, and it will say so.

- ✅ Builds cleanly from a fresh clone on current Visual Studio
- ✅ Repository history preserved in full, with original authorship intact
- ✅ Reproducible release packaging
- ⏳ Part of the v15 pre-release work still pending review — see below

---

## Building

Requires **Visual Studio 2017 or newer**. Tested on VS 2026 (18.9).

**Components** — Visual Studio Installer → Individual components:

- `Desktop development with C++` (workload)
- `MSVC v141 - VS 2017 C++ x64/x86 build tools`
- `C++ MFC for v141 build tools (x86 & x64)`
- `C++ ATL for v141 build tools (x86 & x64)`
- `.NET Framework 4.8 targeting pack` — OpenReplayShooter only

**Steps**

1. Open `OpenHoldem.sln` and accept the .NET 4.8 upgrade prompt for OpenReplayShooter.
2. Retarget the C++ projects to Platform Toolset `v141` and a Windows 10 SDK. `Project → Retarget
   solution` may not be offered; project properties work just as well (All Configurations, All
   Platforms).
3. Build `Release | Win32`. Expected: **18 succeeded, 0 failed, 2 skipped**, in under a minute.

**Things that will waste your time otherwise**

- **Don't take the toolset Visual Studio suggests** (`v145` or newer). This is MultiByte MFC code
  from another era; five compiler generations in one step will not survive. Moving to a current
  toolset is planned as its own release.
- The Windows SDK field needs the **complete** version string (`10.0.22621.0`), not `10.0`.
  Otherwise all projects fail at once with MSB8036, which looks far worse than it is.
- `ManualMode-XMLRPC` and `SymbolDumperUserDll` are deselected for this configuration upstream;
  skipping them is expected.
- Binaries land in `Release\`, except `poker-eval.lib` (`pokereval\Release\`), `SciLexer.lib`
  (`scintilla\bin\`) and `OpenReplayShooter.exe`, which the C# project writes to its own `bin\`.

**Building for Windows XP**

Nothing in the code depends on the toolset. Install the XP support component, retarget to
`v141_xp`, and it builds: no source change, no XP-specific blockers. Official builds use `v141`
only because current Visual Studio installers no longer offer the XP toolset.

### Packaging a release

```
.\scripts\make_release.ps1
```

Assembles the distributable from the release skeleton, the build output and the OpenPPL library,
then produces the zip. Needs no AutoIt, 7-zip or HTML Help Workshop, which the previous process
did. It reads the version from the built executable and warns if `stdafx.h` disagrees.

A compiled build on its own is not a distribution: the bot expects the OpenPPL library and the
supporting folders next to the executable, or it starts and reports missing initialisation
functions.

---

## What is actually useful here

Not code. What this fork is short of is **people who use a thing and can say whether it works**.

Part of the v15 pre-release work is not merged yet — Auto-OCR, the ante guesser, the unwanted
animations filter, enhanced PrWin at script level, special slider swag support, the new
PokerTracker DLL, the project restructure. None of it was rejected. In each case it could not be
verified before release, or it added behaviour nobody had tested in play, or it carried a reported
problem that was never closed.

Each of those was reviewed rather than skipped, and the reasoning is kept: what the change does,
what the concern is, and what would settle it. Ask and you get the full answer. If you use one of
them, testing it is worth more than any patch.

The same goes for fixes that only exist as forum posts. One of them is in this release. There are
probably more.

## Contributing

Issues and Discussions are open — the upstream repository had both disabled, which is a large part
of how it ended up here.

- **Bug reports and build problems:** open an issue
- **Questions about compiling or installing:** Discussions → Build & Install help
- **Strategy, scripts and bot logic:** those belong on the community forum, not here

Pull requests are welcome. Small and self-contained gets merged; large and unverifiable waits for
someone who can verify it. Upstream pull requests are cherry-picked with their original authorship
intact — if you wrote one, your commits still carry your name.

## Credits

OpenHoldem is the work of many people over many years, most of whom never met. The commit history
in this repository is complete and unmodified in that respect: every contribution still carries
its author.

This release merges work by Mudr0x, SalemMaxInMontreal, Stars83, nolog, rub3r0id and Sir_Spin.

## License

GPLv3. See [LICENSE](LICENSE).

You are free to use, modify and redistribute this software. If you distribute a modified version,
you must release the source and state that you changed it. If you are using code from this project
in something you sell, the same obligation applies to you.
