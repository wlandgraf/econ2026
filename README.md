***English** · [Português (Brasil)](README.pt-BR.md)*

# TMS Smart Setup — Sample Project

A tiny Delphi VCL app whose only job is to demonstrate [TMS Smart Setup](https://www.smartsetup.org):
installing components, snapshotting their exact versions, restoring them on another machine, and
building the whole thing — dependencies included — from a CI/CD agent.

It depends on two third-party libraries, neither of them a TMS product, both from the
[community registry](https://github.com/tmssoftware/smartsetup-registry):

| Library | Product id | Used in the app for |
|---|---|---|
| [Spring4D](https://bitbucket.org/sglienke/spring4d) | `sglienke.spring4d` | `Shared<TStringList>` smart pointer |
| [Virtual TreeView](https://github.com/JAM-Software/Virtual-TreeView) | `jam.virtualtreeview` | the `TVirtualStringTree` on the form |

**Requirements:** [Smart Setup 3.5+](https://github.com/tmssoftware/smartsetup/releases),
Delphi 13 / RAD Studio 37.0 with Win32, and Git. No credentials needed — both dependencies are
open source.

---

## Where you run `tms` matters

Smart Setup is folder-based: whatever folder you run `tms` from is the **workspace**, and that's
where it downloads, builds and tracks components.

- **As a developer**, you run `tms` from your own Smart Setup workspace — the folder holding all
  the components installed in your IDE. That workspace belongs to your *IDE*, not to any single
  project, so every project you work on shares it. It's not the folder `tms.exe` lives in, and
  it's not this repository: installing a new component is always `tms install` from the workspace.
- **On a CI/CD agent**, you run `tms` from the repository root. The [tms.config.yaml](tms.config.yaml)
  committed here makes that folder a throwaway workspace (`__smartsetup/`, gitignored) and turns
  off IDE registration, so the build never touches machine state.

Everything below follows from that split.

---

## 1. Install the dependencies (developer)

From your Smart Setup workspace folder — *not* from this repo:

```
cd C:\your-smartsetup-workspace
tms install sglienke.spring4d jam.virtualtreeview
```

Smart Setup clones both, resolves their dependencies, builds the packages and registers the
design-time ones in the IDE. Now open [source/SampleProject.dproj](source/SampleProject.dproj):
`TVirtualStringTree` is on the palette, the form opens in the designer, the project compiles. No
library paths were edited by hand.

Handy: `tms list`, `tms list-remote`, `tms log-view`, [`tms doctor`](https://doc.tmssoftware.com/smartsetup/guide/doctor.html).

## 2. Save the snapshot (developer)

Still from your workspace, writing to this repo with a full path:

```
tms snapshot C:\path\to\econ2026\tms.snapshot.yaml
```

[tms.snapshot.yaml](tms.snapshot.yaml) is committed and records exact versions — a git commit hash
for Virtual TreeView, release `2.0.2` for Spring4D.

## 3. Restore on a new machine or a new IDE (developer)

The reason the snapshot is in the repo. On a fresh Delphi install, from your workspace:

```
cd C:\your-smartsetup-workspace
tms restore C:\path\to\econ2026\tms.snapshot.yaml -auto-register
```

Same components, same versions, registered and ready. Add `-latest` to restore the same *set* of
products at their newest versions instead of the pinned ones.

## 4. Build from CI/CD

Only here do you run `tms` from the repository root:

```
cd C:\path\to\econ2026
tms restore tms.snapshot.yaml -skip-register
```

One command: it downloads the pinned versions into `__smartsetup/`, builds them, then builds every
project in the repo that has a `tmsbuild.yaml` — including the app itself. The executable lands in
`source/Win32/Release/SampleProject.exe`. Nothing is registered in any IDE.

Use `tms build` afterwards for incremental rebuilds (`-full` to force a clean one).

See the [continuous integration guide](https://doc.tmssoftware.com/smartsetup/guide/continuous-integration.html).

---

## The files that make this work

| File | Role |
|---|---|
| [tms.config.yaml](tms.config.yaml) | **CI only.** Sets `working folder: __smartsetup`, `skip register: true`, and pins the build to `delphi13` / `win32intel` so a misconfigured agent fails visibly. Your developer workspace uses its own config, not this one. |
| [tms.snapshot.yaml](tms.snapshot.yaml) | The exact dependency versions. Committed. |
| [source/tmsbuild.yaml](source/tmsbuild.yaml) | Declares the app *itself* as a Smart Setup product: `SampleProject: [exe, vcl]` plus `dependencies: all.installed.components`, so Smart Setup builds Spring4D and Virtual TreeView before linking the exe. See [creating bundles](https://doc.tmssoftware.com/smartsetup/guide/creating-bundles.html). |

Not in the repo: no vendored sources, no `.dcu`/`.bpl`, no absolute library paths in the `.dproj`.

Running a different Delphi? Adjust `delphi versions` and `platforms` in `tms.config.yaml`, and
`ide since:` in `source/tmsbuild.yaml`. Nothing else.

---

## Demo script

The history was built one step at a time and doubles as a running order:

| Commit | Step |
|---|---|
| `32be5e0` | `tms install sglienke.spring4d` → use `Shared<T>` in the form |
| `df1613b` | `tms install jam.virtualtreeview` → drop a `TVirtualStringTree` from the palette |
| `4d178ea` | `tms snapshot` → commit the versions |
| `3673660` | Commit the untouched `tms config` output, so that… |
| `f43f70f` | …`git show f43f70f -- tms.config.yaml` is a clean six-setting CI diff, not 210 lines of boilerplate |

---

Full documentation: [doc.tmssoftware.com/smartsetup](https://doc.tmssoftware.com/smartsetup) ·
`tms help <command>`
