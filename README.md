# Terraria macOS Dependency

Automates the retrieval and rebuilding of Terraria’s 64-bit (x86_64) runtime libraries, tuned for optimal performance and hassle-free setup on Apple-silicon (M-series) Macs. While aimed at smoother gameplay and developer quality-of-life, the custom libraries may introduce compatibility or functional deviations from the stock distribution.

---

## What this script does

1. **Installs pre-built dependencies** (`jpeg`, `libogg`, `openal-soft`, `libpng`, `sdl2_image`, `theora`, `libvorbis`) through an **Intel-only Homebrew** installation.  
2. **Builds from source**:
   * **SDL 2.32.8**
   * **FAudio 25.07**
   * **FNA3D 24.12** (with MojoShader)
   * **Theorafile**  
3. Copies every resulting `.dylib` into `./terraria-deps/lib`.

Result: `./terraria-deps/lib` holds a neat, redistributable set of `.dylib`s you can then copy and replace directly to Terraria's package contents.

---

## Prerequisites

| Requirement | Why it’s needed | Install command |
|-------------|-----------------|-----------------|
| **Xcode Command-Line Tools** | compilers, `git`, `cmake`, etc. | `xcode-select --install` |
| **Rosetta 2** <br>(Apple-silicon only) | runs Intel-only Homebrew and compilers | `softwareupdate --install-rosetta --agree-to-license` |
| **x86_64 Homebrew** (in `/usr/local`) | consistent, Intel-only formulae | <pre>arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"</pre> |

> **Note** – You may keep your native `/opt/homebrew` installation; this script explicitly invokes the Intel one via `/usr/local/bin/brew`.

---

## Quick-start

```bash
git clone https://github.com/ricardoramo-s/terraria-macos-deps.git
cd terraria-macos-deps

# Run the script
sh build-deps.sh
````

When it finishes you should see:

```
All done! Libraries are in /Users/<you>/terraria-deps/lib
```

---

## Detailed walk-through

1. **Open Terminal** and verify the Command-Line Tools are present:

   ```bash
   xcode-select -p
   ```

   If the path is empty, run `xcode-select --install`.

2. **Install Rosetta 2** (Apple-silicon only):

   ```bash
   softwareupdate --install-rosetta --agree-to-license
   ```

3. **Install Intel Homebrew** (skip if `/usr/local/bin/brew` already exists):

   ```bash
   arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

4. **Run `build-deps.sh`**
   The script will:

   * Create `./terraria-deps`
   * Install the required formulae through Intel Brew
   * Clone & build SDL, FAudio, FNA3D, MojoShader, Theorafile
   * Copy everything into `./terraria-deps/lib`

5. **Verify**:

   ```bash
   ls ./terraria-deps/lib
   # libFAudio.0.dylib  libFNA3D.0.dylib  libjpeg.9.dylib  ...
   ```

6. **Use**:

   You may then copy and replace all the `.dylib` files inside of `./terraria-deps/lib` into `Terraria.app/Contents/MacOS/osx`.

---

## Library versions

| Library            | Version / Tag      | Notes                                                                |
| ------------------ | ------------------ | -------------------------------------------------------------------- |
| SDL                | 2.32.8             | Apple-silicon fixes included                                         |
| FAudio             | 25.07              | Matches latest FNA requirements                                      |
| FNA3D + MojoShader | 24.12              | Built as shared libs. Newer versions break compatibility with Vulkan.|
| Theorafile         | HEAD at build time | Static makefile build                                                |
| Homebrew deps      | As of script run   | jpeg, libpng, libogg, libvorbis, theora, openal-soft, sdl2\_image    |

---

## Cleaning up or rebuilding

```bash
rm -rf ./terraria-deps
```

Then re-run the script.

---

## Troubleshooting

| Symptom                            | Fix                                                                                                                                 |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| *“command not found: brew”*        | Ensure Intel Homebrew is at `/usr/local/bin/brew` and you’re invoking via `arch -x86_64`.                                           |
| *CMake cannot find XXXX*           | Verify `CMAKE_PREFIX_PATH`, `CMAKE_INCLUDE_PATH`, and `CMAKE_LIBRARY_PATH` are set by the script; wipe `./terraria-deps` and retry. |

---

## License

This build script is released under the **MIT License**—see [LICENSE](LICENSE) for details.
Individual third-party libraries retain their own licenses; consult each project’s repository.

---
