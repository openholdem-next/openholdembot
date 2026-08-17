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

The work on OpenHoldem never stopped — it just stopped landing. Contributions kept arriving through 2025, but
nothing has been merged into the main branch since December 2021, issues are disabled, and there
is nobody available to merge anything.

This fork exists to give that work a home: review the pending contributions, publish builds that
anyone can reproduce, and document how the thing actually works. The goal is to keep the project
going, not to replace what came before.

## Status

**In development. No release yet.**

The first release will be **14.1.0**, continuing upstream version numbering. That is deliberate:
the major version tracks compatibility, so `14.x` tells you your existing scripts, table maps and
user DLLs still work. A future `15.0.0` will be the release that breaks that promise, and it will
say so.

- ✅ Builds cleanly from a fresh clone on current Visual Studio
- ✅ Repository history preserved in full (5,300+ commits, all original authorship)
- ⏳ Pending pull requests being reviewed and integrated
- ⏳ Release packaging not yet reproducible

### Windows XP and Visual Studio 2015

Official builds now target **Windows 7 or later**, and the solution requires **Visual Studio 2017
or newer** to open.

Upstream targeted Windows XP through the `v140_xp` toolset, which needs Visual Studio 2015 and the
Windows 8.1 SDK. Neither installs on a current Visual Studio, and the XP toolset is no longer
offered — so continuing to require it meant requiring a development environment that is currently difficult to set up.

Nothing in the code depends on this: building with an XP-capable toolset is still possible if you
have one. If you need that configuration and can help maintain it, open an issue.

Builds remain **32-bit (Win32) only**, as they always have been: user DLLs must match the host
process bitness, so going 64-bit would invalidate every compiled `user.dll` at once. That belongs
in a major release with a migration guide.

**Scripts, table maps and user DLLs are unaffected** — this is a build-environment change, which
is why the release is still `14.x`.

---

## Building

Requires **Visual Studio 2017 or newer**. Tested on VS 2026 (18.9).

**Components** — Visual Studio Installer → Individual components:

- `Desktop development with C++`
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
  from another era; five compiler generations in one step will not survive. That migration is
  planned as its own release.
- The Windows SDK field needs the **complete** version string (`10.0.22621.0`), not `10.0`.
  Otherwise all projects fail at once with MSB8036, which looks far worse than it is.
- `Release - Optimized`, `Template` and `profile` are orphaned configurations that exist in only
  some projects and still point at `v140_xp`. Use `Release`. Despite the name,
  `Release - Optimized` is *less* optimised than `Release`.
- `ManualMode-XMLRPC` and `SymbolDumperUserDll` are deselected for this configuration upstream;
  skipping them is expected.
- Binaries land in `Release\`, except `poker-eval.lib` (`pokereval\Release\`) and `SciLexer.lib`
  (`scintilla\bin\`).

**A compiled build is not a distribution.** The bot expects the OpenPPL library and supporting
folders next to the executable; without them it starts and reports missing initialisation
functions. Reproducible packaging is in progress.

---

## Contributing

Issues and Discussions are open — the upstream repository had both disabled, which is a large part
of how it ended up here.

- **Bug reports and build problems:** open an issue
- **Questions about compiling or installing:** Discussions → Build & Install help
- **Strategy, scripts and bot logic:** those belong on the community forum, not here

Pull requests are welcome. Existing upstream pull requests are being cherry-picked with their
original authorship intact — if you wrote one, your commits will still carry your name.

## Credits

OpenHoldem is the work of many people over many years, most of whom never met. The commit
history in this repository is complete and unmodified in that respect: every contribution still
carries its author.

Particular thanks to the contributors whose pending work this fork exists to publish.

## License

GPLv3. See [LICENSE](LICENSE).

You are free to use, modify and redistribute this software. If you distribute a modified version,
you must release the source and state that you changed it. If you are using code from this project
in something you sell, the same obligation applies to you.
